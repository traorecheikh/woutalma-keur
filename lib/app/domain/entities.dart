import 'package:flutter/foundation.dart';

/// Nature d'un intermédiaire.
enum BrokerKind { individual, agency }

/// Où en est la vérification d'un profil.
enum VerificationStatus { none, pending, verified, rejected }

/// Ce qu'on fait d'un bien.
enum TransactionKind { rent, sale }

/// Type de bien.
enum PropertyKind { apartment, house, land, studio, room }

/// Disponibilité d'un bien.
///
/// `closed` couvre vendu et loué : côté client, l'information utile est
/// « ce n'est plus disponible », pas laquelle des deux.
enum PropertyStatus { available, reserved, closed }

/// Canal par lequel un client a joint un courtier.
enum ContactChannel { call, sms, whatsapp, voiceMessage }

/// Ce qui est arrivé après une mise en relation.
enum ContactOutcome {
  /// Le canal a été ouvert, on ne sait pas encore ce qui s'est passé.
  attempted,

  /// L'échange a eu lieu : c'est la seule porte vers un avis.
  reached,

  /// Pas de réponse. Le journal reste, l'avis n'est pas ouvert.
  noAnswer,
}

/// Étape de modération d'un avis.
enum ModerationStatus { pending, published, rejected }

@immutable
class GeoPoint {
  const GeoPoint(this.latitude, this.longitude);

  final double latitude;
  final double longitude;

  @override
  bool operator ==(Object other) =>
      other is GeoPoint &&
      other.latitude == latitude &&
      other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);
}

@immutable
class Broker {
  const Broker({
    required this.id,
    required this.kind,
    required this.name,
    required this.phone,
    required this.position,
    required this.coverage,
    this.whatsapp,
    this.logoAsset,
    this.verification = VerificationStatus.none,
    this.responseRate = 0,
    this.pinned = false,
  });

  final String id;
  final BrokerKind kind;
  final String name;
  final String phone;

  /// Absent quand le courtier n'a pas WhatsApp : le bouton disparaît alors,
  /// il ne devient pas un bouton mort.
  final String? whatsapp;
  final GeoPoint position;

  /// Quartiers couverts, tels qu'ils sont dits localement.
  final List<String> coverage;
  final String? logoAsset;
  final VerificationStatus verification;

  /// Entre 0 et 1. Entre dans le score de classement.
  final double responseRate;

  /// Mise en avant payée. Toujours signalée comme telle : elle ne se confond
  /// jamais avec un bon classement organique.
  final bool pinned;

  bool get isVerified => verification == VerificationStatus.verified;

  /// Copie modifiée.
  ///
  /// Les appelants recomposaient les onze champs à la main : un oubli effaçait
  /// silencieusement une donnée — la couverture, ou le WhatsApp — au moment
  /// même où le courtier croyait n'avoir changé que son nom.
  ///
  /// `whatsapp` et `logoAsset` sont nullables et se vident volontairement, d'où
  /// les drapeaux explicites : `whatsapp: null` ne peut pas dire à la fois
  /// « inchangé » et « retiré ».
  Broker copyWith({
    BrokerKind? kind,
    String? name,
    String? phone,
    String? whatsapp,
    GeoPoint? position,
    List<String>? coverage,
    String? logoAsset,
    VerificationStatus? verification,
    double? responseRate,
    bool? pinned,
    bool clearWhatsapp = false,
    bool clearLogoAsset = false,
  }) {
    return Broker(
      id: id,
      kind: kind ?? this.kind,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      whatsapp: clearWhatsapp ? null : whatsapp ?? this.whatsapp,
      position: position ?? this.position,
      coverage: coverage ?? this.coverage,
      logoAsset: clearLogoAsset ? null : logoAsset ?? this.logoAsset,
      verification: verification ?? this.verification,
      responseRate: responseRate ?? this.responseRate,
      pinned: pinned ?? this.pinned,
    );
  }
}

@immutable
class Property {
  const Property({
    required this.id,
    required this.brokerId,
    required this.kind,
    required this.transaction,
    required this.title,
    required this.price,
    required this.position,
    required this.neighbourhood,
    required this.createdAt,
    this.description = '',
    this.surface,
    this.rooms,
    this.photoAssets = const <String>[],
    this.status = PropertyStatus.available,
  });

  final String id;
  final String brokerId;
  final PropertyKind kind;
  final TransactionKind transaction;
  final String title;
  final String description;

  /// En francs CFA, entier : personne ne saisit de centimes ici.
  final int price;

  /// En mètres carrés.
  final int? surface;
  final int? rooms;
  final GeoPoint position;
  final String neighbourhood;
  final List<String> photoAssets;
  final PropertyStatus status;
  final DateTime createdAt;

  /// Un bien clos sort de la découverte mais reste dans la gestion du
  /// courtier.
  bool get isDiscoverable => status != PropertyStatus.closed;
}

@immutable
class Review {
  const Review({
    required this.id,
    required this.brokerId,
    required this.contactId,
    required this.rating,
    required this.createdAt,
    this.responsiveness,
    this.accuracy,
    this.courtesy,
    this.comment,
    this.moderation = ModerationStatus.pending,
    this.brokerReply,
  });

  final String id;
  final String brokerId;

  /// Le contact qui a rendu cet avis possible. C'est ce lien qui empêche les
  /// faux avis.
  final String contactId;

  /// De 1 à 5.
  final int rating;
  final int? responsiveness;
  final int? accuracy;
  final int? courtesy;
  final String? comment;
  final ModerationStatus moderation;
  final String? brokerReply;
  final DateTime createdAt;

  bool get isPublic => moderation == ModerationStatus.published;

  /// Copie modifiée. Même raison que [Broker.copyWith] : la réponse du
  /// courtier et la modération se posent sur un avis existant, sans en
  /// réécrire les notes.
  Review copyWith({
    ModerationStatus? moderation,
    String? brokerReply,
    bool clearBrokerReply = false,
  }) {
    return Review(
      id: id,
      brokerId: brokerId,
      contactId: contactId,
      rating: rating,
      createdAt: createdAt,
      responsiveness: responsiveness,
      accuracy: accuracy,
      courtesy: courtesy,
      comment: comment,
      moderation: moderation ?? this.moderation,
      brokerReply: clearBrokerReply ? null : brokerReply ?? this.brokerReply,
    );
  }
}

@immutable
class ContactLog {
  const ContactLog({
    required this.id,
    required this.brokerId,
    required this.channel,
    required this.createdAt,
    this.propertyId,
    this.outcome = ContactOutcome.attempted,
    this.reviewId,
  });

  final String id;
  final String brokerId;
  final String? propertyId;
  final ContactChannel channel;
  final ContactOutcome outcome;

  /// Rempli une fois l'avis donné : un contact n'ouvre qu'un seul avis.
  final String? reviewId;
  final DateTime createdAt;

  /// Un avis n'est possible qu'après un échange confirmé, et une seule fois.
  bool get allowsReview =>
      outcome == ContactOutcome.reached && reviewId == null;

  ContactLog copyWith({ContactOutcome? outcome, String? reviewId}) {
    return ContactLog(
      id: id,
      brokerId: brokerId,
      propertyId: propertyId,
      channel: channel,
      createdAt: createdAt,
      outcome: outcome ?? this.outcome,
      reviewId: reviewId ?? this.reviewId,
    );
  }
}

/// Un courtier accompagné de tout ce que la découverte doit afficher.
@immutable
class BrokerListing {
  const BrokerListing({
    required this.broker,
    required this.distanceMeters,
    required this.averageRating,
    required this.reviewCount,
    required this.availableProperties,
    required this.score,
  });

  final Broker broker;
  final double distanceMeters;
  final double averageRating;
  final int reviewCount;
  final int availableProperties;
  final double score;
}
