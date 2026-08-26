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
  BackendWarmup({required api.HealthApi health, int? maxAttempts})
    : _health = health,
      _maxAttempts = maxAttempts ?? backoff.length + 1;

  /// Mode local : il n'y a pas de serveur à réveiller.
  ///
  /// Une instance inerte plutôt qu'un `BackendWarmup?` : `Provider` refuse
  /// d'exposer un sous-type de `Listenable` (il ne saurait pas se réabonner),
  /// et un `ChangeNotifierProvider` d'un type nullable n'existe pas. Un objet
  /// qui reste `idle` dit la même chose sans compliquer chaque lecteur.
  BackendWarmup.disabled() : _health = null, _maxAttempts = 0;

  /// Couvre les cinquante secondes d'un démarrage à froid, avec de la marge :
  /// la série précédente s'arrêtait au bout de vingt-trois secondes et
  /// déclarait le serveur injoignable alors qu'il était en train de se lever.
  @visibleForTesting
  static const List<Duration> backoff = <Duration>[
    Duration(seconds: 1),
    Duration(seconds: 2),
    Duration(seconds: 4),
    Duration(seconds: 8),
    Duration(seconds: 10),
    Duration(seconds: 10),
    Duration(seconds: 15),
    Duration(seconds: 15),
    Duration(seconds: 15),
    Duration(seconds: 15),
  ];

  /// Total des attentes, hors durée des requêtes elles-mêmes.
  static Duration get backoffTotal =>
      backoff.fold(Duration.zero, (Duration sum, Duration d) => sum + d);

  /// Chaque tentative est courte : rester suspendu soixante secondes sur un
  /// socket mort revenait à ne réessayer jamais.
  static const Duration attemptTimeout = Duration(seconds: 8);

  final api.HealthApi? _health;
  final int _maxAttempts;

  WarmupState _state = WarmupState.idle;
  WarmupState get state => _state;

  Future<void>? _running;

  /// Démarre la séquence, ou la relance après un échec. Synchrone par
  /// contrat : un appelant qui vient de se prendre une coupure ne doit pas
  /// attendre le réveil pour continuer.
  void start() {
    if (_health == null || _state == WarmupState.warm || _running != null) {
      return;
    }
    _set(WarmupState.warming);
    _running = _loop().whenComplete(() => _running = null);
  }

  /// Après une coupure : l'instance déclarée réveillée a pu se rendormir, et
  /// [start] seul n'y serait jamais revenu.
  void retry() {
    if (_running != null) {
      return;
    }
    _state = WarmupState.idle;
    start();
  }

  Future<void> _loop() async {
    for (var attempt = 0; attempt < _maxAttempts; attempt++) {
      final CancelToken token = CancelToken();
      try {
        await _health!
            .healthControllerReadiness(
              cancelToken: token,
              validateStatus: (int? status) => status != null && status < 500,
            )
            // Les délais du client généré valent vingt et soixante secondes :
            // ils ne se règlent pas par requête, alors on rend la main
            // nous-mêmes et on ferme la socket abandonnée.
            .timeout(
              attemptTimeout,
              onTimeout: () => throw TimeoutException(null),
            );
        _set(WarmupState.warm);
        return;
      } on Object {
        // Pendant un démarrage à froid, la bordure de Render répond 502/503
        // avant que le processus n'écoute, ou ne répond pas du tout. Ce n'est
        // pas un échec, c'est « pas encore ».
        token.cancel();
      }
      if (attempt + 1 < _maxAttempts) {
        await Future<void>.delayed(
          backoff[attempt.clamp(0, backoff.length - 1)],
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
