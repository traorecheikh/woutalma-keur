import 'package:woutalma_keur/app/data/local/cache_status.dart';
import 'package:woutalma_keur/app/data/repositories/cached_repositories.dart';
import 'package:woutalma_keur/app/domain/discovery.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/repositories.dart';

/// Recherche en ligne, classement local en secours.
///
/// `RemoteDiscoveryService` interroge `GET /search/*`, ce qui est la bonne
/// façon de chercher : PostGIS pour les distances, index GIN pour le texte.
/// Mais il ne laisse aucune trace, si bien que l'écran Explorer — le premier
/// écran de l'application — était le seul à n'avoir aucune version hors ligne,
/// alors même que les dépôts en gardent une.
///
/// Deux gestes, donc :
///
/// 1. **Recopier.** Chaque réponse du serveur écrit ses courtiers et ses biens
///    dans la base locale, en un lot par collection.
/// 2. **Reclasser sur place.** Réseau coupé, on rejoue la même recherche avec
///    [LocalDiscoveryService] sur ce qui a été recopié. Le portage SQL du
///    classement et sa version Dart sont comparés par les tests des deux côtés,
///    donc l'ordre reste celui que l'utilisateur avait sous les yeux.
///
/// Ce qui n'est pas promis : un résultat hors ligne aussi complet qu'en ligne.
/// On ne classe que ce qui a déjà été vu. Une base locale vide relance
/// l'erreur, comme partout ailleurs — jamais une liste vide qui ressemblerait
/// à « aucun courtier près de vous ».
class CachedDiscoveryService implements DiscoveryService {
  CachedDiscoveryService({
    required DiscoveryService remote,
    required BrokerRepository brokerCache,
    required PropertyRepository propertyCache,
    required ReviewRepository reviewCache,
    required CacheStatus status,
    DateTime Function() now = DateTime.now,
  }) : _remote = remote,
       _brokers = brokerCache,
       _properties = propertyCache,
       _status = status,
       _now = now,
       _local = LocalDiscoveryService(
         brokers: brokerCache,
         properties: propertyCache,
         reviews: reviewCache,
       );

  final DiscoveryService _remote;
  final DiscoveryService _local;
  final BrokerRepository _brokers;
  final PropertyRepository _properties;
  final CacheStatus _status;
  final DateTime Function() _now;

  @override
  Future<List<BrokerListing>> findBrokers({
    required GeoPoint from,
    DiscoveryFilters filters = const DiscoveryFilters(),
  }) async {
    try {
      final List<BrokerListing> fresh = await _remote.findBrokers(
        from: from,
        filters: filters,
      );
      await _brokers.saveAll(fresh.map((BrokerListing l) => l.broker).toList());
      _status.markFresh(_now());
      return fresh;
    } catch (error) {
      if (!isOfflineFailure(error)) {
        rethrow;
      }
      final List<BrokerListing> cached = await _local.findBrokers(
        from: from,
        filters: filters,
      );
      if (cached.isEmpty) {
        rethrow;
      }
      _status.markStale(_status.fetchedAt);
      return cached;
    }
  }

  @override
  Future<List<Property>> findProperties({
    required GeoPoint from,
    DiscoveryFilters filters = const DiscoveryFilters(),
  }) async {
    try {
      final List<Property> fresh = await _remote.findProperties(
        from: from,
        filters: filters,
      );
      await _properties.saveAll(fresh);
      _status.markFresh(_now());
      return fresh;
    } catch (error) {
      if (!isOfflineFailure(error)) {
        rethrow;
      }
      final List<Property> cached = await _local.findProperties(
        from: from,
        filters: filters,
      );
      if (cached.isEmpty) {
        rethrow;
      }
      _status.markStale(_status.fetchedAt);
      return cached;
    }
  }

  /// Les suggestions ne méritent pas une erreur : elles aident la frappe, elles
  /// ne portent pas l'écran. Hors ligne, celles tirées du cache suffisent, et
  /// une liste vide est une réponse acceptable.
  @override
  Future<List<String>> suggestions({
    required GeoPoint from,
    DiscoveryFilters filters = const DiscoveryFilters(),
    int limit = 5,
  }) async {
    try {
      return await _remote.suggestions(
        from: from,
        filters: filters,
        limit: limit,
      );
    } catch (error) {
      if (!isOfflineFailure(error)) {
        rethrow;
      }
      try {
        return await _local.suggestions(
          from: from,
          filters: filters,
          limit: limit,
        );
      } on Object {
        return const <String>[];
      }
    }
  }
}
