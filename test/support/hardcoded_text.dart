import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'l10n_corpus.dart';

/// Texte visible rendu par l'arbre courant qui ne vient ni de l'ARB, ni des
/// données.
///
/// Sont tolérés :
/// - tout texte correspondant à un motif de `app_fr.arb`, placeholders et
///   branches de pluriel compris ;
/// - les chaînes sans mot traduisible (`4,6`, `800 m`, `#0B3B66`) ;
/// - les valeurs listées dans [data] — un nom de courtier, un titre de bien :
///   ce sont des données d'exécution que personne ne traduira jamais.
///
/// Tout le reste est une chaîne en dur : une phrase qu'aucun traducteur ne
/// verra et que la synthèse vocale lira dans la mauvaise langue.
List<String> findHardcodedText(
  WidgetTester tester, {
  Set<String> data = const <String>{},
}) {
  final List<RegExp> patterns = loadL10nPatterns();
  final List<String> offenders = <String>[];

  for (final Element element in find.byType(Text).evaluate()) {
    final Text widget = element.widget as Text;
    final String? value = widget.data;
    if (value == null || value.trim().isEmpty) {
      continue;
    }
    if (data.contains(value) || _isDataNotCopy(value)) {
      continue;
    }
    if (patterns.any((RegExp p) => p.hasMatch(value))) {
      continue;
    }
    offenders.add(value);
  }

  return offenders;
}

/// Vrai quand la chaîne ne contient aucun mot traduisible : chiffres, unités,
/// ponctuation, codes hexadécimaux.
bool _isDataNotCopy(String value) {
  return !RegExp(r'\p{L}{3,}', unicode: true).hasMatch(value);
}

/// Échoue en nommant chaque chaîne fautive.
void expectNoHardcodedText(
  WidgetTester tester, {
  Set<String> data = const <String>{},
}) {
  final List<String> offenders = findHardcodedText(tester, data: data);
  expect(
    offenders,
    isEmpty,
    reason:
        'Chaînes visibles absentes de app_fr.arb : $offenders. '
        'Tout texte lisible passe par context.l10n, ou est déclaré comme '
        'donnée d\'exécution via le paramètre `data`.',
  );
}
