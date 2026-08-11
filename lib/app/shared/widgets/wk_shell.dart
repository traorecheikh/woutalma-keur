import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/core/feedback/interaction_feedback.dart';
import 'package:woutalma_keur/app/shared/theme/wk_spacing.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';

/// Coquille à onglets, partagée par les deux rôles.
///
/// Un onglet qui mène à un écran vide serait pire qu'un onglet absent : seules
/// les destinations réellement implémentées figurent ici.
///
/// Le dock **flotte au-dessus** du contenu (`extendBody`). Posé dans le flux, il
/// coupait net le bas de chaque écran : la liste s'arrêtait sur une frontière
/// dure et rien ne passait derrière, ce qui donne l'impression que la page
/// s'arrête là. En flottant, il laisse deviner qu'il reste des résultats — et
/// `Scaffold` reporte sa hauteur dans `MediaQuery.padding.bottom`, si bien que
/// chaque écran sait exactement de combien allonger son défilement.
class WkShell extends StatelessWidget {
  const WkShell({
    required this.navigationShell,
    required this.destinations,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  /// Pictogramme et libellé de chaque onglet, déjà localisés.
  final List<(IconData, String)> destinations;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(
          WkSpacing.page,
          0,
          WkSpacing.page,
          WkSpacing.sm,
        ),
        child: WkDockNav(
          items: destinations,
          index: navigationShell.currentIndex,
          onSelect: (int index) {
            if (index != navigationShell.currentIndex) {
              context.read<InteractionFeedbackService?>()?.emit(
                FeedbackIntent.selection,
              );
            }
            // `initialLocation: true` sur le même onglet le ramène à sa
            // racine : c'est le geste attendu d'un second appui.
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
        ),
      ),
    );
  }
}

class WkDockNav extends StatelessWidget {
  const WkDockNav({
    required this.items,
    required this.index,
    required this.onSelect,
    super.key,
  });

  final List<(IconData, String)> items;
  final int index;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(WkSpacing.xs),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(WkRadius.xxl),
        border: Border.all(color: context.colors.outlineVariant),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: context.colors.onSurface.withValues(alpha: 0.10),
            blurRadius: WkSpacing.lg,
            offset: const Offset(0, WkSpacing.sm),
          ),
        ],
      ),
      // Onglets de largeur égale. Un onglet actif trois fois plus large que ses
      // voisins déplace les cibles à chaque navigation : on ne peut plus viser
      // « Profil » de mémoire, il n'est jamais au même endroit.
      child: Row(
        children: <Widget>[
          for (int i = 0; i < items.length; i++)
            Expanded(
              child: Semantics(
                button: true,
                selected: i == index,
                label: items[i].$2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: WkSpacing.xs / 2,
                  ),
                  child: AnimatedContainer(
                    duration: context.motion.fast,
                    curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(
                      color: i == index
                          ? context.colors.primaryContainer
                          : context.colors.surface,
                      borderRadius: BorderRadius.circular(WkRadius.xl),
                    ),
                    child: InkWell(
                      onTap: () => onSelect(i),
                      borderRadius: BorderRadius.circular(WkRadius.xl),
                      child: Container(
                        // Le plancher de cible, pas la hauteur confortable :
                        // un dock permanent qui prend 64 dp plus ses marges
                        // mange un dixième d'un écran de 5 pouces.
                        constraints: const BoxConstraints(
                          minHeight: WkTouch.min,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: WkSpacing.xs,
                          vertical: WkSpacing.xs,
                        ),
                        child: _NavItem(
                          icon: items[i].$1,
                          label: items[i].$2,
                          selected: i == index,
                        ),
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

/// Pictogramme **et** libellé, sur tous les onglets, sélectionné ou non.
///
/// Cacher le libellé des onglets inactifs demande de reconnaître trois
/// pictogrammes seuls — exactement ce que la cible de l'application ne fait pas.
/// Le contrat le dit pour les actions critiques ; naviguer en est une.
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
  });

  final IconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final Color color = selected
        ? context.colors.onPrimaryContainer
        : context.colors.onSurfaceVariant;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(icon, color: color, size: WkIconSize.md),
        Text(
          label,
          style: context.text.labelSmall?.copyWith(color: color),
          textAlign: TextAlign.center,
          // Deux lignes : à ×1.3 le dock grandit plutôt que de couper un mot.
          maxLines: 2,
        ),
      ],
    );
  }
}
