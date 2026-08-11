import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Jetons de mouvement de `docs/INTERACTION-FEEDBACK.md` §4.
///
/// Un écran n'écrit jamais une `Duration` : il prend un jeton ici. Toujours
/// via [WkMotion.of] pour que « animations réduites » soit respecté sans que
/// chaque appelant y pense.
@immutable
class WkMotion {
  const WkMotion._({required this.reduced});

  /// Durées à zéro, mais **les changements d'état restent**. On ne supprime
  /// jamais un retour, seulement le déplacement.
  final bool reduced;

  /// Retour d'appui.
  Duration get instant => _scale(const Duration(milliseconds: 80));

  /// Coche de validation, chip, icône, texte d'aide.
  Duration get fast => _scale(const Duration(milliseconds: 140));

  /// Contenu de sheet, remplacement de résultats, fin de progression.
  Duration get standard => _scale(const Duration(milliseconds: 220));

  /// Confirmation de succès complète, et rien d'autre.
  Duration get slow => _scale(const Duration(milliseconds: 320));

  /// Anti-rebond de validation d'un champ. Unique dans le cycle de vie d'un
  /// champ : aucun second délai avant d'afficher le résultat.
  static const Duration validationDebounce = Duration(milliseconds: 400);

  /// Un indicateur n'apparaît qu'au-delà de ce seuil, sinon il clignote.
  static const Duration progressThreshold = Duration(milliseconds: 300);

  /// Une fois affiché, un indicateur reste au moins ce temps.
  static const Duration progressMinimum = Duration(milliseconds: 400);

  /// Durée de vie d'un `WkToast`, et fenêtre d'annulation associée.
  static const Duration transient = Duration(seconds: 6);

  /// Idem au-delà de ×1.2 de taille de texte ou avec un lecteur d'écran : il
  /// faut le temps de lire avant de pouvoir revenir en arrière.
  static const Duration transientAssisted = Duration(seconds: 10);

  /// Courbe par défaut de tout ce qui apparaît ou se déplace.
  static const Curve standardCurve = Curves.easeOutCubic;

  /// Tout ce qui disparaît.
  static const Curve exitCurve = Curves.easeInCubic;

  Duration _scale(Duration base) => reduced ? Duration.zero : base;

  /// Durée de vie d'un message transitoire, allongée quand la lecture est plus
  /// lente : gros texte, ou lecteur d'écran actif.
  static Duration transientFor(BuildContext context) {
    final MediaQueryData media = MediaQuery.of(context);
    final bool assisted =
        media.textScaler.scale(16) / 16 > 1.2 || media.accessibleNavigation;
    return assisted ? transientAssisted : transient;
  }

  /// Lit la préférence système d'animations réduites.
  static WkMotion of(BuildContext context) =>
      WkMotion._(reduced: MediaQuery.disableAnimationsOf(context));

  /// Pour les tests et les cas hors arbre de widgets.
  static const WkMotion full = WkMotion._(reduced: false);
  static const WkMotion none = WkMotion._(reduced: true);
}
