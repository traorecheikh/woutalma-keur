import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/core/feedback/interaction_feedback.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/ui/ui.dart';

abstract final class ContactSheet {
  static Future<ContactChannel?> show(
    BuildContext context, {
    required Broker broker,
  }) => showAppSheet<ContactChannel>(
    context,
    title: context.l10n.contactSheetTitle,
    scrollable: true,
    child: _Channels(broker: broker),
  );
}

class _Channels extends StatelessWidget {
  const _Channels({required this.broker});
  final Broker broker;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = context.tones;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            AppAvatar(name: broker.name, size: 56, imagePath: broker.logoAsset),
            const SizedBox(width: Insets.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    broker.name,
                    style: context.text.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l.brokerResponseRate((broker.responseRate * 100).round()),
                    style: context.text.bodySmall!.copyWith(
                      color: t.inkSecondary,
                    ),
                  ),
                  if (broker.isVerified || broker.coverage.isNotEmpty) ...[
                    const SizedBox(height: Insets.sm),
                    Wrap(
                      spacing: Insets.xs,
                      runSpacing: Insets.xs,
                      children: [
                        if (broker.isVerified)
                          AppTag(
                            l.badgeVerified,
                            tone: AppTone.success,
                            icon: FIcons.badgeCheck,
                          ),
                        if (broker.coverage.isNotEmpty)
                          AppTag(broker.coverage.first, icon: FIcons.mapPin),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: Insets.xl),
        _Channel(
          label: l.contactCall,
          hint: l.contactCallHint,
          icon: FIcons.phone,
          color: t.success,
          channel: ContactChannel.call,
        ),
        if (broker.whatsapp != null) ...[
          const SizedBox(height: Insets.md),
          _Channel(
            label: l.contactWhatsapp,
            hint: l.contactWhatsappHint,
            icon: FIcons.messageCircle,
            color: t.whatsapp,
            channel: ContactChannel.whatsapp,
          ),
        ],
        const SizedBox(height: Insets.md),
        _Channel(
          label: l.contactSms,
          hint: l.contactSmsHint,
          icon: FIcons.messageSquare,
          color: t.sunken,
          onColor: context.colors.onSurface,
          channel: ContactChannel.sms,
        ),
        const SizedBox(height: Insets.lg),
        Text(
          l.contactSheetHint,
          style: context.text.bodySmall!.copyWith(color: t.inkSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _Channel extends StatelessWidget {
  const _Channel({
    required this.label,
    required this.hint,
    required this.icon,
    required this.color,
    required this.channel,
    this.onColor,
  });
  final String label, hint;
  final IconData icon;
  final Color color;
  final Color? onColor;
  final ContactChannel channel;

  @override
  Widget build(BuildContext context) => FTappable(
    semanticsLabel: '$label, $hint',
    excludeSemantics: true,
    behavior: HitTestBehavior.opaque,
    onPress: () {
      context.read<InteractionFeedbackService?>()?.emit(
        FeedbackIntent.selection,
      );
      popSheet(context, channel);
    },
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: Radii.container,
        border: Border.all(color: context.tones.hairline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Insets.md),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(
                icon,
                size: 24,
                color: onColor ?? context.colors.onPrimary,
              ),
            ),
            const SizedBox(width: Insets.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: context.text.titleMedium),
                  Text(
                    hint,
                    style: context.text.bodySmall!.copyWith(
                      color: context.tones.inkSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(FIcons.chevronRight, color: context.tones.inkSecondary),
          ],
        ),
      ),
    ),
  );
}

abstract final class ContactOutcomeSheet {
  static Future<ContactOutcome?> show(BuildContext context) {
    final l = context.l10n;
    return showAppSheet<ContactOutcome>(
      context,
      title: l.outcomeTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppButton(
            l.outcomeReached,
            icon: FIcons.circleCheck,
            onPressed: () => popSheet(context, ContactOutcome.reached),
          ),
          const SizedBox(height: Insets.sm),
          AppButton(
            l.outcomeNoAnswer,
            variant: AppButtonVariant.secondary,
            onPressed: () => popSheet(context, ContactOutcome.noAnswer),
          ),
          const SizedBox(height: Insets.sm),
          AppButton(
            l.outcomeLater,
            variant: AppButtonVariant.ghost,
            onPressed: () => popSheet<ContactOutcome>(context),
          ),
        ],
      ),
    );
  }
}
