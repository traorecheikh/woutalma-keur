import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_keur/app/data/seed/demo_seed.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_property_card.dart';

import '../support/pump.dart';

void main() {
  testWidgets('la carte bien donne la priorité à la photo et à la galerie', (
    WidgetTester tester,
  ) async {
    await pumpWk(
      tester,
      WkPropertyCard(
        property: const DemoSeed().properties().first,
        distanceMeters: 1600,
        onOpen: () {},
      ),
      surfaceSize: const Size(360, 440),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(WkPropertyCard),
      matchesGoldenFile('goldens/wk_property_card.png'),
    );
  });
}
