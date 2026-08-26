import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/core/feedback/interaction_feedback.dart';
import 'package:woutalma_keur/app/domain/auth_service.dart';
import 'package:woutalma_keur/app/domain/contact_launcher.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/l10n/generated/app_l10n.dart';
import 'package:woutalma_keur/app/ui/ui.dart';

/// Numéro sénégalais lisible : « +221 77 123 45 67 ».
String formatPhone(String raw) {
  final String digits = raw.replaceAll(' ', '');
  if (!digits.startsWith('+221') || digits.length != 13) {
    return raw;
  }
  final String n = digits.substring(4);
  return '+221 ${n.substring(0, 2)} ${n.substring(2, 5)} '
      '${n.substring(5, 7)} ${n.substring(7)}';
}

/// Le numéro, lisible et copiable.
///
/// Il était absent de la fiche : qui n'a pas de crédit data, ou veut appeler
/// depuis un autre téléphone, n'avait aucun moyen de le lire.
class BrokerPhone extends StatelessWidget {
  const BrokerPhone(this.phone, {super.key, this.style, this.copiable = false});

  final String phone;
  final TextStyle? style;
  final bool copiable;

  @override
  Widget build(BuildContext context) {
    final String shown = formatPhone(phone);
    final Widget text = Text(
      shown,
      style: style ?? AppText.moneyLg,
      textAlign: TextAlign.center,
    );
    if (!copiable) {
      return text;
    }
    return FTappable(
      semanticsLabel: '$shown, ${context.l10n.contactPhoneCopyHint}',
      excludeSemantics: true,
      behavior: HitTestBehavior.opaque,
      onLongPress: () async {
        await Clipboard.setData(ClipboardData(text: phone));
        if (!context.mounted) return;
        context.read<InteractionFeedbackService?>()?.emit(
          FeedbackIntent.selection,
        );
        toast(context, context.l10n.contactPhoneCopied);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Insets.xs),
        child: text,
      ),
    );
  }
}

/// Ce que l'écran doit dire quand un canal ne s'ouvre pas.
///
/// Jamais le message générique de permission : l'utilisateur doit savoir quoi
/// faire à la place.
String channelFailureText(AppL10n l, ContactChannel channel) =>
    switch (channel) {
      ContactChannel.whatsapp => l.contactWhatsappMissing,
      ContactChannel.sms => l.contactSmsMissing,
      ContactChannel.call ||
      ContactChannel.voiceMessage => l.contactCallMissing,
    };

enum ContactGateChoice { signIn, callAnyway }

/// Demandée avant de contacter quand personne n'est identifié.
///
/// L'appel reste possible sans compte : le produit promet un courtier joignable
/// en trois écrans, pas une inscription.
abstract final class ContactGateSheet {
  static Future<ContactGateChoice?> show(
    BuildContext context, {
    required Broker broker,
  }) {
    final l = context.l10n;
    return showAppSheet<ContactGateChoice>(
      context,
      title: l.contactGateTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.contactGateBody,
            style: context.text.bodyMedium!.copyWith(
              color: context.tones.inkSecondary,
            ),
          ),
          const SizedBox(height: Insets.md),
          BrokerPhone(broker.phone),
          const SizedBox(height: Insets.lg),
          AppButton(
            l.contactGateSignIn,
            icon: FIcons.smartphone,
            onPressed: () => popSheet(context, ContactGateChoice.signIn),
          ),
          const SizedBox(height: Insets.sm),
          AppButton(
            l.contactGateCallAnyway,
            icon: FIcons.phone,
            variant: AppButtonVariant.secondary,
            onPressed: () => popSheet(context, ContactGateChoice.callAnyway),
          ),
        ],
      ),
    );
  }
}

/// Le parcours complet de mise en relation, partagé par C02 et C03.
Future<void> runContactFlow(
  BuildContext context, {
  required Broker broker,
  required Future<ContactAttempt> Function(ContactChannel channel) contact,
  required Future<bool> Function() callWithoutAccount,
  required VoidCallback onSignIn,
}) async {
  final l = context.l10n;
  final AuthService? auth = context.read<AuthService?>();
  if (auth != null && auth.current == null) {
    final ContactGateChoice? choice = await ContactGateSheet.show(
      context,
      broker: broker,
    );
    if (choice == null || !context.mounted) {
      return;
    }
    if (choice == ContactGateChoice.signIn) {
      onSignIn();
      return;
    }
    final bool called = await callWithoutAccount();
    if (!context.mounted) return;
    if (!called) {
      toast(context, channelFailureText(l, ContactChannel.call));
    }
    return;
  }

  final ContactChannel? channel = await ContactSheet.show(
    context,
    broker: broker,
  );
  if (channel == null || !context.mounted) {
    return;
  }
  final ContactAttempt attempt = await contact(channel);
  if (!context.mounted) return;
  toast(
    context,
    !attempt.opened
        ? channelFailureText(l, channel)
        : attempt.log != null
        ? l.contactLogged
        : l.contactNotLogged,
  );
}

/// Pose M05 au retour de l'application externe.
///
/// La feuille n'était jamais montrée : le résultat restait « tentative », donc
/// aucun avis ne s'ouvrait jamais. Un seul passage par contact, `take` vidant
/// l'attente.
class ContactOutcomeOnResume extends StatefulWidget {
  const ContactOutcomeOnResume({
    required this.take,
    required this.onOutcome,
    required this.child,
    super.key,
  });

  final ContactLog? Function() take;
  final Future<void> Function(ContactLog log, ContactOutcome outcome) onOutcome;
  final Widget child;

  @override
  State<ContactOutcomeOnResume> createState() => _ContactOutcomeOnResumeState();
}

class _ContactOutcomeOnResumeState extends State<ContactOutcomeOnResume> {
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(onResume: _ask);
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  Future<void> _ask() async {
    final ContactLog? log = widget.take();
    if (log == null || !mounted) {
      return;
    }
    final ContactOutcome? outcome = await ContactOutcomeSheet.show(context);
    if (outcome == null) {
      return;
    }
    await widget.onOutcome(log, outcome);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

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
                  BrokerPhone(
                    broker.phone,
                    style: AppText.moneyMd,
                    copiable: true,
                  ),
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
