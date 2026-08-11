import 'package:flutter/material.dart';

/// Échelle typographique de `docs/DESIGN.md`, branchée sur les emplacements
/// standards de [TextTheme].
///
/// Aucune famille n'est déclarée : `fontFamily` reste nul, donc Roboto sur
/// Android et SF sur iOS. Pas de police téléchargée ni embarquée — sur 2G, une
/// police distante afficherait un substitut pendant plusieurs secondes.
///
/// Un écran n'écrit jamais de `TextStyle` : il lit `Theme.of(context).textTheme`.
abstract final class WkTypography {
  /// Corps de texte par défaut. 18 et non 16 : la cible lit mal, il faut de la
  /// matière.
  static const double bodyDefaultSize = 18;

  /// Plancher absolu. Rien en dessous, nulle part.
  static const double floorSize = 13;

  static TextTheme textTheme(Color onSurface) {
    return TextTheme(
      // display-lg — accueil vocal, onboarding.
      displayLarge: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        height: 1.10,
        color: onSurface,
      ),
      // display-md — titre de section héros.
      displayMedium: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        height: 1.15,
        color: onSurface,
      ),
      // headline-lg — nom de courtier, titre de page, valeur de note.
      headlineLarge: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        height: 1.20,
        color: onSurface,
      ),
      // headline-md — titre de carte, en-tête de sheet.
      headlineMedium: TextStyle(
        fontSize: 21,
        fontWeight: FontWeight.w700,
        height: 1.30,
        color: onSurface,
      ),
      // body-lg — corps par défaut, champs de saisie.
      bodyLarge: TextStyle(
        fontSize: bodyDefaultSize,
        fontWeight: FontWeight.w500,
        height: 1.50,
        color: onSurface,
      ),
      // body-md — texte secondaire dense. Plancher pour un prix, une distance,
      // une note ou un nom de courtier.
      bodyMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.50,
        color: onSurface,
      ),
      // body-sm — métadonnées.
      bodySmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.45,
        color: onSurface,
      ),
      // label-lg — libellé de bouton.
      labelLarge: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        height: 1.20,
        color: onSurface,
      ),
      // label-md — chip, onglet.
      labelMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        height: 1.20,
        color: onSurface,
      ),
      // label-sm — badge.
      labelSmall: TextStyle(
        fontSize: floorSize,
        fontWeight: FontWeight.w700,
        height: 1.20,
        letterSpacing: 0.26,
        color: onSurface,
      ),
    );
  }
}
