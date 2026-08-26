import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_keur/app/data/local/cache_status.dart';
import 'package:woutalma_keur/app/data/repositories/cached_repositories.dart';
import 'package:woutalma_keur/app/data/repositories/in_memory_repositories.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/repositories.dart';

/// Dépôt distant scriptable : soit il rend une liste, soit il lance.
class _ScriptedBrokers implements BrokerRepository {
  _ScriptedBrokers();

  List<Broker> result = const <Broker>[];
  Object? error;
  int calls = 0;

  @override
  Future<List<Broker>> all() async {
    calls++;
    if (error != null) {
      throw error!;
    }
    return result;
  }

  @override
  Future<Broker?> byId(String id) async {
    calls++;
    if (error != null) {
      throw error!;
    }
    return result.where((Broker b) => b.id == id).firstOrNull;
  }

  @override
  Future<void> save(Broker broker) async {}

  @override
  Future<void> saveAll(List<Broker> brokers) async {}

  @override
  Future<Broker> requestVerification(String brokerId) async {
    throw UnimplementedError('non utilisé par ce test');
  }
}

Broker _broker(String id) => Broker(
  id: id,
  kind: BrokerKind.individual,
  name: 'Courtier $id',
  phone: '+221770000000',
  position: const GeoPoint(14.6690, -17.4380),
  coverage: const <String>['Plateau'],
);

DioException _offline() => DioException(
  requestOptions: RequestOptions(path: '/brokers'),
  type: DioExceptionType.connectionError,
);

DioException _status(int code) => DioException(
  requestOptions: RequestOptions(path: '/brokers'),
  type: DioExceptionType.badResponse,
  response: Response<void>(
    requestOptions: RequestOptions(path: '/brokers'),
    statusCode: code,
  ),
);

void main() {
  late _ScriptedBrokers remote;
  late BrokerRepository cache;
  late CacheStatus status;
  late CachedBrokerRepository repo;

  setUp(() {
    remote = _ScriptedBrokers();
    cache = InMemoryBrokerRepository(InMemoryStore());
    status = CacheStatus();
    repo = CachedBrokerRepository(remote: remote, cache: cache, status: status);
  });

  test(
    'une lecture réussie recopie localement et se déclare fraîche',
    () async {
      remote.result = <Broker>[_broker('a'), _broker('b')];

      final List<Broker> got = await repo.all();

      expect(got.map((Broker b) => b.id), <String>['a', 'b']);
      expect(await cache.all(), hasLength(2));
      expect(status.servedFromCache, isFalse);
      expect(status.fetchedAt, isNotNull);
    },
  );

  test('deux lectures identiques ne dupliquent pas les lignes', () async {
    remote.result = <Broker>[_broker('a')];
    await repo.all();
    await repo.all();

    // L'index `uid` est unique/replace : recopier est idempotent.
    expect(await cache.all(), hasLength(1));
  });

  test(
    'hors ligne avec une copie chaude, on sert la copie et on le dit',
    () async {
      remote.result = <Broker>[_broker('a')];
      await repo.all();

      remote.error = _offline();
      final List<Broker> got = await repo.all();

      expect(got.map((Broker b) => b.id), <String>['a']);
      expect(status.servedFromCache, isTrue);
    },
  );

  test(
    'hors ligne sans copie, l\'erreur remonte au lieu d\'un écran vide',
    () async {
      remote.error = _offline();

      // Rien en cache : c'est un état d'erreur explicite, jamais une donnée
      // fabriquée ni une liste vide qui ressemblerait à « aucun courtier ».
      await expectLater(repo.all(), throwsA(isA<DioException>()));
      expect(status.servedFromCache, isFalse);
    },
  );

  test('un 5xx compte comme une coupure et autorise la copie', () async {
    remote.result = <Broker>[_broker('a')];
    await repo.all();

    remote.error = _status(503);
    expect(await repo.all(), hasLength(1));
    expect(status.servedFromCache, isTrue);
  });

  test('un 401 ne sert jamais la copie', () async {
    remote.result = <Broker>[_broker('a')];
    await repo.all();

    remote.error = _status(401);

    // Une session expirée n'est pas une coupure réseau : servir une copie
    // datée masquerait la déconnexion au lieu de la signaler.
    await expectLater(repo.all(), throwsA(isA<DioException>()));
    expect(status.servedFromCache, isFalse);
  });

  test('byId absent en ligne rend null sans consulter la copie', () async {
    remote.result = <Broker>[_broker('a')];
    expect(await repo.byId('inconnu'), isNull);
  });

  test('une copie locale impossible ne fait pas échouer la lecture', () async {
    remote.result = <Broker>[_broker('a')];
    final CachedBrokerRepository fragile = CachedBrokerRepository(
      remote: remote,
      cache: _FullDisk(),
      status: status,
    );

    // Disque plein après une lecture réussie : la donnée est déjà là, la
    // rendre vaut mieux qu'un « Ça n'a pas marché ».
    expect(await fragile.all(), hasLength(1));
    expect(status.servedFromCache, isFalse);
  });

  test('la liste d\'un courtier chasse ce que le serveur n\'a plus', () async {
    final InMemoryStore store = InMemoryStore();
    final PropertyRepository cache = InMemoryPropertyRepository(store);
    final _ScriptedProperties server = _ScriptedProperties();
    final CachedPropertyRepository properties = CachedPropertyRepository(
      remote: server,
      cache: cache,
      status: status,
    );

    server.result = <Property>[_property('p1'), _property('p2')];
    await properties.byBroker('brk');
    expect(await cache.byBroker('brk'), hasLength(2));

    // « p2 » a été supprimé côté serveur : le garder localement le faisait
    // réapparaître dans « Mes biens » à chaque passage hors ligne.
    server.result = <Property>[_property('p1')];
    await properties.byBroker('brk');
    expect((await cache.byBroker('brk')).map((Property p) => p.id), <String>[
      'p1',
    ]);
  });

  test('une liste filtrée ne supprime rien', () async {
    final InMemoryStore store = InMemoryStore();
    final PropertyRepository cache = InMemoryPropertyRepository(store);
    final _ScriptedProperties server = _ScriptedProperties();
    final CachedPropertyRepository properties = CachedPropertyRepository(
      remote: server,
      cache: cache,
      status: status,
    );

    server.result = <Property>[_property('p1'), _property('p2')];
    await properties.byBroker('brk');

    // Les biens écartés par le filtre existent toujours : les effacer
    // reviendrait à perdre la copie hors ligne d'un bien simplement clos.
    server.result = <Property>[_property('p1')];
    await properties.byBroker('brk', onlyDiscoverable: true);
    expect(await cache.byBroker('brk'), hasLength(2));
  });

  test('la date du dernier succès survit au redémarrage', () async {
    final Map<String, String> disk = <String, String>{};
    final DateTime at = DateTime(2026, 8, 20, 9);
    CacheStatus(
      persist: (DateTime value) async => disk['at'] = value.toIso8601String(),
    ).markFresh(at);

    final CacheStatus next = CacheStatus()
      ..restoreFetchedAt(DateTime.tryParse(disk['at'] ?? ''));

    // Sans cela, le bandeau annonçait « enregistrées à l'instant » après
    // chaque relance, quel que soit l'âge réel de la copie.
    expect(next.fetchedAt, at);
    expect(CacheStatus().fetchedAt, isNull);
  });
}

/// Copie locale qui refuse toute écriture : disque plein.
class _FullDisk implements BrokerRepository {
  @override
  Future<List<Broker>> all() async => const <Broker>[];

  @override
  Future<Broker?> byId(String id) async => null;

  @override
  Future<void> save(Broker broker) async => throw StateError('disque plein');

  @override
  Future<void> saveAll(List<Broker> brokers) async =>
      throw StateError('disque plein');

  @override
  Future<Broker> requestVerification(String brokerId) async =>
      throw UnimplementedError();
}

class _ScriptedProperties implements PropertyRepository {
  List<Property> result = const <Property>[];

  @override
  Future<List<Property>> all() async => result;

  @override
  Future<List<Property>> discoverable() async => result;

  @override
  Future<List<Property>> byBroker(
    String brokerId, {
    bool onlyDiscoverable = false,
  }) async => result;

  @override
  Future<Property?> byId(String id) async =>
      result.where((Property p) => p.id == id).firstOrNull;

  @override
  Future<Property> save(Property property) async => property;

  @override
  Future<void> saveAll(List<Property> properties) async {}

  @override
  Future<void> delete(String id) async {}
}

Property _property(String id) => Property(
  id: id,
  brokerId: 'brk',
  kind: PropertyKind.apartment,
  transaction: TransactionKind.rent,
  title: 'Bien $id',
  price: 150000,
  position: const GeoPoint(14.6690, -17.4380),
  neighbourhood: 'Plateau',
  createdAt: DateTime(2026),
);
