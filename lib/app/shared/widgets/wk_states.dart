import 'package:flutter/material.dart';
import 'package:woutalma_keur/app/core/state/screen_state.dart';
import 'package:woutalma_keur/app/l10n/generated/app_l10n.dart';
import 'package:woutalma_keur/app/shared/theme/wk_spacing.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_button.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_busy_indicator.dart';

/// Traduit une cause d'échec. La couche métier transporte un code, l'écran
/// transporte la phrase — sinon le texte en dur rentre par la porte de
/// derrière.
String failureMessage(AppL10n l10n, WkFailure failure) {
  return switch (failure) {
    WkFailure.localStorage => l10n.failureLocalStorage,
    WkFailure.seed => l10n.failureSeed,
    WkFailure.permission => l10n.failurePermission,
    WkFailure.notFound => l10n.failureNotFound,
    WkFailure.unknown => l10n.failureUnknown,
  };
}

/// Chargement. Occupe la même place que le contenu attendu pour qu'aucun
/// saut de mise en page ne survienne à l'arrivée des données.
class WkLoadingState extends StatelessWidget {
  const WkLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: context.l10n.stateLoading,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(WkSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const WkBusyIndicator(size: 36),
              const SizedBox(height: WkSpacing.md),
              Text(
                context.l10n.stateLoading,
                style: context.text.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Rien à afficher.
///
/// C'est le moment où un non-lecteur décroche : le pictogramme est grand,
/// la phrase est courte, et l'action de sortie est toujours présente.
class WkEmptyState extends StatelessWidget {
  const WkEmptyState({
    this.icon = Icons.search_off,
    this.title,
    this.body,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final IconData icon;
  final String? title;
  final String? body;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return _StatePanel(
      icon: icon,
      iconColor: context.colors.onSurfaceVariant,
      title: title ?? context.l10n.stateEmptyTitle,
      body: body ?? context.l10n.stateEmptyBody,
      actionLabel: actionLabel,
      onAction: onAction,
      variant: WkButtonVariant.secondary,
    );
  }
}

/// Erreur récupérable. Nomme la cause et propose une seule suite.
class WkErrorState extends StatelessWidget {
  const WkErrorState({required this.failure, this.onRetry, super.key});

  final WkFailure failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return _StatePanel(
      icon: Icons.error_outline,
      iconColor: context.colors.error,
      title: context.l10n.stateErrorTitle,
      body: failureMessage(context.l10n, failure),
      actionLabel: onRetry == null ? null : context.l10n.commonRetry,
      onAction: onRetry,
      variant: WkButtonVariant.primary,
      announce: true,
    );
  }
}

class _StatePanel extends StatelessWidget {
  const _StatePanel({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.variant,
    this.actionLabel,
    this.onAction,
    this.announce = false,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;
  final WkButtonVariant variant;
  final bool announce;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: announce,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(WkSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 64, color: iconColor),
              const SizedBox(height: WkSpacing.lg),
              Text(
                title,
                style: context.text.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: WkSpacing.sm),
              Text(
                body,
                style: context.text.bodyLarge?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              if (actionLabel != null && onAction != null) ...<Widget>[
                const SizedBox(height: WkSpacing.lg),
                WkButton(
                  label: actionLabel!,
                  onPressed: onAction,
                  variant: variant,
                  expand: false,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
