import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/data/repositories/in_memory_repositories.dart';
import 'package:woutalma_keur/app/modules/broker/broker_trust_screens.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_badge.dart';

import '../support/pump.dart';

void main() {
  late InMemoryStore store;

  setUp(() async {
    store = InMemoryStore();
    await InMemorySeedRepository(store).loadDemoSeed();
  });

  Future<BrokerTrustViewModel> trustModel(String brokerId) async {
    final BrokerTrustViewModel model = BrokerTrustViewModel(
      brokers: InMemoryBrokerRepository(store),
      reviews: InMemoryReviewRepository(store),
      brokerId: brokerId,
    );
    await model.load();
    addTearDown(model.dispose);
    return model;
  }

  Future<void> pumpScreen(WidgetTester tester, String brokerId) async {
    final BrokerTrustViewModel model = await trustModel(brokerId);

    await pumpWk(
      tester,
      ChangeNotifierProvider<BrokerTrustViewModel>.value(
        value: model,
        child: BrokerVerificationScreen(onBack: () {}),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('la pastille garde sa taille, elle ne devient pas une bannière', (
    WidgetTester tester,
  ) async {
    // Enfant direct d'un `ListView`, elle recevait toute la largeur : un
    // libellé perdu à gauche d'un bandeau vert, plus du tout une pastille.
    await pumpScreen(tester, 'brk-moussa');

    final double badge = tester.getSize(find.byType(WkBadge)).width;
    final double screen = tester.getSize(find.byType(ListView)).width;

    expect(badge, lessThan(screen / 2));
  });

  testWidgets('un profil non vérifié ne lit pas deux fois la même phrase', (
    WidgetTester tester,
  ) async {
    // L'état initial affichait « Un profil vérifié inspire confiance… » en
    // haut, puis exactement la même chose en dessous du badge.
    await pumpScreen(tester, 'brk-ibrahima');

    expect(
      find.text(
        'Un profil vérifié inspire confiance et remonte dans les résultats.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('le classement reste lisible à ×1.3', (
    WidgetTester tester,
  ) async {
    final BrokerTrustViewModel model = await trustModel('brk-moussa');

    await pumpWk(
      tester,
      ChangeNotifierProvider<BrokerTrustViewModel>.value(
        value: model,
        child: BrokerRankingScreen(onBack: () {}),
      ),
      surfaceSize: const Size(360, 760),
      textScale: 1.3,
    );
    await tester.pumpAndSettle();

    expect(find.text('Mon classement'), findsOneWidget);
    expect(find.text('Proximité du client'), findsOneWidget);
    expectNoClippedText(tester);
    expectTouchTargets(tester);
  });
}
