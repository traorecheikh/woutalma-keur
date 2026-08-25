import 'package:flutter/material.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/shared/formatters.dart';
import 'package:woutalma_keur/app/shared/theme/wk_spacing.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_property_card.dart';

/// Carte photo à largeur fixe, pour les rangées horizontales de l'accueil.
class WkPropertyTile extends StatelessWidget {
  const WkPropertyTile({
    required this.property,
    required this.distanceMeters,
    required this.onOpen,
    this.width = 240,
    super.key,
  });

  final Property property;
  final double distanceMeters;
  final VoidCallback onOpen;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: property.title,
      child: SizedBox(
        width: width,
        child: Material(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(WkRadius.xl),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onOpen,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                WkPhotoCarousel(property: property, height: 150),
                Padding(
                  padding: const EdgeInsets.all(WkSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        WkFormat.price(
                          context.l10n,
                          property.price,
                          property.transaction,
                        ),
                        style: context.text.titleLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: WkSpacing.xs),
                      Text(
                        property.title,
                        style: context.text.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: WkSpacing.xs),
                      Text(
                        '${property.neighbourhood} · ${WkFormat.distance(context.l10n, distanceMeters)}',
                        style: context.text.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
