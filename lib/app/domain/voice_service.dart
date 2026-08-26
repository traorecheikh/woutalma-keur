import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Lecture à voix haute d'un texte déjà affiché.
///
/// Le produit s'adresse à des personnes qui ne lisent pas couramment : un
/// écran qui ne peut pas se faire lire leur est fermé. Abstrait pour que les
/// tests n'ouvrent pas de canal de plateforme.
abstract class VoiceService {
  Future<void> speak(String text);
  Future<void> stop();
}

/// Synthèse du téléphone, en français.
class TtsVoiceService implements VoiceService {
  TtsVoiceService({FlutterTts? tts}) : _tts = tts ?? FlutterTts();

  final FlutterTts _tts;
  bool _configured = false;

  @override
  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    try {
      if (!_configured) {
        await _tts.setLanguage('fr-FR');
        _configured = true;
      }
      await _tts.stop();
      await _tts.speak(text);
    } on Object catch (e) {
      // Moteur absent ou langue non installée : l'écran reste lisible, il ne
      // se lit simplement pas.
      debugPrint('[wk] lecture à voix haute impossible : $e');
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _tts.stop();
    } on Object catch (e) {
      debugPrint('[wk] arrêt de la lecture impossible : $e');
    }
  }
}
