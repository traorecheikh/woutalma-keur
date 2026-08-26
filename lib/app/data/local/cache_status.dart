import 'package:flutter/foundation.dart';

/// Dit à l'interface si ce qu'elle affiche vient du serveur ou de la dernière
/// copie reçue.
///
/// Un seul objet pour toute l'application : la question « suis-je à jour ? »
/// n'est pas propre à un écran, et deux bandeaux qui se contredisent seraient
/// pires qu'aucun.
class CacheStatus extends ChangeNotifier {
  CacheStatus({Future<void> Function(DateTime at)? persist})
    : _persist = persist;

  /// Écrit la date du dernier succès pour le prochain lancement. Sans elle,
  /// le bandeau hors ligne annonçait « enregistrées à l'instant » après chaque
  /// redémarrage, alors que la copie pouvait dater de la semaine passée.
  final Future<void> Function(DateTime at)? _persist;

  /// Assez espacé pour ne pas écrire sur le disque à chaque requête, assez
  /// serré pour que la date relue reste juste à la minute.
  static const Duration _persistEvery = Duration(minutes: 1);

  bool _servedFromCache = false;
  DateTime? _fetchedAt;
  DateTime? _persistedAt;
  bool _localCacheUnavailable = false;

  /// Vrai dès qu'une lecture a dû se rabattre sur la copie locale.
  bool get servedFromCache => _servedFromCache;

  /// Quand la copie affichée a été reçue du serveur. `null` si on n'a jamais
  /// réussi une lecture — le bandeau dit alors « date inconnue », pas « à
  /// l'instant ».
  DateTime? get fetchedAt => _fetchedAt;

  /// La base locale n'a pas pu s'ouvrir : l'application tourne sans copie
  /// hors ligne, et l'accueil doit le dire au lieu de le laisser découvrir.
  bool get localCacheUnavailable => _localCacheUnavailable;

  /// Date relue au démarrage.
  void restoreFetchedAt(DateTime? at) {
    _fetchedAt = at;
    _persistedAt = at;
  }

  void markCacheUnavailable() {
    _localCacheUnavailable = true;
    notifyListeners();
  }

  void markFresh(DateTime at) {
    _remember(at);
    if (!_servedFromCache && _fetchedAt != null) {
      _fetchedAt = at;
      return;
    }
    _servedFromCache = false;
    _fetchedAt = at;
    notifyListeners();
  }

  void _remember(DateTime at) {
    final DateTime? last = _persistedAt;
    if (_persist == null ||
        (last != null && at.difference(last).abs() < _persistEvery)) {
      return;
    }
    _persistedAt = at;
    _persist(at).ignore();
  }

  void markStale(DateTime? cachedAt) {
    if (_servedFromCache && _fetchedAt == cachedAt) {
      return;
    }
    _servedFromCache = true;
    _fetchedAt = cachedAt;
    notifyListeners();
  }
}
