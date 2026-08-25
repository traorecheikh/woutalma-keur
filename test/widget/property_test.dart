import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/data/repositories/in_memory_repositories.dart';
import 'package:woutalma_keur/app/data/seed/demo_seed.dart';
import 'package:woutalma_keur/app/domain/contact_launcher.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/modules/client/property/property_screen.dart';
import 'package:woutalma_keur/app/ui/ui.dart';

import '../support/pump.dart';

class _Launcher implements ContactLauncher {
  @override
  Future<bool> open(ContactChannel channel, Broker broker) async => true;
}

void main() {
  late InMemoryStore store;

  setUp(() async {
    store = InMemoryStore();
    await InMemorySeedRepository(store).loadDemoSeed();
  });

  Future<void> pumpProperty(
    WidgetTester tester,
    Property p, {
    bool preview = false,
  }) async {
    await InMemoryPropertyRepository(store).save(p);
    final model = PropertyViewModel(
      propertyId: p.id,
      properties: InMemoryPropertyRepository(store),
      brokers: InMemoryBrokerRepository(store),
      contact: ContactService(
        contacts: InMemoryContactRepository(store, now: () => DateTime(2026)),
        launcher: _Launcher(),
      ),
      from: DemoSeed.clientPosition,
    );
    await model.load();
    addTearDown(model.dispose);
    await pumpWk(
      tester,
      ChangeNotifierProvider<PropertyViewModel>.value(
        value: model,
        child: PropertyScreen(
          onBack: () {},
          onOpenBroker: (_) {},
          publicPreview: preview,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Property fresh({String? voice}) => Property(
    id: 'prp-fresh',
    brokerId: 'brk-teranga',
    kind: PropertyKind.land,
    transaction: TransactionKind.sale,
    title: 'Terrain 300 m² à Mermoz',
    price: 25000000,
    position: const GeoPoint(14.6952, -17.4611),
    neighbourhood: 'Mermoz',
    createdAt: DateTime(2026, 8, 15),
    voiceAsset: voice,
  );

  testWidgets('la fiche montre prix, titre, courtier et contact', (
    tester,
  ) async {
    await pumpProperty(tester, fresh());
    expect(find.textContaining('25'), findsWidgets);
    expect(find.text('Terrain 300 m² à Mermoz'), findsOneWidget);
    expect(find.text('Contacter'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(find.text('Agence Teranga Immo'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('un vocal du courtier est lisible sur la fiche', (tester) async {
    await pumpProperty(tester, fresh(voice: 'api:v1'));
    expect(find.text('Le courtier vous en parle'), findsOneWidget);
    expect(find.byIcon(FIcons.play), findsOneWidget);
  });

  testWidgets('en aperçu, le contact est inactif', (tester) async {
    await pumpProperty(tester, fresh(), preview: true);
    final button = tester.widget<AppButton>(
      find.widgetWithText(AppButton, 'Contacter'),
    );
    expect(button.onPressed, isNull);
  });
}
