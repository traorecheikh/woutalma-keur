import 'package:woutalma_keur/app/data/seed/demo_seed.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/repositories.dart';

/// Magasin local unique, partagé par tous les dépôts.
///
/// Première implémentation des contrats de `repositories.dart`. Elle existe
/// pour que les écrans se construisent et se testent sans attendre la
/// génération de code de la base ; l'implémentation persistante viendra
/// derrière les mêmes interfaces, sans toucher un seul widget.
///
/// **Limite assumée** : rien ne survit à la fermeture de l'application.
class InMemoryStore {
  final Map<String, Broker> brokers = <String, Broker>{};
  final Map<String, Property> properties = <String, Property>{};
  final Map<String, Review> reviews = <String, Review>{};
  final Map<String, ContactLog> contacts = <String, ContactLog>{};

  int _sequence = 0;

  /// Identifiants croissants et prévisibles : un test peut les attendre.
  String nextId(String prefix) => '$prefix-${++_sequence}';

  void clear() {
    brokers.clear();
    properties.clear();
    reviews.clear();
    contacts.clear();
  }

  int get itemCount =>
      brokers.length + properties.length + reviews.length + contacts.length;
}

class InMemoryBrokerRepository implements BrokerRepository {
  InMemoryBrokerRepository(this._store);

  final InMemoryStore _store;

  @override
  Future<List<Broker>> all() async => _store.brokers.values.toList();

  @override
  Future<Broker?> byId(String id) async => _store.brokers[id];

  @override
  Future<void> save(Broker broker) async => _store.brokers[broker.id] = broker;
}

class InMemoryPropertyRepository implements PropertyRepository {
  InMemoryPropertyRepository(this._store);

  final InMemoryStore _store;

  @override
  Future<List<Property>> all() async => _store.properties.values.toList();

  @override
  Future<List<Property>> discoverable() async =>
      _store.properties.values.where((Property p) => p.isDiscoverable).toList();

  @override
  Future<List<Property>> byBroker(
    String brokerId, {
    bool onlyDiscoverable = false,
  }) async {
    return _store.properties.values
        .where(
          (Property p) =>
              p.brokerId == brokerId && (!onlyDiscoverable || p.isDiscoverable),
        )
        .toList();
  }

  @override
  Future<Property?> byId(String id) async => _store.properties[id];

  @override
  Future<void> save(Property property) async =>
      _store.properties[property.id] = property;

  @override
  Future<void> delete(String id) async => _store.properties.remove(id);
}

class InMemoryReviewRepository implements ReviewRepository {
  InMemoryReviewRepository(this._store);

  final InMemoryStore _store;

  @override
  Future<List<Review>> all() async => _store.reviews.values.toList();

  @override
  Future<List<Review>> byBroker(
    String brokerId, {
    bool onlyPublic = true,
  }) async {
    final List<Review> found =
        _store.reviews.values
            .where(
              (Review r) =>
                  r.brokerId == brokerId && (!onlyPublic || r.isPublic),
            )
            .toList()
          ..sort((Review a, Review b) => b.createdAt.compareTo(a.createdAt));
    return found;
  }

  @override
  Future<void> save(Review review) async => _store.reviews[review.id] = review;
}

class InMemoryContactRepository implements ContactRepository {
  InMemoryContactRepository(this._store, {required DateTime Function() now})
    : _now = now;

  final InMemoryStore _store;

  /// Injectée : une horloge figée rend les tests reproductibles.
  final DateTime Function() _now;

  @override
  Future<List<ContactLog>> all() async {
    final List<ContactLog> found = _store.contacts.values.toList()
      ..sort(
        (ContactLog a, ContactLog b) => b.createdAt.compareTo(a.createdAt),
      );
    return found;
  }

  @override
  Future<ContactLog?> byId(String id) async => _store.contacts[id];

  @override
  Future<ContactLog> log({
    required String brokerId,
    String? propertyId,
    required ContactChannel channel,
  }) async {
    final ContactLog contact = ContactLog(
      id: _store.nextId('ctc'),
      brokerId: brokerId,
      propertyId: propertyId,
      channel: channel,
      createdAt: _now(),
    );
    _store.contacts[contact.id] = contact;
    return contact;
  }

  @override
  Future<void> update(ContactLog contact) async =>
      _store.contacts[contact.id] = contact;
}

class InMemorySeedRepository implements SeedRepository {
  InMemorySeedRepository(this._store, {DemoSeed seed = const DemoSeed()})
    : _seed = seed;

  final InMemoryStore _store;
  final DemoSeed _seed;

  @override
  Future<void> clearAll() async => _store.clear();

  @override
  Future<int> itemCount() async => _store.itemCount;

  @override
  Future<void> loadDemoSeed() async {
    // Purge d'abord : charger deux fois ne doit pas dupliquer.
    _store.clear();
    for (final Broker b in _seed.brokers()) {
      _store.brokers[b.id] = b;
    }
    for (final Property p in _seed.properties()) {
      _store.properties[p.id] = p;
    }
    for (final Review r in _seed.reviews()) {
      _store.reviews[r.id] = r;
    }
    for (final ContactLog c in _seed.contacts()) {
      _store.contacts[c.id] = c;
    }
  }
}
