import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/domain/contact_launcher.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/data/repositories/in_memory_repositories.dart';
import 'package:woutalma_keur/app/data/seed/demo_seed.dart';
import 'package:woutalma_keur/app/modules/client/property/property_screen.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_button.dart';

import '../support/pump.dart';

void main() {
  late InMemoryStore store;

  setUp(() async {
    store = InMemoryStore();
    await InMemorySeedRepository(store).loadDemoSeed();
  });

  Future<void> pumpProperty(
    WidgetTester tester, {
    required bool preview,
    Size surfaceSize = const Size(360, 800),
    double textScale = 1,
  }) async {
    final PropertyViewModel model = PropertyViewModel(
      properties: InMemoryPropertyRepository(store),
      brokers: InMemoryBrokerRepository(store),
      contact: ContactService(
        contacts: InMemoryContactRepository(
          store,
          now: () => DateTime(2026, 1, 1),
        ),
        launcher: _NoopLauncher(),
      ),
      propertyId: 'prp-001',
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
      surfaceSize: surfaceSize,
      textScale: textScale,
    );
    await tester.pumpAndSettle();
  }

  testWidgets('l\'aperçu montre la même barre que les clients, inerte', (
    WidgetTester tester,
  ) async {
    // L'écran annonce « Voici ce que voient les clients » : masquer leur
    // barre d'action rendait cette phrase fausse et l'aperçu plus court que
    // la vraie fiche.
    await pumpProperty(tester, preview: true);

    final WkButton contact = tester.widget<WkButton>(
      find.widgetWithText(WkButton, 'Contacter'),
    );
    expect(contact.onPressed, isNull);
    expect(contact.disabledReason, isNotNull);
  });

  testWidgets('sur la vraie fiche, la même barre agit', (
    WidgetTester tester,
  ) async {
    await pumpProperty(tester, preview: false);

    final WkButton contact = tester.widget<WkButton>(
      find.widgetWithText(WkButton, 'Contacter'),
    );
    expect(contact.onPressed, isNotNull);
  });

  testWidgets('le nom du courtier est présenté, pas posé nu', (
    WidgetTester tester,
  ) async {
    await pumpProperty(tester, preview: true);
    await tester.drag(find.byType(ListView), const Offset(0, -360));
    await tester.pumpAndSettle();

    expect(find.text('Proposé par'), findsOneWidget);
    expect(find.text('Moussa Ndiaye'), findsOneWidget);
  });

  testWidgets('la galerie du seed montre un compteur visible', (
    WidgetTester tester,
  ) async {
    await pumpProperty(tester, preview: false);

    expect(find.text('1 sur 3'), findsOneWidget);
  });

  testWidgets('la galerie laisse voir qu\'il y a d\'autres photos', (
    WidgetTester tester,
  ) async {
    await pumpProperty(tester, preview: false);

    final PageView gallery = tester.widget<PageView>(find.byType(PageView));
    expect(gallery.controller?.viewportFraction, lessThan(1));
  });

  testWidgets('la fiche bien reste lisible à 320 dp et ×1.3', (
    WidgetTester tester,
  ) async {
    await pumpProperty(
      tester,
      preview: false,
      surfaceSize: const Size(320, 800),
      textScale: 1.3,
    );

    expect(tester.takeException(), isNull);
  });
}

class _NoopLauncher implements ContactLauncher {
  @override
  Future<bool> open(ContactChannel channel, Broker broker) async => true;
}
