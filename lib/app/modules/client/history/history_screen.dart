import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/modules/client/broker/contact_sheet.dart';
import 'package:woutalma_keur/app/modules/client/history/history_view_model.dart';
import 'package:woutalma_keur/app/ui/ui.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({
    required this.onSearch,
    required this.onReview,
    required this.onCallAgain,
    required this.onSignIn,
    super.key,
  });
  final VoidCallback onSearch;
  final void Function(ContactEntry entry) onReview;
  final void Function(ContactEntry entry) onCallAgain;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<HistoryViewModel>();
    final l = context.l10n;
    return AppScaffold(
      title: l.historyTitle,
      showBack: false,
      onRefresh: model.load,
      body: model.state.map(
        initial: () => const SizedBox.shrink(),
        loading: () => const AppSkeleton(rows: 4, height: 120),
        empty: () => AppState(
          kind: AppStateKind.empty,
          icon: FIcons.history,
          title: l.historyEmptyTitle,
          message: l.historyEmptyBody,
          actionLabel: l.historySearch,
          onAction: onSearch,
        ),
        error: (f) => model.signedOut
            ? AppState(
                kind: AppStateKind.permission,
                icon: FIcons.history,
                title: l.historySignedOutTitle,
                message: l.historyEmptyBody,
                actionLabel: l.historySignedOutAction,
                onAction: onSignIn,
              )
            : failureState(context, f, onRetry: model.load),
        data: (entries) => _Groups(
          entries: entries,
          onReview: onReview,
          onCallAgain: onCallAgain,
          onOutcome: model.setOutcome,
        ),
      ),
    );
  }
}

class _Groups extends StatelessWidget {
  const _Groups({
    required this.entries,
    required this.onReview,
    required this.onCallAgain,
    required this.onOutcome,
  });
  final List<ContactEntry> entries;
  final void Function(ContactEntry entry) onReview;
  final void Function(ContactEntry entry) onCallAgain;
  final void Function(ContactLog contact, ContactOutcome outcome) onOutcome;

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<ContactEntry>>{};
    for (final e in entries) {
      (groups[e.contact.brokerId] ??= <ContactEntry>[]).add(e);
    }
    final keys = groups.keys.toList();
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(Insets.page, 0, Insets.page, 120),
      itemCount: keys.length,
      separatorBuilder: (_, _) => const SizedBox(height: Insets.md),
      itemBuilder: (_, i) => _BrokerGroup(
        entries: groups[keys[i]]!,
        onReview: onReview,
        onCallAgain: onCallAgain,
        onOutcome: onOutcome,
      ),
    );
  }
}

class _BrokerGroup extends StatelessWidget {
  const _BrokerGroup({
    required this.entries,
    required this.onReview,
    required this.onCallAgain,
    required this.onOutcome,
  });
  final List<ContactEntry> entries;
  final void Function(ContactEntry entry) onReview;
  final void Function(ContactEntry entry) onCallAgain;
  final void Function(ContactLog contact, ContactOutcome outcome) onOutcome;

  @override
  Widget build(BuildContext context) {
    final broker = entries.first.broker;
    final name = broker?.name ?? context.l10n.failureNotFound;
    return AppCard(
      padding: const EdgeInsets.all(Insets.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              AppAvatar(name: name, imagePath: broker?.logoAsset),
              const SizedBox(width: Insets.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: context.text.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (broker != null)
                      BrokerPhone(
                        broker.phone,
                        copiable: true,
                        style: AppText.moneyMd,
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (broker != null) ...[
            const SizedBox(height: Insets.md),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: AppButton(
                context.l10n.historyCallAgain,
                icon: FIcons.phone,
                variant: AppButtonVariant.secondary,
                size: 44,
                onPressed: () => onCallAgain(entries.first),
              ),
            ),
          ],
          for (final entry in entries) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: Insets.md),
              child: AppDivider(inset: false),
            ),
            _Entry(
              entry: entry,
              onReview: () => onReview(entry),
              onOutcome: (o) => onOutcome(entry.contact, o),
            ),
          ],
        ],
      ),
    );
  }
}

class _Entry extends StatelessWidget {
  const _Entry({
    required this.entry,
    required this.onReview,
    required this.onOutcome,
  });
  final ContactEntry entry;
  final VoidCallback onReview;
  final void Function(ContactOutcome outcome) onOutcome;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final contact = entry.contact;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.tones.sunken,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _channelIcon(contact.channel),
                size: 20,
                color: context.colors.onSurface,
              ),
            ),
            const SizedBox(width: Insets.md),
            Expanded(
              child: Text(
                l.historyChannelWhen(
                  _channelLabel(context, contact.channel),
                  DateFormat.yMMMd(l.localeName).format(contact.createdAt),
                ),
                style: context.text.bodyMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: Insets.md),
        Wrap(
          spacing: Insets.sm,
          runSpacing: Insets.sm,
          children: [
            AppTag(
              _outcomeLabel(context, contact.outcome),
              tone: switch (contact.outcome) {
                ContactOutcome.reached => AppTone.success,
                ContactOutcome.noAnswer => AppTone.warning,
                ContactOutcome.attempted => AppTone.neutral,
              },
              icon: _outcomeIcon(contact.outcome),
            ),
            if (entry.alreadyReviewed)
              AppTag(
                l.historyReviewDone,
                tone: AppTone.accent,
                icon: FIcons.star,
              ),
          ],
        ),
        if (entry.canReview) ...[
          const SizedBox(height: Insets.sm),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: AppButton(
              l.historyReviewCta,
              icon: FIcons.star,
              variant: AppButtonVariant.ghost,
              size: 40,
              onPressed: onReview,
            ),
          ),
        ] else if (contact.outcome == ContactOutcome.attempted) ...[
          const SizedBox(height: Insets.md),
          Text(l.historyOutcomeQuestion, style: context.text.bodyMedium),
          const SizedBox(height: Insets.sm),
          AppButton(
            l.outcomeReached,
            size: 44,
            onPressed: () => onOutcome(ContactOutcome.reached),
          ),
          const SizedBox(height: Insets.sm),
          AppButton(
            l.outcomeNoAnswer,
            size: 44,
            variant: AppButtonVariant.secondary,
            onPressed: () => onOutcome(ContactOutcome.noAnswer),
          ),
        ] else if (contact.outcome == ContactOutcome.noAnswer &&
            !entry.alreadyReviewed) ...[
          const SizedBox(height: Insets.sm),
          Text(
            l.historyNoAnswerNote,
            style: context.text.bodySmall!.copyWith(
              color: context.tones.inkSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

IconData _channelIcon(ContactChannel channel) => switch (channel) {
  ContactChannel.call => FIcons.phone,
  ContactChannel.sms => FIcons.messageSquare,
  ContactChannel.whatsapp => FIcons.messageCircle,
  ContactChannel.voiceMessage => FIcons.mic,
};

String _channelLabel(BuildContext context, ContactChannel channel) =>
    switch (channel) {
      ContactChannel.call => context.l10n.historyChannelCall,
      ContactChannel.sms => context.l10n.historyChannelSms,
      ContactChannel.whatsapp => context.l10n.historyChannelWhatsapp,
      ContactChannel.voiceMessage => context.l10n.historyChannelVoice,
    };

IconData _outcomeIcon(ContactOutcome outcome) => switch (outcome) {
  ContactOutcome.reached => FIcons.circleCheck,
  ContactOutcome.attempted => FIcons.circleQuestionMark,
  ContactOutcome.noAnswer => FIcons.phoneMissed,
};

String _outcomeLabel(BuildContext context, ContactOutcome outcome) =>
    switch (outcome) {
      ContactOutcome.reached => context.l10n.brokerActivityOutcomeReached,
      ContactOutcome.attempted => context.l10n.brokerActivityOutcomeAttempted,
      ContactOutcome.noAnswer => context.l10n.brokerActivityOutcomeNoAnswer,
    };
