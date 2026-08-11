import 'package:flutter/material.dart';
import 'package:woutalma_keur/app/shared/theme/wk_spacing.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_top_bar.dart';

/// Coquille de tout écran. Remplace `Scaffold` nu.
///
/// Tient les zones sûres, le fond de page, la marge horizontale et les
/// encarts de clavier au même endroit, pour qu'aucun écran n'ait à s'en
/// souvenir.
class WkScaffold extends StatelessWidget {
  const WkScaffold({
    required this.body,
    this.topBar,
    this.bottomAction,
    this.padHorizontal = true,
    this.extendBody = false,
    super.key,
  });

  final Widget body;
  final WkTopBar? topBar;

  /// Action primaire ancrée en bas, dans la zone du pouce. Elle ne défile
  /// jamais avec le contenu.
  final Widget? bottomAction;

  /// Faux quand le corps gère lui-même sa marge — une liste dont les cartes
  /// doivent toucher les bords lors du défilement horizontal, par exemple.
  final bool padHorizontal;

  /// Vrai quand le corps défile et doit passer **derrière** le dock d'onglets
  /// plutôt que de s'arrêter dessus.
  ///
  /// Réservé aux racines d'onglet : l'écran prend alors en charge lui-même sa
  /// marge basse, avec [bottomInset]. Ailleurs, la coquille garde son
  /// comportement sûr et réserve l'indicateur d'accueil.
  final bool extendBody;

  /// Hauteur à réserver au bas d'un contenu pour qu'il ne finisse pas sous le
  /// dock d'onglets ou sous l'indicateur d'accueil.
  ///
  /// Vaut 0 sur un écran ouvert hors coquille : le même code marche des deux
  /// côtés sans savoir où il est monté.
  static double bottomInset(BuildContext context) =>
      MediaQuery.paddingOf(context).bottom;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Material(
        color: context.colors.background,
        // Avec [extendBody], l'encart du bas reste intact dans le sous-arbre :
        // sous la coquille à onglets il vaut la hauteur du dock flottant, et le
        // corps allonge son défilement d'autant pour passer derrière plutôt que
        // de s'arrêter dessus.
        child: SafeArea(
          bottom: !extendBody,
          child: Column(
            children: <Widget>[
              ?topBar,
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: padHorizontal ? WkSpacing.page : 0,
                  ),
                  child: body,
                ),
              ),
              if (bottomAction != null)
                Padding(
                  padding: EdgeInsets.only(
                    left: WkSpacing.page,
                    right: WkSpacing.page,
                    top: WkSpacing.md,
                    // L'action primaire, elle, ne passe jamais sous le dock ni
                    // sous le clavier.
                    bottom:
                        WkSpacing.md +
                        bottomInset(context) +
                        MediaQuery.viewInsetsOf(context).bottom,
                  ),
                  child: SizedBox(width: double.infinity, child: bottomAction),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
