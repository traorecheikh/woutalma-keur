import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/modules/client/explore/results_map.dart';

import '../support/pump.dart';

/// Ne rend jamais une tuile : le réseau faible est le cas normal ici, pas
/// l'exception.
class _FailingTileProvider extends TileProvider {
  @override
  ImageProvider<Object> getImage(
    TileCoordinates coordinates,
    TileLayer options,
  ) {
    return const _FailingImage();
  }
}

class _FailingImage extends ImageProvider<_FailingImage> {
  const _FailingImage();

  @override
  Future<_FailingImage> obtainKey(ImageConfiguration configuration) async =>
      this;

  @override
  ImageStreamCompleter loadImage(_FailingImage key, ImageDecoderCallback _) {
    return OneFrameImageStreamCompleter(
      Future<ImageInfo>.error(Exception('pas de réseau')),
    );
  }
}

/// Rend toujours une tuile : le cas nominal, qu'un test ne peut pas obtenir
/// du réseau — le binding de test répond 400 à toute requête HTTP.
class _BlankTileProvider extends TileProvider {
  @override
  ImageProvider<Object> getImage(
    TileCoordinates coordinates,
    TileLayer options,
  ) {
    return MemoryImage(Uint8List.fromList(_transparentPng));
  }
}

/// PNG 1×1 transparent.
const List<int> _transparentPng = <int>[
  137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, //
  0, 0, 0, 1, 8, 6, 0, 0, 0, 31, 21, 196, 137, 0, 0, 0, 10, 73, 68, 65, 84,
  120, 156, 99, 0, 1, 0, 0, 5, 0, 1, 13, 10, 45, 180, 0, 0, 0, 0, 73, 69, 78,
  68, 174, 66, 96, 130,
];

void main() {
  Future<void> pumpMap(WidgetTester tester, {TileProvider? provider}) async {
    await pumpWk(
      tester,
      SizedBox(
        height: 400,
        child: ResultsMap(
          center: const GeoPoint(14.6690, -17.4380),
          markers: const <(String, GeoPoint)>[
            ('brk-moussa', GeoPoint(14.6712, -17.4395)),
          ],
          onSelect: (_) {},
          tileProvider: provider,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('des tuiles qui n\'arrivent pas sont annoncées', (
    WidgetTester tester,
  ) async {
    // Sans un mot, la carte se réduit à un rectangle gris avec des repères qui
    // flottent, et on croit que l'application est cassée.
    await pumpMap(tester, provider: _FailingTileProvider());

    expect(
      find.text(
        'Les images de la carte n\'arrivent pas. Les repères et la liste '
        'fonctionnent toujours.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('sinon c\'est l\'avertissement sur les données qui s\'affiche', (
    WidgetTester tester,
  ) async {
    // Tuiles absentes mais sans erreur : rien n'a échoué, donc rien à annoncer.
    await pumpMap(tester, provider: _BlankTileProvider());

    expect(
      find.text(
        'La carte télécharge des images. En mode léger, restez sur la liste.',
      ),
      findsOneWidget,
    );
  });
}
