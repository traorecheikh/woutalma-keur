/// Verifies a third-party identity token and returns the stable facts we
/// trust from it. This is the server-side mirror of the Flutter app's
/// `AuthService` seam (lib/app/domain/auth_service.dart): abstract now so a
/// later provider (WhatsApp OTP, SMS OTP, Firebase Phone Auth) slots in
/// beside `GoogleAuthProvider` without `AuthService`/`AuthController`
/// changing shape. Not built yet — see docs/PRODUCT.md §8/§8bis.
export interface VerifiedIdentity {
  /// Provider-stable subject id (e.g. Google's `sub`). Used to find-or-create
  /// the matching `User` row — never re-derived from a mutable field like
  /// email.
  readonly subject: string;
  readonly email: string | null;
  readonly emailVerified: boolean;
}

export interface AuthProvider {
  readonly name: string;
  verify(token: string): Promise<VerifiedIdentity>;
}
