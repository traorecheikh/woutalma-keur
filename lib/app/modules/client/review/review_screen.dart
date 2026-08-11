import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/core/feedback/interaction_feedback.dart';
import 'package:woutalma_keur/app/core/state/mutation_state.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/repositories.dart';
import 'package:woutalma_keur/app/shared/theme/wk_spacing.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_button.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_scaffold.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_text_field.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_top_bar.dart';

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

    final String id = 'rev-${_contact.id}';
    await _reviews.save(
      Review(
        id: id,
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
    await _contacts.update(_contact.copyWith(reviewId: id));

    _submission = const MutationState.success();
    notifyListeners();
    return true;
  }

  int? _optionalScore(int value) => value == 0 ? null : value;
}

/// C05 — Donner un avis.
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
  final TextEditingController _comment = TextEditingController();

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ReviewViewModel model = context.watch<ReviewViewModel>();

    return WkScaffold(
      topBar: WkTopBar(title: context.l10n.reviewTitle, onBack: widget.onBack),
      bottomAction: WkButton(
        label: context.l10n.reviewSubmit,
        loading: model.submission.isSubmitting,
        // Reste actif : c'est en appuyant qu'on découvre ce qui manque.
        onPressed: () => _submit(context, model),
        disabledReason: model.rating == 0
            ? context.l10n.reviewMissingRating
            : null,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: WkSpacing.lg),
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: context.colors.surface,
                          borderRadius: BorderRadius.circular(WkRadius.full),
                        ),
                        child: Icon(
                          Icons.rate_review_outlined,
                          color: context.colors.primary,
                        ),
                      ),
                      const SizedBox(width: WkSpacing.md),
                      Expanded(
                        child: Text(
                          widget.brokerName,
                          style: context.text.headlineMedium?.copyWith(
                            color: context.colors.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: WkSpacing.md),
                  Text(
                    context.l10n.reviewRatingQuestion,
                    style: context.text.bodyLarge?.copyWith(
                      color: context.colors.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: WkSpacing.sm),
                  WkStarInput(
                    value: model.rating,
                    onChanged: model.setRating,
                    activeColor: context.colors.onPrimaryContainer,
                    inactiveColor: context.colors.onPrimaryContainer.withValues(
                      alpha: 0.45,
                    ),
                  ),
                  if (model.rating == 0)
                    Padding(
                      padding: const EdgeInsets.only(top: WkSpacing.xs),
                      child: Text(
                        context.l10n.reviewMissingRating,
                        style: context.text.bodySmall?.copyWith(
                          color: context.colors.onPrimaryContainer,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: WkSpacing.lg),
          _CriteriaCard(model: model),
          const SizedBox(height: WkSpacing.lg),
          WkTextField(
            label: context.l10n.reviewCommentLabel,
            hint: context.l10n.reviewCommentHint,
            controller: _comment,
          ),
        ],
      ),
    );
  }

  Future<void> _submit(BuildContext context, ReviewViewModel model) async {
    if (!model.canSubmit) {
      // Un formulaire incomplet émet une erreur **une fois**, pas une par
      // champ manquant.
      context.read<InteractionFeedbackService?>()?.emit(FeedbackIntent.error);
      return;
    }
    final bool ok = await model.submit(_comment.text);
    if (ok && context.mounted) {
      context.read<InteractionFeedbackService?>()?.emit(
        FeedbackIntent.success,
        eventId: 'C05:success:${model.hashCode}',
      );
      widget.onDone();
    }
  }
}

class _CriteriaCard extends StatelessWidget {
  const _CriteriaCard({required this.model});

  final ReviewViewModel model;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(WkRadius.xl),
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(WkSpacing.md),
        child: Column(
          children: <Widget>[
            _CriterionRow(
              label: context.l10n.reviewCriteriaResponsiveness,
              value: model.responsiveness,
              onChanged: model.setResponsiveness,
            ),
            const SizedBox(height: WkSpacing.md),
            _CriterionRow(
              label: context.l10n.reviewCriteriaAccuracy,
              value: model.accuracy,
              onChanged: model.setAccuracy,
            ),
            const SizedBox(height: WkSpacing.md),
            _CriterionRow(
              label: context.l10n.reviewCriteriaCourtesy,
              value: model.courtesy,
              onChanged: model.setCourtesy,
            ),
          ],
        ),
      ),
    );
  }
}

class _CriterionRow extends StatelessWidget {
  const _CriterionRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: context.text.labelLarge),
        const SizedBox(height: WkSpacing.xs),
        WkStarInput(value: value, onChanged: onChanged),
      ],
    );
  }
}

/// Cinq grandes cibles. Chaque étoile est un bouton de 56 dp, annoncé par son
/// rang : « 4 étoiles », pas « étoile numéro 4 ».
class WkStarInput extends StatelessWidget {
  const WkStarInput({
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.inactiveColor,
    super.key,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final Color? activeColor;
  final Color? inactiveColor;

  @override
  Widget build(BuildContext context) {
    final Color resolvedActive = activeColor ?? context.colors.primary;
    final Color resolvedInactive =
        inactiveColor ??
        context.colors.onSurfaceVariant.withValues(alpha: 0.55);

    return Wrap(
      spacing: WkSpacing.xs,
      runSpacing: WkSpacing.xs,
      children: <Widget>[
        for (int star = 1; star <= 5; star++)
          Semantics(
            button: true,
            selected: star <= value,
            label: context.l10n.reviewStarLabel(star),
            excludeSemantics: true,
            child: InkResponse(
              onTap: () {
                context.read<InteractionFeedbackService?>()?.emit(
                  FeedbackIntent.selection,
                );
                onChanged(star);
              },
              radius: WkTouch.min / 2,
              child: SizedBox(
                width: WkTouch.min,
                height: WkTouch.min,
                child: Icon(
                  star <= value ? Icons.star : Icons.star_border,
                  size: 34,
                  color: star <= value ? resolvedActive : resolvedInactive,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
