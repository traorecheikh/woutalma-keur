import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/ranking.dart';
import 'package:woutalma_keur/app/domain/repositories.dart';

/// Dans quel ordre le résultat est rendu.
enum DiscoverySort { relevance, newest }

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
    this.sort = DiscoverySort.relevance,
  });

  final TransactionKind? transaction;
  final PropertyKind? kind;
  final int? maxPrice;
  final double? radiusMeters;
  final DiscoverySort sort;

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
    DiscoverySort? sort,
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
      sort: sort ?? this.sort,
    );
  }
}

/// Une tranche de résultats et le total que le serveur dit avoir.
///
/// [total] vient de `totalCount` : sans lui, « 20 résultats » s'affichait dès
/// que le serveur en avait mille, la taille de page devenant le compte.
@immutable
class DiscoveryPage<T> {
  const DiscoveryPage({required this.items, required this.total});

  /// Un classement local n'est pas paginé : on découpe ce qu'on a.
  factory DiscoveryPage.slice(
    List<T> all, {
    required int limit,
    int offset = 0,
  }) => DiscoveryPage<T>(
    items: all.skip(offset).take(limit).toList(),
    total: all.length,
  );

  final List<T> items;
  final int total;
}

/// Ce que l'écran Explorer demande.
///
/// Deux implémentations : [LocalDiscoveryService], qui classe en Dart pur, et
/// `RemoteDiscoveryService`, qui délègue à `GET /search/*`. L'écran ne sait pas
/// laquelle est branchée — même raison d'être que les contrats de
/// `repositories.dart`.
abstract class DiscoveryService {
  const DiscoveryService();

  /// Le maximum accepté par `GET /search/*`.
  static const int pageSize = 50;

  Future<DiscoveryPage<Property>> searchProperties({
    required GeoPoint from,
    DiscoveryFilters filters,
    int limit,
    int offset,
  });

  Future<DiscoveryPage<BrokerListing>> searchBrokers({
    required GeoPoint from,
    DiscoveryFilters filters,
    int limit,
    int offset,
  });

  Future<List<String>> suggestions({
    required GeoPoint from,
    DiscoveryFilters filters,
    int limit,
  });

  Future<List<Property>> findProperties({
    required GeoPoint from,
    DiscoveryFilters filters = const DiscoveryFilters(),
  }) async => (await searchProperties(from: from, filters: filters)).items;

  Future<List<BrokerListing>> findBrokers({
    required GeoPoint from,
    DiscoveryFilters filters = const DiscoveryFilters(),
  }) async => (await searchBrokers(from: from, filters: filters)).items;
}

/// Derniers publiés d'abord. Le serveur ne sait pas trier, donc l'ordre est
/// posé ici, des deux côtés, sur ce qui a été rendu.
List<Property> sortedBy(DiscoverySort sort, List<Property> properties) {
  if (sort != DiscoverySort.newest) {
    return properties;
  }
  return List<Property>.of(properties)
    ..sort((Property a, Property b) => b.createdAt.compareTo(a.createdAt));
}

/// Assemble ce que l'écran Explorer affiche, en local.
///
/// Toute la logique vit ici, en Dart pur : un widget ne trie ni ne filtre.
/// C'est aussi la référence dont `backend/src/search` est le portage — les
/// tests des deux côtés comparent les mêmes scores.
class LocalDiscoveryService extends DiscoveryService {
  const LocalDiscoveryService({
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
  @override
  Future<DiscoveryPage<Property>> searchProperties({
    required GeoPoint from,
    DiscoveryFilters filters = const DiscoveryFilters(),
    int limit = DiscoveryService.pageSize,
    int offset = 0,
  }) async {
    final _SearchQuery search = _SearchQuery.parse(filters.query);
    final List<Property> all = await properties.discoverable();
    final _FtsIndex index = _FtsIndex(
      all.map((Property p) => _propertyDocument(p)),
    );
    final Map<String, double> scores = index.search(search.tokens);
    final bool hasTextQuery = search.tokens.isNotEmpty;
    final List<Property> kept = all.where((Property p) {
      if (!_passesPropertyFacets(p, filters, from, search)) {
        return false;
      }
      return !hasTextQuery || scores.containsKey(p.id);
    }).toList();

    kept.sort((Property a, Property b) {
      final int byRelevance = (scores[b.id] ?? 0).compareTo(scores[a.id] ?? 0);
      if (byRelevance != 0) {
        return byRelevance;
      }
      return distanceMeters(
        from,
        a.position,
      ).compareTo(distanceMeters(from, b.position));
    });
    return DiscoveryPage<Property>.slice(
      sortedBy(filters.sort, kept),
      limit: limit,
      offset: offset,
    );
  }

  /// Courtiers classés, avec tout ce que la carte de résultat doit montrer.
  @override
  Future<DiscoveryPage<BrokerListing>> searchBrokers({
    required GeoPoint from,
    DiscoveryFilters filters = const DiscoveryFilters(),
    int limit = DiscoveryService.pageSize,
    int offset = 0,
  }) async {
    final _SearchQuery search = _SearchQuery.parse(filters.query);
    final List<Broker> allBrokers = await brokers.all();
    final List<Property> visible = await properties.discoverable();
    final List<Review> allReviews = await reviews.all();
    final Map<String, List<Property>> byBroker = <String, List<Property>>{};
    for (final Property property in visible) {
      byBroker.putIfAbsent(property.brokerId, () => <Property>[]).add(property);
    }
    final _FtsIndex index = _FtsIndex(
      allBrokers.map(
        (Broker broker) =>
            _brokerDocument(broker, byBroker[broker.id] ?? const <Property>[]),
      ),
    );
    final Map<String, double> scores = index.search(search.tokens);
    final bool hasTextQuery = search.tokens.isNotEmpty;

    final List<BrokerListing> listings = <BrokerListing>[];

    for (final Broker broker in allBrokers) {
      final double meters = distanceMeters(from, broker.position);
      if (filters.radiusMeters != null && meters > filters.radiusMeters!) {
        continue;
      }

      final List<Property> own = (byBroker[broker.id] ?? const <Property>[])
          .where(
            (Property p) => _passesPropertyFacets(p, filters, from, search),
          )
          .toList();

      // Un filtre de bien ne masque pas un courtier qui n'en a aucun : il
      // n'aurait alors plus aucun résultat à proposer.
      final bool filtersProperties =
          filters.transaction != null ||
          filters.kind != null ||
          filters.maxPrice != null ||
          search.filtersProperties;
      if (filtersProperties && own.isEmpty) {
        continue;
      }

      if (hasTextQuery && !scores.containsKey(broker.id)) {
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
          score:
              ranking.score(
                averageRating: average,
                reviewCount: published.length,
                distanceInMeters: meters,
                responseRate: broker.responseRate,
              ) +
              (scores[broker.id] ?? 0),
        ),
      );
    }

    return DiscoveryPage<BrokerListing>.slice(
      ranking.sort(listings),
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<List<String>> suggestions({
    required GeoPoint from,
    DiscoveryFilters filters = const DiscoveryFilters(),
    int limit = 5,
  }) async {
    final _SearchQuery search = _SearchQuery.parse(filters.query);
    final List<Broker> allBrokers = await brokers.all();
    final List<Property> visible = await properties.discoverable();
    final Map<String, int> scored = <String, int>{};

    void add(String value, {int boost = 0}) {
      final String label = value.trim();
      if (label.isEmpty || label.toLowerCase() == filters.query.toLowerCase()) {
        return;
      }
      final int score = search.suggestionScore(label) + boost;
      if (score <= 0) {
        return;
      }
      scored.update(
        label,
        (int old) => old > score ? old : score,
        ifAbsent: () => score,
      );
    }

    for (final Broker broker in allBrokers) {
      add(broker.name, boost: 2);
      for (final String zone in broker.coverage) {
        add(zone, boost: 3);
      }
    }
    for (final Property property in visible) {
      if (filters.transaction != null &&
          property.transaction != filters.transaction) {
        continue;
      }
      if (filters.kind != null && property.kind != filters.kind) {
        continue;
      }
      if (filters.maxPrice != null && property.price > filters.maxPrice!) {
        continue;
      }
      if (filters.radiusMeters != null &&
          distanceMeters(from, property.position) > filters.radiusMeters!) {
        continue;
      }
      add(property.neighbourhood, boost: 3);
      add(property.title, boost: 1);
    }
    for (final String scope in search.scopeSuggestions) {
      add(scope, boost: 4);
    }

    final List<MapEntry<String, int>> entries = scored.entries.toList()
      ..sort((MapEntry<String, int> a, MapEntry<String, int> b) {
        final int byScore = b.value.compareTo(a.value);
        if (byScore != 0) {
          return byScore;
        }
        return a.key.length.compareTo(b.key.length);
      });
    return entries.map((MapEntry<String, int> e) => e.key).take(limit).toList();
  }

  bool _passesPropertyFacets(
    Property property,
    DiscoveryFilters filters,
    GeoPoint from,
    _SearchQuery search,
  ) {
    if (filters.transaction != null &&
        property.transaction != filters.transaction) {
      return false;
    }
    if (search.transaction != null &&
        property.transaction != search.transaction) {
      return false;
    }
    if (filters.kind != null && property.kind != filters.kind) {
      return false;
    }
    if (search.kind != null && property.kind != search.kind) {
      return false;
    }
    if (filters.maxPrice != null && property.price > filters.maxPrice!) {
      return false;
    }
    if (filters.radiusMeters != null &&
        distanceMeters(from, property.position) > filters.radiusMeters!) {
      return false;
    }
    return true;
  }

  _FtsDocument _propertyDocument(Property property) => _FtsDocument(
    id: property.id,
    fields: <_FtsField>[
      _FtsField(property.title, 3.5),
      _FtsField(property.neighbourhood, 4),
      _FtsField(property.description, 1),
      _FtsField(_kindToken(property.kind), 3),
      _FtsField(_transactionToken(property.transaction), 3),
      if (property.rooms != null) _FtsField('${property.rooms} pieces', 1.5),
    ],
    suggestions: <String>[property.neighbourhood, property.title],
  );

  _FtsDocument _brokerDocument(Broker broker, List<Property> own) =>
      _FtsDocument(
        id: broker.id,
        fields: <_FtsField>[
          _FtsField(broker.name, 4),
          for (final String zone in broker.coverage) _FtsField(zone, 3),
          for (final Property property in own) ...<_FtsField>[
            _FtsField(property.title, 2),
            _FtsField(property.neighbourhood, 2.5),
            _FtsField(_kindToken(property.kind), 2),
            _FtsField(_transactionToken(property.transaction), 2),
          ],
        ],
        suggestions: <String>[broker.name, ...broker.coverage],
      );

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

  static List<String> _tokens(String value) => _fold(value)
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .split(' ')
      .where((String token) => token.length > 1)
      .toList();

  static String _kindToken(PropertyKind kind) => switch (kind) {
    PropertyKind.apartment => 'appartement appart',
    PropertyKind.house => 'maison villa',
    PropertyKind.land => 'terrain parcelle',
    PropertyKind.studio => 'studio',
    PropertyKind.room => 'chambre',
  };

  static String _transactionToken(TransactionKind transaction) =>
      switch (transaction) {
        TransactionKind.rent => 'location louer loue',
        TransactionKind.sale => 'vente vendre acheter',
      };
}

@immutable
class _SearchQuery {
  const _SearchQuery({
    required this.tokens,
    required this.kind,
    required this.transaction,
  });

  final List<String> tokens;
  final PropertyKind? kind;
  final TransactionKind? transaction;

  bool get isEmpty => tokens.isEmpty && kind == null && transaction == null;
  bool get filtersProperties => kind != null || transaction != null;

  List<String> get scopeSuggestions {
    final List<String> values = <String>[];
    if (kind == null) {
      values.addAll(const <String>['Appartement', 'Maison', 'Terrain']);
    }
    if (transaction == null) {
      values.addAll(const <String>['À louer', 'À vendre']);
    }
    return values;
  }

  static _SearchQuery parse(String raw) {
    final List<String> remaining = <String>[];
    PropertyKind? kind;
    TransactionKind? transaction;

    for (final String token in LocalDiscoveryService._tokens(raw)) {
      switch (token) {
        case 'appart':
        case 'appartement':
        case 'appartements':
          kind = PropertyKind.apartment;
        case 'maison':
        case 'maisons':
        case 'villa':
          kind = PropertyKind.house;
        case 'terrain':
        case 'terrains':
        case 'parcelle':
        case 'parcelles':
          kind = PropertyKind.land;
        case 'studio':
        case 'studios':
          kind = PropertyKind.studio;
        case 'chambre':
        case 'chambres':
          kind = PropertyKind.room;
        case 'location':
        case 'louer':
        case 'loue':
        case 'loyer':
          transaction = TransactionKind.rent;
        case 'vente':
        case 'vendre':
        case 'vend':
        case 'acheter':
        case 'achat':
          transaction = TransactionKind.sale;
        default:
          if (!const <String>{
            'avec',
            'pour',
            'pres',
            'dans',
            'chez',
          }.contains(token)) {
            remaining.add(token);
          }
      }
    }
    return _SearchQuery(
      tokens: remaining,
      kind: kind,
      transaction: transaction,
    );
  }

  bool matchesAny(Iterable<String> values) {
    if (tokens.isEmpty) {
      return true;
    }
    final List<String> haystack = values
        .expand((String value) => LocalDiscoveryService._tokens(value))
        .toList();
    return tokens.every(
      (String token) =>
          haystack.any((String candidate) => _matchesToken(candidate, token)),
    );
  }

  int scoreText(String value) {
    final List<String> haystack = LocalDiscoveryService._tokens(value);
    var score = 0;
    for (final String token in tokens) {
      for (final String candidate in haystack) {
        if (candidate == token) {
          score += 4;
        } else if (candidate.startsWith(token)) {
          score += 3;
        } else if (candidate.contains(token)) {
          score += 2;
        } else if (_distanceAtMostOne(candidate, token)) {
          score += 1;
        }
      }
    }
    return score;
  }

  int suggestionScore(String value) {
    if (tokens.isEmpty) {
      return 1;
    }
    final int score = scoreText(value);
    if (score > 0) {
      return score;
    }
    final List<String> haystack = LocalDiscoveryService._tokens(value);
    return tokens.any(
          (String token) => haystack.any(
            (String candidate) => _distanceAtMostOne(candidate, token),
          ),
        )
        ? 1
        : 0;
  }

  static bool _matchesToken(String candidate, String token) =>
      candidate == token ||
      candidate.startsWith(token) ||
      candidate.contains(token) ||
      _distanceAtMostOne(candidate, token);

  static bool _distanceAtMostOne(String a, String b) {
    if (a == b) {
      return true;
    }
    if ((a.length - b.length).abs() > 1 || a.length < 4 || b.length < 4) {
      return false;
    }
    var edits = 0;
    var i = 0;
    var j = 0;
    while (i < a.length && j < b.length) {
      if (a.codeUnitAt(i) == b.codeUnitAt(j)) {
        i++;
        j++;
        continue;
      }
      edits++;
      if (edits > 1) {
        return false;
      }
      if (a.length > b.length) {
        i++;
      } else if (b.length > a.length) {
        j++;
      } else {
        i++;
        j++;
      }
    }
    return true;
  }
}

@immutable
class _FtsField {
  const _FtsField(this.value, this.weight);

  final String value;
  final double weight;
}

@immutable
class _FtsDocument {
  const _FtsDocument({
    required this.id,
    required this.fields,
    required this.suggestions,
  });

  final String id;
  final List<_FtsField> fields;
  final List<String> suggestions;
}

class _FtsIndex {
  _FtsIndex(Iterable<_FtsDocument> documents)
    : _documents = documents.toList(growable: false) {
    for (final _FtsDocument document in _documents) {
      final Map<String, double> documentTerms = <String, double>{};
      for (final _FtsField field in document.fields) {
        for (final String token in LocalDiscoveryService._tokens(field.value)) {
          documentTerms.update(
            token,
            (double value) => value + field.weight,
            ifAbsent: () => field.weight,
          );
        }
      }
      _termWeights[document.id] = documentTerms;
      for (final String token in documentTerms.keys) {
        _documentFrequency.update(
          token,
          (int value) => value + 1,
          ifAbsent: () => 1,
        );
      }
    }
  }

  final List<_FtsDocument> _documents;
  final Map<String, Map<String, double>> _termWeights =
      <String, Map<String, double>>{};
  final Map<String, int> _documentFrequency = <String, int>{};

  Map<String, double> search(List<String> queryTokens) {
    if (queryTokens.isEmpty) {
      return const <String, double>{};
    }
    final Map<String, double> scores = <String, double>{};
    for (final _FtsDocument document in _documents) {
      final Map<String, double> terms = _termWeights[document.id]!;
      var score = 0.0;
      for (final String queryToken in queryTokens) {
        final String? token = _matchingTerm(terms.keys, queryToken);
        if (token == null) {
          score = 0;
          break;
        }
        final double idf = math.log(
          1 +
              (_documents.length - (_documentFrequency[token] ?? 0) + 0.5) /
                  ((_documentFrequency[token] ?? 0) + 0.5),
        );
        score += terms[token]! * idf;
      }
      if (score > 0) {
        scores[document.id] = score;
      }
    }
    return scores;
  }

  static String? _matchingTerm(Iterable<String> terms, String queryToken) {
    for (final String term in terms) {
      if (_SearchQuery._matchesToken(term, queryToken)) {
        return term;
      }
    }
    return null;
  }
}
