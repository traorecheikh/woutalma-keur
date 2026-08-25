import 'package:flutter/material.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/shared/formatters.dart';
import 'package:woutalma_keur/app/shared/theme/wk_spacing.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_avatar.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_badge.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_rating.dart';

/// Courtier en vignette, pour les rangées horizontales de l'accueil.
class WkBrokerTile extends StatelessWidget {
  const WkBrokerTile({
    required this.listing,
    required this.onOpen,
    this.width = 180,
    super.key,
  });

  final BrokerListing listing;
  final VoidCallback onOpen;
  final double width;

  @override
  Widget build(BuildContext context) {
    final Broker broker = listing.broker;
    return Semantics(
      button: true,
      label: broker.name,
      child: SizedBox(
        width: width,
        child: Material(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(WkRadius.xl),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onOpen,
            child: Padding(
              padding: const EdgeInsets.all(WkSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  WkAvatar(
                    name: broker.name,
                    kind: broker.kind,
                    imagePath: broker.logoAsset,
                    size: 52,
                  ),
                  const SizedBox(height: WkSpacing.sm),
                  Text(
                    broker.name,
                    style: context.text.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: WkSpacing.xs),
                  WkRating(
                    value: listing.averageRating,
                    reviewCount: listing.reviewCount,
                    compact: true,
                  ),
                  const SizedBox(height: WkSpacing.xs),
                  Text(
                    WkFormat.distance(context.l10n, listing.distanceMeters),
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  if (broker.isVerified) ...<Widget>[
                    const SizedBox(height: WkSpacing.sm),
                    WkBadge(
                      label: context.l10n.badgeVerified,
                      icon: Icons.verified_user,
                      tone: WkBadgeTone.positive,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
