import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_keur/app/domain/discovery.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/modules/client/explore/filters_sheet.dart';

import '../support/pump.dart';

void main() {
  Future<void> openSheet(
    WidgetTester tester, {
    required Future<int> Function(DiscoveryFilters filters) countResults,
    DiscoveryFilters initial = const DiscoveryFilters(),
  }) async {
    await pumpWk(
      tester,
      Builder(
        builder: (BuildContext context) => Center(
          child: TextButton(
            onPressed: () => FiltersSheet.show(
              context,
              initial: initial,
              countResults: countResults,
            ),
            child: const Text('ouvrir'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('ouvrir'));
    await tester.pumpAndSettle();
  }

  testWidgets('un comptage en échec le dit au lieu de charger sans fin', (
    WidgetTester tester,
  ) async {
    await openSheet(
      tester,
      countResults: (_) async => throw Exception('réseau coupé'),
    );

    // Avant : le bouton restait sur « Un instant… » pour toujours, tout en
    // restant tapable.
    expect(find.text('Un instant…'), findsNothing);
    expect(
      find.text('Le nombre de résultats n\'a pas pu être compté.'),
      findsOneWidget,
    );
    expect(find.text('Appliquer les filtres'), findsOneWidget);
  });

  testWidgets('appliquer reste possible quand le comptage a échoué', (
    WidgetTester tester,
  ) async {
    DiscoveryFilters? applied;
    await pumpWk(
      tester,
      Builder(
        builder: (BuildContext context) => Center(
          child: TextButton(
            onPressed: () async {
              applied = await FiltersSheet.show(
                context,
                initial: const DiscoveryFilters(
                  transaction: TransactionKind.sale,
                ),
                countResults: (_) async => throw Exception('réseau coupé'),
              );
            },
            child: const Text('ouvrir'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('ouvrir'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Appliquer les filtres'));
    await tester.pumpAndSettle();

    // Le compteur n'est qu'un aperçu : son échec ne doit pas retenir
    // l'utilisateur dans la feuille.
    expect(applied?.transaction, TransactionKind.sale);
  });

  testWidgets('un changement de filtre ne part pas au premier appui', (
    WidgetTester tester,
  ) async {
    int calls = 0;
    await openSheet(
      tester,
      initial: const DiscoveryFilters(transaction: TransactionKind.sale),
      countResults: (_) async {
        calls++;
        return 3;
      },
    );
    expect(calls, 1, reason: 'comptage initial');

    await tester.tap(find.text('Tout enlever'));
    await tester.pump();

    // Chaque option touchée est un aller-retour réseau : il attend que la
    // main s'arrête.
    await tester.pump(const Duration(milliseconds: 100));
    expect(calls, 1);

    await tester.pump(const Duration(milliseconds: 300));
    expect(calls, 2);
  });
}
