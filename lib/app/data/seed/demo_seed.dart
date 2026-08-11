import 'package:woutalma_keur/app/domain/entities.dart';

/// Jeu de démonstration déterministe.
///
/// Aucun aléatoire, aucune date « maintenant » : le même seed produit toujours
/// les mêmes écrans, sinon une capture de référence devient impossible à
/// comparer.
///
/// Il couvre volontairement les cas pénibles, pas seulement le cas nominal :
/// un courtier sans avis, un sans WhatsApp, un non vérifié, un épinglé, un
/// bien réservé, un bien clos, un avis en modération, un contact sans réponse.
class DemoSeed {
  const DemoSeed({DateTime? reference}) : _reference = reference;

  final DateTime? _reference;

  /// Date de référence à partir de laquelle tout est daté à rebours.
  ///
  /// Figée par défaut : une capture de référence prise aujourd'hui doit rester
  /// comparable dans six mois.
  DateTime get reference => _reference ?? DateTime.utc(2026, 7, 1, 9);

  /// Dakar, Plateau. Position du client en démonstration.
  static const GeoPoint clientPosition = GeoPoint(14.6690, -17.4380);

  DateTime _daysAgo(int days) => reference.subtract(Duration(days: days));

  List<Broker> brokers() => <Broker>[
    const Broker(
      id: 'brk-moussa',
      kind: BrokerKind.individual,
      name: 'Moussa Ndiaye',
      phone: '+221771234567',
      whatsapp: '+221771234567',
      position: GeoPoint(14.6712, -17.4395),
      coverage: <String>['Plateau', 'Médina', 'Fann'],
      verification: VerificationStatus.verified,
      responseRate: 0.92,
    ),
    const Broker(
      id: 'brk-teranga',
      kind: BrokerKind.agency,
      name: 'Agence Teranga Immo',
      phone: '+221338211234',
      whatsapp: '+221771112233',
      position: GeoPoint(14.6935, -17.4570),
      coverage: <String>['Sacré-Cœur', 'Mermoz', 'Point E'],
      verification: VerificationStatus.verified,
      responseRate: 0.78,
      pinned: true,
    ),
    const Broker(
      id: 'brk-fatou',
      kind: BrokerKind.individual,
      name: 'Fatou Sarr',
      phone: '+221775558899',
      // Pas de WhatsApp : le bouton doit disparaître, pas rester mort.
      position: GeoPoint(14.6805, -17.4462),
      coverage: <String>['Grand Dakar', 'Liberté 6'],
      verification: VerificationStatus.verified,
      responseRate: 0.61,
    ),
    const Broker(
      id: 'brk-ibrahima',
      kind: BrokerKind.individual,
      name: 'Ibrahima Diop',
      phone: '+221776667788',
      whatsapp: '+221776667788',
      position: GeoPoint(14.7448, -17.5098),
      coverage: <String>['Almadies', 'Ngor', 'Yoff'],
      // Profil non vérifié : le badge ne doit pas apparaître.
      responseRate: 0.35,
    ),
    const Broker(
      id: 'brk-awa',
      kind: BrokerKind.individual,
      name: 'Awa Bâ',
      phone: '+221773334455',
      whatsapp: '+221773334455',
      position: GeoPoint(14.7691, -17.3920),
      coverage: <String>['Parcelles Assainies', 'Yoff'],
      verification: VerificationStatus.pending,
      responseRate: 0.5,
    ),
    const Broker(
      id: 'brk-keur-massar',
      kind: BrokerKind.agency,
      name: 'Keur Massar Habitat',
      phone: '+221338990011',
      position: GeoPoint(14.7810, -17.3160),
      coverage: <String>['Keur Massar', 'Yeumbeul'],
      verification: VerificationStatus.verified,
      responseRate: 0.44,
    ),
  ];

  List<Property> properties() => <Property>[
    Property(
      id: 'prp-001',
      brokerId: 'brk-moussa',
      kind: PropertyKind.house,
      transaction: TransactionKind.rent,
      title: 'Maison 4 pièces à Médina',
      description: 'Maison familiale avec cour, proche du marché.',
      price: 350000,
      surface: 120,
      rooms: 4,
      position: const GeoPoint(14.6790, -17.4510),
      neighbourhood: 'Médina',
      createdAt: _daysAgo(4),
      photoAssets: const <String>[
        'demo:house:medina:front',
        'demo:room:medina:cour',
        'demo:house:medina:street',
      ],
    ),
    Property(
      id: 'prp-002',
      brokerId: 'brk-moussa',
      kind: PropertyKind.studio,
      transaction: TransactionKind.rent,
      title: 'Studio meublé au Plateau',
      price: 180000,
      surface: 32,
      rooms: 1,
      position: const GeoPoint(14.6668, -17.4342),
      neighbourhood: 'Plateau',
      createdAt: _daysAgo(9),
      status: PropertyStatus.reserved,
      photoAssets: const <String>[
        'demo:studio:plateau:room',
        'demo:studio:plateau:kitchen',
      ],
    ),
    Property(
      id: 'prp-003',
      brokerId: 'brk-teranga',
      kind: PropertyKind.apartment,
      transaction: TransactionKind.rent,
      title: 'Appartement 3 pièces à Mermoz',
      description: 'Deuxième étage, balcon, eau et courant réguliers.',
      price: 425000,
      surface: 85,
      rooms: 3,
      position: const GeoPoint(14.6952, -17.4611),
      neighbourhood: 'Mermoz',
      createdAt: _daysAgo(2),
      photoAssets: const <String>[
        'demo:apartment:mermoz:balcony',
        'demo:room:mermoz:salon',
        'demo:apartment:mermoz:street',
      ],
    ),
    Property(
      id: 'prp-004',
      brokerId: 'brk-teranga',
      kind: PropertyKind.apartment,
      transaction: TransactionKind.sale,
      title: 'Appartement à vendre, Point E',
      price: 78000000,
      surface: 110,
      rooms: 4,
      position: const GeoPoint(14.6889, -17.4640),
      neighbourhood: 'Point E',
      createdAt: _daysAgo(21),
      photoAssets: const <String>[
        'demo:apartment:pointe:front',
        'demo:room:pointe:salon',
      ],
    ),
    Property(
      id: 'prp-005',
      brokerId: 'brk-fatou',
      kind: PropertyKind.room,
      transaction: TransactionKind.rent,
      title: 'Chambre à Grand Dakar',
      price: 75000,
      surface: 16,
      rooms: 1,
      position: const GeoPoint(14.6821, -17.4455),
      neighbourhood: 'Grand Dakar',
      createdAt: _daysAgo(1),
      photoAssets: const <String>[
        'demo:room:grand-dakar:bed',
        'demo:room:grand-dakar:window',
      ],
    ),
    Property(
      id: 'prp-006',
      brokerId: 'brk-fatou',
      kind: PropertyKind.house,
      transaction: TransactionKind.rent,
      title: 'Maison 3 pièces à Liberté 6',
      price: 300000,
      surface: 95,
      rooms: 3,
      position: const GeoPoint(14.7115, -17.4602),
      neighbourhood: 'Liberté 6',
      createdAt: _daysAgo(30),
      // Déjà loué : doit disparaître de la découverte.
      status: PropertyStatus.closed,
      photoAssets: const <String>[
        'demo:house:liberte:front',
        'demo:room:liberte:salon',
      ],
    ),
    Property(
      id: 'prp-007',
      brokerId: 'brk-ibrahima',
      kind: PropertyKind.apartment,
      transaction: TransactionKind.rent,
      title: 'Appartement vue mer, Ngor',
      price: 900000,
      surface: 140,
      rooms: 4,
      position: const GeoPoint(14.7500, -17.5140),
      neighbourhood: 'Ngor',
      createdAt: _daysAgo(6),
      photoAssets: const <String>[
        'demo:apartment:ngor:coast',
        'demo:room:ngor:salon',
        'demo:apartment:ngor:balcony',
      ],
    ),
    Property(
      id: 'prp-008',
      brokerId: 'brk-awa',
      kind: PropertyKind.land,
      transaction: TransactionKind.sale,
      title: 'Terrain 300 m² aux Parcelles',
      price: 22000000,
      surface: 300,
      position: const GeoPoint(14.7702, -17.3955),
      neighbourhood: 'Parcelles Assainies',
      createdAt: _daysAgo(14),
      photoAssets: const <String>[
        'demo:land:parcelles:plot',
        'demo:land:parcelles:road',
      ],
    ),
    Property(
      id: 'prp-009',
      brokerId: 'brk-keur-massar',
      kind: PropertyKind.land,
      transaction: TransactionKind.sale,
      title: 'Terrain 200 m² à Keur Massar',
      price: 9500000,
      surface: 200,
      position: const GeoPoint(14.7822, -17.3188),
      neighbourhood: 'Keur Massar',
      createdAt: _daysAgo(11),
      photoAssets: const <String>[
        'demo:land:keur-massar:plot',
        'demo:land:keur-massar:access',
      ],
    ),
    Property(
      id: 'prp-010',
      brokerId: 'brk-keur-massar',
      kind: PropertyKind.house,
      transaction: TransactionKind.sale,
      title: 'Maison inachevée à Yeumbeul',
      price: 31000000,
      surface: 150,
      rooms: 5,
      position: const GeoPoint(14.7760, -17.3400),
      neighbourhood: 'Yeumbeul',
      createdAt: _daysAgo(45),
      photoAssets: const <String>[
        'demo:house:yeumbeul:unfinished',
        'demo:land:yeumbeul:yard',
      ],
    ),
  ];

  List<ContactLog> contacts() => <ContactLog>[
    ContactLog(
      id: 'ctc-001',
      brokerId: 'brk-moussa',
      propertyId: 'prp-001',
      channel: ContactChannel.call,
      outcome: ContactOutcome.reached,
      reviewId: 'rev-001',
      createdAt: _daysAgo(12),
    ),
    // Échange confirmé, aucun avis encore : c'est la ligne qui ouvre C05.
    ContactLog(
      id: 'ctc-002',
      brokerId: 'brk-teranga',
      propertyId: 'prp-003',
      channel: ContactChannel.whatsapp,
      outcome: ContactOutcome.reached,
      createdAt: _daysAgo(3),
    ),
    // Sans réponse : le journal reste, l'avis ne s'ouvre pas.
    ContactLog(
      id: 'ctc-003',
      brokerId: 'brk-ibrahima',
      channel: ContactChannel.call,
      outcome: ContactOutcome.noAnswer,
      createdAt: _daysAgo(2),
    ),
    // Canal ouvert, résultat pas encore déclaré.
    ContactLog(
      id: 'ctc-004',
      brokerId: 'brk-fatou',
      propertyId: 'prp-005',
      channel: ContactChannel.sms,
      createdAt: _daysAgo(1),
    ),
  ];

  List<Review> reviews() => <Review>[
    Review(
      id: 'rev-001',
      brokerId: 'brk-moussa',
      contactId: 'ctc-001',
      rating: 5,
      responsiveness: 5,
      accuracy: 5,
      courtesy: 5,
      comment: 'Très rapide, les informations correspondaient à la visite.',
      moderation: ModerationStatus.published,
      createdAt: _daysAgo(11),
    ),
    Review(
      id: 'rev-002',
      brokerId: 'brk-moussa',
      contactId: 'ctc-900',
      rating: 4,
      responsiveness: 4,
      accuracy: 4,
      courtesy: 5,
      moderation: ModerationStatus.published,
      createdAt: _daysAgo(25),
    ),
    Review(
      id: 'rev-003',
      brokerId: 'brk-moussa',
      contactId: 'ctc-901',
      rating: 5,
      moderation: ModerationStatus.published,
      createdAt: _daysAgo(40),
    ),
    Review(
      id: 'rev-004',
      brokerId: 'brk-teranga',
      contactId: 'ctc-902',
      rating: 4,
      comment: 'Bon accueil, un peu lent pour rappeler.',
      moderation: ModerationStatus.published,
      brokerReply: 'Merci, nous renforçons notre équipe téléphonique.',
      createdAt: _daysAgo(8),
    ),
    Review(
      id: 'rev-005',
      brokerId: 'brk-teranga',
      contactId: 'ctc-903',
      rating: 3,
      moderation: ModerationStatus.published,
      createdAt: _daysAgo(33),
    ),
    Review(
      id: 'rev-006',
      brokerId: 'brk-fatou',
      contactId: 'ctc-904',
      rating: 5,
      comment: 'Elle connaît très bien le quartier.',
      moderation: ModerationStatus.published,
      createdAt: _daysAgo(5),
    ),
    // En modération : invisible côté client, visible côté courtier.
    Review(
      id: 'rev-007',
      brokerId: 'brk-fatou',
      contactId: 'ctc-905',
      rating: 2,
      comment: 'Le prix annoncé n\'était pas le bon.',
      createdAt: _daysAgo(1),
    ),
    // Un seul avis à 5 : le classement ne doit pas le hisser devant les
    // profils établis.
    Review(
      id: 'rev-008',
      brokerId: 'brk-awa',
      contactId: 'ctc-906',
      rating: 5,
      moderation: ModerationStatus.published,
      createdAt: _daysAgo(7),
    ),
  ];
}
