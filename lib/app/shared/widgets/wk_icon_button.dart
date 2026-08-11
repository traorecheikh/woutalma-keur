import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/core/feedback/interaction_feedback.dart';
import 'package:woutalma_keur/app/shared/theme/wk_spacing.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';

/// Action réduite à un pictogramme. Remplace `IconButton`.
///
/// La cible fait toujours 56 dp, même si le pictogramme en fait 24 : c'est
/// l'écart entre les deux qui rend l'action atteignable en marchant.
///
/// [label] est obligatoire — sans lui, l'action n'existe pas pour un lecteur
/// d'écran, et le pictogramme seul n'est jamais une preuve de compréhension.
class WkIconButton extends StatelessWidget {
  const WkIconButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
    super.key,
  });

  final IconData icon;

  /// Déjà localisé. Décrit le geste : « Réglages », pas « engrenage ».
  final String label;
  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: Opacity(
        // Même atténuation que `WkButton` : sans elle, un bouton mort avait
        // exactement l'aspect d'un bouton vivant. Le lecteur d'écran le
        // savait, l'œil non.
        opacity: enabled ? 1 : 0.55,
        child: Tooltip(
          message: label,
          child: InkResponse(
            onTap: !enabled
                ? null
                : () {
                    context.read<InteractionFeedbackService?>()?.emit(
                      FeedbackIntent.selection,
                    );
                    onPressed!();
                  },
            radius: WkTouch.min / 2,
            child: SizedBox(
              width: WkTouch.min,
              height: WkTouch.min,
              child: Icon(icon, color: color ?? context.colors.onSurface),
            ),
          ),
        ),
      ),
    );
  }
}
