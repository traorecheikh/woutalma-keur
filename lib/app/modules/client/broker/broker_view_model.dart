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
    required this.distanceMeters,
    required this.properties,
    required this.reviews,
    required this.averageRating,
  });

  final Broker broker;
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
    final List<Review> published = await _reviews.byBroker(_brokerId);
    final double average = published.isEmpty
        ? 0
        : published
                  .map((Review r) => r.rating)
                  .reduce((int a, int b) => a + b) /
              published.length;

    _state = ScreenState<BrokerDetail>.data(
      BrokerDetail(
        broker: broker,
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

    final ContactAttempt attempt = await _contact.contact(
      broker: detail.broker,
      channel: channel,
      propertyId: propertyId,
    );
    lastContact = attempt.log;
    _contactState = attempt.opened
        ? const MutationState.success()
        : const MutationState.failure(WkFailure.unknown);
    notifyListeners();
    return attempt.opened;
  }
}
