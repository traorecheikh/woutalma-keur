import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_keur/app/core/state/mutation_state.dart';
import 'package:woutalma_keur/app/core/state/screen_state.dart';
import 'package:woutalma_keur/app/data/repositories/in_memory_repositories.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/repositories.dart';
import 'package:woutalma_keur/app/modules/broker/broker_activity_screen.dart';
import 'package:woutalma_keur/app/modules/broker/broker_home_screen.dart';
import 'package:woutalma_keur/app/modules/broker/broker_profile_editor_screen.dart';
import 'package:woutalma_keur/app/modules/broker/broker_properties_screen.dart';
import 'package:woutalma_keur/app/modules/broker/broker_reviews_screen.dart';
import 'package:woutalma_keur/app/modules/broker/broker_trust_screens.dart';
import 'package:woutalma_keur/app/modules/broker/property_editor_view_model.dart';

/// Le réseau qui tombe : une requête partie, aucune réponse.
DioException _offline() =>
    DioException(requestOptions: RequestOptions(path: '/brokers'));

/// Le serveur qui répond non : ici, la limite de photos.
DioException _rejected() => DioException(
  requestOptions: RequestOptions(path: '/properties'),
  response: Response<dynamic>(
    requestOptions: RequestOptions(path: '/properties'),
    statusCode: 400,
  ),
);

class _BrokenBrokers implements BrokerRepository {
  _BrokenBrokers(this.error);

  final Object error;

  @override
  Future<List<Broker>> all() async => throw error;
  @override
  Future<Broker?> byId(String id) async => throw error;
  @override
  Future<void> save(Broker broker) async => throw error;
  @override
  Future<void> saveAll(List<Broker> brokers) async => throw error;

  @override
  Future<Broker> requestVerification(String brokerId) async => throw error;
}

class _BrokenProperties implements PropertyRepository {
  _BrokenProperties(this.error);

  final Object error;

  @override
  Future<List<Property>> all() async => throw error;
  @override
  Future<List<Property>> discoverable() async => throw error;
  @override
  Future<List<Property>> byBroker(
    String brokerId, {
    bool onlyDiscoverable = false,
  }) async => throw error;
  @override
  Future<Property?> byId(String id) async => throw error;
  @override
  Future<Property> save(Property property) async => throw error;
  @override
  Future<void> delete(String id) async => throw error;
  @override
  Future<void> saveAll(List<Property> properties) async => throw error;
}

class _BrokenReviews implements ReviewRepository {
  _BrokenReviews(this.error);

  final Object error;

  @override
  Future<List<Review>> byBroker(
    String brokerId, {
    bool onlyPublic = true,
  }) async => throw error;
  @override
  Future<List<Review>> all() async => throw error;
  @override
  Future<Review> save(Review review) async => throw error;
  @override
  Future<void> saveAll(List<Review> reviews) async => throw error;

  @override
  Future<Review> reply(String reviewId, String reply) async => throw error;

  @override
  Future<Review> report(String reviewId, {String? reason}) async => throw error;
}

class _BrokenContacts implements ContactRepository {
  _BrokenContacts(this.error);

  final Object error;

  @override
  Future<List<ContactLog>> all() async => throw error;
  @override
  Future<ContactLog?> byId(String id) async => throw error;
  @override
  Future<ContactLog> log({
    required String brokerId,
    String? propertyId,
    required ContactChannel channel,
  }) async => throw error;
  @override
  Future<void> update(ContactLog contact) async => throw error;
  @override
  Future<void> updateAll(List<ContactLog> contacts) async => throw error;

  @override
  Future<List<ContactLog>> receivedBy(String brokerId) async => throw error;
}

/// Un dépôt qui lit bien mais refuse d'écrire.
class _ReadOnlyBrokers implements BrokerRepository {
  _ReadOnlyBrokers(this._inner, this.error);

  final BrokerRepository _inner;
  final Object error;

  @override
  Future<List<Broker>> all() => _inner.all();
  @override
  Future<Broker?> byId(String id) => _inner.byId(id);
  @override
  Future<void> save(Broker broker) async => throw error;
  @override
  Future<void> saveAll(List<Broker> brokers) async => throw error;

  @override
  Future<Broker> requestVerification(String brokerId) async => throw error;
}

/// Un dépôt qui accepte l'écriture mais ne change rien : exactement ce que
/// fait un serveur qui ignore le champ `verification`.
class _IndifferentBrokers implements BrokerRepository {
  _IndifferentBrokers(this._inner);

  final BrokerRepository _inner;

  @override
  Future<List<Broker>> all() => _inner.all();
  @override
  Future<Broker?> byId(String id) => _inner.byId(id);
  @override
  Future<void> save(Broker broker) async {}
  @override
  Future<void> saveAll(List<Broker> brokers) async {}

  /// Accepte, puis rend le profil **inchangé** : le cas d'un serveur qui
  /// répond 200 sans rien écrire. L'écran ne doit pas crier victoire.
  @override
  Future<Broker> requestVerification(String brokerId) async {
    final Broker? current = await _inner.byId(brokerId);
    if (current == null) {
      throw StateError('Courtier $brokerId inconnu');
    }
    return current;
  }
}

void main() {
  late InMemoryStore store;

  setUp(() async {
    store = InMemoryStore();
    await InMemorySeedRepository(store).loadDemoSeed();
  });

  group('aucun écran courtier ne reste sur son indicateur', () {
    test('B01 rend une erreur réseau, jamais un chargement sans fin', () async {
      final BrokerHomeViewModel model = BrokerHomeViewModel(
        brokers: _BrokenBrokers(_offline()),
        properties: _BrokenProperties(_offline()),
        reviews: _BrokenReviews(_offline()),
        contacts: _BrokenContacts(_offline()),
        brokerId: 'brk-moussa',
      );
      addTearDown(model.dispose);

      await model.load();

      expect(model.state, const ScreenError<BrokerActivity>(WkFailure.network));
    });

    test(
      'une réponse du serveur ne se raconte pas comme une coupure',
      () async {
        final BrokerHomeViewModel model = BrokerHomeViewModel(
          brokers: _BrokenBrokers(_rejected()),
          properties: _BrokenProperties(_rejected()),
          reviews: _BrokenReviews(_rejected()),
          contacts: _BrokenContacts(_rejected()),
          brokerId: 'brk-moussa',
        );
        addTearDown(model.dispose);

        await model.load();

        expect(
          model.state,
          const ScreenError<BrokerActivity>(WkFailure.unknown),
        );
      },
    );

    test('B02 rend une erreur', () async {
      final BrokerPropertiesViewModel model = BrokerPropertiesViewModel(
        properties: _BrokenProperties(_offline()),
        brokerId: 'brk-moussa',
      );
      addTearDown(model.dispose);

      await model.load();

      expect(model.state, const ScreenError<List<Property>>(WkFailure.network));
    });

    test('B05 rend une erreur', () async {
      final BrokerActivityViewModel model = BrokerActivityViewModel(
        contacts: _BrokenContacts(_offline()),
        properties: _BrokenProperties(_offline()),
        brokerId: 'brk-moussa',
      );
      addTearDown(model.dispose);

      await model.load();

      expect(
        model.state,
        const ScreenError<List<ReceivedContact>>(WkFailure.network),
      );
    });

    test('B06 rend une erreur', () async {
      final BrokerReviewsViewModel model = BrokerReviewsViewModel(
        reviews: _BrokenReviews(_offline()),
        brokerId: 'brk-moussa',
      );
      addTearDown(model.dispose);

      await model.load();

      expect(model.state, const ScreenError<List<Review>>(WkFailure.network));
    });

    test('B09/B10 rendent une erreur au lieu d\'un profil vide', () async {
      final BrokerTrustViewModel model = BrokerTrustViewModel(
        brokers: _BrokenBrokers(_offline()),
        reviews: _BrokenReviews(_offline()),
        brokerId: 'brk-moussa',
      );
      addTearDown(model.dispose);

      await model.load();

      // Sans état, l'écran affichait « Non vérifié » et quatre barres à 0 %,
      // impossibles à distinguer d'une donnée réelle.
      expect(model.state, const ScreenError<Broker>(WkFailure.network));
      expect(model.broker, isNull);
    });
  });

  group('une écriture refusée ne se célèbre pas', () {
    test('la suppression échouée porte la cause', () async {
      final BrokerPropertiesViewModel model = BrokerPropertiesViewModel(
        properties: _BrokenProperties(_offline()),
        brokerId: 'brk-moussa',
      );
      addTearDown(model.dispose);

      await model.delete('prp-001');

      expect(model.mutation, const MutationFailure(WkFailure.network));
    });

    test('le changement de statut échoué porte la cause', () async {
      final Property property = (await InMemoryPropertyRepository(
        store,
      ).byId('prp-001'))!;
      final BrokerPropertiesViewModel model = BrokerPropertiesViewModel(
        properties: _BrokenProperties(_rejected()),
        brokerId: 'brk-moussa',
      );
      addTearDown(model.dispose);

      await model.changeStatus(property, PropertyStatus.closed);

      expect(model.mutation, const MutationFailure(WkFailure.unknown));
    });

    test('une réponse à un avis qui n\'est pas partie se voit', () async {
      final Review review = (await InMemoryReviewRepository(
        store,
      ).byBroker('brk-moussa', onlyPublic: false)).first;
      final BrokerReviewsViewModel model = BrokerReviewsViewModel(
        reviews: _BrokenReviews(_offline()),
        brokerId: 'brk-moussa',
      );
      addTearDown(model.dispose);

      await model.reply(review, 'Merci !');

      expect(model.mutation, const MutationFailure(WkFailure.network));
    });
  });

  group('demande de vérification', () {
    test('un serveur qui ne change rien n\'est pas un succès', () async {
      final BrokerTrustViewModel model = BrokerTrustViewModel(
        brokers: _IndifferentBrokers(InMemoryBrokerRepository(store)),
        reviews: InMemoryReviewRepository(store),
        brokerId: 'brk-ibrahima',
      );
      addTearDown(model.dispose);
      await model.load();

      await model.submitVerification();

      expect(model.broker!.verification, VerificationStatus.none);
      expect(model.request, isA<MutationFailure>());
    });

    test('une écriture qui passe fait bouger le statut', () async {
      final BrokerTrustViewModel model = BrokerTrustViewModel(
        brokers: InMemoryBrokerRepository(store),
        reviews: InMemoryReviewRepository(store),
        brokerId: 'brk-ibrahima',
      );
      addTearDown(model.dispose);
      await model.load();

      await model.submitVerification();

      expect(model.broker!.verification, VerificationStatus.pending);
      expect(model.request, const MutationSuccess());
    });

    test('le réseau coupé ne prétend rien', () async {
      final BrokerTrustViewModel model = BrokerTrustViewModel(
        brokers: _ReadOnlyBrokers(InMemoryBrokerRepository(store), _offline()),
        reviews: InMemoryReviewRepository(store),
        brokerId: 'brk-ibrahima',
      );
      addTearDown(model.dispose);
      await model.load();

      await model.submitVerification();

      expect(model.request, const MutationFailure(WkFailure.network));
    });
  });

  group('éditeur de bien', () {
    PropertyEditorViewModel editor(PropertyRepository properties) =>
        PropertyEditorViewModel(
          properties: properties,
          brokerId: 'brk-moussa',
          fallbackPosition: const GeoPoint(14.7, -17.4),
          now: () => DateTime.utc(2026, 8, 1),
        );

    test('une saisie refusée laisse la soumission au repos', () async {
      final PropertyEditorViewModel model = editor(
        InMemoryPropertyRepository(store),
      );
      addTearDown(model.dispose);

      final String? id = await model.save(
        title: '',
        priceText: '0',
        neighbourhood: '',
      );

      expect(id, isNull);
      // C'est ce qui distingue « corrigez le formulaire » d'un échec réseau.
      expect(model.submission, const MutationIdle());
    });

    test('un enregistrement refusé porte la cause réelle', () async {
      final PropertyEditorViewModel model = editor(
        _BrokenProperties(_offline()),
      );
      addTearDown(model.dispose);

      final String? id = await model.save(
        title: 'Studio à Yoff',
        priceText: '120000',
        neighbourhood: 'Yoff',
      );

      expect(id, isNull);
      // `localStorage` envoyait chercher la panne dans une base locale qui
      // n'existe plus.
      expect(model.submission, const MutationFailure(WkFailure.network));
    });
  });

  group('éditeur de profil courtier', () {
    test('enregistre nom, téléphone, WhatsApp et zone couverte', () async {
      final BrokerRepository brokers = InMemoryBrokerRepository(store);
      final BrokerProfileEditorViewModel model = BrokerProfileEditorViewModel(
        brokers: brokers,
        brokerId: 'brk-moussa',
      );
      addTearDown(model.dispose);
      await model.load();
      model.setKind(BrokerKind.agency);

      final bool saved = await model.save(
        name: 'Agence Yoff',
        phone: '771112233',
        whatsapp: '',
        coverage: 'Yoff, Ngor,  Yoff ',
      );

      expect(saved, isTrue);
      final Broker updated = (await brokers.byId('brk-moussa'))!;
      expect(updated.name, 'Agence Yoff');
      expect(updated.phone, '+221771112233');
      // Vide veut dire « pas de WhatsApp », pas « numéro vide ».
      expect(updated.whatsapp, isNull);
      expect(updated.coverage, <String>['Yoff', 'Ngor']);
      expect(updated.kind, BrokerKind.agency);
    });

    test('ne touche ni à la vérification ni à la mise en avant', () async {
      final BrokerRepository brokers = InMemoryBrokerRepository(store);
      final Broker before = (await brokers.byId('brk-moussa'))!;
      final BrokerProfileEditorViewModel model = BrokerProfileEditorViewModel(
        brokers: brokers,
        brokerId: 'brk-moussa',
      );
      addTearDown(model.dispose);
      await model.load();

      await model.save(
        name: 'Moussa Diop',
        phone: '771234567',
        whatsapp: '771234567',
        coverage: 'Yoff',
      );

      final Broker after = (await brokers.byId('brk-moussa'))!;
      expect(after.verification, before.verification);
      expect(after.pinned, before.pinned);
      expect(after.responseRate, before.responseRate);
      expect(after.position, before.position);
    });

    test('un numéro incomplet ne part pas', () async {
      final BrokerProfileEditorViewModel model = BrokerProfileEditorViewModel(
        brokers: InMemoryBrokerRepository(store),
        brokerId: 'brk-moussa',
      );
      addTearDown(model.dispose);
      await model.load();

      final bool saved = await model.save(
        name: 'Moussa',
        phone: '7712',
        whatsapp: '',
        coverage: '',
      );

      expect(saved, isFalse);
      expect(model.submission, const MutationIdle());
    });

    test('un enregistrement refusé porte la cause', () async {
      final BrokerProfileEditorViewModel model = BrokerProfileEditorViewModel(
        brokers: _ReadOnlyBrokers(InMemoryBrokerRepository(store), _offline()),
        brokerId: 'brk-moussa',
      );
      addTearDown(model.dispose);
      await model.load();

      final bool saved = await model.save(
        name: 'Moussa',
        phone: '771234567',
        whatsapp: '',
        coverage: 'Yoff',
      );

      expect(saved, isFalse);
      expect(model.submission, const MutationFailure(WkFailure.network));
    });
  });
}
