import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_keur/app/core/feedback/interaction_feedback.dart';
import 'package:woutalma_keur/app/domain/discovery.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/voice_service.dart';
import 'package:woutalma_keur/app/modules/client/explore/voice_overlay.dart';

import '../support/pump.dart';
import '../support/recording_feedback_service.dart';

/// Ne comprend jamais rien : c'est le cas qui décide si le parcours vocal est
/// utilisable.
class _DeafVoiceService implements VoiceService {
  @override
  bool get isSimulated => true;

  @override
  Future<VoiceCommand?> listen() async => null;
}

void main() {
  testWidgets('l\'écoute est confirmée au doigt, sans avoir à regarder', (
    WidgetTester tester,
  ) async {
    final RecordingFeedbackService feedback = await pumpWk(
      tester,
      VoiceOverlay(
        service: SimulatedVoiceService(delay: const Duration(milliseconds: 10)),
      ),
    );

    await tester.pump();
    expect(feedback.countOf(FeedbackIntent.recordingStarted), 1);

    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();
    expect(feedback.countOf(FeedbackIntent.recordingStopped), 1);
  });

  testWidgets('la commande comprise est relue avant d\'être appliquée', (
    WidgetTester tester,
  ) async {
    final RecordingFeedbackService feedback = await pumpWk(
      tester,
      VoiceOverlay(
        service: SimulatedVoiceService(delay: const Duration(milliseconds: 10)),
      ),
    );

    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();

    // Le texte compris est affiché **et** annoncé : rien n'est appliqué sur
    // une interprétation que personne n'a vue.
    expect(find.text('Maison à louer près d\'ici'), findsOneWidget);
    expect(feedback.announcements, contains('Maison à louer près d\'ici'));
  });

  testWidgets('ne rien comprendre propose un exemple, pas un reproche', (
    WidgetTester tester,
  ) async {
    final RecordingFeedbackService feedback = await pumpWk(
      tester,
      VoiceOverlay(service: _DeafVoiceService()),
    );

    await tester.pumpAndSettle();

    expect(find.text('Je n\'ai pas compris'), findsOneWidget);
    expect(
      find.text('Dites par exemple : maison à louer près d\'ici.'),
      findsOneWidget,
    );
    expect(feedback.countOf(FeedbackIntent.error), 1);
  });

  testWidgets('la simulation est annoncée honnêtement', (
    WidgetTester tester,
  ) async {
    await pumpWk(
      tester,
      VoiceOverlay(
        service: SimulatedVoiceService(delay: const Duration(milliseconds: 10)),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();

    // Laisser croire à une reconnaissance réelle se paierait au premier essai.
    expect(
      find.text('Reconnaissance simulée : le moteur réel arrive plus tard.'),
      findsOneWidget,
    );
  });

  test('le script simulé couvre plusieurs intentions', () async {
    final SimulatedVoiceService service = SimulatedVoiceService(
      delay: Duration.zero,
    );

    final VoiceCommand first = (await service.listen())!;
    final VoiceCommand second = (await service.listen())!;

    expect(first.filters.transaction, TransactionKind.rent);
    expect(second.filters.transaction, TransactionKind.sale);
    // Chaque commande porte des filtres exploitables, pas seulement du texte.
    expect(first.filters.isEmpty, isFalse);
  });

  test('un script vide se comporte comme « rien compris »', () async {
    final SimulatedVoiceService service = SimulatedVoiceService(
      delay: Duration.zero,
      script: const <VoiceCommand>[],
    );

    expect(await service.listen(), isNull);
  });

  testWidgets('à ×1.3, tout le contenu reste atteignable', (
    WidgetTester tester,
  ) async {
    // Repéré à l'écran : la mention « reconnaissance simulée » était coupée
    // par le bas de l'écran, et rien ne permettait d'aller la chercher.
    await pumpWk(
      tester,
      VoiceOverlay(service: _DeafVoiceService()),
      textScale: 1.3,
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Annuler'), 100);
    expect(find.text('Annuler'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('les filtres vocaux remplacent sans effacer la recherche texte', () {
    const DiscoveryFilters heard = DiscoveryFilters(
      transaction: TransactionKind.rent,
      kind: PropertyKind.house,
    );

    final DiscoveryFilters merged = heard.copyWith(query: 'Mermoz');

    expect(merged.query, 'Mermoz');
    expect(merged.kind, PropertyKind.house);
  });
}
