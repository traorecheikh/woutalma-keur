import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_keur/app/domain/photo_service.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_photo_picker.dart';

import '../support/pump.dart';

class _NoPhotoService implements PhotoService {
  @override
  int get maxPerProperty => 6;

  @override
  Future<String?> pick(PhotoSource source) async => null;
}

void main() {
  testWidgets('le sélecteur photo vide présente une grande cible', (
    WidgetTester tester,
  ) async {
    await pumpWk(
      tester,
      WkPhotoPicker(
        paths: const <String>[],
        service: _NoPhotoService(),
        onChanged: (_) {},
      ),
      surfaceSize: const Size(360, 280),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(WkPhotoPicker),
      matchesGoldenFile('goldens/wk_photo_picker_empty.png'),
    );
  });
}
