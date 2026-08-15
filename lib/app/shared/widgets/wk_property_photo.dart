import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:woutalma_keur/app/core/app_config.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';

/// Photo de bien.
///
/// Quatre provenances, une seule API :
/// - `demo:type:quartier:vue` — seed de démonstration, résolu vers un asset
///   embarqué (`assets/seed/photos/`). Aucun réseau au premier lancement.
/// - `assets/...` — asset déclaré par l'application.
/// - `api:<id>` — octets stockés par le serveur, servis par
///   `GET {apiBaseUrl}/properties/photos/<id>`. C'est ce que rend toute photo
///   téléversée par un courtier : sans cette branche, elle ne s'affichait que
///   sur le téléphone qui l'avait publiée.
/// - tout le reste — photo prise ou choisie par un courtier et pas encore
///   envoyée, donc un chemin de fichier local (un blob sur le web).
///
/// Une photo qui ne charge pas ne laisse jamais un trou : le repli est un aplat
/// de marque avec le pictogramme du type de bien. **Une photo qui n'est pas
/// encore arrivée non plus.** Un asset embarqué se décode dans la frame, mais
/// une photo `api:` traverse le réseau : sur une 2G de quartier, la galerie
/// d'un bien fraîchement publié restait un rectangle transparent pendant
/// plusieurs secondes, sans rien derrière pour le remplir. Le repli tient la
/// place jusqu'à la première frame.
class WkPropertyPhoto extends StatelessWidget {
  const WkPropertyPhoto({
    required this.path,
    required this.fallbackIcon,
    this.fit = BoxFit.cover,
    this.cacheWidth,
    super.key,
  });

  final String path;
  final IconData fallbackIcon;
  final BoxFit fit;

  /// Largeur de décodage. Sur un téléphone d'entrée de gamme, décoder une photo
  /// pleine résolution pour une vignette de 96 dp coûte plus cher que l'afficher.
  final int? cacheWidth;

  static const String _demoPrefix = 'demo:';
  static const String _apiPrefix = 'api:';
  static const String _seedDirectory = 'assets/seed/photos';

  /// `demo:house:medina:front` → `assets/seed/photos/house-medina-front.webp`,
  /// `api:abc` → `{apiBaseUrl}/properties/photos/abc`.
  static String resolve(String path) {
    if (path.startsWith(_demoPrefix)) {
      return '$_seedDirectory/${path.substring(_demoPrefix.length).replaceAll(':', '-')}.webp';
    }
    if (path.startsWith(_apiPrefix)) {
      return '${AppConfig.apiBaseUrl}/properties/photos/'
          '${path.substring(_apiPrefix.length)}';
    }
    return path;
  }

  @override
  Widget build(BuildContext context) {
    final String resolved = resolve(path);
    final Widget fallback = WkPropertyPhotoFallback(icon: fallbackIcon);

    // Tant qu'aucune frame n'est décodée, on rend l'aplat plutôt que du vide.
    Widget waiting(
      BuildContext context,
      Widget child,
      int? frame,
      bool wasSynchronouslyLoaded,
    ) {
      return wasSynchronouslyLoaded || frame != null ? child : fallback;
    }

    if (resolved.startsWith('assets/')) {
      return Image.asset(
        resolved,
        fit: fit,
        cacheWidth: cacheWidth,
        frameBuilder: waiting,
        errorBuilder: (_, _, _) => fallback,
      );
    }

    // `image_picker` rend un blob: sur le web ; il n'y a pas de fichier.
    if (kIsWeb || path.startsWith(_apiPrefix)) {
      return Image.network(
        resolved,
        fit: fit,
        cacheWidth: cacheWidth,
        frameBuilder: waiting,
        errorBuilder: (_, _, _) => fallback,
      );
    }

    return Image.file(
      File(resolved),
      fit: fit,
      cacheWidth: cacheWidth,
      frameBuilder: waiting,
      errorBuilder: (_, _, _) => fallback,
    );
  }
}

/// Ce qui tient la place d'une photo : aplat de marque et pictogramme centré.
///
/// Public parce qu'un bien peut n'avoir **aucune** photo — c'est le cas
/// ordinaire d'une annonce qu'un courtier vient de publier depuis son
/// téléphone. La carte de résultat et la galerie de C03 décidaient chacune de
/// leur propre repli : un pictogramme décalé à 10 % d'opacité pour l'une, un
/// autre centré à 20 % pour l'autre. Les deux se lisaient comme une image
/// cassée plutôt que comme « pas de photo ». Un seul repli, partout.
class WkPropertyPhotoFallback extends StatelessWidget {
  const WkPropertyPhotoFallback({required this.icon, super.key});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.colors.primaryContainer,
      child: Center(
        child: Icon(
          icon,
          size: 64,
          color: context.colors.onPrimaryContainer.withValues(alpha: 0.42),
        ),
      ),
    );
  }
}
