import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/data/repositories/in_memory_repositories.dart';
import 'package:woutalma_keur/app/modules/broker/broker_properties_screen.dart';

import '../support/pump.dart';

void main() {
  late BrokerPropertiesViewModel model;

  setUp(() async {
    final InMemoryStore store = InMemoryStore();
    await InMemorySeedRepository(store).loadDemoSeed();
    model = BrokerPropertiesViewModel(
      properties: InMemoryPropertyRepository(store),
      brokerId: 'brk-moussa',
    );
    await model.load();
  });

  tearDown(() => model.dispose());

  Future<void> pumpScreen(WidgetTester tester, {double textScale = 1}) async {
    await pumpWk(
      tester,
      ChangeNotifierProvider<BrokerPropertiesViewModel>.value(
        value: model,
        child: BrokerPropertiesScreen(
          onAdd: () {},
          onEdit: (_) {},
          onPreview: (_) {},
        ),
      ),
      textScale: textScale,
    );
    await tester.pumpAndSettle();
  }

  testWidgets('aucune action du bien n\'est coupée à 360 dp', (
    WidgetTester tester,
  ) async {
    // Vu à l'écran : « Change… », « Aperçu … », « Modifie… ». Trois des
    // quatre actions étaient illisibles parce qu'elles tenaient à deux par
    // ligne.
    await pumpScreen(tester);

    expectNoClippedText(tester);
  });

  testWidgets('à ×1.3 non plus', (WidgetTester tester) async {
    await pumpScreen(tester, textScale: 1.3);

    // Les titres de biens viennent du courtier : les couper au bout de deux
    // lignes garde la liste parcourable, et la fiche complète est à un geste.
    expectNoClippedText(
      tester,
      userContent: <String>{
        'Maison 4 pièces à Médina',
        'Studio meublé au Plateau',
      },
    );
  });

  testWidgets('chaque action garde une cible atteignable', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester);

    expectTouchTargets(tester, minimum: 56);
  });
}
