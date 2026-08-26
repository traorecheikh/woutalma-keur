import 'package:woutalma_keur/app/domain/entities.dart';

/// Contrats de données.
///
/// Les écrans ne connaissent que ces interfaces. Une implémentation Isar ou
/// distante se substitue sans qu'un widget bouge.
abstract class BrokerRepository {
  Future<List<Broker>> all();
  Future<Broker?> byId(String id);
  Future<void> save(Broker broker);

  /// Écrit un lot d'un coup.
  ///
  /// Un magasin mémoire boucle sur [save] ; une base ouvre **une** transaction.
  /// Recopier une réponse serveur ligne par ligne en ouvre une par
  /// enregistrement, et sur un téléphone d'entrée de gamme — la cible
  /// d'acceptation — cela se voit à l'écran.
  Future<void> saveAll(List<Broker> brokers);

  /// B09 — se mettre dans la file de vérification.
  ///
  /// Une demande, jamais une décision : le badge est ce qu'un opérateur dit
  /// d'un courtier, donc [save] ne porte pas `verification` et cette méthode
  /// existe pour que le bouton ait un endroit légitime où aller. Rend le
  /// profil relu, pour que l'écran constate l'état réel au lieu de le
  /// supposer — c'est ce qui empêche un « demande envoyée » mensonger.
  Future<Broker> requestVerification(String brokerId);
}

abstract class PropertyRepository {
  Future<List<Property>> all();

  /// Ce que la découverte a le droit de montrer : un bien clos en sort.
  Future<List<Property>> discoverable();

  Future<List<Property>> byBroker(
    String brokerId, {
    bool onlyDiscoverable = false,
  });
  Future<Property?> byId(String id);

  /// Rend le bien **tel qu'enregistré**, pas celui qu'on a proposé.
  ///
  /// Même raison que [ReviewRepository.save] : à la publication, l'éditeur
  /// fabrique un identifiant local (`prp-<micros>`) que le serveur ignore — il
  /// frappe le sien — et il transforme les photos locales en clés `api:<id>`.
  /// Sans ce retour, la copie hors ligne s'écrivait sous l'identifiant
  /// fantôme et « Mes biens » montrait deux fois la même annonce.
  Future<Property> save(Property property);

  Future<void> delete(String id);

  /// Voir [BrokerRepository.saveAll].
  Future<void> saveAll(List<Property> properties);
}

abstract class ReviewRepository {
  /// Par défaut, **seulement les avis publiés**.
  ///
  /// La valeur par défaut est fournie par l'implémentation appelée, pas par
  /// l'interface : quand chaque classe choisissait la sienne, `byBroker(id)`
  /// rendait les avis publics sur Isar et les avis en modération sur le
  /// serveur. Le côté sûr est écrit ici et repris à l'identique partout.
  Future<List<Review>> byBroker(String brokerId, {bool onlyPublic = true});
  Future<List<Review>> all();

  /// Rend l'avis **tel qu'enregistré**, pas celui qu'on a proposé.
  ///
  /// L'identifiant et l'état de modération appartiennent à la source de
  /// vérité : côté serveur, l'identifiant est frappé à l'insertion et la
  /// modération démarre à `pending`. L'appelant en a besoin pour rattacher
  /// l'avis au contact, d'où le retour plutôt qu'un `void`.
  Future<Review> save(Review review);

  /// Voir [BrokerRepository.saveAll].
  Future<void> saveAll(List<Review> reviews);

  /// B06 — réponse publique du courtier à un avis le concernant.
  ///
  /// Distinct de [save] : répondre n'est pas déposer un avis. Passer par
  /// `save()` envoyait un nouvel avis signé du courtier contre le contact du
  /// client, que le serveur refusait — à juste titre — en 403.
  Future<Review> reply(String reviewId, String reply);

  /// B06 — signaler un avis pour re-modération.
  ///
  /// Remet l'avis en attente ; seul un opérateur peut le rejeter. Un courtier
  /// qui pourrait rejeter lui-même supprimerait la critique.
  Future<Review> report(String reviewId, {String? reason});
}

abstract class ContactRepository {
  Future<List<ContactLog>> all();
  Future<ContactLog?> byId(String id);

  /// Journalise **avant** d'ouvrir le canal externe : si l'utilisateur ne
  /// revient jamais dans l'app, la trace existe quand même.
  Future<ContactLog> log({
    required String brokerId,
    String? propertyId,
    required ContactChannel channel,
  });

  Future<void> update(ContactLog contact);

  /// Voir [BrokerRepository.saveAll].
  Future<void> updateAll(List<ContactLog> contacts);

  Future<void> remove(String id);

  /// B05 — les mises en relation **reçues** par un courtier.
  ///
  /// [all] rend ce que l'utilisateur a envoyé en tant que client ; ce n'est
  /// pas la même liste, et filtrer l'une pour obtenir l'autre donnait toujours
  /// zéro. Les entrées rendues ne portent aucune identité de client :
  /// rapprocher un avis d'un appel précis désignerait son auteur
  /// (docs/PRODUCT.md §4 règle 7).
  Future<List<ContactLog>> receivedBy(String brokerId);
}

/// Ce que le mode démo peut purger et resemer.
abstract class SeedRepository {
  Future<void> clearAll();
  Future<void> loadDemoSeed();
  Future<int> itemCount();
}
