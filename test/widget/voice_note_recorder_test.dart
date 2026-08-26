import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_keur/app/ui/voice_note.dart';

import '../support/fake_voice_note_recorder.dart';
import '../support/pump.dart';

void main() {
  testWidgets('s\'arrête seul à 60 s et rend le fichier', (tester) async {
    final FakeVoiceNoteRecorder recorder = FakeVoiceNoteRecorder();
    final List<String?> changes = <String?>[];
    String? asset;
    await pumpWk(
      tester,
      StatefulBuilder(
        builder: (context, setState) => AppVoiceNoteRecorder(
          asset: asset,
          recorder: recorder,
          onChanged: (value) {
            changes.add(value);
            setState(() => asset = value);
          },
        ),
      ),
    );

    await tester.tap(find.text('Enregistrer un message vocal'));
    await tester.pump();
    expect(recorder.starts, 1);
    expect(find.text('Arrêter'), findsOneWidget);

    await tester.pump(const Duration(seconds: 50));
    expect(find.text('Fin dans 10 s'), findsOneWidget);
    expect(recorder.stops, 0);

    await tester.pump(const Duration(seconds: 10));
    await tester.pump();
    expect(recorder.stops, 1);
    expect(changes, <String?>['/tmp/voice.m4a']);
    await tester.pumpAndSettle();
    expect(find.text('Message vocal prêt'), findsOneWidget);
    expect(find.text('Réenregistrer'), findsOneWidget);
  });

  testWidgets('les deux actions tiennent à ×1.3 sans déborder', (tester) async {
    await pumpWk(
      tester,
      AppVoiceNoteRecorder(
        asset: '/tmp/voice.m4a',
        recorder: FakeVoiceNoteRecorder(),
        onChanged: (_) {},
      ),
      textScale: 1.3,
      surfaceSize: const Size(320, 700),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Supprimer le vocal'), findsOneWidget);
  });
}
