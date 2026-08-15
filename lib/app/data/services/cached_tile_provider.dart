import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_map/flutter_map.dart';

/// Tuiles de carte gardées sur le disque.
///
/// Le paquet ne cache rien de lui-même : chaque ouverture de la carte
/// retélécharge tout, et hors couverture le fond devient vide. Sur une cible
/// qui paie sa data et n'a pas toujours de réseau, une carte déjà regardée
/// doit rester regardable.
///
/// Volontairement modeste : pas d'index, pas de base. Un fichier par tuile,
/// nommé par l'empreinte de son URL, et un ménage par date de dernier accès
/// quand le dossier dépasse [maxBytes]. Une tuile de rue ne périme pas vite,
/// d'où [maxAge] en semaines plutôt qu'en heures.
class CachedTileProvider extends TileProvider {
  CachedTileProvider({
    required Directory directory,
    Dio? client,
    this.maxBytes = 40 * 1024 * 1024,
    this.maxAge = const Duration(days: 30),
  }) : _directory = directory,
       _client = client ?? Dio();

  final Directory _directory;
  final Dio _client;

  /// Plafond du dossier. Dépassé, les tuiles les plus anciennement lues
  /// partent en premier.
  final int maxBytes;

  /// Au-delà, la tuile est refetchée si le réseau répond — et resservie telle
  /// quelle s'il ne répond pas. Une carte périmée vaut mieux qu'un carré gris.
  final Duration maxAge;

  /// Ouvre (ou crée) le dossier de tuiles sous le chemin donné.
  static Future<CachedTileProvider> open(
    String parentPath, {
    Dio? client,
  }) async {
    final Directory dir = Directory('$parentPath/map-tiles');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return CachedTileProvider(directory: dir, client: client);
  }

  @override
  ImageProvider<Object> getImage(
    TileCoordinates coordinates,
    TileLayer options,
  ) {
    return _DiskTileImage(
      url: getTileUrl(coordinates, options),
      provider: this,
    );
  }

  File _fileFor(String url) => File('${_directory.path}/${_hash(url)}.tile');

  /// FNV-1a 64 bits, écrit ici plutôt que tiré d'un paquet : il ne s'agit que
  /// de donner un nom de fichier court et stable à une URL, pas de résister à
  /// une attaque.
  @visibleForTesting
  static String hashUrl(String url) => _hash(url);

  static String _hash(String value) {
    var hash = 0xcbf29ce484222325;
    for (final int unit in value.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x100000001b3) & 0xFFFFFFFFFFFFFFFF;
    }
    return hash.toRadixString(16).padLeft(16, '0');
  }

  Future<Uint8List> load(String url) async {
    final File file = _fileFor(url);
    final bool exists = await file.exists();
    final bool fresh =
        exists && DateTime.now().difference(await file.lastModified()) < maxAge;

    if (exists && fresh) {
      unawaited(_touch(file));
      return file.readAsBytes();
    }

    try {
      final Response<List<int>> response = await _client.get<List<int>>(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          headers: const <String, String>{
            // Exigé par la politique d'usage des tuiles OSM.
            'User-Agent': 'WoutalmaKeur/1.0 (sn.lic.woutalma_keur)',
          },
        ),
      );
      final Uint8List bytes = Uint8List.fromList(
        response.data ?? const <int>[],
      );
      if (bytes.isEmpty) {
        throw const _EmptyTile();
      }
      await file.writeAsBytes(bytes, flush: false);
      unawaited(_sweep());
      return bytes;
    } catch (_) {
      // Réseau absent ou serveur muet : une copie même périmée reste la
      // meilleure réponse possible.
      if (exists) {
        return file.readAsBytes();
      }
      rethrow;
    }
  }

  Future<void> _touch(File file) async {
    try {
      await file.setLastAccessed(DateTime.now());
    } on FileSystemException {
      // Certains systèmes de fichiers refusent : le ménage retombera sur la
      // date de modification, ce qui reste un ordre acceptable.
    }
  }

  /// Ramène le dossier sous le plafond, les tuiles les moins récemment lues
  /// d'abord.
  Future<void> _sweep() async {
    try {
      final List<FileSystemEntity> entries = await _directory.list().toList();
      final List<(File, FileStat)> files = <(File, FileStat)>[];
      var total = 0;
      for (final FileSystemEntity entry in entries) {
        if (entry is! File) {
          continue;
        }
        final FileStat stat = await entry.stat();
        total += stat.size;
        files.add((entry, stat));
      }
      if (total <= maxBytes) {
        return;
      }
      files.sort(
        ((File, FileStat) a, (File, FileStat) b) =>
            a.$2.accessed.compareTo(b.$2.accessed),
      );
      for (final (File file, FileStat stat) in files) {
        if (total <= maxBytes) {
          return;
        }
        await file.delete();
        total -= stat.size;
      }
    } on FileSystemException {
      // Un ménage raté n'est pas une erreur visible : au pire le dossier
      // dépasse jusqu'au prochain passage.
    }
  }
}

class _EmptyTile implements Exception {
  const _EmptyTile();
}

/// Charge une tuile en passant par le disque.
///
/// Deux tuiles de même URL doivent partager la même clé, sinon Flutter garde
/// deux entrées en mémoire pour la même image.
@immutable
class _DiskTileImage extends ImageProvider<_DiskTileImage> {
  const _DiskTileImage({required this.url, required this.provider});

  final String url;
  final CachedTileProvider provider;

  @override
  Future<_DiskTileImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture<_DiskTileImage>(this);

  @override
  ImageStreamCompleter loadImage(
    _DiskTileImage key,
    ImageDecoderCallback decode,
  ) {
    return MultiFrameImageStreamCompleter(
      codec: _decode(decode),
      scale: 1,
      debugLabel: url,
    );
  }

  Future<ui.Codec> _decode(ImageDecoderCallback decode) async {
    final Uint8List bytes = await provider.load(url);
    return decode(await ui.ImmutableBuffer.fromUint8List(bytes));
  }

  @override
  bool operator ==(Object other) => other is _DiskTileImage && other.url == url;

  @override
  int get hashCode => url.hashCode;
}
