import 'package:woutalma_keur/app/core/feedback/interaction_feedback.dart';

/// Double de test : enregistre au lieu de faire vibrer.
///
/// C'est ce qui permet d'affirmer « exactement une erreur par transition »
/// plutôt que de l'espérer.
class RecordingFeedbackService implements InteractionFeedbackService {
  final List<FeedbackIntent> intents = <FeedbackIntent>[];
  final List<String> announcements = <String>[];
  final List<String> spoken = <String>[];
  final Set<String> _consumed = <String>{};
  FeedbackPreferences preferences = const FeedbackPreferences();

  int countOf(FeedbackIntent intent) =>
      intents.where((FeedbackIntent i) => i == intent).length;

  void clear() {
    intents.clear();
    announcements.clear();
    spoken.clear();
    _consumed.clear();
  }

  @override
  void emit(FeedbackIntent intent, {String? eventId}) {
    if (eventId != null && !_consumed.add(eventId)) {
      return;
    }
    intents.add(intent);
  }

  @override
  void announce(String message) => announcements.add(message);

  @override
  Future<void> speak(String text, {bool spontaneous = false}) async {
    announcements.add(text);
    if (!spontaneous || preferences.guidedVoice) {
      spoken.add(text);
    }
  }

  @override
  Future<void> stopSpeaking() async {}

  @override
  void forgetScope(String scope) {
    _consumed.removeWhere((String id) => id.startsWith('$scope:'));
  }
}
