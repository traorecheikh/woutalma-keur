import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/modules/broker/broker_trust_screens.dart'
    show verificationTag;
import 'package:woutalma_keur/app/modules/client/broker/broker_view_model.dart';
import 'package:woutalma_keur/app/shared/formatters.dart';
import 'package:woutalma_keur/app/ui/ui.dart';

const _pad = EdgeInsets.symmetric(horizontal: Insets.page);

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
  final Future<void> Function() onEditProfile;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<BrokerViewModel>();
    final l = context.l10n;
    return AppScaffold(
      title: l.brokerProfileTitle,
      showBack: false,
      onRefresh: model.load,
      actions: [
        AppIconButton(
          icon: FIcons.settings,
          label: l.settingsTitle,
          onTap: onOpenSettings,
        ),
      ],
      body: model.state.map(
        initial: () => const AppSkeleton(height: 96),
        loading: () => const AppSkeleton(height: 96),
        empty: () => AppState(
          kind: AppStateKind.empty,
          title: l.stateEmptyTitle,
          message: l.stateEmptyBody,
        ),
        error: (failure) => failureState(context, failure, onRetry: model.load),
        data: (detail) => _Body(
          detail: detail,
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

class _Body extends StatelessWidget {
  const _Body({
    required this.detail,
    required this.onOpenVerification,
    required this.onOpenRanking,
    required this.onOpenProperty,
    required this.onEditProfile,
  });

  final BrokerDetail detail;
  final VoidCallback onOpenVerification;
  final VoidCallback onOpenRanking;
  final void Function(Property property) onOpenProperty;
  final VoidCallback onEditProfile;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final broker = detail.broker;
    return ListView(
      padding: const EdgeInsets.only(bottom: Insets.xxl),
      children: [
        Padding(
          padding: _pad,
          child: AppCard(
            padding: const EdgeInsets.all(Insets.page),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppAvatar(
                  name: broker.name,
                  size: 64,
                  imagePath: broker.logoAsset,
                ),
                const SizedBox(width: Insets.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(broker.name, style: context.text.titleLarge),
                      const SizedBox(height: Insets.sm),
                      Wrap(
                        spacing: Insets.sm,
                        runSpacing: Insets.xs,
                        children: [
                          verificationTag(context, broker.verification),
                          if (broker.pinned)
                            AppTag(
                              l.badgePinned,
                              tone: AppTone.accent,
                              icon: FIcons.pin,
                            ),
                        ],
                      ),
                      const SizedBox(height: Insets.md),
                      if (detail.reviews.isEmpty)
                        Text(
                          l.ratingNone,
                          style: context.text.bodySmall!.copyWith(
                            color: context.tones.inkSecondary,
                          ),
                        )
                      else
                        AppStars(
                          detail.averageRating,
                          count: detail.reviews.length,
                        ),
                      const SizedBox(height: Insets.xs),
                      Text(
                        l.brokerResponseRate(
                          (broker.responseRate * 100).round(),
                        ),
                        style: context.text.bodySmall!.copyWith(
                          color: context.tones.inkSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        AppSection(l.brokerCoverage),
        Padding(
          padding: _pad,
          child: broker.coverage.isEmpty
              ? Text(
                  l.commonUnspecified,
                  style: context.text.bodyMedium!.copyWith(
                    color: context.tones.inkSecondary,
                  ),
                )
              : Wrap(
                  spacing: Insets.sm,
                  runSpacing: Insets.sm,
                  children: [
                    for (final zone in broker.coverage)
                      AppTag(zone, icon: FIcons.mapPin),
                  ],
                ),
        ),
        AppSection(l.brokerProperties),
        Padding(
          padding: _pad,
          child: detail.properties.isEmpty
              ? Text(
                  l.brokerNoProperties,
                  style: context.text.bodyMedium!.copyWith(
                    color: context.tones.inkSecondary,
                  ),
                )
              : _PropertyCard(
                  property: detail.properties.first,
                  onTap: () => onOpenProperty(detail.properties.first),
                ),
        ),
        const SizedBox(height: Insets.xl),
        Padding(
          padding: _pad,
          child: AppCard.rows([
            AppRow(
              title: l.brokerProfileEditorTitle,
              leading: const Icon(FIcons.pencil),
              onTap: onEditProfile,
            ),
            AppRow(
              title: l.brokerVerificationTitle,
              leading: const Icon(FIcons.badgeCheck),
              onTap: onOpenVerification,
            ),
            AppRow(
              title: l.brokerRankingTitle,
              leading: const Icon(FIcons.chartColumn),
              onTap: onOpenRanking,
            ),
          ]),
        ),
      ],
    );
  }
}

class _PropertyCard extends StatelessWidget {
  const _PropertyCard({required this.property, required this.onTap});

  final Property property;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppPhoto(
            property.photoAssets.firstOrNull,
            aspectRatio: 16 / 10,
            radius: BorderRadius.zero,
          ),
          Padding(
            padding: const EdgeInsets.all(Insets.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  WkFormat.price(l, property.price, property.transaction),
                  style: AppText.moneyLg,
                ),
                const SizedBox(height: Insets.xs),
                Text(
                  property.title,
                  style: context.text.bodyLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
