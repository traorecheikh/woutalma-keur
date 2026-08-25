import 'package:flutter/foundation.dart';

/// Enregistre le message vocal d'un bien.
///
/// Abstrait pour que l'éditeur se teste sans micro ; l'implémentation réelle
/// vit dans `data/services/record_voice_note_recorder.dart`.
abstract class VoiceNoteRecorder {
  /// Demande le micro si besoin. Faux quand il est refusé.
  Future<bool> requestPermission();

  /// Démarre un enregistrement dans un fichier temporaire.
  Future<void> start();

  /// Arrête et rend le chemin du fichier, ou `null` si rien n'a été capté.
  Future<String?> stop();

  /// Abandonne l'enregistrement en cours et supprime le fichier.
  Future<void> cancel();

  Future<void> dispose();
}

/// Bornes partagées par l'enregistreur, l'envoi et le serveur
/// (`MAX_VOICE_NOTE_BYTES`, `ALLOWED_VOICE_NOTE_MIME_TYPES`).
@immutable
class VoiceNoteConstraints {
  const VoiceNoteConstraints({
    this.maxDuration = const Duration(seconds: 45),
    this.maxUploadBytes = 512 * 1024,
  });

  /// Assez pour décrire un bien, pas assez pour coûter de la data.
  final Duration maxDuration;

  final int maxUploadBytes;

  static const Set<String> allowedMimeTypes = <String>{
    'audio/mp4',
    'audio/aac',
    'audio/mpeg',
    'audio/ogg',
    'audio/webm',
  };
}
