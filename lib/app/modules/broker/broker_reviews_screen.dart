import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/core/feedback/interaction_feedback.dart';
import 'package:woutalma_keur/app/core/state/mutation_state.dart';
import 'package:woutalma_keur/app/core/state/screen_state.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/repositories.dart';
import 'package:woutalma_keur/app/modules/broker/broker_failures.dart';
import 'package:woutalma_keur/app/ui/ui.dart';

class BrokerReviewsViewModel extends ChangeNotifier with BrokerFailures {
  BrokerReviewsViewModel({
    required ReviewRepository reviews,
    required String brokerId,
  }) : _reviews = reviews,
       _brokerId = brokerId;

  final ReviewRepository _reviews;
  final String _brokerId;

  ScreenState<List<Review>> _state = const ScreenState<List<Review>>.initial();

  ScreenState<List<Review>> get state => _state;

  MutationState _mutation = const MutationState.idle();

  MutationState get mutation => _mutation;

  Future<void> load() async {
    _state = const ScreenState<List<Review>>.loading();
    notifyListeners();

    try {
      final List<Review> all = await _reviews.byBroker(
        _brokerId,
        onlyPublic: false,
      );

      _state = all.isEmpty
          ? const ScreenState<List<Review>>.empty()
          : ScreenState<List<Review>>.data(all);
    } on Object catch (error) {
      _state = ScreenState<List<Review>>.error(onLoadError(error));
    }
    notifyListeners();
  }

  /// Ne touche jamais à la note ni au commentaire : un avis reçu n'est pas
  /// modifiable par celui qu'il note.
  Future<void> reply(Review review, String text) async {
    if (text.trim().isEmpty) {
      _mutation = const MutationState.idle();
      notifyListeners();
      return;
    }
    await _write(() => _reviews.reply(review.id, text.trim()));
  }

  Future<void> report(Review review) async {
    await _write(() => _reviews.report(review.id));
  }

  Future<void> _write(Future<Review> Function() action) async {
    _mutation = const MutationState.submitting();
    notifyListeners();
    try {
      await action();
      _mutation = const MutationState.success();
    } on Object catch (error) {
      _mutation = MutationState.failure(onWriteError(error));
      notifyListeners();
      return;
    }
    await load();
  }
}

class BrokerReviewsScreen extends StatelessWidget {
  const BrokerReviewsScreen({required this.onBack, super.key});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<BrokerReviewsViewModel>();
    final l = context.l10n;
    return AppScaffold(
      title: l.brokerReviewsTitle,
      onBack: onBack,
      onRefresh: model.load,
      body: model.state.map(
        initial: () => const AppSkeleton(height: 120),
        loading: () => const AppSkeleton(height: 120),
        empty: () => AppState(
          kind: AppStateKind.empty,
          icon: FIcons.star,
          title: l.brokerReviewsEmptyTitle,
          message: l.brokerReviewsEmptyBody,
        ),
        error: (_) =>
            brokerFailureState(context, model.loadFailure, onRetry: model.load),
        data: (reviews) => ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            Insets.page,
            0,
            Insets.page,
            Insets.xxl,
          ),
          itemCount: reviews.length + 1,
          separatorBuilder: (_, _) => const SizedBox(height: Insets.lg),
          itemBuilder: (_, i) => i == 0
              ? Text(
                  l.reviewCannotEdit,
                  style: context.text.bodySmall!.copyWith(
                    color: context.tones.inkSecondary,
                  ),
                )
              : _ReviewCard(
                  review: reviews[i - 1],
                  onReply: () => _reply(context, model, reviews[i - 1]),
                  onReport: () => _report(context, model, reviews[i - 1]),
                ),
        ),
      ),
    );
  }

  Future<void> _reply(
    BuildContext context,
    BrokerReviewsViewModel model,
    Review review,
  ) async {
    final l = context.l10n;
    final controller = TextEditingController();
    final text = await showAppSheet<String>(
      context,
      title: l.reviewReplyLabel,
      child: Builder(
        builder: (sheet) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheet).bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppField(
                label: l.reviewReplyLabel,
                hint: l.reviewReplyHint,
                controller: controller,
                maxLines: 3,
                autofocus: true,
              ),
              const SizedBox(height: Insets.lg),
              AppButton(
                l.reviewReplySend,
                icon: FIcons.reply,
                onPressed: () => popSheet(sheet, controller.text),
              ),
            ],
          ),
        ),
      ),
    );
    final written = text ?? '';
    controller.dispose();
    if (written.trim().isEmpty || !context.mounted) return;

    await model.reply(review, written);
    if (!context.mounted || _announceFailure(context, model)) return;
    context.read<InteractionFeedbackService?>()?.emit(
      FeedbackIntent.success,
      eventId: 'B06:success:reply-${review.id}',
    );
    toast(context, l.reviewReplySent);
  }

  Future<void> _report(
    BuildContext context,
    BrokerReviewsViewModel model,
    Review review,
  ) async {
    final l = context.l10n;
    final confirmed = await confirm(
      context,
      title: l.reviewReportTitle,
      message: l.reviewReportBody,
      action: l.reviewReportAction,
    );
    if (!confirmed || !context.mounted) return;

    await model.report(review);
    if (!context.mounted || _announceFailure(context, model)) return;
    toast(context, l.reviewReported);
  }

  bool _announceFailure(BuildContext context, BrokerReviewsViewModel model) {
    if (model.mutation is! MutationFailure) return false;
    context.read<InteractionFeedbackService?>()?.emit(FeedbackIntent.error);
    toast(context, brokerFailureText(context.l10n, model.writeFailure));
    return true;
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.review,
    required this.onReply,
    required this.onReport,
  });

  final Review review;
  final VoidCallback onReply, onReport;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AppCard(
      padding: const EdgeInsets.all(Insets.page),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: AppStars(review.rating.toDouble(), size: 18)),
              switch (review.moderation) {
                ModerationStatus.published => AppTag(
                  l.reviewModerationPublished,
                  tone: AppTone.success,
                  icon: FIcons.check,
                ),
                ModerationStatus.pending => AppTag(
                  l.reviewModerationPending,
                  tone: AppTone.warning,
                  icon: FIcons.hourglass,
                ),
                ModerationStatus.rejected => AppTag(
                  l.reviewModerationRejected,
                  icon: FIcons.ban,
                ),
              },
            ],
          ),
          if (review.comment != null) ...[
            const SizedBox(height: Insets.md),
            Text(review.comment!, style: context.text.bodyLarge),
          ],
          if (review.brokerReply != null) ...[
            const SizedBox(height: Insets.md),
            DecoratedBox(
              decoration: BoxDecoration(
                color: context.tones.sunken,
                borderRadius: Radii.container,
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
          const SizedBox(height: Insets.md),
          Row(
            children: [
              if (review.brokerReply == null)
                AppButton(
                  l.reviewReplyAction,
                  icon: FIcons.reply,
                  variant: AppButtonVariant.secondary,
                  size: 40,
                  onPressed: onReply,
                ),
              const Spacer(),
              AppButton(
                l.reviewReportAction,
                icon: FIcons.flag,
                variant: AppButtonVariant.ghost,
                size: 40,
                onPressed: onReport,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
