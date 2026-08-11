import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_keur/app/modules/catalog/catalog_screen.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_badge.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_broker_card.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_button.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_icon_button.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_option_sheet.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_property_card.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_rating.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_states.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_text_field.dart';

import '../support/pump.dart';

void main() {
  testWidgets('le catalogue montre les composants qu\'il annonce', (
    WidgetTester tester,
  ) async {
    // Le sous-titre promet « les composants partagés et tous leurs états »
    // alors que l'écran n'affichait que des jetons. Une fixture qui ment sur
    // son contenu ne sert à rien : on n'y valide jamais ce qu'on croit.
    await pumpWk(
      tester,
      const CatalogScreen(),
      // Surface haute : un ListView ne construit pas ce qu'il n'affiche pas,
      // et tout le catalogue doit exister pour être inventorié.
      surfaceSize: const Size(360, 8000),
    );
    // Pas de `pumpAndSettle` : l'indicateur de chargement tourne en boucle,
    // c'est son travail.
    await tester.pump(const Duration(milliseconds: 300));

    for (final Type component in <Type>[
      WkButton,
      WkTextField,
      WkBadge,
      WkRating,
      WkBrokerCard,
      WkPropertyCard,
      WkLoadingState,
      WkEmptyState,
      WkErrorState,
    ]) {
      expect(
        find.byType(component, skipOffstage: false),
        findsWidgets,
        reason: '$component absent du catalogue',
      );
    }

    // Le type est générique : on ne peut pas le chercher par `Type`.
    expect(
      find.byWidgetPredicate(
        (Widget w) => w is WkSelectField,
        skipOffstage: false,
      ),
      findsWidgets,
    );
  });

  testWidgets('chaque variante de bouton est représentée', (
    WidgetTester tester,
  ) async {
    await pumpWk(
      tester,
      const CatalogScreen(),
      // Surface haute : un ListView ne construit pas ce qu'il n'affiche pas,
      // et tout le catalogue doit exister pour être inventorié.
      surfaceSize: const Size(360, 8000),
    );
    // Pas de `pumpAndSettle` : l'indicateur de chargement tourne en boucle,
    // c'est son travail.
    await tester.pump(const Duration(milliseconds: 300));

    final Set<WkButtonVariant> shown = tester
        .widgetList<WkButton>(find.byType(WkButton, skipOffstage: false))
        .map((WkButton b) => b.variant)
        .toSet();

    // Une variante jamais montrée est une variante jamais relue : c'est ainsi
    // qu'un `danger` finit par ressembler à un `primary`.
    expect(shown, containsAll(WkButtonVariant.values));
  });

  testWidgets('les états désactivé et en cours sont visibles côte à côte', (
    WidgetTester tester,
  ) async {
    await pumpWk(
      tester,
      const CatalogScreen(),
      // Surface haute : un ListView ne construit pas ce qu'il n'affiche pas,
      // et tout le catalogue doit exister pour être inventorié.
      surfaceSize: const Size(360, 8000),
    );
    // Pas de `pumpAndSettle` : l'indicateur de chargement tourne en boucle,
    // c'est son travail.
    await tester.pump(const Duration(milliseconds: 300));

    final List<WkButton> buttons = tester
        .widgetList<WkButton>(find.byType(WkButton, skipOffstage: false))
        .toList();

    expect(buttons.any((WkButton b) => b.onPressed == null), isTrue);
    expect(buttons.any((WkButton b) => b.loading), isTrue);
  });

  testWidgets('un bouton-icône désactivé se voit, pas seulement s\'entend', (
    WidgetTester tester,
  ) async {
    // Repéré dans le catalogue : les trois pictogrammes avaient la même
    // intensité, alors que le dernier n'était pas actionnable.
    await pumpWk(
      tester,
      const CatalogScreen(),
      surfaceSize: const Size(360, 8000),
    );
    await tester.pump(const Duration(milliseconds: 300));

    double opacityOf(String label) {
      final Finder button = find.byWidgetPredicate(
        (Widget w) => w is WkIconButton && w.label == label,
        skipOffstage: false,
      );
      return tester
          .widget<Opacity>(
            find.descendant(of: button, matching: find.byType(Opacity)).first,
          )
          .opacity;
    }

    expect(opacityOf('mic'), 1);
    expect(opacityOf('share'), lessThan(1));
  });
}
