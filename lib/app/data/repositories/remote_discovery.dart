import 'package:woutalma_api_client/woutalma_api_client.dart' as api;
import 'package:woutalma_keur/app/data/repositories/remote_mappers.dart';
import 'package:woutalma_keur/app/domain/discovery.dart';
import 'package:woutalma_keur/app/domain/entities.dart';

/// Découverte servie par `GET /search/*`.
///
/// [LocalDiscoveryService] chargerait ici trois collections entières — tous
/// les courtiers, tous les biens visibles, tous les avis — à **chaque** frappe
/// dans la barre de recherche, pour les reclasser côté téléphone. Sur un
/// réseau faible c'est la première impression que donne l'application.
///
/// Le serveur fait déjà le même calcul (`backend/src/search/ranking.sql.ts`
/// est le portage SQL de `ranking.dart`, et les tests des deux côtés comparent
/// les mêmes scores), avec les distances calculées par PostGIS et la recherche
/// plein texte adossée à un index GIN.
/// Le tri par date n'existe pas côté serveur : il est appliqué à la page
/// reçue, ce qui suffit tant qu'on n'en demande qu'une.
class RemoteDiscoveryService extends DiscoveryService {
  const RemoteDiscoveryService(this._api);

  final api.SearchApi _api;

  @override
  Future<DiscoveryPage<Property>> searchProperties({
    required GeoPoint from,
    DiscoveryFilters filters = const DiscoveryFilters(),
    int limit = DiscoveryService.pageSize,
    int offset = 0,
  }) async {
    final response = await _api.searchControllerFindProperties(
      lat: from.latitude,
      lng: from.longitude,
      transaction: _transaction(filters),
      kind: _kind(filters),
      maxPrice: filters.maxPrice,
      radiusMeters: filters.radiusMeters,
      query: _query(filters),
      limit: limit,
      offset: offset,
    );
    final items = response.data?.items ?? const <api.PropertyDto>[];
    final List<Property> mapped = items.map(mapProperty).toList();
    return DiscoveryPage<Property>(
      items: sortedBy(filters.sort, mapped),
      total: response.data?.totalCount.toInt() ?? mapped.length,
    );
  }

  @override
  Future<DiscoveryPage<BrokerListing>> searchBrokers({
    required GeoPoint from,
    DiscoveryFilters filters = const DiscoveryFilters(),
    int limit = DiscoveryService.pageSize,
    int offset = 0,
  }) async {
    final response = await _api.searchControllerFindBrokers(
      lat: from.latitude,
      lng: from.longitude,
      transaction: _transaction(filters),
      kind: _kind(filters),
      maxPrice: filters.maxPrice,
      radiusMeters: filters.radiusMeters,
      query: _query(filters),
      limit: limit,
      offset: offset,
    );
    final items = response.data?.items ?? const <api.BrokerListingDto>[];
    final List<BrokerListing> mapped = items.map(mapBrokerListing).toList();
    return DiscoveryPage<BrokerListing>(
      items: mapped,
      total: response.data?.totalCount.toInt() ?? mapped.length,
    );
  }

  @override
  Future<List<String>> suggestions({
    required GeoPoint from,
    DiscoveryFilters filters = const DiscoveryFilters(),
    int limit = 5,
  }) async {
    final response = await _api.searchControllerSuggestions(
      lat: from.latitude,
      lng: from.longitude,
      query: _query(filters),
      limit: limit,
    );
    return (response.data?.items ?? const <String>[]).take(limit).toList();
  }

  // Le DTO de requête rejette une chaîne vide (`@IsOptional` ne s'applique
  // qu'à l'absence), donc un filtre vide s'envoie comme absent.
  static String? _query(DiscoveryFilters filters) =>
      filters.query.trim().isEmpty ? null : filters.query.trim();

  static String? _transaction(DiscoveryFilters filters) =>
      filters.transaction == null
      ? null
      : transactionKindWireName(filters.transaction!);

  static String? _kind(DiscoveryFilters filters) =>
      filters.kind == null ? null : propertyKindWireName(filters.kind!);
}
