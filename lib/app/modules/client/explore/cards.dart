import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/shared/formatters.dart';
import 'package:woutalma_keur/app/ui/ui.dart';

class PhotoCarousel extends StatefulWidget {
  const PhotoCarousel({
    super.key,
    required this.property,
    this.aspectRatio = 16 / 10,
    this.radius = Radii.container,
    this.onTap,
  });
  final Property property;
  final double aspectRatio;
  final BorderRadius radius;
  final VoidCallback? onTap;
  @override
  State<PhotoCarousel> createState() => _PhotoCarouselState();
}

class _PhotoCarouselState extends State<PhotoCarousel> {
  final _page = PageController();
  int _index = 0;

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.property.photoAssets;
    final icon = WkFormat.propertyKindIcon(widget.property.kind);
    return GestureDetector(
      onTap: widget.onTap,
      child: ClipRRect(
        borderRadius: widget.radius,
        child: AspectRatio(
          aspectRatio: widget.aspectRatio,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (photos.isEmpty)
                AppPhoto(null, fallbackIcon: icon, radius: BorderRadius.zero)
              else
                Semantics(
                  label: photos.length == 1
                      ? null
                      : context.l10n.photoPosition(_index + 1, photos.length),
                  child: PageView.builder(
                    controller: _page,
                    itemCount: photos.length,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemBuilder: (_, i) => AppPhoto(
                      photos[i],
                      fallbackIcon: icon,
                      radius: BorderRadius.zero,
                    ),
                  ),
                ),
              if (photos.length > 1)
                Positioned(
                  bottom: Insets.md,
                  right: Insets.md,
                  // Écartés du centre : c'est là qu'on appuie pour ouvrir le
                  // bien, et les points ne doivent pas prendre ce geste.
                  child: Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: SmoothPageIndicator(
                      controller: _page,
                      count: photos.length,
                      // Le glissement n'est pas la seule façon de changer de
                      // photo : les points s'appuient aussi.
                      onDotClicked: (i) => unawaited(
                        _page.animateToPage(
                          i,
                          duration: Motion.of(context, Motion.base),
                          curve: Curves.easeOut,
                        ),
                      ),
                      effect: ExpandingDotsEffect(
                        dotHeight: 8,
                        dotWidth: 8,
                        expansionFactor: 3,
                        activeDotColor: context.colors.surface,
                        dotColor: context.colors.surface.withValues(alpha: .5),
                      ),
                    ),
                  ),
                ),
              if (widget.property.hasVoiceNote)
                Positioned(
                  top: Insets.md,
                  left: Insets.md,
                  child: AppOverlayChip(
                    context.l10n.voiceNoteBadge,
                    icon: FIcons.mic,
                  ),
                ),
              if (widget.property.status != PropertyStatus.available)
                Positioned(
                  top: Insets.md,
                  right: Insets.md,
                  child: AppOverlayChip(
                    WkFormat.propertyStatus(
                      context.l10n,
                      widget.property.status,
                    ),
                    icon: widget.property.status == PropertyStatus.reserved
                        ? FIcons.clock
                        : FIcons.ban,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class PropertyCard extends StatelessWidget {
  const PropertyCard({
    super.key,
    required this.property,
    required this.distanceMeters,
    required this.onTap,
    this.width,
  });
  final Property property;
  final double distanceMeters;
  final VoidCallback onTap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final compact = width != null;
    final card = FTappable(
      onPress: onTap,
      semanticsLabel: property.title,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PhotoCarousel(property: property, onTap: onTap),
          const SizedBox(height: Insets.md),
          AppMoney(
            property.price,
            monthly: property.transaction == TransactionKind.rent,
            style: compact
                ? AppText.moneyLg
                : AppText.moneyXl.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 2),
          Text(
            property.title,
            style: context.text.titleMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            compact
                ? '${property.neighbourhood} · ${WkFormat.distance(l, distanceMeters)}'
                : WkFormat.propertyMeta(l, property, distanceMeters),
            style: context.text.bodySmall!.copyWith(
              color: context.tones.inkSecondary,
            ),
            maxLines: compact ? 1 : 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
    return width == null ? card : SizedBox(width: width, child: card);
  }
}

class BrokerCard extends StatelessWidget {
  const BrokerCard({
    super.key,
    required this.listing,
    required this.onTap,
    this.width,
  });
  final BrokerListing listing;
  final VoidCallback onTap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final b = listing.broker;
    final l = context.l10n;
    final body = AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(Insets.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppAvatar(name: b.name, size: 52, imagePath: b.logoAsset),
              if (width == null) ...[
                const SizedBox(width: Insets.md),
                Expanded(child: _identity(context)),
              ],
            ],
          ),
          if (width != null) ...[
            const SizedBox(height: Insets.md),
            _identity(context),
          ],
          const SizedBox(height: Insets.md),
          Row(
            spacing: Insets.sm,
            children: [
              AppStars(listing.averageRating, count: listing.reviewCount),
              Text('·', style: context.text.bodySmall),
              Flexible(
                child: Text(
                  WkFormat.distance(l, listing.distanceMeters),
                  style: context.text.bodySmall!.copyWith(
                    color: context.tones.inkSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (width == null) ...[
            const SizedBox(height: Insets.sm),
            Text(
              WkFormat.responseRate(l, b.responseRate),
              style: context.text.bodySmall!.copyWith(
                color: context.tones.inkSecondary,
              ),
            ),
          ],
          const SizedBox(height: Insets.md),
          Wrap(
            spacing: Insets.xs,
            runSpacing: Insets.xs,
            children: [
              if (b.isVerified)
                AppTag(
                  l.badgeVerified,
                  tone: AppTone.success,
                  icon: FIcons.badgeCheck,
                ),
              if (b.pinned)
                AppTag(
                  l.badgePinned,
                  tone: AppTone.accent,
                  icon: FIcons.sparkles,
                ),
              AppTag(
                l.propertyCount(listing.availableProperties),
                icon: FIcons.house,
              ),
            ],
          ),
        ],
      ),
    );
    return width == null ? body : SizedBox(width: width, child: body);
  }

  Widget _identity(BuildContext context) => Text(
    listing.broker.name,
    style: context.text.titleMedium,
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
  );
}
