import 'package:woutalma_keur/app/domain/entities.dart';

/// Contrats de données.
///
/// Les écrans ne connaissent que ces interfaces. Une implémentation Isar ou
/// distante se substitue sans qu'un widget bouge.
abstract class BrokerRepository {
  Future<List<Broker>> all();
  Future<Broker?> byId(String id);
  Future<void> save(Broker broker);
}

abstract class PropertyRepository {
  Future<List<Property>> all();

  /// Ce que la découverte a le droit de montrer : un bien clos en sort.
  Future<List<Property>> discoverable();

  Future<List<Property>> byBroker(String brokerId, {bool onlyDiscoverable});
  Future<Property?> byId(String id);
  Future<void> save(Property property);
  Future<void> delete(String id);
}

abstract class ReviewRepository {
  Future<List<Review>> byBroker(String brokerId, {bool onlyPublic});
  Future<List<Review>> all();

  /// Rend l'avis **tel qu'enregistré**, pas celui qu'on a proposé.
  ///
  /// L'identifiant et l'état de modération appartiennent à la source de
  /// vérité : côté serveur, l'identifiant est frappé à l'insertion et la
  /// modération démarre à `pending`. L'appelant en a besoin pour rattacher
  /// l'avis au contact, d'où le retour plutôt qu'un `void`.
  Future<Review> save(Review review);
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
}

/// Ce que le mode démo peut purger et resemer.
abstract class SeedRepository {
  Future<void> clearAll();
  Future<void> loadDemoSeed();
  Future<int> itemCount();
}
