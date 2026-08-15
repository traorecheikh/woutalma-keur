import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/core/feedback/interaction_feedback.dart';
import 'package:woutalma_keur/app/data/repositories/in_memory_repositories.dart';
import 'package:woutalma_keur/app/data/seed/demo_seed.dart';
import 'package:woutalma_keur/app/domain/photo_service.dart';
import 'package:woutalma_keur/app/modules/broker/property_editor_screen.dart';
import 'package:woutalma_keur/app/modules/broker/property_editor_view_model.dart';

import '../support/pump.dart';
import '../support/recording_feedback_service.dart';

/// Aucun accès à l'appareil photo dans un test.
class _NoPhotoService implements PhotoService {
  @override
  int get maxPerProperty => 6;

  @override
  Future<String?> pick(PhotoSource source) async => null;
}

void main() {
  late InMemoryStore store;
  late PropertyEditorViewModel model;

  setUp(() async {
    store = InMemoryStore();
    await InMemorySeedRepository(store).loadDemoSeed();
    model = PropertyEditorViewModel(
      properties: InMemoryPropertyRepository(store),
      brokerId: 'brk-moussa',
      fallbackPosition: DemoSeed.clientPosition,
      now: () => DateTime.utc(2026, 8, 1),
    );
  });

  Future<RecordingFeedbackService> pumpEditor(WidgetTester tester) {
    return pumpWk(
      tester,
      ChangeNotifierProvider<PropertyEditorViewModel>.value(
        value: model,
        child: PropertyEditorScreen(
          photos: _NoPhotoService(),
          onBack: () {},
          onSaved: (String _) {},
        ),
      ),
      surfaceSize: const Size(360, 1400),
    );
  }

  /// Le quartier est un choix, pas une frappe : c'est le geste réel.
  Future<void> chooseNeighbourhood(WidgetTester tester, String name) async {
    await tester.tap(find.text('Quartier'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(name).last);
    await tester.pumpAndSettle();
  }

  Future<void> next(WidgetTester tester) async {
    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();
  }

  Future<void> goToPublish(WidgetTester tester) async {
    await next(tester);
    await next(tester);
  }

  testWidgets('soumettre un formulaire vide montre ce qui manque', (
    WidgetTester tester,
  ) async {
    final RecordingFeedbackService feedback = await pumpEditor(tester);

    await goToPublish(tester);
    await tester.tap(find.text('Publier le bien'));
    await tester.pumpAndSettle();

    // Le bouton n'était pas grisé : c'est en appuyant qu'on apprend. Encore
    // faut-il que quelque chose s'affiche — sans déclencheur de
    // revalidation, l'écran restait muet et le bouton semblait cassé.
    //
    // La première étape fautive est ici l'étape 1 : sans quartier, rien
    // d'autre ne peut être jugé, et le sélecteur porte son propre message.
    expect(find.text('Étape 1 sur 3'), findsOneWidget);
    expect(find.text('Ce champ est nécessaire'), findsOneWidget);
    // Une erreur pour la soumission entière, pas une par champ vide.
    expect(feedback.countOf(FeedbackIntent.error), 1);
    expect(
      feedback.announcements,
      contains('Corrigez le premier champ signalé'),
    );
  });

  testWidgets('corriger un champ efface son message sans nouvelle soumission', (
    WidgetTester tester,
  ) async {
    await pumpEditor(tester);
    await chooseNeighbourhood(tester, 'Ouakam');
    await next(tester);
    // Le titre est écrit par l'écran ; on l'efface pour se retrouver dans le
    // cas qui nous intéresse, un champ requis vide.
    await tester.enterText(find.byType(TextField).at(0), '');
    await next(tester);

    await tester.tap(find.text('Publier le bien'));
    await tester.pumpAndSettle();
    expect(find.text('Ce champ est nécessaire'), findsWidgets);

    await tester.enterText(
      find.byType(TextField).at(0),
      'Villa 5 pièces à Ouakam',
    );
    await tester.pump();

    // Une fois en erreur, chaque frappe revalide : la correction se voit
    // immédiatement.
    expect(find.text('Ce champ est nécessaire'), findsNothing);
    expect(find.text('Indiquez un nombre plus grand que zéro'), findsOneWidget);
  });

  testWidgets('un formulaire complet publie et signale un succès', (
    WidgetTester tester,
  ) async {
    final RecordingFeedbackService feedback = await pumpEditor(tester);

    await chooseNeighbourhood(tester, 'Ouakam');
    await next(tester);
    await tester.enterText(find.byType(TextField).at(0), 'Villa à Ouakam');
    await tester.enterText(find.byType(TextField).at(1), '650000');
    await next(tester);

    await tester.tap(find.text('Publier le bien'));
    await tester.pumpAndSettle();

    expect(feedback.countOf(FeedbackIntent.success), 1);
    expect(feedback.countOf(FeedbackIntent.error), 0);
    expect(store.properties.length, 11);
  });
}
