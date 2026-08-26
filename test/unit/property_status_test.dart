import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_keur/app/data/repositories/in_memory_repositories.dart';
import 'package:woutalma_keur/app/data/seed/demo_seed.dart';
import 'package:woutalma_keur/app/domain/discovery.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/repositories.dart';
import 'package:woutalma_keur/app/modules/broker/broker_properties_screen.dart';

void main() {
  late InMemoryStore store;
  late PropertyRepository properties;
  late DiscoveryService discovery;
  late BrokerPropertiesViewModel model;

  setUp(() async {
    store = InMemoryStore();
    properties = InMemoryPropertyRepository(store);
    discovery = LocalDiscoveryService(
      brokers: InMemoryBrokerRepository(store),
      properties: properties,
      reviews: InMemoryReviewRepository(store),
    );
    await InMemorySeedRepository(store).loadDemoSeed();
    model = BrokerPropertiesViewModel(
      properties: properties,
      brokerId: 'brk-moussa',
    );
    await model.load();
  });

  Future<bool> visibleToClients(String id) async {
    final List<Property> found = await discovery.findProperties(
      from: DemoSeed.clientPosition,
    );
    return found.any((Property p) => p.id == id);
  }

  test('clore un bien le retire immédiatement des recherches', () async {
    expect(await visibleToClients('prp-001'), isTrue);

    await model.changeStatus(
      (await properties.byId('prp-001'))!,
      PropertyStatus.closed,
    );

    expect(await visibleToClients('prp-001'), isFalse);
    // Il reste dans la gestion : le courtier doit pouvoir le rouvrir.
    expect(
      (await properties.byBroker(
        'brk-moussa',
      )).any((Property p) => p.id == 'prp-001'),
      isTrue,
    );
  });

  test('rouvrir un bien clos le remet dans les recherches', () async {
    await model.changeStatus(
      (await properties.byId('prp-001'))!,
      PropertyStatus.closed,
    );
    expect(await visibleToClients('prp-001'), isFalse);

    await model.changeStatus(
      (await properties.byId('prp-001'))!,
      PropertyStatus.available,
    );

    expect(await visibleToClients('prp-001'), isTrue);
  });

  test('réserver garde le bien visible, avec son statut', () async {
    await model.changeStatus(
      (await properties.byId('prp-001'))!,
      PropertyStatus.reserved,
    );

    expect(await visibleToClients('prp-001'), isTrue);
    expect((await properties.byId('prp-001'))!.status, PropertyStatus.reserved);
  });

  test('changer le statut ne touche à rien d\'autre', () async {
    final Property before = (await properties.byId('prp-001'))!;

    await model.changeStatus(before, PropertyStatus.reserved);

    final Property after = (await properties.byId('prp-001'))!;
    expect(after.title, before.title);
    expect(after.price, before.price);
    expect(after.createdAt, before.createdAt);
    expect(after.position, before.position);
  });

  test('le message vocal et les photos survivent au changement', () async {
    // Le bien recomposé à la main oubliait `voiceAsset` : le dépôt distant
    // lisait cet oubli comme un retrait et effaçait l'enregistrement du
    // courtier au moment où il disait « c'est loué ».
    final Property before = (await properties.byId('prp-001'))!.copyWith(
      voiceAsset: 'api:note-1',
      photoAssets: <String>['demo:house:medina:front'],
      surface: 90,
      rooms: 4,
    );
    await properties.save(before);

    await model.changeStatus(before, PropertyStatus.closed);

    final Property after = (await properties.byId('prp-001'))!;
    expect(after.status, PropertyStatus.closed);
    expect(after.voiceAsset, 'api:note-1');
    expect(after.hasVoiceNote, isTrue);
    expect(after.photoAssets, <String>['demo:house:medina:front']);
    expect(after.surface, 90);
    expect(after.rooms, 4);
    expect(after.description, before.description);
    expect(after.neighbourhood, before.neighbourhood);
  });

  test('copyWith vide un champ seulement quand on le lui demande', () async {
    final Property before = (await properties.byId(
      'prp-001',
    ))!.copyWith(voiceAsset: 'api:note-1', surface: 90, rooms: 4);

    expect(
      before.copyWith(status: PropertyStatus.closed).voiceAsset,
      isNotNull,
    );
    expect(before.copyWith(clearVoiceAsset: true).voiceAsset, isNull);
    expect(before.copyWith(clearRooms: true).rooms, isNull);
    expect(before.copyWith(clearRooms: true).surface, 90);
    expect(before.copyWith(clearSurface: true).surface, isNull);
  });

  test('rejouer le même statut ne réécrit rien', () async {
    final Property before = (await properties.byId('prp-001'))!;

    await model.changeStatus(before, before.status);

    expect((await properties.byId('prp-001'))!.status, before.status);
    // Aucun doublon n'est créé au passage.
    expect(
      (await properties.byBroker(
        'brk-moussa',
      )).where((Property p) => p.id == 'prp-001').length,
      1,
    );
  });
}
