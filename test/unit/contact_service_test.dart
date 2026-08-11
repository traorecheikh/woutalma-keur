import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_keur/app/data/repositories/in_memory_repositories.dart';
import 'package:woutalma_keur/app/domain/contact_launcher.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/repositories.dart';
import 'package:woutalma_keur/app/domain/review_eligibility.dart';

/// Enregistre l'ordre des opérations pour prouver que la trace précède
/// l'ouverture du canal.
class _RecordingLauncher implements ContactLauncher {
  _RecordingLauncher(this._contacts, {this.succeeds = true});

  final ContactRepository _contacts;
  final bool succeeds;
  int contactsAtOpen = -1;

  @override
  Future<bool> open(ContactChannel channel, Broker broker) async {
    contactsAtOpen = (await _contacts.all()).length;
    return succeeds;
  }
}

class _HangingLauncher implements ContactLauncher {
  @override
  Future<bool> open(ContactChannel channel, Broker broker) =>
      Completer<bool>().future;
}

class _ThrowingLauncher implements ContactLauncher {
  @override
  Future<bool> open(ContactChannel channel, Broker broker) async =>
      throw StateError('aucune application pour ce canal');
}

void main() {
  late InMemoryStore store;
  late ContactRepository contacts;
  late Broker broker;

  setUp(() async {
    store = InMemoryStore();
    contacts = InMemoryContactRepository(
      store,
      now: () => DateTime.utc(2026, 7, 1, 10),
    );
    broker = const Broker(
      id: 'brk-1',
      kind: BrokerKind.individual,
      name: 'Moussa Ndiaye',
      phone: '+221771234567',
      position: GeoPoint(14.67, -17.44),
      coverage: <String>['Plateau'],
    );
  });

  test('la trace est écrite avant l\'ouverture du canal', () async {
    final _RecordingLauncher launcher = _RecordingLauncher(contacts);
    final ContactService service = ContactService(
      contacts: contacts,
      launcher: launcher,
    );

    await service.contact(broker: broker, channel: ContactChannel.call);

    // Si l'utilisateur ne revient jamais dans l'application, la trace existe
    // quand même — et c'est elle qui autorisera un avis plus tard.
    expect(launcher.contactsAtOpen, 1);
  });

  test('un canal qui ne s\'ouvre pas est signalé, pas avalé', () async {
    final ContactService service = ContactService(
      contacts: contacts,
      launcher: _RecordingLauncher(contacts, succeeds: false),
    );

    final ContactAttempt attempt = await service.contact(
      broker: broker,
      channel: ContactChannel.whatsapp,
    );

    expect(attempt.opened, isFalse);
    // La trace reste : la tentative a bien eu lieu.
    expect((await contacts.all()).length, 1);
  });

  test('un canal qui ne rend jamais la main finit par se résoudre', () async {
    final ContactService service = ContactService(
      contacts: contacts,
      launcher: _HangingLauncher(),
      openTimeout: const Duration(milliseconds: 50),
    );

    final ContactAttempt attempt = await service.contact(
      broker: broker,
      channel: ContactChannel.call,
    );

    // Sans borne, l'indicateur du bouton tournerait sans fin.
    expect(attempt.opened, isFalse);
  });

  test('un lanceur qui lève est traité comme un canal absent', () async {
    final ContactService service = ContactService(
      contacts: contacts,
      launcher: _ThrowingLauncher(),
    );

    final ContactAttempt attempt = await service.contact(
      broker: broker,
      channel: ContactChannel.whatsapp,
    );

    expect(attempt.opened, isFalse);
    expect((await contacts.all()).length, 1);
  });

  test('un contact frais n\'autorise pas encore un avis', () async {
    final ContactService service = ContactService(
      contacts: contacts,
      launcher: _RecordingLauncher(contacts),
    );
    final ReviewEligibilityService eligibility = ReviewEligibilityService(
      contacts,
    );

    final ContactAttempt attempt = await service.contact(
      broker: broker,
      channel: ContactChannel.call,
    );

    expect(attempt.log.allowsReview, isFalse);
    expect(await eligibility.forContact(attempt.log.id), isA<ReviewDenied>());

    // L'avis ne s'ouvre qu'une fois l'échange confirmé par l'utilisateur.
    await contacts.update(
      attempt.log.copyWith(outcome: ContactOutcome.reached),
    );
    expect(await eligibility.forContact(attempt.log.id), isA<ReviewAllowed>());
  });
}
