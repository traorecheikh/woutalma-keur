import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/core/feedback/interaction_feedback.dart';
import 'package:woutalma_keur/app/core/state/mutation_state.dart';
import 'package:woutalma_keur/app/core/state/screen_state.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/repositories.dart';
import 'package:woutalma_keur/app/modules/broker/broker_failures.dart';
import 'package:woutalma_keur/app/shared/theme/wk_spacing.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_badge.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_button.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_confirm_sheet.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_rating.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_scaffold.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_states.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_text_field.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_toast.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_top_bar.dart';

/// Coordonne B06.
class BrokerReviewsViewModel extends ChangeNotifier {
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

  /// État de la dernière réponse ou du dernier signalement.
  ///
  /// L'écran le lit après coup : sans lui, un envoi refusé par le serveur
  /// affichait quand même « Réponse publiée ».
  MutationState get mutation => _mutation;

  Future<void> load() async {
    _state = const ScreenState<List<Review>>.loading();
    notifyListeners();

    try {
      // Le courtier voit aussi ce qui est en modération : c'est son profil, et
      // il doit pouvoir signaler un abus avant publication.
      final List<Review> all = await _reviews.byBroker(
        _brokerId,
        onlyPublic: false,
      );

      _state = all.isEmpty
          ? const ScreenState<List<Review>>.empty()
          : ScreenState<List<Review>>.data(all);
    } on Object catch (error) {
      _state = ScreenState<List<Review>>.error(brokerFailure(error));
    }
    notifyListeners();
  }

  /// Publie une réponse. **Ne touche jamais à la note ni au commentaire** :
  /// un avis reçu n'est pas modifiable par celui qu'il note, sans quoi la
  /// réputation ne vaut plus rien.
  Future<void> reply(Review review, String text) async {
    if (text.trim().isEmpty) {
      _mutation = const MutationState.idle();
      notifyListeners();
      return;
    }
    // Route dédiée : répondre n'est pas déposer un avis. Renvoyer l'avis
    // entier par `save()` postait un nouvel avis signé du courtier contre le
    // contact du client, que le serveur refusait en 403 — et le refus, non
    // rattrapé, ne laissait rien à l'écran.
    await _write(() => _reviews.reply(review.id, text.trim()));
  }

  /// Signale un abus. L'avis **reste visible** : le masquer sur simple
  /// signalement offrirait à chaque courtier un bouton pour effacer ses
  /// mauvaises notes.
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
      _mutation = MutationState.failure(brokerFailure(error));
      notifyListeners();
      return;
    }
    await load();
  }
}

/// B06 — Avis reçus.
class BrokerReviewsScreen extends StatelessWidget {
  const BrokerReviewsScreen({required this.onBack, super.key});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final BrokerReviewsViewModel model = context
        .watch<BrokerReviewsViewModel>();

    return WkScaffold(
      topBar: WkTopBar(title: context.l10n.brokerReviewsTitle, onBack: onBack),
      body: model.state.map(
        initial: () => const SizedBox.shrink(),
        loading: () => const WkLoadingState(),
        empty: () => WkEmptyState(
          icon: Icons.star_outline,
          title: context.l10n.brokerReviewsEmptyTitle,
          body: context.l10n.brokerReviewsEmptyBody,
        ),
        error: (WkFailure failure) =>
            WkErrorState(failure: failure, onRetry: model.load),
        data: (List<Review> reviews) => ListView.separated(
          padding: const EdgeInsets.only(bottom: WkSpacing.xxxl + WkSpacing.xl),
          // Une ligne de plus que d'avis : la règle en tête de liste.
          itemCount: reviews.length + 1,
          separatorBuilder: (_, _) => const SizedBox(height: WkSpacing.sm),
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              // Dit une fois, en tête : répété sur chaque carte, il devenait
              // du bruit qu'on cesse de lire dès le deuxième avis.
              return Padding(
                padding: const EdgeInsets.only(bottom: WkSpacing.sm),
                child: Text(
                  context.l10n.reviewCannotEdit,
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              );
            }
            return _ReceivedReview(review: reviews[index - 1], model: model);
          },
        ),
      ),
    );
  }
}

class _ReceivedReview extends StatefulWidget {
  const _ReceivedReview({required this.review, required this.model});

  final Review review;
  final BrokerReviewsViewModel model;

  @override
  State<_ReceivedReview> createState() => _ReceivedReviewState();
}

class _ReceivedReviewState extends State<_ReceivedReview> {
  final TextEditingController _reply = TextEditingController();
  bool _replying = false;

  @override
  void dispose() {
    _reply.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Review review = widget.review;

    return Container(
      padding: const EdgeInsets.all(WkSpacing.lg),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(WkRadius.lg),
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          WkRating.single(rating: review.rating),
          const SizedBox(height: WkSpacing.sm),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: _ModerationBadge(status: review.moderation),
          ),
          if (review.comment != null) ...<Widget>[
            const SizedBox(height: WkSpacing.sm),
            Text(review.comment!, style: context.text.bodyMedium),
          ],
          if (review.brokerReply != null) ...<Widget>[
            const SizedBox(height: WkSpacing.sm),
            Container(
              width: double.infinity,
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
          if (_replying) ...<Widget>[
            const SizedBox(height: WkSpacing.sm),
            WkTextField(
              label: context.l10n.reviewReplyLabel,
              hint: context.l10n.reviewReplyHint,
              controller: _reply,
            ),
            WkButton(
              label: context.l10n.reviewReplySend,
              onPressed: () => _sendReply(context),
            ),
          ] else ...<Widget>[
            const SizedBox(height: WkSpacing.md),
            if (review.brokerReply == null) ...<Widget>[
              WkButton(
                label: context.l10n.reviewReplyAction,
                icon: Icons.reply,
                variant: WkButtonVariant.secondary,
                onPressed: () => setState(() => _replying = true),
              ),
              const SizedBox(height: WkSpacing.sm),
            ],
            WkButton(
              label: context.l10n.reviewReportAction,
              icon: Icons.flag_outlined,
              variant: WkButtonVariant.ghost,
              onPressed: () => _report(context),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _sendReply(BuildContext context) async {
    await widget.model.reply(widget.review, _reply.text);
    if (!context.mounted) {
      return;
    }
    if (_announceFailure(context)) {
      // La réponse reste à l'écran : la retaper après un réseau coupé serait
      // la punition de trop.
      return;
    }
    setState(() => _replying = false);
    context.read<InteractionFeedbackService?>()?.emit(
      FeedbackIntent.success,
      eventId: 'B06:success:reply-${widget.review.id}',
    );
    WkToast.show(context, message: context.l10n.reviewReplySent);
  }

  /// Dit l'échec s'il y en a un. Renvoie vrai quand rien n'a été écrit.
  bool _announceFailure(BuildContext context) {
    final MutationState mutation = widget.model.mutation;
    if (mutation is! MutationFailure) {
      return false;
    }
    context.read<InteractionFeedbackService?>()?.emit(FeedbackIntent.error);
    WkToast.show(
      context,
      message: failureMessage(context.l10n, mutation.failure),
    );
    return true;
  }

  Future<void> _report(BuildContext context) async {
    final bool? confirmed = await WkConfirmSheet.show(
      context,
      title: context.l10n.reviewReportTitle,
      body: context.l10n.reviewReportBody,
      confirmLabel: context.l10n.reviewReportAction,
      cancelLabel: context.l10n.commonCancel,
    );
    if (confirmed != true || !context.mounted) {
      return;
    }

    await widget.model.report(widget.review);
    if (!context.mounted) {
      return;
    }
    if (_announceFailure(context)) {
      return;
    }
    WkToast.show(context, message: context.l10n.reviewReported);
  }
}

class _ModerationBadge extends StatelessWidget {
  const _ModerationBadge({required this.status});

  final ModerationStatus status;

  @override
  Widget build(BuildContext context) {
    return WkBadge(
      label: switch (status) {
        ModerationStatus.pending => context.l10n.reviewModerationPending,
        ModerationStatus.published => context.l10n.reviewModerationPublished,
        ModerationStatus.rejected => context.l10n.reviewModerationRejected,
      },
      icon: switch (status) {
        ModerationStatus.pending => Icons.hourglass_empty,
        ModerationStatus.published => Icons.public,
        ModerationStatus.rejected => Icons.block,
      },
      tone: switch (status) {
        ModerationStatus.pending => WkBadgeTone.brand,
        ModerationStatus.published => WkBadgeTone.positive,
        ModerationStatus.rejected => WkBadgeTone.neutral,
      },
    );
  }
}
