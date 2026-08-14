import 'dart:async';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:woutalma_api_client/woutalma_api_client.dart' as api;
import 'package:woutalma_keur/app/data/services/token_store.dart';
import 'package:woutalma_keur/app/domain/auth_service.dart';

/// Real `real`-mode AuthService: Google Sign-In on-device, verified and
/// exchanged for a session by the backend's POST /auth/google
/// (backend/src/auth/providers/google-auth.provider.ts). `AuthService`'s own
/// docstring already frames the seam this fills: "le jour où un vrai
/// fournisseur SMS arrive, il prend cette place sans qu'un écran bouge."
///
/// Only signInWithGoogle() is backed by a real provider this phase — the
/// phone-OTP and email/link methods already declared on AuthService (see
/// docs/PRODUCT.md §8bis: SMS/WhatsApp OTP and email magic-link are
/// deferred) throw a clear UnimplementedError rather than silently
/// pretending to work.
class GoogleBackendAuthService implements AuthService {
  GoogleBackendAuthService({
    required api.AuthApi authApi,
    required TokenStore tokens,
    GoogleSignIn? googleSignIn,
  }) : _authApi = authApi,
       _tokens = tokens,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final api.AuthApi _authApi;
  final TokenStore _tokens;
  final GoogleSignIn _googleSignIn;

  Account? _current;
  bool _googleInitialized = false;

  @override
  bool get isSimulated => false;

  @override
  Account? get current => _current;

  @override
  Future<String?> requestCode(String phone) {
    throw UnimplementedError(
      'Phone OTP is deferred in real mode — see docs/PRODUCT.md §8bis (SMS/WhatsApp OTP not yet built).',
    );
  }

  @override
  Future<OtpResult> verify(String phone, String code) {
    throw UnimplementedError(
      'Phone OTP is deferred in real mode — see docs/PRODUCT.md §8bis (SMS/WhatsApp OTP not yet built).',
    );
  }

  @override
  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
  }) {
    throw UnimplementedError(
      'Email sign-up is deferred in real mode — see docs/PRODUCT.md §8bis (email magic link is Phase 2).',
    );
  }

  @override
  Future<AuthResult> link(AuthProvider provider) {
    throw UnimplementedError(
      'Provider linking is deferred in real mode — only Google Sign-In is wired.',
    );
  }

  @override
  Future<AuthResult> signInWithGoogle() async {
    if (!_googleInitialized) {
      await _googleSignIn.initialize();
      _googleInitialized = true;
    }

    final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
    final String? idToken = googleUser.authentication.idToken;
    if (idToken == null) {
      throw StateError('Google Sign-In did not return an ID token.');
    }

    final api.AuthSessionDto session =
        (await _authApi.authControllerSignInWithGoogle(
          googleSignInDto: api.GoogleSignInDto((b) => b.idToken = idToken),
        )).data!;

    await _tokens.save(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
    );
    _current = Account(
      email: googleUser.email,
      name: googleUser.displayName,
      brokerId: session.brokerId,
      linkedProviders: const <AuthProvider>{AuthProvider.google},
    );
    return AuthResult.signedIn;
  }

  @override
  void signOut() {
    _current = null;
    unawaited(_tokens.clear());
    // Fire-and-forget: nothing downstream depends on Google's own sign-out
    // completing before the local session is considered cleared.
    _googleSignIn.signOut();
  }
}
