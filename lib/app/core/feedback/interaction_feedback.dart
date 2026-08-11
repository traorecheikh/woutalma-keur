import 'package:flutter/foundation.dart';

/// Intentions sémantiques de `docs/INTERACTION-FEEDBACK.md` §9.
///
/// Un widget demande une intention, jamais une durée de vibration ni un
/// fichier sonore. C'est le service qui décide comment la rendre, en fonction
/// des préférences et de ce que la plateforme sait faire.
enum FeedbackIntent {
  /// Un choix discret a changé : chip, segment, option, étoile.
  selection,

  /// Une étape entière de formulaire vient de devenir franchissable.
  stepValid,

  /// Risque réversible déclenché par l'utilisateur.
  warning,

  /// Soumission échouée, code invalide, opération refusée.
  error,

  /// Tâche durable terminée : avis envoyé, bien publié, contact journalisé.
  success,

  /// Le micro s'ouvre.
  recordingStarted,

  /// Le micro s'arrête ou est annulé.
  recordingStopped,
}

/// Préférences utilisateur, réglables séparément dans S01.
///
/// L'application doit rester entièrement utilisable avec les trois canaux non
/// visuels coupés.
@immutable
class FeedbackPreferences {
  const FeedbackPreferences({
    this.haptics = true,
    this.sounds = true,
    this.guidedVoice = false,
  });

  final bool haptics;
  final bool sounds;

  /// Lecture parlée des résultats. Coupée d'office quand un lecteur d'écran
  /// est actif : les deux ne parlent jamais ensemble.
  final bool guidedVoice;

  FeedbackPreferences copyWith({
    bool? haptics,
    bool? sounds,
    bool? guidedVoice,
  }) {
    return FeedbackPreferences(
      haptics: haptics ?? this.haptics,
      sounds: sounds ?? this.sounds,
      guidedVoice: guidedVoice ?? this.guidedVoice,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is FeedbackPreferences &&
      other.haptics == haptics &&
      other.sounds == sounds &&
      other.guidedVoice == guidedVoice;

  @override
  int get hashCode => Object.hash(haptics, sounds, guidedVoice);
}

/// Point d'entrée unique du retour sensoriel.
///
/// Aucun widget n'appelle `HapticFeedback` ou `SystemSound` directement : sans
/// ce goulot, les préférences, la déduplication et l'accessibilité seraient à
/// réimplémenter dans chaque écran.
abstract class InteractionFeedbackService {
  /// Émet [intent].
  ///
  /// [eventId] suit la forme `<écran>:<intention>:<clé métier>` — par exemple
  /// `B02:success:property-42`. Une même identité n'émet qu'une fois : un
  /// rebuild, un `notifyListeners()` ou une restauration de route ne peuvent
  /// pas rejouer une vibration. La clé est la donnée métier, jamais un index
  /// de liste.
  ///
  /// Sans [eventId], l'émission n'est pas dédupliquée — réservé aux gestes
  /// directs comme une sélection, qu'on veut sentir à chaque fois.
  void emit(FeedbackIntent intent, {String? eventId});

  /// Annonce polie au lecteur d'écran. Chemin d'annonce unique : le guidage
  /// vocal se superpose à lui, il ne le remplace pas.
  void announce(String message);

  /// Oublie les identités consommées d'un écran qui disparaît.
  void forgetScope(String scope);
}
