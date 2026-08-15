import 'package:dio/dio.dart';
import 'package:woutalma_keur/app/data/local/cache_status.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/repositories.dart';

/// Politique hors ligne : réseau d'abord, copie locale en secours.
///
/// Décorateurs plutôt que du cache glissé dans `Remote*Repository` : les
/// classes distantes restent du HTTP pur (testables avec un faux adaptateur
/// Dio, sans base) et les classes Isar restent du stockage pur. La politique
/// vit dans un seul fichier au lieu d'être étalée sur quatre classes.
///
/// Les règles, dans l'ordre :
///
/// 1. Appeler le serveur. En cas de succès, recopier localement et rendre la
///    donnée fraîche. L'index `uid` des lignes Isar est `unique, replace`,
///    donc la recopie est idempotente et ne duplique rien.
/// 2. Panne de transport ou 5xx : lire la copie locale. Non vide, on la rend
///    en signalant qu'elle est datée.
/// 3. Copie vide : **relancer l'erreur**. Pas de copie veut dire écran
///    d'erreur explicite, jamais une donnée inventée.
/// 4. Tout autre 4xx : relancer sans regarder le cache. Un 401 n'est pas une
///    coupure réseau, et servir une copie datée masquerait une session
///    expirée.
///
/// Aucune durée de péremption : tant qu'il y a du réseau on interroge toujours
/// le serveur d'abord, donc la copie n'est jamais la référence. `fetchedAt`
/// ne sert qu'à dire à l'utilisateur de quand date ce qu'il lit.
/// Vrai quand l'échec est une coupure et non un refus du serveur.
///
/// Partagé avec `cached_discovery.dart` : les deux doivent trancher de la même
/// façon, sinon la découverte se rabattrait sur le cache là où les dépôts
/// remonteraient l'erreur.
bool isOfflineFailure(Object error) => _isOffline(error);

bool _isOffline(Object error) {
  if (error is! DioException) {
    return false;
  }
  switch (error.type) {
    case DioExceptionType.connectionError:
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.sendTimeout:
      return true;
    case DioExceptionType.badResponse:
      final int? status = error.response?.statusCode;
      return status != null && status >= 500;
    default:
      // `unknown` couvre les échecs de résolution DNS et de socket sur mobile.
      return error.error is Exception && error.response == null;
  }
}

/// Exécute la lecture distante, recopie, et se rabat si le réseau lâche.
Future<T> _readThrough<T>({
  required Future<T> Function() remote,
  required Future<void> Function(T value) writeThrough,
  required Future<T> Function() cached,
  required bool Function(T value) isEmpty,
  required CacheStatus status,
  required DateTime Function() now,
}) async {
  try {
    final T fresh = await remote();
    await writeThrough(fresh);
    status.markFresh(now());
    return fresh;
  } catch (error) {
    if (!_isOffline(error)) {
      rethrow;
    }
    final T fallback = await cached();
    if (isEmpty(fallback)) {
      rethrow;
    }
    status.markStale(status.fetchedAt);
    return fallback;
  }
}

class CachedBrokerRepository implements BrokerRepository {
  CachedBrokerRepository({
    required BrokerRepository remote,
    required BrokerRepository cache,
    required CacheStatus status,
    DateTime Function() now = DateTime.now,
  }) : _remote = remote,
       _cache = cache,
       _status = status,
       _now = now;

  final BrokerRepository _remote;
  final BrokerRepository _cache;
  final CacheStatus _status;
  final DateTime Function() _now;

  @override
  Future<List<Broker>> all() => _readThrough<List<Broker>>(
    remote: _remote.all,
    writeThrough: _cache.saveAll,
    cached: _cache.all,
    isEmpty: (List<Broker> brokers) => brokers.isEmpty,
    status: _status,
    now: _now,
  );

  @override
  Future<Broker?> byId(String id) => _readThrough<Broker?>(
    remote: () => _remote.byId(id),
    writeThrough: (Broker? broker) async {
      if (broker != null) {
        await _cache.save(broker);
      }
    },
    cached: () => _cache.byId(id),
    isEmpty: (Broker? broker) => broker == null,
    status: _status,
    now: _now,
  );

  /// Écriture : pas de file d'attente hors ligne. Publier un profil que le
  /// serveur n'a pas vu donnerait à un courtier l'illusion d'être visible.
  @override
  Future<void> save(Broker broker) async {
    await _remote.save(broker);
    await _cache.save(broker);
  }

  @override
  Future<void> saveAll(List<Broker> brokers) async {
    await _remote.saveAll(brokers);
    await _cache.saveAll(brokers);
  }

  @override
  Future<Broker> requestVerification(String brokerId) async {
    final Broker updated = await _remote.requestVerification(brokerId);
    await _cache.save(updated);
    return updated;
  }
}

class CachedPropertyRepository implements PropertyRepository {
  CachedPropertyRepository({
    required PropertyRepository remote,
    required PropertyRepository cache,
    required CacheStatus status,
    DateTime Function() now = DateTime.now,
  }) : _remote = remote,
       _cache = cache,
       _status = status,
       _now = now;

  final PropertyRepository _remote;
  final PropertyRepository _cache;
  final CacheStatus _status;
  final DateTime Function() _now;

  Future<void> _writeAll(List<Property> properties) =>
      _cache.saveAll(properties);

  @override
  Future<List<Property>> all() => _readThrough<List<Property>>(
    remote: _remote.all,
    writeThrough: _writeAll,
    cached: _cache.all,
    isEmpty: (List<Property> p) => p.isEmpty,
    status: _status,
    now: _now,
  );

  @override
  Future<List<Property>> discoverable() => _readThrough<List<Property>>(
    remote: _remote.discoverable,
    writeThrough: _writeAll,
    cached: _cache.discoverable,
    isEmpty: (List<Property> p) => p.isEmpty,
    status: _status,
    now: _now,
  );

  @override
  Future<List<Property>> byBroker(
    String brokerId, {
    bool onlyDiscoverable = false,
  }) => _readThrough<List<Property>>(
    remote: () =>
        _remote.byBroker(brokerId, onlyDiscoverable: onlyDiscoverable),
    writeThrough: _writeAll,
    cached: () => _cache.byBroker(brokerId, onlyDiscoverable: onlyDiscoverable),
    isEmpty: (List<Property> p) => p.isEmpty,
    status: _status,
    now: _now,
  );

  @override
  Future<Property?> byId(String id) => _readThrough<Property?>(
    remote: () => _remote.byId(id),
    writeThrough: (Property? property) async {
      if (property != null) {
        await _cache.save(property);
      }
    },
    cached: () => _cache.byId(id),
    isEmpty: (Property? property) => property == null,
    status: _status,
    now: _now,
  );

  /// Recopie **ce que le serveur a rendu**, pas ce qu'on lui a proposé.
  ///
  /// À la publication, l'éditeur fabrique un identifiant local que le serveur
  /// ignore. Écrire le bien sous cet identifiant laissait une ligne fantôme
  /// dans la copie hors ligne : la vraie ligne arrivait plus tard sous
  /// l'identifiant du serveur et « Mes biens » montrait deux fois la même
  /// annonce.
  @override
  Future<Property> save(Property property) async {
    final Property saved = await _remote.save(property);
    await _cache.save(saved);
    return saved;
  }

  @override
  Future<void> delete(String id) async {
    await _remote.delete(id);
    await _cache.delete(id);
  }

  @override
  Future<void> saveAll(List<Property> properties) async {
    await _remote.saveAll(properties);
    await _cache.saveAll(properties);
  }
}

class CachedReviewRepository implements ReviewRepository {
  CachedReviewRepository({
    required ReviewRepository remote,
    required ReviewRepository cache,
    required CacheStatus status,
    DateTime Function() now = DateTime.now,
  }) : _remote = remote,
       _cache = cache,
       _status = status,
       _now = now;

  final ReviewRepository _remote;
  final ReviewRepository _cache;
  final CacheStatus _status;
  final DateTime Function() _now;

  Future<void> _writeAll(List<Review> reviews) => _cache.saveAll(reviews);

  @override
  Future<List<Review>> byBroker(String brokerId, {bool onlyPublic = true}) =>
      _readThrough<List<Review>>(
        remote: () => _remote.byBroker(brokerId, onlyPublic: onlyPublic),
        writeThrough: _writeAll,
        cached: () => _cache.byBroker(brokerId, onlyPublic: onlyPublic),
        isEmpty: (List<Review> r) => r.isEmpty,
        status: _status,
        now: _now,
      );

  @override
  Future<List<Review>> all() => _readThrough<List<Review>>(
    remote: _remote.all,
    writeThrough: _writeAll,
    cached: _cache.all,
    isEmpty: (List<Review> r) => r.isEmpty,
    status: _status,
    now: _now,
  );

  /// Déposer un avis hors ligne n'a pas de sens : c'est le serveur qui décide
  /// de l'éligibilité, et un avis « en attente d'envoi » qui finit refusé
  /// serait un mensonge affiché pendant des heures.
  @override
  Future<Review> save(Review review) async {
    final Review saved = await _remote.save(review);
    await _cache.save(saved);
    return saved;
  }

  @override
  Future<void> saveAll(List<Review> reviews) async {
    await _remote.saveAll(reviews);
    await _cache.saveAll(reviews);
  }

  @override
  Future<Review> reply(String reviewId, String reply) async {
    final Review replied = await _remote.reply(reviewId, reply);
    await _cache.save(replied);
    return replied;
  }

  @override
  Future<Review> report(String reviewId, {String? reason}) async {
    final Review reported = await _remote.report(reviewId, reason: reason);
    await _cache.save(reported);
    return reported;
  }
}

class CachedContactRepository implements ContactRepository {
  CachedContactRepository({
    required ContactRepository remote,
    required ContactRepository cache,
    required CacheStatus status,
    DateTime Function() now = DateTime.now,
  }) : _remote = remote,
       _cache = cache,
       _status = status,
       _now = now;

  final ContactRepository _remote;
  final ContactRepository _cache;
  final CacheStatus _status;
  final DateTime Function() _now;

  @override
  Future<List<ContactLog>> all() => _readThrough<List<ContactLog>>(
    remote: _remote.all,
    writeThrough: _cache.updateAll,
    cached: _cache.all,
    isEmpty: (List<ContactLog> c) => c.isEmpty,
    status: _status,
    now: _now,
  );

  @override
  Future<ContactLog?> byId(String id) => _readThrough<ContactLog?>(
    remote: () => _remote.byId(id),
    writeThrough: (ContactLog? contact) async {
      if (contact != null) {
        await _cache.update(contact);
      }
    },
    cached: () => _cache.byId(id),
    isEmpty: (ContactLog? contact) => contact == null,
    status: _status,
    now: _now,
  );

  /// Journalise côté serveur **avant** l'ouverture du canal externe, comme le
  /// contrat l'exige. Pas de repli hors ligne : la trace doit exister là où
  /// l'avis sera plus tard autorisé, c'est-à-dire sur le serveur.
  @override
  Future<ContactLog> log({
    required String brokerId,
    String? propertyId,
    required ContactChannel channel,
  }) async {
    final ContactLog logged = await _remote.log(
      brokerId: brokerId,
      propertyId: propertyId,
      channel: channel,
    );
    await _cache.update(logged);
    return logged;
  }

  @override
  Future<void> update(ContactLog contact) async {
    await _remote.update(contact);
    await _cache.update(contact);
  }

  @override
  Future<void> updateAll(List<ContactLog> contacts) async {
    await _remote.updateAll(contacts);
    await _cache.updateAll(contacts);
  }

  @override
  Future<List<ContactLog>> receivedBy(String brokerId) =>
      _readThrough<List<ContactLog>>(
        remote: () => _remote.receivedBy(brokerId),
        writeThrough: _cache.updateAll,
        cached: () => _cache.receivedBy(brokerId),
        isEmpty: (List<ContactLog> c) => c.isEmpty,
        status: _status,
        now: _now,
      );
}

/// En mode distant, « purger » veut dire vider la copie hors ligne, pas
/// recharger un jeu de démonstration. Recharger le seed écrirait des lignes
/// inventées dans ce qui prétend être une copie du serveur.
class CacheSeedRepository implements SeedRepository {
  const CacheSeedRepository(this._cache);

  final SeedRepository _cache;

  @override
  Future<void> clearAll() => _cache.clearAll();

  @override
  Future<int> itemCount() => _cache.itemCount();

  @override
  Future<void> loadDemoSeed() {
    throw UnsupportedError(
      'Le jeu de démonstration ne se charge pas par-dessus des données serveur.',
    );
  }
}
