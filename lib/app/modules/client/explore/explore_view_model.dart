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
  const ExploreResults({required this.brokers, required this.properties});

  final List<BrokerListing> brokers;
  final List<Property> properties;

  int countFor(ExploreSegment segment) => switch (segment) {
    ExploreSegment.brokers => brokers.length,
    ExploreSegment.properties => properties.length,
  };

  /// Derniers publiés d'abord.
  List<Property> get newest =>
      List<Property>.of(properties)
        ..sort((Property a, Property b) => b.createdAt.compareTo(a.createdAt));
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

  String? get placeName => _positions.placeName;
  bool get isFromGps => _positions.isFromGps;
  bool get isOutsideServiceArea => _positions.isOutsideServiceArea;

  final List<Neighbourhood> recentPlaces = <Neighbourhood>[];

  ScreenState<ExploreResults> _home =
      const ScreenState<ExploreResults>.initial();
  ScreenState<ExploreResults> _state =
      const ScreenState<ExploreResults>.initial();
  ExploreSegment _segment = ExploreSegment.properties;
  ExploreView _view = ExploreView.list;
  DiscoveryFilters _filters = const DiscoveryFilters();
  List<String> _searchSuggestions = const <String>[];

  ScreenState<ExploreResults> get home => _home;
  ScreenState<ExploreResults> get state => _state;
  ExploreSegment get segment => _segment;
  ExploreView get view => _view;
  DiscoveryFilters get filters => _filters;
  GeoPoint get position => _positions.position;
  List<String> get searchSuggestions => _searchSuggestions;

  @override
  void dispose() {
    _timer?.cancel();
    _positions.removeListener(_onPositionChanged);
    super.dispose();
  }

  Future<void>? _pendingPositionRun;

  void _onPositionChanged() {
    notifyListeners();
    _pendingPositionRun = Future.wait(<Future<void>>[_loadHome(), _run()]);
  }

  Future<void> load() async {
    _home = const ScreenState<ExploreResults>.loading();
    _state = const ScreenState<ExploreResults>.loading();
    notifyListeners();
    await Future.wait(<Future<void>>[_loadHome(), _run()]);
  }

  void selectView(ExploreView value) {
    if (_view == value) return;
    _view = value;
    notifyListeners();
  }

  void selectSegment(ExploreSegment value) {
    if (_segment == value) return;
    _segment = value;
    notifyListeners();
  }

  void search(String query) {
    _filters = _filters.copyWith(query: query);
    notifyListeners();
    _timer?.cancel();
    _timer = Timer(_debounce, _run);
  }

  Future<int> previewCount(DiscoveryFilters candidate) async {
    if (_segment == ExploreSegment.brokers) {
      return (await _discovery.findBrokers(
        from: _positions.position,
        filters: candidate,
      )).length;
    }
    return (await _discovery.findProperties(
      from: _positions.position,
      filters: candidate,
    )).length;
  }

  Future<void> applyFilters(DiscoveryFilters value) async {
    _filters = value;
    notifyListeners();
    await _run();
  }

  Future<void> clearFilters() async {
    _filters = DiscoveryFilters(query: _filters.query);
    notifyListeners();
    await _run();
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

  Future<ScreenState<ExploreResults>> _fetch(DiscoveryFilters filters) async {
    try {
      final List<BrokerListing> brokers = await _discovery.findBrokers(
        from: _positions.position,
        filters: filters,
      );
      final List<Property> properties = await _discovery.findProperties(
        from: _positions.position,
        filters: filters,
      );
      return brokers.isEmpty && properties.isEmpty
          ? const ScreenState<ExploreResults>.empty()
          : ScreenState<ExploreResults>.data(
              ExploreResults(brokers: brokers, properties: properties),
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
    _home = await _fetch(const DiscoveryFilters());
    notifyListeners();
  }

  Future<void> _run() async {
    _state = await _fetch(_filters);
    try {
      _searchSuggestions = await _discovery.suggestions(
        from: _positions.position,
        filters: _filters,
      );
    } on Object {
      _searchSuggestions = const <String>[];
    }
    notifyListeners();
  }
}
