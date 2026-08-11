import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/repositories.dart';

/// Ouvre un canal de contact hors de l'application.
///
/// Abstrait pour deux raisons : un test ne doit pas déclencher un appel, et
/// l'échec d'ouverture doit être un cas traité, pas une exception muette.
abstract class ContactLauncher {
  /// Renvoie `false` si le téléphone n'a rien pour ouvrir ce canal.
  Future<bool> open(ContactChannel channel, Broker broker);
}

/// Séquence complète d'une mise en relation.
///
/// **L'ordre compte** : on journalise **avant** d'ouvrir le canal externe. Si
/// l'utilisateur ne revient jamais dans l'application, la trace existe quand
/// même — et c'est cette trace qui autorisera un avis plus tard.
class ContactService {
  const ContactService({
    required this.contacts,
    required this.launcher,
    this.openTimeout = const Duration(seconds: 5),
  });

  final ContactRepository contacts;
  final ContactLauncher launcher;

  /// Au-delà, on considère que rien ne s'ouvrira.
  ///
  /// Sans borne, un téléphone lent ou une application manquante laisse un
  /// indicateur tourner sans fin. `docs/INTERACTION-FEEDBACK.md` §2 l'interdit :
  /// passé cinq secondes, il faut une explication et une issue.
  final Duration openTimeout;

  Future<ContactAttempt> contact({
    required Broker broker,
    required ContactChannel channel,
    String? propertyId,
  }) async {
    final ContactLog log = await contacts.log(
      brokerId: broker.id,
      propertyId: propertyId,
      channel: channel,
    );

    bool opened;
    try {
      opened = await launcher
          .open(channel, broker)
          .timeout(openTimeout, onTimeout: () => false);
    } on Object {
      // Un canal absent lève parfois plutôt que de renvoyer faux. Dans les
      // deux cas, la trace reste et l'écran doit le dire.
      opened = false;
    }
    return ContactAttempt(log: log, opened: opened);
  }
}

class ContactAttempt {
  const ContactAttempt({required this.log, required this.opened});

  final ContactLog log;

  /// Faux quand aucune application ne pouvait prendre le relais. L'écran doit
  /// le dire : un bouton qui ne fait rien est pire qu'un bouton absent.
  final bool opened;
}
