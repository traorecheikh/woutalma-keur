import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/core/state/mutation_state.dart';
import 'package:woutalma_keur/app/core/state/screen_state.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/ranking.dart';
import 'package:woutalma_keur/app/modules/client/broker/broker_view_model.dart';
import 'package:woutalma_keur/app/modules/client/broker/contact_sheet.dart';
import 'package:woutalma_keur/app/modules/client/explore/cards.dart';
import 'package:woutalma_keur/app/shared/formatters.dart';
import 'package:woutalma_keur/app/ui/ui.dart';

class BrokerScreen extends StatelessWidget {
  const BrokerScreen({
    required this.onBack,
    required this.onOpenProperty,
    super.key,
  });
  final VoidCallback onBack;
  final void Function(String propertyId) onOpenProperty;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<BrokerViewModel>();
    final detail = model.state.valueOrNull;
    final l = context.l10n;
    return AppScaffold(
      onBack: onBack,
      headerTitle: detail?.broker.name,
      bottom: detail == null
          ? null
          : AppButton(
              l.contactAction,
              icon: FIcons.phone,
              variant: AppButtonVariant.call,
              loading: model.contactState.isSubmitting,
              onPressed: () => _contact(context, model, detail.broker),
            ),
      body: model.state.map(
        initial: () => const SizedBox.shrink(),
        loading: () => const AppSkeleton(rows: 3, height: 140),
        empty: () =>
            AppState(kind: AppStateKind.empty, title: l.stateEmptyTitle),
        error: (f) => failureState(context, f, onRetry: model.load),
        data: (d) => _Body(detail: d, onOpenProperty: onOpenProperty),
      ),
    );
  }

  Future<void> _contact(
    BuildContext context,
    BrokerViewModel model,
    Broker broker,
  ) async {
    final channel = await ContactSheet.show(context, broker: broker);
    if (channel == null || !context.mounted) return;
    final opened = await model.contactVia(channel);
    if (!context.mounted) return;
    toast(
      context,
      opened
          ? context.l10n.contactLogged
          : failureText(
              context.l10n,
              model.contactState is MutationFailure
                  ? (model.contactState as MutationFailure).failure
                  : WkFailure.unknown,
            ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.detail, required this.onOpenProperty});
  final BrokerDetail detail;
  final void Function(String) onOpenProperty;

  @override
  Widget build(BuildContext context) {
    final b = detail.broker;
    final l = context.l10n;
    final dim = context.text.bodyMedium!.copyWith(
      color: context.tones.inkSecondary,
    );
    final recent = detail.reviews.take(2).toList();
    return ListView(
      padding: const EdgeInsets.only(bottom: Insets.xxl),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Insets.page,
            Insets.sm,
            Insets.page,
            0,
          ),
          child: Column(
            children: [
              AppAvatar(name: b.name, size: 72, imagePath: b.logoAsset),
              const SizedBox(height: Insets.lg),
              Text(
                b.name,
                style: context.text.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Insets.md),
              Wrap(
                spacing: Insets.sm,
                runSpacing: Insets.sm,
                alignment: WrapAlignment.center,
                children: [
                  if (b.isVerified)
                    AppTag(
                      l.badgeVerified,
                      tone: AppTone.success,
                      icon: FIcons.badgeCheck,
                    ),
                  if (b.pinned)
                    AppTag(
                      l.badgePinned,
                      tone: AppTone.accent,
                      icon: FIcons.sparkles,
                    ),
                ],
              ),
              const SizedBox(height: Insets.md),
              if (detail.reviews.isEmpty)
                Text(l.ratingNone, style: dim)
              else
                AppStars(detail.averageRating, count: detail.reviews.length),
              const SizedBox(height: Insets.sm),
              Text(
                '${WkFormat.distance(l, detail.distanceMeters)} · '
                '${l.brokerResponseRate((b.responseRate * 100).round())}',
                style: dim,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        if (b.coverage.isNotEmpty) ...[
          AppSection(l.brokerCoverage),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Insets.page),
            child: Wrap(
              spacing: Insets.sm,
              runSpacing: Insets.sm,
              children: [
                for (final zone in b.coverage)
                  AppTag(zone, icon: FIcons.mapPin),
              ],
            ),
          ),
        ],
        AppSection(l.brokerProperties),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Insets.page),
          child: detail.properties.isEmpty
              ? Text(l.brokerNoProperties, style: dim)
              : Column(
                  children: [
                    for (final p in detail.properties)
                      Padding(
                        padding: const EdgeInsets.only(bottom: Insets.xl),
                        child: PropertyCard(
                          property: p,
                          distanceMeters: distanceMeters(
                            detail.from,
                            p.position,
                          ),
                          onTap: () => onOpenProperty(p.id),
                        ),
                      ),
                  ],
                ),
        ),
        AppSection(
          l.brokerReviews,
          action: detail.reviews.length > recent.length
              ? l.exploreSeeAll
              : null,
          onAction: () => showAppSheet<void>(
            context,
            title: l.brokerReviews,
            scrollable: true,
            child: Column(
              children: [
                for (final r in detail.reviews)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Insets.md),
                    child: _ReviewTile(review: r),
                  ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Insets.page),
          child: recent.isEmpty
              ? Text(l.brokerNoReviews, style: dim)
              : Column(
                  children: [
                    for (final r in recent)
                      Padding(
                        padding: const EdgeInsets.only(bottom: Insets.md),
                        child: _ReviewTile(review: r),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});
  final Review review;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AppCard(
      padding: const EdgeInsets.all(Insets.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppStars(review.rating.toDouble()),
              const Spacer(),
              Text(
                DateFormat.yMMMd(l.localeName).format(review.createdAt),
                style: context.text.bodySmall!.copyWith(
                  color: context.tones.inkSecondary,
                ),
              ),
            ],
          ),
          if (review.comment != null) ...[
            const SizedBox(height: Insets.sm),
            Text(review.comment!, style: context.text.bodyLarge),
          ],
          if (review.brokerReply != null) ...[
            const SizedBox(height: Insets.md),
            DecoratedBox(
              decoration: BoxDecoration(
                color: context.tones.sunken,
                borderRadius: Radii.control,
              ),
              child: Padding(
                padding: const EdgeInsets.all(Insets.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.brokerReply,
                      style: context.text.bodySmall!.copyWith(
                        color: context.tones.inkSecondary,
                      ),
                    ),
                    const SizedBox(height: Insets.xs),
                    Text(review.brokerReply!, style: context.text.bodyMedium),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
