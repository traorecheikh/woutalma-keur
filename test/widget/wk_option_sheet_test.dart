import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_option_sheet.dart';

import '../support/pump.dart';

void main() {
  Future<List<String?>?> capture(
    WidgetTester tester, {
    required String tapLabel,
  }) async {
    List<String?>? result;
    await pumpWk(
      tester,
      Builder(
        builder: (BuildContext context) => Center(
          child: TextButton(
            onPressed: () async {
              result = await WkOptionSheet.show<String?>(
                context,
                title: 'Type',
                options: const <WkOption<String?>>[
                  WkOption<String?>(value: null, label: 'Peu importe'),
                  WkOption<String?>(value: 'maison', label: 'Maison'),
                ],
              );
            },
            child: const Text('ouvrir'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('ouvrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(tapLabel));
    await tester.pumpAndSettle();
    return result;
  }

  testWidgets('choisir une option à valeur nulle se distingue d\'un abandon', (
    WidgetTester tester,
  ) async {
    // « Peu importe » retire un filtre. Si sa valeur nulle était renvoyée
    // telle quelle, elle serait confondue avec une feuille fermée et le
    // filtre resterait posé pour toujours.
    final List<String?>? picked = await capture(
      tester,
      tapLabel: 'Peu importe',
    );

    expect(picked, isNotNull);
    expect(picked!.single, isNull);
  });

  testWidgets('choisir une option ordinaire renvoie sa valeur', (
    WidgetTester tester,
  ) async {
    final List<String?>? picked = await capture(tester, tapLabel: 'Maison');

    expect(picked!.single, 'maison');
  });

  testWidgets('fermer sans choisir ne renvoie rien', (
    WidgetTester tester,
  ) async {
    List<String?>? result;
    await pumpWk(
      tester,
      Builder(
        builder: (BuildContext context) => Center(
          child: TextButton(
            onPressed: () async {
              result = await WkOptionSheet.show<String?>(
                context,
                title: 'Type',
                options: const <WkOption<String?>>[
                  WkOption<String?>(value: null, label: 'Peu importe'),
                ],
              );
            },
            child: const Text('ouvrir'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('ouvrir'));
    await tester.pumpAndSettle();
    // Balayage vers le bas : la feuille se ferme sans sélection.
    await tester.tapAt(const Offset(180, 40));
    await tester.pumpAndSettle();

    expect(result, isNull);
  });

  testWidgets('une option sans picto garde la colonne des autres', (
    WidgetTester tester,
  ) async {
    // Repéré à l'écran : « Peu importe » portait une icône, « Maison » non,
    // et les deux libellés commençaient à 38 dp d'écart. L'œil ne suivait
    // plus une colonne, il zigzaguait.
    await pumpWk(
      tester,
      const WkOptionSheet<String>(
        title: 'Type',
        options: <WkOption<String>>[
          WkOption<String>(
            value: 'a',
            label: 'Peu importe',
            icon: Icons.all_inclusive,
          ),
          WkOption<String>(value: 'b', label: 'Maison'),
        ],
      ),
    );

    expect(
      tester.getTopLeft(find.text('Maison')).dx,
      tester.getTopLeft(find.text('Peu importe')).dx,
    );
  });

  testWidgets('la feuille couvre la barre d\'onglets', (
    WidgetTester tester,
  ) async {
    // Une feuille ouverte dans le Navigator d'un onglet laisse la barre
    // d'onglets au-dessus de sa propre barrière : on peut changer d'onglet
    // pendant une confirmation, et la feuille survit dans l'onglet caché.
    var tabTaps = 0;
    await pumpWk(
      tester,
      Column(
        children: <Widget>[
          Expanded(
            child: Navigator(
              onGenerateRoute: (RouteSettings settings) =>
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => Center(
                      child: TextButton(
                        onPressed: () => WkOptionSheet.show<String>(
                          context,
                          title: 'Type',
                          options: const <WkOption<String>>[
                            WkOption<String>(value: 'a', label: 'Maison'),
                          ],
                        ),
                        child: const Text('ouvrir'),
                      ),
                    ),
                  ),
            ),
          ),
          SizedBox(
            height: 80,
            child: TextButton(
              onPressed: () => tabTaps++,
              child: const Text('Mes contacts'),
            ),
          ),
        ],
      ),
    );

    await tester.tap(find.text('ouvrir'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mes contacts'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(tabTaps, 0);
  });

  testWidgets('chaque ligne atteint la hauteur confortable', (
    WidgetTester tester,
  ) async {
    await pumpWk(
      tester,
      const WkOptionSheet<String>(
        title: 'Type',
        options: <WkOption<String>>[
          WkOption<String>(value: 'a', label: 'Maison'),
          WkOption<String>(value: 'b', label: 'Terrain'),
        ],
      ),
    );

    expectTouchTargets(tester, minimum: 56);
  });
}
