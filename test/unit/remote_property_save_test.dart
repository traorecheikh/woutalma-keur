import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_api_client/woutalma_api_client.dart' as api;
import 'package:woutalma_keur/app/data/local/cache_status.dart';
import 'package:woutalma_keur/app/data/repositories/cached_repositories.dart';
import 'package:woutalma_keur/app/data/repositories/in_memory_repositories.dart';
import 'package:woutalma_keur/app/data/repositories/remote_repositories.dart';
import 'package:woutalma_keur/app/data/services/property_photo_uploader.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/repositories.dart';

/// Adaptateur Dio qui enregistre le corps envoyé, pour vérifier ce qui part
/// réellement sur le fil — c'est là que la photo se perdait.
class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter(this._routes);

  final Map<String, ({int status, Object? body})> _routes;
  final Map<String, Map<String, Object?>> sent =
      <String, Map<String, Object?>>{};
  final Map<String, Map<String, Object?>> query =
      <String, Map<String, Object?>>{};

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final String key = '${options.method} ${options.path}';
    query[key] = Map<String, Object?>.from(options.queryParameters);
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
    if (route == null) {
      return ResponseBody.fromString(
        jsonEncode(<String, Object?>{'statusCode': 404, 'message': key}),
        404,
        headers: <String, List<String>>{
          Headers.contentTypeHeader: <String>[Headers.jsonContentType],
        },
      );
    }
    return ResponseBody.fromString(
      jsonEncode(route.body),
      route.status,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Map<String, Object?> _propertyJson({
  String id = 'cksrv1',
  List<String> photoAssets = const <String>[],
}) => <String, Object?>{
  'id': id,
  'brokerId': 'brk-1',
  'kind': 'APARTMENT',
  'transaction': 'RENT',
  'title': 'Appartement Mermoz',
  'description': '',
  'price': 150000,
  'surface': null,
  'rooms': null,
  'position': <String, Object?>{'latitude': 14.7, 'longitude': -17.47},
  'neighbourhood': 'Mermoz',
  'photoAssets': photoAssets,
  'status': 'AVAILABLE',
  'createdAt': DateTime(2026, 1, 1).toIso8601String(),
  'isDiscoverable': true,
};

Property _draft({
  String id = 'prp-999',
  List<String> photoAssets = const <String>[],
}) => Property(
  id: id,
  brokerId: 'brk-1',
  kind: PropertyKind.apartment,
  transaction: TransactionKind.rent,
  title: 'Appartement Mermoz',
  price: 150000,
  position: const GeoPoint(14.7, -17.47),
  neighbourhood: 'Mermoz',
  photoAssets: photoAssets,
  createdAt: DateTime(2026, 1, 1),
);

/// Encode sans toucher au disque ni au plugin de compression.
PropertyPhotoUploader _uploader(Map<String, Uint8List> files) {
  return PropertyPhotoUploader(
    readBytes: (String path) async => files[path]!,
    recompress: (_, {required int quality, required int width}) async => null,
  );
}

Uint8List _jpeg(int length) {
  final Uint8List bytes = Uint8List(length);
  bytes[0] = 0xFF;
  bytes[1] = 0xD8;
  bytes[2] = 0xFF;
  return bytes;
}

({Dio dio, _RecordingAdapter adapter}) _dio(
  Map<String, ({int status, Object? body})> routes,
) {
  final Dio dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
  final _RecordingAdapter adapter = _RecordingAdapter(routes);
  dio.httpClientAdapter = adapter;
  return (dio: dio, adapter: adapter);
}

void main() {
  group('RemotePropertyRepository.save', () {
    test('rend le bien tel que le serveur l\'a enregistré', () async {
      // L'éditeur propose `prp-999` ; le serveur frappe le sien. Sans ce
      // retour, la copie hors ligne s'écrivait sous l'identifiant fantôme.
      final ({Dio dio, _RecordingAdapter adapter}) http = _dio(
        <String, ({int status, Object? body})>{
          'POST /properties': (status: 201, body: _propertyJson()),
        },
      );
      final RemotePropertyRepository repo = RemotePropertyRepository(
        api.PropertiesApi(http.dio, api.standardSerializers),
        api.BrokersApi(http.dio, api.standardSerializers),
        photos: _uploader(<String, Uint8List>{}),
      );

      final Property saved = await repo.save(_draft());

      expect(saved.id, 'cksrv1');
    });

    test(
      'une photo locale part dans newPhotos, pas dans photoAssets',
      () async {
        final ({Dio dio, _RecordingAdapter adapter}) http = _dio(
          <String, ({int status, Object? body})>{
            'POST /properties': (
              status: 201,
              body: _propertyJson(
                photoAssets: <String>['demo:house:medina:front', 'api:ckph1'],
              ),
            ),
          },
        );
        final RemotePropertyRepository repo = RemotePropertyRepository(
          api.PropertiesApi(http.dio, api.standardSerializers),
          api.BrokersApi(http.dio, api.standardSerializers),
          photos: _uploader(<String, Uint8List>{
            '/data/user/0/wk-123.jpg': _jpeg(1024),
          }),
        );

        final Property saved = await repo.save(
          _draft(
            photoAssets: <String>[
              'demo:house:medina:front',
              '/data/user/0/wk-123.jpg',
            ],
          ),
        );

        final Map<String, Object?> body =
            http.adapter.sent['POST /properties']!;
        expect(body['photoAssets'], <String>['demo:house:medina:front']);
        final List<Object?> uploads = body['newPhotos']! as List<Object?>;
        expect(uploads, hasLength(1));
        final Map<String, Object?> upload =
            uploads.single as Map<String, Object?>;
        expect(upload['mimeType'], 'image/jpeg');
        expect(base64Decode(upload['dataBase64']! as String), hasLength(1024));
        // Et la fiche revient avec la clé `api:` que le serveur a créée.
        expect(saved.photoAssets, contains('api:ckph1'));
      },
    );

    test('une modification renvoie aussi la fiche du serveur', () async {
      final ({Dio dio, _RecordingAdapter adapter}) http = _dio(
        <String, ({int status, Object? body})>{
          'GET /properties/cksrv1': (status: 200, body: _propertyJson()),
          'PATCH /properties/cksrv1': (
            status: 200,
            body: _propertyJson(photoAssets: <String>['api:ckph2']),
          ),
        },
      );
      final RemotePropertyRepository repo = RemotePropertyRepository(
        api.PropertiesApi(http.dio, api.standardSerializers),
        api.BrokersApi(http.dio, api.standardSerializers),
        photos: _uploader(<String, Uint8List>{'/tmp/wk-9.jpg': _jpeg(512)}),
      );

      final Property saved = await repo.save(
        _draft(id: 'cksrv1', photoAssets: <String>['/tmp/wk-9.jpg']),
      );

      expect(saved.photoAssets, <String>['api:ckph2']);
      expect(
        http.adapter.sent['PATCH /properties/cksrv1']!['photoAssets'],
        isEmpty,
      );
    });
  });

  group('RemoteReviewRepository.byBroker', () {
    test('ne demande que les avis publics par défaut', () async {
      // Avec `onlyPublic=false`, le serveur rend aussi les avis PENDING et
      // REJECTED, qui entraient dans la moyenne affichée sur la fiche
      // publique.
      final ({Dio dio, _RecordingAdapter adapter}) http = _dio(
        <String, ({int status, Object? body})>{
          'GET /reviews/broker/brk-1': (status: 200, body: <Object?>[]),
        },
      );
      final RemoteReviewRepository repo = RemoteReviewRepository(
        api.ReviewsApi(http.dio, api.standardSerializers),
      );

      await repo.byBroker('brk-1');

      // Le paramètre part en booléen depuis que le serveur le type comme
      // tel ; ce qui compte est qu'il vaille vrai par défaut, pour que la
      // fiche publique n'affiche jamais un avis en attente de modération.
      expect(
        http.adapter.query['GET /reviews/broker/brk-1']!['onlyPublic'],
        isTrue,
      );
    });
  });

  group('CachedPropertyRepository.save', () {
    test(
      'écrit la ligne du serveur, pas l\'identifiant fabriqué localement',
      () async {
        final InMemoryStore store = InMemoryStore();
        final PropertyRepository cache = InMemoryPropertyRepository(store);
        final CachedPropertyRepository repo = CachedPropertyRepository(
          remote: _ServerMintingProperties(),
          cache: cache,
          status: CacheStatus(),
        );

        final Property saved = await repo.save(_draft(id: 'prp-999'));

        expect(saved.id, 'cksrv1');
        // Une seule ligne, sous l'identifiant du serveur : la ligne fantôme
        // faisait apparaître deux fois la même annonce dans « Mes biens ».
        expect((await cache.all()).map((Property p) => p.id), <String>[
          'cksrv1',
        ]);
      },
    );
  });
}

/// Serveur qui remplace l'identifiant proposé, comme `POST /properties`.
class _ServerMintingProperties implements PropertyRepository {
  @override
  Future<List<Property>> all() async => const <Property>[];

  @override
  Future<List<Property>> byBroker(
    String brokerId, {
    bool onlyDiscoverable = false,
  }) async => const <Property>[];

  @override
  Future<Property?> byId(String id) async => null;

  @override
  Future<void> delete(String id) async {}

  @override
  Future<List<Property>> discoverable() async => const <Property>[];

  @override
  Future<Property> save(Property property) async => Property(
    id: 'cksrv1',
    brokerId: property.brokerId,
    kind: property.kind,
    transaction: property.transaction,
    title: property.title,
    price: property.price,
    position: property.position,
    neighbourhood: property.neighbourhood,
    createdAt: property.createdAt,
    photoAssets: const <String>['api:ckph1'],
  );

  @override
  Future<void> saveAll(List<Property> properties) async {}
}
