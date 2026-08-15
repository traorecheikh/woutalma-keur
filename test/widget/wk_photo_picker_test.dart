import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_keur/app/core/feedback/interaction_feedback.dart';
import 'package:woutalma_keur/app/domain/photo_service.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_button.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_photo_picker.dart';

import '../support/pump.dart';
import '../support/recording_feedback_service.dart';

/// Renvoie toujours le même chemin, sans toucher à l'appareil photo.
class _StubPhotoService implements PhotoService {
  _StubPhotoService({this.result = '/tmp/photo.jpg', this.max = 3});

  final String? result;
  final int max;
  int calls = 0;

  @override
  int get maxPerProperty => max;

  @override
  Future<String?> pick(PhotoSource source) async {
    calls++;
    return result;
  }
}

void main() {
  Future<(List<String>, RecordingFeedbackService)> pumpPicker(
    WidgetTester tester, {
    required PhotoService service,
    List<String> initial = const <String>[],
  }) async {
    List<String> current = initial;
    final RecordingFeedbackService feedback = await pumpWk(
      tester,
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => WkPhotoPicker(
          paths: current,
          service: service,
          onChanged: (List<String> value) => setState(() => current = value),
        ),
      ),
    );
    return (current, feedback);
  }

  testWidgets('le compteur dit combien de photos restent', (
    WidgetTester tester,
  ) async {
    await pumpPicker(
      tester,
      service: _StubPhotoService(),
      initial: const <String>['/tmp/a.jpg'],
    );

    expect(find.text('1 sur 3'), findsOneWidget);
  });

  testWidgets('la compression est annoncée, pas subie en silence', (
    WidgetTester tester,
  ) async {
    await pumpPicker(tester, service: _StubPhotoService());

    // Le courtier paie sa data : il a le droit de savoir qu'on l'économise.
    expect(
      find.text('Les photos sont allégées pour économiser vos données.'),
      findsOneWidget,
    );
  });

  testWidgets('sans photo, un grand emplacement invite à en ajouter une', (
    WidgetTester tester,
  ) async {
    await pumpPicker(tester, service: _StubPhotoService());

    final Finder addPhoto = find.text('Ajouter une photo');
    expect(addPhoto, findsOneWidget);
    expectTouchTargets(tester);
  });

  testWidgets('atteindre la limite désactive l\'ajout, avec son motif', (
    WidgetTester tester,
  ) async {
    await pumpPicker(
      tester,
      service: _StubPhotoService(max: 2),
      initial: const <String>['/tmp/a.jpg', '/tmp/b.jpg'],
    );

    final SemanticsNode node = tester.getSemantics(find.byType(WkButton));
    // Le motif est exposé au lecteur d'écran : un bouton désactivé sans
    // raison est un bouton cassé pour qui ne lit pas bien.
    expect(node.hint, '2 photos maximum');
  });

  testWidgets('un échec de sélection ne perd pas les photos déjà là', (
    WidgetTester tester,
  ) async {
    final _StubPhotoService service = _StubPhotoService(result: null);
    final (
      List<String> _,
      RecordingFeedbackService feedback,
    ) = await pumpPicker(
      tester,
      service: service,
      initial: const <String>['/tmp/a.jpg'],
    );

    await tester.tap(find.text('Ajouter une photo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choisir dans mes images'));
    await tester.pumpAndSettle();

    expect(service.calls, 1);
    expect(feedback.countOf(FeedbackIntent.error), 1);
    // La photo existante est toujours affichée.
    expect(find.text('1 sur 3'), findsOneWidget);
  });

  testWidgets('la croix de suppression atteint le plancher tactile', (
    WidgetTester tester,
  ) async {
    // Vue sur l'appareil : une pastille de 32 dp. On la rate au doigt, et la
    // rater ici veut dire supprimer la mauvaise photo au deuxième essai.
    await pumpPicker(
      tester,
      service: _StubPhotoService(),
      initial: const <String>['/tmp/a.jpg'],
    );

    final Finder remove = find.byWidgetPredicate(
      (Widget w) =>
          w is Semantics && w.properties.label == 'Retirer cette photo',
    );
    expect(tester.getSize(remove).height, greaterThanOrEqualTo(56));
    expect(tester.getSize(remove).width, greaterThanOrEqualTo(56));
  });

  test('les contraintes restent raisonnables pour un réseau lent', () {
    const PhotoConstraints constraints = PhotoConstraints();

    // 1280 px suffit à juger un logement sur un téléphone ; au-delà on paie
    // de la data pour des pixels que personne ne regarde.
    expect(constraints.maxWidth, lessThanOrEqualTo(1600));
    expect(constraints.quality, inInclusiveRange(60, 85));
    // Le serveur en refuse une quatrième (`MAX_PHOTOS_PER_PROPERTY = 3`) :
    // le sélecteur doit compter comme lui, sinon on fait prendre des photos
    // qui seront refusées à la publication.
    expect(constraints.maxPerProperty, 3);
  });
}
