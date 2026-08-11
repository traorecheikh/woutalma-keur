import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/core/feedback/interaction_feedback.dart';
import 'package:woutalma_keur/app/l10n/generated/app_l10n.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';
import 'package:woutalma_keur/main.dart';

import 'recording_feedback_service.dart';

/// Monte un widget dans le même environnement que l'application : thème,
/// localisation et service de feedback enregistreur.
///
/// Chaque test peut ainsi vérifier le rendu **et** ce que l'app a répondu.
Future<RecordingFeedbackService> pumpWk(
  WidgetTester tester,
  Widget child, {
  RecordingFeedbackService? feedback,
  ThemeData? theme,
  double textScale = 1,
  Size surfaceSize = const Size(360, 800),
}) async {
  final RecordingFeedbackService service =
      feedback ?? RecordingFeedbackService();

  await tester.binding.setSurfaceSize(surfaceSize);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    Provider<InteractionFeedbackService>.value(
      value: service,
      child: MaterialApp(
        theme: theme ?? WkTheme.light(),
        // La même liste que l'application : un harnais qui localise
        // différemment ne peut pas voir un paquet resté en anglais.
        localizationsDelegates: wkLocalizationsDelegates,
        supportedLocales: AppL10n.supportedLocales,
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: Material(child: child),
        ),
      ),
    ),
  );

  return service;
}

/// Échoue si un texte rendu est coupé par un « … ».
///
/// Un libellé tronqué — « Modifie… », « Change… » — ne veut plus rien dire,
/// et encore moins pour quelqu'un qui déchiffre déjà difficilement. Le test
/// lit l'état réel de la mise en page, pas la chaîne source : `find.text`
/// trouve le libellé entier même quand l'écran n'en montre que la moitié.
/// [userContent] énumère les textes écrits par un utilisateur — titre de bien,
/// commentaire d'avis — dont la troncature est un choix de densité assumé, le
/// texte entier restant à un geste. Tout le reste est de la copie d'interface :
/// elle ne se coupe jamais.
void expectNoClippedText(
  WidgetTester tester, {
  Set<String> userContent = const <String>{},
}) {
  for (final Element element in find.byType(Text).evaluate()) {
    final RenderObject? object = element.renderObject;
    if (object is! RenderParagraph || !object.didExceedMaxLines) {
      continue;
    }
    final String text = (element.widget as Text).data ?? '';
    if (userContent.contains(text)) {
      continue;
    }
    fail('Texte coupé à l\'écran : « $text »');
  }
}

/// Échoue si une cible tactile rendue descend sous le plancher.
///
/// `docs/WOUTALMA-UI.md` §1 : 56 dp est un plancher absolu, y compris pour une
/// icône seule.
void expectTouchTargets(WidgetTester tester, {double minimum = 56}) {
  for (final Element element in find.byType(InkWell).evaluate()) {
    final Size size = element.size ?? Size.zero;
    expect(
      size.height,
      greaterThanOrEqualTo(minimum),
      reason: 'Cible tactile de ${size.height}dp, plancher $minimum dp.',
    );
  }
}
