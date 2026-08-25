import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/ui/ui.dart';

class ResultsMap extends StatefulWidget {
  const ResultsMap({
    super.key,
    required this.center,
    required this.markers,
    required this.onSelect,
    this.tileProvider,
  });
  final GeoPoint center;
  final List<(String, GeoPoint)> markers;
  final void Function(String id) onSelect;
  final TileProvider? tileProvider;
  @override
  State<ResultsMap> createState() => _ResultsMapState();
}

class _ResultsMapState extends State<ResultsMap> {
  bool _tilesFailed = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: Radii.card,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(
                  widget.center.latitude,
                  widget.center.longitude,
                ),
                initialZoom: 12,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                    for (final (id, point) in widget.markers)
                      Marker(
                        point: LatLng(point.latitude, point.longitude),
                        width: 56,
                        height: 56,
                        child: FTappable(
                          onPress: () => widget.onSelect(id),
                          semanticsLabel: id,
                          child: Icon(
                            FIcons.mapPin,
                            size: 36,
                            color: context.tones.accent,
                          ),
                        ),
                      ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: Insets.xs),
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
