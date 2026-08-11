import 'package:flutter/material.dart';
import 'package:woutalma_keur/app/shared/theme/wk_spacing.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';

/// Registres de badge. Chacun porte **une couleur, un pictogramme et un mot** :
/// une pastille de couleur nue exclut ceux qui ne distinguent pas les teintes
/// et ceux qui ne lisent pas.
/// Il n'y a **pas** de registre d'alerte : il empruntait le rôle `error`, sans
/// qu'aucun badge de l'application ne s'en serve. Un badge n'annonce pas une
/// panne, il qualifie une chose — et le rouge d'erreur doit rester réservé à
/// ce qui a réellement échoué, sinon il ne veut plus rien dire nulle part.
enum WkBadgeTone { neutral, brand, positive }

class WkBadge extends StatelessWidget {
  const WkBadge({
    required this.label,
    required this.icon,
    this.tone = WkBadgeTone.neutral,
    super.key,
  });

  /// Déjà localisé.
  final String label;
  final IconData icon;
  final WkBadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final (Color background, Color foreground) = switch (tone) {
      WkBadgeTone.brand => (
        context.colors.primaryContainer,
        context.colors.onPrimaryContainer,
      ),
      WkBadgeTone.positive => (
        context.colors.statusAvailableContainer,
        context.colors.statusAvailable,
      ),
      WkBadgeTone.neutral => (
        context.colors.surfaceVariant,
        context.colors.onSurfaceVariant,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: WkSpacing.sm,
        vertical: WkSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(WkRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: WkSpacing.xs),
          // Un badge rétrécit plutôt que de déborder : son libellé grandit
          // avec la taille de texte et changera avec chaque traduction. Le
          // pictogramme, lui, ne disparaît jamais — c'est lui qui porte le
          // sens pour qui ne lit pas.
          Flexible(
            child: Text(
              label,
              style: context.text.labelSmall?.copyWith(color: foreground),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
