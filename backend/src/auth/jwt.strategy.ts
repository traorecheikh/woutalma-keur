import { Injectable, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { AuthenticatedRequestUser, JwtPayload } from './jwt-payload.interface';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(config: ConfigService) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: config.getOrThrow<string>('JWT_SECRET'),
    });
  }

  validate(payload: JwtPayload): AuthenticatedRequestUser {
    // A refresh token is redeemable only at POST /auth/refresh. Accepting it
    // as a bearer token here would give a 30-day credential the reach of a
    // 15-minute one.
    if (payload.typ === 'refresh') {
      throw new UnauthorizedException('Refresh token cannot be used as an access token');
    }
    return { userId: payload.sub, role: payload.role };
  }
}
