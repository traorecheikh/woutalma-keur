import 'package:flutter/foundation.dart';

/// Identité locale de la personne qui utilise l'application.
@immutable
class Account {
  const Account({
    this.phone,
    this.email,
    this.name,
    this.brokerId,
    this.linkedProviders = const <AuthProvider>{AuthProvider.phone},
  });

  /// Au format international, tel que saisi.
  final String? phone;

  final String? email;

  final String? name;

  /// Le profil courtier rattaché, s'il existe. `null` pour un client.
  final String? brokerId;

  final Set<AuthProvider> linkedProviders;

  String get displayIdentity => phone ?? email ?? name ?? '';

  bool get needsProfileSetup => brokerId == null;
}

/// Résultat d'une vérification de code.
enum OtpResult { verified, wrongCode, tooManyAttempts }

enum AuthProvider { phone, email, google }

enum AuthResult { signedIn, linked, cancelled }

/// Envoie un code et vérifie l'identité.
///
/// Abstrait dès maintenant : le jour où un vrai fournisseur SMS arrive, il
/// prend cette place sans qu'un écran bouge. Les fournisseurs sociaux suivent
/// le même contrat : l'UI ne connaît pas le SDK concret.
abstract class AuthService {
  /// Envoie un code au numéro. Renvoie le code **seulement** quand l'envoi est
  /// simulé — c'est ce qui permet de le montrer honnêtement à l'écran.
  Future<String?> requestCode(String phone);

  Future<OtpResult> verify(String phone, String code);

  Future<AuthResult> signInWithGoogle();

  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
  });

  Future<AuthResult> link(AuthProvider provider);

  /// Compte identifié, ou `null`.
  Account? get current;

  void signOut();

  /// Vrai quand aucun SMS n'est réellement envoyé.
  bool get isSimulated;
}

/// Implémentation de la phase UX.
///
/// Aucun SMS n'est envoyé et le code est constant. Il est **affiché à
/// l'écran** : cacher un code qu'on n'envoie pas rendrait le parcours
/// intestable, et laisser croire à un vrai SMS serait pire.
class SimulatedAuthService implements AuthService {
  SimulatedAuthService({
    this.code = '123456',
    this.maxAttempts = 5,
    Map<String, String> brokerByPhone = const <String, String>{},
    Map<String, String> brokerByEmail = const <String, String>{},
  }) : _brokerByPhone = brokerByPhone,
       _brokerByEmail = brokerByEmail;

  final String code;
  final int maxAttempts;

  /// Numéros déjà rattachés à un profil courtier du jeu de démonstration.
  final Map<String, String> _brokerByPhone;
  final Map<String, String> _brokerByEmail;

  Account? _current;
  int _attempts = 0;

  @override
  bool get isSimulated => true;

  @override
  Account? get current => _current;

  @override
  Future<String?> requestCode(String phone) async {
    _attempts = 0;
    return code;
  }

  @override
  Future<OtpResult> verify(String phone, String entered) async {
    if (_attempts >= maxAttempts) {
      return OtpResult.tooManyAttempts;
    }
    if (entered != code) {
      _attempts++;
      return OtpResult.wrongCode;
    }
    _attempts = 0;
    final String normalised = phone.replaceAll(RegExp(r'\D'), '');
    _current = Account(
      phone: phone,
      // Un numéro connu du seed ouvre le profil courtier correspondant ;
      // sinon la personne est un client.
      brokerId: _brokerByPhone[normalised],
    );
    return OtpResult.verified;
  }

  @override
  Future<AuthResult> signInWithGoogle() async {
    _current = const Account(
      email: 'broker.demo@gmail.com',
      name: 'Compte Google',
      linkedProviders: <AuthProvider>{AuthProvider.google},
    );
    return AuthResult.signedIn;
  }

  @override
  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    _current = Account(
      email: email.trim().toLowerCase(),
      brokerId: _brokerByEmail[email.trim().toLowerCase()],
      linkedProviders: const <AuthProvider>{AuthProvider.email},
    );
    return AuthResult.signedIn;
  }

  @override
  Future<AuthResult> link(AuthProvider provider) async {
    final Account? account = _current;
    if (account == null || account.linkedProviders.contains(provider)) {
      return AuthResult.cancelled;
    }
    _current = Account(
      phone: account.phone,
      email: account.email,
      name: account.name,
      brokerId: account.brokerId,
      linkedProviders: <AuthProvider>{...account.linkedProviders, provider},
    );
    return AuthResult.linked;
  }

  @override
  void signOut() {
    _current = null;
    _attempts = 0;
  }
}
