import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/core/feedback/interaction_feedback.dart';
import 'package:woutalma_keur/app/shared/theme/wk_motion.dart';
import 'package:woutalma_keur/app/shared/theme/wk_spacing.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';

/// Une pastille de choix : pictogramme et mot, jamais la couleur seule.
@immutable
class WkChip<T> {
  const WkChip({required this.value, required this.label, this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

/// Rangée de pastilles qui défile à l'horizontale. Une seule sélectionnée.
///
/// Jetons `chip` / `chip-selected` de `docs/DESIGN.md` : bordure 1.5,
/// hauteur 56, sélection en marine pâle **et** en graisse.
class WkChipGroup<T> extends StatelessWidget {
  const WkChipGroup({
    required this.chips,
    required this.selected,
    required this.onSelected,
    this.padding = const EdgeInsets.symmetric(horizontal: WkSpacing.page),
    super.key,
  });

  final List<WkChip<T>> chips;
  final T? selected;
  final ValueChanged<T> onSelected;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        children: <Widget>[
          for (int i = 0; i < chips.length; i++) ...<Widget>[
            _ChipTile<T>(
              chip: chips[i],
              selected: chips[i].value == selected,
              onTap: () {
                context.read<InteractionFeedbackService?>()?.emit(
                  FeedbackIntent.selection,
                );
                onSelected(chips[i].value);
              },
            ),
            if (i < chips.length - 1) const SizedBox(width: WkSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _ChipTile<T> extends StatelessWidget {
  const _ChipTile({
    required this.chip,
    required this.selected,
    required this.onTap,
  });

  final WkChip<T> chip;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color background = selected
        ? context.colors.primaryContainer
        : context.colors.surface;
    final Color foreground = selected
        ? context.colors.onPrimaryContainer
        : context.colors.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: selected,
      label: chip.label,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(WkRadius.full),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(WkRadius.full),
          child: AnimatedContainer(
            duration: WkMotion.of(context).fast,
            constraints: const BoxConstraints(minHeight: WkTouch.min - 8),
            padding: const EdgeInsets.symmetric(horizontal: WkSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(WkRadius.full),
              border: Border.all(
                color: selected
                    ? context.colors.primary
                    : context.colors.outline,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (chip.icon != null) ...<Widget>[
                  Icon(chip.icon, size: 18, color: foreground),
                  const SizedBox(width: WkSpacing.xs),
                ],
                Text(
                  chip.label,
                  style: context.text.labelMedium?.copyWith(
                    color: foreground,
                    fontWeight: selected ? FontWeight.w800 : null,
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
