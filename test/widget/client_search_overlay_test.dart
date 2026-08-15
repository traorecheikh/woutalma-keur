import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_keur/app/data/repositories/in_memory_repositories.dart';
import 'package:woutalma_keur/app/domain/discovery.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/modules/client/explore/explore_view_model.dart';
import 'package:woutalma_keur/app/modules/client/explore/search_overlay.dart';

import '../support/fake_location.dart';
import '../support/pump.dart';

/// Découverte qui tombe comme un réseau coupé, puis se rétablit.
class _FlakyDiscovery implements DiscoveryService {
  _FlakyDiscovery({required this.store});

  final InMemoryStore store;
  bool offline = true;
  int calls = 0;

  DiscoveryService get _local => LocalDiscoveryService(
    brokers: InMemoryBrokerRepository(store),
    properties: InMemoryPropertyRepository(store),
    reviews: InMemoryReviewRepository(store),
  );

  void _guard() {
    calls++;
    if (offline) {
      throw DioException(
        requestOptions: RequestOptions(path: '/search/brokers'),
        type: DioExceptionType.connectionError,
      );
    }
  }

  @override
  Future<List<BrokerListing>> findBrokers({
    required GeoPoint from,
    DiscoveryFilters filters = const DiscoveryFilters(),
  }) async {
    _guard();
    return _local.findBrokers(from: from, filters: filters);
  }

  @override
  Future<List<Property>> findProperties({
    required GeoPoint from,
    DiscoveryFilters filters = const DiscoveryFilters(),
  }) async {
    _guard();
    return _local.findProperties(from: from, filters: filters);
  }

  @override
  Future<List<String>> suggestions({
    required GeoPoint from,
    DiscoveryFilters filters = const DiscoveryFilters(),
    int limit = 6,
  }) async {
    _guard();
    return _local.suggestions(from: from, filters: filters, limit: limit);
  }
}

void main() {
  late InMemoryStore store;
  late _FlakyDiscovery discovery;
  late ExploreViewModel model;

  setUp(() async {
    store = InMemoryStore();
    await InMemorySeedRepository(store).loadDemoSeed();
    discovery = _FlakyDiscovery(store: store);
    model = ExploreViewModel(
      discovery: discovery,
      position: fakePositions(),
      debounce: const Duration(milliseconds: 10),
    );
  });

  tearDown(() => model.dispose());

  testWidgets('une recherche en échec se voit au lieu de rendre zéro', (
    WidgetTester tester,
  ) async {
    await model.load();

    await pumpWk(
      tester,
      SearchOverlay(model: model, onOpenBroker: (_) {}, onOpenProperty: (_) {}),
    );
    await tester.pumpAndSettle();

    // « Aucun résultat » était un mensonge : la requête n'avait pas abouti,
    // et le bouton mort ne disait pas pourquoi.
    expect(find.text('Aucun résultat'), findsNothing);
    expect(find.text('Ça n\'a pas marché'), findsOneWidget);
    expect(
      find.text('Pas de connexion. Réessayez quand le réseau revient.'),
      findsOneWidget,
    );
    expect(find.text('Réessayer'), findsOneWidget);
  });

  testWidgets('réessayer relance la recherche depuis l\'overlay', (
    WidgetTester tester,
  ) async {
    await model.load();

    await pumpWk(
      tester,
      SearchOverlay(model: model, onOpenBroker: (_) {}, onOpenProperty: (_) {}),
    );
    await tester.pumpAndSettle();

    discovery.offline = false;
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();

    expect(find.text('Ça n\'a pas marché'), findsNothing);
    expect(find.textContaining('Voir '), findsOneWidget);
  });
}
