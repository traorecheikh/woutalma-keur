import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_keur/app/data/repositories/in_memory_repositories.dart';
import 'package:woutalma_keur/app/data/seed/demo_seed.dart';
import 'package:woutalma_keur/app/domain/discovery.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/ranking.dart';
import 'package:woutalma_keur/app/domain/repositories.dart';
import 'package:woutalma_keur/app/domain/review_eligibility.dart';

void main() {
  late InMemoryStore store;
  late DiscoveryService discovery;
  late PropertyRepository propertyRepo;
  late ContactRepository contactRepo;
  late SeedRepository seedRepo;

  const GeoPoint plateau = DemoSeed.clientPosition;

  setUp(() async {
    store = InMemoryStore();
    propertyRepo = InMemoryPropertyRepository(store);
    contactRepo = InMemoryContactRepository(
      store,
      now: () => DateTime.utc(2026, 7, 1, 10),
    );
    seedRepo = InMemorySeedRepository(store);
    discovery = DiscoveryService(
      brokers: InMemoryBrokerRepository(store),
      properties: propertyRepo,
      reviews: InMemoryReviewRepository(store),
    );
    await seedRepo.loadDemoSeed();
  });

  group('seed', () {
    test('est idempotent : charger deux fois ne duplique rien', () async {
      final int once = await seedRepo.itemCount();
      await seedRepo.loadDemoSeed();

      expect(await seedRepo.itemCount(), once);
    });

    test('la purge vide tout', () async {
      await seedRepo.clearAll();
      expect(await seedRepo.itemCount(), 0);
    });

    test('couvre les cas pénibles, pas seulement le cas nominal', () async {
      final List<Property> all = await propertyRepo.all();
      final List<Review> reviews = await InMemoryReviewRepository(store).all();

      expect(
        all.any((Property p) => p.status == PropertyStatus.reserved),
        isTrue,
      );
      expect(
        all.any((Property p) => p.status == PropertyStatus.closed),
        isTrue,
      );
      expect(reviews.any((Review r) => !r.isPublic), isTrue);
    });

    test('donne des photos aux biens visibles', () async {
      final List<Property> visible = await propertyRepo.discoverable();

      expect(visible, isNotEmpty);
      expect(visible.every((Property p) => p.photoAssets.isNotEmpty), isTrue);
    });
  });

  group('découverte', () {
    test('un bien clos sort de la recherche', () async {
      final List<Property> visible = await discovery.findProperties(
        from: plateau,
      );

      expect(visible.any((Property p) => p.id == 'prp-006'), isFalse);
      // Mais il reste dans la gestion du courtier.
      final List<Property> owned = await propertyRepo.byBroker('brk-fatou');
      expect(owned.any((Property p) => p.id == 'prp-006'), isTrue);
    });

    test('un bien réservé reste visible avec son statut', () async {
      final List<Property> visible = await discovery.findProperties(
        from: plateau,
      );

      final Property reserved = visible.firstWhere(
        (Property p) => p.id == 'prp-002',
      );
      expect(reserved.status, PropertyStatus.reserved);
    });

    test('les biens sont triés du plus proche au plus loin', () async {
      final List<Property> visible = await discovery.findProperties(
        from: plateau,
      );

      for (int i = 1; i < visible.length; i++) {
        final double previous = distanceMeters(
          plateau,
          visible[i - 1].position,
        );
        final double current = distanceMeters(plateau, visible[i].position);
        expect(current, greaterThanOrEqualTo(previous));
      }
    });

    test('le filtre de transaction ne garde que la vente', () async {
      final List<Property> sales = await discovery.findProperties(
        from: plateau,
        filters: const DiscoveryFilters(transaction: TransactionKind.sale),
      );

      expect(sales, isNotEmpty);
      expect(
        sales.every((Property p) => p.transaction == TransactionKind.sale),
        isTrue,
      );
    });

    test('la recherche texte ignore accents et casse', () async {
      final List<BrokerListing> found = await discovery.findBrokers(
        from: plateau,
        // Ni majuscule, ni accent, ni trait d'union correct.
        filters: const DiscoveryFilters(query: 'sacre-c'),
      );

      expect(
        found.map((BrokerListing l) => l.broker.id),
        contains('brk-teranga'),
      );
    });

    test('la recherche comprend les mots métier et le quartier', () async {
      final List<Property> found = await discovery.findProperties(
        from: plateau,
        filters: const DiscoveryFilters(query: 'appart à louer mermoz'),
      );

      expect(found.map((Property p) => p.id), <String>['prp-003']);
    });

    test('une faute courte garde la suggestion utile', () async {
      final List<String> suggestions = await discovery.suggestions(
        from: plateau,
        filters: const DiscoveryFilters(query: 'Mermozz'),
      );

      expect(suggestions.first, 'Mermoz');
    });

    test('une recherche par intention filtre aussi les courtiers', () async {
      final List<BrokerListing> found = await discovery.findBrokers(
        from: plateau,
        filters: const DiscoveryFilters(query: 'terrain à vendre'),
      );

      expect(
        found.map((BrokerListing l) => l.broker.id),
        containsAll(<String>['brk-awa', 'brk-keur-massar']),
      );
      expect(
        found.any((BrokerListing l) => l.broker.id == 'brk-moussa'),
        isFalse,
      );
    });

    test('le profil épinglé arrive en tête et reste identifiable', () async {
      final List<BrokerListing> found = await discovery.findBrokers(
        from: plateau,
      );

      expect(found.first.broker.id, 'brk-teranga');
      expect(found.first.broker.pinned, isTrue);
    });

    test('un rayon serré exclut les courtiers lointains', () async {
      final List<BrokerListing> near = await discovery.findBrokers(
        from: plateau,
        filters: const DiscoveryFilters(radiusMeters: 5000),
      );

      expect(
        near.any((BrokerListing l) => l.broker.id == 'brk-keur-massar'),
        isFalse,
      );
      expect(
        near.any((BrokerListing l) => l.broker.id == 'brk-moussa'),
        isTrue,
      );
    });

    test('un avis en modération ne compte pas dans la note publique', () async {
      final List<BrokerListing> found = await discovery.findBrokers(
        from: plateau,
      );
      final BrokerListing fatou = found.firstWhere(
        (BrokerListing l) => l.broker.id == 'brk-fatou',
      );

      // rev-006 publié à 5, rev-007 à 2 encore en modération.
      expect(fatou.reviewCount, 1);
      expect(fatou.averageRating, 5);
    });

    test('un seul avis à 5 ne hisse pas devant un profil établi', () async {
      final List<BrokerListing> found = await discovery.findBrokers(
        from: plateau,
      );
      final int awa = found.indexWhere(
        (BrokerListing l) => l.broker.id == 'brk-awa',
      );
      final int moussa = found.indexWhere(
        (BrokerListing l) => l.broker.id == 'brk-moussa',
      );

      expect(moussa, lessThan(awa));
    });
  });

  group('éligibilité à noter', () {
    late ReviewEligibilityService eligibility;

    setUp(() => eligibility = ReviewEligibilityService(contactRepo));

    test('un échange confirmé et non consommé ouvre l\'avis', () async {
      final ReviewPermission permission = await eligibility.forContact(
        'ctc-002',
      );

      expect(permission, isA<ReviewAllowed>());
    });

    test('un contact déjà noté est refusé', () async {
      final ReviewPermission permission = await eligibility.forContact(
        'ctc-001',
      );

      expect(
        (permission as ReviewDenied).reason,
        ReviewRefusal.alreadyReviewed,
      );
    });

    test('sans réponse, pas d\'avis', () async {
      final ReviewPermission permission = await eligibility.forContact(
        'ctc-003',
      );

      expect((permission as ReviewDenied).reason, ReviewRefusal.notReached);
    });

    test('un contact inconnu est refusé', () async {
      final ReviewPermission permission = await eligibility.forContact('nope');

      expect((permission as ReviewDenied).reason, ReviewRefusal.noContact);
    });

    test('noter sans avoir jamais contacté est impossible', () async {
      final ReviewPermission permission = await eligibility.forBroker(
        'brk-keur-massar',
      );

      expect((permission as ReviewDenied).reason, ReviewRefusal.noContact);
    });

    test('un contact journalisé ne suffit pas : il faut l\'échange', () async {
      final ContactLog fresh = await contactRepo.log(
        brokerId: 'brk-keur-massar',
        channel: ContactChannel.call,
      );

      expect(fresh.allowsReview, isFalse);
      expect(
        ((await eligibility.forBroker('brk-keur-massar')) as ReviewDenied)
            .reason,
        ReviewRefusal.notReached,
      );

      // Une fois l'échange confirmé, l'avis s'ouvre.
      await contactRepo.update(fresh.copyWith(outcome: ContactOutcome.reached));
      expect(
        await eligibility.forBroker('brk-keur-massar'),
        isA<ReviewAllowed>(),
      );
    });
  });
}
