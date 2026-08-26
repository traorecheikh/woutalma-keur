import 'dart:async' show unawaited;
import 'dart:ui' show FlutterView, PlatformDispatcher;

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:woutalma_keur/app/core/feedback/interaction_feedback.dart';
import 'package:woutalma_keur/app/domain/voice_service.dart';

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
    VoiceService? voice,
  }) : _preferences = preferences,
       _screenReaderActive = screenReaderActive,
       _voice = voice,
       _viewResolver =
           viewResolver ?? (() => PlatformDispatcher.instance.implicitView);

  /// L'annonce sémantique est rattachée à une vue depuis Flutter 3.35.
  /// L'application est mono-fenêtre, donc la vue implicite est la bonne ; le
  /// paramètre existe pour les tests.
  final FlutterView? Function() _viewResolver;

  FeedbackPreferences _preferences;
  bool _screenReaderActive;

  /// Créée au premier besoin : la plupart des sessions ne parlent jamais, et
  /// un moteur de synthèse ouvert au démarrage coûterait à tout le monde.
  VoiceService? _voice;

  /// Identités déjà émises. Vidée par écran via [forgetScope].
  final Set<String> _consumed = <String>{};

  @override
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
    if (_preferences.sounds) {
      _earcon(intent);
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
  Future<void> speak(String text, {bool spontaneous = false}) async {
    announce(text);
    // Le lecteur d'écran vient de dire la même chose ; parler par-dessus
    // rendrait les deux inaudibles.
    if (_screenReaderActive || text.trim().isEmpty) {
      return;
    }
    if (spontaneous && !_preferences.guidedVoice) {
      return;
    }
    await (_voice ??= TtsVoiceService()).speak(text);
  }

  @override
  Future<void> stopSpeaking() => _voice?.stop() ?? Future<void>.value();

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
      case FeedbackIntent.preview:
        HapticFeedback.lightImpact();
      case FeedbackIntent.warning:
      case FeedbackIntent.success:
      case FeedbackIntent.recordingStopped:
        HapticFeedback.mediumImpact();
      case FeedbackIntent.error:
        HapticFeedback.heavyImpact();
    }
  }

  /// Les cinq earcons de `docs/INTERACTION-FEEDBACK.md` §5 n'existent pas
  /// encore. En attendant, les sons du système couvrent F4, F5 et F6 : sans
  /// eux le réglage « Sons » ne commanderait rien du tout.
  void _earcon(FeedbackIntent intent) {
    final SystemSoundType? sound = switch (intent) {
      FeedbackIntent.error => SystemSoundType.alert,
      FeedbackIntent.success ||
      FeedbackIntent.warning ||
      FeedbackIntent.recordingStarted ||
      FeedbackIntent.recordingStopped ||
      FeedbackIntent.preview => SystemSoundType.click,
      FeedbackIntent.selection || FeedbackIntent.stepValid => null,
    };
    if (sound == null) {
      return;
    }
    // Pas de canal audio : le son n'est qu'un renfort, le visuel reste
    // complet.
    unawaited(SystemSound.play(sound).catchError((Object _) {}));
  }
}
