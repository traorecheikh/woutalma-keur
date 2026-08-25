import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/shared/formatters.dart';
import 'package:woutalma_keur/app/shared/theme/wk_spacing.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_badge.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_property_photo.dart';

/// Résultat de recherche pour un bien. Le prix domine ; les photos se
/// feuillettent sur place.
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
    final Color dim = context.colors.onSurfaceVariant;
    return Semantics(
      button: true,
      child: Material(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(WkRadius.xl),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onOpen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              WkPhotoCarousel(property: property, height: 180),
              Padding(
                padding: const EdgeInsets.all(WkSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
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
                        if (property.status != PropertyStatus.available)
                          WkStatusBadge(status: property.status),
                      ],
                    ),
                    const SizedBox(height: WkSpacing.xs),
                    Text(
                      property.title,
                      style: context.text.bodyLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: WkSpacing.xs),
                    Text(
                      WkFormat.propertyMeta(
                        context.l10n,
                        property,
                        distanceMeters,
                      ),
                      style: context.text.bodyMedium?.copyWith(color: dim),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Photos d'un bien qui se feuillettent, avec leurs points de position.
class WkPhotoCarousel extends StatefulWidget {
  const WkPhotoCarousel({
    required this.property,
    required this.height,
    this.showVoiceBadge = true,
    super.key,
  });

  final Property property;
  final double height;
  final bool showVoiceBadge;

  @override
  State<WkPhotoCarousel> createState() => _WkPhotoCarouselState();
}

class _WkPhotoCarouselState extends State<WkPhotoCarousel> {
  final PageController _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> photos = widget.property.photoAssets;
    return SizedBox(
      height: widget.height,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          if (photos.isEmpty)
            const WkPropertyPhotoFallback(icon: Icons.home_work_outlined)
          else
            PageView.builder(
              controller: _controller,
              itemCount: photos.length,
              itemBuilder: (_, int i) => WkPropertyPhoto(
                path: photos[i],
                fallbackIcon: Icons.home_work_outlined,
              ),
            ),
          if (photos.length > 1)
            Positioned(
              bottom: WkSpacing.sm,
              left: 0,
              right: 0,
              child: Center(
                child: SmoothPageIndicator(
                  controller: _controller,
                  count: photos.length,
                  effect: ExpandingDotsEffect(
                    dotHeight: 6,
                    dotWidth: 6,
                    expansionFactor: 3,
                    activeDotColor: context.colors.surface,
                    dotColor: context.colors.surface.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          if (widget.showVoiceBadge && widget.property.hasVoiceNote)
            PositionedDirectional(
              start: WkSpacing.sm,
              top: WkSpacing.sm,
              child: WkBadge(
                label: context.l10n.voiceNoteBadge,
                icon: Icons.mic,
                tone: WkBadgeTone.brand,
              ),
            ),
        ],
      ),
    );
  }
}

class WkStatusBadge extends StatelessWidget {
  const WkStatusBadge({required this.status, super.key});

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
