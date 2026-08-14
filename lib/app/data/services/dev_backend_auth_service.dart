import 'dart:async';

import 'package:woutalma_api_client/woutalma_api_client.dart' as api;
import 'package:woutalma_keur/app/data/services/token_store.dart';
import 'package:woutalma_keur/app/domain/auth_service.dart';

/// Personas ouverts par `POST /auth/dev`.
enum DevPersona {
  client('client', 'demo.client@demo.woutalma.sn', 'Client de démonstration'),
  broker('broker', 'moussa.owner@demo.woutalma.sn', 'Moussa Ndiaye');

  const DevPersona(this.wireName, this.email, this.displayName);

  final String wireName;
  final String email;
  final String displayName;
}

/// Identification de développement, adossée à `POST /auth/dev`.
///
/// Classe **distincte** de [GoogleBackendAuthService] et non une branche à
/// l'intérieur : une porte dérobée logée dans l'implémentation destinée à la
/// production finit par atteindre un build de production à la faveur d'une
/// condition mal écrite. Ici, `AppDependencies.remote()` est le seul endroit
/// qui choisit, et le serveur exige de son côté un secret que ce build ne
/// contient pas nécessairement.
///
/// `isSimulated` est **faux** : le jeton obtenu est un vrai JWT signé par le
/// serveur, et l'écran d'identification n'affiche donc pas de code OTP factice.
class DevBackendAuthService implements AuthService {
  DevBackendAuthService({
    required api.AuthApi authApi,
    required TokenStore tokens,
    required String secret,
  }) : _authApi = authApi,
       _tokens = tokens,
       _secret = secret;

  final api.AuthApi _authApi;
  final TokenStore _tokens;
  final String _secret;

  Account? _current;

  @override
  bool get isSimulated => false;

  @override
  Account? get current => _current;

  /// Le bouton Google de G03 ouvre la session cliente : le parcours reste
  /// celui que l'utilisateur connaît, seul le fournisseur derrière change.
  @override
  Future<AuthResult> signInWithGoogle() => signInAs(DevPersona.client);

  Future<AuthResult> signInAs(DevPersona persona) async {
    final api.AuthSessionDto session =
        (await _authApi.authControllerSignInAsDev(
          devSignInDto: api.DevSignInDto(
            (b) => b.persona = api.DevSignInDtoPersonaEnum.valueOf(
              persona.wireName,
            ),
          ),
          xDevAuthSecret: _secret,
        )).data!;

    await _tokens.save(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
    );
    _current = Account(
      email: persona.email,
      name: persona.displayName,
      brokerId: session.brokerId,
      linkedProviders: const <AuthProvider>{AuthProvider.google},
    );
    return AuthResult.signedIn;
  }

  @override
  Future<String?> requestCode(String phone) {
    throw UnimplementedError(
      'Le code par SMS n\'est pas branché — voir docs/PRODUCT.md §8bis.',
    );
  }

  @override
  Future<OtpResult> verify(String phone, String code) {
    throw UnimplementedError(
      'Le code par SMS n\'est pas branché — voir docs/PRODUCT.md §8bis.',
    );
  }

  @override
  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
  }) {
    throw UnimplementedError(
      'L\'inscription par courriel n\'est pas branchée — voir docs/PRODUCT.md §8bis.',
    );
  }

  @override
  Future<AuthResult> link(AuthProvider provider) {
    throw UnimplementedError(
      'Le rattachement de fournisseur n\'est pas branché.',
    );
  }

  @override
  void signOut() {
    _current = null;
    unawaited(_tokens.clear());
  }
}
