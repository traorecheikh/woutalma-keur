/// Configuration de compilation.
///
/// `String.fromEnvironment` plutôt qu'un fichier lu au démarrage : la valeur
/// est constante, donc repliée à la compilation et éliminée par le
/// tree-shaking, et surtout elle est disponible **avant** `runApp` sans le
/// moindre accès disque. Un `.env` chargé de façon asynchrone ajouterait une
/// attente là où l'application doit déjà se lever vite.
///
/// `flutter run` sans option parle au serveur de recette Render, identification
/// comprise. Build local contre l'émulateur Android :
///
/// ```sh
/// flutter run \
///   --dart-define=WK_API_BASE_URL=http://10.0.2.2:3000 \
///   --dart-define=WK_DEV_AUTH_SECRET=<DEV_AUTH_SECRET du serveur local>
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

  /// Identification de recette (téléphone, code rendu par le serveur).
  ///
  /// Activée par défaut : le serveur de recette n'a pas de client OAuth
  /// Google, et un `flutter run` sans option doit ouvrir une session.
  /// `--dart-define=WK_DEV_AUTH=false` rend le chemin Google.
  static const bool devAuth = bool.fromEnvironment(
    'WK_DEV_AUTH',
    defaultValue: true,
  );

  /// Secret `x-dev-auth-secret` du serveur de recette. Celui de Render est
  /// compilé par défaut ; passer `WK_DEV_AUTH_SECRET` pour un serveur local.
  static const String devAuthSecret = String.fromEnvironment(
    'WK_DEV_AUTH_SECRET',
    defaultValue:
        '1a7f68f1c31043cae51d8ce004134d0098fd171e634bfc2eaced7cfc41ab07e3',
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
