import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_keur/app/data/services/property_photo_uploader.dart';
import 'package:woutalma_keur/app/domain/voice_note_service.dart';
import 'package:woutalma_keur/app/modules/broker/property_editor_view_model.dart';
import 'package:woutalma_keur/app/data/repositories/in_memory_repositories.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/location_service.dart';

Uint8List m4a([int size = 64]) {
  final Uint8List bytes = Uint8List(size);
  bytes.setRange(4, 8, 'ftyp'.codeUnits);
  return bytes;
}

void main() {
  group('PropertyVoiceNoteUploader', () {
    test('un fichier local devient un envoi base64 audio/mp4', () async {
      final PropertyVoiceNoteUploader uploader = PropertyVoiceNoteUploader(
        readBytes: (_) async => m4a(),
      );

      final PreparedVoiceNote prepared = await uploader.prepare('/tmp/v.m4a');

      expect(prepared.upload?.mimeType, 'audio/mp4');
      expect(base64Decode(prepared.upload!.dataBase64), m4a());
      expect(prepared.clear, isFalse);
    });

    test('une clé api: repart telle quelle', () async {
      final PropertyVoiceNoteUploader uploader = PropertyVoiceNoteUploader(
        readBytes: (_) async => throw StateError('jamais lu'),
      );

      final PreparedVoiceNote prepared = await uploader.prepare('api:v1');

      expect(prepared.retained, 'api:v1');
      expect(prepared.upload, isNull);
    });

    test('null après un vocal connu du serveur demande son retrait', () async {
      const PropertyVoiceNoteUploader uploader = PropertyVoiceNoteUploader();

      expect((await uploader.prepare(null, previous: 'api:v1')).clear, isTrue);
      expect(await uploader.prepare(null), same(PreparedVoiceNote.none));
    });

    test('trop lourd ou inconnu est refusé avant l\'envoi', () async {
      final PropertyVoiceNoteUploader heavy = PropertyVoiceNoteUploader(
        constraints: const VoiceNoteConstraints(maxUploadBytes: 16),
        readBytes: (_) async => m4a(),
      );
      final PropertyVoiceNoteUploader unknown = PropertyVoiceNoteUploader(
        readBytes: (_) async => Uint8List(32),
      );

      await expectLater(
        heavy.prepare('/tmp/v.m4a'),
        throwsA(
          isA<VoiceNoteUploadFailed>().having(
            (VoiceNoteUploadFailed e) => e.refusal,
            'refusal',
            VoiceNoteUploadRefusal.tooLarge,
          ),
        ),
      );
      await expectLater(
        unknown.prepare('/tmp/v.bin'),
        throwsA(isA<VoiceNoteUploadFailed>()),
      );
    });
  });

  test('l\'éditeur enregistre le vocal avec le bien', () async {
    final InMemoryStore store = InMemoryStore();
    final InMemoryPropertyRepository properties = InMemoryPropertyRepository(
      store,
    );
    final PropertyEditorViewModel model = PropertyEditorViewModel(
      properties: properties,
      brokerId: 'brk-test',
      fallbackPosition: const GeoPoint(14.6, -17.4),
      now: () => DateTime(2026, 8, 25),
    )..setNeighbourhood(dakarNeighbourhoods.first);
    model.setVoiceNote('/tmp/v.m4a');

    final String? id = await model.save(title: 'Studio', priceText: '50000');

    expect(id, isNotNull);
    expect((await properties.byId(id!))?.voiceAsset, '/tmp/v.m4a');
  });
}
