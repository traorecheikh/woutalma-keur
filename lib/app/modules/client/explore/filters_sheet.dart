import 'dart:async';

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

  /// Vrai quand le comptage a échoué. Distinct de `_preview == null`, qui veut
  /// dire « pas encore répondu » : sans cette distinction, un comptage en
  /// échec laissait le bouton sur « Un instant… » pour toujours.
  bool _previewFailed = false;

  Timer? _debounce;

  /// Numéro de la demande en cours. Une réponse lente arrivée après un
  /// nouveau choix est jetée, sinon elle réécrirait un compte périmé.
  int _request = 0;

  /// Chaque option touchée relance un comptage, qui est un appel réseau.
  /// Sans ce délai, parcourir quatre filtres en tapotant partait en une
  /// dizaine d'allers-retours sur une connexion qui n'en a pas les moyens.
  static const Duration _previewDebounce = Duration(milliseconds: 250);

  static const List<int> _radiusChoicesKm = <int>[2, 5, 10, 25];
  static const List<int> _priceChoices = <int>[100000, 250000, 500000, 1000000];

  @override
  void initState() {
    super.initState();
    // Premier comptage immédiat : rien à fusionner avec une frappe précédente.
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
      // Le comptage n'est qu'un aperçu : son échec ne doit pas empêcher
      // d'appliquer les filtres, mais il doit se voir.
      count = null;
    }
    if (!mounted || request != _request) {
      return;
    }
    setState(() {
      _preview = count;
      _previewFailed = count == null;
    });
  }

  void _update(DiscoveryFilters next) {
    setState(() {
      _draft = next;
      // Le compteur repasse à « inconnu » plutôt que d'afficher l'ancien
      // chiffre : un nombre faux est pire qu'un nombre absent.
      _preview = null;
      _previewFailed = false;
    });
    _debounce?.cancel();
    _debounce = Timer(_previewDebounce, () => unawaited(_refresh()));
  }

  /// Le bouton applique **toujours** : le compte n'est qu'une indication.
  String _applyLabel(BuildContext context) {
    if (_previewFailed) {
      return context.l10n.filtersApplyUnknown;
    }
    return _preview == null
        ? context.l10n.stateLoading
        : context.l10n.filtersApply(_preview!);
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
