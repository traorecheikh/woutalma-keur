import 'package:flutter/material.dart';
import 'package:forui/forui.dart' show FDeterminateProgress;
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/core/feedback/interaction_feedback.dart';
import 'package:woutalma_keur/app/core/state/mutation_state.dart';
import 'package:woutalma_keur/app/core/state/screen_state.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/ranking.dart';
import 'package:woutalma_keur/app/domain/repositories.dart';
import 'package:woutalma_keur/app/modules/broker/broker_failures.dart';
import 'package:woutalma_keur/app/ui/ui.dart';

const _pad = EdgeInsets.symmetric(horizontal: Insets.page);

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

  ScreenState<Broker> _state = const ScreenState<Broker>.initial();

  ScreenState<Broker> get state => _state;

  Broker? get broker => _state.valueOrNull;

  double averageRating = 0;
  int reviewCount = 0;

  MutationState _request = const MutationState.idle();

  MutationState get request => _request;

  Future<void> load() async {
    if (_state is! ScreenData<Broker>) {
      _state = const ScreenState<Broker>.loading();
      notifyListeners();
    }

    try {
      final Broker? current = await _brokers.byId(_brokerId);
      final List<Review> published = await _reviews.byBroker(_brokerId);
      reviewCount = published.length;
      averageRating = published.isEmpty
          ? 0
          : published
                    .map((Review r) => r.rating)
                    .reduce((int a, int b) => a + b) /
                published.length;
      _state = current == null
          ? const ScreenState<Broker>.error(WkFailure.notFound)
          : ScreenState<Broker>.data(current);
    } on Object catch (error) {
      _state = ScreenState<Broker>.error(brokerFailure(error));
    }
    notifyListeners();
  }

  /// Le serveur peut accepter la requête sans changer le statut : le succès
  /// n'est annoncé que si le profil est réellement passé « en attente ».
  Future<void> submitVerification() async {
    final Broker? current = broker;
    if (current == null || current.verification == VerificationStatus.pending) {
      _request = const MutationState.idle();
      notifyListeners();
      return;
    }

    _request = const MutationState.submitting();
    notifyListeners();

    try {
      await _brokers.requestVerification(current.id);
    } on Object catch (error) {
      _request = MutationState.failure(brokerFailure(error));
      notifyListeners();
      return;
    }

    await load();
    _request = broker?.verification == VerificationStatus.pending
        ? const MutationState.success()
        : const MutationState.failure(WkFailure.unknown);
    notifyListeners();
  }

  /// Contribution de chaque facteur au score, à une distance de référence :
  /// la proximité dépend du client, il n'existe pas de classement unique.
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

AppTag verificationTag(BuildContext context, VerificationStatus? status) {
  final l = context.l10n;
  return switch (status) {
    VerificationStatus.verified => AppTag(
      l.badgeVerified,
      tone: AppTone.success,
      icon: FIcons.badgeCheck,
    ),
    VerificationStatus.pending => AppTag(
      l.brokerVerificationPending,
      tone: AppTone.warning,
      icon: FIcons.hourglass,
    ),
    VerificationStatus.rejected => AppTag(
      l.brokerVerificationTagRejected,
      tone: AppTone.danger,
      icon: FIcons.ban,
    ),
    _ => AppTag(l.brokerVerificationMissing, icon: FIcons.circleQuestionMark),
  };
}

class BrokerVerificationScreen extends StatelessWidget {
  const BrokerVerificationScreen({required this.onBack, super.key});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<BrokerTrustViewModel>();
    final l = context.l10n;
    final status = model.broker?.verification;
    return AppScaffold(
      title: l.brokerVerificationTitle,
      onBack: onBack,
      bottom: status == null || status == VerificationStatus.verified
          ? null
          : AppButton(
              status == VerificationStatus.pending
                  ? l.brokerVerificationWaiting
                  : l.brokerVerificationSubmit,
              icon: FIcons.badgeCheck,
              loading: model.request.isSubmitting,
              onPressed: status == VerificationStatus.pending
                  ? null
                  : () => _submit(context, model),
            ),
      body: model.state.map(
        initial: () => const AppSkeleton(rows: 2, height: 120),
        loading: () => const AppSkeleton(rows: 2, height: 120),
        empty: () =>
            AppState(kind: AppStateKind.empty, title: l.stateEmptyTitle),
        error: (failure) => failureState(context, failure, onRetry: model.load),
        data: (broker) => ListView(
          padding: const EdgeInsets.only(bottom: Insets.xxl),
          children: [
            Padding(
              padding: _pad,
              child: AppCard(
                padding: const EdgeInsets.all(Insets.page),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      spacing: Insets.md,
                      children: [
                        Icon(
                          FIcons.badgeCheck,
                          color: context.colors.onSurface,
                        ),
                        Expanded(
                          child: verificationTag(context, broker.verification),
                        ),
                      ],
                    ),
                    const SizedBox(height: Insets.lg),
                    Text(
                      l.brokerVerificationExplain,
                      style: context.text.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Insets.lg),
            Padding(
              padding: _pad,
              child: Text(
                switch (broker.verification) {
                  VerificationStatus.verified => l.brokerVerificationDone,
                  VerificationStatus.pending => l.brokerVerificationWaiting,
                  VerificationStatus.rejected => l.brokerVerificationRejected,
                  VerificationStatus.none => l.brokerVerificationHowTo,
                },
                style: context.text.bodyMedium!.copyWith(
                  color: context.tones.inkSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context, BrokerTrustViewModel model) async {
    await model.submitVerification();
    if (!context.mounted) return;

    final feedback = context.read<InteractionFeedbackService?>();
    if (model.request is! MutationSuccess) {
      feedback?.emit(FeedbackIntent.error);
      toast(context, context.l10n.brokerVerificationNotSent);
      return;
    }
    feedback?.emit(
      FeedbackIntent.success,
      eventId: 'B09:success:${model.broker?.id}',
    );
    toast(context, context.l10n.brokerVerificationSent);
  }
}

class BrokerRankingScreen extends StatelessWidget {
  const BrokerRankingScreen({required this.onBack, super.key});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<BrokerTrustViewModel>();
    final l = context.l10n;
    return AppScaffold(
      title: l.brokerRankingTitle,
      onBack: onBack,
      body: model.state.map(
        initial: () => const AppSkeleton(rows: 4, height: 88),
        loading: () => const AppSkeleton(rows: 4, height: 88),
        empty: () =>
            AppState(kind: AppStateKind.empty, title: l.stateEmptyTitle),
        error: (failure) => failureState(context, failure, onRetry: model.load),
        data: (_) => _Ranking(parts: model.contributions()),
      ),
    );
  }
}

class _Ranking extends StatelessWidget {
  const _Ranking({required this.parts});

  final Map<String, int> parts;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return ListView(
      padding: const EdgeInsets.only(bottom: Insets.xxl),
      children: [
        Padding(
          padding: _pad,
          child: Text(l.brokerRankingExplain, style: context.text.bodyLarge),
        ),
        const SizedBox(height: Insets.xl),
        for (final (key, label) in [
          ('rating', l.brokerRankingRating),
          ('proximity', l.brokerRankingProximity),
          ('volume', l.brokerRankingVolume),
          ('response', l.brokerRankingResponse),
        ])
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Insets.page,
              0,
              Insets.page,
              Insets.md,
            ),
            child: _Factor(label: label, percent: parts[key] ?? 0),
          ),
        const SizedBox(height: Insets.md),
        Padding(
          padding: _pad,
          child: Text(
            l.brokerRankingVaries,
            style: context.text.bodySmall!.copyWith(
              color: context.tones.inkSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _Factor extends StatelessWidget {
  const _Factor({required this.label, required this.percent});

  final String label;
  final int percent;

  @override
  Widget build(BuildContext context) {
    final value = context.l10n.brokerRankingPercent(percent);
    return Semantics(
      label: label,
      value: value,
      excludeSemantics: true,
      child: AppCard(
        padding: const EdgeInsets.all(Insets.page),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(label, style: context.text.bodyLarge)),
                Text(value, style: context.text.labelLarge),
              ],
            ),
            const SizedBox(height: Insets.md),
            FDeterminateProgress(value: percent.clamp(0, 100) / 100),
          ],
        ),
      ),
    );
  }
}
