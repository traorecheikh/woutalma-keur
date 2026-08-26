import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/data/repositories/in_memory_repositories.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/modules/broker/broker_properties_screen.dart';
import 'package:woutalma_keur/app/ui/ui.dart';

import '../support/pump.dart';

/// B02 : chaque bien doit exposer ses actions **visiblement**. Le glissement
/// et l'appui long ne s'annoncent nulle part, et la cible ne les cherche pas.
void main() {
  late InMemoryStore store;
  late BrokerPropertiesViewModel model;

  setUp(() async {
    store = InMemoryStore();
    await InMemorySeedRepository(store).loadDemoSeed();
    model = BrokerPropertiesViewModel(
      properties: InMemoryPropertyRepository(store),
      brokerId: 'brk-moussa',
    );
    await model.load();
    addTearDown(model.dispose);
  });

  Future<void> pumpList(
    WidgetTester tester, {
    void Function(Property)? onEdit,
  }) async {
    await pumpWk(
      tester,
      ChangeNotifierProvider<BrokerPropertiesViewModel>.value(
        value: model,
        child: BrokerPropertiesScreen(
          onAdd: () {},
          onEdit: onEdit ?? (_) {},
          onPreview: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('chaque bien porte un bouton « Plus d\'actions »', (
    WidgetTester tester,
  ) async {
    await pumpList(tester);

    final int shown = model.state.valueOrNull!.length;
    expect(find.byIcon(FIcons.ellipsis), findsNWidgets(shown));
    // Le picto ne suffit pas : le lecteur d'écran doit le nommer.
    expect(
      find.byWidgetPredicate(
        (Widget w) => w is Semantics && w.properties.label == 'Plus d\'actions',
      ),
      findsNWidgets(shown),
    );
  });

  testWidgets('ce bouton ouvre les actions, sans geste caché', (
    WidgetTester tester,
  ) async {
    await pumpList(tester);

    await tester.tap(find.byIcon(FIcons.ellipsis).first);
    await tester.pumpAndSettle();

    expect(find.text('Modifier le bien'), findsOneWidget);
    expect(find.text('Supprimer'), findsOneWidget);
    // Le geste le plus fréquent, en un appui, sans passer par la liste des
    // trois statuts.
    expect(find.text('Marquer vendu ou loué'), findsOneWidget);
  });

  testWidgets('« Marquer vendu ou loué » clôt le bien après confirmation', (
    WidgetTester tester,
  ) async {
    await pumpList(tester);
    final Property first = model.state.valueOrNull!.first;

    await tester.tap(find.byIcon(FIcons.ellipsis).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Marquer vendu ou loué'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Changer le statut').last);
    await tester.pumpAndSettle();

    expect(
      (await InMemoryPropertyRepository(store).byId(first.id))!.status,
      PropertyStatus.closed,
    );
  });

  testWidgets('un bien clos propose de le remettre disponible', (
    WidgetTester tester,
  ) async {
    final Property first = model.state.valueOrNull!.first;
    await InMemoryPropertyRepository(
      store,
    ).save(first.copyWith(status: PropertyStatus.closed));
    await model.load();
    await pumpList(tester);

    await tester.tap(find.byIcon(FIcons.ellipsis).first);
    await tester.pumpAndSettle();

    expect(find.text('Remettre disponible'), findsOneWidget);
  });
}
