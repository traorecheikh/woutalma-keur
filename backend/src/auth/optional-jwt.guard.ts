import { Injectable } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

/// Lets a public route recognise a signed-in caller without demanding one.
///
/// `AuthGuard('jwt')` answers 401 as soon as the Authorization header is
/// missing, expired or malformed. Some routes are public but serve *more* to
/// the account that owns the data — `GET /reviews/broker/:id` is the case
/// this exists for: anyone may read the published reviews of a broker, only
/// that broker may also read the ones still awaiting moderation.
///
/// A bad or stale token is treated as "anonymous", not as an error: a public
/// broker page must not start failing because the phone's access token
/// expired between two screens.
@Injectable()
export class OptionalJwtAuthGuard extends AuthGuard('jwt') {
  handleRequest<TUser = any>(_err: any, user: any): TUser {
    return (user || undefined) as TUser;
  }
}
