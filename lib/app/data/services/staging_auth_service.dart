import 'dart:async';

import 'package:woutalma_api_client/woutalma_api_client.dart' as api;
import 'package:woutalma_keur/app/data/services/token_store.dart';
import 'package:woutalma_keur/app/domain/auth_service.dart';

/// Identification de recette : le vrai parcours, sans SMS.
///
/// Les écrans G03 et G04 restent exactement ceux de la production — saisie du
/// numéro, puis code à six chiffres. Seule change la façon dont le code
/// voyage : le serveur le renvoie dans la réponse au lieu de l'envoyer par
/// SMS, et l'écran l'affiche parce que [isSimulated] est vrai. Une recette qui
/// contournerait les écrans ne testerait pas les écrans.
///
/// Première connexion d'un numéro = inscription : c'est le serveur qui crée le
/// compte, comme il le fera en production.
///
/// Le secret n'est pas compilé dans un build ordinaire, et le serveur refuse
/// ces routes si le déploiement ne les a pas explicitement ouvertes : un APK de
/// recette pointé sur la production n'ouvre donc rien.
class StagingAuthService implements AuthService {
  StagingAuthService({
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

  /// Demandé sur l'écran G03 et honoré à la vérification : c'est ce qui rend
  /// le parcours courtier atteignable sans qu'un opérateur crée un profil.
  bool signUpAsBroker = false;

  @override
  Account? get current => _current;

  /// Vrai pour que l'écran affiche le code au lieu de le cacher. Rien d'autre
  /// n'est simulé : le jeton rendu est un vrai JWT signé par le serveur.
  @override
  bool get isSimulated => true;

  @override
  Future<String?> requestCode(String phone) async {
    final api.DevRequestCodeResponseDto response =
        (await _authApi.authControllerRequestDevCode(
          xDevAuthSecret: _secret,
          devRequestCodeDto: api.DevRequestCodeDto((b) => b.phone = phone),
        )).data!;
    return response.code;
  }

  @override
  Future<OtpResult> verify(String phone, String code) async {
    try {
      final api.AuthSessionDto session =
          (await _authApi.authControllerVerifyDevCode(
            xDevAuthSecret: _secret,
            devVerifyCodeDto: api.DevVerifyCodeDto(
              (b) => b
                ..phone = phone
                ..code = code
                ..asBroker = signUpAsBroker,
            ),
          )).data!;

      await _tokens.save(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
      );
      _current = Account(
        phone: phone,
        brokerId: session.brokerId,
        linkedProviders: const <AuthProvider>{AuthProvider.phone},
      );
      return OtpResult.verified;
    } on Object {
      return OtpResult.wrongCode;
    }
  }

  /// Le bouton Google ouvre la session cliente de démonstration, celle qui
  /// possède déjà des contacts et un avis — utile pour éprouver l'historique
  /// sans repartir d'un compte vide.
  @override
  Future<AuthResult> signInWithGoogle() async {
    final api.AuthSessionDto session =
        (await _authApi.authControllerSignInAsDev(
          xDevAuthSecret: _secret,
          devSignInDto: api.DevSignInDto(
            (b) => b.persona = api.DevSignInDtoPersonaEnum.client,
          ),
        )).data!;

    await _tokens.save(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
    );
    _current = Account(
      email: 'demo.client@demo.woutalma.sn',
      name: 'Client de démonstration',
      brokerId: session.brokerId,
      linkedProviders: const <AuthProvider>{AuthProvider.google},
    );
    return AuthResult.signedIn;
  }

  @override
  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
  }) {
    throw UnimplementedError(
      'Inscription par courriel non branchée — le numéro suffit en recette.',
    );
  }

  @override
  Future<AuthResult> link(AuthProvider provider) {
    throw UnimplementedError('Rattachement de fournisseur non branché.');
  }

  @override
  void signOut() {
    _current = null;
    signUpAsBroker = false;
    unawaited(_tokens.clear());
  }
}
