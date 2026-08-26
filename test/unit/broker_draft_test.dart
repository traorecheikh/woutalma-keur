import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_keur/app/data/repositories/in_memory_repositories.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/location_service.dart';
import 'package:woutalma_keur/app/modules/broker/property_editor_draft.dart';
import 'package:woutalma_keur/app/modules/broker/property_editor_view_model.dart';

/// Brouillon en mémoire : le vrai passe par `path_provider`, qui n'existe pas
/// dans `flutter test`.
class _FakeDrafts implements PropertyDraftStore {
  PropertyDraft? saved;
  int clears = 0;

  @override
  Future<PropertyDraft?> read() async => saved;

  @override
  Future<void> write(PropertyDraft draft) async => saved = draft;

  @override
  Future<void> clear() async {
    saved = null;
    clears++;
  }
}

void main() {
  late InMemoryStore store;
  late _FakeDrafts drafts;

  PropertyEditorViewModel editor({Property? existing}) =>
      PropertyEditorViewModel(
        properties: InMemoryPropertyRepository(store),
        brokerId: 'brk-moussa',
        fallbackPosition: const GeoPoint(14.7, -17.4),
        now: () => DateTime.utc(2026, 8, 1),
        drafts: drafts,
        existing: existing,
      );

  setUp(() {
    store = InMemoryStore();
    drafts = _FakeDrafts();
  });

  test('la saisie survit à une fermeture de l\'application', () async {
    final PropertyEditorViewModel model = editor()
      ..setTransaction(TransactionKind.sale)
      ..setKind(PropertyKind.land)
      ..setSurface(300)
      ..setNeighbourhood(
        dakarNeighbourhoods.firstWhere((Neighbourhood n) => n.name == 'Yoff'),
      );
    addTearDown(model.dispose);

    model.rememberDraft(
      title: 'Terrain Yoff',
      priceText: '9000000',
      description: 'Bien clôturé.',
    );
    await Future<void>.delayed(const Duration(milliseconds: 700));

    final PropertyDraft? kept = await drafts.read();
    expect(kept, isNotNull);
    expect(kept!.title, 'Terrain Yoff');
    expect(kept.priceText, '9000000');
    expect(kept.kind, PropertyKind.land);
    expect(kept.transaction, TransactionKind.sale);
    expect(kept.surface, 300);
    expect(kept.neighbourhood?.name, 'Yoff');
  });

  test('rouvrir l\'éditeur retrouve ce brouillon et le restitue', () async {
    drafts.saved = PropertyDraft(
      id: 'prp-1',
      kind: PropertyKind.studio,
      transaction: TransactionKind.rent,
      title: 'Studio Ngor',
      description: 'Vue mer.',
      priceText: '150000',
      surface: 25,
      rooms: 1,
      neighbourhood: dakarNeighbourhoods.first,
      photos: const <String>['/data/wk-1.jpg'],
      voiceNote: '/data/wk-voice.m4a',
    );

    final PropertyEditorViewModel model = editor();
    addTearDown(model.dispose);
    final PropertyDraft? found = await model.pendingDraft();
    model.restore(found!);

    expect(model.kind, PropertyKind.studio);
    expect(model.surface, 25);
    expect(model.rooms, 1);
    expect(model.photos, <String>['/data/wk-1.jpg']);
    expect(model.voiceNote, '/data/wk-voice.m4a');
  });

  test('modifier un bien existant n\'hérite pas d\'un brouillon', () async {
    drafts.saved = PropertyDraft(
      id: 'prp-1',
      kind: PropertyKind.studio,
      transaction: TransactionKind.rent,
      title: 'Studio Ngor',
      description: '',
      priceText: '150000',
      photos: const <String>[],
    );

    final PropertyEditorViewModel model = editor(
      existing: Property(
        id: 'cksrv1',
        brokerId: 'brk-moussa',
        kind: PropertyKind.house,
        transaction: TransactionKind.sale,
        title: 'Villa Ngor',
        price: 90000000,
        position: const GeoPoint(14.7, -17.4),
        neighbourhood: 'Ngor',
        createdAt: DateTime.utc(2026, 1, 1),
      ),
    );
    addTearDown(model.dispose);

    expect(await model.pendingDraft(), isNull);
  });

  test('publier efface le brouillon', () async {
    final PropertyEditorViewModel model = editor()
      ..setNeighbourhood(
        dakarNeighbourhoods.firstWhere((Neighbourhood n) => n.name == 'Yoff'),
      );
    addTearDown(model.dispose);

    final String? id = await model.save(
      title: 'Studio Yoff',
      priceText: '120000',
    );

    expect(id, isNotNull);
    expect(drafts.clears, 1);
    expect(await drafts.read(), isNull);
  });

  test('le prix garde le plafond du serveur', () async {
    final PropertyEditorViewModel model = editor()
      ..setNeighbourhood(
        dakarNeighbourhoods.firstWhere((Neighbourhood n) => n.name == 'Yoff'),
      );
    addTearDown(model.dispose);

    expect(model.isPriceTooHigh(PropertyEditorViewModel.maxPriceCfa), isFalse);
    expect(
      model.isPriceTooHigh(PropertyEditorViewModel.maxPriceCfa + 1),
      isTrue,
    );

    // Un zéro de trop n'est plus envoyé pour se faire refuser là-bas.
    final String? id = await model.save(
      title: 'Villa Yoff',
      priceText: '${PropertyEditorViewModel.maxPriceCfa + 1}',
    );
    expect(id, isNull);
  });

  test('deux essais de publication portent le même identifiant', () async {
    final PropertyEditorViewModel model = editor()
      ..setNeighbourhood(
        dakarNeighbourhoods.firstWhere((Neighbourhood n) => n.name == 'Yoff'),
      );
    addTearDown(model.dispose);

    model.rememberDraft(title: 'A', priceText: '1', description: '');
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final String first = (await drafts.read())!.id;

    model.rememberDraft(title: 'B', priceText: '2', description: '');
    await Future<void>.delayed(const Duration(milliseconds: 700));

    // C'est cet identifiant que le serveur reçoit comme clé d'idempotence :
    // le regénérer publiait deux fois la même annonce après un délai dépassé.
    expect((await drafts.read())!.id, first);
  });
}
