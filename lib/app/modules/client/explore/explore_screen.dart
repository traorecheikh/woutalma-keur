import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:woutalma_keur/app/core/location/client_position_controller.dart';
import 'package:woutalma_keur/app/core/state/screen_state.dart';
import 'package:woutalma_keur/app/domain/discovery.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/location_service.dart';
import 'package:woutalma_keur/app/domain/ranking.dart';
import 'package:woutalma_keur/app/modules/client/explore/explore_view_model.dart';
import 'package:woutalma_keur/app/modules/client/explore/location_permission_flow.dart';
import 'package:woutalma_keur/app/modules/client/explore/location_sheet.dart';
import 'package:woutalma_keur/app/modules/client/explore/search_overlay.dart';
import 'package:woutalma_keur/app/shared/formatters.dart';
import 'package:woutalma_keur/app/shared/theme/wk_spacing.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_broker_tile.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_button.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_chip_group.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_icon_button.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_property_tile.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_scaffold.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_search_bar.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_section_header.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_states.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_top_bar.dart';

/// C01 — Accueil. Recherche, catégories, puis des rangées qui défilent :
/// près de chez vous, courtiers de confiance, nouveautés. La liste complète
/// vit dans M14.
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({
    required this.onOpenBroker,
    required this.onOpenProperty,
    required this.onOpenSettings,
    required this.location,
    super.key,
  });

  final void Function(String brokerId) onOpenBroker;
  final void Function(String propertyId) onOpenProperty;
  final VoidCallback onOpenSettings;
  final LocationService location;

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _primeLocation());
  }

  Future<void> _primeLocation() async {
    final ClientPositionController positions = context
        .read<ClientPositionController>();
    if (!mounted) return;
    if (positions.hasBeenPrimed) {
      await positions.refreshIfPermitted();
      return;
    }
    await requestClientPosition(
      context,
      positions,
      offerSettingsOnPermanentDenial: false,
    );
  }

  Future<void> _openSearch(
    ExploreViewModel model, {
    DiscoveryFilters? filters,
    ExploreSegment? segment,
    ExploreView? view,
    bool autofocus = false,
  }) async {
    if (segment != null) model.selectSegment(segment);
    if (view != null) model.selectView(view);
    if (filters != null) await model.applyFilters(filters);
    if (!mounted) return;
    await SearchOverlay.show(
      context,
      model: model,
      onOpenBroker: widget.onOpenBroker,
      onOpenProperty: widget.onOpenProperty,
      autofocus: autofocus,
    );
  }

  Future<void> _openPlace(ExploreViewModel model) async {
    final Neighbourhood? place = await LocationSheet.show(
      context,
      service: widget.location,
      positions: context.read<ClientPositionController>(),
      recents: model.recentPlaces,
    );
    if (place != null) await model.moveTo(place);
  }

  @override
  Widget build(BuildContext context) {
    final ExploreViewModel model = context.watch<ExploreViewModel>();
    final ClientPositionController positions = context
        .watch<ClientPositionController>();

    return WkScaffold(
      extendBody: true,
      padHorizontal: false,
      topBar: WkTopBar(
        title:
            model.placeName ??
            (model.isOutsideServiceArea
                ? context.l10n.exploreDefaultArea
                : context.l10n.exploreNearYou),
        onBack: null,
        action: WkIconButton(
          icon: Icons.settings_outlined,
          label: context.l10n.settingsTitle,
          onPressed: widget.onOpenSettings,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: model.load,
        color: context.colors.primary,
        child: ListView(
          padding: EdgeInsets.only(
            bottom: WkScaffold.bottomInset(context) + WkSpacing.lg,
          ),
          children: <Widget>[
            const SizedBox(height: WkSpacing.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: WkSpacing.page),
              child: WkSearchTrigger(
                hint: context.l10n.exploreSearchHint,
                semanticLabel: context.l10n.exploreSearchOpen,
                onOpen: () => _openSearch(
                  model,
                  filters: const DiscoveryFilters(),
                  segment: ExploreSegment.properties,
                  autofocus: true,
                ),
              ),
            ),
            const SizedBox(height: WkSpacing.md),
            WkChipGroup<_Category>(
              chips: <WkChip<_Category>>[
                WkChip<_Category>(
                  value: _Category.all,
                  label: context.l10n.exploreCategoryAll,
                  icon: Icons.grid_view_outlined,
                ),
                WkChip<_Category>(
                  value: _Category.rent,
                  label: context.l10n.transactionRent,
                  icon: Icons.vpn_key_outlined,
                ),
                WkChip<_Category>(
                  value: _Category.sale,
                  label: context.l10n.transactionSale,
                  icon: Icons.sell_outlined,
                ),
                for (final PropertyKind kind in PropertyKind.values)
                  WkChip<_Category>(
                    value: _Category.kinds[kind]!,
                    label: WkFormat.propertyKind(context.l10n, kind),
                    icon: WkFormat.propertyKindIcon(kind),
                  ),
                WkChip<_Category>(
                  value: _Category.brokers,
                  label: context.l10n.exploreSegmentBrokers,
                  icon: Icons.support_agent_outlined,
                ),
              ],
              selected: null,
              onSelected: (_Category c) =>
                  _openSearch(model, filters: c.filters, segment: c.segment),
            ),
            if (!positions.isFromGps && model.placeName == null) ...<Widget>[
              const SizedBox(height: WkSpacing.lg),
              _LocationPrompt(
                onEnable: () => requestClientPosition(
                  context,
                  positions,
                  offerSettingsOnPermanentDenial: true,
                ),
                onChoose: () => _openPlace(model),
              ),
            ],
            const SizedBox(height: WkSpacing.lg),
            _Sections(
              model: model,
              onOpenBroker: widget.onOpenBroker,
              onOpenProperty: widget.onOpenProperty,
              onSeeAll: (ExploreSegment segment) => _openSearch(
                model,
                filters: const DiscoveryFilters(),
                segment: segment,
              ),
              onOpenMap: () => _openSearch(
                model,
                filters: const DiscoveryFilters(),
                segment: ExploreSegment.properties,
                view: ExploreView.map,
              ),
              onChangePlace: () => _openPlace(model),
            ),
          ],
        ),
      ),
    );
  }
}

class _Category {
  const _Category(this.filters, this.segment);

  final DiscoveryFilters filters;
  final ExploreSegment segment;

  static const _Category all = _Category(
    DiscoveryFilters(),
    ExploreSegment.properties,
  );
  static const _Category rent = _Category(
    DiscoveryFilters(transaction: TransactionKind.rent),
    ExploreSegment.properties,
  );
  static const _Category sale = _Category(
    DiscoveryFilters(transaction: TransactionKind.sale),
    ExploreSegment.properties,
  );
  static const _Category brokers = _Category(
    DiscoveryFilters(),
    ExploreSegment.brokers,
  );
  static final Map<PropertyKind, _Category> kinds = <PropertyKind, _Category>{
    for (final PropertyKind kind in PropertyKind.values)
      kind: _Category(DiscoveryFilters(kind: kind), ExploreSegment.properties),
  };
}

class _LocationPrompt extends StatelessWidget {
  const _LocationPrompt({required this.onEnable, required this.onChoose});

  final VoidCallback onEnable;
  final VoidCallback onChoose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: WkSpacing.page),
      child: Container(
        padding: const EdgeInsets.all(WkSpacing.md),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(WkRadius.xl),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.near_me_outlined, color: context.colors.primary),
                const SizedBox(width: WkSpacing.sm),
                Expanded(
                  child: Text(
                    context.l10n.exploreEnableLocationTitle,
                    style: context.text.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: WkSpacing.xs),
            Text(
              context.l10n.exploreEnableLocationBody,
              style: context.text.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: WkSpacing.sm),
            WkButton(
              label: context.l10n.exploreEnableLocationTitle,
              icon: Icons.my_location,
              variant: WkButtonVariant.secondary,
              onPressed: onEnable,
            ),
            const SizedBox(height: WkSpacing.xs),
            WkButton(
              label: context.l10n.exploreChooseArea,
              icon: Icons.place_outlined,
              variant: WkButtonVariant.ghost,
              onPressed: onChoose,
            ),
          ],
        ),
      ),
    );
  }
}

class _Sections extends StatelessWidget {
  const _Sections({
    required this.model,
    required this.onOpenBroker,
    required this.onOpenProperty,
    required this.onSeeAll,
    required this.onOpenMap,
    required this.onChangePlace,
  });

  final ExploreViewModel model;
  final void Function(String brokerId) onOpenBroker;
  final void Function(String propertyId) onOpenProperty;
  final void Function(ExploreSegment segment) onSeeAll;
  final VoidCallback onOpenMap;
  final VoidCallback onChangePlace;

  @override
  Widget build(BuildContext context) {
    return model.home.map(
      initial: () => const SizedBox.shrink(),
      loading: () => Skeletonizer(child: _rows(context, _placeholder)),
      empty: () => WkEmptyState(
        title: context.l10n.exploreEmptyTitle,
        body: context.l10n.exploreEmptyBody,
        actionLabel: context.l10n.exploreChooseArea,
        onAction: onChangePlace,
      ),
      error: (WkFailure failure) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: WkSpacing.page),
        child: WkErrorState(failure: failure, onRetry: model.load),
      ),
      data: (ExploreResults results) => _rows(context, results),
    );
  }

  Widget _rows(BuildContext context, ExploreResults results) {
    final List<Property> nearby = results.properties.take(8).toList();
    final List<Property> newest = results.newest.take(8).toList();
    final List<BrokerListing> brokers = results.brokers.take(8).toList();
    final TextScaler scaler = MediaQuery.textScalerOf(context);
    final double propertyHeight = 150 + scaler.scale(116);
    final double brokerHeight = 92 + scaler.scale(150);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (nearby.isNotEmpty) ...<Widget>[
          WkSectionHeader(
            title: context.l10n.exploreNearbyProperties,
            actionLabel: context.l10n.exploreSeeAll,
            onAction: () => onSeeAll(ExploreSegment.properties),
          ),
          const SizedBox(height: WkSpacing.sm),
          _strip(
            height: propertyHeight,
            children: <Widget>[
              for (final Property p in nearby)
                WkPropertyTile(
                  property: p,
                  distanceMeters: distanceMeters(model.position, p.position),
                  onOpen: () => onOpenProperty(p.id),
                ),
            ],
          ),
          const SizedBox(height: WkSpacing.xl),
        ],
        if (brokers.isNotEmpty) ...<Widget>[
          WkSectionHeader(
            title: context.l10n.exploreTrustedBrokers,
            actionLabel: context.l10n.exploreSeeAll,
            onAction: () => onSeeAll(ExploreSegment.brokers),
          ),
          const SizedBox(height: WkSpacing.sm),
          _strip(
            height: brokerHeight,
            children: <Widget>[
              for (final BrokerListing l in brokers)
                WkBrokerTile(
                  listing: l,
                  onOpen: () => onOpenBroker(l.broker.id),
                ),
            ],
          ),
          const SizedBox(height: WkSpacing.xl),
        ],
        if (newest.length > 1) ...<Widget>[
          WkSectionHeader(
            title: context.l10n.exploreNewListings,
            actionLabel: context.l10n.exploreSeeAll,
            onAction: () => onSeeAll(ExploreSegment.properties),
          ),
          const SizedBox(height: WkSpacing.sm),
          _strip(
            height: propertyHeight,
            children: <Widget>[
              for (final Property p in newest)
                WkPropertyTile(
                  property: p,
                  distanceMeters: distanceMeters(model.position, p.position),
                  onOpen: () => onOpenProperty(p.id),
                ),
            ],
          ),
          const SizedBox(height: WkSpacing.lg),
        ],
        Center(
          child: WkButton(
            label: context.l10n.exploreShowMap,
            icon: Icons.map_outlined,
            variant: WkButtonVariant.ghost,
            expand: false,
            onPressed: onOpenMap,
          ),
        ),
      ],
    );
  }

  Widget _strip({required double height, required List<Widget> children}) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: WkSpacing.page),
        itemCount: children.length,
        separatorBuilder: (_, _) => const SizedBox(width: WkSpacing.md),
        itemBuilder: (_, int i) => children[i],
      ),
    );
  }

  static final ExploreResults _placeholder = ExploreResults(
    brokers: List<BrokerListing>.generate(
      3,
      (int i) => BrokerListing(
        broker: Broker(
          id: 'skeleton-$i',
          kind: BrokerKind.individual,
          name: 'Courtier Dakar',
          phone: '',
          position: const GeoPoint(0, 0),
          coverage: const <String>[],
        ),
        distanceMeters: 1200,
        averageRating: 4,
        reviewCount: 3,
        availableProperties: 2,
        score: 0,
      ),
    ),
    properties: List<Property>.generate(
      3,
      (int i) => Property(
        id: 'skeleton-$i',
        brokerId: '',
        kind: PropertyKind.apartment,
        transaction: TransactionKind.rent,
        title: 'Appartement 3 pièces à Mermoz',
        price: 250000,
        position: const GeoPoint(0, 0),
        neighbourhood: 'Mermoz',
        createdAt: DateTime(2026),
      ),
    ),
  );
}
