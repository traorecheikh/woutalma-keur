import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:woutalma_keur/app/domain/photo_service.dart';

/// Prépare les photos d'un bien avant l'envoi au serveur.
///
/// `Property.photoAssets` mélange deux natures très différentes :
///
/// - une **clé d'affichage** que le serveur connaît déjà (`demo:…` pour le
///   jeu de démonstration, `api:<id>` pour des octets déjà stockés) ;
/// - un **chemin de fichier local** (`/data/user/0/…/wk-123.jpg`) quand le
///   courtier vient de prendre la photo.
///
/// Le serveur accepte le second comme une chaîne opaque : la photo s'affichait
/// alors sur le seul téléphone qui l'a publiée et restait une icône cassée
/// pour tout le monde. Cette classe sépare les deux, lit les fichiers locaux
/// et les encode en base64 dans `newPhotos`, où le serveur les stocke
/// vraiment et rend des clés `api:<id>`.
///
/// Les limites du serveur (`write-property.dto.ts` : 3 photos, 160 Ko après
/// décodage, jpeg/png/webp) sont revérifiées ici. Les répéter côté client
/// n'est pas de la défiance : sur un réseau faible, découvrir un refus après
/// avoir téléversé 2 Mo coûte de la data que le courtier a payée.

/// Pourquoi une photo n'a pas pu être préparée.
enum PhotoUploadRefusal {
  /// Plus de photos que le serveur n'en accepte par bien.
  tooMany,

  /// Ni jpeg, ni png, ni webp.
  unsupportedType,

  /// Toujours au-dessus de la limite après recompression.
  tooLarge,

  /// Fichier absent, vide ou illisible.
  unreadable,
}

/// Échec de préparation. Porte un code, jamais une phrase : l'écran traduit.
@immutable
class PhotoUploadFailed implements Exception {
  const PhotoUploadFailed(this.refusal, {this.path});

  final PhotoUploadRefusal refusal;

  /// Chemin fautif, pour le journal de développement uniquement.
  final String? path;

  @override
  String toString() => 'PhotoUploadFailed(${refusal.name}, $path)';
}

/// Une photo prête à partir : octets encodés et type déclaré.
@immutable
class PreparedPhoto {
  const PreparedPhoto({required this.mimeType, required this.dataBase64});

  final String mimeType;
  final String dataBase64;
}

/// Résultat du tri : ce qui repart tel quel, ce qui monte.
@immutable
class PreparedPhotos {
  const PreparedPhotos({required this.retained, required this.uploads});

  /// Clés déjà connues du serveur, dans l'ordre d'affichage.
  final List<String> retained;

  /// Nouvelles photos, ajoutées après [retained] par le serveur.
  final List<PreparedPhoto> uploads;
}

/// Lit les octets d'un chemin local. Injectable pour tester sans appareil.
typedef PhotoBytesReader = Future<Uint8List> Function(String path);

/// Recompresse un fichier et rend les octets, ou `null` si impossible.
typedef PhotoRecompressor =
    Future<Uint8List?> Function(
      String path, {
      required int quality,
      required int width,
    });

class PropertyPhotoUploader {
  const PropertyPhotoUploader({
    this.constraints = const PhotoConstraints(),
    PhotoBytesReader readBytes = _readFile,
    PhotoRecompressor recompress = _compressFile,
  }) : _readBytes = readBytes,
       _recompress = recompress;

  final PhotoConstraints constraints;
  final PhotoBytesReader _readBytes;
  final PhotoRecompressor _recompress;

  static Future<Uint8List> _readFile(String path) => File(path).readAsBytes();

  static Future<Uint8List?> _compressFile(
    String path, {
    required int quality,
    required int width,
  }) {
    return FlutterImageCompress.compressWithFile(
      path,
      quality: quality,
      minWidth: width,
      // La hauteur suit le ratio : on ne déforme jamais une photo de logement.
      minHeight: 1,
      format: CompressFormat.jpeg,
    );
  }

  /// Vrai quand la clé désigne quelque chose que le serveur sait déjà rendre.
  static bool isServerKey(String asset) =>
      asset.startsWith('demo:') ||
      asset.startsWith('api:') ||
      asset.startsWith('assets/') ||
      asset.startsWith('http://') ||
      asset.startsWith('https://');

  /// Trie [photoAssets] en clés conservées et photos à téléverser.
  Future<PreparedPhotos> prepare(List<String> photoAssets) async {
    if (photoAssets.length > constraints.maxPerProperty) {
      // Compté avant la moindre lecture disque : inutile de compresser
      // quatre photos pour en faire refuser une par le serveur.
      throw const PhotoUploadFailed(PhotoUploadRefusal.tooMany);
    }

    final List<String> retained = <String>[];
    final List<PreparedPhoto> uploads = <PreparedPhoto>[];
    for (final String asset in photoAssets) {
      if (isServerKey(asset)) {
        retained.add(asset);
      } else {
        uploads.add(await _encode(asset));
      }
    }
    return PreparedPhotos(retained: retained, uploads: uploads);
  }

  Future<PreparedPhoto> _encode(String path) async {
    Uint8List bytes;
    try {
      bytes = await _readBytes(path);
    } on Object {
      throw PhotoUploadFailed(PhotoUploadRefusal.unreadable, path: path);
    }
    if (bytes.isEmpty) {
      throw PhotoUploadFailed(PhotoUploadRefusal.unreadable, path: path);
    }

    String? mimeType = _mimeOf(bytes);

    if (bytes.length > constraints.maxUploadBytes) {
      // Recompresser plutôt que refuser : la photo est déjà prise, et
      // l'écran de publication n'a rien d'autre à proposer au courtier.
      final Uint8List? smaller = await _shrink(path);
      if (smaller == null) {
        throw PhotoUploadFailed(PhotoUploadRefusal.tooLarge, path: path);
      }
      bytes = smaller;
      // La recompression sort du jpeg, quel que soit le format d'entrée.
      mimeType = _mimeOf(bytes) ?? 'image/jpeg';
    }

    if (mimeType == null ||
        !PhotoConstraints.allowedMimeTypes.contains(mimeType)) {
      throw PhotoUploadFailed(PhotoUploadRefusal.unsupportedType, path: path);
    }
    if (bytes.length > constraints.maxUploadBytes) {
      throw PhotoUploadFailed(PhotoUploadRefusal.tooLarge, path: path);
    }

    return PreparedPhoto(mimeType: mimeType, dataBase64: base64Encode(bytes));
  }

  /// Passes successives, de moins en moins de qualité et de largeur. On
  /// s'arrête à la première qui tient sous la limite : au-delà, on abîmerait
  /// la photo sans nécessité.
  Future<Uint8List?> _shrink(String path) async {
    for (final ({int quality, int width}) attempt in _attempts()) {
      Uint8List? candidate;
      try {
        candidate = await _recompress(
          path,
          quality: attempt.quality,
          width: attempt.width,
        );
      } on Object {
        return null;
      }
      if (candidate == null || candidate.isEmpty) {
        return null;
      }
      if (candidate.length <= constraints.maxUploadBytes) {
        return candidate;
      }
    }
    return null;
  }

  Iterable<({int quality, int width})> _attempts() sync* {
    final int width = constraints.maxWidth;
    yield (quality: constraints.quality, width: width);
    yield (quality: 55, width: (width * 0.8).round());
    yield (quality: 40, width: (width * 0.62).round());
    yield (quality: 28, width: (width * 0.5).round());
  }

  /// Type déduit des octets, pas de l'extension : un `.jpg` renommé depuis un
  /// heic passerait la vérification d'extension et se ferait refuser au bout
  /// du téléversement.
  static String? _mimeOf(Uint8List bytes) {
    if (bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF) {
      return 'image/jpeg';
    }
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0D &&
        bytes[5] == 0x0A &&
        bytes[6] == 0x1A &&
        bytes[7] == 0x0A) {
      return 'image/png';
    }
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return 'image/webp';
    }
    return null;
  }
}
