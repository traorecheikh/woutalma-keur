import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_keur/app/core/state/mutation_state.dart';
import 'package:woutalma_keur/app/data/repositories/in_memory_repositories.dart';
import 'package:woutalma_keur/app/data/seed/demo_seed.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/location_service.dart';
import 'package:woutalma_keur/app/domain/property_surface.dart';
import 'package:woutalma_keur/app/domain/repositories.dart';
import 'package:woutalma_keur/app/modules/broker/property_editor_view_model.dart';

/// B03 après la refonte : ce que le formulaire **demande** et ce qu'il en
/// fait. Le quartier, la surface et les pièces ne sont plus des chaînes
/// reparsées par l'écran mais des choix typés, et le quartier apporte la
/// position que l'ancienne étape carte n'a jamais fournie.
void main() {
  late InMemoryStore store;
  late PropertyRepository properties;

  DateTime clock() => DateTime.utc(2026, 8, 1, 12);

  Neighbourhood area(String name) =>
      dakarNeighbourhoods.firstWhere((Neighbourhood n) => n.name == name);

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
    await InMemorySeedRepository(store).loadDemoSeed();
  });

  group('quartier', () {
    test('le quartier choisi place le bien', () async {
      final PropertyEditorViewModel model = editor()
        ..setNeighbourhood(area('Ngor'));

      final String? id = await model.save(
        title: 'Villa à Ngor',
        priceText: '900000',
      );

      final Property saved = (await properties.byId(id!))!;
      expect(saved.neighbourhood, 'Ngor');
      // Sans cette position, le bien atterrissait sur celle du téléphone du
      // courtier — ou, avant elle, au large du golfe de Guinée.
      expect(saved.position, area('Ngor').position);
    });

    test(
      'sans quartier, rien n\'est enregistré et rien n\'a été tenté',
      () async {
        final PropertyEditorViewModel model = editor();

        final String? id = await model.save(
          title: 'Studio sans adresse',
          priceText: '120000',
        );

        expect(id, isNull);
        // Saisie refusée, pas échec réseau : c'est ce qui distingue « corrigez
        // le formulaire » d'un « réessayez ».
        expect(model.submission, const MutationIdle());
        expect(store.properties.length, 10);
      },
    );

    test('rouvrir un bien ne le déplace pas', () async {
      final Property original = (await properties.byId('prp-001'))!;
      final PropertyEditorViewModel model = editor(existing: original);

      expect(model.neighbourhood?.name, original.neighbourhood);

      final String? id = await model.save(
        title: original.title,
        priceText: '390000',
      );

      final Property updated = (await properties.byId(id!))!;
      // Le nom vient de la liste, la position vient du bien : corriger un
      // prix ne recentre pas l'annonce sur le milieu du quartier.
      expect(updated.position, original.position);
    });

    test('un quartier absent de la liste reste proposé', () {
      final Property elsewhere = Property(
        id: 'prp-ext',
        brokerId: 'brk-moussa',
        kind: PropertyKind.house,
        transaction: TransactionKind.sale,
        title: 'Maison à Thiès',
        description: '',
        price: 25000000,
        position: const GeoPoint(14.7910, -16.9260),
        neighbourhood: 'Thiès',
        photoAssets: const <String>[],
        status: PropertyStatus.available,
        createdAt: clock(),
      );

      final PropertyEditorViewModel model = editor(existing: elsewhere);

      expect(
        model.neighbourhoodOptions.first.name,
        'Thiès',
        reason: 'Une annonce ancienne ne perd pas son quartier.',
      );
      expect(model.neighbourhoodOptions.length, dakarNeighbourhoods.length + 1);
    });

    test('le bien suivant reprend le quartier du précédent', () async {
      final Property previous = (await properties.byId('prp-004'))!;
      final PropertyEditorViewModel model = editor(previous: previous);

      expect(model.neighbourhood?.name, previous.neighbourhood);
      expect(model.prefilledFromPrevious, isTrue);
    });
  });

  group('surface', () {
    test('les paliers viennent du barème du domaine', () {
      final PropertyEditorViewModel model = editor()
        ..setKind(PropertyKind.land);

      expect(
        model.surfaceOptions,
        PropertySurfaceCatalogue.valuesFor(PropertyKind.land),
      );
    });

    test('une surface enregistrée hors palier garde sa place', () async {
      final Property original = (await properties.byId('prp-001'))!;
      final Property offGrid = Property(
        id: original.id,
        brokerId: original.brokerId,
        kind: original.kind,
        transaction: original.transaction,
        title: original.title,
        description: original.description,
        price: original.price,
        // Aucun barème ne propose 97 : c'est exactement le cas à préserver.
        surface: 97,
        rooms: original.rooms,
        position: original.position,
        neighbourhood: original.neighbourhood,
        photoAssets: original.photoAssets,
        status: original.status,
        createdAt: original.createdAt,
      );
      final PropertyEditorViewModel model = editor(existing: offGrid);

      expect(model.surface, 97);
      expect(
        model.surfaceOptions,
        contains(97),
        reason:
            'Arrondir la donnée de quelqu\'un d\'autre publie un chiffre '
            'qu\'il n\'a pas écrit.',
      );
      final List<int> sorted = List<int>.of(model.surfaceOptions)..sort();
      expect(model.surfaceOptions, orderedEquals(sorted));
    });

    test('la surface reste facultative', () async {
      final String? id = await (editor()..setNeighbourhood(area('Yoff'))).save(
        title: 'Terrain à Yoff',
        priceText: '15000000',
      );

      expect((await properties.byId(id!))!.surface, isNull);
    });
  });

  group('pièces', () {
    test('un terrain n\'a pas de pièces, et n\'en publie pas', () async {
      final PropertyEditorViewModel model = editor()
        ..setNeighbourhood(area('Keur Massar'))
        ..setRooms(3)
        ..setKind(PropertyKind.land);

      expect(model.asksRooms, isFalse);
      // Effacé au changement de type : sinon « 3 pièces » restait invisible
      // dans le formulaire et visible dans l'annonce publiée.
      expect(model.rooms, isNull);

      final String? id = await model.save(
        title: 'Terrain à Keur Massar',
        priceText: '18000000',
      );

      expect((await properties.byId(id!))!.rooms, isNull);
    });

    test('les pièces restent indexables par la recherche client', () async {
      final PropertyEditorViewModel model = editor()
        ..setNeighbourhood(area('Mermoz'))
        ..setRooms(3);

      final String? id = await model.save(
        title: 'Appartement à Mermoz',
        priceText: '400000',
      );

      // `discovery.dart` indexe « 3 pieces » : supprimer le champ retirerait
      // cette recherche, d'où le choix de le garder en sélecteur.
      expect((await properties.byId(id!))!.rooms, 3);
    });

    test('un nombre de pièces enregistré hors liste reste proposé', () async {
      final Property original = (await properties.byId('prp-010'))!;
      final PropertyEditorViewModel model = editor(existing: original)
        ..setRooms(9);

      expect(model.roomOptions, contains(9));
    });
  });
}
