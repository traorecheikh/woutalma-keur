import 'package:flutter/foundation.dart';
import 'package:woutalma_keur/app/core/feedback/interaction_feedback.dart';
import 'package:woutalma_keur/app/core/state/mutation_state.dart';
import 'package:woutalma_keur/app/core/state/screen_state.dart';
import 'package:woutalma_keur/app/domain/repositories.dart';

/// Qui utilise l'application en ce moment.
///
/// Le même binaire sert les deux rôles ; seuls les écrans et la barre de
/// navigation changent.
enum UserRole { client, broker }

/// Source des données de l'application.
enum AppMode {
  /// Jeu de démonstration déterministe.
  demo,

  /// Base vide et parcours normal de saisie.
  real,

  /// Le serveur est la source de vérité ; la base locale n'est qu'une copie
  /// hors ligne. Aucun jeu de démonstration ne peut être chargé par-dessus.
  remote,
}

/// Coordonne S01.
class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel({
    required SeedRepository seed,
    AppMode mode = AppMode.demo,
    UserRole role = UserRole.client,
    FeedbackPreferences preferences = const FeedbackPreferences(),
  }) : _seed = seed,
       _mode = mode,
       _role = role,
       _preferences = preferences;

  final SeedRepository _seed;

  AppMode _mode;
  UserRole _role;
  FeedbackPreferences _preferences;
  MutationState _switching = const MutationState.idle();

  AppMode get mode => _mode;
  UserRole get role => _role;
  FeedbackPreferences get preferences => _preferences;
  MutationState get switching => _switching;

  /// Ce que la bascule va détruire. Affiché **avant** de demander confirmation :
  /// « êtes-vous sûr ? » sans chiffre n'informe personne.
  Future<int> impactCount() => _seed.itemCount();

  void setRole(UserRole value) {
    if (_role == value) {
      return;
    }
    _role = value;
    notifyListeners();
  }

  void setPreferences(FeedbackPreferences value) {
    _preferences = value;
    notifyListeners();
  }

  /// Bascule de mode. Purge puis recharge, en une fois.
  ///
  /// Un échec ne doit jamais laisser un mélange des deux jeux de données —
  /// c'est pour ça que la purge et le chargement sont enchaînés ici et pas
  /// répartis dans l'écran.
  Future<bool> toggleMode() async {
    if (_switching.isSubmitting || _mode == AppMode.remote) {
      // Rien à basculer quand les données viennent du serveur : écrire le jeu
      // de démonstration par-dessus une copie hors ligne fabriquerait
      // exactement ce que le mode distant interdit.
      return false;
    }
    _switching = const MutationState.submitting();
    notifyListeners();

    final AppMode target = _mode == AppMode.demo ? AppMode.real : AppMode.demo;
    try {
      if (target == AppMode.demo) {
        await _seed.loadDemoSeed();
      } else {
        await _seed.clearAll();
      }
      _mode = target;
      _switching = const MutationState.success();
    } on Object {
      _switching = const MutationState.failure(WkFailure.seed);
    }
    notifyListeners();
    return _switching is MutationSuccess;
  }
}
