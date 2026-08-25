import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:woutalma_keur/app/core/app_config.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';

/// Photo de bien : `demo:` (asset embarqué), `assets/`, `api:<id>` (serveur)
/// ou chemin local. Jamais un trou : repli de marque tant que rien n'est
/// décodé.
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
  final int? cacheWidth;

  static const String _demoPrefix = 'demo:';
  static const String _apiPrefix = 'api:';

  static String resolve(String path) {
    if (path.startsWith(_demoPrefix)) {
      return 'assets/seed/photos/${path.substring(_demoPrefix.length).replaceAll(':', '-')}.webp';
    }
    if (path.startsWith(_apiPrefix)) {
      return '${AppConfig.apiBaseUrl}/properties/photos/${path.substring(_apiPrefix.length)}';
    }
    return path;
  }

  @override
  Widget build(BuildContext context) {
    final String resolved = resolve(path);
    final Widget fallback = WkPropertyPhotoFallback(icon: fallbackIcon);

    Widget waiting(BuildContext _, Widget child, int? frame, bool sync) =>
        sync || frame != null ? child : fallback;

    if (resolved.startsWith('assets/')) {
      return Image.asset(
        resolved,
        fit: fit,
        cacheWidth: cacheWidth,
        frameBuilder: waiting,
        errorBuilder: (_, _, _) => fallback,
      );
    }
    if (resolved.startsWith('http') || kIsWeb) {
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
