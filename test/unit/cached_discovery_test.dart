import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_keur/app/data/local/cache_status.dart';
import 'package:woutalma_keur/app/data/repositories/cached_discovery.dart';
import 'package:woutalma_keur/app/data/repositories/in_memory_repositories.dart';
import 'package:woutalma_keur/app/data/seed/demo_seed.dart';
import 'package:woutalma_keur/app/domain/discovery.dart';
import 'package:woutalma_keur/app/domain/entities.dart';

/// Découverte distante scriptable : rend le seed, ou tombe.
class _ScriptedRemote extends DiscoveryService {
  _ScriptedRemote(this._source);

  final DiscoveryService _source;
  Object? error;

  @override
  Future<DiscoveryPage<BrokerListing>> searchBrokers({
    required GeoPoint from,
    DiscoveryFilters filters = const DiscoveryFilters(),
    int limit = DiscoveryService.pageSize,
    int offset = 0,
  }) async {
    if (error != null) {
      throw error!;
    }
    return _source.searchBrokers(
      from: from,
      filters: filters,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<DiscoveryPage<Property>> searchProperties({
    required GeoPoint from,
    DiscoveryFilters filters = const DiscoveryFilters(),
    int limit = DiscoveryService.pageSize,
    int offset = 0,
  }) async {
    if (error != null) {
      throw error!;
    }
    return _source.searchProperties(
      from: from,
      filters: filters,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<List<String>> suggestions({
    required GeoPoint from,
    DiscoveryFilters filters = const DiscoveryFilters(),
    int limit = 5,
  }) async {
    if (error != null) {
      throw error!;
    }
    return _source.suggestions(from: from, filters: filters, limit: limit);
  }
}

DioException _offline() => DioException(
  requestOptions: RequestOptions(path: '/search/brokers'),
  type: DioExceptionType.connectionError,
);

DioException _unauthorised() => DioException(
  requestOptions: RequestOptions(path: '/search/brokers'),
  type: DioExceptionType.badResponse,
  response: Response<void>(
    requestOptions: RequestOptions(path: '/search/brokers'),
    statusCode: 401,
  ),
);

void main() {
  late _ScriptedRemote remote;
  late InMemoryStore cacheStore;
  late CacheStatus status;
  late CachedDiscoveryService discovery;

  const GeoPoint from = DemoSeed.clientPosition;

  setUp(() async {
    // Le « serveur » : un magasin complet, monté derrière la découverte locale.
    final InMemoryStore server = InMemoryStore();
    await InMemorySeedRepository(server).loadDemoSeed();
    remote = _ScriptedRemote(
      LocalDiscoveryService(
        brokers: InMemoryBrokerRepository(server),
        properties: InMemoryPropertyRepository(server),
        reviews: InMemoryReviewRepository(server),
      ),
    );

    // Le cache du téléphone : vide au départ.
    cacheStore = InMemoryStore();
    status = CacheStatus();
    discovery = CachedDiscoveryService(
      remote: remote,
      brokerCache: InMemoryBrokerRepository(cacheStore),
      propertyCache: InMemoryPropertyRepository(cacheStore),
      reviewCache: InMemoryReviewRepository(cacheStore),
      status: status,
    );
  });

  test('une recherche réussie laisse une trace pour plus tard', () async {
    final List<BrokerListing> fresh = await discovery.findBrokers(from: from);

    expect(fresh, isNotEmpty);
    expect(cacheStore.brokers, isNotEmpty);
    expect(status.servedFromCache, isFalse);
  });

  test('hors ligne, la recherche se rejoue sur ce qui a déjà été vu', () async {
    final List<BrokerListing> online = await discovery.findBrokers(from: from);
    await discovery.findProperties(from: from);

    remote.error = _offline();
    final List<BrokerListing> offline = await discovery.findBrokers(from: from);

    // Même ordre : le classement local est le portage de celui du serveur.
    expect(
      offline.map((BrokerListing l) => l.broker.id).toList(),
      online.map((BrokerListing l) => l.broker.id).toList(),
    );
    expect(status.servedFromCache, isTrue);
  });

  test('les filtres s\'appliquent encore hors ligne', () async {
    await discovery.findProperties(from: from);
    remote.error = _offline();

    final List<Property> land = await discovery.findProperties(
      from: from,
      filters: const DiscoveryFilters(kind: PropertyKind.land),
    );

    expect(land, isNotEmpty);
    expect(land.every((Property p) => p.kind == PropertyKind.land), isTrue);
  });

  test('hors ligne sans rien en cache, l\'erreur remonte', () async {
    remote.error = _offline();

    // Une liste vide ressemblerait à « aucun courtier près de vous », ce qui
    // est un mensonge. L'écran doit dire qu'il n'y a pas de réseau.
    await expectLater(
      discovery.findBrokers(from: from),
      throwsA(isA<DioException>()),
    );
    expect(status.servedFromCache, isFalse);
  });

  test('un 401 ne se rabat jamais sur le cache', () async {
    await discovery.findBrokers(from: from);
    remote.error = _unauthorised();

    await expectLater(
      discovery.findBrokers(from: from),
      throwsA(isA<DioException>()),
    );
    expect(status.servedFromCache, isFalse);
  });

  test('les suggestions hors ligne ne font pas échouer la frappe', () async {
    remote.error = _offline();

    // Une aide à la saisie ne doit jamais faire tomber l'écran : hors ligne et
    // sans cache, on retombe sur les repères génériques du parcours local
    // (« Maison », « À louer »…), ce qui reste utile pour composer une
    // recherche à rejouer au retour du réseau.
    final List<String> hints = await discovery.suggestions(from: from);
    expect(hints, isNotEmpty);

    // Et une fois du contenu vu, les suggestions parlent de vrais quartiers.
    remote.error = null;
    await discovery.findProperties(from: from);
    remote.error = _offline();
    expect(
      await discovery.suggestions(
        from: from,
        filters: const DiscoveryFilters(query: 'mer'),
      ),
      contains('Mermoz'),
    );
  });
}
