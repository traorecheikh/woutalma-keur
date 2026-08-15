import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_keur/app/data/repositories/in_memory_repositories.dart';
import 'package:woutalma_keur/app/data/seed/demo_seed.dart';
import 'package:woutalma_keur/app/domain/contact_launcher.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/repositories.dart';
import 'package:woutalma_keur/app/modules/client/broker/broker_view_model.dart';

/// Dépôt d'avis qui note comment on l'a interrogé, et rend tout ce qu'il a
/// quand on ne lui demande pas de filtrer — comme le serveur.
class _RecordingReviews implements ReviewRepository {
  _RecordingReviews(this._reviews);

  final List<Review> _reviews;
  bool? askedOnlyPublic;

  @override
  Future<List<Review>> all() async => _reviews;

  @override
  Future<List<Review>> byBroker(
    String brokerId, {
    bool onlyPublic = true,
  }) async {
    askedOnlyPublic = onlyPublic;
    return _reviews
        .where(
          (Review r) => r.brokerId == brokerId && (!onlyPublic || r.isPublic),
        )
        .toList();
  }

  @override
  Future<Review> save(Review review) async => review;

  @override
  Future<void> saveAll(List<Review> reviews) async {}

  @override
  Future<Review> reply(String reviewId, String reply) async {
    throw UnimplementedError('non utilisé par ce test');
  }

  @override
  Future<Review> report(String reviewId, {String? reason}) async {
    throw UnimplementedError('non utilisé par ce test');
  }
}

class _NoopLauncher implements ContactLauncher {
  @override
  Future<bool> open(ContactChannel channel, Broker broker) async => true;
}

Review _review({
  required String id,
  required int rating,
  required ModerationStatus moderation,
}) => Review(
  id: id,
  brokerId: 'brk-teranga',
  contactId: 'ctc-$id',
  rating: rating,
  moderation: moderation,
  createdAt: DateTime(2026, 1, 1),
);

void main() {
  late InMemoryStore store;

  setUp(() async {
    store = InMemoryStore();
    await InMemorySeedRepository(store).loadDemoSeed();
  });

  BrokerViewModel modelWith(_RecordingReviews reviews) => BrokerViewModel(
    brokerId: 'brk-teranga',
    brokers: InMemoryBrokerRepository(store),
    properties: InMemoryPropertyRepository(store),
    reviews: reviews,
    contact: ContactService(
      contacts: InMemoryContactRepository(
        store,
        now: () => DateTime(2026, 1, 1),
      ),
      launcher: _NoopLauncher(),
    ),
    from: DemoSeed.clientPosition,
  );

  test('C02 demande explicitement les avis publics', () async {
    final _RecordingReviews reviews = _RecordingReviews(const <Review>[]);
    final BrokerViewModel model = modelWith(reviews);
    addTearDown(model.dispose);

    await model.load();

    // Sans ce `true`, l'implémentation distante prenait sa propre valeur par
    // défaut et le serveur rendait aussi les avis PENDING et REJECTED.
    expect(reviews.askedOnlyPublic, isTrue);
  });

  test('un avis en modération ne pèse pas dans la note publique', () async {
    final _RecordingReviews reviews = _RecordingReviews(<Review>[
      _review(id: 'r1', rating: 5, moderation: ModerationStatus.published),
      _review(id: 'r2', rating: 1, moderation: ModerationStatus.pending),
      _review(id: 'r3', rating: 1, moderation: ModerationStatus.rejected),
    ]);
    final BrokerViewModel model = modelWith(reviews);
    addTearDown(model.dispose);

    await model.load();

    final BrokerDetail detail = model.state.valueOrNull!;
    expect(detail.reviews.map((Review r) => r.id), <String>['r1']);
    // 5, et non 2,33 : une note publique ne se fabrique pas avec des avis que
    // personne n'a validés.
    expect(detail.averageRating, 5);
  });
}
