import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/data/local/cache_status.dart';
import 'package:woutalma_keur/app/data/services/backend_warmup.dart';
import 'package:woutalma_keur/app/shared/theme/wk_spacing.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';

/// Une ligne, deux nouvelles possibles : « ce que vous lisez date de… » et
/// « le service se réveille ».
///
/// `docs/INTERACTION-FEEDBACK.md` demande qu'une attente longue soit racontée.
/// L'instance gratuite met une cinquantaine de secondes à revenir d'un
/// sommeil : une roue qui tourne sans un mot pendant ce temps est la pire
/// chose que cette application puisse montrer.
///
/// Rien ne s'affiche quand tout va bien — un bandeau permanent finit par ne
/// plus être lu.
class WkConnectionBanner extends StatelessWidget {
  const WkConnectionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final CacheStatus status = context.watch<CacheStatus>();
    final BackendWarmup warmup = context.watch<BackendWarmup>();

    if (status.servedFromCache) {
      return _Line(
        icon: Icons.cloud_off,
        message: context.l10n.offlineCached(_age(context, status.fetchedAt)),
      );
    }
    if (warmup.state == WarmupState.warming) {
      return _Line(
        icon: Icons.hourglass_bottom,
        message: context.l10n.backendWakingUp,
      );
    }
    return const SizedBox.shrink();
  }

  static String _age(BuildContext context, DateTime? at) {
    if (at == null) {
      return context.l10n.offlineJustNow;
    }
    final Duration ago = DateTime.now().difference(at);
    if (ago.inMinutes < 1) {
      return context.l10n.offlineJustNow;
    }
    if (ago.inHours < 1) {
      return context.l10n.offlineMinutesAgo(ago.inMinutes);
    }
    if (ago.inDays < 1) {
      return context.l10n.offlineHoursAgo(ago.inHours);
    }
    return context.l10n.offlineDaysAgo(ago.inDays);
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        color: context.colors.surfaceVariant,
        padding: const EdgeInsets.symmetric(
          horizontal: WkSpacing.md,
          vertical: WkSpacing.sm,
        ),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 18, color: context.colors.onSurfaceVariant),
            const SizedBox(width: WkSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: context.text.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
