import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_shell.dart';

import '../support/pump.dart';

void main() {
  testWidgets('le dock de navigation reste utilisable à 320 dp et ×1.3', (
    WidgetTester tester,
  ) async {
    int selected = 0;

    await pumpWk(
      tester,
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return WkDockNav(
            index: selected,
            onSelect: (int value) => setState(() => selected = value),
            // Les libellés d'onglet de `docs/UX-FLOWS.md` §4, pas les titres
            // d'écran : trois destinations se partagent 320 dp, et chacune
            // porte son libellé en clair, sélectionnée ou non.
            items: const <(IconData, String)>[
              (Icons.travel_explore, 'Explorer'),
              (Icons.history, 'Contacts'),
              (Icons.person_outline, 'Profil'),
            ],
          );
        },
      ),
      surfaceSize: const Size(320, 220),
      textScale: 1.3,
    );

    expectTouchTargets(tester);
    expectNoClippedText(tester);

    await tester.tap(find.byIcon(Icons.history));
    await tester.pumpAndSettle();

    expect(selected, 1);
    expectTouchTargets(tester);
    expectNoClippedText(tester);
  });
}
