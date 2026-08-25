import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/core/state/screen_state.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/repositories.dart';
import 'package:woutalma_keur/app/l10n/generated/app_l10n.dart';
import 'package:woutalma_keur/app/modules/broker/broker_failures.dart';
import 'package:woutalma_keur/app/ui/ui.dart';

const _pad = EdgeInsets.symmetric(horizontal: Insets.page);

@immutable
class ReceivedContact {
  const ReceivedContact({required this.contact, required this.property});

  final ContactLog contact;
  final Property? property;
}

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

    try {
      final List<ContactLog> received = await _contacts.receivedBy(_brokerId);
      final List<ReceivedContact> mine = <ReceivedContact>[];

      for (final ContactLog contact in received) {
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
    } on Object catch (error) {
      _state = ScreenState<List<ReceivedContact>>.error(brokerFailure(error));
    }
    notifyListeners();
  }
}

class BrokerActivityScreen extends StatelessWidget {
  const BrokerActivityScreen({this.onBack, super.key});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<BrokerActivityViewModel>();
    final l = context.l10n;
    return AppScaffold(
      title: l.brokerActivityTitle,
      onBack: onBack,
      showBack: onBack != null,
      onRefresh: model.load,
      body: model.state.map(
        initial: () => const AppSkeleton(),
        loading: () => const AppSkeleton(),
        empty: () => AppState(
          kind: AppStateKind.empty,
          icon: FIcons.phoneIncoming,
          title: l.brokerActivityEmptyTitle,
          message: l.brokerActivityEmptyBody,
        ),
        error: (failure) => failureState(context, failure, onRetry: model.load),
        data: (received) => _Days(received: received),
      ),
    );
  }
}

class _Days extends StatelessWidget {
  const _Days({required this.received});

  final List<ReceivedContact> received;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final day = DateFormat('EEEE d MMMM', 'fr');
    final groups = <String, List<ReceivedContact>>{};
    for (final entry in received) {
      groups
          .putIfAbsent(
            toBeginningOfSentenceCase(day.format(entry.contact.createdAt)),
            () => <ReceivedContact>[],
          )
          .add(entry);
    }
    return ListView(
      padding: const EdgeInsets.only(bottom: Insets.xxl),
      children: [
        for (final group in groups.entries) ...[
          AppSection(group.key),
          Padding(
            padding: _pad,
            child: AppCard.rows([
              for (final entry in group.value)
                AppRow(
                  title: entry.property?.title ?? _channelLabel(l, entry),
                  subtitle: l.historyChannelWhen(
                    _channelLabel(l, entry),
                    DateFormat.Hm('fr').format(entry.contact.createdAt),
                  ),
                  leading: Icon(switch (entry.contact.channel) {
                    ContactChannel.call => FIcons.phoneIncoming,
                    ContactChannel.sms => FIcons.messageSquare,
                    ContactChannel.whatsapp => FIcons.messageCircle,
                    ContactChannel.voiceMessage => FIcons.mic,
                  }),
                  trailing: switch (entry.contact.outcome) {
                    ContactOutcome.reached => AppTag(
                      l.brokerActivityOutcomeReached,
                      tone: AppTone.success,
                      icon: FIcons.circleCheck,
                    ),
                    ContactOutcome.attempted => AppTag(
                      l.brokerActivityOutcomeAttempted,
                      icon: FIcons.clock,
                    ),
                    ContactOutcome.noAnswer => AppTag(
                      l.brokerActivityOutcomeNoAnswer,
                      tone: AppTone.warning,
                      icon: FIcons.phoneMissed,
                    ),
                  },
                ),
            ]),
          ),
        ],
      ],
    );
  }
}

String _channelLabel(AppL10n l, ReceivedContact entry) =>
    switch (entry.contact.channel) {
      ContactChannel.call => l.historyChannelCall,
      ContactChannel.sms => l.historyChannelSms,
      ContactChannel.whatsapp => l.historyChannelWhatsapp,
      ContactChannel.voiceMessage => l.historyChannelVoice,
    };
