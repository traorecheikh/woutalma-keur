import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/data/repositories/in_memory_repositories.dart';
import 'package:woutalma_keur/app/data/seed/demo_seed.dart';
import 'package:woutalma_keur/app/domain/discovery.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/location_service.dart';
import 'package:woutalma_keur/app/domain/repositories.dart';
import 'package:woutalma_keur/app/modules/client/explore/explore_screen.dart';
import 'package:woutalma_keur/app/modules/client/explore/explore_view_model.dart';
import 'package:woutalma_keur/app/modules/client/explore/search_overlay.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_avatar.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_broker_card.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_broker_tile.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_property_card.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_property_tile.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_search_bar.dart';

import '../support/fake_location.dart';
import '../support/hardcoded_text.dart';
import '../support/pump.dart';

void main() {
  late InMemoryStore store;
  late DiscoveryService discovery;
  late SeedRepository seed;

  setUp(() async {
    store = InMemoryStore();
    seed = InMemorySeedRepository(store);
    discovery = LocalDiscoveryService(
      brokers: InMemoryBrokerRepository(store),
      properties: InMemoryPropertyRepository(store),
      reviews: InMemoryReviewRepository(store),
    );
    await seed.loadDemoSeed();
  });

  Future<ExploreViewModel> pumpExplore(
    WidgetTester tester, {
    void Function(String)? onOpenProperty,
    double textScale = 1,
    Size surfaceSize = const Size(360, 800),
  }) async {
    final ExploreViewModel model = ExploreViewModel(
      discovery: discovery,
      position: fakePositions(),
    );
    addTearDown(model.dispose);

    await pumpWk(
      tester,
      ChangeNotifierProvider<ExploreViewModel>.value(
        value: model,
        child: ExploreScreen(
          onOpenBroker: (String _) {},
          onOpenProperty: onOpenProperty ?? (String _) {},
          onOpenSettings: () {},
          location: _FixedLocationService(),
        ),
      ),
      textScale: textScale,
      surfaceSize: surfaceSize,
    );

    await model.load();
    await tester.pumpAndSettle();
    return model;
  }

  testWidgets('l\'accueil montre des rangées, pas une liste de résultats', (
    WidgetTester tester,
  ) async {
    await pumpExplore(tester);

    expect(find.text('Près de chez vous'), findsOneWidget);
    expect(find.text('Courtiers de confiance'), findsOneWidget);
    expect(find.byType(WkPropertyTile), findsWidgets);
    expect(find.byType(WkBrokerTile), findsWidgets);
    expect(find.byType(WkPropertyCard), findsNothing);
    expect(find.byType(WkBrokerCard), findsNothing);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('les courtiers de confiance sont classés, épinglé en tête', (
    WidgetTester tester,
  ) async {
    await pumpExplore(tester);

    final WkBrokerTile first = tester.widget<WkBrokerTile>(
      find.byType(WkBrokerTile).first,
    );
    expect(first.listing.broker.id, 'brk-teranga');
    expect(find.text('AT'), findsWidgets);
  });

  testWidgets('les biens près de chez vous sont triés par distance', (
    WidgetTester tester,
  ) async {
    await pumpExplore(tester);

    final List<WkPropertyTile> tiles = tester
        .widgetList<WkPropertyTile>(find.byType(WkPropertyTile))
        .toList();
    final List<double> nearby = tiles
        .take(3)
        .map((WkPropertyTile t) => t.distanceMeters)
        .toList();
    expect(nearby, orderedEquals(List<double>.of(nearby)..sort()));
  });

  testWidgets('une catégorie ouvre les résultats déjà filtrés', (
    WidgetTester tester,
  ) async {
    final ExploreViewModel model = await pumpExplore(tester);

    await tester.ensureVisible(find.text('Terrain').first);
    await tester.tap(find.text('Terrain').first);
    await tester.pumpAndSettle();

    expect(find.byType(SearchOverlay), findsOneWidget);
    expect(model.filters.kind, PropertyKind.land);
    expect(find.byType(WkPropertyCard), findsWidgets);
    expect(find.textContaining('résultat'), findsWidgets);
  });

  testWidgets('la barre ouvre les résultats, un quartier suggéré les filtre', (
    WidgetTester tester,
  ) async {
    final ExploreViewModel model = await pumpExplore(tester);

    await tester.tap(find.byType(WkSearchTrigger));
    await tester.pumpAndSettle();
    expect(find.byType(SearchOverlay), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Mer');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.text('Mermoz'), findsWidgets);

    await tester.tap(find.text('Mermoz').first);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(model.filters.query, 'Mermoz');

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.byType(SearchOverlay), findsNothing);
    expect(find.text('Près de chez vous'), findsOneWidget);
  });

  testWidgets('toucher une vignette ouvre la fiche du bon bien', (
    WidgetTester tester,
  ) async {
    String? opened;
    await pumpExplore(tester, onOpenProperty: (String id) => opened = id);

    final WkPropertyTile first = tester.widget<WkPropertyTile>(
      find.byType(WkPropertyTile).first,
    );
    await tester.ensureVisible(find.byType(WkPropertyTile).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(WkPropertyTile).first);
    await tester.pumpAndSettle();

    expect(opened, first.property.id);
  });

  testWidgets('la carte est atteignable depuis l\'accueil', (
    WidgetTester tester,
  ) async {
    final ExploreViewModel model = await pumpExplore(tester);

    await tester.ensureVisible(find.text('Carte'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Carte'));
    await tester.pumpAndSettle();

    expect(find.byType(SearchOverlay), findsOneWidget);
    expect(model.view, ExploreView.map);
    expect(find.text('Liste'), findsOneWidget);
  });

  testWidgets('une recherche sans résultat propose une sortie', (
    WidgetTester tester,
  ) async {
    await pumpExplore(tester);

    await tester.tap(find.byType(WkSearchTrigger));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'zzzzzz');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.text('Personne dans cette zone'), findsOneWidget);
  });

  testWidgets('aucun texte visible n\'est écrit en dur', (
    WidgetTester tester,
  ) async {
    await pumpExplore(tester);

    final Set<String> data = <String>{};
    for (final Broker b in await InMemoryBrokerRepository(store).all()) {
      data
        ..add(b.name)
        ..add(WkAvatar.initials(b.name))
        ..addAll(b.coverage);
    }
    for (final Property p in await InMemoryPropertyRepository(store).all()) {
      data
        ..add(p.title)
        ..add(p.neighbourhood);
    }
    expectNoHardcodedText(tester, data: data);
  });

  testWidgets('à ×1.3 rien ne déborde', (WidgetTester tester) async {
    await pumpExplore(tester, textScale: 1.3);
    expect(tester.takeException(), isNull);
  });

  testWidgets('à 320 dp rien ne déborde', (WidgetTester tester) async {
    await pumpExplore(tester, surfaceSize: const Size(320, 800));
    expect(tester.takeException(), isNull);
    final Rect rect = tester.getRect(find.byType(WkSearchTrigger));
    expect(rect.left, greaterThanOrEqualTo(0));
    expect(rect.right, lessThanOrEqualTo(320));
  });

  test('trois frappes rapprochées ne lancent qu\'une recherche', () async {
    final _CountingDiscovery counting = _CountingDiscovery(discovery);
    final ExploreViewModel model = ExploreViewModel(
      discovery: counting,
      position: fakePositions(),
    );
    addTearDown(model.dispose);

    await model.load();
    final int before = counting.brokerCalls;
    model
      ..search('M')
      ..search('Me')
      ..search('Mer');
    await Future<void>.delayed(const Duration(milliseconds: 500));

    expect(counting.brokerCalls - before, 1);
  });
}

class _FixedLocationService implements LocationService {
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

class _CountingDiscovery implements DiscoveryService {
  _CountingDiscovery(this._inner);

  final DiscoveryService _inner;
  int brokerCalls = 0;

  @override
  Future<List<BrokerListing>> findBrokers({
    required GeoPoint from,
    DiscoveryFilters filters = const DiscoveryFilters(),
  }) {
    brokerCalls++;
    return _inner.findBrokers(from: from, filters: filters);
  }

  @override
  Future<List<Property>> findProperties({
    required GeoPoint from,
    DiscoveryFilters filters = const DiscoveryFilters(),
  }) => _inner.findProperties(from: from, filters: filters);

  @override
  Future<List<String>> suggestions({
    required GeoPoint from,
    DiscoveryFilters filters = const DiscoveryFilters(),
    int limit = 5,
  }) => _inner.suggestions(from: from, filters: filters, limit: limit);
}
