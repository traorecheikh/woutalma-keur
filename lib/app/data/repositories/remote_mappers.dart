import 'package:woutalma_api_client/woutalma_api_client.dart' as api;
import 'package:woutalma_keur/app/domain/entities.dart';

/// Maps generated `woutalma_api_client` models onto the domain entities in
/// entities.dart. Keeps the generated types out of domain/ and out of every
/// widget — screens only ever see Broker/Property/Review/ContactLog, exactly
/// as the repositories.dart docstring promises ("Une implémentation Isar ou
/// distante se substitue sans qu'un widget bouge").
///
/// Each API enum is its own generated Dart type (BrokerDtoKindEnum vs
/// PropertyDtoKindEnum, etc.) even where the wire values are shared, so the
/// mapping below is written per concrete enum type rather than once
/// generically.

BrokerKind _brokerKind(api.BrokerDtoKindEnum value) {
  switch (value.name) {
    case 'AGENCY':
      return BrokerKind.agency;
    case 'INDIVIDUAL':
    default:
      return BrokerKind.individual;
  }
}

VerificationStatus _verificationStatus(api.BrokerDtoVerificationEnum value) {
  switch (value.name) {
    case 'PENDING':
      return VerificationStatus.pending;
    case 'VERIFIED':
      return VerificationStatus.verified;
    case 'REJECTED':
      return VerificationStatus.rejected;
    case 'NONE':
    default:
      return VerificationStatus.none;
  }
}

TransactionKind _transactionKind(api.PropertyDtoTransactionEnum value) {
  switch (value.name) {
    case 'SALE':
      return TransactionKind.sale;
    case 'RENT':
    default:
      return TransactionKind.rent;
  }
}

PropertyKind _propertyKind(api.PropertyDtoKindEnum value) {
  switch (value.name) {
    case 'HOUSE':
      return PropertyKind.house;
    case 'LAND':
      return PropertyKind.land;
    case 'STUDIO':
      return PropertyKind.studio;
    case 'ROOM':
      return PropertyKind.room;
    case 'APARTMENT':
    default:
      return PropertyKind.apartment;
  }
}

PropertyStatus _propertyStatus(api.PropertyDtoStatusEnum value) {
  switch (value.name) {
    case 'RESERVED':
      return PropertyStatus.reserved;
    case 'CLOSED':
      return PropertyStatus.closed;
    case 'AVAILABLE':
    default:
      return PropertyStatus.available;
  }
}

ContactChannel _contactChannel(String wireName) {
  switch (wireName) {
    case 'SMS':
      return ContactChannel.sms;
    case 'WHATSAPP':
      return ContactChannel.whatsapp;
    case 'VOICE_MESSAGE':
      return ContactChannel.voiceMessage;
    case 'CALL':
    default:
      return ContactChannel.call;
  }
}

String _contactChannelWireName(ContactChannel channel) {
  switch (channel) {
    case ContactChannel.call:
      return 'CALL';
    case ContactChannel.sms:
      return 'SMS';
    case ContactChannel.whatsapp:
      return 'WHATSAPP';
    case ContactChannel.voiceMessage:
      return 'VOICE_MESSAGE';
  }
}

ContactOutcome _contactOutcome(String wireName) {
  switch (wireName) {
    case 'REACHED':
      return ContactOutcome.reached;
    case 'NO_ANSWER':
      return ContactOutcome.noAnswer;
    case 'ATTEMPTED':
    default:
      return ContactOutcome.attempted;
  }
}

String _contactOutcomeWireName(ContactOutcome outcome) {
  switch (outcome) {
    case ContactOutcome.attempted:
      return 'ATTEMPTED';
    case ContactOutcome.reached:
      return 'REACHED';
    case ContactOutcome.noAnswer:
      return 'NO_ANSWER';
  }
}

ModerationStatus _moderationStatus(api.ReviewDtoModerationEnum value) {
  switch (value.name) {
    case 'PUBLISHED':
      return ModerationStatus.published;
    case 'REJECTED':
      return ModerationStatus.rejected;
    case 'PENDING':
    default:
      return ModerationStatus.pending;
  }
}

GeoPoint mapGeoPoint(api.GeoPointDto dto) {
  return GeoPoint(dto.latitude.toDouble(), dto.longitude.toDouble());
}

Broker mapBroker(api.BrokerDto dto) {
  return Broker(
    id: dto.id,
    kind: _brokerKind(dto.kind),
    name: dto.name,
    phone: dto.phone,
    whatsapp: dto.whatsapp,
    position: mapGeoPoint(dto.position),
    coverage: dto.coverage.toList(),
    logoAsset: dto.logoAsset,
    verification: _verificationStatus(dto.verification),
    responseRate: dto.responseRate.toDouble(),
    pinned: dto.pinned,
  );
}

Property mapProperty(api.PropertyDto dto) {
  return Property(
    id: dto.id,
    brokerId: dto.brokerId,
    kind: _propertyKind(dto.kind),
    transaction: _transactionKind(dto.transaction),
    title: dto.title,
    description: dto.description,
    price: dto.price.toInt(),
    surface: dto.surface?.toInt(),
    rooms: dto.rooms?.toInt(),
    position: mapGeoPoint(dto.position),
    neighbourhood: dto.neighbourhood,
    photoAssets: dto.photoAssets.toList(),
    status: _propertyStatus(dto.status),
    createdAt: dto.createdAt,
  );
}

Review mapReview(api.ReviewDto dto) {
  return Review(
    id: dto.id,
    brokerId: dto.brokerId,
    contactId: dto.contactId,
    rating: dto.rating.toInt(),
    responsiveness: dto.responsiveness?.toInt(),
    accuracy: dto.accuracy?.toInt(),
    courtesy: dto.courtesy?.toInt(),
    comment: dto.comment,
    moderation: _moderationStatus(dto.moderation),
    brokerReply: dto.brokerReply,
    createdAt: dto.createdAt,
  );
}

ContactLog mapContactLog(api.ContactLogDto dto) {
  return ContactLog(
    id: dto.id,
    brokerId: dto.brokerId,
    propertyId: dto.propertyId,
    channel: _contactChannel(dto.channel.name),
    outcome: _contactOutcome(dto.outcome.name),
    createdAt: dto.createdAt,
    reviewId: dto.reviewId,
  );
}

BrokerListing mapBrokerListing(api.BrokerListingDto dto) {
  return BrokerListing(
    broker: mapBroker(dto.broker),
    distanceMeters: dto.distanceMeters.toDouble(),
    averageRating: dto.averageRating.toDouble(),
    reviewCount: dto.reviewCount.toInt(),
    availableProperties: dto.availableProperties.toInt(),
    score: dto.score.toDouble(),
  );
}

/// Noms filaires pour les écritures.
///
/// Le générateur produit un type d'énumération distinct par DTO
/// (`CreatePropertyDtoKindEnum`, `UpdatePropertyDtoKindEnum`, …) alors que la
/// valeur transmise est la même chaîne. Passer par le nom filaire évite
/// d'écrire la même table de correspondance une fois par DTO.
String brokerKindWireName(BrokerKind kind) => switch (kind) {
  BrokerKind.individual => 'INDIVIDUAL',
  BrokerKind.agency => 'AGENCY',
};

String propertyKindWireName(PropertyKind kind) => switch (kind) {
  PropertyKind.apartment => 'APARTMENT',
  PropertyKind.house => 'HOUSE',
  PropertyKind.land => 'LAND',
  PropertyKind.studio => 'STUDIO',
  PropertyKind.room => 'ROOM',
};

String transactionKindWireName(TransactionKind kind) => switch (kind) {
  TransactionKind.rent => 'RENT',
  TransactionKind.sale => 'SALE',
};

String propertyStatusWireName(PropertyStatus status) => switch (status) {
  PropertyStatus.available => 'AVAILABLE',
  PropertyStatus.reserved => 'RESERVED',
  PropertyStatus.closed => 'CLOSED',
};

api.CreateContactDtoChannelEnum mapContactChannelToApi(ContactChannel channel) {
  return api.CreateContactDtoChannelEnum.valueOf(
    _contactChannelWireName(channel),
  );
}

api.UpdateContactOutcomeDtoOutcomeEnum mapContactOutcomeToApi(
  ContactOutcome outcome,
) {
  return api.UpdateContactOutcomeDtoOutcomeEnum.valueOf(
    _contactOutcomeWireName(outcome),
  );
}
