import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/core/location/client_position_controller.dart';
import 'package:woutalma_keur/app/modules/client/explore/location_permission_flow.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_connection_banner.dart';
import 'package:woutalma_keur/app/core/state/screen_state.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/ranking.dart';
import 'package:woutalma_keur/app/domain/discovery.dart';
import 'package:woutalma_keur/app/modules/client/explore/explore_view_model.dart';
import 'package:woutalma_keur/app/domain/location_service.dart';
import 'package:woutalma_keur/app/modules/client/explore/filters_sheet.dart';
import 'package:woutalma_keur/app/modules/client/explore/location_sheet.dart';
import 'package:woutalma_keur/app/modules/client/explore/results_map.dart';
import 'package:woutalma_keur/app/modules/client/explore/search_overlay.dart';
import 'package:woutalma_keur/app/shared/formatters.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_button.dart';
import 'package:woutalma_keur/app/shared/theme/wk_spacing.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_broker_card.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_icon_button.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_property_card.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_scaffold.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_search_bar.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_segmented_control.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_states.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_top_bar.dart';

/// C01 — Explorer.
///
/// Premier écran du parcours client, et le seul qui doive tenir la promesse
/// des trois écrans : d'ici, un contact est à deux gestes.
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

  /// Position du téléphone et quartiers connus.
  final LocationService location;

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  @override
  void initState() {
    super.initState();
    // Décision C : le GPS est la position par défaut. On explique d'abord —
    // M06 — puis le système demande. Une seule fois dans la vie de
    // l'installation : `docs/screen-contracts/client-discovery.md` interdit
    // toute boucle de permission, donc un refus ne se redemande jamais au
    // lancement suivant. Le bouton GPS de M02 reste la porte de rattrapage.
    WidgetsBinding.instance.addPostFrameCallback((_) => _primeLocation());
  }

  Future<void> _primeLocation() async {
    final ClientPositionController positions = context
        .read<ClientPositionController>();
    if (positions.hasBeenPrimed || !mounted) {
      return;
    }
    await requestClientPosition(
      context,
      positions,
      // Au premier lancement, enchaîner « ouvrez les réglages » sur un refus
      // serait la relance que le contrat interdit.
      offerSettingsOnPermanentDenial: false,
    );
  }

  Future<void> _openSearch(BuildContext context, ExploreViewModel model) {
    return SearchOverlay.show(context, model: model);
  }

  Future<void> _openPlace(BuildContext context, ExploreViewModel model) async {
    final Neighbourhood? place = await LocationSheet.show(
      context,
      service: widget.location,
      recents: model.recentPlaces,
    );
    if (place != null) {
      await model.moveTo(place);
    }
  }

  Future<void> _openFilters(
    BuildContext context,
    ExploreViewModel model,
  ) async {
    final DiscoveryFilters? applied = await FiltersSheet.show(
      context,
      initial: model.filters,
      countResults: model.previewCount,
    );
    if (applied != null) {
      await model.applyFilters(applied);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ExploreViewModel model = context.watch<ExploreViewModel>();

    return WkScaffold(
      extendBody: true,
      topBar: WkTopBar(
        title: model.placeName ?? context.l10n.exploreNearYou,
        onBack: null,
        action: WkIconButton(
          icon: Icons.settings_outlined,
          label: context.l10n.settingsTitle,
          onPressed: widget.onOpenSettings,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const WkConnectionBanner(),
          const SizedBox(height: WkSpacing.sm),
          // Seule pièce épinglée. Filtres, segments et compteur défilent avec
          // les résultats : trois blocs figés au-dessus d'une liste ne
          // laissaient voir qu'une carte et demie sur un écran de 5 pouces.
          WkSearchTrigger(
            hint: context.l10n.exploreSearchHint,
            semanticLabel: context.l10n.exploreSearchOpen,
            query: model.filters.query,
            onOpen: () => _openSearch(context, model),
          ),
          Expanded(
            child: _Body(
              model: model,
              screen: widget,
              onFilters: () => _openFilters(context, model),
              onPlace: () => _openPlace(context, model),
            ),
          ),
        ],
      ),
    );
  }
}

/// Filtres, quartier et segments. Défile avec les résultats.
class _Controls extends StatelessWidget {
  const _Controls({
    required this.model,
    required this.onFilters,
    required this.onPlace,
  });

  final ExploreViewModel model;
  final VoidCallback onFilters;
  final VoidCallback onPlace;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: WkSpacing.betweenTargets),
        Row(
          children: <Widget>[
            Expanded(
              child: WkButton(
                label: context.l10n.filtersActive(model.filters.activeCount),
                icon: Icons.tune,
                variant: WkButtonVariant.secondary,
                onPressed: onFilters,
              ),
            ),
            const SizedBox(width: WkSpacing.betweenTargets),
            Expanded(
              child: WkButton(
                label: model.placeName ?? context.l10n.locationShort,
                icon: Icons.place_outlined,
                variant: WkButtonVariant.secondary,
                onPressed: onPlace,
              ),
            ),
          ],
        ),
        const SizedBox(height: WkSpacing.lg),
        _ActiveFilters(model: model),
        WkSegmentedControl<ExploreSegment>(
          value: model.segment,
          onChanged: model.selectSegment,
          segments: <(ExploreSegment, String)>[
            (ExploreSegment.brokers, context.l10n.exploreSegmentBrokers),
            (ExploreSegment.properties, context.l10n.exploreSegmentProperties),
          ],
        ),
        const SizedBox(height: WkSpacing.md),
      ],
    );
  }
}

class _ActiveFilters extends StatelessWidget {
  const _ActiveFilters({required this.model});

  final ExploreViewModel model;

  @override
  Widget build(BuildContext context) {
    final DiscoveryFilters filters = model.filters;
    if (filters.activeCount == 0) {
      return const SizedBox.shrink();
    }
    final List<Widget> chips = <Widget>[
      if (filters.transaction != null)
        _FilterChip(
          label: WkFormat.transaction(context.l10n, filters.transaction!),
          icon: Icons.sell_outlined,
          onRemove: () =>
              model.applyFilters(filters.copyWith(clearTransaction: true)),
        ),
      if (filters.kind != null)
        _FilterChip(
          label: WkFormat.propertyKind(context.l10n, filters.kind!),
          icon: WkFormat.propertyKindIcon(filters.kind!),
          onRemove: () => model.applyFilters(filters.copyWith(clearKind: true)),
        ),
      if (filters.maxPrice != null)
        _FilterChip(
          label: context.l10n.filtersPriceValue(
            NumberFormat('#,##0', 'fr').format(filters.maxPrice),
          ),
          icon: Icons.payments_outlined,
          onRemove: () =>
              model.applyFilters(filters.copyWith(clearMaxPrice: true)),
        ),
      if (filters.radiusMeters != null)
        _FilterChip(
          label: context.l10n.filtersRadiusValue(
            (filters.radiusMeters! / 1000).round(),
          ),
          icon: Icons.place_outlined,
          onRemove: () =>
              model.applyFilters(filters.copyWith(clearRadius: true)),
        ),
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: WkSpacing.md),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <Widget>[
            for (int i = 0; i < chips.length; i++) ...<Widget>[
              chips[i],
              if (i < chips.length - 1) const SizedBox(width: WkSpacing.sm),
            ],
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.icon,
    required this.onRemove,
  });

  final String label;
  final IconData icon;
  final Future<void> Function() onRemove;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: context.colors.primaryContainer,
        borderRadius: BorderRadius.circular(WkRadius.full),
        child: InkWell(
          onTap: () => unawaited(onRemove()),
          borderRadius: BorderRadius.circular(WkRadius.full),
          child: Container(
            constraints: const BoxConstraints(minHeight: WkTouch.min),
            padding: const EdgeInsetsDirectional.only(
              start: WkSpacing.md,
              end: WkSpacing.sm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(icon, size: 18, color: context.colors.onPrimaryContainer),
                const SizedBox(width: WkSpacing.xs),
                Text(
                  label,
                  style: context.text.labelMedium?.copyWith(
                    color: context.colors.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: WkSpacing.xs),
                Icon(
                  Icons.close,
                  size: 18,
                  color: context.colors.onPrimaryContainer,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.model,
    required this.screen,
    required this.onFilters,
    required this.onPlace,
  });

  final ExploreViewModel model;
  final ExploreScreen screen;
  final VoidCallback onFilters;
  final VoidCallback onPlace;

  @override
  Widget build(BuildContext context) {
    final Widget controls = _Controls(
      model: model,
      onFilters: onFilters,
      onPlace: onPlace,
    );

    return model.state.map(
      initial: () => controls,
      loading: () => _Scrolled(
        controls: controls,
        sliver: const SliverFillRemaining(
          hasScrollBody: false,
          child: WkLoadingState(),
        ),
      ),
      empty: () => _Scrolled(
        controls: controls,
        sliver: SliverFillRemaining(
          hasScrollBody: false,
          child: WkEmptyState(
            title: context.l10n.exploreEmptyTitle,
            body: context.l10n.exploreEmptyBody,
            actionLabel: model.filters.isEmpty
                ? null
                : context.l10n.exploreClearFilters,
            onAction: model.filters.isEmpty ? null : model.clearFilters,
          ),
        ),
      ),
      error: (WkFailure failure) => _Scrolled(
        controls: controls,
        sliver: SliverFillRemaining(
          hasScrollBody: false,
          child: WkErrorState(failure: failure, onRetry: model.load),
        ),
      ),
      data: (ExploreResults results) => _Results(
        results: results,
        model: model,
        screen: screen,
        controls: controls,
      ),
    );
  }
}

/// Coquille de défilement commune : les commandes en tête, l'état en dessous.
///
/// Les commandes vivent **dans** le défilement, pas au-dessus : c'est ce qui
/// rend la liste au premier plan dès qu'on pousse le pouce.
class _Scrolled extends StatelessWidget {
  const _Scrolled({required this.controls, required this.sliver});

  final Widget controls;
  final Widget sliver;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(child: controls),
        sliver,
      ],
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({
    required this.results,
    required this.model,
    required this.screen,
    required this.controls,
  });

  final ExploreResults results;
  final ExploreViewModel model;
  final ExploreScreen screen;
  final Widget controls;

  Widget _card(BuildContext context, int index) {
    if (model.segment == ExploreSegment.brokers) {
      final BrokerListing listing = results.brokers[index];
      return WkBrokerCard(
        listing: listing,
        onOpen: () => screen.onOpenBroker(listing.broker.id),
      );
    }
    final Property property = results.properties[index];
    return WkPropertyCard(
      property: property,
      distanceMeters: distanceMeters(model.position, property.position),
      onOpen: () => screen.onOpenProperty(property.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int count = results.countFor(model.segment);
    final Widget header = _ResultsHeader(model: model, count: count);

    // La carte ne défile pas : elle se manipule, et une carte posée dans une
    // liste vole le geste de défilement à celui qui voulait lire la suite.
    if (model.view == ExploreView.map) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          controls,
          header,
          const SizedBox(height: WkSpacing.sm),
          Expanded(
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
                  ? screen.onOpenBroker(id)
                  : screen.onOpenProperty(id),
            ),
          ),
          SizedBox(height: WkScaffold.bottomInset(context) + WkSpacing.sm),
        ],
      );
    }

    if (count == 0) {
      return _Scrolled(
        controls: controls,
        sliver: SliverFillRemaining(
          hasScrollBody: false,
          child: WkEmptyState(
            title: context.l10n.exploreEmptyTitle,
            body: context.l10n.exploreEmptyBody,
          ),
        ),
      );
    }

    return CustomScrollView(
      // La position de défilement survit au retour d'une fiche.
      key: PageStorageKey<ExploreSegment>(model.segment),
      slivers: <Widget>[
        SliverToBoxAdapter(child: controls),
        SliverToBoxAdapter(child: header),
        const SliverToBoxAdapter(child: SizedBox(height: WkSpacing.sm)),
        SliverList.separated(
          itemCount: count,
          separatorBuilder: (_, _) => const SizedBox(height: WkSpacing.sm),
          itemBuilder: _card,
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: WkScaffold.bottomInset(context) + WkSpacing.md,
          ),
        ),
      ],
    );
  }
}

/// Nombre de résultats et bascule liste/carte.
class _ResultsHeader extends StatelessWidget {
  const _ResultsHeader({required this.model, required this.count});

  final ExploreViewModel model;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
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
        // La bascule vit ici, à côté du nombre de résultats : la carte
        // existait déjà mais rien à l'écran n'y menait, donc personne ne
        // pouvait l'atteindre. Elle se demande, elle ne s'impose pas — elle
        // télécharge des tuiles, donc de la data.
        WkButton(
          label: model.view == ExploreView.map
              ? context.l10n.exploreShowList
              : context.l10n.exploreShowMap,
          icon: model.view == ExploreView.map ? Icons.list : Icons.map_outlined,
          variant: WkButtonVariant.ghost,
          expand: false,
          onPressed: () => model.selectView(
            model.view == ExploreView.map ? ExploreView.list : ExploreView.map,
          ),
        ),
      ],
    );
  }
}
