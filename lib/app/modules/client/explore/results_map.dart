import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/shared/theme/wk_spacing.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';

/// Carte des résultats.
///
/// **Vue secondaire, jamais celle par défaut.** Elle télécharge des tuiles,
/// donc de la data, sur une cible qui la paie cher. La liste reste le chemin
/// principal et le retour vers elle est toujours à un geste.
///
/// Tuiles OpenStreetMap : pas de SDK propriétaire, pas de clé d'API, pas de
/// compte à créer pour lancer l'application.
class ResultsMap extends StatefulWidget {
  const ResultsMap({
    required this.center,
    required this.markers,
    required this.onSelect,
    this.tileProvider,
    super.key,
  });

  final GeoPoint center;

  /// Identifiant et position de chaque résultat.
  final List<(String, GeoPoint)> markers;
  final void Function(String id) onSelect;

  /// Injecté par les tests pour éprouver le cas où les tuiles n'arrivent pas.
  /// En production, `null` laisse le paquet utiliser le réseau.
  final TileProvider? tileProvider;

  @override
  State<ResultsMap> createState() => _ResultsMapState();
}

class _ResultsMapState extends State<ResultsMap> {
  /// Vrai dès qu'une tuile n'arrive pas.
  ///
  /// Sur un réseau faible — le cas normal ici — la carte se réduit à un
  /// rectangle gris avec des repères qui flottent. Sans un mot, on croit que
  /// l'application est cassée.
  bool _tilesFailed = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(WkRadius.sm),
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(
                  widget.center.latitude,
                  widget.center.longitude,
                ),
                initialZoom: 12,
                // Ni rotation ni inclinaison : sur un petit écran elles se
                // déclenchent par accident et personne ne sait revenir.
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                ),
              ),
              children: <Widget>[
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'sn.lic.woutalma_keur',
                  tileProvider: widget.tileProvider,
                  errorTileCallback: (_, _, _) {
                    if (!_tilesFailed && mounted) {
                      // Après la frame : le callback part depuis la phase de
                      // rendu, où `setState` est interdit.
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(() => _tilesFailed = true);
                        }
                      });
                    }
                  },
                ),
                MarkerLayer(
                  markers: <Marker>[
                    for (final (String id, GeoPoint point) in widget.markers)
                      Marker(
                        point: LatLng(point.latitude, point.longitude),
                        width: WkTouch.min,
                        height: WkTouch.min,
                        child: Semantics(
                          button: true,
                          child: InkResponse(
                            onTap: () => widget.onSelect(id),
                            child: Icon(
                              Icons.place,
                              size: 36,
                              color: context.colors.primary,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: WkSpacing.xs,
                    ),
                    color: context.colors.surface.withValues(alpha: 0.8),
                    child: Text(
                      // Attribution exigée par la licence des tuiles.
                      context.l10n.mapAttribution,
                      style: context.text.labelSmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: WkSpacing.sm),
        Text(
          _tilesFailed
              ? context.l10n.mapTilesUnavailable
              : context.l10n.mapDataWarning,
          style: context.text.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
