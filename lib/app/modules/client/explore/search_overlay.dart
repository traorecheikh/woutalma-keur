import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:woutalma_keur/app/core/state/screen_state.dart';
import 'package:woutalma_keur/app/domain/discovery.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/ranking.dart';
import 'package:woutalma_keur/app/modules/client/explore/explore_view_model.dart';
import 'package:woutalma_keur/app/modules/client/explore/filters_sheet.dart';
import 'package:woutalma_keur/app/modules/client/explore/results_map.dart';
import 'package:woutalma_keur/app/shared/formatters.dart';
import 'package:woutalma_keur/app/shared/theme/wk_spacing.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_broker_card.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_button.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_chip_group.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_property_card.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_scaffold.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_search_bar.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_segmented_control.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_states.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_top_bar.dart';

/// M14 — Résultats. Recherche, filtres, segments, liste ou carte. Les
/// résultats se mettent à jour pendant la frappe.
class SearchOverlay extends StatefulWidget {
  const SearchOverlay({
    required this.model,
    required this.onOpenBroker,
    required this.onOpenProperty,
    this.autofocus = false,
    super.key,
  });

  final ExploreViewModel model;
  final void Function(String brokerId) onOpenBroker;
  final void Function(String propertyId) onOpenProperty;

  /// Clavier ouvert d'emblée : seulement quand on vient de la barre.
  final bool autofocus;

  static Future<void> show(
    BuildContext context, {
    required ExploreViewModel model,
    required void Function(String brokerId) onOpenBroker,
    required void Function(String propertyId) onOpenProperty,
    bool autofocus = false,
  }) {
    return Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => SearchOverlay(
          model: model,
          onOpenBroker: onOpenBroker,
          onOpenProperty: onOpenProperty,
          autofocus: autofocus,
        ),
      ),
    );
  }

  @override
  State<SearchOverlay> createState() => _SearchOverlayState();
}

enum _Quick { rent, sale, apartment, house, land, studio, room }

class _SearchOverlayState extends State<SearchOverlay> {
  late final TextEditingController _query = TextEditingController(
    text: widget.model.filters.query,
  );

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_onModelChanged);
  }

  @override
  void dispose() {
    widget.model.removeListener(_onModelChanged);
    _query.dispose();
    super.dispose();
  }

  void _onModelChanged() {
    if (mounted) setState(() {});
  }

  ExploreViewModel get model => widget.model;

  void _select(String value) {
    _query.text = value;
    _query.selection = TextSelection.collapsed(offset: value.length);
    model.search(value);
  }

  _Quick? get _quickSelected {
    final DiscoveryFilters f = model.filters;
    if (f.kind != null) {
      return _Quick.values.byName(f.kind!.name);
    }
    return switch (f.transaction) {
      TransactionKind.rent => _Quick.rent,
      TransactionKind.sale => _Quick.sale,
      null => null,
    };
  }

  Future<void> _quick(_Quick q) {
    final DiscoveryFilters f = model.filters;
    final bool off = _quickSelected == q;
    return switch (q) {
      _Quick.rent || _Quick.sale => model.applyFilters(
        off
            ? f.copyWith(clearTransaction: true)
            : f.copyWith(
                transaction: q == _Quick.rent
                    ? TransactionKind.rent
                    : TransactionKind.sale,
                clearKind: true,
              ),
      ),
      _ => model.applyFilters(
        off
            ? f.copyWith(clearKind: true)
            : f.copyWith(kind: PropertyKind.values.byName(q.name)),
      ),
    };
  }

  Future<void> _openFilters() async {
    final DiscoveryFilters? applied = await FiltersSheet.show(
      context,
      initial: model.filters,
      countResults: model.previewCount,
    );
    if (applied != null) await model.applyFilters(applied);
  }

  @override
  Widget build(BuildContext context) {
    final bool searching = _query.text.trim().isNotEmpty;
    return WkScaffold(
      padHorizontal: false,
      topBar: WkTopBar(
        title: searching
            ? context.l10n.exploreSearchTitle
            : context.l10n.exploreSearchAll,
        onBack: () => Navigator.of(context).pop(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: WkSpacing.page),
            child: WkSearchBar(
              controller: _query,
              hint: context.l10n.exploreSearchHint,
              autofocus: widget.autofocus,
              onChanged: model.search,
            ),
          ),
          const SizedBox(height: WkSpacing.sm),
          _quickChips(context),
          const SizedBox(height: WkSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: WkSpacing.page),
            child: WkSegmentedControl<ExploreSegment>(
              value: model.segment,
              onChanged: model.selectSegment,
              segments: <(ExploreSegment, String)>[
                (
                  ExploreSegment.properties,
                  context.l10n.exploreSegmentProperties,
                ),
                (ExploreSegment.brokers, context.l10n.exploreSegmentBrokers),
              ],
            ),
          ),
          const SizedBox(height: WkSpacing.sm),
          Expanded(child: _body(context)),
        ],
      ),
    );
  }

  Widget _quickChips(BuildContext context) {
    final DiscoveryFilters f = model.filters;
    final int extra = <bool>[
      f.maxPrice != null,
      f.radiusMeters != null,
    ].where((bool b) => b).length;
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsetsDirectional.only(start: WkSpacing.page),
          child: WkChipGroup<String>(
            padding: EdgeInsets.zero,
            chips: <WkChip<String>>[
              WkChip<String>(
                value: 'filters',
                label: context.l10n.filtersActive(extra),
                icon: Icons.tune,
              ),
            ],
            selected: extra > 0 ? 'filters' : null,
            onSelected: (_) => _openFilters(),
          ),
        ),
        const SizedBox(width: WkSpacing.sm),
        Expanded(
          child: WkChipGroup<_Quick>(
            padding: const EdgeInsetsDirectional.only(end: WkSpacing.page),
            selected: _quickSelected,
            onSelected: _quick,
            chips: <WkChip<_Quick>>[
              WkChip<_Quick>(
                value: _Quick.rent,
                label: context.l10n.transactionRent,
                icon: Icons.vpn_key_outlined,
              ),
              WkChip<_Quick>(
                value: _Quick.sale,
                label: context.l10n.transactionSale,
                icon: Icons.sell_outlined,
              ),
              for (final PropertyKind kind in PropertyKind.values)
                WkChip<_Quick>(
                  value: _Quick.values.byName(kind.name),
                  label: WkFormat.propertyKind(context.l10n, kind),
                  icon: WkFormat.propertyKindIcon(kind),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _body(BuildContext context) {
    final ScreenState<ExploreResults> state = model.state;
    if (state.isLoading || state is ScreenInitial<ExploreResults>) {
      return const WkLoadingState();
    }
    final WkFailure? failure = state.map(
      initial: () => null,
      loading: () => null,
      empty: () => null,
      error: (WkFailure v) => v,
      data: (_) => null,
    );
    if (failure != null) {
      return WkErrorState(
        failure: failure,
        onRetry: () => model.search(_query.text),
      );
    }
    final ExploreResults? results = state.valueOrNull;
    final int count = results?.countFor(model.segment) ?? 0;
    if (results == null || count == 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: WkSpacing.page),
        child: WkEmptyState(
          icon: Icons.search_off,
          title: context.l10n.exploreEmptyTitle,
          body: context.l10n.exploreSearchNoMatch,
          actionLabel: model.filters.activeCount == 0
              ? null
              : context.l10n.exploreClearFilters,
          onAction: model.filters.activeCount == 0 ? null : model.clearFilters,
        ),
      );
    }

    final Widget header = Padding(
      padding: const EdgeInsets.symmetric(horizontal: WkSpacing.page),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Semantics(
              liveRegion: true,
              child: Text(
                context.l10n.exploreResults(count),
                style: context.text.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ),
          ),
          WkButton(
            label: model.view == ExploreView.map
                ? context.l10n.exploreShowList
                : context.l10n.exploreShowMap,
            icon: model.view == ExploreView.map
                ? Icons.list
                : Icons.map_outlined,
            variant: WkButtonVariant.ghost,
            expand: false,
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
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          header,
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: WkSpacing.page),
              child: ResultsMap(
                center: model.position,
                markers: model.segment == ExploreSegment.brokers
                    ? <(String, GeoPoint)>[
                        for (final BrokerListing l in results.brokers)
                          (l.broker.id, l.broker.position),
                      ]
                    : <(String, GeoPoint)>[
                        for (final Property p in results.properties)
                          (p.id, p.position),
                      ],
                onSelect: (String id) => model.segment == ExploreSegment.brokers
                    ? widget.onOpenBroker(id)
                    : widget.onOpenProperty(id),
              ),
            ),
          ),
          const SizedBox(height: WkSpacing.md),
        ],
      );
    }

    final List<String> hints = searchingHints(results);
    return ListView.builder(
      key: PageStorageKey<ExploreSegment>(model.segment),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.only(bottom: WkSpacing.lg),
      itemCount: hints.length + 1 + count,
      itemBuilder: (BuildContext context, int index) {
        if (index < hints.length) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(
              WkSpacing.page,
              0,
              WkSpacing.page,
              WkSpacing.xs,
            ),
            child: _Suggestion(
              label: hints[index],
              onTap: () => _select(hints[index]),
            ),
          );
        }
        if (index == hints.length) return header;
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            WkSpacing.page,
            WkSpacing.sm,
            WkSpacing.page,
            0,
          ),
          child: _result(results, index - hints.length - 1),
        );
      },
    );
  }

  List<String> searchingHints(ExploreResults results) {
    if (_query.text.trim().isEmpty) return const <String>[];
    return model.searchSuggestions
        .where(
          (String s) => s.toLowerCase() != _query.text.trim().toLowerCase(),
        )
        .take(3)
        .toList();
  }

  Widget _result(ExploreResults results, int index) {
    if (model.segment == ExploreSegment.brokers) {
      final BrokerListing listing = results.brokers[index];
      return WkBrokerCard(
        listing: listing,
        onOpen: () => widget.onOpenBroker(listing.broker.id),
      );
    }
    final Property property = results.properties[index];
    return WkPropertyCard(
      property: property,
      distanceMeters: distanceMeters(model.position, property.position),
      onOpen: () => widget.onOpenProperty(property.id),
    );
  }
}

class _Suggestion extends StatelessWidget {
  const _Suggestion({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(WkRadius.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(WkRadius.md),
          child: Container(
            constraints: const BoxConstraints(minHeight: WkTouch.min),
            padding: const EdgeInsets.symmetric(horizontal: WkSpacing.md),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.north_west,
                  size: WkIconSize.md,
                  color: context.colors.onSurfaceVariant,
                ),
                const SizedBox(width: WkSpacing.md),
                Expanded(
                  child: Text(
                    label,
                    style: context.text.bodyLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Étiquette d'un prix en FCFA, pour les curseurs de M01.
String formatPriceLabel(int value) => NumberFormat('#,##0', 'fr').format(value);
