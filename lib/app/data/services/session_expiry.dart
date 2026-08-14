import 'package:flutter/foundation.dart';

/// Annonce qu'une session est morte et qu'aucun renouvellement n'est possible.
///
/// L'intercepteur ne peut pas naviguer — il ne connaît pas le routeur — et le
/// routeur ne doit pas connaître Dio. Ce petit signal les relie sans les
/// coupler.
class SessionExpiry extends ChangeNotifier {
  bool _expired = false;

  bool get isExpired => _expired;

  void expire() {
    if (_expired) {
      return;
    }
    _expired = true;
    notifyListeners();
  }

  /// Appelé une fois l'utilisateur redirigé vers l'identification, pour que
  /// la prochaine expiration soit de nouveau signalée.
  void acknowledge() => _expired = false;
}
