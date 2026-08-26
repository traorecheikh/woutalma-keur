import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:woutalma_keur/app/domain/voice_note_service.dart';

/// Enregistreur réel, sur le paquet `record`.
///
/// AAC mono à 32 kbit/s : 60 secondes pèsent environ 240 Ko, sous la limite
/// du serveur, et la voix reste nette — c'est le réglage des messages vocaux
/// WhatsApp, que la cible connaît.
class RecordVoiceNoteRecorder implements VoiceNoteRecorder {
  RecordVoiceNoteRecorder();

  final AudioRecorder _recorder = AudioRecorder();
  String? _path;

  @override
  Future<bool> requestPermission() => _recorder.hasPermission();

  /// Le vocal atterrit dans le dossier documents, pas dans le temporaire : le
  /// système vide celui-ci quand la place manque, et l'enregistrement d'un
  /// bien pas encore publié disparaissait avec.
  @override
  Future<void> start() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    _path = '${dir.path}/wk-voice-${DateTime.now().microsecondsSinceEpoch}.m4a';
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 32000,
        sampleRate: 22050,
        numChannels: 1,
      ),
      path: _path!,
    );
  }

  @override
  Future<String?> stop() async {
    final String? path = await _recorder.stop();
    _path = null;
    if (path == null) {
      return null;
    }
    final File file = File(path);
    if (!await file.exists() || await file.length() == 0) {
      return null;
    }
    return path;
  }

  @override
  Future<void> cancel() async {
    await _recorder.cancel();
    _path = null;
  }

  /// `current` est en dBFS : -160 dans le silence, 0 à saturation. La voix
  /// parlée vit entre -50 et 0, d'où la fenêtre.
  @override
  Stream<double> levels() => _recorder
      .onAmplitudeChanged(const Duration(milliseconds: 50))
      .map((Amplitude a) => ((a.current + 50) / 50).clamp(0.0, 1.0));

  @override
  Future<void> dispose() => _recorder.dispose();
}
