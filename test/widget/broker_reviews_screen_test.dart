import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/data/repositories/in_memory_repositories.dart';
import 'package:woutalma_keur/app/modules/broker/broker_reviews_screen.dart';

import '../support/pump.dart';

void main() {
  testWidgets('les avis reçus restent lisibles à ×1.3', (
    WidgetTester tester,
  ) async {
    final InMemoryStore store = InMemoryStore();
    await InMemorySeedRepository(store).loadDemoSeed();
    final BrokerReviewsViewModel model = BrokerReviewsViewModel(
      reviews: InMemoryReviewRepository(store),
      brokerId: 'brk-fatou',
    );
    await model.load();
    addTearDown(model.dispose);

    await pumpWk(
      tester,
      ChangeNotifierProvider<BrokerReviewsViewModel>.value(
        value: model,
        child: BrokerReviewsScreen(onBack: () {}),
      ),
      surfaceSize: const Size(360, 760),
      textScale: 1.3,
    );
    await tester.pumpAndSettle();

    expect(find.text('Avis reçus'), findsOneWidget);
    expect(find.text('En modération'), findsWidgets);
    expectNoClippedText(tester);
    expectTouchTargets(tester);
  });
}
