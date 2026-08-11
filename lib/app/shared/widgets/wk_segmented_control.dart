import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/core/feedback/interaction_feedback.dart';
import 'package:woutalma_keur/app/shared/theme/wk_spacing.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';

/// Choix entre deux ou trois vues du même contenu.
///
/// L'état sélectionné se lit **sans la couleur** : fond plein plus graisse du
/// libellé, pas seulement une teinte.
class WkSegmentedControl<T> extends StatelessWidget {
  const WkSegmentedControl({
    required this.segments,
    required this.value,
    required this.onChanged,
    super.key,
  });

  /// Valeur et libellé déjà localisé.
  final List<(T, String)> segments;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(WkSpacing.xs),
      decoration: BoxDecoration(
        color: context.colors.surfaceVariant,
        borderRadius: BorderRadius.circular(WkRadius.full),
      ),
      child: Row(
        children: <Widget>[
          for (final (T segment, String label) in segments)
            Expanded(
              child: Semantics(
                button: true,
                selected: segment == value,
                child: InkWell(
                  onTap: () {
                    if (segment == value) {
                      return;
                    }
                    context.read<InteractionFeedbackService?>()?.emit(
                      FeedbackIntent.selection,
                    );
                    onChanged(segment);
                  },
                  borderRadius: BorderRadius.circular(WkRadius.full),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: WkTouch.min),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: segment == value
                          ? context.colors.surface
                          : context.colors.surfaceVariant,
                      borderRadius: BorderRadius.circular(WkRadius.full),
                    ),
                    child: Text(
                      label,
                      style: context.text.labelMedium?.copyWith(
                        color: segment == value
                            ? context.colors.onSurface
                            : context.colors.onSurfaceVariant,
                        fontWeight: segment == value
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
