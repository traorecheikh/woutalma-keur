import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:woutalma_keur/app/domain/discovery.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/shared/formatters.dart';
import 'package:woutalma_keur/app/ui/ui.dart';

class FiltersSheet extends StatefulWidget {
  const FiltersSheet({
    super.key,
    required this.initial,
    required this.countResults,
  });
  final DiscoveryFilters initial;
  final Future<int> Function(DiscoveryFilters) countResults;

  static Future<DiscoveryFilters?> show(
    BuildContext context, {
    required DiscoveryFilters initial,
    required Future<int> Function(DiscoveryFilters) countResults,
  }) => showAppSheet<DiscoveryFilters>(
    context,
    title: context.l10n.filtersTitle,
    scrollable: true,
    child: FiltersSheet(initial: initial, countResults: countResults),
  );

  @override
  State<FiltersSheet> createState() => _FiltersSheetState();
}

const _prices = [
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
const _radiiKm = [1, 2, 5, 10, 25];

class _FiltersSheetState extends State<FiltersSheet> {
  late DiscoveryFilters _draft = widget.initial;
  int? _count;
  bool _failed = false;
  Timer? _debounce;
  int _request = 0;

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
    final r = ++_request;
    int? n;
    try {
      n = await widget.countResults(_draft);
    } on Object {
      n = null;
    }
    if (!mounted || r != _request) return;
    setState(() {
      _count = n;
      _failed = n == null;
    });
  }

  void _update(DiscoveryFilters next) {
    setState(() {
      _draft = next;
      _count = null;
      _failed = false;
    });
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 250),
      () => unawaited(_refresh()),
    );
  }

  int? get _price => _draft.maxPrice == null
      ? null
      : _prices.firstWhere(
          (p) => p >= _draft.maxPrice!,
          orElse: () => _prices.last,
        );
  int? get _radiusKm => _draft.radiusMeters == null
      ? null
      : _radiiKm.firstWhere(
          (k) => k * 1000 >= _draft.radiusMeters!,
          orElse: () => _radiiKm.last,
        );

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final fr = NumberFormat('#,##0', 'fr');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _label(context, l.filtersTransaction),
        AppChoice<TransactionKind?>(
          options: const [null, TransactionKind.rent, TransactionKind.sale],
          selected: _draft.transaction,
          label: (t) => t == null ? l.filtersAny : WkFormat.transaction(l, t),
          onChanged: (t) => _update(
            t == null
                ? _draft.copyWith(clearTransaction: true)
                : _draft.copyWith(transaction: t),
          ),
        ),
        const SizedBox(height: Insets.lg),
        _label(context, l.filtersKind),
        AppChoice<PropertyKind?>(
          options: const [null, ...PropertyKind.values],
          selected: _draft.kind,
          label: (k) => k == null ? l.filtersAny : WkFormat.propertyKind(l, k),
          icon: (k) => k == null ? null : WkFormat.propertyKindIcon(k),
          onChanged: (k) => _update(
            k == null
                ? _draft.copyWith(clearKind: true)
                : _draft.copyWith(kind: k),
          ),
        ),
        const SizedBox(height: Insets.lg),
        _label(context, l.filtersMaxPrice),
        AppPillRow(
          padding: EdgeInsets.zero,
          children: [
            for (final p in <int?>[null, ..._prices])
              AppPill(
                p == null
                    ? l.filtersPriceAny
                    : l.filtersPriceValue(fr.format(p)),
                selected: p == _price,
                onTap: () => _update(
                  p == null
                      ? _draft.copyWith(clearMaxPrice: true)
                      : _draft.copyWith(maxPrice: p),
                ),
              ),
          ],
        ),
        const SizedBox(height: Insets.lg),
        _label(context, l.filtersRadius),
        AppChoice<int?>(
          options: const [null, ..._radiiKm],
          selected: _radiusKm,
          label: (k) =>
              k == null ? l.filtersRadiusAny : l.filtersRadiusValue(k),
          onChanged: (k) => _update(
            k == null
                ? _draft.copyWith(clearRadius: true)
                : _draft.copyWith(radiusMeters: k * 1000.0),
          ),
        ),
        const SizedBox(height: Insets.lg),
        if (_failed)
          Padding(
            padding: const EdgeInsets.only(bottom: Insets.sm),
            child: Text(
              l.filtersCountUnavailable,
              style: context.text.bodySmall!.copyWith(
                color: context.tones.danger,
              ),
            ),
          ),
        AppButton(
          _failed
              ? l.filtersApplyUnknown
              : _count == null
              ? l.stateLoading
              : l.filtersApply(_count!),
          onPressed: () => popSheet(context, _draft),
        ),
        const SizedBox(height: Insets.sm),
        AppButton(
          l.filtersReset,
          variant: AppButtonVariant.ghost,
          onPressed: _draft.activeCount == 0
              ? null
              : () => _update(DiscoveryFilters(query: _draft.query)),
        ),
      ],
    );
  }

  Widget _label(BuildContext context, String text) => Padding(
    padding: const EdgeInsets.only(bottom: Insets.sm),
    child: Text(
      text,
      style: context.text.labelLarge!.copyWith(
        color: context.tones.inkSecondary,
      ),
    ),
  );
}
