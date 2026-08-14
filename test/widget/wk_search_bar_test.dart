import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_search_bar.dart';

import '../support/pump.dart';

void main() {
  testWidgets('la barre déclencheur n\'affiche aucun micro par défaut', (
    WidgetTester tester,
  ) async {
    await pumpWk(
      tester,
      WkSearchTrigger(
        onOpen: () {},
        hint: 'Chercher',
        semanticLabel: 'Ouvrir la recherche',
      ),
    );

    // Le micro ne reviendra pas par l'oubli d'un paramètre : il n'existe que
    // si un appelant fournit `onVoice`, et aucun ne le fait tant qu'aucun
    // moteur de reconnaissance réel n'est branché.
    expect(find.byIcon(Icons.mic), findsNothing);
  });

  testWidgets('le champ de recherche n\'affiche aucun micro par défaut', (
    WidgetTester tester,
  ) async {
    await pumpWk(
      tester,
      WkSearchBar(
        controller: TextEditingController(),
        onChanged: (_) {},
        hint: 'Chercher',
      ),
    );

    expect(find.byIcon(Icons.mic), findsNothing);
  });

  testWidgets('les cibles tactiles restent au-dessus du plancher', (
    WidgetTester tester,
  ) async {
    await pumpWk(
      tester,
      WkSearchTrigger(
        onOpen: () {},
        hint: 'Chercher',
        semanticLabel: 'Ouvrir la recherche',
      ),
    );

    // Retirer le micro ne doit pas avoir rétréci ce qui reste.
    expectTouchTargets(tester);
  });
}
