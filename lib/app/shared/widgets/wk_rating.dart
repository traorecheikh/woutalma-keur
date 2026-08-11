import 'package:flutter/material.dart';
import 'package:woutalma_keur/app/shared/formatters.dart';
import 'package:woutalma_keur/app/shared/theme/wk_spacing.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';

/// Note affichée.
///
/// Les étoiles ne sont **pas** dorées : elles sont en encre, et le chiffre est
/// gros. L'or serait une quatrième teinte pour une information que le chiffre
/// porte mieux — et il faut de toute façon le volume d'avis à côté, sans quoi
/// un 5,0 sur un avis se lit comme un 5,0 sur cinquante.
class WkRating extends StatelessWidget {
  const WkRating({
    required this.value,
    required this.reviewCount,
    this.compact = false,
    super.key,
  }) : _single = false;

  /// La note d'**un seul** avis, sans compteur.
  ///
  /// Le volume n'a de sens que sur une moyenne. Collé à un avis isolé, il
  /// affichait « 5,0 · 1 avis » sur chaque carte d'une liste d'avis : une
  /// information toujours vraie, jamais utile, et qui laisse croire que ce
  /// courtier n'a été noté qu'une fois.
  const WkRating.single({required int rating, super.key})
    : value = rating * 1.0,
      reviewCount = 1,
      compact = false,
      _single = true;

  final double value;
  final int reviewCount;

  /// Vrai dans une carte de liste : chiffre et volume, sans les étoiles.
  final bool compact;

  final bool _single;

  @override
  Widget build(BuildContext context) {
    final bool unrated = reviewCount == 0;

    if (unrated) {
      return Text(
        context.l10n.ratingNone,
        style: context.text.bodySmall?.copyWith(
          color: context.colors.onSurfaceVariant,
        ),
      );
    }

    return Semantics(
      // Un lecteur d'écran doit entendre l'échelle, pas « 4,6 » tout seul.
      label: '${WkFormat.rating(value)} / 5',
      value: _single ? null : context.l10n.reviewCount(reviewCount),
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (!compact) ...<Widget>[
            for (int i = 1; i <= 5; i++)
              Icon(
                i <= value.round() ? Icons.star : Icons.star_border,
                size: 18,
                color: i <= value.round()
                    ? context.colors.onSurface
                    : context.colors.outline,
              ),
            const SizedBox(width: WkSpacing.sm),
          ],
          Text(
            WkFormat.rating(value),
            style: compact
                ? context.text.headlineMedium
                : context.text.headlineLarge,
          ),
          if (!_single) ...<Widget>[
            const SizedBox(width: WkSpacing.sm),
            Flexible(
              child: Text(
                context.l10n.reviewCount(reviewCount),
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
