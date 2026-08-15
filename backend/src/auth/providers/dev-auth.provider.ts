import { createHmac } from 'node:crypto';
import { Injectable, Logger, NotFoundException, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { AuthProvider, VerifiedIdentity } from './auth-provider.interface';

/// Personas this provider can ever mint a token for. A closed allowlist, not
/// a free-form user id: the blast radius of the whole dev path is these two
/// seeded demo accounts, both of which own nothing but seed data.
export const DEV_PERSONAS = ['client', 'broker'] as const;
export type DevPersona = (typeof DEV_PERSONAS)[number];

/// `googleSub` values written by prisma/seed.ts. Signing in as a persona
/// therefore *finds* the seeded user rather than creating a bare one — which
/// is what makes the deployed demo match the local demo screen for screen.
const PERSONA_SUBJECTS: Record<DevPersona, string> = {
  client: 'dev:client',
  broker: 'dev:broker-moussa',
};

const PERSONA_EMAILS: Record<DevPersona, string> = {
  client: 'demo.client@demo.woutalma.sn',
  broker: 'moussa.owner@demo.woutalma.sn',
};

/// Second `AuthProvider` implementation, occupying the seam
/// auth-provider.interface.ts was written for. It exists because no Google
/// OAuth client is available for this deployment, and `/auth/google` is the
/// only way in.
///
/// Deliberately NOT gated on NODE_ENV: the Render deployment is
/// production-shaped and needs this, so a NODE_ENV gate would either be a lie
/// or force NODE_ENV=development on a public service, which changes Express
/// error verbosity. Two explicit secrets plus a fail-closed boot assertion is
/// the honest mechanism.
@Injectable()
export class DevAuthProvider implements AuthProvider {
  readonly name = 'dev';

  private readonly logger = new Logger(DevAuthProvider.name);
  private readonly enabled: boolean;
  private readonly secret: string | undefined;

  constructor(config: ConfigService) {
    // Strict string compare, never truthiness — DEV_AUTH_ENABLED=false must
    // not enable it.
    this.enabled = config.get<string>('DEV_AUTH_ENABLED') === 'true';
    this.secret = config.get<string>('DEV_AUTH_SECRET');

    // Fail closed. You cannot half-enable this: a deployment that asks for
    // dev auth without a real secret refuses to boot rather than exposing an
    // unauthenticated token mint.
    if (this.enabled && (!this.secret || this.secret.length < 32)) {
      throw new Error('DEV_AUTH_ENABLED=true requires DEV_AUTH_SECRET of at least 32 characters.');
    }

    // Second lock, for the one mistake that would actually hurt: shipping a
    // staging config to production. DEV_AUTH_ENABLED is the intent switch;
    // this refuses the combination outright rather than trusting it.
    if (this.enabled && config.get<string>('NODE_ENV') === 'production') {
      throw new Error('DEV_AUTH_ENABLED must not be set when NODE_ENV=production.');
    }

    if (this.enabled) {
      this.logger.warn(
        'DEV AUTH ENABLED — /auth/dev and /auth/dev/otp/* issue real JWTs without any SMS. ' +
          `Personas: ${DEV_PERSONAS.join(', ')}. Never enable this on a production deployment.`,
      );
    }
  }

  get isEnabled(): boolean {
    return this.enabled;
  }

  /// Throws 404 when disabled, so a probe cannot distinguish "route exists but
  /// is off" from "no such route".
  assertEnabled(): void {
    if (!this.enabled) {
      throw new NotFoundException();
    }
  }

  assertSecret(presented: string | undefined): void {
    this.assertEnabled();
    if (!presented || presented !== this.secret) {
      throw new UnauthorizedException('Invalid dev auth secret');
    }
  }

  /// Code à six chiffres pour un numéro, sans SMS.
  ///
  /// Dérivé par HMAC du numéro et du secret, donc stable sans rien stocker :
  /// une instance qui redémarre — ce que fait l'offre gratuite en permanence —
  /// ne perd pas les codes déjà distribués. Il ne tourne pas, ce qui serait
  /// inacceptable ailleurs et sans conséquence sur un environnement de recette
  /// où le code est de toute façon rendu dans la réponse.
  codeFor(phone: string): string {
    this.assertEnabled();
    const digest = createHmac('sha256', this.secret ?? '').update(normalisePhone(phone)).digest();
    return (digest.readUInt32BE(0) % 1_000_000).toString().padStart(6, '0');
  }

  verifyCode(phone: string, code: string): void {
    if (this.codeFor(phone) !== code.trim()) {
      throw new UnauthorizedException('Invalid code');
    }
  }

  /// Identité d'un numéro. Le sujet est préfixé pour ne jamais entrer en
  /// collision avec un `sub` Google.
  identityForPhone(phone: string): VerifiedIdentity {
    this.assertEnabled();
    return {
      subject: `dev:phone:${normalisePhone(phone)}`,
      email: null,
      emailVerified: false,
    };
  }

  /// `token` is the persona name. Re-validated here even though the DTO
  /// already restricts it — the provider is the thing that must be safe.
  async verify(token: string): Promise<VerifiedIdentity> {
    this.assertEnabled();
    if (!DEV_PERSONAS.includes(token as DevPersona)) {
      throw new UnauthorizedException('Unknown dev persona');
    }
    const persona = token as DevPersona;
    return {
      subject: PERSONA_SUBJECTS[persona],
      email: PERSONA_EMAILS[persona],
      emailVerified: true,
    };
  }
}

/// Un seul numéro doit toujours donner la même identité, qu'il ait été saisi
/// avec un « + », des espaces ou des tirets.
export function normalisePhone(phone: string): string {
  return phone.replace(/[^0-9]/g, '');
}
