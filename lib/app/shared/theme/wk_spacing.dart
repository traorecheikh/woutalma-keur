/// Échelle d'espacement de `docs/DESIGN.md`, base 8.
///
/// Un écran n'écrit jamais un nombre de padding : il prend un jeton ici.
abstract final class WkSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;

  /// Marge horizontale de toute page, sur tous les écrans.
  static const double page = 20;

  /// Écart minimal entre deux cibles tactiles.
  static const double betweenTargets = 12;
}

/// Rayons de `docs/DESIGN.md`.
abstract final class WkRadius {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 28;

  /// Pilules : chips, badges, avatars, bouton vocal. Pas les boutons.
  static const double full = 9999;
}

/// Hauteurs minimales de cible tactile, de `docs/WOUTALMA-UI.md` §1.
///
/// Ce sont des minimums, jamais des hauteurs figées : à ×1.3 un composant
/// grandit.
abstract final class WkTouch {
  /// Plancher absolu de toute cible : icône seule, chip, bouton secondaire.
  static const double min = 56;

  /// Action primaire, champ de saisie, ligne de `WkOptionSheet`.
  static const double comfy = 64;

  /// Bouton micro, le plus gros élément interactif de l'écran d'accueil.
  static const double voice = 96;
}

/// Tailles de pictogramme.
///
/// Une seule mesure sert de référence pour réserver la colonne d'icônes d'une
/// liste : sans elle, chaque composant devine 24 dans son coin et les listes
/// ne s'alignent plus entre elles.
abstract final class WkIconSize {
  /// Taille par défaut d'un picto en ligne, celle de Material.
  static const double md = 24;
}
