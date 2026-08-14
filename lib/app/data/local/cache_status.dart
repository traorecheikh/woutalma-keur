import 'package:flutter/foundation.dart';

/// Dit à l'interface si ce qu'elle affiche vient du serveur ou de la dernière
/// copie reçue.
///
/// Un seul objet pour toute l'application : la question « suis-je à jour ? »
/// n'est pas propre à un écran, et deux bandeaux qui se contredisent seraient
/// pires qu'aucun.
class CacheStatus extends ChangeNotifier {
  bool _servedFromCache = false;
  DateTime? _fetchedAt;

  /// Vrai dès qu'une lecture a dû se rabattre sur la copie locale.
  bool get servedFromCache => _servedFromCache;

  /// Quand la copie affichée a été reçue du serveur. `null` si on n'a jamais
  /// réussi une lecture.
  DateTime? get fetchedAt => _fetchedAt;

  void markFresh(DateTime at) {
    if (!_servedFromCache && _fetchedAt != null) {
      _fetchedAt = at;
      return;
    }
    _servedFromCache = false;
    _fetchedAt = at;
    notifyListeners();
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
