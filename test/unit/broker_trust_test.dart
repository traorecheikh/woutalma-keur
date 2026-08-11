import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_keur/app/data/repositories/in_memory_repositories.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/repositories.dart';
import 'package:woutalma_keur/app/modules/broker/broker_activity_screen.dart';
import 'package:woutalma_keur/app/modules/broker/broker_trust_screens.dart';

void main() {
  late InMemoryStore store;
  late BrokerRepository brokers;
  late ReviewRepository reviews;
  late ContactRepository contacts;
  late PropertyRepository properties;

  setUp(() async {
    store = InMemoryStore();
    brokers = InMemoryBrokerRepository(store);
    reviews = InMemoryReviewRepository(store);
    properties = InMemoryPropertyRepository(store);
    contacts = InMemoryContactRepository(
      store,
      now: () => DateTime.utc(2026, 8, 1),
    );
    await InMemorySeedRepository(store).loadDemoSeed();
  });

  group('activité reçue', () {
    test('ne montre que les contacts du courtier concerné', () async {
      final BrokerActivityViewModel model = BrokerActivityViewModel(
        contacts: contacts,
        properties: properties,
        brokerId: 'brk-moussa',
      );

      await model.load();

      final List<ReceivedContact> mine = model.state.valueOrNull!;
      expect(mine, isNotEmpty);
      expect(
        mine.every((ReceivedContact c) => c.contact.brokerId == 'brk-moussa'),
        isTrue,
      );
    });

    test('rattache le bien concerné quand il y en a un', () async {
      final BrokerActivityViewModel model = BrokerActivityViewModel(
        contacts: contacts,
        properties: properties,
        brokerId: 'brk-moussa',
      );

      await model.load();

      final ReceivedContact entry = model.state.valueOrNull!.first;
      expect(entry.property?.id, 'prp-001');
    });

    test('un courtier jamais contacté obtient un état vide', () async {
      final BrokerActivityViewModel model = BrokerActivityViewModel(
        contacts: contacts,
        properties: properties,
        brokerId: 'brk-awa',
      );

      await model.load();

      expect(model.state.isResolved, isTrue);
      expect(model.state.valueOrNull, isNull);
    });
  });

  group('vérification', () {
    test('demander la vérification met le profil en attente', () async {
      final BrokerTrustViewModel model = BrokerTrustViewModel(
        brokers: brokers,
        reviews: reviews,
        brokerId: 'brk-ibrahima',
      );
      await model.load();
      expect(model.broker!.verification, VerificationStatus.none);

      await model.submitVerification();

      expect(model.broker!.verification, VerificationStatus.pending);
      // Le profil n'est pas vérifié pour autant : la décision reste au
      // modérateur, hors application.
      expect(model.broker!.isVerified, isFalse);
    });

    test('redemander pendant l\'examen ne change rien', () async {
      final BrokerTrustViewModel model = BrokerTrustViewModel(
        brokers: brokers,
        reviews: reviews,
        brokerId: 'brk-awa',
      );
      await model.load();
      expect(model.broker!.verification, VerificationStatus.pending);

      await model.submitVerification();

      expect(model.broker!.verification, VerificationStatus.pending);
    });

    test('la demande ne touche à rien d\'autre du profil', () async {
      final BrokerTrustViewModel model = BrokerTrustViewModel(
        brokers: brokers,
        reviews: reviews,
        brokerId: 'brk-ibrahima',
      );
      await model.load();
      final Broker before = model.broker!;

      await model.submitVerification();

      final Broker after = model.broker!;
      expect(after.name, before.name);
      expect(after.phone, before.phone);
      expect(after.responseRate, before.responseRate);
      expect(after.coverage, before.coverage);
    });
  });

  group('classement expliqué', () {
    test('les contributions somment à cent', () async {
      final BrokerTrustViewModel model = BrokerTrustViewModel(
        brokers: brokers,
        reviews: reviews,
        brokerId: 'brk-moussa',
      );
      await model.load();

      final Map<String, int> parts = model.contributions();

      expect(parts.keys, containsAll(<String>['rating', 'proximity']));
      final int total = parts.values.reduce((int a, int b) => a + b);
      // Arrondis compris : on ne prétend pas à la précision au point près.
      expect(total, inInclusiveRange(99, 101));
    });

    test('un profil sans avis a une contribution de volume nulle', () async {
      final BrokerTrustViewModel model = BrokerTrustViewModel(
        brokers: brokers,
        reviews: reviews,
        brokerId: 'brk-keur-massar',
      );
      await model.load();

      expect(model.reviewCount, 0);
      expect(model.contributions()['volume'], 0);
    });

    test('la note pèse plus que le taux de réponse', () async {
      final BrokerTrustViewModel model = BrokerTrustViewModel(
        brokers: brokers,
        reviews: reviews,
        brokerId: 'brk-moussa',
      );
      await model.load();

      final Map<String, int> parts = model.contributions();
      expect(parts['rating']!, greaterThan(parts['response']!));
    });
  });
}
