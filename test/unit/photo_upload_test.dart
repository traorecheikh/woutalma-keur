import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_keur/app/data/services/property_photo_uploader.dart';
import 'package:woutalma_keur/app/domain/photo_service.dart';

/// Octets minimaux reconnaissables par leur en-tête, comme le fait le serveur.
Uint8List _jpeg(int length) {
  final Uint8List bytes = Uint8List(length);
  bytes[0] = 0xFF;
  bytes[1] = 0xD8;
  bytes[2] = 0xFF;
  return bytes;
}

Uint8List _png(int length) {
  final Uint8List bytes = Uint8List(length);
  bytes.setAll(0, const <int>[0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
  return bytes;
}

Uint8List _heic(int length) {
  final Uint8List bytes = Uint8List(length);
  bytes.setAll(0, const <int>[0x00, 0x00, 0x00, 0x18, 0x66, 0x74, 0x79, 0x70]);
  return bytes;
}

/// Lit depuis une table en mémoire : aucun accès disque, aucun plugin.
PhotoBytesReader _reader(Map<String, Uint8List> files) {
  return (String path) async {
    final Uint8List? bytes = files[path];
    if (bytes == null) {
      throw StateError('fichier absent : $path');
    }
    return bytes;
  };
}

void main() {
  const PhotoConstraints constraints = PhotoConstraints();

  test('les clés déjà connues du serveur ne repartent pas en octets', () async {
    final PropertyPhotoUploader uploader = PropertyPhotoUploader(
      readBytes: _reader(<String, Uint8List>{}),
      recompress: (_, {required int quality, required int width}) async => null,
    );

    final PreparedPhotos prepared = await uploader.prepare(<String>[
      'demo:house:medina:front',
      'api:ckphoto1',
    ]);

    expect(prepared.retained, <String>[
      'demo:house:medina:front',
      'api:ckphoto1',
    ]);
    expect(prepared.uploads, isEmpty);
  });

  test('un chemin local devient une photo encodée en base64', () async {
    final Uint8List bytes = _jpeg(2048);
    final PropertyPhotoUploader uploader = PropertyPhotoUploader(
      readBytes: _reader(<String, Uint8List>{'/data/user/0/wk-1.jpg': bytes}),
      recompress: (_, {required int quality, required int width}) async => null,
    );

    final PreparedPhotos prepared = await uploader.prepare(<String>[
      'api:ckphoto1',
      '/data/user/0/wk-1.jpg',
    ]);

    // Le chemin local ne doit jamais rester dans photoAssets : le serveur
    // l'accepterait comme une chaîne opaque et l'image serait cassée partout
    // ailleurs que sur le téléphone qui a publié.
    expect(prepared.retained, <String>['api:ckphoto1']);
    expect(prepared.uploads, hasLength(1));
    expect(prepared.uploads.single.mimeType, 'image/jpeg');
    expect(base64Decode(prepared.uploads.single.dataBase64), bytes);
  });

  test('le png est reconnu par ses octets, pas par son extension', () async {
    final PropertyPhotoUploader uploader = PropertyPhotoUploader(
      readBytes: _reader(<String, Uint8List>{'/tmp/photo.jpg': _png(512)}),
      recompress: (_, {required int quality, required int width}) async => null,
    );

    final PreparedPhotos prepared = await uploader.prepare(<String>[
      '/tmp/photo.jpg',
    ]);

    expect(prepared.uploads.single.mimeType, 'image/png');
  });

  test('un type que le serveur refuse est refusé avant l\'envoi', () async {
    final PropertyPhotoUploader uploader = PropertyPhotoUploader(
      readBytes: _reader(<String, Uint8List>{'/tmp/photo.heic': _heic(512)}),
      recompress: (_, {required int quality, required int width}) async => null,
    );

    await expectLater(
      uploader.prepare(<String>['/tmp/photo.heic']),
      throwsA(
        isA<PhotoUploadFailed>().having(
          (PhotoUploadFailed e) => e.refusal,
          'refusal',
          PhotoUploadRefusal.unsupportedType,
        ),
      ),
    );
  });

  test('une photo trop lourde est recompressée, pas refusée', () async {
    final Uint8List heavy = _jpeg(constraints.maxUploadBytes + 1);
    int calls = 0;
    final PropertyPhotoUploader uploader = PropertyPhotoUploader(
      readBytes: _reader(<String, Uint8List>{'/tmp/heavy.jpg': heavy}),
      recompress: (_, {required int quality, required int width}) async {
        calls++;
        // La première passe ne suffit pas ; la seconde tient sous la limite.
        return calls == 1
            ? _jpeg(constraints.maxUploadBytes + 1)
            : _jpeg(constraints.maxUploadBytes ~/ 2);
      },
    );

    final PreparedPhotos prepared = await uploader.prepare(<String>[
      '/tmp/heavy.jpg',
    ]);

    expect(calls, 2);
    expect(
      base64Decode(prepared.uploads.single.dataBase64).length,
      lessThanOrEqualTo(constraints.maxUploadBytes),
    );
  });

  test(
    'une photo qui reste trop lourde après compression est signalée',
    () async {
      final PropertyPhotoUploader uploader = PropertyPhotoUploader(
        readBytes: _reader(<String, Uint8List>{
          '/tmp/heavy.jpg': _jpeg(constraints.maxUploadBytes * 4),
        }),
        recompress: (_, {required int quality, required int width}) async =>
            _jpeg(constraints.maxUploadBytes * 2),
      );

      await expectLater(
        uploader.prepare(<String>['/tmp/heavy.jpg']),
        throwsA(
          isA<PhotoUploadFailed>().having(
            (PhotoUploadFailed e) => e.refusal,
            'refusal',
            PhotoUploadRefusal.tooLarge,
          ),
        ),
      );
    },
  );

  test('au-delà de la limite du serveur, rien n\'est même lu', () async {
    int reads = 0;
    final PropertyPhotoUploader uploader = PropertyPhotoUploader(
      readBytes: (String path) async {
        reads++;
        return _jpeg(64);
      },
      recompress: (_, {required int quality, required int width}) async => null,
    );

    await expectLater(
      uploader.prepare(<String>['/a.jpg', '/b.jpg', '/c.jpg', '/d.jpg']),
      throwsA(
        isA<PhotoUploadFailed>().having(
          (PhotoUploadFailed e) => e.refusal,
          'refusal',
          PhotoUploadRefusal.tooMany,
        ),
      ),
    );
    expect(reads, 0);
  });

  test('un fichier illisible est signalé plutôt que téléversé vide', () async {
    final PropertyPhotoUploader uploader = PropertyPhotoUploader(
      readBytes: _reader(<String, Uint8List>{}),
      recompress: (_, {required int quality, required int width}) async => null,
    );

    await expectLater(
      uploader.prepare(<String>['/tmp/disparu.jpg']),
      throwsA(
        isA<PhotoUploadFailed>().having(
          (PhotoUploadFailed e) => e.refusal,
          'refusal',
          PhotoUploadRefusal.unreadable,
        ),
      ),
    );
  });

  test('le sélecteur et le serveur comptent le même maximum', () {
    // `MAX_PHOTOS_PER_PROPERTY` vaut 3 côté serveur : en accepter six côté
    // client fait prendre trois photos pour rien.
    expect(constraints.maxPerProperty, 3);
    expect(constraints.maxUploadBytes, 160 * 1024);
  });
}
