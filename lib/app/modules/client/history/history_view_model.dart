import 'package:flutter/foundation.dart';
import 'package:woutalma_keur/app/core/state/screen_state.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/repositories.dart';
import 'package:woutalma_keur/app/domain/review_eligibility.dart';

/// Une ligne de C04 : le contact, le courtier joint, et ce qu'on peut encore
/// en faire.
@immutable
class ContactEntry {
  const ContactEntry({
    required this.contact,
    required this.broker,
    required this.canReview,
  });

  final ContactLog contact;

  /// Absent si le courtier a disparu de la base. La ligne reste affichée :
  /// effacer l'historique de quelqu'un serait pire que l'afficher incomplet.
  final Broker? broker;

  /// Vrai seulement si l'échange est confirmé et l'avis pas encore donné.
  final bool canReview;

  bool get alreadyReviewed => contact.reviewId != null;
}

/// Coordonne C04.
class HistoryViewModel extends ChangeNotifier {
  HistoryViewModel({
    required ContactRepository contacts,
    required BrokerRepository brokers,
    required ReviewEligibilityService eligibility,
  }) : _contacts = contacts,
       _brokers = brokers,
       _eligibility = eligibility;

  final ContactRepository _contacts;
  final BrokerRepository _brokers;
  final ReviewEligibilityService _eligibility;

  ScreenState<List<ContactEntry>> _state =
      const ScreenState<List<ContactEntry>>.initial();

  ScreenState<List<ContactEntry>> get state => _state;

  Future<void> load() async {
    _state = const ScreenState<List<ContactEntry>>.loading();
    notifyListeners();

    final List<ContactLog> logs = await _contacts.all();
    final List<ContactEntry> entries = <ContactEntry>[];

    for (final ContactLog log in logs) {
      final ReviewPermission permission = await _eligibility.forContact(log.id);
      entries.add(
        ContactEntry(
          contact: log,
          broker: await _brokers.byId(log.brokerId),
          canReview: permission is ReviewAllowed,
        ),
      );
    }
    entries.sort(
      (ContactEntry a, ContactEntry b) =>
          b.contact.createdAt.compareTo(a.contact.createdAt),
    );

    _state = entries.isEmpty
        ? const ScreenState<List<ContactEntry>>.empty()
        : ScreenState<List<ContactEntry>>.data(entries);
    notifyListeners();
  }

  /// Enregistre ce qui s'est passé après une mise en relation.
  ///
  /// C'est ce geste qui ouvre — ou non — le droit de noter.
  Future<void> setOutcome(ContactLog contact, ContactOutcome outcome) async {
    await _contacts.update(contact.copyWith(outcome: outcome));
    await load();
  }
}
