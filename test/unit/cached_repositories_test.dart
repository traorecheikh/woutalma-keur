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
}
