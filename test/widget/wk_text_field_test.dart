import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_keur/app/core/feedback/interaction_feedback.dart';
import 'package:woutalma_keur/app/shared/theme/wk_motion.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_text_field.dart';

import '../support/pump.dart';
import '../support/recording_feedback_service.dart';

/// Neuf chiffres après l'indicatif, comme au Sénégal.
String? phoneValidator(String value) {
  final String digits = value.replaceAll(RegExp(r'\D'), '');
  if (digits.length == 9) {
    return null;
  }
  final int missing = 9 - digits.length;
  return missing > 0 ? 'Il manque $missing chiffres' : 'Chiffres en trop';
}

void main() {
  late TextEditingController controller;

  setUp(() => controller = TextEditingController());
  tearDown(() => controller.dispose());

  Future<RecordingFeedbackService> pumpField(
    WidgetTester tester, {
    bool Function(String)? readyToEvaluate,
  }) {
    return pumpWk(
      tester,
      Padding(
        padding: const EdgeInsets.all(16),
        child: WkTextField(
          label: 'Téléphone',
          controller: controller,
          validator: phoneValidator,
          readyToEvaluate: readyToEvaluate,
        ),
      ),
    );
  }

  testWidgets('rien n\'est déclaré faux pendant qu\'on tape', (
    WidgetTester tester,
  ) async {
    final RecordingFeedbackService feedback = await pumpField(tester);

    await tester.enterText(find.byType(TextField), '77');
    await tester.pump(const Duration(milliseconds: 200));

    // Anti-rebond non écoulé : la valeur est incomplète, pas fausse.
    expect(find.text('Il manque 7 chiffres'), findsNothing);
    expect(feedback.countOf(FeedbackIntent.error), 0);
  });

  testWidgets('la coche apparaît dès la fin de l\'anti-rebond, sans '
      'seconde attente', (WidgetTester tester) async {
    await pumpField(tester);

    await tester.enterText(find.byType(TextField), '771234567');
    await tester.pump(WkMotion.validationDebounce);
    await tester.pump();

    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('une erreur n\'émet qu\'une fois, même en continuant à taper', (
    WidgetTester tester,
  ) async {
    final RecordingFeedbackService feedback = await pumpField(tester);

    await tester.enterText(find.byType(TextField), '7712');
    await tester.pump(WkMotion.validationDebounce);
    await tester.pump();
    expect(feedback.countOf(FeedbackIntent.error), 1);

    // Toujours invalide : on revalide à chaque frappe pour montrer le
    // progrès, mais on ne re-vibre pas.
    await tester.enterText(find.byType(TextField), '77123');
    await tester.pump();
    await tester.enterText(find.byType(TextField), '771234');
    await tester.pump();

    expect(feedback.countOf(FeedbackIntent.error), 1);
  });

  testWidgets('une fois en erreur, la correction se voit immédiatement', (
    WidgetTester tester,
  ) async {
    await pumpField(tester);

    await tester.enterText(find.byType(TextField), '7712');
    await tester.pump(WkMotion.validationDebounce);
    await tester.pump();
    expect(find.byIcon(Icons.error_outline), findsOneWidget);

    // Pas de nouvel anti-rebond : la récompense est instantanée.
    await tester.enterText(find.byType(TextField), '771234567');
    await tester.pump();

    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsNothing);
  });

  testWidgets('le message dit quoi faire, pas que c\'est invalide', (
    WidgetTester tester,
  ) async {
    await pumpField(tester);

    await tester.enterText(find.byType(TextField), '7712345');
    await tester.pump(WkMotion.validationDebounce);
    await tester.pump();

    expect(find.text('Il manque 2 chiffres'), findsOneWidget);
  });

  testWidgets('la hauteur ne bouge pas quand le message apparaît', (
    WidgetTester tester,
  ) async {
    await pumpField(tester);
    final double idle = tester.getSize(find.byType(WkTextField)).height;

    await tester.enterText(find.byType(TextField), '7712');
    await tester.pump(WkMotion.validationDebounce);
    await tester.pump();
    final double errored = tester.getSize(find.byType(WkTextField)).height;

    expect(
      errored,
      idle,
      reason: 'le champ saute quand l\'erreur apparaît, sous le doigt',
    );
  });

  testWidgets('un champ non prêt à être jugé attend la perte de focus', (
    WidgetTester tester,
  ) async {
    // Un titre libre ne peut jamais « devenir valide » tout seul.
    await pumpField(tester, readyToEvaluate: (String _) => false);

    await tester.enterText(find.byType(TextField), '77');
    await tester.pump(WkMotion.validationDebounce);
    await tester.pump();

    expect(find.byIcon(Icons.error_outline), findsNothing);
  });
}
