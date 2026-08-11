import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/core/state/screen_state.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/modules/client/history/history_view_model.dart';
import 'package:woutalma_keur/app/shared/theme/wk_spacing.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_badge.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_button.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_scaffold.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_states.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_top_bar.dart';

/// C04 — Mes contacts.
///
/// La question : « qui ai-je déjà joint ? ». C'est aussi d'ici que part un
/// avis, jamais depuis une fiche : sans contact enregistré, il n'y a rien à
/// noter.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({
    required this.onSearch,
    required this.onReview,
    super.key,
  });

  final VoidCallback onSearch;
  final void Function(ContactEntry entry) onReview;

  @override
  Widget build(BuildContext context) {
    final HistoryViewModel model = context.watch<HistoryViewModel>();

    return WkScaffold(
      extendBody: true,
      topBar: WkTopBar(title: context.l10n.historyTitle),
      body: model.state.map(
        initial: () => const SizedBox.shrink(),
        loading: () => const WkLoadingState(),
        empty: () => WkEmptyState(
          icon: Icons.history,
          title: context.l10n.historyEmptyTitle,
          body: context.l10n.historyEmptyBody,
          actionLabel: context.l10n.historySearch,
          onAction: onSearch,
        ),
        error: (WkFailure failure) =>
            WkErrorState(failure: failure, onRetry: model.load),
        data: (List<ContactEntry> entries) => ListView.separated(
          padding: EdgeInsets.only(
            bottom: WkScaffold.bottomInset(context) + WkSpacing.md,
          ),
          itemCount: entries.length,
          separatorBuilder: (_, _) => const SizedBox(height: WkSpacing.sm),
          itemBuilder: (BuildContext context, int index) => _EntryTile(
            entry: entries[index],
            onReview: () => onReview(entries[index]),
            onOutcome: (ContactOutcome outcome) =>
                model.setOutcome(entries[index].contact, outcome),
          ),
        ),
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({
    required this.entry,
    required this.onReview,
    required this.onOutcome,
  });

  final ContactEntry entry;
  final VoidCallback onReview;
  final void Function(ContactOutcome outcome) onOutcome;

  @override
  Widget build(BuildContext context) {
    final String channel = context.l10n.historyChannelWhen(
      _channelLabel(context, entry.contact.channel),
      DateFormat.yMMMd(context.l10n.localeName).format(entry.contact.createdAt),
    );

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _ChannelAvatar(icon: _channelIcon(entry.contact.channel)),
              const SizedBox(width: WkSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      entry.broker?.name ?? context.l10n.failureNotFound,
                      style: context.text.headlineMedium,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    const SizedBox(height: WkSpacing.xs),
                    Text(
                      channel,
                      style: context.text.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: WkSpacing.md),
          _OutcomeRow(
            label: _outcomeLabel(context, entry.contact.outcome),
            icon: _outcomeIcon(entry.contact.outcome),
            positive: entry.contact.outcome == ContactOutcome.reached,
          ),
          if (entry.alreadyReviewed) ...<Widget>[
            const SizedBox(height: WkSpacing.sm),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: WkBadge(
                label: context.l10n.historyReviewDone,
                icon: Icons.rate_review_outlined,
                tone: WkBadgeTone.positive,
              ),
            ),
          ],
          // Le bouton n'apparaît que si l'avis est réellement ouvert : montrer
          // une action refusée ensuite serait une promesse cassée.
          if (entry.canReview) ...<Widget>[
            const SizedBox(height: WkSpacing.md),
            WkButton(
              label: context.l10n.historyReviewCta,
              icon: Icons.star_outline,
              variant: WkButtonVariant.secondary,
              onPressed: onReview,
            ),
          ]
          // Sans cette question, un contact ouvert restait `attempted` pour
          // toujours : l'avis exige un échange confirmé, et rien à l'écran ne
          // permettait de le confirmer. Le droit de noter était inatteignable
          // hors des données de démonstration.
          else if (entry.contact.outcome ==
              ContactOutcome.attempted) ...<Widget>[
            const SizedBox(height: WkSpacing.md),
            Text(
              context.l10n.historyOutcomeQuestion,
              style: context.text.bodyMedium,
            ),
            const SizedBox(height: WkSpacing.sm),
            WkButton(
              label: context.l10n.outcomeReached,
              onPressed: () => onOutcome(ContactOutcome.reached),
            ),
            const SizedBox(height: WkSpacing.sm),
            WkButton(
              label: context.l10n.outcomeNoAnswer,
              variant: WkButtonVariant.ghost,
              onPressed: () => onOutcome(ContactOutcome.noAnswer),
            ),
          ]
          // Un contact sans bouton doit dire pourquoi : sinon la ligne
          // ressemble à une action qui a disparu.
          else if (entry.contact.outcome == ContactOutcome.noAnswer &&
              !entry.alreadyReviewed) ...<Widget>[
            const SizedBox(height: WkSpacing.sm),
            Text(
              context.l10n.historyNoAnswerNote,
              style: context.text.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _channelLabel(BuildContext context, ContactChannel channel) {
    return switch (channel) {
      ContactChannel.call => context.l10n.historyChannelCall,
      ContactChannel.sms => context.l10n.historyChannelSms,
      ContactChannel.whatsapp => context.l10n.historyChannelWhatsapp,
      ContactChannel.voiceMessage => context.l10n.historyChannelVoice,
    };
  }

  IconData _channelIcon(ContactChannel channel) {
    return switch (channel) {
      ContactChannel.call => Icons.call,
      ContactChannel.sms => Icons.sms_outlined,
      ContactChannel.whatsapp => Icons.chat,
      ContactChannel.voiceMessage => Icons.mic,
    };
  }

  String _outcomeLabel(BuildContext context, ContactOutcome outcome) {
    return switch (outcome) {
      ContactOutcome.reached => context.l10n.brokerActivityOutcomeReached,
      ContactOutcome.attempted => context.l10n.brokerActivityOutcomeAttempted,
      ContactOutcome.noAnswer => context.l10n.brokerActivityOutcomeNoAnswer,
    };
  }

  IconData _outcomeIcon(ContactOutcome outcome) {
    return switch (outcome) {
      ContactOutcome.reached => Icons.check_circle_outline,
      ContactOutcome.attempted => Icons.help_outline,
      ContactOutcome.noAnswer => Icons.phone_missed_outlined,
    };
  }
}

class _OutcomeRow extends StatelessWidget {
  const _OutcomeRow({
    required this.label,
    required this.icon,
    required this.positive,
  });

  final String label;
  final IconData icon;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final Color background = positive
        ? context.colors.statusAvailableContainer
        : context.colors.surfaceVariant;
    final Color foreground = positive
        ? context.colors.statusAvailable
        : context.colors.onSurfaceVariant;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(WkRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: WkSpacing.md,
          vertical: WkSpacing.sm,
        ),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 18, color: foreground),
            const SizedBox(width: WkSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: context.text.bodyMedium?.copyWith(color: foreground),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChannelAvatar extends StatelessWidget {
  const _ChannelAvatar({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.primaryContainer,
        borderRadius: BorderRadius.circular(WkRadius.full),
      ),
      child: SizedBox(
        width: WkTouch.min,
        height: WkTouch.min,
        child: Icon(icon, color: context.colors.onPrimaryContainer),
      ),
    );
  }
}
