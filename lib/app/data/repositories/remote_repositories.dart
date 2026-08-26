import 'dart:math';

import 'package:dio/dio.dart';
import 'package:woutalma_api_client/woutalma_api_client.dart' as api;
import 'package:woutalma_keur/app/data/repositories/remote_mappers.dart';
import 'package:woutalma_keur/app/data/services/property_photo_uploader.dart';
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
          // built_value n'écrit pas les nuls : effacer le WhatsApp n'envoyait
          // rien et le bouton continuait d'ouvrir un numéro abandonné.
          ..clearWhatsapp = broker.whatsapp == null
          ..latitude = broker.position.latitude
          ..longitude = broker.position.longitude
          ..logoAsset = broker.logoAsset
          ..coverage.addAll(broker.coverage),
      ),
    );
  }

  @override
  Future<Broker> requestVerification(String brokerId) async {
    final response = await _api.brokersControllerRequestVerification(
      id: brokerId,
    );
    return mapBroker(response.data!);
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
  RemotePropertyRepository(
    this._propertiesApi,
    this._brokersApi, {
    PropertyPhotoUploader photos = const PropertyPhotoUploader(),
    PropertyVoiceNoteUploader voiceNotes = const PropertyVoiceNoteUploader(),
  }) : _photos = photos,
       _voiceNotes = voiceNotes;

  final api.PropertiesApi _propertiesApi;

  // brokers/:id/properties lives on BrokersApi, not PropertiesApi — kept
  // private so callers of this repository never need to know that.
  final api.BrokersApi _brokersApi;

  /// Sépare les clés déjà connues du serveur des fichiers locaux à téléverser.
  final PropertyPhotoUploader _photos;
  final PropertyVoiceNoteUploader _voiceNotes;

  static const String _draftIdPrefix = 'prp-';

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

  /// Publie ou met à jour un bien, et rend **ce que le serveur a enregistré**.
  ///
  /// Deux choses ne survivent pas au voyage et doivent revenir de là-bas :
  /// l'identifiant, frappé à l'insertion — celui que l'éditeur avait fabriqué
  /// est ignoré — et les photos, dont les chemins locaux deviennent des clés
  /// `api:<id>`.
  ///
  /// Les photos déjà connues du serveur (`demo:…`, `api:…`) repartent telles
  /// quelles dans `photoAssets` ; celles qui viennent d'être prises sur le
  /// téléphone sont des chemins de fichier locaux, lus et encodés dans
  /// `newPhotos` par [PropertyPhotoUploader]. Envoyer le chemin dans
  /// `photoAssets`, comme avant, faisait accepter au serveur une chaîne
  /// opaque : la photo ne s'affichait que sur le téléphone qui l'avait
  /// publiée.
  ///
  /// Publication ou modification se décide sur la forme de l'identifiant, sans
  /// aller le demander : `PropertyRepository.save` fixe déjà que l'éditeur
  /// fabrique `prp-<micros>` et que le serveur frappe le sien. La sonde
  /// coûtait un aller-retour supplémentaire exactement au moment où le réseau
  /// est le plus fragile — juste avant de publier.
  @override
  Future<Property> save(Property property) async {
    final bool isNew = property.id.startsWith(_draftIdPrefix);
    final PreparedPhotos photos = await _photos.prepare(property.photoAssets);
    final PreparedVoiceNote voice = await _voiceNotes.prepare(
      property.voiceAsset,
    );
    // Sur une modification, l'absence de vocal est une décision : la chaîne
    // vide dit « retire-le », l'omission dirait « n'y touche pas ».
    final String? voiceAsset = voice.upload != null
        ? null
        : voice.retained ?? (isNew ? null : '');
    final api.UploadVoiceNoteDto? newVoiceNote = voice.upload == null
        ? null
        : api.UploadVoiceNoteDto(
            (b) => b
              ..mimeType = api.UploadVoiceNoteDtoMimeTypeEnum.valueOf(
                voice.upload!.mimeType,
              )
              ..dataBase64 = voice.upload!.dataBase64,
          );

    if (isNew) {
      final response = await _propertiesApi.propertiesControllerCreate(
        createPropertyDto: api.CreatePropertyDto(
          (b) => b
            // Clé d'idempotence : l'éditeur garde le même identifiant de
            // brouillon d'un essai à l'autre, donc republier après un
            // délai dépassé rend l'annonce déjà créée au lieu d'une seconde.
            ..clientRequestId = property.id
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
            ..photoAssets.addAll(photos.retained)
            ..newPhotos.addAll(photos.uploads.map(_uploadDto))
            ..voiceAsset = voiceAsset
            ..newVoiceNote = newVoiceNote?.toBuilder(),
        ),
      );
      return mapProperty(response.data!);
    }
    final response = await _propertiesApi.propertiesControllerUpdate(
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
          // Même raison que `clearWhatsapp` : un champ vidé ne part pas, donc
          // un bien repassé en terrain gardait ses « 3 pièces » sur le
          // serveur alors que le formulaire ne les proposait plus.
          ..clearSurface = property.surface == null
          ..clearRooms = property.rooms == null
          ..latitude = property.position.latitude
          ..longitude = property.position.longitude
          ..neighbourhood = property.neighbourhood
          ..status = api.UpdatePropertyDtoStatusEnum.valueOf(
            propertyStatusWireName(property.status),
          )
          ..photoAssets.addAll(photos.retained)
          ..newPhotos.addAll(photos.uploads.map(_uploadDto))
          ..voiceAsset = voiceAsset
          ..newVoiceNote = newVoiceNote?.toBuilder(),
      ),
    );
    return mapProperty(response.data!);
  }

  static api.UploadPhotoDto _uploadDto(PreparedPhoto photo) {
    return api.UploadPhotoDto(
      (b) => b
        ..mimeType = _mimeEnum(photo.mimeType)
        ..dataBase64 = photo.dataBase64,
    );
  }

  /// Le générateur renomme `image/jpeg` en `imageSlashJpeg` ; la valeur
  /// filaire reste `image/jpeg`.
  static api.UploadPhotoDtoMimeTypeEnum _mimeEnum(String mimeType) =>
      switch (mimeType) {
        'image/png' => api.UploadPhotoDtoMimeTypeEnum.imageSlashPng,
        'image/webp' => api.UploadPhotoDtoMimeTypeEnum.imageSlashWebp,
        _ => api.UploadPhotoDtoMimeTypeEnum.imageSlashJpeg,
      };

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

  /// Public par défaut, comme le contrat. Le serveur, lui, rend aussi les
  /// avis `PENDING`/`REJECTED` quand on lui demande `onlyPublic=false` : la
  /// fiche publique d'un courtier les affichait et les faisait entrer dans la
  /// moyenne.
  @override
  Future<List<Review>> byBroker(
    String brokerId, {
    bool onlyPublic = true,
  }) async {
    final response = await _api.reviewsControllerByBroker(
      brokerId: brokerId,
      onlyPublic: onlyPublic,
    );
    return (response.data ?? const <api.ReviewDto>[]).map(mapReview).toList();
  }

  /// Le serveur ne rend plus que les avis publiés sur cette route, sans
  /// paramètre : elle traverse tous les courtiers, donc il n'existe personne à
  /// qui accorder une vue plus large, et `onlyPublic=false` revenait à ouvrir
  /// la file de modération entière à un appelant anonyme.
  @override
  Future<List<Review>> all() async {
    final response = await _api.reviewsControllerAll();
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

  @override
  Future<Review> reply(String reviewId, String reply) async {
    final response = await _api.reviewsControllerReply(
      id: reviewId,
      replyReviewDto: api.ReplyReviewDto((b) => b.reply = reply),
    );
    return mapReview(response.data!);
  }

  @override
  Future<Review> report(String reviewId, {String? reason}) async {
    final response = await _api.reviewsControllerReport(
      id: reviewId,
      reportReviewDto: api.ReportReviewDto((b) => b.reason = reason),
    );
    return mapReview(response.data!);
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
  RemoteContactRepository(this._api, this._brokersApi);

  static final Random _random = Random();

  final api.ContactsApi _api;

  /// Les contacts reçus vivent sur BrokersApi : c'est une lecture du profil
  /// courtier, pas de l'historique personnel de l'appelant.
  final api.BrokersApi _brokersApi;

  @override
  Future<List<ContactLog>> receivedBy(String brokerId) async {
    final response = await _brokersApi.brokersControllerFindContacts(
      id: brokerId,
    );
    return (response.data ?? const <api.BrokerContactLogDto>[])
        .map(mapReceivedContactLog)
        .toList();
  }

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

  /// `clientRequestId` : une reprise après coupure ne doit pas créer deux
  /// contacts pour un seul appel. Le serveur déduplique dessus.
  @override
  Future<ContactLog> log({
    required String brokerId,
    String? propertyId,
    required ContactChannel channel,
  }) async {
    final String requestId =
        'req-${DateTime.now().microsecondsSinceEpoch}-'
        '${_random.nextInt(0xFFFFFF).toRadixString(16)}';
    final response = await _api.contactsControllerLog(
      createContactDto: api.CreateContactDto((b) {
        b.brokerId = brokerId;
        b.propertyId = propertyId;
        b.channel = mapContactChannelToApi(channel);
        b.clientRequestId = requestId;
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

  @override
  Future<void> remove(String id) async {}
}
