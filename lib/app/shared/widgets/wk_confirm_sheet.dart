import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/core/feedback/interaction_feedback.dart';
import 'package:woutalma_keur/app/shared/theme/wk_spacing.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_button.dart';

/// Confirmation. Remplace `AlertDialog`.
///
/// Règle de `docs/INTERACTION-FEEDBACK.md` §7 : une action a **soit** une
/// confirmation, **soit** une annulation. Jamais les deux — sinon on apprend
/// aux gens à confirmer sans lire.
///
/// Un contenu destructif nomme l'objet et la conséquence, jamais « Êtes-vous
/// sûr ? ».
class WkConfirmSheet extends StatelessWidget {
  const WkConfirmSheet({
    required this.title,
    required this.body,
    required this.confirmLabel,
    required this.cancelLabel,
    this.destructive = false,
    super.key,
  });

  final String title;

  /// Dit ce qui va se passer, avec l'objet nommé.
  final String body;
  final String confirmLabel;
  final String cancelLabel;
  final bool destructive;

  /// Renvoie `true` si l'utilisateur confirme, `false` ou `null` sinon.
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String body,
    required String confirmLabel,
    required String cancelLabel,
    bool destructive = false,
  }) {
    if (destructive) {
      context.read<InteractionFeedbackService?>()?.emit(FeedbackIntent.warning);
    }
    return showModalBottomSheet<bool>(
      context: context,
      // Racine, pas la branche : une feuille ouverte dans le Navigator
      // d'un onglet laisserait la barre d'onglets cliquable au-dessus de
      // sa propre barrière modale.
      useRootNavigator: true,
      isDismissible: !destructive,
      enableDrag: !destructive,
      // Sans cela la feuille est plafonnée à 9/16 de l'écran. Un corps de
      // texte de trois lignes plus deux boutons de 56 dp dépasse ce plafond
      // sur un petit téléphone, et l'action de confirmation sort de l'écran —
      // ce qui est exactement le pire endroit où perdre du contenu. À ×1.3,
      // le cas devient la règle plutôt que l'exception.
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(WkRadius.xxl)),
      ),
      builder: (_) => WkConfirmSheet(
        title: title,
        body: body,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        destructive: destructive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(WkSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Semantics(
              header: true,
              child: Text(title, style: context.text.headlineMedium),
            ),
            const SizedBox(height: WkSpacing.sm),
            Text(
              body,
              style: context.text.bodyLarge?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: WkSpacing.lg),
            WkButton(
              label: confirmLabel,
              onPressed: () => Navigator.of(context).pop(true),
              variant: destructive
                  ? WkButtonVariant.danger
                  : WkButtonVariant.primary,
            ),
            const SizedBox(height: WkSpacing.betweenTargets),
            WkButton(
              label: cancelLabel,
              onPressed: () => Navigator.of(context).pop(false),
              variant: WkButtonVariant.secondary,
            ),
          ],
        ),
      ),
    );
  }
}
