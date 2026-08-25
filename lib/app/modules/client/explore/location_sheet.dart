import 'package:flutter/material.dart';
import 'package:woutalma_keur/app/core/location/client_position_controller.dart';
import 'package:woutalma_keur/app/domain/location_service.dart';
import 'package:woutalma_keur/app/modules/client/explore/location_permission_flow.dart';
import 'package:woutalma_keur/app/ui/ui.dart';

/// M02 — Choisir où chercher.
///
/// Le GPS est premier, la liste des quartiers reste entière juste en dessous :
/// un refus de position n'ampute rien.
abstract final class LocationSheet {
  static Future<Neighbourhood?> show(
    BuildContext context, {
    required LocationService service,
    required ClientPositionController positions,
    List<Neighbourhood> recents = const <Neighbourhood>[],
  }) => showAppSheet<Neighbourhood>(
    context,
    title: context.l10n.locationTitle,
    scrollable: true,
    child: _Places(service: service, positions: positions, recents: recents),
  );
}

class _Places extends StatefulWidget {
  const _Places({
    required this.service,
    required this.positions,
    required this.recents,
  });
  final LocationService service;
  final ClientPositionController positions;
  final List<Neighbourhood> recents;

  @override
  State<_Places> createState() => _PlacesState();
}

class _PlacesState extends State<_Places> {
  final _query = TextEditingController();
  String _filter = '';
  bool _locating = false;
  String? _error;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  List<Neighbourhood> get _matches {
    final needle = _filter.trim().toLowerCase();
    final all = widget.service.knownNeighbourhoods();
    if (needle.isEmpty) return all;
    return all
        .where((n) => n.name.toLowerCase().contains(needle))
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final matches = _matches;
    final dim = context.text.bodySmall!.copyWith(
      color: context.tones.inkSecondary,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppButton(
          l.locationUseGps,
          icon: FIcons.locateFixed,
          loading: _locating,
          onPressed: _useGps,
        ),
        if (_error != null) ...[
          const SizedBox(height: Insets.sm),
          Semantics(
            liveRegion: true,
            child: Text(_error!, style: dim, textAlign: TextAlign.center),
          ),
        ],
        const SizedBox(height: Insets.lg),
        AppField(
          label: l.locationSearchHint,
          controller: _query,
          onChanged: (v) => setState(() => _filter = v),
        ),
        const SizedBox(height: Insets.md),
        if (matches.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Insets.lg),
            child: Text(l.locationNone, style: dim),
          )
        else ...[
          if (_filter.isEmpty && widget.recents.isNotEmpty) ...[
            _GroupTitle(l.locationRecent),
            for (final n in widget.recents) _row(n),
            _GroupTitle(l.locationAll),
          ],
          for (final n in matches) _row(n),
        ],
      ],
    );
  }

  Widget _row(Neighbourhood n) => AppRow(
    leading: const Icon(FIcons.mapPin),
    title: n.name,
    onTap: () => popSheet(context, n),
  );

  Future<void> _useGps() async {
    setState(() {
      _locating = true;
      _error = null;
    });

    // Un seul M06 dans l'application : ce bouton n'est qu'un appelant de
    // location_permission_flow.dart.
    final result = await requestClientPosition(context, widget.positions);
    if (!mounted) return;
    setState(() => _locating = false);

    switch (result) {
      case null:
        // « Pas maintenant » : la liste des quartiers reste ouverte, entière.
        return;
      case LocationFound():
        // La position est déjà posée dans le contrôleur ; rien à renvoyer.
        popSheet<Neighbourhood>(context);
      case LocationRefused(:final reason):
        setState(
          () => _error = reason == LocationRefusal.unavailable
              ? context.l10n.locationUnavailable
              : context.l10n.locationDenied,
        );
    }
  }
}

class _GroupTitle extends StatelessWidget {
  const _GroupTitle(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: Insets.sm),
    child: Text(
      label,
      style: context.text.bodySmall!.copyWith(
        color: context.tones.inkSecondary,
      ),
    ),
  );
}
