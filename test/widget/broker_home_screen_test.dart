import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/data/repositories/in_memory_repositories.dart';
import 'package:woutalma_keur/app/modules/broker/broker_home_screen.dart';

import '../support/pump.dart';

void main() {
  testWidgets('le résumé courtier respire sur un téléphone étroit', (
    WidgetTester tester,
  ) async {
    final InMemoryStore store = InMemoryStore();
    await InMemorySeedRepository(store).loadDemoSeed();
    final BrokerHomeViewModel model = BrokerHomeViewModel(
      brokers: InMemoryBrokerRepository(store),
      properties: InMemoryPropertyRepository(store),
      reviews: InMemoryReviewRepository(store),
      contacts: InMemoryContactRepository(
        store,
        now: () => DateTime(2026, 1, 1),
      ),
      brokerId: 'brk-moussa',
    );
    await model.load();
    addTearDown(model.dispose);

    await pumpWk(
      tester,
      ChangeNotifierProvider<BrokerHomeViewModel>.value(
        value: model,
        child: BrokerHomeScreen(
          onAddProperty: () {},
          onOpenSettings: () {},
          onOpenReviews: () {},
          onOpenActivity: () {},
          onOpenVerification: () {},
          onOpenRanking: () {},
        ),
      ),
      surfaceSize: const Size(360, 760),
      textScale: 1.3,
    );
    await tester.pumpAndSettle();

    expect(find.text('Résumé'), findsOneWidget);
    expect(find.text('2 biens visibles'), findsOneWidget);
    expect(find.text('1 contact reçu'), findsOneWidget);
    expectNoClippedText(tester);
    expectTouchTargets(tester);
  });
}
