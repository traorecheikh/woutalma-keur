import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_keur/app/data/repositories/in_memory_repositories.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/repositories.dart';
import 'package:woutalma_keur/app/modules/broker/broker_activity_screen.dart';
import 'package:woutalma_keur/app/modules/broker/broker_home_screen.dart';

/// Compte les lectures : le journal d'activité en faisait une par contact
/// reçu, sur un réseau où chacune se paie.
class _CountingProperties implements PropertyRepository {
  _CountingProperties(this._inner);

  final PropertyRepository _inner;
  int byIdCalls = 0;
  int byBrokerCalls = 0;

  @override
  Future<Property?> byId(String id) {
    byIdCalls++;
    return _inner.byId(id);
  }

  @override
  Future<List<Property>> byBroker(
    String brokerId, {
    bool onlyDiscoverable = false,
  }) {
    byBrokerCalls++;
    return _inner.byBroker(brokerId, onlyDiscoverable: onlyDiscoverable);
  }

  @override
  Future<List<Property>> all() => _inner.all();

  @override
  Future<List<Property>> discoverable() => _inner.discoverable();

  @override
  Future<void> delete(String id) => _inner.delete(id);

  @override
  Future<Property> save(Property property) => _inner.save(property);

  @override
  Future<void> saveAll(List<Property> properties) => _inner.saveAll(properties);
}

void main() {
  late InMemoryStore store;

  setUp(() async {
    store = InMemoryStore();
    await InMemorySeedRepository(store).loadDemoSeed();
  });

  test('B01 compte les contacts reçus, pas ceux qu\'on a envoyés', () async {
    final ContactRepository contacts = InMemoryContactRepository(
      store,
      now: () => DateTime.utc(2026, 8, 1),
    );
    final BrokerHomeViewModel model = BrokerHomeViewModel(
      brokers: InMemoryBrokerRepository(store),
      properties: InMemoryPropertyRepository(store),
      reviews: InMemoryReviewRepository(store),
      contacts: contacts,
      brokerId: 'brk-moussa',
    );
    addTearDown(model.dispose);

    await model.load();

    // `all()` rend l'historique du compte **en tant que client** : filtré sur
    // le courtier, il trouvait toujours zéro.
    expect(
      model.state.valueOrNull!.contactsReceived,
      (await contacts.receivedBy('brk-moussa')).length,
    );
    expect(model.state.valueOrNull!.contactsReceived, greaterThan(0));
  });

  test('B05 lit les biens une fois, pas une fois par contact', () async {
    final _CountingProperties properties = _CountingProperties(
      InMemoryPropertyRepository(store),
    );
    final BrokerActivityViewModel model = BrokerActivityViewModel(
      contacts: InMemoryContactRepository(
        store,
        now: () => DateTime.utc(2026, 8, 1),
      ),
      properties: properties,
      brokerId: 'brk-moussa',
    );
    addTearDown(model.dispose);

    await model.load();

    expect(properties.byBrokerCalls, 1);
    expect(properties.byIdCalls, 0);
    // Et le bien reste rattaché à son contact.
    final List<ReceivedContact> received = model.state.valueOrNull!;
    final ReceivedContact withProperty = received.firstWhere(
      (ReceivedContact r) => r.contact.propertyId != null,
    );
    expect(withProperty.property?.id, withProperty.contact.propertyId);
  });
}
