import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_keur/app/data/seed/demo_seed.dart';
import 'package:woutalma_keur/app/domain/discovery.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/modules/client/explore/explore_view_model.dart';

import '../support/fake_location.dart';

Property _property(String id) => Property(
  id: id,
  brokerId: 'brk',
  kind: PropertyKind.apartment,
  transaction: TransactionKind.rent,
  title: 'Bien $id',
  price: 200000,
  position: DemoSeed.clientPosition,
  neighbourhood: 'Plateau',
  createdAt: DateTime(2026),
);

/// Laisse tourner les microtâches en attente : les requêtes ne partent qu'une
/// fois les `await` précédents rendus.
Future<void> _tick() => Future<void>.delayed(Duration.zero);

/// Découverte pilotée à la main : chaque recherche de biens attend qu'on la
/// libère, ce qui permet de faire répondre les requêtes dans le désordre.
class _SlowDiscovery extends DiscoveryService {
  final List<Completer<List<Property>>> pending = <Completer<List<Property>>>[];
  int total = 0;
  int calls = 0;
  Object? error;

  @override
  Future<DiscoveryPage<Property>> searchProperties({
    required GeoPoint from,
    DiscoveryFilters filters = const DiscoveryFilters(),
    int limit = DiscoveryService.pageSize,
    int offset = 0,
  }) async {
    calls++;
    if (error != null) {
      throw error!;
    }
    final Completer<List<Property>> gate = Completer<List<Property>>();
    pending.add(gate);
    final List<Property> items = await gate.future;
    return DiscoveryPage<Property>(
      items: items,
      total: total == 0 ? items.length : total,
    );
  }

  @override
  Future<DiscoveryPage<BrokerListing>> searchBrokers({
    required GeoPoint from,
    DiscoveryFilters filters = const DiscoveryFilters(),
    int limit = DiscoveryService.pageSize,
    int offset = 0,
  }) async {
    calls++;
    if (error != null) {
      throw error!;
    }
    return const DiscoveryPage<BrokerListing>(
      items: <BrokerListing>[],
      total: 0,
    );
  }

  @override
  Future<List<String>> suggestions({
    required GeoPoint from,
    DiscoveryFilters filters = const DiscoveryFilters(),
    int limit = 5,
  }) async => const <String>[];
}

void main() {
  late _SlowDiscovery discovery;

  ExploreViewModel build() =>
      ExploreViewModel(discovery: discovery, position: fakePositions());

  setUp(() => discovery = _SlowDiscovery());

  test('une réponse en retard n\'écrase pas la recherche suivante', () async {
    final ExploreViewModel model = build();
    addTearDown(model.dispose);
    final Future<void> first = model.applyFilters(
      const DiscoveryFilters(query: 'ancien'),
    );
    final Future<void> second = model.applyFilters(
      const DiscoveryFilters(query: 'récent'),
    );
    await _tick();

    // La seconde répond d'abord, la première arrive après : c'est le cas d'un
    // réseau lent, et c'est là que l'écran affichait la mauvaise liste.
    discovery.pending[1].complete(<Property>[_property('récent')]);
    discovery.pending[0].complete(<Property>[_property('ancien')]);
    await Future.wait(<Future<void>>[first, second]);

    expect(model.state.valueOrNull?.properties.single.id, 'récent');
  });

  test(
    'sans filtre, la recherche réutilise la réponse de l\'accueil',
    () async {
      final ExploreViewModel model = build();
      addTearDown(model.dispose);
      final Future<void> loading = model.load();
      await _tick();
      discovery.pending.single.complete(<Property>[_property('a')]);
      await loading;

      // Une requête de courtiers, une de biens : l'accueil et les résultats
      // demandaient deux fois la même chose.
      expect(discovery.calls, 2);
      expect(model.state, model.home);
    },
  );

  test('hors ligne, le compte annoncé reste le dernier connu', () async {
    final ExploreViewModel model = build();
    addTearDown(model.dispose);
    discovery.total = 42;
    final Future<int> counted = model.previewCount(const DiscoveryFilters());
    await _tick();
    discovery.pending.single.complete(<Property>[_property('a')]);
    expect(await counted, 42);

    discovery.error = DioException(
      requestOptions: RequestOptions(path: '/search/properties'),
      type: DioExceptionType.connectionError,
    );
    expect(await model.previewCount(const DiscoveryFilters()), 42);
  });

  test('la page suivante s\'ajoute à la précédente', () async {
    final ExploreViewModel model = build();
    addTearDown(model.dispose);
    discovery.total = 3;
    final Future<void> loading = model.load();
    await _tick();
    discovery.pending.single.complete(<Property>[
      _property('a'),
      _property('b'),
    ]);
    await loading;
    expect(model.hasMore, isTrue);

    final Future<void> more = model.loadMore();
    await _tick();
    discovery.pending.last.complete(<Property>[_property('c')]);
    await more;

    expect(
      model.state.valueOrNull?.properties.map((Property p) => p.id),
      <String>['a', 'b', 'c'],
    );
    expect(model.hasMore, isFalse);
  });

  test('une réponse arrivée après dispose ne notifie personne', () async {
    final ExploreViewModel model = build();
    final Future<void> loading = model.load();
    await _tick();
    model.dispose();
    discovery.pending.single.complete(<Property>[_property('a')]);
    await loading;
  });
}
