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

  /// Dernier contact ouvert, tant que M05 ne l'a pas repris.
  ContactLog? _pendingOutcome;

  ScreenState<BrokerDetail> get state => _state;
  MutationState get contactState => _contactState;

  /// Rend le contact en attente de résultat, et le retire : M05 ne se pose
  /// qu'une fois par mise en relation.
  ContactLog? takePendingOutcome() {
    final ContactLog? pending = _pendingOutcome;
    _pendingOutcome = null;
    return pending;
  }

  Future<void> load() async {
    _state = const ScreenState<BrokerDetail>.loading();
    notifyListeners();

    final Broker? broker;
    final List<Property> owned;
    final List<Review> published;
    try {
      broker = await _brokers.byId(_brokerId);
      if (broker == null) {
        // Lien profond vers une fiche disparue : on le dit, on ne redirige pas
        // en silence.
        _state = const ScreenState<BrokerDetail>.error(WkFailure.notFound);
        notifyListeners();
        return;
      }
      owned = await _properties.byBroker(_brokerId, onlyDiscoverable: true);
      // `onlyPublic` explicite : C02 est la fiche publique. Un avis en
      // modération — ou refusé — ne s'y affiche pas et ne pèse pas dans la
      // moyenne, sans quoi une note publique se fabriquerait avec des avis que
      // personne n'a validés.
      published = await _reviews.byBroker(_brokerId, onlyPublic: true);
    } on DioException catch (error) {
      // Sans cette garde, une coupure laissait le squelette tourner sans fin.
      _state = ScreenState<BrokerDetail>.error(
        error.response == null ? WkFailure.network : WkFailure.unknown,
      );
      notifyListeners();
      return;
    } on Object {
      _state = const ScreenState<BrokerDetail>.error(WkFailure.unknown);
      notifyListeners();
      return;
    }

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

  /// Ouvre le canal puis journalise. L'écran dit ce qui n'a pas pu s'ouvrir.
  Future<ContactAttempt> contactVia(
    ContactChannel channel, {
    String? propertyId,
  }) async {
    final BrokerDetail? detail = _state.valueOrNull;
    if (detail == null || _contactState.isSubmitting) {
      return const ContactAttempt(log: null, opened: false);
    }

    _contactState = const MutationState.submitting();
    notifyListeners();

    final ContactAttempt attempt = await _contact.contact(
      broker: detail.broker,
      channel: channel,
      propertyId: propertyId,
    );

    _pendingOutcome = attempt.log;
    _contactState = attempt.opened
        ? const MutationState.success()
        : const MutationState.failure(WkFailure.unknown);
    notifyListeners();
    return attempt;
  }

  /// L'appel sans compte : rien n'est journalisé, mais le téléphone s'ouvre.
  Future<bool> callWithoutAccount() async {
    final BrokerDetail? detail = _state.valueOrNull;
    if (detail == null) {
      return false;
    }
    return _contact.open(ContactChannel.call, detail.broker);
  }

  Future<void> recordOutcome(ContactLog log, ContactOutcome outcome) async {
    try {
      await _contact.recordOutcome(log, outcome);
    } on Object {
      // Déclarer un résultat n'est pas l'action principale de l'écran : son
      // échec ne doit pas remplacer la fiche par une erreur.
    }
  }
}
