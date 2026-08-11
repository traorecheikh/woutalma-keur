import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/core/state/screen_state.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/repositories.dart';
import 'package:woutalma_keur/app/shared/theme/wk_spacing.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_badge.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_scaffold.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_states.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_top_bar.dart';

/// Une mise en relation reçue, avec le bien concerné s'il y en a un.
@immutable
class ReceivedContact {
  const ReceivedContact({required this.contact, required this.property});

  final ContactLog contact;
  final Property? property;
}

/// Coordonne B05.
class BrokerActivityViewModel extends ChangeNotifier {
  BrokerActivityViewModel({
    required ContactRepository contacts,
    required PropertyRepository properties,
    required String brokerId,
  }) : _contacts = contacts,
       _properties = properties,
       _brokerId = brokerId;

  final ContactRepository _contacts;
  final PropertyRepository _properties;
  final String _brokerId;

  ScreenState<List<ReceivedContact>> _state =
      const ScreenState<List<ReceivedContact>>.initial();

  ScreenState<List<ReceivedContact>> get state => _state;

  Future<void> load() async {
    _state = const ScreenState<List<ReceivedContact>>.loading();
    notifyListeners();

    final List<ContactLog> all = await _contacts.all();
    final List<ReceivedContact> mine = <ReceivedContact>[];

    for (final ContactLog contact in all) {
      if (contact.brokerId != _brokerId) {
        continue;
      }
      mine.add(
        ReceivedContact(
          contact: contact,
          property: contact.propertyId == null
              ? null
              : await _properties.byId(contact.propertyId!),
        ),
      );
    }

    _state = mine.isEmpty
        ? const ScreenState<List<ReceivedContact>>.empty()
        : ScreenState<List<ReceivedContact>>.data(mine);
    notifyListeners();
  }
}

/// B05 — Consultations et contacts.
///
/// Ne montre **aucune donnée personnelle du client** : ni nom, ni numéro. Le
/// courtier voit qu'on l'a joint, par quel canal, à propos de quoi. Le numéro
/// n'apparaît que dans l'application du téléphone, au moment de l'appel.
class BrokerActivityScreen extends StatelessWidget {
  const BrokerActivityScreen({this.onBack, super.key});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final BrokerActivityViewModel model = context
        .watch<BrokerActivityViewModel>();

    return WkScaffold(
      extendBody: true,
      topBar: WkTopBar(title: context.l10n.brokerActivityTitle, onBack: onBack),
      body: model.state.map(
        initial: () => const SizedBox.shrink(),
        loading: () => const WkLoadingState(),
        empty: () => WkEmptyState(
          icon: Icons.phone_in_talk_outlined,
          title: context.l10n.brokerActivityEmptyTitle,
          body: context.l10n.brokerActivityEmptyBody,
        ),
        error: (WkFailure failure) =>
            WkErrorState(failure: failure, onRetry: model.load),
        data: (List<ReceivedContact> received) => ListView.separated(
          padding: EdgeInsets.only(
            bottom: WkScaffold.bottomInset(context) + WkSpacing.md,
          ),
          itemCount: received.length,
          separatorBuilder: (_, _) => const SizedBox(height: WkSpacing.sm),
          itemBuilder: (BuildContext context, int index) =>
              _ContactTile(entry: received[index]),
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({required this.entry});

  final ReceivedContact entry;

  @override
  Widget build(BuildContext context) {
    final String channel = switch (entry.contact.channel) {
      ContactChannel.call => context.l10n.historyChannelCall,
      ContactChannel.sms => context.l10n.historyChannelSms,
      ContactChannel.whatsapp => context.l10n.historyChannelWhatsapp,
      ContactChannel.voiceMessage => context.l10n.historyChannelVoice,
    };
    final IconData channelIcon = switch (entry.contact.channel) {
      ContactChannel.call => Icons.call,
      ContactChannel.sms => Icons.sms_outlined,
      ContactChannel.whatsapp => Icons.chat,
      ContactChannel.voiceMessage => Icons.mic,
    };

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
              _ChannelAvatar(icon: channelIcon),
              const SizedBox(width: WkSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(channel, style: context.text.headlineMedium),
                    if (entry.property != null) ...<Widget>[
                      const SizedBox(height: WkSpacing.xs),
                      Text(
                        context.l10n.brokerActivityAbout(entry.property!.title),
                        style: context.text.bodyMedium?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: WkSpacing.md),
          Wrap(
            spacing: WkSpacing.xs,
            runSpacing: WkSpacing.xs,
            children: <Widget>[
              WkBadge(
                label: switch (entry.contact.outcome) {
                  ContactOutcome.reached =>
                    context.l10n.brokerActivityOutcomeReached,
                  ContactOutcome.attempted =>
                    context.l10n.brokerActivityOutcomeAttempted,
                  ContactOutcome.noAnswer =>
                    context.l10n.brokerActivityOutcomeNoAnswer,
                },
                icon: switch (entry.contact.outcome) {
                  ContactOutcome.reached => Icons.check_circle_outline,
                  ContactOutcome.attempted => Icons.help_outline,
                  ContactOutcome.noAnswer => Icons.phone_missed_outlined,
                },
                tone: switch (entry.contact.outcome) {
                  ContactOutcome.reached => WkBadgeTone.positive,
                  ContactOutcome.attempted => WkBadgeTone.neutral,
                  ContactOutcome.noAnswer => WkBadgeTone.neutral,
                },
              ),
            ],
          ),
        ],
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
