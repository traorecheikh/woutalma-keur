import 'package:flutter/material.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/shared/formatters.dart';
import 'package:woutalma_keur/app/shared/theme/wk_spacing.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_avatar.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_badge.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_rating.dart';

/// Résultat de recherche pour un courtier.
///
/// La carte est **une seule cible tactile** : pas de petit bouton Appeler
/// dedans. Un bouton de 40 dp au milieu d'une liste qui défile se rate une
/// fois sur deux, et appeler par erreur coûte cher.
///
/// Ordre de lecture : nom, distance, note. Distance et note sont ce que l'œil
/// doit attraper en premier.
class WkBrokerCard extends StatelessWidget {
  const WkBrokerCard({required this.listing, required this.onOpen, super.key});

  final BrokerListing listing;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final Broker broker = listing.broker;

    return Semantics(
      button: true,
      child: Material(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(WkRadius.lg),
        child: InkWell(
          onTap: onOpen,
          borderRadius: BorderRadius.circular(WkRadius.lg),
          child: Container(
            constraints: const BoxConstraints(minHeight: 96),
            padding: const EdgeInsets.all(WkSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                WkAvatar(
                  name: broker.name,
                  kind: broker.kind,
                  imagePath: broker.logoAsset,
                ),
                const SizedBox(width: WkSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        broker.name,
                        style: context.text.headlineMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: WkSpacing.xs),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _InlineMeta(
                            icon: Icons.near_me_outlined,
                            label: WkFormat.distance(
                              context.l10n,
                              listing.distanceMeters,
                            ),
                          ),
                          const SizedBox(height: WkSpacing.xs),
                          _InlineMeta(
                            icon: Icons.bolt_outlined,
                            label: context.l10n.brokerResponseRate(
                              (broker.responseRate * 100).round(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: WkSpacing.sm),
                      WkRating(
                        value: listing.averageRating,
                        reviewCount: listing.reviewCount,
                        compact: true,
                      ),
                      const SizedBox(height: WkSpacing.sm),
                      Wrap(
                        spacing: WkSpacing.xs,
                        runSpacing: WkSpacing.xs,
                        children: <Widget>[
                          if (broker.pinned)
                            WkBadge(
                              label: context.l10n.badgePinned,
                              icon: Icons.push_pin,
                              tone: WkBadgeTone.brand,
                            ),
                          if (broker.isVerified)
                            WkBadge(
                              label: context.l10n.badgeVerified,
                              icon: Icons.verified_user,
                              tone: WkBadgeTone.positive,
                            ),
                          WkBadge(
                            label: context.l10n.propertyCount(
                              listing.availableProperties,
                            ),
                            icon: Icons.home_work_outlined,
                          ),
                        ],
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

class _InlineMeta extends StatelessWidget {
  const _InlineMeta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 16, color: context.colors.primary),
        const SizedBox(width: WkSpacing.xs),
        Expanded(
          child: Text(
            label,
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
