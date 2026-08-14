import { Injectable, ServiceUnavailableException, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { OAuth2Client } from 'google-auth-library';
import { AuthProvider, VerifiedIdentity } from './auth-provider.interface';

@Injectable()
export class GoogleAuthProvider implements AuthProvider {
  readonly name = 'google';

  private readonly client: OAuth2Client | null;
  private readonly clientId: string | undefined;

  constructor(config: ConfigService) {
    // Resolved lazily rather than with getOrThrow. A deployment that has no
    // Google OAuth client must still boot — it just cannot serve this one
    // route. Throwing here would take the whole API down, and would also make
    // scripts/emit-openapi.ts (which boots AppModule) need a client id just to
    // write a JSON file.
    this.clientId = config.get<string>('GOOGLE_CLIENT_ID');
    this.client = this.clientId ? new OAuth2Client(this.clientId) : null;
  }

  get isConfigured(): boolean {
    return this.client !== null;
  }

  async verify(idToken: string): Promise<VerifiedIdentity> {
    if (!this.client || !this.clientId) {
      throw new ServiceUnavailableException('Google sign-in is not configured on this deployment.');
    }
    const ticket = await this.client.verifyIdToken({ idToken, audience: this.clientId }).catch(() => null);
    const payload = ticket?.getPayload();
    if (!payload || !payload.sub) {
      throw new UnauthorizedException('Invalid Google ID token');
    }
    return {
      subject: payload.sub,
      email: payload.email ?? null,
      emailVerified: payload.email_verified ?? false,
    };
  }
}
