import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_keur/app/core/feedback/interaction_feedback.dart';
import 'package:woutalma_keur/app/shared/theme/wk_spacing.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_button.dart';

import '../support/pump.dart';
import '../support/recording_feedback_service.dart';

void main() {
  testWidgets('un appui déclenche l\'action et un retour sensoriel', (
    WidgetTester tester,
  ) async {
    var taps = 0;
    final RecordingFeedbackService feedback = await pumpWk(
      tester,
      WkButton(label: 'Appeler', onPressed: () => taps++),
    );

    await tester.tap(find.byType(WkButton));
    await tester.pump();

    expect(taps, 1);
    expect(feedback.countOf(FeedbackIntent.selection), 1);
  });

  testWidgets('l\'action primaire atteint la hauteur confortable', (
    WidgetTester tester,
  ) async {
    await pumpWk(tester, WkButton(label: 'Chercher', onPressed: () {}));

    final Size size = tester.getSize(find.byType(WkButton));
    expect(size.height, greaterThanOrEqualTo(WkTouch.comfy));
  });

  testWidgets('un bouton secondaire respecte le plancher tactile', (
    WidgetTester tester,
  ) async {
    await pumpWk(
      tester,
      WkButton(
        label: 'Plus tard',
        onPressed: () {},
        variant: WkButtonVariant.secondary,
      ),
    );

    final Size size = tester.getSize(find.byType(WkButton));
    expect(size.height, greaterThanOrEqualTo(WkTouch.min));
  });

  testWidgets('le chargement ne change pas la largeur et refuse les appuis', (
    WidgetTester tester,
  ) async {
    var taps = 0;

    await pumpWk(
      tester,
      Center(
        child: WkButton(
          label: 'Publier le bien',
          onPressed: () => taps++,
          expand: false,
        ),
      ),
    );
    final double idleWidth = tester.getSize(find.byType(WkButton)).width;

    await pumpWk(
      tester,
      Center(
        child: WkButton(
          label: 'Publier le bien',
          onPressed: () => taps++,
          loading: true,
          expand: false,
        ),
      ),
    );
    final double loadingWidth = tester.getSize(find.byType(WkButton)).width;

    await tester.tap(find.byType(WkButton));
    await tester.pump();

    expect(loadingWidth, idleWidth, reason: 'le bouton saute pendant l\'envoi');
    expect(taps, 0, reason: 'une double soumission est possible');
  });

  testWidgets('un bouton désactivé annonce son motif', (
    WidgetTester tester,
  ) async {
    await pumpWk(
      tester,
      const WkButton(
        label: 'Envoyer l\'avis',
        onPressed: null,
        disabledReason: 'Choisissez d\'abord une note',
      ),
    );

    final SemanticsNode node = tester.getSemantics(find.byType(WkButton));
    expect(node.hint, 'Choisissez d\'abord une note');
  });

  testWidgets('à ×1.3 le libellé ne déborde pas', (WidgetTester tester) async {
    await pumpWk(
      tester,
      WkButton(label: 'Ajouter un bien', onPressed: () {}),
      textScale: 1.3,
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('appel et WhatsApp gardent leur couleur propre', (
    WidgetTester tester,
  ) async {
    await pumpWk(
      tester,
      Column(
        children: <Widget>[
          WkButton(
            label: 'Appeler',
            onPressed: () {},
            variant: WkButtonVariant.call,
          ),
          WkButton(
            label: 'WhatsApp',
            onPressed: () {},
            variant: WkButtonVariant.whatsapp,
          ),
        ],
      ),
    );

    final Iterable<Material> materials = tester
        .widgetList<Material>(find.byType(Material))
        .where((Material m) => m.color != null);
    final Set<Color?> colors = materials.map((Material m) => m.color).toSet();

    expect(colors, contains(const Color(0xFF0F7B3F)));
    expect(colors, contains(const Color(0xFF25D366)));
  });
}
