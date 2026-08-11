import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/core/feedback/interaction_feedback.dart';
import 'package:woutalma_keur/app/shared/theme/wk_colors.dart';
import 'package:woutalma_keur/app/shared/theme/wk_spacing.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_busy_indicator.dart';

/// Rôles de bouton. La couleur n'est pas un paramètre : elle découle du rôle.
enum WkButtonVariant {
  /// Un seul par écran. Marine, hauteur 64.
  primary,

  /// Chemin secondaire : annuler, revenir, plus tard.
  secondary,

  /// Action tertiaire, sans surface.
  ghost,

  /// Destructif. Nomme toujours ce qu'il détruit.
  danger,

  /// Destructif discret : le poids d'un lien, la couleur d'un danger.
  ///
  /// Existe parce que `ghost` peint son libellé en couleur de marque. Une
  /// suppression écrite dans la teinte qui sert partout ailleurs à inviter se
  /// lit comme une action ordinaire — et c'est la seule de la carte qu'on ne
  /// peut pas défaire.
  dangerGhost,

  /// Appel téléphonique. Vert sémantique.
  call,

  /// WhatsApp. Couleur de marque, reconnue avant lecture.
  whatsapp,
}

/// Bouton unique de l'application. Remplace `ElevatedButton`, `TextButton` et
/// `OutlinedButton`.
class WkButton extends StatelessWidget {
  const WkButton({
    required this.label,
    required this.onPressed,
    this.variant = WkButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.disabledReason,
    this.expand = true,
    super.key,
  });

  /// Déjà localisé. Concret : « Appeler », « Ajouter un bien ». Jamais
  /// « Valider », vide de sens à l'oreille.
  final String label;

  /// `null` désactive le bouton. Un bouton désactivé reste lisible et doit
  /// porter [disabledReason].
  final VoidCallback? onPressed;

  final WkButtonVariant variant;
  final IconData? icon;

  /// Remplace le libellé par un indicateur **sans changer la largeur**, et
  /// refuse tout nouvel appui : une double soumission devient impossible.
  final bool loading;

  /// Pourquoi l'action est indisponible. Lu par le lecteur d'écran. Un bouton
  /// désactivé sans motif est un bouton cassé pour qui ne lit pas bien.
  final String? disabledReason;

  final bool expand;

  bool get _enabled => onPressed != null && !loading;

  @override
  Widget build(BuildContext context) {
    final WkColors colors = context.colors;
    final _Style style = _styleFor(variant, colors);
    final double minHeight = variant == WkButtonVariant.primary
        ? WkTouch.comfy
        : WkTouch.min;
    final bool shrinkToLabel = !expand && variant == WkButtonVariant.ghost;
    final Widget labelText = Text(
      label,
      style: context.text.labelLarge?.copyWith(color: style.foreground),
      textAlign: TextAlign.center,
      // Deux lignes avant de couper : à l'étroit ou à ×1.3, un bouton
      // qui grandit reste lisible, un bouton qui affiche « Modifie… »
      // ne veut plus rien dire.
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );

    final Widget content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (icon != null) ...<Widget>[
          Icon(icon, size: 22, color: style.foreground),
          const SizedBox(width: WkSpacing.sm),
        ],
        if (shrinkToLabel) labelText else Flexible(child: labelText),
      ],
    );

    return Semantics(
      button: true,
      enabled: _enabled,
      label: label,
      hint: _enabled ? null : disabledReason,
      child: Opacity(
        // Un bouton indisponible reste lisible : jamais sous le contraste AA.
        opacity: onPressed == null && !loading ? 0.55 : 1,
        child: Material(
          color: style.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(WkRadius.md),
            side: style.border == null
                ? BorderSide.none
                : BorderSide(color: style.border!, width: 1.5),
          ),
          child: InkWell(
            onTap: _enabled ? () => _press(context) : null,
            borderRadius: BorderRadius.circular(WkRadius.md),
            child: Container(
              constraints: BoxConstraints(minHeight: minHeight),
              padding: const EdgeInsets.symmetric(
                horizontal: WkSpacing.lg,
                vertical: WkSpacing.sm,
              ),
              alignment: Alignment.center,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  // Le libellé reste dans l'arbre pendant le chargement : il
                  // réserve sa largeur, donc le bouton ne saute pas.
                  Opacity(opacity: loading ? 0 : 1, child: content),
                  if (loading)
                    WkBusyIndicator(color: style.foreground, size: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _press(BuildContext context) {
    context.read<InteractionFeedbackService?>()?.emit(FeedbackIntent.selection);
    onPressed!();
  }

  static _Style _styleFor(WkButtonVariant variant, WkColors c) {
    return switch (variant) {
      WkButtonVariant.primary => _Style(c.primary, c.onPrimary),
      WkButtonVariant.secondary => _Style(
        c.surface,
        c.onSurface,
        border: c.outline,
      ),
      WkButtonVariant.ghost => _Style(Colors.transparent, c.primary),
      WkButtonVariant.danger => _Style(c.error, c.onError),
      WkButtonVariant.dangerGhost => _Style(Colors.transparent, c.error),
      WkButtonVariant.call => _Style(c.call, c.onCall),
      WkButtonVariant.whatsapp => _Style(c.whatsapp, c.onWhatsapp),
    };
  }
}

@immutable
class _Style {
  const _Style(this.background, this.foreground, {this.border});

  final Color background;
  final Color foreground;
  final Color? border;
}
