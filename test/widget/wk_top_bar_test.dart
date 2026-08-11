import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_top_bar.dart';

import '../support/pump.dart';

void main() {
  testWidgets('la barre haute ne déborde pas même très étroite', (
    WidgetTester tester,
  ) async {
    await pumpWk(
      tester,
      WkTopBar(title: 'Votre numéro', onBack: () {}),
      surfaceSize: const Size(155, 160),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('le titre long reste lisible à ×1.3', (
    WidgetTester tester,
  ) async {
    await pumpWk(
      tester,
      WkTopBar(title: 'Agence Teranga Immo', onBack: () {}),
      surfaceSize: const Size(360, 160),
      textScale: 1.3,
    );

    expectNoClippedText(tester);
  });
}
