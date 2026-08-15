/// Configuration de compilation.
///
/// `String.fromEnvironment` plutôt qu'un fichier lu au démarrage : la valeur
/// est constante, donc repliée à la compilation et éliminée par le
/// tree-shaking, et surtout elle est disponible **avant** `runApp` sans le
/// moindre accès disque. Un `.env` chargé de façon asynchrone ajouterait une
/// attente là où l'application doit déjà se lever vite.
///
/// Build local contre l'émulateur Android :
///
/// ```sh
/// flutter run \
///   --dart-define=WK_API_BASE_URL=http://10.0.2.2:3000 \
///   --dart-define=WK_DEV_AUTH=true
/// ```
///
/// Build hors ligne (Isar + jeu de démonstration, aucun réseau) :
///
/// ```sh
/// flutter run --dart-define=WK_API_BASE_URL=
/// ```
abstract final class AppConfig {
  /// Racine de l'API. Vide = mode local.
  static const String apiBaseUrl = String.fromEnvironment(
    'WK_API_BASE_URL',
    defaultValue: 'https://woutalma-api.onrender.com',
  );

  /// Ouvre `POST /auth/dev` côté application.
  ///
  /// Aucun client OAuth Google n'est configuré sur ce déploiement ; sans ce
  /// drapeau il n'existe aucun moyen de se connecter. Le secret n'est **pas**
  /// compilé dans l'application : le serveur l'exige en en-tête, donc un build
  /// avec `WK_DEV_AUTH=true` ne suffit pas à ouvrir une session sur un
  /// déploiement qui n'a pas activé ce chemin.
  static const bool devAuth = bool.fromEnvironment('WK_DEV_AUTH');

  /// Secret `x-dev-auth-secret`. Vide sur un build distribué.
  static const String devAuthSecret = String.fromEnvironment(
    'WK_DEV_AUTH_SECRET',
  );

  /// Ouvre le catalogue des composants dans les réglages.
  ///
  /// Faux par défaut, y compris en debug : une passe de recette se fait sur un
  /// build de debug, et une galerie de composants au milieu des réglages n'a
  /// rien à y faire. `--dart-define=WK_DEV_TOOLS=true` la rend au concepteur.
  static const bool showDeveloperTools = bool.fromEnvironment('WK_DEV_TOOLS');

  /// Vrai quand l'application doit parler au serveur.
  static bool get isRemote => apiBaseUrl.isNotEmpty;
}
