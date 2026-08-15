import { Injectable, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { Prisma, Role } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { AuthSessionDto } from './dto/auth-session.dto';
import { JwtPayload } from './jwt-payload.interface';
import { GoogleAuthProvider } from './providers/google-auth.provider';
import { DevAuthProvider, DevPersona, normalisePhone } from './providers/dev-auth.provider';
import { VerifiedIdentity } from './providers/auth-provider.interface';

@Injectable()
export class AuthService {
  constructor(
    private readonly google: GoogleAuthProvider,
    private readonly dev: DevAuthProvider,
    private readonly prisma: PrismaService,
    private readonly jwt: JwtService,
    private readonly config: ConfigService,
  ) {}

  async signInWithGoogle(idToken: string): Promise<AuthSessionDto> {
    return this.sessionFor(await this.google.verify(idToken), false);
  }

  /// Dev sign-in. Deliberately funnels through the same identity → upsert →
  /// issueSession path as Google, so there is exactly one user-resolution code
  /// path and the two cannot diverge.
  async signInAsDev(persona: DevPersona, presentedSecret: string | undefined): Promise<AuthSessionDto> {
    this.dev.assertSecret(presentedSecret);
    return this.sessionFor(await this.dev.verify(persona), true);
  }

  /// Distribue un code sans envoyer de SMS. Recette uniquement.
  requestDevCode(phone: string, presentedSecret: string | undefined): { phone: string; code: string } {
    this.dev.assertSecret(presentedSecret);
    return { phone, code: this.dev.codeFor(phone) };
  }

  /// Vérifie le code et ouvre la session, en créant le compte au premier
  /// passage — l'inscription et la connexion sont le même geste, comme dans le
  /// parcours réel.
  async verifyDevCode(
    phone: string,
    code: string,
    asBroker: boolean,
    presentedSecret: string | undefined,
  ): Promise<AuthSessionDto> {
    this.dev.assertSecret(presentedSecret);
    this.dev.verifyCode(phone, code);

    const identity = this.dev.identityForPhone(phone);
    const user = await this.prisma.user.upsert({
      where: { googleSub: identity.subject },
      update: {},
      create: { googleSub: identity.subject, phone: normalisePhone(phone) },
      include: { brokerProfile: { select: { id: true } } },
    });

    let brokerId = user.brokerProfile?.id ?? null;
    if (asBroker && brokerId === null) {
      brokerId = await this.createStagingBrokerProfile(user.id, phone);
    }
    if (asBroker) {
      await this.prisma.user.update({
        where: { id: user.id },
        data: { activeRole: Role.BROKER },
      });
    }

    return this.issueSession(user.id, asBroker ? Role.BROKER : user.activeRole, brokerId, true);
  }

  /// Profil courtier minimal, pour que le parcours courtier soit atteignable
  /// sans qu'un opérateur intervienne. Non vérifié, sans bien, sans avis :
  /// exactement ce qu'un nouveau courtier verrait.
  private async createStagingBrokerProfile(ownerId: string, phone: string): Promise<string> {
    const id = `brk-staging-${normalisePhone(phone)}`;
    await this.prisma.$executeRaw(Prisma.sql`
      INSERT INTO "brokers" (
        "id", "ownerId", "kind", "name", "phone", "whatsapp", "position", "coverage",
        "logoAsset", "verification", "responseRate", "pinned", "createdAt", "updatedAt"
      ) VALUES (
        ${id}, ${ownerId}, 'INDIVIDUAL'::"BrokerKind", ${`Courtier ${normalisePhone(phone).slice(-4)}`},
        ${phone}, ${phone},
        public.ST_SetSRID(public.ST_MakePoint(-17.4380, 14.6690), 4326)::public.geography,
        ARRAY['Plateau']::text[], NULL, 'NONE'::"VerificationStatus", 0, false, now(), now()
      )
      ON CONFLICT ("id") DO NOTHING
    `);
    return id;
  }

  /// Redeems a refresh token for a fresh pair. Re-reads the user so a role
  /// switch or a newly created broker profile is reflected without a full
  /// sign-in.
  async refresh(refreshToken: string): Promise<AuthSessionDto> {
    let payload: JwtPayload;
    try {
      payload = await this.jwt.verifyAsync<JwtPayload>(refreshToken);
    } catch {
      throw new UnauthorizedException('Invalid or expired refresh token');
    }
    if (payload.typ !== 'refresh') {
      throw new UnauthorizedException('Not a refresh token');
    }

    const user = await this.prisma.user.findUnique({
      where: { id: payload.sub },
      include: { brokerProfile: { select: { id: true } } },
    });
    if (!user) {
      throw new UnauthorizedException('Unknown user');
    }

    return this.issueSession(
      user.id,
      user.activeRole,
      user.brokerProfile?.id ?? null,
      payload.prv === 'dev',
    );
  }

  private async sessionFor(identity: VerifiedIdentity, isDev: boolean): Promise<AuthSessionDto> {
    const user = await this.prisma.user.upsert({
      where: { googleSub: identity.subject },
      update: identity.emailVerified && identity.email ? { email: identity.email } : {},
      create: {
        googleSub: identity.subject,
        email: identity.emailVerified ? identity.email : null,
      },
      include: { brokerProfile: { select: { id: true } } },
    });

    return this.issueSession(user.id, user.activeRole, user.brokerProfile?.id ?? null, isDev);
  }

  private async issueSession(
    userId: string,
    activeRole: AuthSessionDto['activeRole'],
    brokerId: string | null,
    isDev = false,
  ): Promise<AuthSessionDto> {
    const base: JwtPayload = { sub: userId, role: activeRole, ...(isDev ? { prv: 'dev' as const } : {}) };
    const [accessToken, refreshToken] = await Promise.all([
      this.jwt.signAsync(
        { ...base, typ: 'access' },
        { expiresIn: this.config.getOrThrow<string>('JWT_ACCESS_TOKEN_TTL') },
      ),
      this.jwt.signAsync(
        { ...base, typ: 'refresh' },
        { expiresIn: this.config.getOrThrow<string>('JWT_REFRESH_TOKEN_TTL') },
      ),
    ]);
    return { accessToken, refreshToken, userId, activeRole, brokerId };
  }
}
