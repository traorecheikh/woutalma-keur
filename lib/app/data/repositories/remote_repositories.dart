import 'package:dio/dio.dart';
import 'package:woutalma_api_client/woutalma_api_client.dart' as api;
import 'package:woutalma_keur/app/data/repositories/remote_mappers.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/repositories.dart';
import 'package:woutalma_keur/app/domain/review_eligibility.dart';

/// Dépôts branchés sur l'API. Mêmes contrats que les versions InMemory/Isar
/// (`lib/app/domain/repositories.dart` : « Une implémentation Isar ou distante
/// se substitue sans qu'un widget bouge ») — aucun écran ne sait laquelle est
/// câblée.
///
/// Ces classes ne font que du HTTP : ni cache, ni repli. La politique hors
/// ligne vit dans `cached_repositories.dart`, qui les enveloppe. Garder les
/// deux séparées permet de tester la politique sans réseau et le réseau sans
/// base.

class RemoteBrokerRepository implements BrokerRepository {
  RemoteBrokerRepository(this._api);

  final api.BrokersApi _api;

  @override
  Future<List<Broker>> all() async {
    final response = await _api.brokersControllerFindAll();
    return (response.data ?? const <api.BrokerDto>[]).map(mapBroker).toList();
  }

  @override
  Future<Broker?> byId(String id) async {
    try {
      final response = await _api.brokersControllerFindById(id: id);
      final dto = response.data;
      return dto == null ? null : mapBroker(dto);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  /// Crée le profil au premier enregistrement, le met à jour ensuite.
  ///
  /// Le serveur refuse `verification`, `responseRate` et `pinned` : ce sont
  /// des signaux de confiance que le produit calcule ou qu'un opérateur
  /// accorde, jamais le courtier lui-même.
  @override
  Future<void> save(Broker broker) async {
    final Broker? existing = await byId(broker.id);
    if (existing == null) {
      await _api.brokersControllerCreate(
        createBrokerDto: api.CreateBrokerDto(
          (b) => b
            ..kind = api.CreateBrokerDtoKindEnum.valueOf(
              brokerKindWireName(broker.kind),
            )
            ..name = broker.name
            ..phone = broker.phone
            ..whatsapp = broker.whatsapp
            ..latitude = broker.position.latitude
            ..longitude = broker.position.longitude
            ..logoAsset = broker.logoAsset
            ..coverage.addAll(broker.coverage),
        ),
      );
      return;
    }
    await _api.brokersControllerUpdate(
      id: broker.id,
      updateBrokerDto: api.UpdateBrokerDto(
        (b) => b
          ..kind = api.UpdateBrokerDtoKindEnum.valueOf(
            brokerKindWireName(broker.kind),
          )
          ..name = broker.name
          ..phone = broker.phone
          ..whatsapp = broker.whatsapp
          ..latitude = broker.position.latitude
          ..longitude = broker.position.longitude
          ..logoAsset = broker.logoAsset
          ..coverage.addAll(broker.coverage),
      ),
    );
  }

  /// Pas d'écriture en lot côté serveur : chaque profil est une requête.
  @override
  Future<void> saveAll(List<Broker> brokers) async {
    for (final Broker broker in brokers) {
      await save(broker);
    }
  }
}

class RemotePropertyRepository implements PropertyRepository {
  RemotePropertyRepository(this._propertiesApi, this._brokersApi);

  final api.PropertiesApi _propertiesApi;

  // brokers/:id/properties lives on BrokersApi, not PropertiesApi — kept
  // private so callers of this repository never need to know that.
  final api.BrokersApi _brokersApi;

  @override
  Future<List<Property>> all() async {
    final response = await _propertiesApi.propertiesControllerFindAll(
      discoverableOnly: 'false',
    );
    return (response.data ?? const <api.PropertyDto>[])
        .map(mapProperty)
        .toList();
  }

  @override
  Future<List<Property>> discoverable() async {
    final response = await _propertiesApi.propertiesControllerFindAll(
      discoverableOnly: 'true',
    );
    return (response.data ?? const <api.PropertyDto>[])
        .map(mapProperty)
        .toList();
  }

  @override
  Future<List<Property>> byBroker(
    String brokerId, {
    bool onlyDiscoverable = false,
  }) async {
    final response = await _brokersApi.brokersControllerFindProperties(
      id: brokerId,
      onlyDiscoverable: onlyDiscoverable,
    );
    return (response.data ?? const <api.PropertyDto>[])
        .map(mapProperty)
        .toList();
  }

  @override
  Future<Property?> byId(String id) async {
    try {
      final response = await _propertiesApi.propertiesControllerFindById(
        id: id,
      );
      final dto = response.data;
      return dto == null ? null : mapProperty(dto);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  /// Publie ou met à jour un bien.
  ///
  /// Les photos déjà connues du serveur (`demo:…`, `api:…`) repartent telles
  /// quelles dans `photoAssets` ; celles qui viennent d'être prises sur le
  /// téléphone sont des chemins de fichier locaux et doivent être téléversées
  /// séparément — voir `PropertyPhotoUploader`.
  @override
  Future<void> save(Property property) async {
    final Property? existing = await byId(property.id);
    if (existing == null) {
      await _propertiesApi.propertiesControllerCreate(
        createPropertyDto: api.CreatePropertyDto(
          (b) => b
            ..kind = api.CreatePropertyDtoKindEnum.valueOf(
              propertyKindWireName(property.kind),
            )
            ..transaction = api.CreatePropertyDtoTransactionEnum.valueOf(
              transactionKindWireName(property.transaction),
            )
            ..title = property.title
            ..description = property.description
            ..price = property.price
            ..surface = property.surface
            ..rooms = property.rooms
            ..latitude = property.position.latitude
            ..longitude = property.position.longitude
            ..neighbourhood = property.neighbourhood
            ..status = api.CreatePropertyDtoStatusEnum.valueOf(
              propertyStatusWireName(property.status),
            )
            ..photoAssets.addAll(property.photoAssets),
        ),
      );
      return;
    }
    await _propertiesApi.propertiesControllerUpdate(
      id: property.id,
      updatePropertyDto: api.UpdatePropertyDto(
        (b) => b
          ..kind = api.UpdatePropertyDtoKindEnum.valueOf(
            propertyKindWireName(property.kind),
          )
          ..transaction = api.UpdatePropertyDtoTransactionEnum.valueOf(
            transactionKindWireName(property.transaction),
          )
          ..title = property.title
          ..description = property.description
          ..price = property.price
          ..surface = property.surface
          ..rooms = property.rooms
          ..latitude = property.position.latitude
          ..longitude = property.position.longitude
          ..neighbourhood = property.neighbourhood
          ..status = api.UpdatePropertyDtoStatusEnum.valueOf(
            propertyStatusWireName(property.status),
          )
          ..photoAssets.addAll(property.photoAssets),
      ),
    );
  }

  /// Retrait doux : le serveur passe le bien en `CLOSED` au lieu de le
  /// supprimer, sinon l'historique de contact d'un client cesserait de
  /// résoudre la fiche qu'il a appelée.
  @override
  Future<void> delete(String id) async {
    await _propertiesApi.propertiesControllerClose(id: id);
  }

  /// Pas d'écriture en lot côté serveur : chaque bien est une requête.
  @override
  Future<void> saveAll(List<Property> properties) async {
    for (final Property property in properties) {
      await save(property);
    }
  }
}

class RemoteReviewRepository implements ReviewRepository {
  const RemoteReviewRepository(this._api);

  final api.ReviewsApi _api;

  @override
  Future<List<Review>> byBroker(
    String brokerId, {
    bool onlyPublic = false,
  }) async {
    final response = await _api.reviewsControllerByBroker(
      brokerId: brokerId,
      onlyPublic: onlyPublic.toString(),
    );
    return (response.data ?? const <api.ReviewDto>[]).map(mapReview).toList();
  }

  @override
  Future<List<Review>> all() async {
    final response = await _api.reviewsControllerAll(onlyPublic: 'false');
    return (response.data ?? const <api.ReviewDto>[]).map(mapReview).toList();
  }

  /// L'identifiant et la modération viennent du serveur : l'éligibilité est
  /// revérifiée là-bas, et un 403 rapporte laquelle des quatre règles a
  /// refusé. On la retraduit vers le vocabulaire de
  /// `review_eligibility.dart` pour que l'écran affiche la même phrase qu'en
  /// local.
  @override
  Future<Review> save(Review review) async {
    try {
      final response = await _api.reviewsControllerCreate(
        createReviewDto: api.CreateReviewDto(
          (b) => b
            ..contactId = review.contactId
            ..rating = review.rating
            ..responsiveness = review.responsiveness
            ..accuracy = review.accuracy
            ..courtesy = review.courtesy
            ..comment = review.comment,
        ),
      );
      return mapReview(response.data!);
    } on DioException catch (error) {
      final ReviewRefusal? refusal = _refusalFrom(error);
      if (refusal != null) {
        throw ReviewNotAllowed(refusal);
      }
      rethrow;
    }
  }

  ReviewRefusal? _refusalFrom(DioException error) {
    if (error.response?.statusCode != 403) {
      return null;
    }
    final Object? body = error.response?.data;
    final Object? reason = body is Map ? body['reason'] : null;
    return switch (reason) {
      'noContact' => ReviewRefusal.noContact,
      'notOwner' => ReviewRefusal.notOwner,
      'notReached' => ReviewRefusal.notReached,
      'alreadyReviewed' => ReviewRefusal.alreadyReviewed,
      _ => null,
    };
  }

  /// Pas d'écriture en lot côté serveur : chaque avis passe par sa propre
  /// vérification d'éligibilité.
  @override
  Future<void> saveAll(List<Review> reviews) async {
    for (final Review review in reviews) {
      await save(review);
    }
  }
}

class RemoteContactRepository implements ContactRepository {
  RemoteContactRepository(this._api);

  final api.ContactsApi _api;

  @override
  Future<List<ContactLog>> all() async {
    final response = await _api.contactsControllerAll();
    return (response.data ?? const <api.ContactLogDto>[])
        .map(mapContactLog)
        .toList();
  }

  @override
  Future<ContactLog?> byId(String id) async {
    try {
      final response = await _api.contactsControllerById(id: id);
      final dto = response.data;
      return dto == null ? null : mapContactLog(dto);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  /// Mirrors ContactRepository.log — logs BEFORE the caller opens the
  /// external channel (see ContactService.contact in contact_launcher.dart),
  /// and the row is durably committed server-side by the time this returns.
  @override
  Future<ContactLog> log({
    required String brokerId,
    String? propertyId,
    required ContactChannel channel,
  }) async {
    final response = await _api.contactsControllerLog(
      createContactDto: api.CreateContactDto((b) {
        b.brokerId = brokerId;
        b.propertyId = propertyId;
        b.channel = mapContactChannelToApi(channel);
      }),
    );
    return mapContactLog(response.data!);
  }

  @override
  Future<void> update(ContactLog contact) async {
    await _api.contactsControllerUpdateOutcome(
      id: contact.id,
      updateContactOutcomeDto: api.UpdateContactOutcomeDto((b) {
        b.outcome = mapContactOutcomeToApi(contact.outcome);
      }),
    );
  }

  @override
  Future<void> updateAll(List<ContactLog> contacts) async {
    for (final ContactLog contact in contacts) {
      await update(contact);
    }
  }
}
