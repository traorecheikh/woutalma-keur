import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/data/repositories/in_memory_repositories.dart';
import 'package:woutalma_keur/app/data/seed/demo_seed.dart';
import 'package:woutalma_keur/app/domain/contact_launcher.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/modules/client/broker/broker_screen.dart';
import 'package:woutalma_keur/app/modules/client/broker/broker_view_model.dart';

import '../support/pump.dart';

void main() {
  testWidgets('la fiche courtier commence par une carte de confiance lisible', (
    WidgetTester tester,
  ) async {
    final InMemoryStore store = InMemoryStore();
    await InMemorySeedRepository(store).loadDemoSeed();

    final BrokerViewModel model = BrokerViewModel(
      brokerId: 'brk-teranga',
      brokers: InMemoryBrokerRepository(store),
      properties: InMemoryPropertyRepository(store),
      reviews: InMemoryReviewRepository(store),
      contact: ContactService(
        contacts: InMemoryContactRepository(
          store,
          now: () => DateTime(2026, 1, 1),
        ),
        launcher: _NoopLauncher(),
      ),
      from: DemoSeed.clientPosition,
    );
    await model.load();
    addTearDown(model.dispose);

    await pumpWk(
      tester,
      ChangeNotifierProvider<BrokerViewModel>.value(
        value: model,
        child: BrokerScreen(onBack: () {}, onOpenProperty: (_) {}),
      ),
      surfaceSize: const Size(360, 640),
      textScale: 1.3,
    );
    await tester.pumpAndSettle();

    expect(find.text('Agence Teranga Immo'), findsOneWidget);
    expect(find.text('Mis en avant'), findsOneWidget);
    expect(find.text('Vérifié'), findsOneWidget);
    expect(find.text('Répond à 78 % des demandes'), findsOneWidget);
    expect(find.text('Contacter'), findsOneWidget);
    expectNoClippedText(tester);
    expectTouchTargets(tester);
  });
}

class _NoopLauncher implements ContactLauncher {
  @override
  Future<bool> open(ContactChannel channel, Broker broker) async => true;
}
