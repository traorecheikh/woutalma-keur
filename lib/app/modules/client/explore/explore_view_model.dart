import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:woutalma_keur/app/core/state/screen_state.dart';
import 'package:woutalma_keur/app/domain/discovery.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/location_service.dart';

/// Ce que C01 montre : des courtiers ou des biens.
enum ExploreSegment { brokers, properties }

/// Comment C01 le montre. Deux vues du **même** résultat, pas deux écrans.
enum ExploreView { list, map }

/// Contenu résolu de l'écran Explorer.
@immutable
class ExploreResults {
  const ExploreResults({required this.brokers, required this.properties});

  final List<BrokerListing> brokers;
  final List<Property> properties;

  int countFor(ExploreSegment segment) => switch (segment) {
    ExploreSegment.brokers => brokers.length,
    ExploreSegment.properties => properties.length,
  };
}

/// Coordonne C01.
///
/// Aucun widget ne filtre ni ne trie : il lit cet état et émet des intentions.
class ExploreViewModel extends ChangeNotifier {
  ExploreViewModel({
    required DiscoveryService discovery,
    required GeoPoint position,
    Duration debounce = const Duration(milliseconds: 350),
  }) : _discovery = discovery,
       _position = position,
       _debounce = debounce;

  final DiscoveryService _discovery;

  /// Anti-rebond de la frappe. Trois frappes rapprochées ne déclenchent
  /// qu'une recherche.
  final Duration _debounce;

  GeoPoint _position;
  Timer? _timer;

  /// Nom de l'endroit où l'on cherche, affiché en titre. `null` tant qu'on
  /// n'a rien choisi explicitement.
  String? placeName;

  /// Derniers quartiers choisis, les plus récents d'abord.
  final List<Neighbourhood> recentPlaces = <Neighbourhood>[];

  ScreenState<ExploreResults> _state =
      const ScreenState<ExploreResults>.initial();
  ExploreSegment _segment = ExploreSegment.brokers;

  /// La liste par défaut : la carte coûte de la data, elle se demande.
  ExploreView _view = ExploreView.list;
  DiscoveryFilters _filters = const DiscoveryFilters();

  ScreenState<ExploreResults> get state => _state;
  ExploreSegment get segment => _segment;
  ExploreView get view => _view;
  DiscoveryFilters get filters => _filters;
  GeoPoint get position => _position;

  List<String> get searchSuggestions {
    final String query = _filters.query.trim().toLowerCase();
    if (query.isEmpty) {
      return const <String>[];
    }
    return _state.map(
      initial: () => const <String>[],
      loading: () => const <String>[],
      empty: () => const <String>[],
      error: (_) => const <String>[],
      data: (ExploreResults results) {
        final LinkedHashSet<String> values = LinkedHashSet<String>();
        for (final BrokerListing listing in results.brokers) {
          values.addAll(listing.broker.coverage.take(2));
        }
        for (final Property property in results.properties) {
          values.add(property.neighbourhood);
        }
        values.removeWhere(
          (String value) =>
              value.toLowerCase() == query ||
              !value.toLowerCase().contains(query),
        );
        return values.take(4).toList(growable: false);
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> load() async {
    _state = const ScreenState<ExploreResults>.loading();
    notifyListeners();
    await _run();
  }

  /// Bascule liste/carte. Ne touche ni aux filtres, ni à la requête, ni au
  /// segment : c'est une présentation, pas une recherche.
  void selectView(ExploreView value) {
    if (_view == value) {
      return;
    }
    _view = value;
    notifyListeners();
  }

  /// Changer de segment **ne réinitialise pas** les filtres ni la requête :
  /// c'est une autre vue du même résultat, pas une nouvelle recherche.
  void selectSegment(ExploreSegment value) {
    if (_segment == value) {
      return;
    }
    _segment = value;
    notifyListeners();
  }

  /// Appelée à chaque frappe. Ne montre pas d'indicateur : les résultats
  /// précédents restent lisibles pendant le calcul, et la liste ne saute pas.
  void search(String query) {
    _filters = _filters.copyWith(query: query);
    notifyListeners();
    _timer?.cancel();
    _timer = Timer(_debounce, _run);
  }

  /// Combien de résultats donnerait ce jeu de filtres, sans l'appliquer.
  ///
  /// Sert l'aperçu en direct de M01 : on apprend qu'un filtre vide la liste
  /// **avant** de le poser, pas après.
  Future<int> previewCount(DiscoveryFilters candidate) async {
    final List<BrokerListing> brokers = await _discovery.findBrokers(
      from: _position,
      filters: candidate,
    );
    final List<Property> properties = await _discovery.findProperties(
      from: _position,
      filters: candidate,
    );
    return _segment == ExploreSegment.brokers
        ? brokers.length
        : properties.length;
  }

  Future<void> applyFilters(DiscoveryFilters value) async {
    _filters = value;
    notifyListeners();
    await _run();
  }

  Future<void> clearFilters() async {
    // La requête texte survit : effacer les filtres n'efface pas ce que
    // l'utilisateur vient d'écrire.
    _filters = DiscoveryFilters(query: _filters.query);
    notifyListeners();
    await _run();
  }

  /// Change l'endroit où l'on cherche.
  ///
  /// Les filtres et la requête survivent : déplacer la recherche n'est pas la
  /// recommencer.
  Future<void> moveTo(Neighbourhood place) async {
    _position = place.position;
    placeName = place.name;
    recentPlaces
      ..remove(place)
      ..insert(0, place);
    if (recentPlaces.length > 3) {
      recentPlaces.removeLast();
    }
    notifyListeners();
    await _run();
  }

  Future<void> _run() async {
    try {
      final List<BrokerListing> brokers = await _discovery.findBrokers(
        from: _position,
        filters: _filters,
      );
      final List<Property> properties = await _discovery.findProperties(
        from: _position,
        filters: _filters,
      );

      final ExploreResults results = ExploreResults(
        brokers: brokers,
        properties: properties,
      );

      // Vide seulement si les deux vues le sont : basculer de segment ne doit
      // pas donner l'impression que la recherche a échoué.
      _state = brokers.isEmpty && properties.isEmpty
          ? const ScreenState<ExploreResults>.empty()
          : ScreenState<ExploreResults>.data(results);
    } on Object {
      _state = const ScreenState<ExploreResults>.error(WkFailure.unknown);
    }
    notifyListeners();
  }
}
