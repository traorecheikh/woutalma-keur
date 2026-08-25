import 'dart:io';

import 'package:flutter/services.dart';

/// Charge la police de l'application dans le moteur de test.
///
/// Sans elle, `flutter test` mesure chaque glyphe à 1 em : « Recevoir le code »
/// fait alors 291 px au lieu de 160, et tout dépassement observé à ×1.3 est un
/// artefact de la police de repli, pas un défaut de l'écran.
Future<void> loadAppFonts() async {
  final loader = FontLoader('PlusJakartaSans');
  for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    loader.addFont(
      File(
        'assets/fonts/PlusJakartaSans-$weight.ttf',
      ).readAsBytes().then((bytes) => ByteData.view(bytes.buffer)),
    );
  }
  await loader.load();
}
