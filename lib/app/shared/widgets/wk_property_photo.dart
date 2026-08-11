import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';

/// Photo de bien.
///
/// Trois provenances, une seule API :
/// - `demo:type:quartier:vue` — seed de démonstration, résolu vers un asset
///   embarqué (`assets/seed/photos/`). Aucun réseau au premier lancement.
/// - `assets/...` — asset déclaré par l'application.
/// - tout le reste — photo prise ou choisie par un courtier, donc un chemin de
///   fichier local (un blob sur le web).
///
/// Une photo qui ne charge pas ne laisse jamais un trou : le repli est un aplat
/// de marque avec le pictogramme du type de bien.
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
  static const String _seedDirectory = 'assets/seed/photos';

  /// `demo:house:medina:front` → `assets/seed/photos/house-medina-front.webp`.
  static String resolve(String path) => path.startsWith(_demoPrefix)
      ? '$_seedDirectory/${path.substring(_demoPrefix.length).replaceAll(':', '-')}.webp'
      : path;

  @override
  Widget build(BuildContext context) {
    final String resolved = resolve(path);
    final Widget fallback = _Fallback(icon: fallbackIcon);

    if (resolved.startsWith('assets/')) {
      return Image.asset(
        resolved,
        fit: fit,
        cacheWidth: cacheWidth,
        errorBuilder: (_, _, _) => fallback,
      );
    }

    if (kIsWeb) {
      // `image_picker` rend un blob: sur le web ; il n'y a pas de fichier.
      return Image.network(
        resolved,
        fit: fit,
        cacheWidth: cacheWidth,
        errorBuilder: (_, _, _) => fallback,
      );
    }

    return Image.file(
      File(resolved),
      fit: fit,
      cacheWidth: cacheWidth,
      errorBuilder: (_, _, _) => fallback,
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({required this.icon});

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
