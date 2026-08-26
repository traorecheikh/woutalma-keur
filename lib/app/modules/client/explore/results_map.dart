import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/ui/ui.dart';

/// Un repère de la carte : ce qu'il désigne et ce qu'on en dit.
@immutable
class MapMarker {
  const MapMarker({
    required this.id,
    required this.position,
    required this.title,
    this.detail,
  });
  final String id;
  final GeoPoint position;
  final String title;

  /// Prix et distance, déjà mis en forme par l'appelant.
  final String? detail;

  String get spoken => detail == null ? title : '$title, $detail';
}

class ResultsMap extends StatefulWidget {
  const ResultsMap({
    super.key,
    required this.center,
    required this.markers,
    required this.onSelect,
    this.tileProvider,
  });
  final GeoPoint center;
  final List<MapMarker> markers;
  final void Function(String id) onSelect;
  final TileProvider? tileProvider;
  @override
  State<ResultsMap> createState() => _ResultsMapState();
}

class _ResultsMapState extends State<ResultsMap> {
  bool _tilesFailed = false;
  MapMarker? _selected;

  @override
  void didUpdateWidget(ResultsMap old) {
    super.didUpdateWidget(old);
    final id = _selected?.id;
    if (id != null && !widget.markers.any((m) => m.id == id)) {
      _selected = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final selected = _selected;
    return Column(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: Radii.card,
            child: Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(
                      widget.center.latitude,
                      widget.center.longitude,
                    ),
                    initialZoom: 12,
                    onTap: (_, _) => setState(() => _selected = null),
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'sn.lic.woutalma_keur',
                      tileProvider:
                          widget.tileProvider ?? context.watch<TileProvider?>(),
                      errorTileCallback: (_, _, _) {
                        if (_tilesFailed || !mounted) return;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) setState(() => _tilesFailed = true);
                        });
                      },
                    ),
                    MarkerLayer(
                      markers: [
                        for (final marker in widget.markers)
                          Marker(
                            point: LatLng(
                              marker.position.latitude,
                              marker.position.longitude,
                            ),
                            width: Touch.min,
                            height: Touch.min,
                            child: FTappable(
                              // Un identifiant technique n'apprend rien :
                              // le repère se nomme comme la fiche qu'il ouvre.
                              semanticsLabel: marker.spoken,
                              behavior: HitTestBehavior.opaque,
                              onPress: () => setState(() => _selected = marker),
                              child: Icon(
                                FIcons.mapPin,
                                size: 36,
                                color: marker.id == selected?.id
                                    ? context.colors.primary
                                    : context.tones.accent,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Insets.xs,
                        ),
                        color: context.colors.surface.withValues(alpha: .8),
                        child: Text(
                          l.mapAttribution,
                          style: context.text.bodySmall!.copyWith(
                            color: context.tones.inkSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (selected != null)
                  Positioned(
                    left: Insets.md,
                    right: Insets.md,
                    bottom: Insets.md,
                    child: _Preview(
                      marker: selected,
                      onOpen: () => widget.onSelect(selected.id),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: Insets.sm),
        Text(
          _tilesFailed ? l.mapTilesUnavailable : l.mapDataWarning,
          style: context.text.bodySmall!.copyWith(
            color: context.tones.inkSecondary,
          ),
        ),
      ],
    );
  }
}

/// Ce que le repère désigne, avant d'ouvrir quoi que ce soit : un simple
/// appui qui change d'écran fait perdre la carte et le contexte.
class _Preview extends StatelessWidget {
  const _Preview({required this.marker, required this.onOpen});
  final MapMarker marker;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: AppCard(
      padding: const EdgeInsets.all(Insets.md),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  marker.title,
                  style: context.text.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (marker.detail != null)
                  Text(
                    marker.detail!,
                    style: context.text.bodySmall!.copyWith(
                      color: context.tones.inkSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const SizedBox(width: Insets.md),
          AppButton(
            context.l10n.commonOpen,
            icon: FIcons.arrowRight,
            variant: AppButtonVariant.secondary,
            onPressed: onOpen,
          ),
        ],
      ),
    ),
  );
}
