import 'package:isar_community/isar.dart';
import 'package:woutalma_keur/app/domain/entities.dart';

part 'isar_rows.g.dart';

/// Lignes de la base locale.
///
/// Volontairement **distinctes des entités du domaine**. Le domaine reste
/// immuable, sans identifiant technique et sans annotation ; la base garde ses
/// contraintes. Le jour où un serveur remplace Isar, seul ce fichier et les
/// dépôts changent.
@collection
class BrokerRow {
  Id id = Isar.autoIncrement;

  /// Identifiant métier, stable et lisible. C'est lui que le reste de
  /// l'application manipule.
  @Index(unique: true, replace: true)
  late String uid;

  @enumerated
  late BrokerKind kind;

  late String name;
  late String phone;
  String? whatsapp;
  late double latitude;
  late double longitude;
  late List<String> coverage;
  String? logoAsset;

  @enumerated
  late VerificationStatus verification;

  late double responseRate;
  late bool pinned;

  Broker toDomain() => Broker(
    id: uid,
    kind: kind,
    name: name,
    phone: phone,
    whatsapp: whatsapp,
    position: GeoPoint(latitude, longitude),
    coverage: coverage,
    logoAsset: logoAsset,
    verification: verification,
    responseRate: responseRate,
    pinned: pinned,
  );

  static BrokerRow fromDomain(Broker broker) => BrokerRow()
    ..uid = broker.id
    ..kind = broker.kind
    ..name = broker.name
    ..phone = broker.phone
    ..whatsapp = broker.whatsapp
    ..latitude = broker.position.latitude
    ..longitude = broker.position.longitude
    ..coverage = broker.coverage
    ..logoAsset = broker.logoAsset
    ..verification = broker.verification
    ..responseRate = broker.responseRate
    ..pinned = broker.pinned;
}

@collection
class PropertyRow {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uid;

  @Index()
  late String brokerUid;

  @enumerated
  late PropertyKind kind;

  @enumerated
  late TransactionKind transaction;

  late String title;
  late String description;
  late int price;
  int? surface;
  int? rooms;
  late double latitude;
  late double longitude;
  late String neighbourhood;
  late List<String> photoAssets;

  @enumerated
  late PropertyStatus status;

  late DateTime createdAt;

  Property toDomain() => Property(
    id: uid,
    brokerId: brokerUid,
    kind: kind,
    transaction: transaction,
    title: title,
    description: description,
    price: price,
    surface: surface,
    rooms: rooms,
    position: GeoPoint(latitude, longitude),
    neighbourhood: neighbourhood,
    photoAssets: photoAssets,
    status: status,
    createdAt: createdAt,
  );

  static PropertyRow fromDomain(Property property) => PropertyRow()
    ..uid = property.id
    ..brokerUid = property.brokerId
    ..kind = property.kind
    ..transaction = property.transaction
    ..title = property.title
    ..description = property.description
    ..price = property.price
    ..surface = property.surface
    ..rooms = property.rooms
    ..latitude = property.position.latitude
    ..longitude = property.position.longitude
    ..neighbourhood = property.neighbourhood
    ..photoAssets = property.photoAssets
    ..status = property.status
    ..createdAt = property.createdAt;
}

@collection
class ReviewRow {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uid;

  @Index()
  late String brokerUid;

  late String contactUid;
  late int rating;
  int? responsiveness;
  int? accuracy;
  int? courtesy;
  String? comment;

  @enumerated
  late ModerationStatus moderation;

  String? brokerReply;
  late DateTime createdAt;

  Review toDomain() => Review(
    id: uid,
    brokerId: brokerUid,
    contactId: contactUid,
    rating: rating,
    responsiveness: responsiveness,
    accuracy: accuracy,
    courtesy: courtesy,
    comment: comment,
    moderation: moderation,
    brokerReply: brokerReply,
    createdAt: createdAt,
  );

  static ReviewRow fromDomain(Review review) => ReviewRow()
    ..uid = review.id
    ..brokerUid = review.brokerId
    ..contactUid = review.contactId
    ..rating = review.rating
    ..responsiveness = review.responsiveness
    ..accuracy = review.accuracy
    ..courtesy = review.courtesy
    ..comment = review.comment
    ..moderation = review.moderation
    ..brokerReply = review.brokerReply
    ..createdAt = review.createdAt;
}

@collection
class ContactRow {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uid;

  @Index()
  late String brokerUid;

  String? propertyUid;

  @enumerated
  late ContactChannel channel;

  @enumerated
  late ContactOutcome outcome;

  String? reviewUid;
  late DateTime createdAt;

  ContactLog toDomain() => ContactLog(
    id: uid,
    brokerId: brokerUid,
    propertyId: propertyUid,
    channel: channel,
    outcome: outcome,
    reviewId: reviewUid,
    createdAt: createdAt,
  );

  static ContactRow fromDomain(ContactLog contact) => ContactRow()
    ..uid = contact.id
    ..brokerUid = contact.brokerId
    ..propertyUid = contact.propertyId
    ..channel = contact.channel
    ..outcome = contact.outcome
    ..reviewUid = contact.reviewId
    ..createdAt = contact.createdAt;
}
