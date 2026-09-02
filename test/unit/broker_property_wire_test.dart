import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_api_client/woutalma_api_client.dart' as api;
import 'package:woutalma_keur/app/data/repositories/remote_repositories.dart';
import 'package:woutalma_keur/app/data/services/property_photo_uploader.dart';
import 'package:woutalma_keur/app/domain/entities.dart';

/// Ce qui part réellement sur le fil quand le courtier publie ou modifie.
///
/// Trois défauts ne se voient que là : la publication rejouée qui créait un
/// second bien, le champ vidé qui n'arrivait jamais, et l'aller-retour de
/// sonde payé juste avant de publier, quand le réseau est au plus faible.
class _Recorder implements HttpClientAdapter {
  _Recorder(this._routes);

  final Map<String, ({int status, Object? body})> _routes;
  final List<String> calls = <String>[];
  final Map<String, Map<String, Object?>> sent =
      <String, Map<String, Object?>>{};

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final String key = '${options.method} ${options.path}';
    calls.add(key);
    if (requestStream != null) {
      final List<int> bytes = <int>[];
      await for (final Uint8List chunk in requestStream) {
        bytes.addAll(chunk);
      }
      if (bytes.isNotEmpty) {
        sent[key] = jsonDecode(utf8.decode(bytes)) as Map<String, Object?>;
      }
    }
    final route = _routes[key];
    return ResponseBody.fromString(
      jsonEncode(route?.body ?? <String, Object?>{'message': key}),
      route?.status ?? 404,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Map<String, Object?> _propertyJson({String id = 'cksrv1'}) => <String, Object?>{
  'id': id,
  'brokerId': 'brk-1',
  'kind': 'LAND',
  'transaction': 'SALE',
  'title': 'Terrain Diamniadio',
  'description': '',
  'price': 9000000,
  'surface': null,
  'rooms': null,
  'position': <String, Object?>{'latitude': 14.7, 'longitude': -17.47},
  'neighbourhood': 'Diamniadio',
  'photoAssets': <String>[],
  'voiceAsset': null,
  'status': 'AVAILABLE',
  'createdAt': DateTime(2026, 1, 1).toIso8601String(),
  'isDiscoverable': true,
};

Map<String, Object?> _brokerJson() => <String, Object?>{
  'id': 'brk-1',
  'kind': 'INDIVIDUAL',
  'name': 'Moussa',
  'phone': '+221771112233',
  'whatsapp': '+221771112233',
  'position': <String, Object?>{'latitude': 14.7, 'longitude': -17.47},
  'coverage': <String>['Yoff'],
  'logoAsset': null,
  'verification': 'NONE',
  'responseRate': 0,
  'pinned': false,
  'isVerified': false,
};

Property _property({required String id, int? surface, int? rooms}) => Property(
  id: id,
  brokerId: 'brk-1',
  kind: PropertyKind.land,
  transaction: TransactionKind.sale,
  title: 'Terrain Diamniadio',
  price: 9000000,
  surface: surface,
  rooms: rooms,
  position: const GeoPoint(14.7, -17.47),
  neighbourhood: 'Diamniadio',
  createdAt: DateTime(2026, 1, 1),
);

({RemotePropertyRepository repo, _Recorder http}) _properties(
  Map<String, ({int status, Object? body})> routes,
) {
  final Dio dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
  final _Recorder recorder = _Recorder(routes);
  dio.httpClientAdapter = recorder;
  return (
    repo: RemotePropertyRepository(
      api.PropertiesApi(dio, api.standardSerializers),
      api.BrokersApi(dio, api.standardSerializers),
    ),
    http: recorder,
  );
}

void main() {
  group('publication', () {
    test('porte une clé d\'idempotence et ne sonde plus le serveur', () async {
      final http = _properties(<String, ({int status, Object? body})>{
        'POST /properties': (status: 201, body: _propertyJson()),
      });

      await http.repo.save(_property(id: 'prp-1756200000000000'));

      // La sonde `GET /properties/prp-…` cherchait un identifiant que le
      // serveur n'a jamais frappé : un aller-retour perdu à chaque publication.
      expect(http.http.calls, <String>['POST /properties']);
      expect(
        http.http.sent['POST /properties']!['clientRequestId'],
        'prp-1756200000000000',
      );
    });

    test('rejouée, elle repart avec la même clé', () async {
      final http = _properties(<String, ({int status, Object? body})>{
        'POST /properties': (status: 201, body: _propertyJson()),
      });
      final Property draft = _property(id: 'prp-1756200000000000');

      await http.repo.save(draft);
      await http.repo.save(draft);

      final Map<String, Object?> body = http.http.sent['POST /properties']!;
      expect(body['clientRequestId'], 'prp-1756200000000000');
      expect(http.http.calls, hasLength(2));
    });
  });

  group('modification', () {
    test('un identifiant serveur va droit au PATCH', () async {
      final http = _properties(<String, ({int status, Object? body})>{
        'PATCH /properties/cksrv1': (status: 200, body: _propertyJson()),
      });

      await http.repo.save(_property(id: 'cksrv1', surface: 300));

      expect(http.http.calls, <String>['PATCH /properties/cksrv1']);
    });

    test('un champ vidé part comme un ordre d\'effacement', () async {
      final http = _properties(<String, ({int status, Object? body})>{
        'PATCH /properties/cksrv1': (status: 200, body: _propertyJson()),
      });

      // Un bien repassé en terrain : le formulaire ne propose plus de pièces.
      await http.repo.save(_property(id: 'cksrv1'));

      final Map<String, Object?> body =
          http.http.sent['PATCH /properties/cksrv1']!;
      // built_value n'écrit pas les nuls : sans ces drapeaux, le serveur
      // gardait « 3 pièces » que le formulaire ne montrait plus.
      expect(body['clearSurface'], isTrue);
      expect(body['clearRooms'], isTrue);
      expect(body['voiceAsset'], '');
    });

    test('un champ rempli ne demande aucun effacement', () async {
      final http = _properties(<String, ({int status, Object? body})>{
        'PATCH /properties/cksrv1': (status: 200, body: _propertyJson()),
      });

      await http.repo.save(_property(id: 'cksrv1', surface: 300, rooms: 4));

      final Map<String, Object?> body =
          http.http.sent['PATCH /properties/cksrv1']!;
      expect(body['clearSurface'], isFalse);
      expect(body['clearRooms'], isFalse);
      expect(body['surface'], 300);
      expect(body['rooms'], 4);
    });
  });

  group('profil courtier', () {
    test('un WhatsApp retiré part comme un ordre d\'effacement', () async {
      final Dio dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
      final _Recorder recorder =
          _Recorder(<String, ({int status, Object? body})>{
            'GET /brokers/brk-1': (status: 200, body: _brokerJson()),
            'PATCH /brokers/brk-1': (status: 200, body: _brokerJson()),
          });
      dio.httpClientAdapter = recorder;
      final RemoteBrokerRepository repo = RemoteBrokerRepository(
        api.BrokersApi(dio, api.standardSerializers),
      );

      await repo.save(
        const Broker(
          id: 'brk-1',
          kind: BrokerKind.individual,
          name: 'Moussa',
          phone: '+221771112233',
          position: GeoPoint(14.7, -17.47),
          coverage: <String>['Yoff'],
        ),
      );

      expect(recorder.sent['PATCH /brokers/brk-1']!['clearWhatsapp'], isTrue);
    });
  });

  group('vocal', () {
    test('un fichier local part en base64 avec son type réseau', () async {
      final Dio dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
      final _Recorder recorder = _Recorder(
        <String, ({int status, Object? body})>{
          'POST /properties': (status: 201, body: _propertyJson()),
        },
      );
      dio.httpClientAdapter = recorder;
      final Uint8List m4a = Uint8List.fromList(<int>[
        0,
        0,
        0,
        24,
        0x66,
        0x74,
        0x79,
        0x70,
        0x6D,
        0x70,
        0x34,
        0x32,
        1,
        2,
        3,
      ]);
      final RemotePropertyRepository repo = RemotePropertyRepository(
        api.PropertiesApi(dio, api.standardSerializers),
        api.BrokersApi(dio, api.standardSerializers),
        voiceNotes: PropertyVoiceNoteUploader(readBytes: (_) async => m4a),
      );

      await repo.save(
        Property(
          id: 'prp-1756200000000000',
          brokerId: 'brk-1',
          kind: PropertyKind.land,
          transaction: TransactionKind.sale,
          title: 'Terrain Diamniadio',
          price: 9000000,
          position: const GeoPoint(14.7, -17.47),
          neighbourhood: 'Diamniadio',
          voiceAsset: '/tmp/v.m4a',
          createdAt: DateTime(2026, 1, 1),
        ),
      );

      final Map<String, Object?> body = recorder.sent['POST /properties']!;
      final Map<String, Object?> note =
          body['newVoiceNote']! as Map<String, Object?>;
      expect(note['mimeType'], 'audio/mp4');
      expect(note['dataBase64'], base64Encode(m4a));
    });
  });
}
