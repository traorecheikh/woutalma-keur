import 'package:flutter/foundation.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/ranking.dart';
import 'package:woutalma_keur/app/domain/repositories.dart';

/// Ce que le client a demandé. Tout est facultatif : chercher sans filtre est
/// le cas le plus fréquent.
@immutable
class DiscoveryFilters {
  const DiscoveryFilters({
    this.transaction,
    this.kind,
    this.maxPrice,
    this.radiusMeters,
    this.query = '',
  });

  final TransactionKind? transaction;
  final PropertyKind? kind;
  final int? maxPrice;
  final double? radiusMeters;

  /// Texte libre : nom de courtier, quartier ou titre de bien.
  final String query;

  bool get isEmpty =>
      transaction == null &&
      kind == null &&
      maxPrice == null &&
      radiusMeters == null &&
      query.trim().isEmpty;

  /// Nombre de filtres actifs, pour l'afficher sur le bouton Filtres.
  int get activeCount => <bool>[
    transaction != null,
    kind != null,
    maxPrice != null,
    radiusMeters != null,
  ].where((bool active) => active).length;

  DiscoveryFilters copyWith({
    TransactionKind? transaction,
    PropertyKind? kind,
    int? maxPrice,
    double? radiusMeters,
    String? query,
    bool clearTransaction = false,
    bool clearKind = false,
    bool clearMaxPrice = false,
    bool clearRadius = false,
  }) {
    return DiscoveryFilters(
      transaction: clearTransaction ? null : transaction ?? this.transaction,
      kind: clearKind ? null : kind ?? this.kind,
      maxPrice: clearMaxPrice ? null : maxPrice ?? this.maxPrice,
      radiusMeters: clearRadius ? null : radiusMeters ?? this.radiusMeters,
      query: query ?? this.query,
    );
  }
}

/// Assemble ce que l'écran Explorer affiche.
///
/// Toute la logique vit ici, en Dart pur : un widget ne trie ni ne filtre.
class DiscoveryService {
  const DiscoveryService({
    required this.brokers,
    required this.properties,
    required this.reviews,
    this.ranking = const RankingService(),
  });

  final BrokerRepository brokers;
  final PropertyRepository properties;
  final ReviewRepository reviews;
  final RankingService ranking;

  /// Biens visibles par un client, filtrés et triés par distance.
  Future<List<Property>> findProperties({
    required GeoPoint from,
    DiscoveryFilters filters = const DiscoveryFilters(),
  }) async {
    final List<Property> all = await properties.discoverable();
    final List<Property> kept = all.where((Property p) {
      return _matchesProperty(p, filters, from);
    }).toList();

    kept.sort((Property a, Property b) {
      return distanceMeters(
        from,
        a.position,
      ).compareTo(distanceMeters(from, b.position));
    });
    return kept;
  }

  /// Courtiers classés, avec tout ce que la carte de résultat doit montrer.
  Future<List<BrokerListing>> findBrokers({
    required GeoPoint from,
    DiscoveryFilters filters = const DiscoveryFilters(),
  }) async {
    final List<Broker> allBrokers = await brokers.all();
    final List<Property> visible = await properties.discoverable();
    final List<Review> allReviews = await reviews.all();

    final List<BrokerListing> listings = <BrokerListing>[];

    for (final Broker broker in allBrokers) {
      final double meters = distanceMeters(from, broker.position);
      if (filters.radiusMeters != null && meters > filters.radiusMeters!) {
        continue;
      }

      final List<Property> own = visible
          .where(
            (Property p) =>
                p.brokerId == broker.id && _matchesProperty(p, filters, from),
          )
          .toList();

      // Un filtre de bien ne masque pas un courtier qui n'en a aucun : il
      // n'aurait alors plus aucun résultat à proposer.
      final bool filtersProperties =
          filters.transaction != null ||
          filters.kind != null ||
          filters.maxPrice != null;
      if (filtersProperties && own.isEmpty) {
        continue;
      }

      if (!_matchesQuery(broker, own, filters.query)) {
        continue;
      }

      final List<Review> published = allReviews
          .where((Review r) => r.brokerId == broker.id && r.isPublic)
          .toList();
      final double average = published.isEmpty
          ? 0
          : published
                    .map((Review r) => r.rating)
                    .reduce((int a, int b) => a + b) /
                published.length;

      listings.add(
        BrokerListing(
          broker: broker,
          distanceMeters: meters,
          averageRating: average,
          reviewCount: published.length,
          availableProperties: own.length,
          score: ranking.score(
            averageRating: average,
            reviewCount: published.length,
            distanceInMeters: meters,
            responseRate: broker.responseRate,
          ),
        ),
      );
    }

    return ranking.sort(listings);
  }

  bool _matchesProperty(
    Property property,
    DiscoveryFilters filters,
    GeoPoint from,
  ) {
    if (filters.transaction != null &&
        property.transaction != filters.transaction) {
      return false;
    }
    if (filters.kind != null && property.kind != filters.kind) {
      return false;
    }
    if (filters.maxPrice != null && property.price > filters.maxPrice!) {
      return false;
    }
    if (filters.radiusMeters != null &&
        distanceMeters(from, property.position) > filters.radiusMeters!) {
      return false;
    }
    final String query = filters.query.trim();
    if (query.isEmpty) {
      return true;
    }
    return _contains(property.title, query) ||
        _contains(property.neighbourhood, query);
  }

  bool _matchesQuery(Broker broker, List<Property> own, String rawQuery) {
    final String query = rawQuery.trim();
    if (query.isEmpty) {
      return true;
    }
    if (_contains(broker.name, query)) {
      return true;
    }
    if (broker.coverage.any((String zone) => _contains(zone, query))) {
      return true;
    }
    return own.any(
      (Property p) =>
          _contains(p.title, query) || _contains(p.neighbourhood, query),
    );
  }

  /// Comparaison indulgente : sans casse ni accents, parce que personne ne
  /// tape « Sacré-Cœur » correctement sur un clavier de téléphone.
  static bool _contains(String haystack, String needle) =>
      _fold(haystack).contains(_fold(needle));

  static String _fold(String value) {
    const String accented = 'àâäáãçéèêëíìîïñóòôöõúùûüýÿ';
    const String plain = 'aaaaaceeeeiiiinooooouuuuyy';
    final StringBuffer buffer = StringBuffer();
    for (final int rune in value.toLowerCase().runes) {
      final String char = String.fromCharCode(rune);
      final int index = accented.indexOf(char);
      buffer.write(index >= 0 ? plain[index] : char);
    }
    return buffer.toString();
  }
}
