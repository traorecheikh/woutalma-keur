import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/core/feedback/interaction_feedback.dart';
import 'package:woutalma_keur/app/core/state/mutation_state.dart';
import 'package:woutalma_keur/app/core/state/screen_state.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/repositories.dart';
import 'package:woutalma_keur/app/domain/review_eligibility.dart';
import 'package:woutalma_keur/app/ui/ui.dart';

/// Coordonne C05.
class ReviewViewModel extends ChangeNotifier {
  ReviewViewModel({
    required ContactLog contact,
    required ReviewRepository reviews,
    required ContactRepository contacts,
    required DateTime Function() now,
  }) : _contact = contact,
       _reviews = reviews,
       _contacts = contacts,
       _now = now;

  final ContactLog _contact;
  final ReviewRepository _reviews;
  final ContactRepository _contacts;
  final DateTime Function() _now;

  int _rating = 0;
  int _responsiveness = 0;
  int _accuracy = 0;
  int _courtesy = 0;
  MutationState _submission = const MutationState.idle();

  int get rating => _rating;
  int get responsiveness => _responsiveness;
  int get accuracy => _accuracy;
  int get courtesy => _courtesy;
  MutationState get submission => _submission;

  /// Seule la note globale est obligatoire. Exiger les trois critères ferait
  /// abandonner la moitié des avis.
  bool get canSubmit => _rating > 0 && !_submission.isSubmitting;

  void setRating(int value) {
    _rating = value;
    notifyListeners();
  }

  void setResponsiveness(int value) {
    _responsiveness = value;
    notifyListeners();
  }

  void setAccuracy(int value) {
    _accuracy = value;
    notifyListeners();
  }

  void setCourtesy(int value) {
    _courtesy = value;
    notifyListeners();
  }

  Future<bool> submit(String? comment) async {
    if (!canSubmit) {
      return false;
    }
    _submission = const MutationState.submitting();
    notifyListeners();

    // L'identifiant est celui que le serveur attribue : le nôtre n'est qu'une
    // valeur d'attente pour le dépôt local.
    try {
      final Review saved = await _reviews.save(
        Review(
          id: 'rev-${_contact.id}',
          brokerId: _contact.brokerId,
          contactId: _contact.id,
          rating: _rating,
          responsiveness: _optionalScore(_responsiveness),
          accuracy: _optionalScore(_accuracy),
          courtesy: _optionalScore(_courtesy),
          comment: (comment == null || comment.trim().isEmpty)
              ? null
              : comment.trim(),
          createdAt: _now(),
        ),
      );
      // Consomme le contact : un échange n'ouvre qu'un seul avis.
      await _contacts.update(_contact.copyWith(reviewId: saved.id));
    } on ReviewNotAllowed catch (refusal) {
      // Le serveur revérifie l'éligibilité et dit laquelle des quatre règles a
      // refusé. Sans ce catch, le refus partait au néant et le bouton Envoyer
      // tournait indéfiniment.
      _submission = MutationState.failure(_failureFor(refusal.reason));
      notifyListeners();
      return false;
    } on DioException catch (error) {
      _submission = MutationState.failure(
        error.response == null ? WkFailure.network : WkFailure.unknown,
      );
      notifyListeners();
      return false;
    } on Object {
      _submission = const MutationState.failure(WkFailure.unknown);
      notifyListeners();
      return false;
    }

    _submission = const MutationState.success();
    notifyListeners();
    return true;
  }

  int? _optionalScore(int value) => value == 0 ? null : value;

  /// Un refus d'éligibilité n'est pas une panne : c'est une règle produit.
  static WkFailure _failureFor(ReviewRefusal reason) => switch (reason) {
    ReviewRefusal.noContact ||
    ReviewRefusal.notOwner ||
    ReviewRefusal.notReached ||
    ReviewRefusal.alreadyReviewed => WkFailure.permission,
  };
}

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({
    required this.brokerName,
    required this.onDone,
    required this.onBack,
    super.key,
  });
  final String brokerName;
  final VoidCallback onDone;
  final VoidCallback onBack;

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final _comment = TextEditingController();
  bool _commenting = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ReviewViewModel>();
    final l = context.l10n;
    return AppScaffold(
      headerTitle: l.reviewTitle,
      title: widget.brokerName,
      onBack: _commenting
          ? () => setState(() => _commenting = false)
          : widget.onBack,
      bottom: AppButton(
        _commenting ? l.reviewSubmit : l.commonNext,
        loading: model.submission.isSubmitting,
        onPressed: () => _next(context, model),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Insets.page,
          0,
          Insets.page,
          Insets.xxl,
        ),
        children: _commenting
            ? [
                AppField(
                  label: l.reviewCommentLabel,
                  hint: l.reviewCommentHint,
                  controller: _comment,
                  maxLines: 5,
                  autofocus: true,
                ),
              ]
            : [
                Text(l.reviewRatingQuestion, style: context.text.titleLarge),
                const SizedBox(height: Insets.lg),
                Center(
                  child: _Stars(
                    value: model.rating,
                    onChanged: model.setRating,
                    size: Touch.min,
                  ),
                ),
                const SizedBox(height: Insets.sm),
                Center(
                  child: Semantics(
                    liveRegion: true,
                    child: Text(
                      model.rating == 0
                          ? l.reviewMissingRating
                          : l.reviewStarLabel(model.rating),
                      style: context.text.bodyMedium!.copyWith(
                        color: context.tones.inkSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: Insets.xxl),
                AppCard(
                  padding: const EdgeInsets.all(Insets.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Criterion(
                        label: l.reviewCriteriaResponsiveness,
                        value: model.responsiveness,
                        onChanged: model.setResponsiveness,
                      ),
                      _Criterion(
                        label: l.reviewCriteriaAccuracy,
                        value: model.accuracy,
                        onChanged: model.setAccuracy,
                      ),
                      _Criterion(
                        label: l.reviewCriteriaCourtesy,
                        value: model.courtesy,
                        onChanged: model.setCourtesy,
                      ),
                    ],
                  ),
                ),
              ],
      ),
    );
  }

  Future<void> _next(BuildContext context, ReviewViewModel model) async {
    // Le bouton reste actif : c'est en appuyant qu'on découvre ce qui manque.
    if (model.rating == 0) {
      context.read<InteractionFeedbackService?>()?.emit(FeedbackIntent.error);
      return;
    }
    if (!_commenting) {
      setState(() => _commenting = true);
      return;
    }
    final ok = await model.submit(_comment.text);
    if (!context.mounted) return;
    if (!ok) {
      final state = model.submission;
      toast(
        context,
        failureText(
          context.l10n,
          state is MutationFailure ? state.failure : WkFailure.unknown,
        ),
      );
      return;
    }
    context.read<InteractionFeedbackService?>()?.emit(
      FeedbackIntent.success,
      eventId: 'C05:success:${model.hashCode}',
    );
    // Dit avant de quitter l'écran : sinon l'avis part sans que rien ne
    // confirme qu'il est arrivé.
    toast(context, context.l10n.reviewSent);
    widget.onDone();
  }
}

class _Criterion extends StatelessWidget {
  const _Criterion({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: Insets.xs),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.text.bodyLarge),
        _Stars(value: value, onChanged: onChanged, size: Touch.compact),
      ],
    ),
  );
}

class _Stars extends StatelessWidget {
  const _Stars({
    required this.value,
    required this.onChanged,
    required this.size,
  });
  final int value;
  final ValueChanged<int> onChanged;
  final double size;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: Insets.md,
    runSpacing: Insets.sm,
    children: [
      for (var star = 1; star <= 5; star++)
        FTappable(
          behavior: HitTestBehavior.opaque,
          selected: star <= value,
          semanticsLabel: context.l10n.reviewStarLabel(star),
          onPress: () {
            context.read<InteractionFeedbackService?>()?.emit(
              FeedbackIntent.selection,
            );
            onChanged(star);
          },
          // La police Lucide n'a pas d'étoile pleine : l'étoile choisie porte
          // donc un disque, pas seulement une autre couleur.
          child: Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: star <= value ? context.tones.accent : null,
            ),
            child: Icon(
              FIcons.star,
              size: size * 0.6,
              color: star <= value
                  ? context.colors.onPrimary
                  : context.tones.inkTertiary,
            ),
          ),
        ),
    ],
  );
}
