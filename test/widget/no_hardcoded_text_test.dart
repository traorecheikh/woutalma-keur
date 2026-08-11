import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_keur/app/l10n/generated/app_l10n.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';

import '../support/hardcoded_text.dart';
import '../support/l10n_corpus.dart';

/// Le garde-fou de `lib/app/l10n/README.md`.
///
/// Il est testé sur lui-même : un garde-fou qui ne prouve pas qu'il attrape
/// une violation ne garde rien.
void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: WkTheme.light(),
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      home: Scaffold(body: child),
    );
  }

  testWidgets('attrape une phrase écrite en dur', (WidgetTester tester) async {
    await tester.pumpWidget(
      wrap(const Text('Trouvez un courtier près de vous')),
    );

    expect(findHardcodedText(tester), <String>[
      'Trouvez un courtier près de vous',
    ]);
  });

  testWidgets('laisse passer une chaîne venue de l\'ARB', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        Builder(
          builder: (BuildContext context) => Text(context.l10n.commonRetry),
        ),
      ),
    );

    expect(findHardcodedText(tester), isEmpty);
  });

  testWidgets('laisse passer une donnée sans mot traduisible', (
    WidgetTester tester,
  ) async {
    // Une note, une distance, un code couleur : données produites à
    // l'exécution, pas de la copie.
    await tester.pumpWidget(
      wrap(
        const Column(
          children: <Widget>[Text('4,6'), Text('800 m'), Text('#0B3B66')],
        ),
      ),
    );

    expect(findHardcodedText(tester), isEmpty);
  });

  testWidgets('attrape une unité monétaire écrite en dur', (
    WidgetTester tester,
  ) async {
    // Volontaire : « FCFA » ressemble à une donnée mais c'est une unité, donc
    // de la copie. Elle doit venir de l'ARB, sinon une seconde monnaie ou une
    // seconde langue oblige à rouvrir chaque écran qui affiche un prix.
    await tester.pumpWidget(wrap(const Text('120 000 FCFA')));

    expect(findHardcodedText(tester), <String>['120 000 FCFA']);
  });

  test('les motifs couvrent placeholders et branches de pluriel', () {
    final List<RegExp> patterns = loadL10nPatterns();

    bool matches(String value) => patterns.any((RegExp p) => p.hasMatch(value));

    expect(patterns, isNotEmpty);
    expect(matches('Réessayer'), isTrue);
    // Trois branches d'un même pluriel, dont aucune n'est la valeur ARB.
    expect(matches('Aucun avis'), isTrue);
    expect(matches('1 avis'), isTrue);
    expect(matches('12 avis'), isTrue);
    // Un placeholder accepte la donnée mise en forme à l'exécution.
    expect(matches('350 000 F/mois'), isTrue);
    // `@@locale` n'est pas du texte affichable.
    expect(matches('fr'), isFalse);
  });
}
