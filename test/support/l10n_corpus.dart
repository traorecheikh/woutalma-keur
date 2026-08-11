import 'dart:convert';
import 'dart:io';

/// Motifs de tous les textes traduisibles de l'ARB modèle.
///
/// Lu depuis le fichier plutôt que depuis la classe générée : c'est l'ARB qui
/// fait foi, et une clé oubliée à la génération doit faire échouer le test,
/// pas passer inaperçue.
///
/// Chaque valeur devient une expression régulière, pour deux raisons :
/// - un placeholder `{price}` accepte n'importe quelle donnée à l'exécution ;
/// - un pluriel ICU produit **plusieurs** textes possibles, et la valeur
///   stockée dans l'ARB n'est aucun d'entre eux.
List<RegExp> loadL10nPatterns() {
  final File arb = File('lib/app/l10n/app_fr.arb');
  if (!arb.existsSync()) {
    throw StateError(
      'ARB modèle introuvable à ${arb.path}. '
      'Le garde-fou de texte en dur ne peut pas fonctionner sans lui.',
    );
  }

  final Map<String, dynamic> json =
      jsonDecode(arb.readAsStringSync()) as Map<String, dynamic>;

  final List<RegExp> patterns = <RegExp>[];
  for (final MapEntry<String, dynamic> entry in json.entries) {
    // `@@locale` et les blocs `@maClef` sont des métadonnées.
    if (entry.key.startsWith('@') || entry.value is! String) {
      continue;
    }
    for (final String variant in _expandIcu(entry.value as String)) {
      patterns.add(_toPattern(variant));
    }
  }
  return patterns;
}

/// Développe un pluriel ou un choix ICU en ses textes possibles.
///
/// `{count, plural, =0{Aucun avis} =1{1 avis} other{{count} avis}}` produit
/// les trois branches ; une valeur sans ICU se rend telle quelle.
List<String> _expandIcu(String value) {
  final int marker = value.indexOf(', plural,');
  if (marker < 0) {
    return <String>[value];
  }

  final List<String> branches = <String>[];
  int index = value.indexOf('{', marker);
  while (index >= 0 && index < value.length) {
    final int end = _matchingBrace(value, index);
    if (end < 0) {
      break;
    }
    branches.add(value.substring(index + 1, end));
    index = value.indexOf('{', end + 1);
  }
  return branches.isEmpty ? <String>[value] : branches;
}

/// Position de l'accolade fermante correspondant à celle en [open].
int _matchingBrace(String value, int open) {
  int depth = 0;
  for (int i = open; i < value.length; i++) {
    if (value[i] == '{') {
      depth++;
    } else if (value[i] == '}') {
      depth--;
      if (depth == 0) {
        return i;
      }
    }
  }
  return -1;
}

/// Transforme un texte ARB en motif : les placeholders acceptent n'importe
/// quelle donnée.
RegExp _toPattern(String value) {
  final StringBuffer buffer = StringBuffer('^');
  int i = 0;
  while (i < value.length) {
    if (value[i] == '{') {
      final int end = _matchingBrace(value, i);
      if (end > 0) {
        buffer.write('.+');
        i = end + 1;
        continue;
      }
    }
    buffer.write(RegExp.escape(value[i]));
    i++;
  }
  buffer.write(r'$');
  return RegExp(buffer.toString());
}
