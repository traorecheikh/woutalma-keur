import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/core/feedback/interaction_feedback.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/shared/theme/wk_spacing.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_avatar.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_badge.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_button.dart';

/// M04 — feuille de mise en relation. Un canal par ligne ; un canal absent
/// chez le courtier n'apparaît pas.
class ContactSheet extends StatelessWidget {
  const ContactSheet({required this.broker, super.key});

  final Broker broker;

  static Future<ContactChannel?> show(
    BuildContext context, {
    required Broker broker,
  }) {
    return showModalBottomSheet<ContactChannel>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(WkRadius.xxl)),
      ),
      builder: (_) => ContactSheet(broker: broker),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color dim = context.colors.onSurfaceVariant;
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            WkSpacing.page,
            WkSpacing.lg,
            WkSpacing.page,
            WkSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  WkAvatar(
                    name: broker.name,
                    kind: broker.kind,
                    imagePath: broker.logoAsset,
                    size: 56,
                  ),
                  const SizedBox(width: WkSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Semantics(
                          header: true,
                          child: Text(
                            context.l10n.contactSheetTitle,
                            style: context.text.labelMedium?.copyWith(
                              color: dim,
                            ),
                          ),
                        ),
                        Text(
                          broker.name,
                          style: context.text.headlineMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: WkSpacing.xs),
                        Text(
                          context.l10n.brokerResponseRate(
                            (broker.responseRate * 100).round(),
                          ),
                          style: context.text.bodySmall?.copyWith(color: dim),
                        ),
                        const SizedBox(height: WkSpacing.sm),
                        Wrap(
                          spacing: WkSpacing.xs,
                          runSpacing: WkSpacing.xs,
                          children: <Widget>[
                            if (broker.isVerified)
                              WkBadge(
                                label: context.l10n.badgeVerified,
                                icon: Icons.verified_user,
                                tone: WkBadgeTone.positive,
                              ),
                            if (broker.coverage.isNotEmpty)
                              WkBadge(
                                label: broker.coverage.first,
                                icon: Icons.place_outlined,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: WkSpacing.lg),
              _Channel(
                label: context.l10n.contactCall,
                hint: context.l10n.contactCallHint,
                icon: Icons.call,
                color: context.colors.call,
                onColor: context.colors.onCall,
                channel: ContactChannel.call,
              ),
              if (broker.whatsapp != null) ...<Widget>[
                const SizedBox(height: WkSpacing.betweenTargets),
                _Channel(
                  label: context.l10n.contactWhatsapp,
                  hint: context.l10n.contactWhatsappHint,
                  icon: Icons.chat,
                  color: context.colors.whatsapp,
                  onColor: context.colors.onWhatsapp,
                  channel: ContactChannel.whatsapp,
                ),
              ],
              const SizedBox(height: WkSpacing.betweenTargets),
              _Channel(
                label: context.l10n.contactSms,
                hint: context.l10n.contactSmsHint,
                icon: Icons.sms_outlined,
                color: context.colors.primaryContainer,
                onColor: context.colors.onPrimaryContainer,
                channel: ContactChannel.sms,
              ),
              const SizedBox(height: WkSpacing.md),
              Text(
                context.l10n.contactSheetHint,
                style: context.text.bodySmall?.copyWith(color: dim),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Channel extends StatelessWidget {
  const _Channel({
    required this.label,
    required this.hint,
    required this.icon,
    required this.color,
    required this.onColor,
    required this.channel,
  });

  final String label;
  final String hint;
  final IconData icon;
  final Color color;
  final Color onColor;
  final ContactChannel channel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      hint: hint,
      child: Material(
        color: context.colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WkRadius.lg),
          side: BorderSide(color: context.colors.outlineVariant, width: 1.5),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(WkRadius.lg),
          onTap: () {
            context.read<InteractionFeedbackService?>()?.emit(
              FeedbackIntent.selection,
            );
            Navigator.of(context).pop(channel);
          },
          child: Container(
            constraints: const BoxConstraints(minHeight: WkTouch.comfy),
            padding: const EdgeInsets.symmetric(
              horizontal: WkSpacing.md,
              vertical: WkSpacing.sm,
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: onColor, size: 24),
                ),
                const SizedBox(width: WkSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(label, style: context.text.titleMedium),
                      Text(
                        hint,
                        style: context.text.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: context.colors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// M05 — résultat du contact, posé au retour de l'application externe.
class ContactOutcomeSheet extends StatelessWidget {
  const ContactOutcomeSheet({super.key});

  static Future<ContactOutcome?> show(BuildContext context) {
    return showModalBottomSheet<ContactOutcome>(
      context: context,
      useRootNavigator: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(WkRadius.xxl)),
      ),
      builder: (_) => const ContactOutcomeSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(WkSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Semantics(
              header: true,
              child: Text(
                context.l10n.outcomeTitle,
                style: context.text.headlineMedium,
              ),
            ),
            const SizedBox(height: WkSpacing.lg),
            WkButton(
              label: context.l10n.outcomeReached,
              icon: Icons.check_circle_outline,
              onPressed: () =>
                  Navigator.of(context).pop(ContactOutcome.reached),
            ),
            const SizedBox(height: WkSpacing.betweenTargets),
            WkButton(
              label: context.l10n.outcomeNoAnswer,
              variant: WkButtonVariant.secondary,
              onPressed: () =>
                  Navigator.of(context).pop(ContactOutcome.noAnswer),
            ),
            const SizedBox(height: WkSpacing.betweenTargets),
            WkButton(
              label: context.l10n.outcomeLater,
              variant: WkButtonVariant.ghost,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
