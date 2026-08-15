import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_keur/app/data/services/cached_tile_provider.dart';

/// Adaptateur scriptable : compte les requêtes réellement parties sur le
/// réseau, et sait tomber en panne à la demande.
class _Adapter implements HttpClientAdapter {
  int calls = 0;
  bool offline = false;
  List<int> body = <int>[1, 2, 3, 4];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    if (offline) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'test',
      );
    }
    return ResponseBody.fromBytes(body, 200);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late Directory root;
  late _Adapter adapter;
  late Dio dio;

  const String url = 'https://tile.openstreetmap.org/12/1851/1880.png';

  setUp(() async {
    root = await Directory.systemTemp.createTemp('wk-tiles');
    adapter = _Adapter();
    dio = Dio()..httpClientAdapter = adapter;
  });

  tearDown(() async {
    if (root.existsSync()) {
      await root.delete(recursive: true);
    }
  });

  Future<CachedTileProvider> open() =>
      CachedTileProvider.open(root.path, client: dio);

  test(
    'la première tuile part sur le réseau, la seconde vient du disque',
    () async {
      final CachedTileProvider tiles = await open();

      expect(await tiles.load(url), <int>[1, 2, 3, 4]);
      expect(adapter.calls, 1);

      // C'est tout l'intérêt : rouvrir la carte ne doit pas repayer la data.
      expect(await tiles.load(url), <int>[1, 2, 3, 4]);
      expect(adapter.calls, 1);
    },
  );

  test('le cache survit à un redémarrage de l\'application', () async {
    await (await open()).load(url);
    adapter.calls = 0;

    // Nouvelle instance sur le même dossier : le disque doit suffire.
    final CachedTileProvider next = await open();
    expect(await next.load(url), <int>[1, 2, 3, 4]);
    expect(adapter.calls, 0);
  });

  test('hors ligne, une tuile déjà vue reste servie', () async {
    final CachedTileProvider tiles = await open();
    await tiles.load(url);

    adapter.offline = true;
    // Le fond de carte doit rester lisible dans un tunnel.
    expect(await tiles.load(url), <int>[1, 2, 3, 4]);
  });

  test('hors ligne, une tuile jamais vue échoue franchement', () async {
    final CachedTileProvider tiles = await open();
    adapter.offline = true;

    // Pas de copie : mieux vaut laisser la carte signaler l'absence que
    // rendre un carré vide silencieux.
    await expectLater(tiles.load(url), throwsA(isA<DioException>()));
  });

  test('une tuile périmée est rafraîchie quand le réseau répond', () async {
    final CachedTileProvider tiles = CachedTileProvider(
      directory: Directory('${root.path}/map-tiles')
        ..createSync(recursive: true),
      client: dio,
      maxAge: Duration.zero,
    );
    await tiles.load(url);
    adapter.body = <int>[9, 9];

    expect(await tiles.load(url), <int>[9, 9]);
    expect(adapter.calls, 2);
  });

  test('le ménage ramène le dossier sous le plafond', () async {
    final Directory dir = Directory('${root.path}/map-tiles')
      ..createSync(recursive: true);
    final CachedTileProvider tiles = CachedTileProvider(
      directory: dir,
      client: dio,
      maxBytes: 8,
    );
    adapter.body = List<int>.filled(4, 7);

    for (var i = 0; i < 6; i++) {
      await tiles.load('https://tile.openstreetmap.org/12/$i/1880.png');
    }
    // Le balayage part en tâche de fond après l'écriture.
    await Future<void>.delayed(const Duration(milliseconds: 120));

    final int bytes = dir.listSync().whereType<File>().fold(
      0,
      (int sum, File f) => sum + f.lengthSync(),
    );
    expect(bytes, lessThanOrEqualTo(8));
  });

  test('deux URL différentes ne partagent pas un fichier', () {
    expect(
      CachedTileProvider.hashUrl('https://a/1.png'),
      isNot(CachedTileProvider.hashUrl('https://a/2.png')),
    );
    expect(
      CachedTileProvider.hashUrl('https://a/1.png'),
      CachedTileProvider.hashUrl('https://a/1.png'),
    );
  });
}
