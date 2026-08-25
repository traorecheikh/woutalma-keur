import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_keur/app/data/repositories/in_memory_repositories.dart';
import 'package:woutalma_keur/app/data/seed/demo_seed.dart';
import 'package:woutalma_keur/app/domain/discovery.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/modules/client/explore/filters_sheet.dart';

import '../support/pump.dart';

void main() {
  late DiscoveryService discovery;

  setUp(() async {
    final InMemoryStore store = InMemoryStore();
    await InMemorySeedRepository(store).loadDemoSeed();
    discovery = LocalDiscoveryService(
      brokers: InMemoryBrokerRepository(store),
      properties: InMemoryPropertyRepository(store),
      reviews: InMemoryReviewRepository(store),
    );
  });

  Future<int> countBrokers(DiscoveryFilters filters) async {
    final List<BrokerListing> found = await discovery.findBrokers(
      from: DemoSeed.clientPosition,
      filters: filters,
    );
    return found.length;
  }

  Future<DiscoveryFilters? Function()> openSheet(WidgetTester tester) async {
    DiscoveryFilters? applied;
    await pumpWk(
      tester,
      Builder(
        builder: (BuildContext context) => Center(
          child: TextButton(
            onPressed: () async {
              applied = await FiltersSheet.show(
                context,
                initial: const DiscoveryFilters(),
                countResults: countBrokers,
              );
            },
            child: const Text('ouvrir'),
          ),
        ),
      ),
      surfaceSize: const Size(360, 900),
    );
    await tester.tap(find.text('ouvrir'));
    await tester.pumpAndSettle();
    return () => applied;
  }

  testWidgets('le bouton porte le nombre de résultats avant application', (
    WidgetTester tester,
  ) async {
    await openSheet(tester);
    expect(find.text('Voir 6 résultats'), findsOneWidget);
  });

  testWidgets('poser un filtre met le compteur à jour', (
    WidgetTester tester,
  ) async {
    await openSheet(tester);

    await tester.ensureVisible(find.text('Terrain'));
    await tester.tap(find.text('Terrain'));
    await tester.pumpAndSettle();

    expect(find.text('Voir 2 résultats'), findsOneWidget);
  });

  testWidgets('« Peu importe » retire réellement le filtre', (
    WidgetTester tester,
  ) async {
    await openSheet(tester);

    await tester.ensureVisible(find.text('Terrain'));
    await tester.tap(find.text('Terrain'));
    await tester.pumpAndSettle();
    expect(find.text('Voir 2 résultats'), findsOneWidget);

    await tester.ensureVisible(find.text('Peu importe').last);
    await tester.tap(find.text('Peu importe').last);
    await tester.pumpAndSettle();

    expect(find.text('Voir 6 résultats'), findsOneWidget);
  });

  testWidgets('le curseur de distance pose un rayon', (
    WidgetTester tester,
  ) async {
    await openSheet(tester);

    await tester.tap(find.text('Toute la ville'));
    final Finder slider = find.byType(Slider).last;
    await tester.drag(slider, const Offset(-300, 0));
    await tester.pumpAndSettle();

    expect(find.text('1 km autour de moi'), findsOneWidget);
  });

  testWidgets('appliquer renvoie les filtres choisis', (
    WidgetTester tester,
  ) async {
    final DiscoveryFilters? Function() applied = await openSheet(tester);

    await tester.ensureVisible(find.text('À vendre'));
    await tester.tap(find.text('À vendre'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Voir '));
    await tester.pumpAndSettle();

    expect(applied()?.transaction, TransactionKind.sale);
  });
}
