import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/core/feedback/interaction_feedback.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/ranking.dart';
import 'package:woutalma_keur/app/domain/repositories.dart';
import 'package:woutalma_keur/app/shared/theme/wk_motion.dart';
import 'package:woutalma_keur/app/shared/theme/wk_spacing.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_badge.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_button.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_scaffold.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_toast.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_top_bar.dart';

/// Coordonne B09 et B10, qui partagent la même donnée : le profil courtier.
class BrokerTrustViewModel extends ChangeNotifier {
  BrokerTrustViewModel({
    required BrokerRepository brokers,
    required ReviewRepository reviews,
    required String brokerId,
    this.ranking = const RankingService(),
  }) : _brokers = brokers,
       _reviews = reviews,
       _brokerId = brokerId;

  final BrokerRepository _brokers;
  final ReviewRepository _reviews;
  final String _brokerId;
  final RankingService ranking;

  Broker? broker;
  double averageRating = 0;
  int reviewCount = 0;

  Future<void> load() async {
    broker = await _brokers.byId(_brokerId);
    final List<Review> published = await _reviews.byBroker(_brokerId);
    reviewCount = published.length;
    averageRating = published.isEmpty
        ? 0
        : published
                  .map((Review r) => r.rating)
                  .reduce((int a, int b) => a + b) /
              published.length;
    notifyListeners();
  }

  /// Soumet la demande de vérification.
  ///
  /// Le prototype ne joint aucune pièce : la décision appartient à un
  /// modérateur hors application. Le profil passe simplement « en attente »,
  /// ce que l'écran dit sans promettre de délai.
  Future<void> submitVerification() async {
    final Broker? current = broker;
    if (current == null || current.verification == VerificationStatus.pending) {
      return;
    }
    await _brokers.save(
      Broker(
        id: current.id,
        kind: current.kind,
        name: current.name,
        phone: current.phone,
        whatsapp: current.whatsapp,
        position: current.position,
        coverage: current.coverage,
        logoAsset: current.logoAsset,
        verification: VerificationStatus.pending,
        responseRate: current.responseRate,
        pinned: current.pinned,
      ),
    );
    await load();
  }

  /// Contribution de chaque facteur au score, en pourcentage.
  ///
  /// Calculée à une distance de référence : la proximité dépend du client, et
  /// prétendre le contraire ferait croire à un classement unique.
  Map<String, int> contributions({double referenceMeters = 2000}) {
    final double rating =
        ranking.ratingWeight *
        (ranking.bayesianRating(averageRating, reviewCount) / 5);
    final double proximity =
        ranking.proximityWeight * ranking.proximityFactor(referenceMeters);
    final double volume =
        ranking.volumeWeight * ranking.volumeFactor(reviewCount);
    final double response =
        ranking.responseWeight * (broker?.responseRate ?? 0).clamp(0, 1);
    final double total = rating + proximity + volume + response;
    if (total <= 0) {
      return const <String, int>{};
    }
    return <String, int>{
      'rating': (rating / total * 100).round(),
      'proximity': (proximity / total * 100).round(),
      'volume': (volume / total * 100).round(),
      'response': (response / total * 100).round(),
    };
  }
}

/// B09 — Vérification.
class BrokerVerificationScreen extends StatelessWidget {
  const BrokerVerificationScreen({required this.onBack, super.key});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final BrokerTrustViewModel model = context.watch<BrokerTrustViewModel>();
    final VerificationStatus status =
        model.broker?.verification ?? VerificationStatus.none;

    return WkScaffold(
      topBar: WkTopBar(
        title: context.l10n.brokerVerificationTitle,
        onBack: onBack,
      ),
      bottomAction: status == VerificationStatus.verified
          ? null
          : WkButton(
              label: context.l10n.brokerVerificationSubmit,
              onPressed: status == VerificationStatus.pending
                  ? null
                  : () => _submit(context, model),
              disabledReason: status == VerificationStatus.pending
                  ? context.l10n.brokerVerificationWaiting
                  : null,
            ),
      body: ListView(
        children: <Widget>[
          DecoratedBox(
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(WkRadius.xl),
            ),
            child: Padding(
              padding: const EdgeInsets.all(WkSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: context.colors.primaryContainer,
                      borderRadius: BorderRadius.circular(WkRadius.full),
                    ),
                    child: Icon(
                      Icons.verified_user_outlined,
                      color: context.colors.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: WkSpacing.md),
                  Expanded(
                    child: Text(
                      context.l10n.brokerVerificationExplain,
                      style: context.text.bodyLarge,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: WkSpacing.lg),
          // Aligné, pas étiré : enfant direct d'un `ListView`, la pastille
          // recevait toute la largeur et se lisait comme une bannière.
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: WkBadge(
              label: switch (status) {
                VerificationStatus.verified => context.l10n.badgeVerified,
                VerificationStatus.pending =>
                  context.l10n.brokerVerificationPending,
                VerificationStatus.rejected =>
                  context.l10n.brokerVerificationRejected,
                VerificationStatus.none =>
                  context.l10n.brokerVerificationMissing,
              },
              icon: switch (status) {
                VerificationStatus.verified => Icons.verified_user,
                VerificationStatus.pending => Icons.hourglass_empty,
                VerificationStatus.rejected => Icons.block,
                VerificationStatus.none => Icons.help_outline,
              },
              tone: switch (status) {
                VerificationStatus.verified => WkBadgeTone.positive,
                VerificationStatus.pending => WkBadgeTone.brand,
                _ => WkBadgeTone.neutral,
              },
            ),
          ),
          const SizedBox(height: WkSpacing.md),
          Text(
            switch (status) {
              VerificationStatus.verified =>
                context.l10n.brokerVerificationDone,
              VerificationStatus.pending =>
                context.l10n.brokerVerificationWaiting,
              VerificationStatus.rejected =>
                context.l10n.brokerVerificationRejected,
              // Pas une répétition de l'explication du haut : ce qu'il
              // reste à faire.
              VerificationStatus.none => context.l10n.brokerVerificationHowTo,
            },
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(BuildContext context, BrokerTrustViewModel model) async {
    await model.submitVerification();
    if (!context.mounted) {
      return;
    }
    context.read<InteractionFeedbackService?>()?.emit(
      FeedbackIntent.success,
      eventId: 'B09:success:${model.broker?.id}',
    );
    WkToast.show(context, message: context.l10n.brokerVerificationSent);
  }
}

/// B10 — Mon classement.
///
/// Explique la position sans la promettre : la proximité dépend du client, il
/// n'existe pas de rang unique.
class BrokerRankingScreen extends StatelessWidget {
  const BrokerRankingScreen({required this.onBack, super.key});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final BrokerTrustViewModel model = context.watch<BrokerTrustViewModel>();
    final Map<String, int> parts = model.contributions();

    return WkScaffold(
      topBar: WkTopBar(title: context.l10n.brokerRankingTitle, onBack: onBack),
      body: ListView(
        children: <Widget>[
          Text(
            context.l10n.brokerRankingExplain,
            style: context.text.bodyLarge,
          ),
          const SizedBox(height: WkSpacing.lg),
          for (final (String key, String label) in <(String, String)>[
            ('rating', context.l10n.brokerRankingRating),
            ('proximity', context.l10n.brokerRankingProximity),
            ('volume', context.l10n.brokerRankingVolume),
            ('response', context.l10n.brokerRankingResponse),
          ])
            _Factor(label: label, percent: parts[key] ?? 0),
          const SizedBox(height: WkSpacing.lg),
          Text(
            context.l10n.brokerRankingVaries,
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _Factor extends StatelessWidget {
  const _Factor({required this.label, required this.percent});

  final String label;
  final int percent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: WkSpacing.md),
      child: Semantics(
        label: label,
        value: context.l10n.brokerRankingPercent(percent),
        excludeSemantics: true,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(WkRadius.lg),
            border: Border.all(color: context.colors.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(WkSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(child: Text(label, style: context.text.bodyLarge)),
                    Text(
                      context.l10n.brokerRankingPercent(percent),
                      style: context.text.labelLarge,
                    ),
                  ],
                ),
                const SizedBox(height: WkSpacing.sm),
                _FactorBar(percent: percent),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FactorBar extends StatelessWidget {
  const _FactorBar({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    final double value = (percent.clamp(0, 100)) / 100;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Stack(
          children: <Widget>[
            Container(
              height: WkSpacing.md,
              decoration: BoxDecoration(
                color: context.colors.surfaceVariant,
                borderRadius: BorderRadius.circular(WkRadius.full),
              ),
            ),
            AnimatedContainer(
              duration: context.motion.standard,
              curve: WkMotion.standardCurve,
              width: constraints.maxWidth * value,
              height: WkSpacing.md,
              decoration: BoxDecoration(
                color: context.colors.primary,
                borderRadius: BorderRadius.circular(WkRadius.full),
              ),
            ),
          ],
        );
      },
    );
  }
}
