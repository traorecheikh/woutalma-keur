import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_api_client/woutalma_api_client.dart' as api;
import 'package:woutalma_keur/app/data/repositories/remote_repositories.dart';
import 'package:woutalma_keur/app/domain/entities.dart';

/// A [HttpClientAdapter] fake that never touches a socket — routes match by
/// exact `method path`, returning canned JSON bodies. Kept in-file rather
/// than adding a mocking package, since a handful of fixed routes is all
/// these repositories need to prove.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this._routes);

  final Map<String, ({int status, Object? body})> _routes;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final String key = '${options.method} ${options.path}';
    final route = _routes[key];
    if (route == null) {
      return ResponseBody.fromString(
        jsonEncode(<String, Object?>{
          'statusCode': 404,
          'message': 'no fixture for $key',
        }),
        404,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    return ResponseBody.fromString(
      jsonEncode(route.body),
      route.status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Map<String, Object?> _brokerJson({String id = 'brk-1'}) => <String, Object?>{
  'id': id,
  'kind': 'INDIVIDUAL',
  'name': 'Moussa',
  'phone': '+221770000000',
  'whatsapp': '+221770000000',
  'position': <String, Object?>{'latitude': 14.69, 'longitude': -17.44},
  'coverage': <String>['Plateau'],
  'logoAsset': null,
  'verification': 'VERIFIED',
  'responseRate': 0.8,
  'pinned': false,
  'isVerified': true,
};

Map<String, Object?> _propertyJson({String id = 'prop-1'}) => <String, Object?>{
  'id': id,
  'brokerId': 'brk-1',
  'kind': 'APARTMENT',
  'transaction': 'RENT',
  'title': 'Appartement Mermoz',
  'description': '',
  'price': 150000,
  'surface': 45,
  'rooms': 2,
  'position': <String, Object?>{'latitude': 14.7, 'longitude': -17.47},
  'neighbourhood': 'Mermoz',
  'photoAssets': <String>[],
  'status': 'AVAILABLE',
  'createdAt': DateTime(2026, 1, 1).toIso8601String(),
  'isDiscoverable': true,
};

Dio _dioWithRoutes(Map<String, ({int status, Object? body})> routes) {
  final Dio dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
  dio.httpClientAdapter = _FakeAdapter(routes);
  return dio;
}

void main() {
  group('RemoteBrokerRepository', () {
    test('byId maps a 200 response onto the domain Broker entity', () async {
      final Dio dio = _dioWithRoutes(<String, ({int status, Object? body})>{
        'GET /brokers/brk-1': (status: 200, body: _brokerJson()),
      });
      final RemoteBrokerRepository repo = RemoteBrokerRepository(
        api.BrokersApi(dio, api.standardSerializers),
      );

      final Broker? broker = await repo.byId('brk-1');

      expect(broker, isNotNull);
      expect(broker!.id, 'brk-1');
      expect(broker.kind, BrokerKind.individual);
      expect(broker.verification, VerificationStatus.verified);
      expect(broker.isVerified, isTrue);
      expect(broker.position, const GeoPoint(14.69, -17.44));
      expect(broker.coverage, <String>['Plateau']);
    });

    test(
      'byId returns null on 404 — matches Isar/InMemory not-found semantics',
      () async {
        final Dio dio = _dioWithRoutes(
          <String, ({int status, Object? body})>{},
        );
        final RemoteBrokerRepository repo = RemoteBrokerRepository(
          api.BrokersApi(dio, api.standardSerializers),
        );

        final Broker? broker = await repo.byId('does-not-exist');

        expect(broker, isNull);
      },
    );

    test('all() maps a list response', () async {
      final Dio dio = _dioWithRoutes(<String, ({int status, Object? body})>{
        'GET /brokers': (
          status: 200,
          body: <Map<String, Object?>>[
            _brokerJson(id: 'brk-1'),
            _brokerJson(id: 'brk-2'),
          ],
        ),
      });
      final RemoteBrokerRepository repo = RemoteBrokerRepository(
        api.BrokersApi(dio, api.standardSerializers),
      );

      final List<Broker> brokers = await repo.all();

      expect(brokers.map((Broker b) => b.id), <String>['brk-1', 'brk-2']);
    });

    test(
      'save creates the profile when the server does not know it yet',
      () async {
        // Un identifiant inconnu répond 404 sur GET, ce qui doit mener à POST
        // /brokers plutôt qu'à un PATCH sur une fiche inexistante.
        final Dio dio = _dioWithRoutes(<String, ({int status, Object? body})>{
          'POST /brokers': (status: 200, body: _brokerJson()),
        });
        final RemoteBrokerRepository repo = RemoteBrokerRepository(
          api.BrokersApi(dio, api.standardSerializers),
        );

        await repo.save(
          const Broker(
            id: 'brk-1',
            kind: BrokerKind.individual,
            name: 'x',
            phone: 'x',
            position: GeoPoint(0, 0),
            coverage: <String>[],
          ),
        );
      },
    );
  });

  group('RemotePropertyRepository', () {
    test('byId maps a 200 response onto the domain Property entity', () async {
      final Dio dio = _dioWithRoutes(<String, ({int status, Object? body})>{
        'GET /properties/prop-1': (status: 200, body: _propertyJson()),
      });
      final RemotePropertyRepository repo = RemotePropertyRepository(
        api.PropertiesApi(dio, api.standardSerializers),
        api.BrokersApi(dio, api.standardSerializers),
      );

      final Property? property = await repo.byId('prop-1');

      expect(property, isNotNull);
      expect(property!.brokerId, 'brk-1');
      expect(property.kind, PropertyKind.apartment);
      expect(property.transaction, TransactionKind.rent);
      expect(property.status, PropertyStatus.available);
      expect(property.isDiscoverable, isTrue);
      expect(property.price, 150000);
      expect(property.surface, 45);
    });

    test(
      'byId returns null on 404 — matches Isar/InMemory not-found semantics',
      () async {
        final Dio dio = _dioWithRoutes(
          <String, ({int status, Object? body})>{},
        );
        final RemotePropertyRepository repo = RemotePropertyRepository(
          api.PropertiesApi(dio, api.standardSerializers),
          api.BrokersApi(dio, api.standardSerializers),
        );

        final Property? property = await repo.byId('missing');

        expect(property, isNull);
      },
    );

    test('discoverable() calls the discoverableOnly=true endpoint', () async {
      final Dio dio = _dioWithRoutes(<String, ({int status, Object? body})>{
        'GET /properties': (
          status: 200,
          body: <Map<String, Object?>>[_propertyJson()],
        ),
      });
      final RemotePropertyRepository repo = RemotePropertyRepository(
        api.PropertiesApi(dio, api.standardSerializers),
        api.BrokersApi(dio, api.standardSerializers),
      );

      final List<Property> properties = await repo.discoverable();

      expect(properties, hasLength(1));
    });
  });

  group('RemoteContactRepository', () {
    test(
      'log() commits before returning and maps the response back to ContactLog',
      () async {
        final Dio dio = _dioWithRoutes(<String, ({int status, Object? body})>{
          'POST /contacts': (
            status: 201,
            body: <String, Object?>{
              'id': 'ctc-1',
              'brokerId': 'brk-1',
              'propertyId': null,
              'channel': 'CALL',
              'outcome': 'ATTEMPTED',
              'reviewId': null,
              'createdAt': DateTime(2026, 1, 1).toIso8601String(),
              'allowsReview': false,
            },
          ),
        });
        final RemoteContactRepository repo = RemoteContactRepository(
          api.ContactsApi(dio, api.standardSerializers),
          api.BrokersApi(dio, api.standardSerializers),
        );

        final ContactLog log = await repo.log(
          brokerId: 'brk-1',
          channel: ContactChannel.call,
        );

        expect(log.id, 'ctc-1');
        expect(log.brokerId, 'brk-1');
        expect(log.channel, ContactChannel.call);
        expect(log.outcome, ContactOutcome.attempted);
        expect(log.allowsReview, isFalse);
      },
    );
  });
}
