import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/data/repositories/in_memory_repositories.dart';
import 'package:woutalma_keur/app/data/seed/demo_seed.dart';
import 'package:woutalma_keur/app/domain/discovery.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/ranking.dart';
import 'package:woutalma_keur/app/domain/repositories.dart';
import 'package:woutalma_keur/app/domain/location_service.dart';
import 'package:woutalma_keur/app/domain/voice_service.dart';
import 'package:woutalma_keur/app/modules/client/explore/explore_screen.dart';
import 'package:woutalma_keur/app/modules/client/explore/explore_view_model.dart';
import 'package:woutalma_keur/app/modules/client/explore/search_overlay.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_broker_card.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_property_card.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_property_photo.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_search_bar.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_states.dart';

import '../support/hardcoded_text.dart';
import '../support/pump.dart';

void main() {
  late InMemoryStore store;
  late DiscoveryService discovery;
  late SeedRepository seed;

  setUp(() async {
    store = InMemoryStore();
    seed = InMemorySeedRepository(store);
    discovery = DiscoveryService(
      brokers: InMemoryBrokerRepository(store),
      properties: InMemoryPropertyRepository(store),
      reviews: InMemoryReviewRepository(store),
    );
    await seed.loadDemoSeed();
  });

  Future<ExploreViewModel> pumpExplore(
    WidgetTester tester, {
    void Function(String)? onOpenBroker,
    double textScale = 1,
    Size surfaceSize = const Size(360, 800),
  }) async {
    final ExploreViewModel model = ExploreViewModel(
      discovery: discovery,
      position: DemoSeed.clientPosition,
    );
    addTearDown(model.dispose);

    await pumpWk(
      tester,
      ChangeNotifierProvider<ExploreViewModel>.value(
        value: model,
        child: ExploreScreen(
          onOpenBroker: onOpenBroker ?? (String _) {},
          onOpenProperty: (String _) {},
          onOpenSettings: () {},
          voice: SimulatedVoiceService(),
          location: _FixedLocationService(),
        ),
      ),
      textScale: textScale,
      surfaceSize: surfaceSize,
    );

    await model.load();
    await tester.pumpAndSettle();
    return model;
  }

  testWidgets('affiche les courtiers classés, épinglé en tête', (
    WidgetTester tester,
  ) async {
    await pumpExplore(tester);

    expect(find.byType(WkBrokerCard), findsWidgets);
    final WkBrokerCard first = tester.widget<WkBrokerCard>(
      find.byType(WkBrokerCard).first,
    );
    expect(first.listing.broker.id, 'brk-teranga');
  });

  testWidgets('un profil épinglé est signalé comme tel', (
    WidgetTester tester,
  ) async {
    await pumpExplore(tester);

    // Sinon il se confond avec un bon classement organique.
    expect(find.text('Mis en avant'), findsOneWidget);
  });

  // Tant qu'un courtier n'a pas déposé sa photo, l'identité tient dans ses
  // initiales : une silhouette générique donnerait la même vignette aux six
  // courtiers de la liste.
  testWidgets('un courtier sans photo est identifié par ses initiales', (
    WidgetTester tester,
  ) async {
    await pumpExplore(tester);

    expect(find.text('MN'), findsOneWidget);
    expect(find.text('AT'), findsOneWidget);
  });

  testWidgets('changer de segment ne réinitialise pas la recherche', (
    WidgetTester tester,
  ) async {
    final ExploreViewModel model = await pumpExplore(tester);

    model.search('Mermoz');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    model.selectSegment(ExploreSegment.properties);
    await tester.pumpAndSettle();

    expect(model.filters.query, 'Mermoz');
    expect(find.byType(WkPropertyCard), findsWidgets);
  });

  testWidgets('les biens en recherche montrent photo et compteur galerie', (
    WidgetTester tester,
  ) async {
    final ExploreViewModel model = await pumpExplore(tester);

    model.selectSegment(ExploreSegment.properties);
    await tester.pumpAndSettle();

    expect(find.byType(WkPropertyPhoto), findsWidgets);
    expect(find.textContaining('1/'), findsWidgets);
  });

  // La recherche est devenue un écran : C01 n'expose plus qu'un déclencheur,
  // et le clavier n'apparaît que si on le demande.
  testWidgets('C01 ne montre aucun champ de saisie tant qu\'on ne cherche pas', (
    WidgetTester tester,
  ) async {
    await pumpExplore(tester);

    expect(find.byType(TextField), findsNothing);
    expect(find.byType(WkSearchTrigger), findsOneWidget);
  });

  testWidgets('la barre ouvre l\'écran de recherche, un quartier suggéré la lance', (
    WidgetTester tester,
  ) async {
    final ExploreViewModel model = await pumpExplore(tester);

    expect(model.searchSuggestions, contains('Maison'));

    await tester.tap(find.byType(WkSearchTrigger));
    await tester.pumpAndSettle();
    expect(find.byType(SearchOverlay), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Mer');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.text('Mermoz'), findsOneWidget);

    await tester.tap(find.text('Mermoz'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(model.filters.query, 'Mermoz');
    expect(model.searchSuggestions, isNotEmpty);

    // Fermer l'écran de recherche rend la requête visible sur C01.
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.byType(SearchOverlay), findsNothing);
    expect(find.text('Mermoz'), findsWidgets);
  });

  // Test simple et non widget : l'anti-rebond repose sur un vrai Timer, et
  // l'horloge de `testWidgets` est simulée — elle ne le ferait jamais partir.
  test('trois frappes rapprochées ne lancent qu\'une recherche', () async {
    final _CountingDiscovery counting = _CountingDiscovery(discovery);
    final ExploreViewModel model = ExploreViewModel(
      discovery: counting,
      position: DemoSeed.clientPosition,
    );
    addTearDown(model.dispose);

    await model.load();
    final int afterLoad = counting.brokerCalls;

    model
      ..search('a')
      ..search('ap')
      ..search('app');
    await Future<void>.delayed(const Duration(milliseconds: 500));

    expect(counting.brokerCalls - afterLoad, 1);
  });

  testWidgets('une recherche sans résultat propose une sortie', (
    WidgetTester tester,
  ) async {
    final ExploreViewModel model = await pumpExplore(tester);

    model.search('zzzzzz');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.byType(WkEmptyState), findsOneWidget);
  });

  testWidgets('les filtres appliqués restent visibles et retirables', (
    WidgetTester tester,
  ) async {
    final ExploreViewModel model = await pumpExplore(tester);

    await model.applyFilters(
      const DiscoveryFilters(
        transaction: TransactionKind.rent,
        kind: PropertyKind.apartment,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('À louer'), findsOneWidget);
    expect(find.text('Appartement'), findsOneWidget);

    await tester.tap(find.text('Appartement'));
    await tester.pumpAndSettle();

    expect(model.filters.kind, isNull);
    expect(model.filters.transaction, TransactionKind.rent);
  });

  testWidgets('toucher une carte ouvre la fiche du bon courtier', (
    WidgetTester tester,
  ) async {
    String? opened;
    await pumpExplore(tester, onOpenBroker: (String id) => opened = id);

    await tester.tap(find.byType(WkBrokerCard).first);
    await tester.pump();

    expect(opened, 'brk-teranga');
  });

  testWidgets('aucun texte visible n\'est écrit en dur', (
    WidgetTester tester,
  ) async {
    await pumpExplore(tester);

    // Les noms de courtiers viennent du seed : ce sont des données, pas de la
    // copie. Le test les déclare explicitement plutôt que de les tolérer en
    // silence.
    expectNoHardcodedText(
      tester,
      data: <String>{
        'Agence Teranga Immo',
        'Moussa Ndiaye',
        'Fatou Sarr',
        'Mermoz',
        'Plateau',
        'Sacré-Cœur',
      },
    );
  });

  testWidgets('la carte est atteignable depuis la liste', (
    WidgetTester tester,
  ) async {
    // `ExploreView.map` et `ResultsMap` existaient, testés unitairement, mais
    // aucun élément de l'écran n'appelait `selectView` : la carte était
    // inaccessible à qui utilise l'application.
    final ExploreViewModel model = await pumpExplore(tester);
    expect(model.view, ExploreView.list);

    await tester.tap(find.text('Carte'));
    await tester.pump();

    expect(model.view, ExploreView.map);
    expect(find.text('Liste'), findsOneWidget);
  });

  testWidgets('à ×1.3 rien ne déborde', (WidgetTester tester) async {
    await pumpExplore(tester, textScale: 1.3);

    expect(tester.takeException(), isNull);
  });

  testWidgets('le dock de recherche reste dans la largeur du téléphone', (
    WidgetTester tester,
  ) async {
    await pumpExplore(tester, surfaceSize: const Size(320, 800));

    for (final Finder finder in <Finder>[
      find.text('Quartier'),
      find.text('Filtres'),
      find.text('Quartier, courtier ou bien'),
    ]) {
      final Rect rect = tester.getRect(finder);
      expect(rect.left, greaterThanOrEqualTo(0));
      expect(rect.right, lessThanOrEqualTo(320));
    }
  });
}

/// Position figée : un test ne demande jamais une vraie autorisation.
class _FixedLocationService implements LocationService {
  @override
  Future<LocationResult> current() async =>
      const LocationFound(DemoSeed.clientPosition);

  @override
  Future<void> openSettings() async {}

  @override
  List<Neighbourhood> knownNeighbourhoods() => dakarNeighbourhoods;
}

/// Compte les appels au service pour prouver l'anti-rebond.
class _CountingDiscovery implements DiscoveryService {
  _CountingDiscovery(this._inner);

  final DiscoveryService _inner;
  int brokerCalls = 0;

  @override
  Future<List<BrokerListing>> findBrokers({
    required GeoPoint from,
    DiscoveryFilters filters = const DiscoveryFilters(),
  }) {
    brokerCalls++;
    return _inner.findBrokers(from: from, filters: filters);
  }

  @override
  Future<List<Property>> findProperties({
    required GeoPoint from,
    DiscoveryFilters filters = const DiscoveryFilters(),
  }) => _inner.findProperties(from: from, filters: filters);

  @override
  Future<List<String>> suggestions({
    required GeoPoint from,
    DiscoveryFilters filters = const DiscoveryFilters(),
    int limit = 5,
  }) => _inner.suggestions(from: from, filters: filters, limit: limit);

  @override
  BrokerRepository get brokers => _inner.brokers;

  @override
  PropertyRepository get properties => _inner.properties;

  @override
  ReviewRepository get reviews => _inner.reviews;

  @override
  RankingService get ranking => _inner.ranking;
}
