import 'package:flutter/material.dart';
import 'package:woutalma_keur/app/shared/theme/wk_spacing.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';

/// Barre de recherche **posée sur un écran de résultats** : elle en a l'allure,
/// mais elle n'a pas de clavier. Un appui ouvre l'écran de recherche, le micro
/// ouvre la dictée.
///
/// Séparer le déclencheur du champ évite le piège d'origine : un champ vivant
/// en permanence au-dessus d'une liste force ses suggestions, son bouton
/// d'effacement et ses filtres à rester à l'écran en continu, et la liste finit
/// par défiler sous un bloc flottant.
class WkSearchTrigger extends StatelessWidget {
  const WkSearchTrigger({
    required this.onOpen,
    required this.hint,
    required this.semanticLabel,
    this.onVoice,
    this.query,
    super.key,
  });

  final VoidCallback onOpen;

  /// Micro. `null` — la valeur par défaut — n'affiche rien.
  ///
  /// Nullable plutôt qu'un drapeau `showVoice` : « pas de micro » devient
  /// l'état par défaut au niveau du type, donc il ne peut pas revenir par
  /// l'oubli d'un paramètre. Tant qu'aucun moteur de reconnaissance réel
  /// n'existe, aucun appelant ne le fournit.
  final VoidCallback? onVoice;

  /// Ce qu'on peut chercher, affiché tant que rien n'est cherché.
  final String hint;

  /// Ce que le lecteur d'écran annonce : le geste, pas la décoration.
  final String semanticLabel;

  /// Requête en cours. Elle remplace l'invite : la barre dit ce qu'on cherche.
  final String? query;

  @override
  Widget build(BuildContext context) {
    final bool searching = (query ?? '').trim().isNotEmpty;

    return Container(
      constraints: const BoxConstraints(minHeight: WkTouch.comfy),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(WkRadius.full),
        border: Border.all(color: context.colors.outline),
      ),
      padding: const EdgeInsetsDirectional.only(end: WkSpacing.xs),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Semantics(
              button: true,
              label: semanticLabel,
              value: searching ? query : null,
              child: InkWell(
                onTap: onOpen,
                borderRadius: BorderRadius.circular(WkRadius.full),
                child: Container(
                  constraints: const BoxConstraints(minHeight: WkTouch.comfy),
                  padding: const EdgeInsetsDirectional.only(
                    start: WkSpacing.md,
                    end: WkSpacing.sm,
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.search,
                        size: WkIconSize.md,
                        color: context.colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: WkSpacing.sm),
                      Expanded(
                        child: Text(
                          searching ? query! : hint,
                          style: context.text.bodyLarge?.copyWith(
                            color: searching
                                ? context.colors.onSurface
                                : context.colors.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (onVoice != null)
            Semantics(
              button: true,
              label: context.l10n.voiceSearch,
              child: InkResponse(
                onTap: onVoice,
                radius: WkTouch.min / 2,
                child: Container(
                  width: WkTouch.min,
                  height: WkTouch.min,
                  alignment: Alignment.center,
                  child: Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: context.colors.primary,
                      borderRadius: BorderRadius.circular(WkRadius.full),
                    ),
                    child: Icon(Icons.mic, color: context.colors.onPrimary),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Champ de recherche véritable, avec clavier. N'apparaît que sur un écran dont
/// la recherche est le sujet.
///
/// Le micro, quand il existe, est à droite, dans le pouce.
class WkSearchBar extends StatelessWidget {
  const WkSearchBar({
    required this.controller,
    required this.onChanged,
    this.onVoice,
    this.hint,
    this.autofocus = false,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  /// Micro. `null` par défaut : voir [WkSearchTrigger.onVoice].
  final VoidCallback? onVoice;
  final String? hint;

  /// Vrai seulement quand la recherche **est** l'écran : ailleurs, ouvrir le
  /// clavier d'autorité vole la moitié de la page à qui venait juste lire.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: WkTouch.comfy + 8),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(WkRadius.full),
        border: Border.all(color: context.colors.primary, width: 1.5),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: context.colors.onSurface.withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsetsDirectional.only(
        start: WkSpacing.sm,
        end: WkSpacing.xs,
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.colors.primaryContainer,
              borderRadius: BorderRadius.circular(WkRadius.full),
            ),
            child: Icon(Icons.search, color: context.colors.onPrimaryContainer),
          ),
          const SizedBox(width: WkSpacing.sm),
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: autofocus,
              onChanged: onChanged,
              onSubmitted: (_) => FocusScope.of(context).unfocus(),
              style: context.text.bodyLarge,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: context.text.bodyLarge?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (BuildContext context, TextEditingValue value, _) {
              if (value.text.isEmpty) {
                return const SizedBox.shrink();
              }
              return Semantics(
                button: true,
                label: context.l10n.commonClose,
                child: InkResponse(
                  onTap: () {
                    controller.clear();
                    onChanged('');
                  },
                  radius: WkTouch.min / 2,
                  child: SizedBox(
                    width: WkTouch.min,
                    height: WkTouch.min,
                    child: Icon(
                      Icons.close,
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            },
          ),
          if (onVoice != null)
            Semantics(
              button: true,
              label: context.l10n.voiceSearch,
              child: InkResponse(
                onTap: onVoice,
                radius: WkTouch.min / 2,
                child: Container(
                  width: WkTouch.min,
                  height: WkTouch.min,
                  alignment: Alignment.center,
                  child: Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: context.colors.primary,
                      borderRadius: BorderRadius.circular(WkRadius.full),
                    ),
                    child: Icon(Icons.mic, color: context.colors.onPrimary),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
