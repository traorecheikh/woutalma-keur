import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/data/repositories/in_memory_repositories.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/repositories.dart';
import 'package:woutalma_keur/app/modules/broker/broker_properties_screen.dart';
import 'package:woutalma_keur/app/routes/reload_on_return.dart';

import '../support/pump.dart';

/// Compte les lectures, et laisse le test décider de ce qu'elles rendent.
class _CountingProperties implements PropertyRepository {
  _CountingProperties(this._inner);

  final PropertyRepository _inner;
  int reads = 0;

  @override
  Future<List<Property>> byBroker(
    String brokerId, {
    bool onlyDiscoverable = false,
  }) {
    reads++;
    return _inner.byBroker(brokerId, onlyDiscoverable: onlyDiscoverable);
  }

  @override
  Future<List<Property>> all() => _inner.all();
  @override
  Future<List<Property>> discoverable() => _inner.discoverable();
  @override
  Future<Property?> byId(String id) => _inner.byId(id);
  @override
  Future<Property> save(Property property) => _inner.save(property);
  @override
  Future<void> delete(String id) => _inner.delete(id);
  @override
  Future<void> saveAll(List<Property> properties) => _inner.saveAll(properties);
}

/// B02 après publication : le bien existait côté serveur et la liste affichait
/// encore « Aucun bien publié ». La branche du shell n'est construite qu'une
/// fois, donc son `load()` initial aussi.
void main() {
  late InMemoryStore store;
  late _CountingProperties properties;
  late BrokerPropertiesViewModel model;

  setUp(() async {
    store = InMemoryStore();
    await InMemorySeedRepository(store).loadDemoSeed();
    properties = _CountingProperties(InMemoryPropertyRepository(store));
    model = BrokerPropertiesViewModel(
      properties: properties,
      brokerId: 'brk-neuf',
    );
    await model.load();
  });

  tearDown(() => model.dispose());

  /// Monte B02 comme la route le fait — enveloppé dans [ReloadOnReturn] — et
  /// reproduit ce que fait la pile de navigation : `TickerMode` est coupé sous
  /// une route opaque, et rétabli au retour.
  ///
  /// L'enveloppe fait partie du sujet : l'écran a d'abord porté sa propre copie
  /// du mécanisme, et le monter nu ici aurait laissé passer sa suppression.
  Future<void> pumpList(WidgetTester tester, ValueNotifier<bool> visible) {
    return pumpWk(
      tester,
      ChangeNotifierProvider<BrokerPropertiesViewModel>.value(
        value: model,
        child: ValueListenableBuilder<bool>(
          valueListenable: visible,
          builder: (BuildContext context, bool enabled, Widget? child) =>
              TickerMode(enabled: enabled, child: child!),
          child: ReloadOnReturn<BrokerPropertiesViewModel>(
            reload: (BrokerPropertiesViewModel model) => model.load(),
            child: BrokerPropertiesScreen(
              onAdd: () {},
              onEdit: (_) {},
              onPreview: (_) {},
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('revenir sur la liste la relit', (WidgetTester tester) async {
    final ValueNotifier<bool> visible = ValueNotifier<bool>(true);
    addTearDown(visible.dispose);

    await pumpList(tester, visible);
    await tester.pumpAndSettle();

    expect(properties.reads, 1);
    expect(find.text('Aucun bien publié'), findsOneWidget);

    // L'éditeur passe par-dessus, publie, puis se referme.
    visible.value = false;
    await tester.pumpAndSettle();
    await InMemoryPropertyRepository(store).save(
      Property(
        id: 'prp-neuf',
        brokerId: 'brk-neuf',
        kind: PropertyKind.studio,
        transaction: TransactionKind.rent,
        title: 'Studio à Yoff',
        description: '',
        price: 120000,
        position: const GeoPoint(14.7550, -17.4700),
        neighbourhood: 'Yoff',
        photoAssets: const <String>[],
        status: PropertyStatus.available,
        createdAt: DateTime.utc(2026, 8, 1),
      ),
    );

    visible.value = true;
    await tester.pumpAndSettle();

    expect(properties.reads, 2);
    expect(find.text('Studio à Yoff'), findsOneWidget);
  });

  testWidgets('deux demandes simultanées ne font qu\'une requête', (
    WidgetTester tester,
  ) async {
    // La route peut recharger en même temps que l'écran :
    // `lib/app/routes/reload_on_return.dart` porte le même mécanisme. Sur un
    // réseau faible, doubler la requête se paie.
    final int before = properties.reads;

    final Future<void> first = model.load();
    final Future<void> second = model.load();
    await Future.wait(<Future<void>>[first, second]);

    expect(properties.reads, before + 1);
  });
}
