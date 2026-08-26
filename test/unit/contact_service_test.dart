import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_keur/app/data/repositories/in_memory_repositories.dart';
import 'package:woutalma_keur/app/domain/contact_launcher.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/repositories.dart';
import 'package:woutalma_keur/app/domain/review_eligibility.dart';

/// Enregistre l'ordre des opérations pour prouver que le canal s'ouvre avant
/// toute écriture.
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

/// Ce que fait un dépôt distant quand personne n'est identifié, ou quand le
/// réseau manque.
class _FailingContacts implements ContactRepository {
  _FailingContacts(this._inner);

  final ContactRepository _inner;
  int logAttempts = 0;

  @override
  Future<ContactLog> log({
    required String brokerId,
    String? propertyId,
    required ContactChannel channel,
  }) async {
    logAttempts++;
    throw DioException(
      requestOptions: RequestOptions(path: '/contacts'),
      response: Response<void>(
        requestOptions: RequestOptions(path: '/contacts'),
        statusCode: 401,
      ),
    );
  }

  @override
  Future<List<ContactLog>> all() => _inner.all();
  @override
  Future<ContactLog?> byId(String id) => _inner.byId(id);
  @override
  Future<List<ContactLog>> receivedBy(String brokerId) =>
      _inner.receivedBy(brokerId);
  @override
  Future<void> update(ContactLog contact) => _inner.update(contact);
  @override
  Future<void> updateAll(List<ContactLog> contacts) =>
      _inner.updateAll(contacts);
  @override
  Future<void> remove(String id) => _inner.remove(id);
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

  test('le canal s\'ouvre avant que la trace ne parte', () async {
    final _RecordingLauncher launcher = _RecordingLauncher(contacts);
    final ContactService service = ContactService(
      contacts: contacts,
      launcher: launcher,
    );

    final ContactAttempt attempt = await service.contact(
      broker: broker,
      channel: ContactChannel.call,
    );

    // Le journal exige le réseau et une session : le faire précéder l'appel
    // privait de téléphone qui n'a ni l'un ni l'autre.
    expect(launcher.contactsAtOpen, 0);
    expect(attempt.opened, isTrue);
    expect((await contacts.all()).length, 1);
  });

  test('un journal qui refuse n\'empêche pas l\'appel', () async {
    final _FailingContacts failing = _FailingContacts(contacts);
    final ContactService service = ContactService(
      contacts: failing,
      launcher: _RecordingLauncher(contacts),
    );

    final ContactAttempt attempt = await service.contact(
      broker: broker,
      channel: ContactChannel.call,
    );

    expect(failing.logAttempts, 1);
    expect(attempt.opened, isTrue);
    expect(attempt.log, isNull);
  });

  test('un canal qui ne s\'ouvre pas ne laisse pas de trace', () async {
    final ContactService service = ContactService(
      contacts: contacts,
      launcher: _RecordingLauncher(contacts, succeeds: false),
    );

    final ContactAttempt attempt = await service.contact(
      broker: broker,
      channel: ContactChannel.whatsapp,
    );

    expect(attempt.opened, isFalse);
    // Rien ne s'est ouvert : personne n'a été contacté, l'historique ne doit
    // pas prétendre le contraire.
    expect((await contacts.all()), isEmpty);
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
    expect(await contacts.all(), isEmpty);
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
    final ContactLog log = attempt.log!;

    expect(log.allowsReview, isFalse);
    expect(await eligibility.forContact(log.id), isA<ReviewDenied>());

    // L'avis ne s'ouvre qu'une fois l'échange confirmé par l'utilisateur.
    await service.recordOutcome(log, ContactOutcome.reached);
    expect(await eligibility.forContact(log.id), isA<ReviewAllowed>());
  });
}
