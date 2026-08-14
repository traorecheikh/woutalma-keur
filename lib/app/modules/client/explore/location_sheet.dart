import 'package:flutter/material.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/location_service.dart';
import 'package:woutalma_keur/app/shared/theme/wk_spacing.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_button.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_confirm_sheet.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_search_bar.dart';

/// M02 — Choisir où chercher.
///
/// Le **GPS est premier**, la saisie manuelle reste juste en dessous.
///
/// L'inverse était la règle jusqu'ici, et le commentaire d'origine la
/// défendait ; la décision a changé (voir docs/screen-contracts/
/// client-discovery.md). Ce qui ne change pas, et qui portait l'intention de
/// départ : un refus de position n'ampute rien. La liste des quartiers reste
/// à sa place, complète, sans dégradation ni relance.
class LocationSheet extends StatefulWidget {
  const LocationSheet({
    required this.service,
    required this.recents,
    super.key,
  });

  final LocationService service;

  /// Derniers quartiers choisis, remontés en tête.
  final List<Neighbourhood> recents;

  static Future<Neighbourhood?> show(
    BuildContext context, {
    required LocationService service,
    List<Neighbourhood> recents = const <Neighbourhood>[],
  }) {
    return showModalBottomSheet<Neighbourhood>(
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
      builder: (_) => LocationSheet(service: service, recents: recents),
    );
  }

  @override
  State<LocationSheet> createState() => _LocationSheetState();
}

class _LocationSheetState extends State<LocationSheet> {
  final TextEditingController _query = TextEditingController();
  String _filter = '';
  bool _locating = false;
  String? _error;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  List<Neighbourhood> get _matches {
    final String needle = _filter.trim().toLowerCase();
    final List<Neighbourhood> all = widget.service.knownNeighbourhoods();
    if (needle.isEmpty) {
      return all;
    }
    return all
        .where((Neighbourhood n) => n.name.toLowerCase().contains(needle))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<Neighbourhood> matches = _matches;

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
                context.l10n.locationTitle,
                style: context.text.headlineMedium,
              ),
            ),
            const SizedBox(height: WkSpacing.md),
            WkButton(
              label: context.l10n.locationUseGps,
              icon: Icons.my_location,
              loading: _locating,
              onPressed: _useGps,
            ),
            const SizedBox(height: WkSpacing.md),
            WkSearchBar(
              controller: _query,
              hint: context.l10n.locationSearchHint,
              onChanged: (String value) => setState(() => _filter = value),
              // Le micro n'a pas sa place ici : on choisit dans une liste
              // courte, pas dans un champ libre.
            ),
            if (_error != null) ...<Widget>[
              const SizedBox(height: WkSpacing.sm),
              Semantics(
                liveRegion: true,
                child: Text(
                  _error!,
                  style: context.text.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
            const SizedBox(height: WkSpacing.md),
            Flexible(
              child: matches.isEmpty
                  ? Text(
                      context.l10n.locationNone,
                      style: context.text.bodyLarge?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    )
                  : ListView(
                      shrinkWrap: true,
                      children: <Widget>[
                        if (_filter.isEmpty && widget.recents.isNotEmpty) ...[
                          _GroupTitle(context.l10n.locationRecent),
                          for (final Neighbourhood n in widget.recents)
                            _NeighbourhoodRow(
                              neighbourhood: n,
                              onTap: () => Navigator.of(context).pop(n),
                            ),
                          _GroupTitle(context.l10n.locationAll),
                        ],
                        for (final Neighbourhood n in matches)
                          _NeighbourhoodRow(
                            neighbourhood: n,
                            onTap: () => Navigator.of(context).pop(n),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _useGps() async {
    // M06 : on explique le bénéfice **avant** la demande système. Une
    // autorisation refusée par réflexe ne se redemande pas.
    final bool? go = await WkConfirmSheet.show(
      context,
      title: context.l10n.permissionLocationTitle,
      body: context.l10n.permissionLocationBody,
      confirmLabel: context.l10n.permissionContinue,
      cancelLabel: context.l10n.permissionNotNow,
    );
    if (go != true || !mounted) {
      return;
    }

    setState(() {
      _locating = true;
      _error = null;
    });
    final LocationResult result = await widget.service.current();
    if (!mounted) {
      return;
    }
    setState(() => _locating = false);

    switch (result) {
      case LocationFound(:final GeoPoint position):
        Navigator.of(context).pop(
          Neighbourhood(name: context.l10n.exploreNearYou, position: position),
        );
      case LocationRefused(:final LocationRefusal reason):
        setState(() {
          _error = reason == LocationRefusal.unavailable
              ? context.l10n.locationUnavailable
              : context.l10n.locationDenied;
        });
        if (reason == LocationRefusal.deniedForever && mounted) {
          // Seul cas où proposer les réglages a du sens : redemander
          // n'affichera plus jamais de dialogue.
          final bool? open = await WkConfirmSheet.show(
            context,
            title: context.l10n.permissionLocationTitle,
            body: context.l10n.locationDenied,
            confirmLabel: context.l10n.permissionOpenSettings,
            cancelLabel: context.l10n.permissionNotNow,
          );
          if (open == true) {
            await widget.service.openSettings();
          }
        }
    }
  }
}

class _GroupTitle extends StatelessWidget {
  const _GroupTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: WkSpacing.sm),
      child: Text(
        label,
        style: context.text.labelMedium?.copyWith(
          color: context.colors.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _NeighbourhoodRow extends StatelessWidget {
  const _NeighbourhoodRow({required this.neighbourhood, required this.onTap});

  final Neighbourhood neighbourhood;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: WkTouch.comfy),
          alignment: Alignment.centerLeft,
          child: Row(
            children: <Widget>[
              Icon(
                Icons.place_outlined,
                color: context.colors.onSurfaceVariant,
              ),
              const SizedBox(width: WkSpacing.md),
              Expanded(
                child: Text(neighbourhood.name, style: context.text.bodyLarge),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
