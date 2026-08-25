import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/data/repositories/in_memory_repositories.dart';
import 'package:woutalma_keur/app/data/seed/demo_seed.dart';
import 'package:woutalma_keur/app/domain/discovery.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/location_service.dart';
import 'package:woutalma_keur/app/modules/client/explore/cards.dart';
import 'package:woutalma_keur/app/modules/client/explore/explore_screen.dart';
import 'package:woutalma_keur/app/modules/client/explore/explore_view_model.dart';
import 'package:woutalma_keur/app/modules/client/explore/filters_sheet.dart';
import 'package:woutalma_keur/app/modules/client/explore/search_overlay.dart';
import 'package:woutalma_keur/app/ui/ui.dart';

import '../support/fake_location.dart';
import '../support/pump.dart';

class _Location implements LocationService {
  @override
  Future<LocationResult> current() async =>
      const LocationFound(DemoSeed.clientPosition);
  @override
  Future<bool> hasPermission() async => false;
  @override
  Future<void> openSettings() async {}
  @override
  List<Neighbourhood> knownNeighbourhoods() => dakarNeighbourhoods;
}

void main() {
  late InMemoryStore store;
  late DiscoveryService discovery;

  setUp(() async {
    store = InMemoryStore();
    await InMemorySeedRepository(store).loadDemoSeed();
    discovery = LocalDiscoveryService(
      brokers: InMemoryBrokerRepository(store),
      properties: InMemoryPropertyRepository(store),
      reviews: InMemoryReviewRepository(store),
    );
  });

  Future<ExploreViewModel> pumpHome(
    WidgetTester tester, {
    void Function(String)? onOpenProperty,
    double textScale = 1,
  }) async {
    final model = ExploreViewModel(
      discovery: discovery,
      position: fakePositions(),
    );
    addTearDown(model.dispose);
    await pumpWk(
      tester,
      ChangeNotifierProvider<ExploreViewModel>.value(
        value: model,
        child: ExploreScreen(
          onOpenBroker: (_) {},
          onOpenProperty: onOpenProperty ?? (_) {},
          onOpenSettings: () {},
          location: _Location(),
        ),
      ),
      textScale: textScale,
    );
    await model.load();
    await tester.pumpAndSettle();
    return model;
  }

  testWidgets('l\'accueil montre des rangées, pas une liste', (tester) async {
    await pumpHome(tester);
    expect(find.text('Près de chez vous'), findsOneWidget);
    expect(find.text('Courtiers de confiance'), findsOneWidget);
    expect(find.byType(PropertyCard), findsWidgets);
    expect(find.byType(BrokerCard), findsWidgets);
    expect(find.byType(TextField), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('une vignette ouvre le bon bien', (tester) async {
    String? opened;
    await pumpHome(tester, onOpenProperty: (id) => opened = id);
    final first = tester.widget<PropertyCard>(find.byType(PropertyCard).first);
    await tester.tap(find.byType(PropertyCard).first);
    await tester.pumpAndSettle();
    expect(opened, first.property.id);
  });

  testWidgets('une catégorie ouvre les résultats déjà filtrés', (tester) async {
    final model = await pumpHome(tester);
    await tester.scrollUntilVisible(
      find.text('Terrain'),
      120,
      scrollable: find.byType(Scrollable).at(1),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Terrain'));
    await tester.pumpAndSettle();
    expect(find.byType(SearchOverlay), findsOneWidget);
    expect(model.filters.kind, PropertyKind.land);
    expect(find.textContaining('résultat'), findsWidgets);
  });

  testWidgets('la recherche filtre pendant la frappe', (tester) async {
    final model = await pumpHome(tester);
    await tester.tap(find.byType(AppSearchPill));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Mermoz');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(model.filters.query, 'Mermoz');
    expect(find.byType(PropertyCard), findsWidgets);
  });

  testWidgets('les filtres annoncent le nombre de résultats', (tester) async {
    await pumpWk(
      tester,
      Builder(
        builder: (context) => Center(
          child: AppButton(
            'ouvrir',
            onPressed: () => FiltersSheet.show(
              context,
              initial: const DiscoveryFilters(),
              countResults: (f) async => (await discovery.findProperties(
                from: DemoSeed.clientPosition,
                filters: f,
              )).length,
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('ouvrir'));
    await tester.pumpAndSettle();
    expect(find.text('Voir 9 résultats'), findsOneWidget);
    final lands = (await discovery.findProperties(
      from: DemoSeed.clientPosition,
      filters: const DiscoveryFilters(kind: PropertyKind.land),
    )).length;
    await tester.ensureVisible(find.text('Terrain'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Terrain'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(find.text('Voir $lands résultats'), findsOneWidget);
  });

  testWidgets('à ×1.3 rien ne déborde', (tester) async {
    await pumpHome(tester, textScale: 1.3);
    expect(tester.takeException(), isNull);
  });
}
