import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Où la session est rangée entre deux lancements.
///
/// Abstrait pour que le canal de plateforme n'entre jamais dans
/// `flutter test` : les tests branchent [InMemoryTokenStorage].
abstract class TokenStorage {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

/// Trousseau iOS / KeyStore Android.
///
/// Pas `shared_preferences` : `GET /contacts` renvoie l'historique de mise en
/// relation d'une personne, donc un JWT lisible en clair sur un téléphone
/// rooté est une fuite réelle, pas théorique.
///
/// Options par défaut : depuis la v10 du paquet, Android chiffre déjà via le
/// KeyStore sans réglage, et l'ancien `encryptedSharedPreferences` est
/// déprécié et ignoré.
class SecureTokenStorage implements TokenStorage {
  const SecureTokenStorage([this._storage = const FlutterSecureStorage()]);

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

class InMemoryTokenStorage implements TokenStorage {
  final Map<String, String> _values = <String, String>{};

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async => _values[key] = value;

  @override
  Future<void> delete(String key) async => _values.remove(key);
}

/// Détient la session du mode distant.
///
/// Les jetons sont persistés : le jeton d'accès expire au bout de quinze
/// minutes, donc sans persistance du jeton de rafraîchissement toute session
/// mourrait au premier redémarrage du processus.
///
/// Les accesseurs restent **synchrones** : l'intercepteur les lit à chaque
/// requête, et une lecture disque sur ce chemin coûterait à chaque appel. Le
/// disque n'est touché qu'au démarrage, par [restore], et à l'écriture.
class TokenStore {
  TokenStore([TokenStorage? storage])
    : _storage = storage ?? const SecureTokenStorage();

  static const String _accessKey = 'wk.accessToken';
  static const String _refreshKey = 'wk.refreshToken';
  static const String _identityKey = 'wk.identity';

  final TokenStorage _storage;

  String? _accessToken;
  String? _refreshToken;
  String? _identity;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

  /// Numéro ou courriel de la session, gardé pour pouvoir l'afficher au
  /// prochain lancement sans redemander au serveur.
  String? get identity => _identity;

  /// Recharge la session depuis le stockage sûr. Lecture locale, rapide :
  /// `bootstrap()` peut l'attendre sans retarder le premier écran.
  Future<void> restore() async {
    _accessToken = await _storage.read(_accessKey);
    _refreshToken = await _storage.read(_refreshKey);
    _identity = await _storage.read(_identityKey);
  }

  Future<void> save({
    required String accessToken,
    String? refreshToken,
    String? identity,
  }) async {
    _accessToken = accessToken;
    await _storage.write(_accessKey, accessToken);
    if (refreshToken != null) {
      _refreshToken = refreshToken;
      await _storage.write(_refreshKey, refreshToken);
    }
    if (identity != null) {
      _identity = identity;
      await _storage.write(_identityKey, identity);
    }
  }

  Future<void> clear() async {
    _accessToken = null;
    _refreshToken = null;
    _identity = null;
    await _storage.delete(_accessKey);
    await _storage.delete(_refreshKey);
    await _storage.delete(_identityKey);
  }
}
