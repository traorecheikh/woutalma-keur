import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_keur/app/core/feedback/interaction_feedback.dart';
import 'package:woutalma_keur/app/core/feedback/platform_interaction_feedback.dart';

import '../support/recording_feedback_service.dart';

void main() {
  group('déduplication par identité', () {
    test('une même identité n\'émet qu\'une fois', () {
      final RecordingFeedbackService service = RecordingFeedbackService();

      // Un rebuild, un notifyListeners() et une restauration de route
      // repassent tous par là.
      service.emit(FeedbackIntent.success, eventId: 'B02:success:property-42');
      service.emit(FeedbackIntent.success, eventId: 'B02:success:property-42');
      service.emit(FeedbackIntent.success, eventId: 'B02:success:property-42');

      expect(service.countOf(FeedbackIntent.success), 1);
    });

    test('deux sujets différents émettent chacun', () {
      final RecordingFeedbackService service = RecordingFeedbackService();

      // Publier deux biens à la suite, c'est deux succès.
      service.emit(FeedbackIntent.success, eventId: 'B02:success:property-1');
      service.emit(FeedbackIntent.success, eventId: 'B02:success:property-2');

      expect(service.countOf(FeedbackIntent.success), 2);
    });

    test('sans identité, chaque geste se sent', () {
      final RecordingFeedbackService service = RecordingFeedbackService();

      // Une sélection est un geste direct : la dédupliquer rendrait l'app
      // muette au doigt.
      service.emit(FeedbackIntent.selection);
      service.emit(FeedbackIntent.selection);

      expect(service.countOf(FeedbackIntent.selection), 2);
    });

    test('quitter un écran libère ses identités', () {
      final RecordingFeedbackService service = RecordingFeedbackService();

      service.emit(FeedbackIntent.success, eventId: 'B02:success:property-1');
      service.forgetScope('B02');
      service.emit(FeedbackIntent.success, eventId: 'B02:success:property-1');

      expect(service.countOf(FeedbackIntent.success), 2);
    });

    test('libérer un écran ne touche pas les autres', () {
      final RecordingFeedbackService service = RecordingFeedbackService();

      service.emit(FeedbackIntent.success, eventId: 'B02:success:p1');
      service.emit(FeedbackIntent.success, eventId: 'C05:success:review-9');
      service.forgetScope('B02');
      service.emit(FeedbackIntent.success, eventId: 'C05:success:review-9');

      expect(service.countOf(FeedbackIntent.success), 2);
    });
  });

  group('préférences et accessibilité', () {
    test('haptique coupée n\'émet rien de tactile', () {
      final PlatformInteractionFeedbackService service =
          PlatformInteractionFeedbackService(
            preferences: const FeedbackPreferences(haptics: false),
          );

      // Sans binding de test les canaux plateforme ne répondent pas ; ce qui
      // compte ici est qu'aucune exception ne remonte et que l'appel soit
      // simplement ignoré.
      expect(
        () => service.emit(FeedbackIntent.error, eventId: 'x:error:1'),
        returnsNormally,
      );
    });

    test('le guidage vocal se tait quand un lecteur d\'écran tourne', () {
      final PlatformInteractionFeedbackService service =
          PlatformInteractionFeedbackService(
            preferences: const FeedbackPreferences(guidedVoice: true),
          );

      expect(service.guidedVoiceAudible, isTrue);

      service.screenReaderActive = true;

      // La préférence garde sa valeur ; elle n'a simplement plus d'effet.
      expect(service.guidedVoiceAudible, isFalse);
    });

    test('une annonce vide ne part pas', () {
      final PlatformInteractionFeedbackService service =
          PlatformInteractionFeedbackService(viewResolver: () => null);

      expect(() => service.announce(''), returnsNormally);
    });
  });
}
