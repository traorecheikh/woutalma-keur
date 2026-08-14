import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:woutalma_api_client/woutalma_api_client.dart' as api;

enum WarmupState { idle, warming, warm, unreachable }

/// Réveille l'instance gratuite pendant que l'application se peint.
///
/// Le service web s'endort après quinze minutes d'inactivité et met une
/// cinquantaine de secondes à revenir. [start] rend la main **immédiatement**
/// et n'est jamais attendu avant `runApp` : bloquer le premier rendu pendant
/// une minute serait pire que le démarrage à froid lui-même.
///
/// Vise `/readyz`, pas `/healthz`. La base gratuite ne dort pas — seul le
/// service web dort — donc l'intérêt de l'aller-retour n'est pas de la
/// réveiller mais de forcer le pool Prisma à finir sa poignée de main, pour
/// que la première vraie requête ne paie pas l'ouverture de connexion
/// par-dessus le démarrage à froid.
class BackendWarmup extends ChangeNotifier {
  BackendWarmup({required api.HealthApi health, int maxAttempts = 6})
    : _health = health,
      _maxAttempts = maxAttempts;

  static const List<Duration> _backoff = <Duration>[
    Duration(seconds: 1),
    Duration(seconds: 2),
    Duration(seconds: 4),
    Duration(seconds: 8),
    Duration(seconds: 8),
    Duration(seconds: 8),
  ];

  final api.HealthApi _health;
  final int _maxAttempts;

  WarmupState _state = WarmupState.idle;
  WarmupState get state => _state;

  Future<void>? _running;

  /// Démarre la séquence. Synchrone par contrat.
  void start() {
    if (_state == WarmupState.warm || _running != null) {
      return;
    }
    _set(WarmupState.warming);
    _running = _loop().whenComplete(() => _running = null);
  }

  Future<void> _loop() async {
    for (var attempt = 0; attempt < _maxAttempts; attempt++) {
      try {
        await _health.healthControllerReadiness(
          // Délai court par tentative : mieux vaut réessayer que rester
          // suspendu soixante secondes sur un socket mort.
          extra: const <String, dynamic>{},
          validateStatus: (int? status) => status != null && status < 500,
        );
        _set(WarmupState.warm);
        return;
      } on DioException {
        // Pendant un démarrage à froid, la bordure de Render répond 502/503
        // avant que le processus n'écoute. Ce n'est pas un échec, c'est
        // « pas encore ».
      } catch (_) {
        // Idem pour une réponse mal formée servie par la page d'attente.
      }
      if (attempt + 1 < _maxAttempts) {
        await Future<void>.delayed(
          _backoff[attempt.clamp(0, _backoff.length - 1)],
        );
      }
    }
    _set(WarmupState.unreachable);
  }

  void _set(WarmupState next) {
    if (_state == next) {
      return;
    }
    _state = next;
    notifyListeners();
  }
}
