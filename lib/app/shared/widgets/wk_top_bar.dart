import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:woutalma_keur/app/shared/theme/wk_spacing.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';

/// Barre haute d'un écran. Remplace `AppBar`.
///
/// Inclut toujours le geste vocal de base : lire le titre de l'écran.
/// Les écrans riches pourront remplacer [onListen] par une lecture complète.
class WkTopBar extends StatelessWidget {
  const WkTopBar({
    required this.title,
    this.onBack,
    this.action,
    this.onListen,
    this.showListen = false,
    super.key,
  });

  /// Déjà localisé par l'appelant. Ce widget ne fabrique aucun texte.
  final String title;

  /// Absent quand l'écran est une racine d'onglet.
  final VoidCallback? onBack;

  /// Une seule action, à droite.
  final Widget? action;

  /// Lecture vocale de l'écran. Par défaut, annonce au moins le titre : mieux
  /// qu'un écran muet, et assez petit pour ne pas dupliquer du code partout.
  final VoidCallback? onListen;

  /// Bouton « Écouter ».
  ///
  /// Faux par défaut depuis le retrait du chemin vocal : il ne faisait
  /// qu'annoncer le titre au lecteur d'écran, ce qui n'est pas ce que promet
  /// un haut-parleur bien visible en haut de chaque écran. Le rebrancher
  /// suppose une vraie lecture de l'écran, pas un titre répété.
  final bool showListen;

  static const double height = 64;

  @override
  Widget build(BuildContext context) {
    final Widget? back = onBack == null
        ? null
        : Semantics(
            button: true,
            label: context.l10n.commonBack,
            child: InkResponse(
              onTap: onBack,
              radius: WkTouch.min / 2,
              child: SizedBox(
                width: WkTouch.min,
                height: WkTouch.min,
                child: Icon(Icons.arrow_back, color: context.colors.onSurface),
              ),
            ),
          );

    return Container(
      constraints: const BoxConstraints(minHeight: height),
      padding: const EdgeInsets.symmetric(horizontal: WkSpacing.page),
      color: context.colors.background,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool canShowListen =
              showListen && constraints.maxWidth >= WkTouch.min * 6;
          return Row(
            children: <Widget>[
              if (back != null) ...<Widget>[
                back,
                const SizedBox(width: WkSpacing.sm),
              ],
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    title,
                    style: context.text.headlineMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              if (action != null) ...<Widget>[
                const SizedBox(width: WkSpacing.betweenTargets),
                action!,
              ],
              if (canShowListen) ...<Widget>[
                const SizedBox(width: WkSpacing.sm),
                Semantics(
                  button: true,
                  label: context.l10n.commonListen,
                  child: InkResponse(
                    onTap: onListen ?? () => _announceTitle(context),
                    radius: WkTouch.min / 2,
                    child: Center(
                      child: Container(
                        width: WkSpacing.xxl,
                        height: WkSpacing.xxl,
                        decoration: BoxDecoration(
                          color: context.colors.primaryContainer,
                          borderRadius: BorderRadius.circular(WkRadius.full),
                        ),
                        child: Icon(
                          Icons.volume_up_outlined,
                          color: context.colors.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  void _announceTitle(BuildContext context) {
    SemanticsService.sendAnnouncement(
      View.of(context),
      title,
      Directionality.of(context),
    );
  }
}
