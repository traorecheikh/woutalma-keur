import 'package:woutalma_keur/app/core/feedback/interaction_feedback.dart';

/// Double de test : enregistre au lieu de faire vibrer.
///
/// C'est ce qui permet d'affirmer « exactement une erreur par transition »
/// plutôt que de l'espérer.
class RecordingFeedbackService implements InteractionFeedbackService {
  final List<FeedbackIntent> intents = <FeedbackIntent>[];
  final List<String> announcements = <String>[];
  final Set<String> _consumed = <String>{};

  int countOf(FeedbackIntent intent) =>
      intents.where((FeedbackIntent i) => i == intent).length;

  void clear() {
    intents.clear();
    announcements.clear();
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
  void forgetScope(String scope) {
    _consumed.removeWhere((String id) => id.startsWith('$scope:'));
  }
}
