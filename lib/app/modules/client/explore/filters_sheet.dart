import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:woutalma_keur/app/domain/discovery.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/shared/formatters.dart';
import 'package:woutalma_keur/app/shared/theme/wk_spacing.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_button.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_option_sheet.dart';

/// M01 — Filtres.
///
/// Le bouton d'application porte **le nombre de résultats en direct**. Sans
/// lui, on applique un filtre, on découvre zéro résultat, on revient : trois
/// écrans pour apprendre ce qu'un compteur disait déjà.
class FiltersSheet extends StatefulWidget {
  const FiltersSheet({
    required this.initial,
    required this.countResults,
    super.key,
  });

  final DiscoveryFilters initial;

  /// Compte ce que donnerait ce jeu de filtres, sans l'appliquer.
  final Future<int> Function(DiscoveryFilters filters) countResults;

  static Future<DiscoveryFilters?> show(
    BuildContext context, {
    required DiscoveryFilters initial,
    required Future<int> Function(DiscoveryFilters filters) countResults,
  }) {
    return showModalBottomSheet<DiscoveryFilters>(
      context: context,
      // Racine, pas la branche : une feuille ouverte dans le Navigator
      // d'un onglet laisserait la barre d'onglets cliquable au-dessus de
      // sa propre barrière modale.
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

  static const List<int> _radiusChoicesKm = <int>[2, 5, 10, 25];
  static const List<int> _priceChoices = <int>[100000, 250000, 500000, 1000000];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final int count = await widget.countResults(_draft);
    if (mounted) {
      setState(() => _preview = count);
    }
  }

  void _update(DiscoveryFilters next) {
    setState(() {
      _draft = next;
      // Le compteur repasse à « inconnu » plutôt que d'afficher l'ancien
      // chiffre : un nombre faux est pire qu'un nombre absent.
      _preview = null;
    });
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(WkSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Semantics(
              header: true,
              child: Text(
                context.l10n.filtersTitle,
                style: context.text.headlineMedium,
              ),
            ),
            const SizedBox(height: WkSpacing.lg),
            WkSelectField<TransactionKind?>(
              label: context.l10n.filtersTransaction,
              value: _draft.transaction,
              onChanged: (TransactionKind? value) => _update(
                value == null
                    ? _draft.copyWith(clearTransaction: true)
                    : _draft.copyWith(transaction: value),
              ),
              options: <WkOption<TransactionKind?>>[
                WkOption<TransactionKind?>(
                  value: null,
                  label: context.l10n.filtersAny,
                  icon: Icons.all_inclusive,
                ),
                WkOption<TransactionKind?>(
                  value: TransactionKind.rent,
                  label: context.l10n.transactionRent,
                  icon: Icons.vpn_key_outlined,
                ),
                WkOption<TransactionKind?>(
                  value: TransactionKind.sale,
                  label: context.l10n.transactionSale,
                  icon: Icons.sell_outlined,
                ),
              ],
            ),
            const SizedBox(height: WkSpacing.md),
            WkSelectField<PropertyKind?>(
              label: context.l10n.filtersKind,
              value: _draft.kind,
              onChanged: (PropertyKind? value) => _update(
                value == null
                    ? _draft.copyWith(clearKind: true)
                    : _draft.copyWith(kind: value),
              ),
              options: <WkOption<PropertyKind?>>[
                WkOption<PropertyKind?>(
                  value: null,
                  label: context.l10n.filtersAny,
                  icon: Icons.all_inclusive,
                ),
                for (final PropertyKind kind in PropertyKind.values)
                  WkOption<PropertyKind?>(
                    value: kind,
                    label: WkFormat.propertyKind(context.l10n, kind),
                    icon: WkFormat.propertyKindIcon(kind),
                  ),
              ],
            ),
            const SizedBox(height: WkSpacing.md),
            WkSelectField<int?>(
              label: context.l10n.filtersMaxPrice,
              value: _draft.maxPrice,
              onChanged: (int? value) => _update(
                value == null
                    ? _draft.copyWith(clearMaxPrice: true)
                    : _draft.copyWith(maxPrice: value),
              ),
              options: <WkOption<int?>>[
                WkOption<int?>(
                  value: null,
                  label: context.l10n.filtersAny,
                  icon: Icons.all_inclusive,
                ),
                for (final int price in _priceChoices)
                  WkOption<int?>(
                    value: price,
                    label: context.l10n.filtersPriceValue(
                      NumberFormat('#,##0', 'fr').format(price),
                    ),
                    icon: Icons.payments_outlined,
                  ),
              ],
            ),
            const SizedBox(height: WkSpacing.md),
            WkSelectField<double?>(
              label: context.l10n.filtersRadius,
              value: _draft.radiusMeters,
              onChanged: (double? value) => _update(
                value == null
                    ? _draft.copyWith(clearRadius: true)
                    : _draft.copyWith(radiusMeters: value),
              ),
              options: <WkOption<double?>>[
                WkOption<double?>(
                  value: null,
                  label: context.l10n.filtersAny,
                  icon: Icons.all_inclusive,
                ),
                for (final int km in _radiusChoicesKm)
                  WkOption<double?>(
                    value: km * 1000,
                    label: context.l10n.filtersRadiusValue(km),
                    icon: Icons.place_outlined,
                  ),
              ],
            ),
            const SizedBox(height: WkSpacing.lg),
            WkButton(
              label: _preview == null
                  ? context.l10n.stateLoading
                  : context.l10n.filtersApply(_preview!),
              onPressed: () => Navigator.of(context).pop(_draft),
            ),
            const SizedBox(height: WkSpacing.betweenTargets),
            // Réinitialiser demande un appui explicite, mais n'est pas
            // destructif : aucune confirmation.
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
}
