import 'dart:async' show unawaited;
import 'dart:ui' show FlutterView, PlatformDispatcher;

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:woutalma_keur/app/core/feedback/interaction_feedback.dart';

/// Implémentation réelle, adossée aux primitives haptiques du SDK.
///
/// Flutter n'expose que cinq primitives : `selectionClick`, `lightImpact`,
/// `mediumImpact`, `heavyImpact` et `vibrate`. Il n'existe **pas** d'haptique
/// de notification succès/avertissement/erreur — c'est propre à iOS et
/// inaccessible sans package. Conséquence acceptée et documentée dans
/// `docs/INTERACTION-FEEDBACK.md` §5 : **l'haptique porte une intensité, pas
/// une catégorie.** `warning` et `success` se ressentent pareil ; la catégorie
/// vient toujours du visuel.
class PlatformInteractionFeedbackService implements InteractionFeedbackService {
  PlatformInteractionFeedbackService({
    FeedbackPreferences preferences = const FeedbackPreferences(),
    bool screenReaderActive = false,
    FlutterView? Function()? viewResolver,
  }) : _preferences = preferences,
       _screenReaderActive = screenReaderActive,
       _viewResolver =
           viewResolver ?? (() => PlatformDispatcher.instance.implicitView);

  /// L'annonce sémantique est rattachée à une vue depuis Flutter 3.35.
  /// L'application est mono-fenêtre, donc la vue implicite est la bonne ; le
  /// paramètre existe pour les tests.
  final FlutterView? Function() _viewResolver;

  FeedbackPreferences _preferences;
  bool _screenReaderActive;

  /// Identités déjà émises. Vidée par écran via [forgetScope].
  final Set<String> _consumed = <String>{};

  set preferences(FeedbackPreferences value) => _preferences = value;

  /// Vrai quand TalkBack ou VoiceOver tourne. Le guidage vocal est alors
  /// supprimé pour la session : les deux ne parlent jamais ensemble.
  set screenReaderActive(bool value) => _screenReaderActive = value;

  bool get guidedVoiceAudible =>
      _preferences.guidedVoice && !_screenReaderActive;

  @override
  void emit(FeedbackIntent intent, {String? eventId}) {
    if (eventId != null) {
      // Consommée à l'émission, pas au lancement de l'opération : un vrai
      // réessai après échec doit pouvoir réémettre.
      if (!_consumed.add(eventId)) {
        return;
      }
    }

    if (_preferences.haptics) {
      _haptic(intent);
    }
  }

  @override
  void announce(String message) {
    if (message.isEmpty) {
      return;
    }
    final FlutterView? view = _viewResolver();
    if (view == null) {
      return;
    }
    unawaited(
      SemanticsService.sendAnnouncement(view, message, TextDirection.ltr),
    );
  }

  @override
  void forgetScope(String scope) {
    _consumed.removeWhere((String id) => id.startsWith('$scope:'));
  }

  void _haptic(FeedbackIntent intent) {
    switch (intent) {
      case FeedbackIntent.selection:
        // `selectionClick` est souvent imperceptible sur Android d'entrée de
        // gamme ; `lightImpact` reste le repli quand la sonde le signale.
        HapticFeedback.selectionClick();
      case FeedbackIntent.stepValid:
      case FeedbackIntent.recordingStarted:
        HapticFeedback.lightImpact();
      case FeedbackIntent.warning:
      case FeedbackIntent.success:
      case FeedbackIntent.recordingStopped:
        HapticFeedback.mediumImpact();
      case FeedbackIntent.error:
        HapticFeedback.heavyImpact();
    }
  }
}
