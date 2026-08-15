import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:woutalma_keur/app/core/state/mutation_state.dart';
import 'package:woutalma_keur/app/core/state/screen_state.dart';
import 'package:woutalma_keur/app/domain/contact_launcher.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/ranking.dart';
import 'package:woutalma_keur/app/domain/repositories.dart';

/// Tout ce que C02 affiche, résolu en une fois.
@immutable
class BrokerDetail {
  const BrokerDetail({
    required this.broker,
    required this.from,
    required this.distanceMeters,
    required this.properties,
    required this.reviews,
    required this.averageRating,
  });

  final Broker broker;

  /// Point depuis lequel on mesure.
  ///
  /// Le seed pose les biens d'un courtier autour de son bureau, si bien qu'une
  /// distance unique passait pour juste. Un bien réel est publié là où il est :
  /// une agence de Sacré-Cœur qui vend un terrain à Mermoz annonçait la
  /// distance de son bureau sur la carte du terrain.
  final GeoPoint from;
  final double distanceMeters;

  /// Seulement ce qui est encore proposé : un bien clos n'apparaît pas dans
  /// la fiche publique.
  final List<Property> properties;

  /// Seulement les avis publiés : un avis en modération reste invisible côté
  /// client.
  final List<Review> reviews;
  final double averageRating;
}

/// Coordonne C02 et la mise en relation M04.
class BrokerViewModel extends ChangeNotifier {
  BrokerViewModel({
    required String brokerId,
    required BrokerRepository brokers,
    required PropertyRepository properties,
    required ReviewRepository reviews,
    required ContactService contact,
    required GeoPoint from,
  }) : _brokerId = brokerId,
       _brokers = brokers,
       _properties = properties,
       _reviews = reviews,
       _contact = contact,
       _from = from;

  final String _brokerId;
  final BrokerRepository _brokers;
  final PropertyRepository _properties;
  final ReviewRepository _reviews;
  final ContactService _contact;
  final GeoPoint _from;

  ScreenState<BrokerDetail> _state = const ScreenState<BrokerDetail>.initial();
  MutationState _contactState = const MutationState.idle();

  /// Dernier contact réussi, pour proposer M05 au retour.
  ContactLog? lastContact;

  ScreenState<BrokerDetail> get state => _state;
  MutationState get contactState => _contactState;

  Future<void> load() async {
    _state = const ScreenState<BrokerDetail>.loading();
    notifyListeners();

    final Broker? broker = await _brokers.byId(_brokerId);
    if (broker == null) {
      // Lien profond vers une fiche disparue : on le dit, on ne redirige pas
      // en silence.
      _state = const ScreenState<BrokerDetail>.error(WkFailure.notFound);
      notifyListeners();
      return;
    }

    final List<Property> owned = await _properties.byBroker(
      _brokerId,
      onlyDiscoverable: true,
    );
    // `onlyPublic` explicite : C02 est la fiche publique. Un avis en
    // modération — ou refusé — ne s'y affiche pas et ne pèse pas dans la
    // moyenne, sans quoi une note publique se fabriquerait avec des avis que
    // personne n'a validés.
    final List<Review> published = await _reviews.byBroker(
      _brokerId,
      onlyPublic: true,
    );
    final double average = published.isEmpty
        ? 0
        : published
                  .map((Review r) => r.rating)
                  .reduce((int a, int b) => a + b) /
              published.length;

    _state = ScreenState<BrokerDetail>.data(
      BrokerDetail(
        broker: broker,
        from: _from,
        distanceMeters: distanceMeters(_from, broker.position),
        properties: owned,
        reviews: published,
        averageRating: average,
      ),
    );
    notifyListeners();
  }

  /// Journalise puis ouvre le canal. Renvoie `false` si rien n'a pu s'ouvrir.
  Future<bool> contactVia(ContactChannel channel, {String? propertyId}) async {
    final BrokerDetail? detail = _state.valueOrNull;
    if (detail == null || _contactState.isSubmitting) {
      return false;
    }

    _contactState = const MutationState.submitting();
    notifyListeners();

    // Le journal part sur le réseau et exige une session. Sans ce catch, un
    // 401 laissait `_contactState` en `submitting` : le bouton Contacter
    // tournait indéfiniment et devenait intouchable, sans un mot à l'écran —
    // sur l'action la plus importante de l'application.
    late final ContactAttempt attempt;
    try {
      attempt = await _contact.contact(
        broker: detail.broker,
        channel: channel,
        propertyId: propertyId,
      );
    } on DioException catch (error) {
      _contactState = MutationState.failure(
        error.response?.statusCode == 401
            ? WkFailure.permission
            : error.response == null
            ? WkFailure.network
            : WkFailure.unknown,
      );
      notifyListeners();
      return false;
    } on Object {
      _contactState = const MutationState.failure(WkFailure.unknown);
      notifyListeners();
      return false;
    }

    lastContact = attempt.log;
    _contactState = attempt.opened
        ? const MutationState.success()
        : const MutationState.failure(WkFailure.unknown);
    notifyListeners();
    return attempt.opened;
  }
}
