import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

/// Relit les données quand l'écran redevient visible.
///
/// Les branches d'un `StatefulShellRoute` sont construites une fois et gardées
/// vivantes : le `create` d'un `ChangeNotifierProvider` ne rejoue pas quand on
/// revient sur l'onglet. Un bien publié depuis l'éditeur n'apparaissait donc
/// pas dans « Mes biens », qui affichait encore « Aucun bien publié » alors
/// que le serveur, lui, l'avait bien enregistré.
///
/// Le signal utilisé est celui de Flutter : `TickerMode` est désactivé par la
/// pile de navigation pour tout ce qui n'est plus à l'écran — branche
/// inactive d'un `IndexedStack`, écran recouvert par une route opaque — et
/// réactivé au retour. Aucune connaissance des rouages de `go_router` n'est
/// donc nécessaire, et les feuilles modales, qui ne sont pas opaques, ne
/// déclenchent rien.
///
/// Volontairement posé écran par écran, pas sur toute l'application : une
/// relecture est une requête, et l'application vise les réseaux faibles. On la
/// place là où revenir sur des données périmées est un défaut, pas là où
/// c'est un instantané que l'utilisateur a demandé.
class ReloadOnReturn<T extends Object> extends StatefulWidget {
  const ReloadOnReturn({required this.reload, required this.child, super.key});

  /// Appelé sur le modèle fourni plus haut dans l'arbre, à chaque retour.
  final void Function(T model) reload;

  final Widget child;

  @override
  State<ReloadOnReturn<T>> createState() => _ReloadOnReturnState<T>();
}

class _ReloadOnReturnState<T extends Object> extends State<ReloadOnReturn<T>> {
  /// Nul tant qu'on n'a rien observé : la première construction ne recharge
  /// pas, le modèle vient d'être créé et chargé.
  bool? _visible;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bool visible = TickerMode.valuesOf(context).enabled;
    final bool? previous = _visible;
    _visible = visible;
    if (previous == null || previous == visible || !visible) {
      return;
    }
    // Après la frame : recharger pendant la construction ferait notifier un
    // `ChangeNotifier` en plein build, ce que Provider refuse.
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      if (!mounted) {
        return;
      }
      widget.reload(context.read<T>());
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
