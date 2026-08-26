import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/core/state/screen_state.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/location_service.dart';
import 'package:woutalma_keur/app/domain/ranking.dart';
import 'package:woutalma_keur/app/modules/client/explore/cards.dart';
import 'package:woutalma_keur/app/modules/client/explore/explore_view_model.dart';
import 'package:woutalma_keur/app/modules/client/explore/filters_sheet.dart';
import 'package:woutalma_keur/app/modules/client/explore/results_map.dart';
import 'package:woutalma_keur/app/shared/formatters.dart';
import 'package:woutalma_keur/app/ui/ui.dart';

class SearchOverlay extends StatefulWidget {
  const SearchOverlay({
    super.key,
    required this.model,
    required this.onOpenBroker,
    required this.onOpenProperty,
    this.autofocus = false,
    this.showAll = true,
  });
  final ExploreViewModel model;
  final void Function(String brokerId) onOpenBroker;
  final void Function(String propertyId) onOpenProperty;
  final bool autofocus, showAll;

  static Future<void> show(
    BuildContext context, {
    required ExploreViewModel model,
    required void Function(String) onOpenBroker,
    required void Function(String) onOpenProperty,
    bool autofocus = false,
    bool showAll = true,
  }) => Navigator.of(context, rootNavigator: true).push<void>(
    MaterialPageRoute<void>(
      builder: (_) => ChangeNotifierProvider<ExploreViewModel>.value(
        value: model,
        child: SearchOverlay(
          model: model,
          onOpenBroker: onOpenBroker,
          onOpenProperty: onOpenProperty,
          autofocus: autofocus,
          showAll: showAll,
        ),
      ),
    ),
  );

  @override
  State<SearchOverlay> createState() => _SearchOverlayState();
}

enum _Quick { rent, sale, apartment, house, land, studio, room }

class _SearchOverlayState extends State<SearchOverlay> {
  late final _query = TextEditingController(text: widget.model.filters.query);

  @override
  void initState() {
    super.initState();
    _query.addListener(() => model.search(_query.text));
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  ExploreViewModel get model => widget.model;

  _Quick? get _selected {
    final f = model.filters;
    if (f.kind != null) return _Quick.values.byName(f.kind!.name);
    return switch (f.transaction) {
      TransactionKind.rent => _Quick.rent,
      TransactionKind.sale => _Quick.sale,
      null => null,
    };
  }

  Future<void> _quick(_Quick q) {
    final f = model.filters;
    final off = _selected == q;
    if (q == _Quick.rent || q == _Quick.sale) {
      return model.applyFilters(
        off
            ? f.copyWith(clearTransaction: true)
            : f.copyWith(
                transaction: q == _Quick.rent
                    ? TransactionKind.rent
                    : TransactionKind.sale,
                clearKind: true,
              ),
      );
    }
    return model.applyFilters(
      off
          ? f.copyWith(clearKind: true)
          : f.copyWith(kind: PropertyKind.values.byName(q.name)),
    );
  }

  Future<void> _openFilters() async {
    final applied = await FiltersSheet.show(
      context,
      initial: model.filters,
      countResults: model.previewCount,
    );
    if (applied != null) await model.applyFilters(applied);
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ExploreViewModel>();
    final l = context.l10n;
    final f = model.filters;
    final extra = [
      f.maxPrice != null,
      f.radiusMeters != null,
    ].where((b) => b).length;
    return AppScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Insets.page,
              Insets.xs,
              Insets.page,
              Insets.md,
            ),
            child: AppSearchPill(
              hint: l.exploreSearchHint,
              controller: _query,
              autofocus: widget.autofocus,
              onSubmitted: model.search,
              onClear: () {
                _query.clear();
                model.search('');
              },
            ),
          ),
          AppPillRow(
            children: [
              AppPill(
                l.filtersActive(extra),
                icon: FIcons.slidersHorizontal,
                selected: extra > 0,
                onTap: _openFilters,
              ),
              for (final q in _Quick.values)
                AppPill(
                  _label(l, q),
                  icon: _icon(q),
                  selected: _selected == q,
                  onTap: () => _quick(q),
                ),
            ],
          ),
          AppSegmented(
            options: [l.exploreSegmentProperties, l.exploreSegmentBrokers],
            index: model.segment == ExploreSegment.properties ? 0 : 1,
            onChanged: (i) => model.selectSegment(
              i == 0 ? ExploreSegment.properties : ExploreSegment.brokers,
            ),
          ),
          Expanded(child: _body(context)),
        ],
      ),
    );
  }

  /// Ce que « Écouter » dit : le nombre de résultats puis les trois premiers,
  /// prix compris. Au-delà, personne ne retient.
  String _spokenResults(
    BuildContext context,
    ExploreResults? results,
    int count,
  ) {
    final l = context.l10n;
    final brokers = model.segment == ExploreSegment.brokers;
    final heads = <String>[
      if (results != null && brokers)
        for (final b in results.brokers.take(3))
          '${b.broker.name}, ${WkFormat.distance(l, b.distanceMeters)}'
      else if (results != null)
        for (final p in results.properties.take(3))
          '${p.title}, ${WkFormat.priceSpoken(l, p.price, monthly: p.transaction == TransactionKind.rent)}',
    ];
    return [l.exploreResults(count), ...heads].join('. ');
  }

  String _label(l, _Quick q) => switch (q) {
    _Quick.rent => l.transactionRent,
    _Quick.sale => l.transactionSale,
    _ => WkFormat.propertyKind(l, PropertyKind.values.byName(q.name)),
  };
  IconData _icon(_Quick q) => switch (q) {
    _Quick.rent => FIcons.key,
    _Quick.sale => FIcons.tag,
    _ => WkFormat.propertyKindIcon(PropertyKind.values.byName(q.name)),
  };

  Widget _body(BuildContext context) {
    final l = context.l10n;
    final state = model.state;
    if (!widget.showAll && model.filters.isEmpty)
      return _Browse(onPick: (v) => _query.text = v);
    if (state.isLoading || state is ScreenInitial<ExploreResults>)
      return const AppSkeleton(rows: 3, height: 220);
    final failure = state.map(
      initial: () => null,
      loading: () => null,
      empty: () => null,
      error: (f) => f,
      data: (_) => null,
    );
    if (failure != null)
      return failureState(
        context,
        failure,
        onRetry: () => model.search(_query.text),
      );
    final results = state.valueOrNull;
    final count = results?.countFor(model.segment) ?? 0;
    if (results == null || count == 0) {
      return AppState(
        kind: AppStateKind.empty,
        title: l.exploreEmptyTitle,
        message: l.exploreSearchNoMatch,
        actionLabel: model.filters.activeCount == 0
            ? null
            : l.exploreClearFilters,
        onAction: model.clearFilters,
      );
    }
    final header = Padding(
      padding: const EdgeInsets.fromLTRB(
        Insets.page,
        Insets.sm,
        Insets.page,
        0,
      ),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              liveRegion: true,
              child: Text(
                l.exploreResults(count),
                style: context.text.titleMedium,
              ),
            ),
          ),
          AppListenButton(text: () => _spokenResults(context, results, count)),
          AppButton(
            model.view == ExploreView.map
                ? l.exploreShowList
                : l.exploreShowMap,
            icon: model.view == ExploreView.map ? FIcons.list : FIcons.map,
            variant: AppButtonVariant.ghost,
            size: Touch.compact,
            onPressed: () => model.selectView(
              model.view == ExploreView.map
                  ? ExploreView.list
                  : ExploreView.map,
            ),
          ),
        ],
      ),
    );
    if (model.view == ExploreView.map) {
      final brokers = model.segment == ExploreSegment.brokers;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(Insets.page),
              child: ResultsMap(
                center: model.position,
                markers: brokers
                    ? [
                        for (final b in results.brokers)
                          MapMarker(
                            id: b.broker.id,
                            position: b.broker.position,
                            title: b.broker.name,
                            detail: WkFormat.distance(l, b.distanceMeters),
                          ),
                      ]
                    : [
                        for (final p in results.properties)
                          MapMarker(
                            id: p.id,
                            position: p.position,
                            title: p.title,
                            detail:
                                '${WkFormat.price(l, p.price, p.transaction)}'
                                ' · '
                                '${WkFormat.distance(l, distanceMeters(model.position, p.position))}',
                          ),
                      ],
                onSelect: brokers ? widget.onOpenBroker : widget.onOpenProperty,
              ),
            ),
          ),
        ],
      );
    }
    final hints = _query.text.trim().isEmpty
        ? const <String>[]
        : model.searchSuggestions
              .where((s) => s.toLowerCase() != _query.text.trim().toLowerCase())
              .take(3)
              .toList();
    return ListView(
      key: PageStorageKey(model.segment),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.only(bottom: Insets.xxxl),
      children: [
        if (hints.isNotEmpty)
          AppCard.rows([
            for (final h in hints)
              AppRow(
                leading: const Icon(FIcons.search),
                title: h,
                onTap: () {
                  _query.text = h;
                },
              ),
          ]),
        header,
        for (var i = 0; i < count; i++)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Insets.page,
              Insets.lg,
              Insets.page,
              0,
            ),
            child: model.segment == ExploreSegment.brokers
                ? BrokerCard(
                    listing: results.brokers[i],
                    onTap: () =>
                        widget.onOpenBroker(results.brokers[i].broker.id),
                  )
                : PropertyCard(
                    property: results.properties[i],
                    distanceMeters: distanceMeters(
                      model.position,
                      results.properties[i].position,
                    ),
                    onTap: () =>
                        widget.onOpenProperty(results.properties[i].id),
                  ),
          ),
        if (model.hasMore)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Insets.page,
              Insets.lg,
              Insets.page,
              0,
            ),
            child: AppButton(
              l.exploreLoadMore,
              icon: FIcons.chevronDown,
              variant: AppButtonVariant.secondary,
              loading: model.loadingMore,
              onPressed: model.loadMore,
            ),
          ),
      ],
    );
  }
}

class _Browse extends StatelessWidget {
  const _Browse({required this.onPick});
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return ListView(
      padding: const EdgeInsets.only(bottom: Insets.xxxl),
      children: [
        AppSection(l.exploreBrowseAreas),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Insets.page),
          child: Wrap(
            spacing: Insets.sm,
            runSpacing: Insets.sm,
            children: [
              for (final n in dakarNeighbourhoods)
                AppPill(
                  n.name,
                  selected: false,
                  icon: FIcons.mapPin,
                  onTap: () => onPick(n.name),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
