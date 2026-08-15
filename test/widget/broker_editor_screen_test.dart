import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/data/repositories/in_memory_repositories.dart';
import 'package:woutalma_keur/app/data/seed/demo_seed.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/photo_service.dart';
import 'package:woutalma_keur/app/modules/broker/property_editor_screen.dart';
import 'package:woutalma_keur/app/modules/broker/property_editor_view_model.dart';

import '../support/pump.dart';

/// Aucun accès à l'appareil photo dans un test.
class _NoPhotoService implements PhotoService {
  @override
  int get maxPerProperty => 6;

  @override
  Future<String?> pick(PhotoSource source) async => null;
}

/// B03 vu de l'écran : ce que le courtier tape, et ce qu'il n'a plus à taper.
void main() {
  late InMemoryStore store;

  setUp(() async {
    store = InMemoryStore();
    await InMemorySeedRepository(store).loadDemoSeed();
  });

  Future<void> pumpEditor(
    WidgetTester tester, {
    Property? existing,
    double textScale = 1,
  }) async {
    final PropertyEditorViewModel model = PropertyEditorViewModel(
      properties: InMemoryPropertyRepository(store),
      brokerId: 'brk-moussa',
      fallbackPosition: DemoSeed.clientPosition,
      now: () => DateTime.utc(2026, 8, 1),
      existing: existing,
    );
    addTearDown(model.dispose);

    await pumpWk(
      tester,
      ChangeNotifierProvider<PropertyEditorViewModel>.value(
        value: model,
        child: PropertyEditorScreen(
          photos: _NoPhotoService(),
          onBack: () {},
          onSaved: (String _) {},
        ),
      ),
      surfaceSize: const Size(360, 1600),
      textScale: textScale,
    );
  }

  Future<void> choose(WidgetTester tester, String field, String option) async {
    await tester.tap(find.text(field));
    await tester.pumpAndSettle();
    await tester.tap(find.text(option).last);
    await tester.pumpAndSettle();
  }

  Future<void> next(WidgetTester tester) async {
    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();
  }

  testWidgets('la première étape se traverse sans clavier', (
    WidgetTester tester,
  ) async {
    await pumpEditor(tester);

    expect(find.text('Étape 1 sur 3'), findsOneWidget);
    // Trois questions, trois choix. Le quartier était le dernier champ libre
    // de cette étape : dix à vingt frappes pour un mot que le produit connaît.
    expect(find.byType(TextField), findsNothing);
    expect(find.text('Louer ou vendre'), findsOneWidget);
    expect(find.text('Type de bien'), findsOneWidget);
    expect(find.text('Quartier'), findsOneWidget);
  });

  testWidgets('il n\'y a plus d\'étape « quartier » séparée', (
    WidgetTester tester,
  ) async {
    await pumpEditor(tester);

    await next(tester);
    expect(find.text('Étape 2 sur 3'), findsOneWidget);
    await next(tester);
    expect(find.text('Étape 3 sur 3'), findsOneWidget);
    // Dernière étape : le bouton devient l'enregistrement.
    expect(find.text('Publier le bien'), findsOneWidget);
  });

  testWidgets('le titre est écrit d\'après les choix, et reste corrigeable', (
    WidgetTester tester,
  ) async {
    await pumpEditor(tester);

    await choose(tester, 'Type de bien', 'Appartement');
    await choose(tester, 'Quartier', 'Mermoz');
    await next(tester);

    // Exactement la phrase que le courtier tapait après avoir déjà répondu
    // aux trois questions qui la composent.
    expect(find.text('Appartement à Mermoz'), findsOneWidget);
    expect(
      find.text('Écrit d\'après vos réponses. Corrigez-le si besoin.'),
      findsWidgets,
    );

    await tester.enterText(find.byType(TextField).at(0), 'Chez Awa');
    await tester.pumpAndSettle();

    // La mention disparaît dès la première frappe : à partir de là, le titre
    // est celui du courtier.
    expect(find.text('Appartement à Mermoz'), findsNothing);
  });

  testWidgets('le nombre de pièces entre dans le titre proposé', (
    WidgetTester tester,
  ) async {
    await pumpEditor(tester);

    await choose(tester, 'Quartier', 'Mermoz');
    await next(tester);
    expect(find.text('Appartement à Mermoz'), findsOneWidget);

    // Les pièces se choisissent après la première écriture du titre. Tant que
    // la phrase est encore celle de l'écran, elle suit la réponse.
    await choose(tester, 'Nombre de pièces', '3 pièces');

    expect(find.text('Appartement 3 pièces à Mermoz'), findsOneWidget);
  });

  testWidgets('la description se compose et suit le prix', (
    WidgetTester tester,
  ) async {
    await pumpEditor(tester);

    await choose(tester, 'Quartier', 'Médina');
    await next(tester);

    // Composée à partir des mêmes réponses : rien qui ne soit dans les
    // données, aucun agrément inventé au nom du courtier.
    expect(find.text('Appartement à louer, quartier Médina.'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(1), '350000');
    await tester.pumpAndSettle();

    // Le séparateur de milliers est l'espace fine insécable française : on
    // vérifie la phrase, pas l'octet exact.
    expect(
      find.textContaining('Appartement à louer, quartier Médina. 350'),
      findsOneWidget,
    );
    expect(find.textContaining('F par mois.'), findsOneWidget);
  });

  testWidgets('une description écrite à la main n\'est jamais réécrite', (
    WidgetTester tester,
  ) async {
    await pumpEditor(tester);

    await choose(tester, 'Quartier', 'Médina');
    await next(tester);
    await tester.enterText(
      find.byType(TextField).at(2),
      'Grande cour, eau courante, proche du marché.',
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(1), '350000');
    await tester.pumpAndSettle();

    expect(
      find.text('Grande cour, eau courante, proche du marché.'),
      findsOneWidget,
    );
  });

  testWidgets('un terrain ne demande pas de pièces', (
    WidgetTester tester,
  ) async {
    await pumpEditor(tester);

    await choose(tester, 'Type de bien', 'Terrain');
    await next(tester);

    expect(find.text('Surface'), findsOneWidget);
    expect(find.text('Nombre de pièces'), findsNothing);
  });

  testWidgets('la surface se choisit, elle ne se tape pas', (
    WidgetTester tester,
  ) async {
    await pumpEditor(tester);

    await next(tester);
    await choose(tester, 'Surface', '60 m²');

    expect(find.text('60 m²'), findsOneWidget);
    // Titre, prix, description : les seuls champs de texte restants.
    expect(find.byType(TextField), findsNWidgets(3));
  });

  testWidgets('le statut ne se demande qu\'en modification', (
    WidgetTester tester,
  ) async {
    await pumpEditor(tester);
    await next(tester);
    await next(tester);

    // Publier, c'est rendre disponible. Offrir « Vendu » à un bien qui
    // n'existe pas encore n'a pas de réponse juste.
    expect(find.text('Statut'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    final Property existing = (await InMemoryPropertyRepository(
      store,
    ).byId('prp-001'))!;
    await pumpEditor(tester, existing: existing);
    await next(tester);
    await next(tester);

    expect(find.text('Statut'), findsOneWidget);
  });

  testWidgets('les étapes de saisie ne coupent rien à ×1.3', (
    WidgetTester tester,
  ) async {
    await pumpEditor(tester, textScale: 1.3);

    // Étapes 1 et 2, celles que cette refonte touche. L'étape photos est
    // laissée de côté : `WkPhotoPicker` déborde de 66 dp à ×1.3, un défaut
    // antérieur du composant partagé, signalé à son propriétaire.
    for (int step = 0; step < 2; step++) {
      expectNoClippedText(tester);
      expectTouchTargets(tester, minimum: 56);
      if (step < 1) {
        await next(tester);
      }
    }
  });
}
