import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_keur/app/data/repositories/in_memory_repositories.dart';
import 'package:woutalma_keur/app/data/seed/demo_seed.dart';
import 'package:woutalma_keur/app/domain/discovery.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/repositories.dart';
import 'package:woutalma_keur/app/modules/broker/broker_reviews_screen.dart';

void main() {
  late InMemoryStore store;
  late ReviewRepository reviews;
  late BrokerReviewsViewModel model;

  setUp(() async {
    store = InMemoryStore();
    reviews = InMemoryReviewRepository(store);
    await InMemorySeedRepository(store).loadDemoSeed();
    model = BrokerReviewsViewModel(reviews: reviews, brokerId: 'brk-fatou');
    await model.load();
  });

  Review byId(String id) =>
      model.state.valueOrNull!.firstWhere((Review r) => r.id == id);

  test('le courtier voit aussi ses avis en modération', () async {
    final List<Review> all = model.state.valueOrNull!;

    // rev-007 est en modération : invisible du client, visible ici pour que
    // le courtier puisse le signaler.
    expect(all.any((Review r) => r.id == 'rev-007'), isTrue);
    expect(all.any((Review r) => r.id == 'rev-006'), isTrue);
  });

  test('répondre ne change ni la note ni le commentaire', () async {
    final Review before = byId('rev-006');

    await model.reply(before, 'Merci beaucoup pour votre confiance.');

    final Review after = byId('rev-006');
    expect(after.brokerReply, 'Merci beaucoup pour votre confiance.');
    // Ce qui fonde la réputation ne bouge pas.
    expect(after.rating, before.rating);
    expect(after.comment, before.comment);
    expect(after.moderation, before.moderation);
    expect(after.createdAt, before.createdAt);
  });

  test('une réponse vide n\'est pas publiée', () async {
    await model.reply(byId('rev-006'), '   ');

    expect(byId('rev-006').brokerReply, isNull);
  });

  test('signaler ne masque pas l\'avis tout de suite', () async {
    final Review target = byId('rev-006');
    expect(target.isPublic, isTrue);

    await model.report(target);

    // Le statut repasse en modération, mais le contenu et la note restent
    // intacts : un signalement n'est pas une gomme.
    final Review after = byId('rev-006');
    expect(after.rating, target.rating);
    expect(after.comment, target.comment);
  });

  test(
    'un avis signalé sort de la note publique le temps de l\'examen',
    () async {
      final DiscoveryService discovery = DiscoveryService(
        brokers: InMemoryBrokerRepository(store),
        properties: InMemoryPropertyRepository(store),
        reviews: reviews,
      );

      final List<BrokerListing> before = await discovery.findBrokers(
        from: DemoSeed.clientPosition,
      );
      expect(
        before
            .firstWhere((BrokerListing l) => l.broker.id == 'brk-fatou')
            .reviewCount,
        1,
      );

      await model.report(byId('rev-006'));

      final List<BrokerListing> after = await discovery.findBrokers(
        from: DemoSeed.clientPosition,
      );
      expect(
        after
            .firstWhere((BrokerListing l) => l.broker.id == 'brk-fatou')
            .reviewCount,
        0,
      );
    },
  );

  test('un courtier sans avis obtient un état vide, pas une erreur', () async {
    final BrokerReviewsViewModel empty = BrokerReviewsViewModel(
      reviews: reviews,
      brokerId: 'brk-keur-massar',
    );

    await empty.load();

    expect(empty.state.isResolved, isTrue);
    expect(empty.state.valueOrNull, isNull);
  });
}
