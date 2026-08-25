import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:woutalma_keur/app/core/location/client_position_controller.dart';
import 'package:woutalma_keur/app/core/state/screen_state.dart';
import 'package:woutalma_keur/app/domain/discovery.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/location_service.dart';
import 'package:woutalma_keur/app/domain/ranking.dart';
import 'package:woutalma_keur/app/modules/client/explore/cards.dart';
import 'package:woutalma_keur/app/modules/client/explore/explore_view_model.dart';
import 'package:woutalma_keur/app/modules/client/explore/location_permission_flow.dart';
import 'package:woutalma_keur/app/modules/client/explore/location_sheet.dart';
import 'package:woutalma_keur/app/modules/client/explore/search_overlay.dart';
import 'package:woutalma_keur/app/shared/formatters.dart';
import 'package:woutalma_keur/app/ui/ui.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({
    super.key,
    required this.onOpenBroker,
    required this.onOpenProperty,
    required this.onOpenSettings,
    required this.location,
  });
  final void Function(String brokerId) onOpenBroker;
  final void Function(String propertyId) onOpenProperty;
  final VoidCallback onOpenSettings;
  final LocationService location;
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _Category {
  const _Category(this.label, this.icon, this.filters, this.segment);
  final String label;
  final IconData icon;
  final DiscoveryFilters filters;
  final ExploreSegment segment;
}

class _ExploreScreenState extends State<ExploreScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _primeLocation());
  }

  Future<void> _primeLocation() async {
    final positions = context.read<ClientPositionController>();
    if (!mounted) return;
    if (positions.hasBeenPrimed) return positions.refreshIfPermitted();
    await requestClientPosition(
      context,
      positions,
      offerSettingsOnPermanentDenial: false,
    );
  }

  Future<void> _open(
    ExploreViewModel model, {
    DiscoveryFilters? filters,
    ExploreSegment? segment,
    ExploreView? view,
    bool autofocus = false,
    bool showAll = true,
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
      showAll: showAll,
    );
  }

  Future<void> _openPlace(ExploreViewModel model) async {
    final place = await LocationSheet.show(
      context,
      service: widget.location,
      positions: context.read<ClientPositionController>(),
      recents: model.recentPlaces,
    );
    if (place != null) await model.moveTo(place);
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ExploreViewModel>();
    final positions = context.watch<ClientPositionController>();
    final l = context.l10n;
    final categories = [
      _Category(
        l.exploreCategoryAll,
        FIcons.layoutGrid,
        const DiscoveryFilters(),
        ExploreSegment.properties,
      ),
      _Category(
        l.transactionRent,
        FIcons.key,
        const DiscoveryFilters(transaction: TransactionKind.rent),
        ExploreSegment.properties,
      ),
      _Category(
        l.transactionSale,
        FIcons.tag,
        const DiscoveryFilters(transaction: TransactionKind.sale),
        ExploreSegment.properties,
      ),
      for (final k in PropertyKind.values)
        _Category(
          WkFormat.propertyKind(l, k),
          WkFormat.propertyKindIcon(k),
          DiscoveryFilters(kind: k),
          ExploreSegment.properties,
        ),
      _Category(
        l.exploreSegmentBrokers,
        FIcons.users,
        const DiscoveryFilters(),
        ExploreSegment.brokers,
      ),
    ];
    final place =
        model.placeName ??
        (model.isOutsideServiceArea ? l.exploreDefaultArea : l.exploreNearYou);

    return AppScaffold(
      showBack: false,
      actions: [
        AppIconButton(
          icon: FIcons.settings,
          label: l.settingsTitle,
          onTap: widget.onOpenSettings,
        ),
      ],
      onRefresh: model.load,
      body: ListView(
        padding: const EdgeInsets.only(bottom: 120),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Insets.page,
              0,
              Insets.page,
              Insets.lg,
            ),
            child: FTappable(
              onPress: () => _openPlace(model),
              semanticsLabel: l.exploreChooseArea,
              excludeSemantics: true,
              child: Row(
                children: [
                  Expanded(
                    child: Text(place, style: context.text.displayMedium),
                  ),
                  Icon(FIcons.chevronDown, color: context.colors.onSurface),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Insets.page),
            child: AppSearchPill(
              hint: l.exploreSearchHint,
              onTap: () => _open(
                model,
                filters: const DiscoveryFilters(),
                segment: ExploreSegment.properties,
                autofocus: true,
                showAll: false,
              ),
            ),
          ),
          const SizedBox(height: Insets.lg),
          AppChoice<_Category>(
            scroll: true,
            options: categories,
            selected: null,
            label: (c) => c.label,
            icon: (c) => c.icon,
            onChanged: (c) =>
                _open(model, filters: c.filters, segment: c.segment),
          ),
          if (!positions.isFromGps && model.placeName == null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Insets.page,
                Insets.xl,
                Insets.page,
                0,
              ),
              child: AppCard.rows([
                AppRow(
                  leading: const Icon(FIcons.navigation),
                  title: l.exploreEnableLocationTitle,
                  subtitle: l.exploreEnableLocationBody,
                  onTap: () => requestClientPosition(
                    context,
                    positions,
                    offerSettingsOnPermanentDenial: true,
                  ),
                ),
              ]),
            ),
          model.home.map(
            initial: () => const SizedBox.shrink(),
            loading: () => Skeletonizer(
              child: _Sections(
                results: _placeholder,
                model: model,
                onOpenBroker: (_) {},
                onOpenProperty: (_) {},
                onSeeAll: (_) {},
                onMap: () {},
              ),
            ),
            empty: () => AppState(
              kind: AppStateKind.empty,
              title: l.exploreEmptyTitle,
              message: l.exploreEmptyBody,
              actionLabel: l.exploreChooseArea,
              onAction: () => _openPlace(model),
            ),
            error: (WkFailure f) =>
                failureState(context, f, onRetry: model.load),
            data: (results) => _Sections(
              results: results,
              model: model,
              onOpenBroker: widget.onOpenBroker,
              onOpenProperty: widget.onOpenProperty,
              onSeeAll: (s) =>
                  _open(model, filters: const DiscoveryFilters(), segment: s),
              onMap: () => _open(
                model,
                filters: const DiscoveryFilters(),
                segment: ExploreSegment.properties,
                view: ExploreView.map,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Sections extends StatelessWidget {
  const _Sections({
    required this.results,
    required this.model,
    required this.onOpenBroker,
    required this.onOpenProperty,
    required this.onSeeAll,
    required this.onMap,
  });
  final ExploreResults results;
  final ExploreViewModel model;
  final void Function(String) onOpenBroker, onOpenProperty;
  final void Function(ExploreSegment) onSeeAll;
  final VoidCallback onMap;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final nearby = results.properties.take(8).toList();
    final newest = results.newest.take(8).toList();
    final brokers = results.brokers.take(8).toList();
    final scale = MediaQuery.textScalerOf(context);
    Widget props(List<Property> list) => AppStrip(
      height: 150 + scale.scale(124),
      children: [
        for (final p in list)
          PropertyCard(
            property: p,
            distanceMeters: distanceMeters(model.position, p.position),
            onTap: () => onOpenProperty(p.id),
            width: 240,
          ),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (nearby.isNotEmpty) ...[
          AppSection(
            l.exploreNearbyProperties,
            action: l.exploreSeeAll,
            onAction: () => onSeeAll(ExploreSegment.properties),
          ),
          props(nearby),
        ],
        if (brokers.isNotEmpty) ...[
          AppSection(
            l.exploreTrustedBrokers,
            action: l.exploreSeeAll,
            onAction: () => onSeeAll(ExploreSegment.brokers),
          ),
          AppStrip(
            height: 150 + scale.scale(160),
            children: [
              for (final b in brokers)
                BrokerCard(
                  listing: b,
                  onTap: () => onOpenBroker(b.broker.id),
                  width: 200,
                ),
            ],
          ),
        ],
        if (newest.length > 1) ...[
          AppSection(
            l.exploreNewListings,
            action: l.exploreSeeAll,
            onAction: () => onSeeAll(ExploreSegment.properties),
          ),
          props(newest),
        ],
        const SizedBox(height: Insets.xl),
        Center(
          child: AppButton(
            l.exploreShowMap,
            icon: FIcons.map,
            variant: AppButtonVariant.secondary,
            onPressed: onMap,
          ),
        ),
      ],
    );
  }
}

final _placeholder = ExploreResults(
  brokers: List.generate(
    3,
    (i) => BrokerListing(
      broker: Broker(
        id: 's$i',
        kind: BrokerKind.individual,
        name: 'Courtier Dakar',
        phone: '',
        position: const GeoPoint(0, 0),
        coverage: const [],
      ),
      distanceMeters: 1200,
      averageRating: 4,
      reviewCount: 3,
      availableProperties: 2,
      score: 0,
    ),
  ),
  properties: List.generate(
    3,
    (i) => Property(
      id: 's$i',
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
