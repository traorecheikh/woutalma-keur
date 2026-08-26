import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_keur/app/data/local/cache_status.dart';
import 'package:woutalma_keur/app/data/repositories/cached_repositories.dart';
import 'package:woutalma_keur/app/core/state/screen_state.dart';
import 'package:woutalma_keur/app/data/repositories/in_memory_repositories.dart';
import 'package:woutalma_keur/app/domain/contact_launcher.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/repositories.dart';
import 'package:woutalma_keur/app/modules/client/broker/broker_view_model.dart';

/// Le dépôt distant : hors ligne, refusé, ou disponible.
class _ScriptedContacts implements ContactRepository {
  Object? error;
  int logCalls = 0;
  final List<ContactLog> rows = <ContactLog>[];

  @override
  Future<List<ContactLog>> all() async {
    if (error != null) throw error!;
    return rows;
  }

  @override
  Future<ContactLog?> byId(String id) async {
    if (error != null) throw error!;
    return rows.where((ContactLog c) => c.id == id).firstOrNull;
  }

  @override
  Future<ContactLog> log({
    required String brokerId,
    String? propertyId,
    required ContactChannel channel,
  }) async {
    logCalls++;
    if (error != null) throw error!;
    final ContactLog logged = ContactLog(
      id: 'srv-$logCalls',
      brokerId: brokerId,
      propertyId: propertyId,
      channel: channel,
      createdAt: DateTime.utc(2026, 8, 1),
    );
    rows.add(logged);
    return logged;
  }

  @override
  Future<List<ContactLog>> receivedBy(String brokerId) async => rows;

  @override
  Future<void> update(ContactLog contact) async {
    if (error != null) throw error!;
  }

  @override
  Future<void> updateAll(List<ContactLog> contacts) async {}

  @override
  Future<void> remove(String id) async {}
}

DioException _offline() => DioException(
  requestOptions: RequestOptions(path: '/contacts'),
  type: DioExceptionType.connectionError,
);

DioException _unauthorized() => DioException(
  requestOptions: RequestOptions(path: '/contacts'),
  response: Response<void>(
    requestOptions: RequestOptions(path: '/contacts'),
    statusCode: 401,
  ),
);

void main() {
  late _ScriptedContacts remote;
  late ContactRepository cache;
  late CachedContactRepository contacts;

  setUp(() {
    remote = _ScriptedContacts();
    cache = InMemoryContactRepository(
      InMemoryStore(),
      now: () => DateTime.utc(2026, 8, 1),
    );
    contacts = CachedContactRepository(
      remote: remote,
      cache: cache,
      status: CacheStatus(),
      now: () => DateTime.utc(2026, 8, 2, 9),
    );
  });

  for (final (String name, DioException failure) in <(String, DioException)>[
    ('hors ligne', _offline()),
    ('sans session', _unauthorized()),
  ]) {
    test('$name, le contact est gardé sur le téléphone', () async {
      remote.error = failure;

      final ContactLog logged = await contacts.log(
        brokerId: 'brk-1',
        channel: ContactChannel.call,
      );

      expect(logged.id, startsWith(CachedContactRepository.localPrefix));
      // L'appel a bien eu lieu : l'historique doit le montrer, même non
      // synchronisé.
      expect((await contacts.all()).map((ContactLog c) => c.id), [logged.id]);
    });
  }

  test('le résultat d\'un contact local ne part pas au serveur', () async {
    remote.error = _unauthorized();
    final ContactLog logged = await contacts.log(
      brokerId: 'brk-1',
      channel: ContactChannel.call,
    );

    await contacts.update(logged.copyWith(outcome: ContactOutcome.reached));

    expect((await cache.byId(logged.id))!.outcome, ContactOutcome.reached);
  });

  test('les contacts locaux rejoignent ceux du serveur', () async {
    remote.error = _offline();
    final ContactLog local = await contacts.log(
      brokerId: 'brk-1',
      channel: ContactChannel.call,
    );

    remote.error = null;
    final ContactLog synced = await contacts.log(
      brokerId: 'brk-2',
      channel: ContactChannel.sms,
    );

    final List<String> ids = (await contacts.all())
        .map((ContactLog c) => c.id)
        .toList();
    expect(ids, contains(synced.id));
    expect(ids, isNot(contains(local.id)));
    expect(ids.toSet().length, 2);
    expect(remote.logCalls, 3);
    expect(await cache.byId(local.id), isNull);
  });

  test('le résultat noté hors ligne part avec le rejeu', () async {
    remote.error = _offline();
    final ContactLog local = await contacts.log(
      brokerId: 'brk-1',
      channel: ContactChannel.call,
    );
    await contacts.update(local.copyWith(outcome: ContactOutcome.reached));

    remote.error = null;
    final List<ContactLog> shown = await contacts.all();

    expect(shown.single.id, startsWith('srv-'));
    expect(shown.single.outcome, ContactOutcome.reached);
  });

  test('sans contact local, un refus du serveur remonte', () async {
    remote.error = _unauthorized();
    expect(contacts.all(), throwsA(isA<DioException>()));
  });

  test('hors ligne, C02 montre une erreur au lieu d\'un squelette', () async {
    final InMemoryStore store = InMemoryStore();
    final BrokerViewModel model = BrokerViewModel(
      brokerId: 'brk-1',
      brokers: _OfflineBrokers(),
      properties: InMemoryPropertyRepository(store),
      reviews: InMemoryReviewRepository(store),
      contact: ContactService(contacts: contacts, launcher: _SilentLauncher()),
      from: const GeoPoint(14.6690, -17.4380),
    );
    addTearDown(model.dispose);

    await model.load();

    expect(model.state, isA<ScreenError<BrokerDetail>>());
    expect(
      (model.state as ScreenError<BrokerDetail>).failure,
      WkFailure.network,
    );
  });
}

class _OfflineBrokers implements BrokerRepository {
  @override
  Future<List<Broker>> all() async => throw _offline();
  @override
  Future<Broker?> byId(String id) async => throw _offline();
  @override
  Future<void> save(Broker broker) async {}
  @override
  Future<void> saveAll(List<Broker> brokers) async {}
  @override
  Future<Broker> requestVerification(String brokerId) async =>
      throw UnimplementedError();
}

class _SilentLauncher implements ContactLauncher {
  @override
  Future<bool> open(ContactChannel channel, Broker broker) async => false;
}
