import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:woutalma_keur/app/domain/discovery.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/shared/formatters.dart';
import 'package:woutalma_keur/app/shared/theme/wk_spacing.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_button.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_chip_group.dart';

/// M01 — Filtres. Pastilles pour les choix, curseurs pour les bornes, et le
/// nombre de résultats en direct sur le bouton.
class FiltersSheet extends StatefulWidget {
  const FiltersSheet({
    required this.initial,
    required this.countResults,
    super.key,
  });

  final DiscoveryFilters initial;
  final Future<int> Function(DiscoveryFilters filters) countResults;

  static Future<DiscoveryFilters?> show(
    BuildContext context, {
    required DiscoveryFilters initial,
    required Future<int> Function(DiscoveryFilters filters) countResults,
  }) {
    return showModalBottomSheet<DiscoveryFilters>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(WkRadius.xxl)),
      ),
      builder: (_) =>
          FiltersSheet(initial: initial, countResults: countResults),
    );
  }

  @override
  State<FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<FiltersSheet> {
  late DiscoveryFilters _draft = widget.initial;
  int? _preview;
  bool _previewFailed = false;
  Timer? _debounce;
  int _request = 0;

  static const List<int> _priceSteps = <int>[
    50000,
    100000,
    150000,
    250000,
    400000,
    600000,
    1000000,
    2500000,
    5000000,
    10000000,
    25000000,
    50000000,
    100000000,
  ];
  static const List<int> _radiusStepsKm = <int>[1, 2, 5, 10, 25];

  @override
  void initState() {
    super.initState();
    unawaited(_refresh());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    final int request = ++_request;
    int? count;
    try {
      count = await widget.countResults(_draft);
    } on Object {
      count = null;
    }
    if (!mounted || request != _request) return;
    setState(() {
      _preview = count;
      _previewFailed = count == null;
    });
  }

  void _update(DiscoveryFilters next) {
    setState(() {
      _draft = next;
      _preview = null;
      _previewFailed = false;
    });
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 250),
      () => unawaited(_refresh()),
    );
  }

  String _applyLabel(BuildContext context) {
    if (_previewFailed) return context.l10n.filtersApplyUnknown;
    return _preview == null
        ? context.l10n.stateLoading
        : context.l10n.filtersApply(_preview!);
  }

  int _priceIndex() {
    final int? price = _draft.maxPrice;
    if (price == null) return _priceSteps.length;
    final int i = _priceSteps.indexWhere((int s) => s >= price);
    return i < 0 ? _priceSteps.length : i;
  }

  int _radiusIndex() {
    final double? radius = _draft.radiusMeters;
    if (radius == null) return _radiusStepsKm.length;
    final int i = _radiusStepsKm.indexWhere((int km) => km * 1000 >= radius);
    return i < 0 ? _radiusStepsKm.length : i;
  }

  @override
  Widget build(BuildContext context) {
    final int priceIndex = _priceIndex();
    final int radiusIndex = _radiusIndex();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          WkSpacing.page,
          WkSpacing.lg,
          WkSpacing.page,
          WkSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Semantics(
              header: true,
              child: Text(
                context.l10n.filtersTitle,
                style: context.text.headlineMedium,
              ),
            ),
            const SizedBox(height: WkSpacing.lg),
            _label(context, context.l10n.filtersTransaction),
            WkChipGroup<TransactionKind?>(
              padding: EdgeInsets.zero,
              selected: _draft.transaction,
              onSelected: (TransactionKind? v) => _update(
                v == null
                    ? _draft.copyWith(clearTransaction: true)
                    : _draft.copyWith(transaction: v),
              ),
              chips: <WkChip<TransactionKind?>>[
                WkChip<TransactionKind?>(
                  value: null,
                  label: context.l10n.filtersAny,
                  icon: Icons.all_inclusive,
                ),
                WkChip<TransactionKind?>(
                  value: TransactionKind.rent,
                  label: context.l10n.transactionRent,
                  icon: Icons.vpn_key_outlined,
                ),
                WkChip<TransactionKind?>(
                  value: TransactionKind.sale,
                  label: context.l10n.transactionSale,
                  icon: Icons.sell_outlined,
                ),
              ],
            ),
            const SizedBox(height: WkSpacing.md),
            _label(context, context.l10n.filtersKind),
            WkChipGroup<PropertyKind?>(
              padding: EdgeInsets.zero,
              selected: _draft.kind,
              onSelected: (PropertyKind? v) => _update(
                v == null
                    ? _draft.copyWith(clearKind: true)
                    : _draft.copyWith(kind: v),
              ),
              chips: <WkChip<PropertyKind?>>[
                WkChip<PropertyKind?>(
                  value: null,
                  label: context.l10n.filtersAny,
                  icon: Icons.all_inclusive,
                ),
                for (final PropertyKind kind in PropertyKind.values)
                  WkChip<PropertyKind?>(
                    value: kind,
                    label: WkFormat.propertyKind(context.l10n, kind),
                    icon: WkFormat.propertyKindIcon(kind),
                  ),
              ],
            ),
            const SizedBox(height: WkSpacing.md),
            _sliderHeader(
              context,
              context.l10n.filtersMaxPrice,
              priceIndex == _priceSteps.length
                  ? context.l10n.filtersPriceAny
                  : context.l10n.filtersPriceValue(
                      NumberFormat(
                        '#,##0',
                        'fr',
                      ).format(_priceSteps[priceIndex]),
                    ),
            ),
            Slider(
              value: priceIndex.toDouble(),
              max: _priceSteps.length.toDouble(),
              divisions: _priceSteps.length,
              semanticFormatterCallback: (double v) =>
                  v.round() == _priceSteps.length
                  ? context.l10n.filtersPriceAny
                  : context.l10n.filtersPriceValue(
                      NumberFormat(
                        '#,##0',
                        'fr',
                      ).format(_priceSteps[v.round()]),
                    ),
              onChanged: (double v) {
                final int i = v.round();
                _update(
                  i == _priceSteps.length
                      ? _draft.copyWith(clearMaxPrice: true)
                      : _draft.copyWith(maxPrice: _priceSteps[i]),
                );
              },
            ),
            _sliderHeader(
              context,
              context.l10n.filtersRadius,
              radiusIndex == _radiusStepsKm.length
                  ? context.l10n.filtersRadiusAny
                  : context.l10n.filtersRadiusValue(
                      _radiusStepsKm[radiusIndex],
                    ),
            ),
            Slider(
              value: radiusIndex.toDouble(),
              max: _radiusStepsKm.length.toDouble(),
              divisions: _radiusStepsKm.length,
              semanticFormatterCallback: (double v) =>
                  v.round() == _radiusStepsKm.length
                  ? context.l10n.filtersRadiusAny
                  : context.l10n.filtersRadiusValue(_radiusStepsKm[v.round()]),
              onChanged: (double v) {
                final int i = v.round();
                _update(
                  i == _radiusStepsKm.length
                      ? _draft.copyWith(clearRadius: true)
                      : _draft.copyWith(
                          radiusMeters: _radiusStepsKm[i] * 1000.0,
                        ),
                );
              },
            ),
            const SizedBox(height: WkSpacing.md),
            if (_previewFailed) ...<Widget>[
              Semantics(
                liveRegion: true,
                child: Text(
                  context.l10n.filtersCountUnavailable,
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.error,
                  ),
                ),
              ),
              const SizedBox(height: WkSpacing.sm),
            ],
            WkButton(
              label: _applyLabel(context),
              onPressed: () => Navigator.of(context).pop(_draft),
            ),
            const SizedBox(height: WkSpacing.betweenTargets),
            WkButton(
              label: context.l10n.filtersReset,
              variant: WkButtonVariant.ghost,
              onPressed: _draft.activeCount == 0
                  ? null
                  : () => _update(DiscoveryFilters(query: _draft.query)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(BuildContext context, String text) => Padding(
    padding: const EdgeInsets.only(bottom: WkSpacing.sm),
    child: Text(
      text,
      style: context.text.labelMedium?.copyWith(
        color: context.colors.onSurfaceVariant,
      ),
    ),
  );

  Widget _sliderHeader(BuildContext context, String label, String value) {
    return Row(
      children: <Widget>[
        Expanded(child: _label(context, label)),
        Text(value, style: context.text.labelLarge),
      ],
    );
  }
}
