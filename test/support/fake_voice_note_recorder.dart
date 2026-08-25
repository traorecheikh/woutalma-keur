import 'package:woutalma_keur/app/domain/voice_note_service.dart';

/// Enregistreur sans micro : rend un chemin fixe, ou refuse la permission.
class FakeVoiceNoteRecorder implements VoiceNoteRecorder {
  FakeVoiceNoteRecorder({this.granted = true, this.path = '/tmp/voice.m4a'});

  final bool granted;
  final String? path;
  int starts = 0;
  int stops = 0;

  @override
  Future<bool> requestPermission() async => granted;

  @override
  Future<void> start() async => starts++;

  @override
  Future<String?> stop() async {
    stops++;
    return path;
  }

  @override
  Future<void> cancel() async {}

  @override
  Future<void> dispose() async {}
}
