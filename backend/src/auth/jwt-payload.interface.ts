import { Role } from '@prisma/client';

/// Distinguishes the two tokens in an AuthSessionDto. Before this existed the
/// access and refresh tokens carried byte-identical claims and differed only
/// in expiry, which meant a long-lived refresh token was silently accepted as
/// a bearer token on every protected route — exactly what a refresh token
/// must not be.
export type TokenType = 'access' | 'refresh';

export interface JwtPayload {
  /// User.id
  sub: string;
  role: Role;
  /// Absent on tokens minted before this claim existed; treated as 'access'
  /// so already-issued sessions keep working.
  typ?: TokenType;
  /// Marks a token minted by DevAuthProvider, so a dev-issued session is
  /// distinguishable in any later audit. Optional — Google-issued tokens omit it.
  prv?: 'dev';
}

export interface AuthenticatedRequestUser {
  userId: string;
  role: Role;
}
