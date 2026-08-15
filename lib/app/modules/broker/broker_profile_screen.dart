import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/core/state/screen_state.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/modules/client/broker/broker_view_model.dart';
import 'package:woutalma_keur/app/shared/theme/wk_spacing.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_badge.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_button.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_icon_button.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_property_card.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_rating.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_scaffold.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_states.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_top_bar.dart';

/// B07 — Profil public du courtier.
class BrokerProfileScreen extends StatelessWidget {
  const BrokerProfileScreen({
    required this.onOpenSettings,
    required this.onOpenVerification,
    required this.onOpenRanking,
    required this.onOpenProperty,
    required this.onEditProfile,
    super.key,
  });

  final VoidCallback onOpenSettings;
  final VoidCallback onOpenVerification;
  final VoidCallback onOpenRanking;
  final void Function(Property property) onOpenProperty;

  /// Ouvre B08 et se termine au retour : le profil se relit alors, sinon
  /// l'écran continuerait d'afficher l'ancien numéro.
  final Future<void> Function() onEditProfile;

  @override
  Widget build(BuildContext context) {
    final BrokerViewModel model = context.watch<BrokerViewModel>();
    final BrokerDetail? detail = model.state.valueOrNull;

    return WkScaffold(
      extendBody: true,
      topBar: WkTopBar(
        title: detail?.broker.name ?? context.l10n.brokerProfileTitle,
        action: WkIconButton(
          icon: Icons.settings_outlined,
          label: context.l10n.settingsTitle,
          onPressed: onOpenSettings,
        ),
      ),
      body: model.state.map(
        initial: () => const SizedBox.shrink(),
        loading: () => const WkLoadingState(),
        empty: () => const WkEmptyState(),
        error: (WkFailure failure) =>
            WkErrorState(failure: failure, onRetry: model.load),
        data: (BrokerDetail value) => _ProfileBody(
          detail: value,
          onOpenSettings: onOpenSettings,
          onOpenVerification: onOpenVerification,
          onOpenRanking: onOpenRanking,
          onOpenProperty: onOpenProperty,
          onEditProfile: () async {
            await onEditProfile();
            await model.load();
          },
        ),
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({
    required this.detail,
    required this.onOpenSettings,
    required this.onOpenVerification,
    required this.onOpenRanking,
    required this.onOpenProperty,
    required this.onEditProfile,
  });

  final BrokerDetail detail;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenVerification;
  final VoidCallback onOpenRanking;
  final void Function(Property property) onOpenProperty;
  final VoidCallback onEditProfile;

  @override
  Widget build(BuildContext context) {
    final Broker broker = detail.broker;

    return ListView(
      padding: EdgeInsets.only(
        bottom: WkScaffold.bottomInset(context) + WkSpacing.md,
      ),
      children: <Widget>[
        DecoratedBox(
          decoration: BoxDecoration(
            color: context.colors.primaryContainer,
            borderRadius: BorderRadius.circular(WkRadius.xl),
          ),
          child: Padding(
            padding: const EdgeInsets.all(WkSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Wrap(
                  spacing: WkSpacing.xs,
                  runSpacing: WkSpacing.xs,
                  children: <Widget>[
                    WkBadge(
                      label: broker.isVerified
                          ? context.l10n.badgeVerified
                          : context.l10n.brokerVerificationMissing,
                      icon: broker.isVerified
                          ? Icons.verified_user
                          : Icons.verified_user_outlined,
                      tone: broker.isVerified
                          ? WkBadgeTone.positive
                          : WkBadgeTone.brand,
                    ),
                    if (broker.pinned)
                      WkBadge(
                        label: context.l10n.badgePinned,
                        icon: Icons.push_pin,
                        tone: WkBadgeTone.brand,
                      ),
                  ],
                ),
                const SizedBox(height: WkSpacing.md),
                WkRating(
                  value: detail.averageRating,
                  reviewCount: detail.reviews.length,
                ),
                const SizedBox(height: WkSpacing.sm),
                Text(
                  context.l10n.brokerResponseRate(
                    (broker.responseRate * 100).round(),
                  ),
                  style: context.text.bodyMedium?.copyWith(
                    color: context.colors.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: WkSpacing.lg),
        _Section(title: context.l10n.brokerCoverage),
        Wrap(
          spacing: WkSpacing.xs,
          runSpacing: WkSpacing.xs,
          children: <Widget>[
            for (final String zone in broker.coverage)
              WkBadge(label: zone, icon: Icons.place_outlined),
          ],
        ),
        const SizedBox(height: WkSpacing.lg),
        _Section(title: context.l10n.brokerProperties),
        if (detail.properties.isEmpty)
          Text(
            context.l10n.brokerNoProperties,
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          )
        else
          for (final Property property in detail.properties.take(1))
            Padding(
              padding: const EdgeInsets.only(bottom: WkSpacing.sm),
              child: WkPropertyCard(
                property: property,
                distanceMeters: detail.distanceMeters,
                onOpen: () => onOpenProperty(property),
              ),
            ),
        const SizedBox(height: WkSpacing.lg),
        // Premier de la série : c'est le seul geste qui change quelque chose
        // au profil qu'on est en train de lire.
        _LinkButton(
          label: context.l10n.brokerProfileEditorTitle,
          icon: Icons.edit_outlined,
          onPressed: onEditProfile,
        ),
        const SizedBox(height: WkSpacing.sm),
        _LinkButton(
          label: context.l10n.brokerVerificationTitle,
          icon: Icons.verified_user_outlined,
          onPressed: onOpenVerification,
        ),
        const SizedBox(height: WkSpacing.sm),
        _LinkButton(
          label: context.l10n.brokerRankingTitle,
          icon: Icons.insights_outlined,
          onPressed: onOpenRanking,
        ),
      ],
    );
  }
}

class _LinkButton extends StatelessWidget {
  const _LinkButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return WkButton(
      label: label,
      icon: icon,
      variant: WkButtonVariant.secondary,
      onPressed: onPressed,
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: WkSpacing.sm),
      child: Semantics(
        header: true,
        child: Text(title, style: context.text.headlineMedium),
      ),
    );
  }
}
