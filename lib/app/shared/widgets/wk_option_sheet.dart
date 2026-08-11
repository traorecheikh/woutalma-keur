import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/core/feedback/interaction_feedback.dart';
import 'package:woutalma_keur/app/shared/theme/wk_spacing.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';

/// Une option présentable dans un [WkOptionSheet].
@immutable
class WkOption<T> {
  const WkOption({required this.value, required this.label, this.icon});

  final T value;

  /// Déjà localisé.
  final String label;
  final IconData? icon;
}

/// Largeur de la colonne de pictogrammes : l'icône elle-même plus sa gouttière.
///
/// Dès qu'une seule option d'une liste porte un picto, **toutes** réservent
/// cette largeur. Sans ça, « Peu importe » décale son libellé et les autres
/// options commencent ailleurs : l'œil ne suit plus une colonne, il zigzague.
const double _iconGutter = WkIconSize.md + WkSpacing.md;

/// Même colonne, resserrée : le champ fermé est plus étroit que la feuille.
const double _fieldIconGutter = WkIconSize.md + WkSpacing.sm;

/// Le remplaçant de tout menu déroulant.
///
/// Un `DropdownButton` est illisible au soleil, minuscule au doigt et
/// impossible à énoncer proprement à voix haute. Ici : pleine largeur, une
/// ligne de 64 dp par option, pictogramme, libellé et coche.
class WkOptionSheet<T> extends StatelessWidget {
  const WkOptionSheet({
    required this.title,
    required this.options,
    this.selected,
    super.key,
  });

  final String title;
  final List<WkOption<T>> options;
  final T? selected;

  /// Renvoie la sélection **emballée** dans une liste d'un élément, ou `null`
  /// si la feuille a été fermée sans choisir.
  ///
  /// Sans cet emballage, une option dont la valeur est `null` — « Peu
  /// importe », qui retire un filtre — serait indistinguable d'un abandon, et
  /// on ne pourrait jamais enlever un filtre.
  static Future<List<T>?> show<T>(
    BuildContext context, {
    required String title,
    required List<WkOption<T>> options,
    T? selected,
  }) {
    return showModalBottomSheet<List<T>>(
      context: context,
      // Racine, pas la branche : une feuille ouverte dans le Navigator
      // d'un onglet laisserait la barre d'onglets cliquable au-dessus de
      // sa propre barrière modale.
      useRootNavigator: true,
      // Sans ça, la feuille est plafonnée à 56 % de l'écran et six options
      // suffisent à cacher la dernière derrière un scroll que rien n'annonce.
      // Le `Flexible` en dessous garde le défilement pour les listes longues.
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(WkRadius.xxl)),
      ),
      builder: (_) =>
          WkOptionSheet<T>(title: title, options: options, selected: selected),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Une seule option illustrée suffit à imposer la colonne à toutes.
    final bool hasIcons = options.any((WkOption<T> o) => o.icon != null);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              WkSpacing.page,
              WkSpacing.lg,
              WkSpacing.page,
              WkSpacing.sm,
            ),
            child: Semantics(
              header: true,
              child: Text(title, style: context.text.headlineMedium),
            ),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (BuildContext context, int index) {
                final WkOption<T> option = options[index];
                final bool isSelected = option.value == selected;
                return InkWell(
                  onTap: () {
                    context.read<InteractionFeedbackService?>()?.emit(
                      FeedbackIntent.selection,
                    );
                    Navigator.of(context).pop(<T>[option.value]);
                  },
                  child: Container(
                    constraints: const BoxConstraints(minHeight: WkTouch.comfy),
                    padding: const EdgeInsets.symmetric(
                      horizontal: WkSpacing.page,
                      vertical: WkSpacing.sm,
                    ),
                    child: Row(
                      children: <Widget>[
                        if (hasIcons)
                          SizedBox(
                            width: _iconGutter,
                            child: option.icon == null
                                ? null
                                : Icon(
                                    option.icon,
                                    size: WkIconSize.md,
                                    color: context.colors.onSurface,
                                  ),
                          ),
                        Expanded(
                          child: Text(
                            option.label,
                            style: context.text.bodyLarge,
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check, color: context.colors.primary),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: WkSpacing.md),
        ],
      ),
    );
  }
}

/// Champ qui ouvre un [WkOptionSheet]. Ressemble à un champ de saisie, se
/// comporte comme un choix.
class WkSelectField<T> extends StatelessWidget {
  const WkSelectField({
    required this.label,
    required this.options,
    required this.onChanged,
    this.value,
    this.hint,
    super.key,
  });

  final String label;
  final List<WkOption<T>> options;
  final ValueChanged<T> onChanged;
  final T? value;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final WkOption<T>? current = options
        .where((WkOption<T> o) => o.value == value)
        .firstOrNull;

    return Semantics(
      button: true,
      label: label,
      value: current?.label,
      child: InkWell(
        onTap: () async {
          final List<T>? picked = await WkOptionSheet.show<T>(
            context,
            title: label,
            options: options,
            selected: value,
          );
          // Liste vide impossible : `null` veut dire « fermé sans choisir »,
          // un élément veut dire « voici la valeur », même si cette valeur
          // est nulle.
          if (picked != null) {
            onChanged(picked.first);
          }
        },
        borderRadius: BorderRadius.circular(WkRadius.md),
        // Le libellé fait partie de la cible : sur un téléphone, on tape le
        // mot qu'on lit, pas le rectangle en dessous.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              label,
              style: context.text.labelMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: WkSpacing.xs),
            Container(
              constraints: const BoxConstraints(minHeight: WkTouch.comfy),
              padding: const EdgeInsets.symmetric(horizontal: WkSpacing.md),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(WkRadius.md),
                border: Border.all(color: context.colors.outline, width: 1.5),
              ),
              child: Row(
                children: <Widget>[
                  // Colonne réservée dès qu'une option de la liste est
                  // illustrée : sinon le libellé se déplace horizontalement
                  // à chaque changement de choix.
                  if (options.any((WkOption<T> o) => o.icon != null))
                    SizedBox(
                      width: _fieldIconGutter,
                      child: current?.icon == null
                          ? null
                          : Icon(
                              current!.icon,
                              size: WkIconSize.md,
                              color: context.colors.onSurface,
                            ),
                    ),
                  Expanded(
                    child: Text(
                      current?.label ?? hint ?? context.l10n.commonChoose,
                      style: context.text.bodyLarge?.copyWith(
                        color: current == null
                            ? context.colors.onSurfaceVariant
                            : context.colors.onSurface,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.expand_more,
                    color: context.colors.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
