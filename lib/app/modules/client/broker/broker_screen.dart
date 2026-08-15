import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/core/state/screen_state.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/ranking.dart';
import 'package:woutalma_keur/app/modules/client/broker/broker_view_model.dart';
import 'package:woutalma_keur/app/modules/client/broker/contact_sheet.dart';
import 'package:woutalma_keur/app/shared/formatters.dart';
import 'package:woutalma_keur/app/shared/theme/wk_spacing.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_badge.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_button.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_property_card.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_rating.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_scaffold.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_states.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_toast.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_top_bar.dart';

/// C02 — Fiche courtier.
///
/// La question de l'écran : « puis-je lui faire confiance ? ». Tout ce qui y
/// répond — vérification, note, volume d'avis, réactivité — vient avant les
/// détails. L'action Contacter est ancrée en bas et ne défile jamais.
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
    final BrokerViewModel model = context.watch<BrokerViewModel>();
    final BrokerDetail? detail = model.state.valueOrNull;

    return WkScaffold(
      topBar: WkTopBar(
        title: detail?.broker.name ?? context.l10n.exploreNearYou,
        onBack: onBack,
      ),
      bottomAction: detail == null
          ? null
          : WkButton(
              label: context.l10n.contactAction,
              icon: Icons.phone_in_talk_outlined,
              loading: model.contactState.isSubmitting,
              onPressed: () => _startContact(context, model, detail.broker),
            ),
      body: model.state.map(
        initial: () => const SizedBox.shrink(),
        loading: () => const WkLoadingState(),
        empty: () => const WkEmptyState(),
        error: (WkFailure failure) =>
            WkErrorState(failure: failure, onRetry: model.load),
        data: (BrokerDetail value) =>
            _Content(detail: value, onOpenProperty: onOpenProperty),
      ),
    );
  }

  Future<void> _startContact(
    BuildContext context,
    BrokerViewModel model,
    Broker broker,
  ) async {
    final ContactChannel? channel = await ContactSheet.show(
      context,
      broker: broker,
    );
    if (channel == null || !context.mounted) {
      return;
    }

    final bool opened = await model.contactVia(channel);
    if (!context.mounted) {
      return;
    }

    if (!opened) {
      // Un canal qui ne s'ouvre pas doit se dire. Sinon l'utilisateur croit
      // avoir appelé.
      WkToast.show(context, message: context.l10n.failureUnknown);
      return;
    }
    WkToast.show(context, message: context.l10n.contactLogged);
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.detail, required this.onOpenProperty});

  final BrokerDetail detail;
  final void Function(String propertyId) onOpenProperty;

  @override
  Widget build(BuildContext context) {
    final Broker broker = detail.broker;

    return ListView(
      padding: const EdgeInsets.only(bottom: WkSpacing.lg),
      children: <Widget>[
        _TrustHero(detail: detail),
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
          for (final Property property in detail.properties)
            Padding(
              padding: const EdgeInsets.only(bottom: WkSpacing.sm),
              child: WkPropertyCard(
                property: property,
                // La distance du bien, pas celle du bureau qui le propose.
                distanceMeters: distanceMeters(detail.from, property.position),
                onOpen: () => onOpenProperty(property.id),
              ),
            ),
        const SizedBox(height: WkSpacing.lg),
        _Section(title: context.l10n.brokerReviews),
        if (detail.reviews.isEmpty)
          Text(
            context.l10n.brokerNoReviews,
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          )
        else
          for (final Review review in detail.reviews)
            _ReviewTile(review: review),
      ],
    );
  }
}

class _TrustHero extends StatelessWidget {
  const _TrustHero({required this.detail});

  final BrokerDetail detail;

  @override
  Widget build(BuildContext context) {
    final Broker broker = detail.broker;

    return Container(
      padding: const EdgeInsets.all(WkSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(WkRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: context.colors.primaryContainer,
                  borderRadius: BorderRadius.circular(
                    broker.kind == BrokerKind.agency
                        ? WkRadius.lg
                        : WkRadius.full,
                  ),
                ),
                child: Icon(
                  broker.kind == BrokerKind.agency
                      ? Icons.business_outlined
                      : Icons.support_agent_outlined,
                  color: context.colors.onPrimaryContainer,
                  size: 32,
                ),
              ),
              const SizedBox(width: WkSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    WkRating(
                      value: detail.averageRating,
                      reviewCount: detail.reviews.length,
                      compact: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: WkSpacing.md),
          Wrap(
            spacing: WkSpacing.xs,
            runSpacing: WkSpacing.xs,
            children: <Widget>[
              if (broker.pinned)
                WkBadge(
                  label: context.l10n.badgePinned,
                  icon: Icons.push_pin,
                  tone: WkBadgeTone.brand,
                ),
              if (broker.isVerified)
                WkBadge(
                  label: context.l10n.badgeVerified,
                  icon: Icons.verified_user,
                  tone: WkBadgeTone.positive,
                ),
            ],
          ),
          const SizedBox(height: WkSpacing.md),
          _TrustLine(
            icon: Icons.near_me_outlined,
            label: WkFormat.distance(context.l10n, detail.distanceMeters),
          ),
          const SizedBox(height: WkSpacing.xs),
          _TrustLine(
            icon: Icons.bolt_outlined,
            label: context.l10n.brokerResponseRate(
              (broker.responseRate * 100).round(),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustLine extends StatelessWidget {
  const _TrustLine({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: 18, color: context.colors.onSurfaceVariant),
        const SizedBox(width: WkSpacing.xs),
        Expanded(
          child: Text(
            label,
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ),
      ],
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

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: WkSpacing.sm),
      padding: const EdgeInsets.all(WkSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(WkRadius.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          WkRating(value: review.rating.toDouble(), reviewCount: 1),
          if (review.comment != null) ...<Widget>[
            const SizedBox(height: WkSpacing.sm),
            Text(review.comment!, style: context.text.bodyMedium),
          ],
          if (review.brokerReply != null) ...<Widget>[
            const SizedBox(height: WkSpacing.sm),
            Container(
              padding: const EdgeInsets.all(WkSpacing.sm),
              decoration: BoxDecoration(
                color: context.colors.surfaceVariant,
                borderRadius: BorderRadius.circular(WkRadius.xs),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    context.l10n.brokerReply,
                    style: context.text.labelSmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: WkSpacing.xs),
                  Text(review.brokerReply!, style: context.text.bodyMedium),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
