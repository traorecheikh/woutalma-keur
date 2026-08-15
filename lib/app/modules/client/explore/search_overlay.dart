import 'package:flutter/material.dart';
import 'package:woutalma_keur/app/core/state/screen_state.dart';
import 'package:woutalma_keur/app/modules/client/explore/explore_view_model.dart';
import 'package:woutalma_keur/app/shared/theme/wk_spacing.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_button.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_scaffold.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_search_bar.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_states.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_top_bar.dart';

/// Recherche de C01, en plein écran.
///
/// La barre vivait en permanence au-dessus des résultats, avec ses suggestions
/// et ses deux boutons : un bloc flottant qui mangeait un tiers de l'écran
/// pendant les 95 % du temps où l'on ne cherche pas, et sous lequel la liste
/// disparaissait. Elle est devenue un écran, ouvert à la demande, fermé dès que
/// la requête est posée.
///
/// L'écran écrit dans le même view model que C01 : les résultats derrière sont
/// déjà à jour quand il se ferme, et revenir en arrière ne perd pas la frappe.
class SearchOverlay extends StatefulWidget {
  const SearchOverlay({required this.model, super.key});

  final ExploreViewModel model;

  /// Le micro reste joignable d'ici : c'est le chemin de qui ne lit pas.

  static Future<void> show(
    BuildContext context, {
    required ExploreViewModel model,
  }) {
    return Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => SearchOverlay(model: model),
      ),
    );
  }

  @override
  State<SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends State<SearchOverlay> {
  late final TextEditingController _query = TextEditingController(
    text: widget.model.filters.query,
  );

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_onModelChanged);
  }

  @override
  void dispose() {
    widget.model.removeListener(_onModelChanged);
    _query.dispose();
    super.dispose();
  }

  void _onModelChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _select(String value) {
    _query.text = value;
    _query.selection = TextSelection.collapsed(offset: value.length);
    widget.model.search(value);
  }

  @override
  Widget build(BuildContext context) {
    final List<String> suggestions = widget.model.searchSuggestions;

    // « Aucun résultat » et « la requête a échoué » ne se disent pas de la
    // même façon. Avec `error: (_) => 0`, un réseau tombé rendait un bouton
    // « Aucun résultat » mort, sans un mot : impossible de distinguer une
    // recherche vide d'une recherche cassée, donc impossible de réessayer.
    final WkFailure? failure = widget.model.state.map(
      initial: () => null,
      loading: () => null,
      empty: () => null,
      error: (WkFailure value) => value,
      data: (_) => null,
    );
    final int count = widget.model.state.map(
      initial: () => 0,
      loading: () => 0,
      empty: () => 0,
      error: (_) => 0,
      data: (ExploreResults results) => results.countFor(widget.model.segment),
    );

    return WkScaffold(
      topBar: WkTopBar(
        title: context.l10n.exploreSearchTitle,
        onBack: () => Navigator.of(context).pop(),
      ),
      bottomAction: failure == null
          ? WkButton(
              label: context.l10n.exploreSearchSubmit(count),
              icon: Icons.arrow_forward,
              onPressed: count == 0 ? null : () => Navigator.of(context).pop(),
            )
          : WkButton(
              label: context.l10n.commonRetry,
              icon: Icons.refresh,
              onPressed: () => widget.model.search(_query.text),
            ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          WkSearchBar(
            controller: _query,
            hint: context.l10n.exploreSearchHint,
            autofocus: true,
            onChanged: widget.model.search,
          ),
          const SizedBox(height: WkSpacing.lg),
          Expanded(
            child: failure != null
                // Une seule action de reprise, celle du bas : deux boutons
                // « Réessayer » sur le même écran font hésiter.
                ? WkErrorState(failure: failure)
                : ListView.separated(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    itemCount: suggestions.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: WkSpacing.xs),
                    itemBuilder: (BuildContext context, int index) =>
                        _Suggestion(
                          label: suggestions[index],
                          onTap: () => _select(suggestions[index]),
                        ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _Suggestion extends StatelessWidget {
  const _Suggestion({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(WkRadius.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(WkRadius.md),
          child: Container(
            constraints: const BoxConstraints(minHeight: WkTouch.min),
            padding: const EdgeInsets.symmetric(horizontal: WkSpacing.md),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.north_west,
                  size: WkIconSize.md,
                  color: context.colors.onSurfaceVariant,
                ),
                const SizedBox(width: WkSpacing.md),
                Expanded(
                  child: Text(
                    label,
                    style: context.text.bodyLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
