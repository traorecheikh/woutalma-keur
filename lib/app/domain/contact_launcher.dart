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
/// **L'ordre compte** : on ouvre le canal **avant** de journaliser. Le journal
/// exige le réseau et une session ; le faire précéder l'appel privait de
/// téléphone quiconque était hors ligne ou non identifié. La trace suit, et le
/// dépôt la met en attente localement si elle ne part pas.
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
    if (!await open(channel, broker)) {
      return const ContactAttempt(log: null, opened: false);
    }
    ContactLog? log;
    try {
      log = await contacts.log(
        brokerId: broker.id,
        propertyId: propertyId,
        channel: channel,
      );
    } on Object {
      log = null;
    }
    return ContactAttempt(log: log, opened: true);
  }

  /// Ouvre le canal sans rien journaliser : un appel doit partir même sans
  /// compte, quand l'identification est refusée.
  Future<bool> open(ContactChannel channel, Broker broker) async {
    try {
      return await launcher
          .open(channel, broker)
          .timeout(openTimeout, onTimeout: () => false);
    } on Object {
      // Un canal absent lève parfois plutôt que de renvoyer faux.
      return false;
    }
  }

  Future<void> recordOutcome(ContactLog log, ContactOutcome outcome) =>
      contacts.update(log.copyWith(outcome: outcome));
}

class ContactAttempt {
  const ContactAttempt({required this.log, required this.opened});

  /// Nul quand rien n'a pu être écrit, même localement.
  final ContactLog? log;

  /// Faux quand aucune application ne pouvait prendre le relais. L'écran doit
  /// le dire : un bouton qui ne fait rien est pire qu'un bouton absent.
  final bool opened;
}
