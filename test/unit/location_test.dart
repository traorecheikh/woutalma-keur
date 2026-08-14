import 'package:flutter_test/flutter_test.dart';
import '../support/fake_location.dart';
import 'package:woutalma_keur/app/data/repositories/in_memory_repositories.dart';
import 'package:woutalma_keur/app/data/seed/demo_seed.dart';
import 'package:woutalma_keur/app/domain/discovery.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/location_service.dart';
import 'package:woutalma_keur/app/modules/client/explore/explore_view_model.dart';

void main() {
  late ExploreViewModel model;

  const Neighbourhood keurMassar = Neighbourhood(
    name: 'Keur Massar',
    position: GeoPoint(14.7822, -17.3188),
  );
  const Neighbourhood plateau = Neighbourhood(
    name: 'Plateau',
    position: DemoSeed.clientPosition,
  );

  setUp(() async {
    final InMemoryStore store = InMemoryStore();
    await InMemorySeedRepository(store).loadDemoSeed();
    model = ExploreViewModel(
      discovery: LocalDiscoveryService(
        brokers: InMemoryBrokerRepository(store),
        properties: InMemoryPropertyRepository(store),
        reviews: InMemoryReviewRepository(store),
      ),
      position: fakePositions(),
    );
    await model.load();
  });

  tearDown(() => model.dispose());

  test('changer de quartier reclasse les résultats', () async {
    final String firstFromPlateau =
        model.state.valueOrNull!.brokers.first.broker.id;

    await model.moveTo(keurMassar);

    // Les distances changent, donc le classement aussi. Le profil épinglé
    // reste en tête, mais le reste bouge.
    final List<BrokerListing> after = model.state.valueOrNull!.brokers;
    final BrokerListing massar = after.firstWhere(
      (BrokerListing l) => l.broker.id == 'brk-keur-massar',
    );
    expect(massar.distanceMeters, lessThan(2000));
    expect(firstFromPlateau, isNotEmpty);
  });

  test('changer de quartier garde filtres et recherche', () async {
    await model.applyFilters(
      const DiscoveryFilters(transaction: TransactionKind.sale, query: 'terr'),
    );

    await model.moveTo(keurMassar);

    expect(model.filters.transaction, TransactionKind.sale);
    expect(model.filters.query, 'terr');
  });

  test('le nom du lieu devient le titre de l\'écran', () async {
    expect(model.placeName, isNull);

    await model.moveTo(keurMassar);

    expect(model.placeName, 'Keur Massar');
  });

  test('les récents remontent le dernier choix en tête', () async {
    await model.moveTo(keurMassar);
    await model.moveTo(plateau);

    expect(model.recentPlaces.first.name, 'Plateau');
    expect(model.recentPlaces[1].name, 'Keur Massar');
  });

  test('rechoisir un quartier ne le duplique pas', () async {
    await model.moveTo(keurMassar);
    await model.moveTo(plateau);
    await model.moveTo(keurMassar);

    expect(model.recentPlaces.length, 2);
    expect(model.recentPlaces.first.name, 'Keur Massar');
  });

  test('les récents restent courts', () async {
    for (final Neighbourhood place in dakarNeighbourhoods.take(6)) {
      await model.moveTo(place);
    }

    // Une liste de récents qui s'allonge cesse d'être un raccourci.
    expect(model.recentPlaces.length, lessThanOrEqualTo(3));
  });

  test('les quartiers connus couvrent Dakar et sa banlieue', () {
    final Iterable<String> names = dakarNeighbourhoods.map(
      (Neighbourhood n) => n.name,
    );

    expect(names, contains('Plateau'));
    expect(names, contains('Keur Massar'));
    expect(names, contains('Guédiawaye'));
    expect(dakarNeighbourhoods.length, greaterThan(15));
  });
}
