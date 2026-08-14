import 'package:flutter_test/flutter_test.dart';
import '../support/fake_location.dart';
import 'package:woutalma_keur/app/data/repositories/in_memory_repositories.dart';
import 'package:woutalma_keur/app/domain/discovery.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/modules/client/explore/explore_view_model.dart';

void main() {
  late ExploreViewModel model;

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

  test('la liste est la vue par défaut', () {
    // La carte télécharge des tuiles : elle se demande, elle ne s'impose pas
    // à une cible qui paie sa data.
    expect(model.view, ExploreView.list);
  });

  test('passer à la carte ne change pas les résultats', () async {
    await model.applyFilters(
      const DiscoveryFilters(transaction: TransactionKind.sale),
    );
    final int before = model.state.valueOrNull!.brokers.length;

    model.selectView(ExploreView.map);

    expect(model.view, ExploreView.map);
    expect(model.state.valueOrNull!.brokers.length, before);
    expect(model.filters.transaction, TransactionKind.sale);
  });

  test('changer de vue ne touche pas au segment', () {
    model
      ..selectSegment(ExploreSegment.properties)
      ..selectView(ExploreView.map);

    expect(model.segment, ExploreSegment.properties);
  });

  test('rechoisir la même vue ne fait rien', () {
    var notifications = 0;
    model.addListener(() => notifications++);

    model
      ..selectView(ExploreView.list)
      ..selectView(ExploreView.list);

    expect(notifications, 0);
  });

  test('chaque résultat a une position exploitable par la carte', () {
    final ExploreResults results = model.state.valueOrNull!;

    for (final BrokerListing listing in results.brokers) {
      // Dakar : latitude autour de 14,7 et longitude autour de -17,4. Un
      // marqueur à zéro tomberait au large du golfe de Guinée.
      expect(listing.broker.position.latitude, inInclusiveRange(14, 15.5));
      expect(listing.broker.position.longitude, inInclusiveRange(-18, -17));
    }
    for (final Property property in results.properties) {
      expect(property.position.latitude, inInclusiveRange(14, 15.5));
      expect(property.position.longitude, inInclusiveRange(-18, -17));
    }
  });
}
