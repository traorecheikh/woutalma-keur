import 'package:flutter/foundation.dart';
import 'package:woutalma_keur/app/routes/app_routes.dart';

/// Décide, une seule fois par lancement, si l'application doit se rouvrir dans
/// l'espace courtier.
///
/// Le problème : la session survit au redémarrage, mais sa reprise passe par
/// le réseau (`POST /auth/refresh`). L'attendre avant le premier écran ferait
/// payer un aller-retour à tout le monde, y compris aux visiteurs, alors que
/// la découverte est publique. L'ignorer laissait un courtier repartir dans
/// l'espace client à chaque ouverture — le défaut signalé.
///
/// La sortie retenue : peindre tout de suite la découverte, puis rejoindre
/// l'espace courtier quand la réponse arrive, mais **seulement** si personne
/// n'a encore navigué. Déplacer quelqu'un qui est déjà parti ailleurs serait
/// pire que le défaut corrigé.
class SessionLanding extends ChangeNotifier {
  SessionLanding({
    required Future<void> restore,
    required bool Function() belongsToBrokerSpace,
    Duration window = defaultWindow,
  }) : _belongsToBrokerSpace = belongsToBrokerSpace,
       _window = window {
    // `restore` ne rejette jamais (voir `AppDependencies.sessionRestore`).
    restore.whenComplete(_onRestored);
  }

  /// Au-delà de ce délai, la réponse arrive trop tard pour être une reprise de
  /// session : c'est quelqu'un qui utilise l'application depuis un moment, et
  /// le basculer d'espace sous les doigts serait une surprise. Le cas se
  /// produit sur instance gratuite endormie, où le réveil prend une minute.
  static const Duration defaultWindow = Duration(seconds: 20);

  final bool Function() _belongsToBrokerSpace;
  final Duration _window;
  final Stopwatch _sinceStart = Stopwatch()..start();

  bool _restored = false;

  /// La décision est prise : plus personne n'est déplacé.
  bool _settled = false;

  @visibleForTesting
  bool get settled => _settled;

  void _onRestored() {
    if (_settled) {
      return;
    }
    _restored = true;
    // Réveille le routeur : il rejoue sa redirection sur l'écran courant.
    notifyListeners();
  }

  /// Réponse à la redirection globale du routeur.
  ///
  /// [location] est l'emplacement demandé. Tant qu'il vaut la racine de
  /// départ, personne n'a bougé et la place reste à prendre ; dès qu'il en
  /// change — onglet, lien profond, écran poussé — la décision est classée.
  String? redirect(String location) {
    if (_settled) {
      return null;
    }
    if (location != AppRoutes.explore) {
      // L'utilisateur a choisi où aller avant nous. On ne le contredit pas.
      _settled = true;
      return null;
    }
    if (!_restored) {
      return null;
    }
    _settled = true;
    if (_sinceStart.elapsed > _window) {
      return null;
    }
    return _belongsToBrokerSpace() ? AppRoutes.brokerHome : null;
  }
}
