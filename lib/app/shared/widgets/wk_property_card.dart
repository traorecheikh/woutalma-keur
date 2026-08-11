import 'package:flutter/material.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/shared/formatters.dart';
import 'package:woutalma_keur/app/shared/theme/wk_spacing.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_badge.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_property_photo.dart';

/// Résultat de recherche pour un bien.
///
/// Le prix domine : c'est le premier tri que fait un client dans sa tête.
class WkPropertyCard extends StatelessWidget {
  const WkPropertyCard({
    required this.property,
    required this.distanceMeters,
    required this.onOpen,
    super.key,
  });

  final Property property;
  final double distanceMeters;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: Material(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(WkRadius.lg),
        child: InkWell(
          onTap: onOpen,
          borderRadius: BorderRadius.circular(WkRadius.lg),
          child: Padding(
            padding: const EdgeInsets.all(WkSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _PhotoStrip(property: property),
                const SizedBox(height: WkSpacing.md),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        WkFormat.price(
                          context.l10n,
                          property.price,
                          property.transaction,
                        ),
                        style: context.text.headlineMedium,
                      ),
                    ),
                    _StatusBadge(status: property.status),
                  ],
                ),
                const SizedBox(height: WkSpacing.xs),
                Text(
                  property.title,
                  style: context.text.bodyLarge,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                const SizedBox(height: WkSpacing.sm),
                Wrap(
                  spacing: WkSpacing.sm,
                  runSpacing: WkSpacing.xs,
                  children: <Widget>[
                    _Meta(
                      icon: Icons.category_outlined,
                      label: WkFormat.propertyKind(context.l10n, property.kind),
                    ),
                    if (property.surface != null)
                      _Meta(
                        icon: Icons.straighten,
                        label: context.l10n.surfaceValue(property.surface!),
                      ),
                    if (property.rooms != null)
                      _Meta(
                        icon: Icons.meeting_room_outlined,
                        label: context.l10n.roomCount(property.rooms!),
                      ),
                    _Meta(
                      icon: Icons.place_outlined,
                      label: WkFormat.distance(context.l10n, distanceMeters),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PhotoStrip extends StatelessWidget {
  const _PhotoStrip({required this.property});

  final Property property;

  @override
  Widget build(BuildContext context) {
    final int photoCount = property.photoAssets.length;

    return Container(
      height: 132,
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.colors.primaryContainer,
        borderRadius: BorderRadius.circular(WkRadius.md),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          if (property.photoAssets.isEmpty)
            Stack(
              children: <Widget>[
                PositionedDirectional(
                  end: -24,
                  top: -18,
                  child: Icon(
                    Icons.home_work_outlined,
                    size: 112,
                    color: context.colors.onPrimaryContainer.withValues(
                      alpha: 0.10,
                    ),
                  ),
                ),
              ],
            )
          else
            WkPropertyPhoto(
              path: property.photoAssets.first,
              fallbackIcon: Icons.home_work_outlined,
            ),
          PositionedDirectional(
            start: WkSpacing.sm,
            bottom: WkSpacing.sm,
            child: WkBadge(
              label: property.neighbourhood,
              icon: Icons.place_outlined,
              tone: WkBadgeTone.neutral,
            ),
          ),
          if (photoCount > 1)
            PositionedDirectional(
              end: WkSpacing.sm,
              bottom: WkSpacing.sm,
              child: WkBadge(
                label: '1/$photoCount',
                icon: Icons.photo_library_outlined,
                tone: WkBadgeTone.neutral,
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final PropertyStatus status;

  @override
  Widget build(BuildContext context) {
    return WkBadge(
      label: WkFormat.propertyStatus(context.l10n, status),
      icon: switch (status) {
        PropertyStatus.available => Icons.check_circle_outline,
        PropertyStatus.reserved => Icons.schedule,
        PropertyStatus.closed => Icons.do_not_disturb_on_outlined,
      },
      tone: switch (status) {
        PropertyStatus.available => WkBadgeTone.positive,
        PropertyStatus.reserved => WkBadgeTone.brand,
        PropertyStatus.closed => WkBadgeTone.neutral,
      },
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 16, color: context.colors.onSurfaceVariant),
        const SizedBox(width: WkSpacing.xs),
        Text(
          label,
          style: context.text.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
