import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_keur/app/data/repositories/in_memory_repositories.dart';
import 'package:woutalma_keur/app/data/seed/demo_seed.dart';
import 'package:woutalma_keur/app/domain/discovery.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/repositories.dart';
import 'package:woutalma_keur/app/modules/broker/property_editor_view_model.dart';

void main() {
  late InMemoryStore store;
  late PropertyRepository properties;
  late DiscoveryService discovery;

  DateTime clock() => DateTime.utc(2026, 8, 1, 12);

  PropertyEditorViewModel editor({Property? existing, Property? previous}) {
    return PropertyEditorViewModel(
      properties: properties,
      brokerId: 'brk-moussa',
      fallbackPosition: DemoSeed.clientPosition,
      now: clock,
      existing: existing,
      previous: previous,
    );
  }

  setUp(() async {
    store = InMemoryStore();
    properties = InMemoryPropertyRepository(store);
    discovery = DiscoveryService(
      brokers: InMemoryBrokerRepository(store),
      properties: properties,
      reviews: InMemoryReviewRepository(store),
    );
    await InMemorySeedRepository(store).loadDemoSeed();
  });

  test('un bien publié apparaît dans la découverte client', () async {
    final String? id = await editor().save(
      title: 'Villa 5 pièces à Ouakam',
      priceText: '650000',
      neighbourhood: 'Ouakam',
    );

    expect(id, isNotNull);
    final List<Property> visible = await discovery.findProperties(
      from: DemoSeed.clientPosition,
    );
    expect(visible.any((Property p) => p.id == id), isTrue);
  });

  test('un bien publié clos n\'apparaît pas côté client', () async {
    final PropertyEditorViewModel model = editor()
      ..setStatus(PropertyStatus.closed);

    final String? id = await model.save(
      title: 'Maison déjà louée',
      priceText: '200000',
      neighbourhood: 'Médina',
    );

    final List<Property> visible = await discovery.findProperties(
      from: DemoSeed.clientPosition,
    );
    expect(visible.any((Property p) => p.id == id), isFalse);
    // Mais elle reste dans la gestion du courtier.
    final List<Property> owned = await properties.byBroker('brk-moussa');
    expect(owned.any((Property p) => p.id == id), isTrue);
  });

  test('un titre vide bloque la publication', () async {
    final String? id = await editor().save(
      title: '   ',
      priceText: '300000',
      neighbourhood: 'Fann',
    );

    expect(id, isNull);
  });

  test('un prix nul bloque la publication', () async {
    final String? id = await editor().save(
      title: 'Chambre à Fann',
      priceText: '0',
      neighbourhood: 'Fann',
    );

    expect(id, isNull);
  });

  test('le prix accepte une saisie avec espaces', () async {
    final String? id = await editor().save(
      title: 'Appartement à Fann',
      // Ce que quelqu'un tape réellement.
      priceText: '450 000',
      neighbourhood: 'Fann',
    );

    final Property? saved = await properties.byId(id!);
    expect(saved!.price, 450000);
  });

  test('modifier conserve l\'identifiant et la date de création', () async {
    final Property original = (await properties.byId('prp-001'))!;

    final String? id = await editor(existing: original).save(
      title: 'Maison 4 pièces à Médina, rénovée',
      priceText: '380000',
      neighbourhood: original.neighbourhood,
    );

    expect(id, original.id);
    final Property? updated = await properties.byId(original.id);
    expect(updated!.createdAt, original.createdAt);
    expect(updated.price, 380000);
    // Aucun doublon créé.
    expect(
      (await properties.byBroker(
        original.brokerId,
      )).where((Property p) => p.id == original.id).length,
      1,
    );
  });

  test('le bien suivant reprend ce qui se répète, et le signale', () async {
    final Property previous = (await properties.byId('prp-004'))!;
    final PropertyEditorViewModel model = editor(previous: previous);

    expect(model.transaction, previous.transaction);
    expect(model.kind, previous.kind);
    // Signalé à l'écran : une valeur reprise sans qu'on la remarque devient
    // une annonce fausse publiée sous son nom.
    expect(model.prefilledFromPrevious, isTrue);
  });

  test('toucher un champ repris lève le signalement', () async {
    final Property previous = (await properties.byId('prp-004'))!;
    final PropertyEditorViewModel model = editor(previous: previous)
      ..setKind(PropertyKind.land);

    expect(model.prefilledFromPrevious, isFalse);
  });
}
