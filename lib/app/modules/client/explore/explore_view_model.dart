import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:woutalma_keur/app/core/location/client_position_controller.dart';
import 'package:woutalma_keur/app/core/state/screen_state.dart';
import 'package:woutalma_keur/app/domain/discovery.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/location_service.dart';

enum ExploreSegment { brokers, properties }

enum ExploreView { list, map }

@immutable
class ExploreResults {
  const ExploreResults({
    required this.brokers,
    required this.properties,
    int? brokerCount,
    int? propertyCount,
  }) : _brokerCount = brokerCount,
       _propertyCount = propertyCount;

  final List<BrokerListing> brokers;
  final List<Property> properties;

  /// Ce que le serveur dit avoir, pas ce qu'il a envoyé : la page valait 20 et
  /// l'écran annonçait « 20 résultats » quand il y en avait deux cents.
  final int? _brokerCount;
  final int? _propertyCount;

  int countFor(ExploreSegment segment) => switch (segment) {
    ExploreSegment.brokers => _brokerCount ?? brokers.length,
    ExploreSegment.properties => _propertyCount ?? properties.length,
  };

  bool hasMoreFor(ExploreSegment segment) => switch (segment) {
    ExploreSegment.brokers => brokers.length < countFor(segment),
    ExploreSegment.properties => properties.length < countFor(segment),
  };

  /// Derniers publiés d'abord.
  List<Property> get newest =>
      List<Property>.of(properties)
        ..sort((Property a, Property b) => b.createdAt.compareTo(a.createdAt));

  ExploreResults followedBy(ExploreResults next) => ExploreResults(
    brokers: <BrokerListing>[...brokers, ...next.brokers],
    properties: <Property>[...properties, ...next.properties],
    brokerCount: next._brokerCount,
    propertyCount: next._propertyCount,
  );
}

/// Coordonne C01 (accueil) et M14 (résultats). L'accueil lit [home], toujours
/// sans filtre ; la recherche lit [state], qui suit [filters].
class ExploreViewModel extends ChangeNotifier {
  ExploreViewModel({
    required DiscoveryService discovery,
    required ClientPositionController position,
    Duration debounce = const Duration(milliseconds: 350),
  }) : _discovery = discovery,
       _positions = position,
       _debounce = debounce {
    _positions.addListener(_onPositionChanged);
  }

  final DiscoveryService _discovery;
  final ClientPositionController _positions;
  final Duration _debounce;

  Timer? _timer;
  bool _disposed = false;

  /// Une réponse lente ne doit jamais écraser une plus récente : sur un réseau
  /// faible, la recherche d'avant-hier arrivait après celle qu'on venait de
  /// taper.
  int _runId = 0;
  int _homeId = 0;

  String? get placeName => _positions.placeName;
  bool get isFromGps => _positions.isFromGps;
  bool get isOutsideServiceArea => _positions.isOutsideServiceArea;
  bool get gpsFailed => _positions.gpsFailed;

  final List<Neighbourhood> recentPlaces = <Neighbourhood>[];

  ScreenState<ExploreResults> _home =
      const ScreenState<ExploreResults>.initial();
  ScreenState<ExploreResults> _state =
      const ScreenState<ExploreResults>.initial();
  ExploreSegment _segment = ExploreSegment.properties;
  ExploreView _view = ExploreView.list;
  DiscoveryFilters _filters = const DiscoveryFilters();
  List<String> _searchSuggestions = const <String>[];
  int? _lastKnownCount;
  bool _loadingMore = false;

  ScreenState<ExploreResults> get home => _home;
  ScreenState<ExploreResults> get state => _state;
  ExploreSegment get segment => _segment;
  ExploreView get view => _view;
  DiscoveryFilters get filters => _filters;
  GeoPoint get position => _positions.position;
  List<String> get searchSuggestions => _searchSuggestions;
  bool get loadingMore => _loadingMore;

  /// Reste-t-il des résultats à demander pour le segment affiché ?
  bool get hasMore => _state.valueOrNull?.hasMoreFor(_segment) ?? false;

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _positions.removeListener(_onPositionChanged);
    super.dispose();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void>? _pendingPositionRun;

  void _onPositionChanged() {
    _notify();
    _pendingPositionRun = _reload();
  }

  Future<void> load() async {
    _home = const ScreenState<ExploreResults>.loading();
    _state = const ScreenState<ExploreResults>.loading();
    _notify();
    await _reload();
  }

  /// L'accueil interroge déjà le serveur sans filtre : quand la recherche
  /// n'en a pas non plus, elle réutilise cette réponse au lieu d'en payer une
  /// seconde, identique.
  Future<void> _reload() async {
    await _loadHome();
    if (_isDefault(_filters)) {
      _state = _home;
      _notify();
      return;
    }
    await _run();
  }

  static bool _isDefault(DiscoveryFilters filters) =>
      filters.isEmpty && filters.sort == DiscoverySort.relevance;

  void selectView(ExploreView value) {
    if (_view == value) return;
    _view = value;
    _notify();
  }

  void selectSegment(ExploreSegment value) {
    if (_segment == value) return;
    _segment = value;
    _notify();
  }

  void search(String query) {
    _filters = _filters.copyWith(query: query);
    _notify();
    _timer?.cancel();
    _timer = Timer(_debounce, _run);
  }

  /// Combien de résultats ce jeu de filtres donnerait.
  ///
  /// Hors ligne, la feuille de filtres ne doit pas remonter une erreur : elle
  /// garde le dernier compte connu plutôt que d'annoncer zéro résultat.
  Future<int> previewCount(DiscoveryFilters candidate) async {
    try {
      final int count = _segment == ExploreSegment.brokers
          ? (await _discovery.searchBrokers(
              from: _positions.position,
              filters: candidate,
              limit: 1,
            )).total
          : (await _discovery.searchProperties(
              from: _positions.position,
              filters: candidate,
              limit: 1,
            )).total;
      _lastKnownCount = count;
      return count;
    } on Object {
      return _lastKnownCount ?? 0;
    }
  }

  Future<void> applyFilters(DiscoveryFilters value) async {
    _filters = value;
    // Chargement annoncé tout de suite : l'écran de résultats s'ouvre avant la
    // réponse, et montrer les résultats précédents sous les nouveaux filtres
    // serait faux.
    _state = const ScreenState<ExploreResults>.loading();
    _notify();
    await _run();
  }

  Future<void> clearFilters() async {
    _filters = DiscoveryFilters(query: _filters.query);
    _notify();
    await _run();
  }

  /// Page suivante des résultats, ajoutée à la suite.
  Future<void> loadMore() async {
    final ExploreResults? current = _state.valueOrNull;
    if (_loadingMore || current == null || !current.hasMoreFor(_segment)) {
      return;
    }
    _loadingMore = true;
    _notify();
    final int id = ++_runId;
    final ScreenState<ExploreResults> next = await _fetch(
      _filters,
      offset: _segment == ExploreSegment.brokers
          ? current.brokers.length
          : current.properties.length,
    );
    _loadingMore = false;
    if (id != _runId || _disposed) {
      return;
    }
    final ExploreResults? more = next.valueOrNull;
    _state = more == null
        ? _state
        : ScreenState<ExploreResults>.data(current.followedBy(more));
    _notify();
  }

  Future<void> moveTo(Neighbourhood place) async {
    recentPlaces
      ..remove(place)
      ..insert(0, place);
    if (recentPlaces.length > 3) recentPlaces.removeLast();
    _pendingPositionRun = null;
    _positions.moveTo(place);
    await _pendingPositionRun;
  }

  Future<ScreenState<ExploreResults>> _fetch(
    DiscoveryFilters filters, {
    int offset = 0,
  }) async {
    try {
      final DiscoveryPage<BrokerListing> brokers = await _discovery
          .searchBrokers(
            from: _positions.position,
            filters: filters,
            offset: offset,
          );
      final DiscoveryPage<Property> properties = await _discovery
          .searchProperties(
            from: _positions.position,
            filters: filters,
            offset: offset,
          );
      return brokers.items.isEmpty && properties.items.isEmpty
          ? const ScreenState<ExploreResults>.empty()
          : ScreenState<ExploreResults>.data(
              ExploreResults(
                brokers: brokers.items,
                properties: properties.items,
                brokerCount: brokers.total,
                propertyCount: properties.total,
              ),
            );
    } on DioException catch (error) {
      return ScreenState<ExploreResults>.error(
        error.response == null ? WkFailure.network : WkFailure.unknown,
      );
    } on Object {
      return const ScreenState<ExploreResults>.error(WkFailure.unknown);
    }
  }

  Future<void> _loadHome() async {
    final int id = ++_homeId;
    final ScreenState<ExploreResults> fetched = await _fetch(
      const DiscoveryFilters(),
    );
    if (id != _homeId) return;
    _home = fetched;
    _notify();
  }

  Future<void> _run() async {
    final int id = ++_runId;
    final ScreenState<ExploreResults> fetched = await _fetch(_filters);
    if (id != _runId) return;
    _state = fetched;
    try {
      _searchSuggestions = await _discovery.suggestions(
        from: _positions.position,
        filters: _filters,
      );
    } on Object {
      _searchSuggestions = const <String>[];
    }
    if (id != _runId) return;
    _notify();
  }
}
