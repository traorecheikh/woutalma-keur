import 'package:isar_community/isar.dart';
import 'package:woutalma_keur/app/data/local/isar_rows.dart';
import 'package:woutalma_keur/app/data/seed/demo_seed.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/repositories.dart';

/// Implémentations persistantes des contrats de `repositories.dart`.
///
/// Aucun écran ne sait qu'Isar existe : ces classes remplacent les
/// implémentations mémoire sans qu'un widget bouge.
class IsarBrokerRepository implements BrokerRepository {
  const IsarBrokerRepository(this._isar);

  final Isar _isar;

  @override
  Future<List<Broker>> all() async {
    final List<BrokerRow> rows = await _isar.brokerRows.where().findAll();
    return rows.map((BrokerRow r) => r.toDomain()).toList();
  }

  @override
  Future<Broker?> byId(String id) async {
    final BrokerRow? row = await _isar.brokerRows
        .filter()
        .uidEqualTo(id)
        .findFirst();
    return row?.toDomain();
  }

  @override
  Future<void> save(Broker broker) async {
    await _isar.writeTxn(
      () => _isar.brokerRows.put(BrokerRow.fromDomain(broker)),
    );
  }

  @override
  Future<Broker> requestVerification(String brokerId) async {
    final Broker? broker = await byId(brokerId);
    if (broker == null) {
      throw StateError('Courtier $brokerId inconnu');
    }
    final Broker queued = broker.verification == VerificationStatus.verified
        ? broker
        : broker.copyWith(verification: VerificationStatus.pending);
    await save(queued);
    return queued;
  }

  @override
  Future<void> saveAll(List<Broker> brokers) async {
    if (brokers.isEmpty) {
      return;
    }
    await _isar.writeTxn(
      () => _isar.brokerRows.putAll(brokers.map(BrokerRow.fromDomain).toList()),
    );
  }
}

class IsarPropertyRepository implements PropertyRepository {
  const IsarPropertyRepository(this._isar);

  final Isar _isar;

  @override
  Future<List<Property>> all() async {
    final List<PropertyRow> rows = await _isar.propertyRows.where().findAll();
    return rows.map((PropertyRow r) => r.toDomain()).toList();
  }

  @override
  Future<List<Property>> discoverable() async {
    // Un bien clos n'est jamais renvoyé à la découverte. La règle vit ici,
    // pas dans l'écran, pour qu'aucun appelant ne puisse l'oublier.
    final List<PropertyRow> rows = await _isar.propertyRows
        .filter()
        .not()
        .statusEqualTo(PropertyStatus.closed)
        .findAll();
    return rows.map((PropertyRow r) => r.toDomain()).toList();
  }

  @override
  Future<List<Property>> byBroker(
    String brokerId, {
    bool onlyDiscoverable = false,
  }) async {
    final List<PropertyRow> rows = await _isar.propertyRows
        .filter()
        .brokerUidEqualTo(brokerId)
        .findAll();
    final Iterable<Property> mapped = rows.map((PropertyRow r) => r.toDomain());
    return onlyDiscoverable
        ? mapped.where((Property p) => p.isDiscoverable).toList()
        : mapped.toList();
  }

  @override
  Future<Property?> byId(String id) async {
    final PropertyRow? row = await _isar.propertyRows
        .filter()
        .uidEqualTo(id)
        .findFirst();
    return row?.toDomain();
  }

  @override
  Future<Property> save(Property property) async {
    await _isar.writeTxn(
      () => _isar.propertyRows.put(PropertyRow.fromDomain(property)),
    );
    // La base locale n'attribue rien : ce qui entre ressort identique.
    return property;
  }

  @override
  Future<void> saveAll(List<Property> properties) async {
    if (properties.isEmpty) {
      return;
    }
    await _isar.writeTxn(
      () => _isar.propertyRows.putAll(
        properties.map(PropertyRow.fromDomain).toList(),
      ),
    );
  }

  @override
  Future<void> delete(String id) async {
    await _isar.writeTxn(
      () => _isar.propertyRows.filter().uidEqualTo(id).deleteAll(),
    );
  }
}

class IsarReviewRepository implements ReviewRepository {
  const IsarReviewRepository(this._isar);

  final Isar _isar;

  @override
  Future<List<Review>> all() async {
    final List<ReviewRow> rows = await _isar.reviewRows.where().findAll();
    return rows.map((ReviewRow r) => r.toDomain()).toList();
  }

  @override
  Future<List<Review>> byBroker(
    String brokerId, {
    bool onlyPublic = true,
  }) async {
    final List<ReviewRow> rows = await _isar.reviewRows
        .filter()
        .brokerUidEqualTo(brokerId)
        .sortByCreatedAtDesc()
        .findAll();
    final Iterable<Review> mapped = rows.map((ReviewRow r) => r.toDomain());
    return onlyPublic
        ? mapped.where((Review r) => r.isPublic).toList()
        : mapped.toList();
  }

  @override
  Future<Review> save(Review review) async {
    await _isar.writeTxn(
      () => _isar.reviewRows.put(ReviewRow.fromDomain(review)),
    );
    // La base locale n'attribue rien : ce qui entre ressort identique.
    return review;
  }

  @override
  Future<Review> reply(String reviewId, String reply) async {
    final Review replied = (await _requireReview(
      reviewId,
    )).copyWith(brokerReply: reply);
    await save(replied);
    return replied;
  }

  @override
  Future<Review> report(String reviewId, {String? reason}) async {
    final Review reported = (await _requireReview(
      reviewId,
    )).copyWith(moderation: ModerationStatus.pending);
    await save(reported);
    return reported;
  }

  Future<Review> _requireReview(String id) async {
    final ReviewRow? row = await _isar.reviewRows
        .filter()
        .uidEqualTo(id)
        .findFirst();
    if (row == null) {
      throw StateError('Avis $id inconnu');
    }
    return row.toDomain();
  }

  @override
  Future<void> saveAll(List<Review> reviews) async {
    if (reviews.isEmpty) {
      return;
    }
    await _isar.writeTxn(
      () => _isar.reviewRows.putAll(reviews.map(ReviewRow.fromDomain).toList()),
    );
  }
}

class IsarContactRepository implements ContactRepository {
  IsarContactRepository(this._isar, {required DateTime Function() now})
    : _now = now;

  final Isar _isar;
  final DateTime Function() _now;

  @override
  Future<List<ContactLog>> all() async {
    final List<ContactRow> rows = await _isar.contactRows
        .where()
        .sortByCreatedAtDesc()
        .findAll();
    return rows.map((ContactRow r) => r.toDomain()).toList();
  }

  @override
  Future<ContactLog?> byId(String id) async {
    final ContactRow? row = await _isar.contactRows
        .filter()
        .uidEqualTo(id)
        .findFirst();
    return row?.toDomain();
  }

  @override
  Future<ContactLog> log({
    required String brokerId,
    String? propertyId,
    required ContactChannel channel,
  }) async {
    final DateTime at = _now();
    final ContactLog contact = ContactLog(
      // Horodatage en microsecondes : deux contacts ne peuvent pas collisionner
      // et l'identifiant reste trié dans l'ordre chronologique.
      id: 'ctc-${at.microsecondsSinceEpoch}',
      brokerId: brokerId,
      propertyId: propertyId,
      channel: channel,
      createdAt: at,
    );
    await _isar.writeTxn(
      () => _isar.contactRows.put(ContactRow.fromDomain(contact)),
    );
    return contact;
  }

  @override
  Future<void> update(ContactLog contact) async {
    await _isar.writeTxn(
      () => _isar.contactRows.put(ContactRow.fromDomain(contact)),
    );
  }

  @override
  Future<List<ContactLog>> receivedBy(String brokerId) async {
    final List<ContactRow> rows = await _isar.contactRows
        .filter()
        .brokerUidEqualTo(brokerId)
        .sortByCreatedAtDesc()
        .findAll();
    return rows.map((ContactRow r) => r.toDomain()).toList();
  }

  @override
  Future<void> updateAll(List<ContactLog> contacts) async {
    if (contacts.isEmpty) {
      return;
    }
    await _isar.writeTxn(
      () => _isar.contactRows.putAll(
        contacts.map(ContactRow.fromDomain).toList(),
      ),
    );
  }

  @override
  Future<void> remove(String id) async {
    await _isar.writeTxn(
      () => _isar.contactRows.filter().uidEqualTo(id).deleteAll(),
    );
  }
}

class IsarSeedRepository implements SeedRepository {
  const IsarSeedRepository(this._isar, {DemoSeed seed = const DemoSeed()})
    : _seed = seed;

  final Isar _isar;
  final DemoSeed _seed;

  @override
  Future<int> itemCount() async {
    final List<int> counts = await Future.wait<int>(<Future<int>>[
      _isar.brokerRows.count(),
      _isar.propertyRows.count(),
      _isar.reviewRows.count(),
      _isar.contactRows.count(),
    ]);
    return counts.reduce((int a, int b) => a + b);
  }

  @override
  Future<void> clearAll() async {
    await _isar.writeTxn(() async {
      await _isar.brokerRows.clear();
      await _isar.propertyRows.clear();
      await _isar.reviewRows.clear();
      await _isar.contactRows.clear();
    });
  }

  @override
  Future<void> loadDemoSeed() async {
    // Purge et chargement dans **une seule transaction** : un échec en cours
    // de route ne doit jamais laisser un demi-jeu de données.
    await _isar.writeTxn(() async {
      await _isar.brokerRows.clear();
      await _isar.propertyRows.clear();
      await _isar.reviewRows.clear();
      await _isar.contactRows.clear();

      await _isar.brokerRows.putAll(
        _seed.brokers().map(BrokerRow.fromDomain).toList(),
      );
      await _isar.propertyRows.putAll(
        _seed.properties().map(PropertyRow.fromDomain).toList(),
      );
      await _isar.reviewRows.putAll(
        _seed.reviews().map(ReviewRow.fromDomain).toList(),
      );
      await _isar.contactRows.putAll(
        _seed.contacts().map(ContactRow.fromDomain).toList(),
      );
    });
  }
}
