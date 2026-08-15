import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/property_description.dart';

/// Espace fine insécable : le séparateur de milliers français que
/// `NumberFormat('#,##0', 'fr')` produit. Écrit en clair pour que le test
/// échoue si la mise en forme des prix change, au lieu de suivre en silence.
const String nb = '\u202f';

PropertyDescriptionDraft draft({
  PropertyKind kind = PropertyKind.apartment,
  TransactionKind transaction = TransactionKind.rent,
  int price = 200000,
  int? surface,
  int? rooms,
  String neighbourhood = 'Médina',
}) {
  return PropertyDescriptionDraft(
    kind: kind,
    transaction: transaction,
    price: price,
    surface: surface,
    rooms: rooms,
    neighbourhood: neighbourhood,
  );
}

void main() {
  group('composition, type par transaction', () {
    test('appartement à louer', () {
      expect(
        PropertyDescriptionComposer.compose(
          draft(
            kind: PropertyKind.apartment,
            transaction: TransactionKind.rent,
            price: 425000,
            surface: 85,
            rooms: 3,
            neighbourhood: 'Mermoz',
          ),
        ),
        'Appartement à louer, quartier Mermoz. '
        '3 pièces, 85 m², 425${nb}000 F par mois.',
      );
    });

    test('appartement à vendre', () {
      expect(
        PropertyDescriptionComposer.compose(
          draft(
            kind: PropertyKind.apartment,
            transaction: TransactionKind.sale,
            price: 78000000,
            surface: 110,
            rooms: 4,
            neighbourhood: 'Point E',
          ),
        ),
        'Appartement à vendre, quartier Point E. '
        '4 pièces, 110 m², 78${nb}000${nb}000 F.',
      );
    });

    test('maison à louer', () {
      expect(
        PropertyDescriptionComposer.compose(
          draft(
            kind: PropertyKind.house,
            transaction: TransactionKind.rent,
            price: 350000,
            surface: 120,
            rooms: 4,
          ),
        ),
        'Maison à louer, quartier Médina. '
        '4 pièces, 120 m², 350${nb}000 F par mois.',
      );
    });

    test('maison à vendre', () {
      expect(
        PropertyDescriptionComposer.compose(
          draft(
            kind: PropertyKind.house,
            transaction: TransactionKind.sale,
            price: 31000000,
            surface: 150,
            rooms: 5,
            neighbourhood: 'Yeumbeul',
          ),
        ),
        'Maison à vendre, quartier Yeumbeul. '
        '5 pièces, 150 m², 31${nb}000${nb}000 F.',
      );
    });

    test('terrain à vendre', () {
      expect(
        PropertyDescriptionComposer.compose(
          draft(
            kind: PropertyKind.land,
            transaction: TransactionKind.sale,
            price: 9500000,
            surface: 200,
            neighbourhood: 'Keur Massar',
          ),
        ),
        'Terrain à vendre, quartier Keur Massar. 200 m², 9${nb}500${nb}000 F.',
      );
    });

    test('terrain à louer', () {
      expect(
        PropertyDescriptionComposer.compose(
          draft(
            kind: PropertyKind.land,
            transaction: TransactionKind.rent,
            price: 150000,
            surface: 300,
            neighbourhood: 'Parcelles Assainies',
          ),
        ),
        'Terrain à louer, quartier Parcelles Assainies. '
        '300 m², 150${nb}000 F par mois.',
      );
    });

    test('studio à louer', () {
      expect(
        PropertyDescriptionComposer.compose(
          draft(
            kind: PropertyKind.studio,
            transaction: TransactionKind.rent,
            price: 180000,
            surface: 32,
            rooms: 1,
            neighbourhood: 'Plateau',
          ),
        ),
        'Studio à louer, quartier Plateau. 32 m², 180${nb}000 F par mois.',
      );
    });

    test('studio à vendre', () {
      expect(
        PropertyDescriptionComposer.compose(
          draft(
            kind: PropertyKind.studio,
            transaction: TransactionKind.sale,
            price: 18000000,
            surface: 30,
            neighbourhood: 'Plateau',
          ),
        ),
        'Studio à vendre, quartier Plateau. 30 m², 18${nb}000${nb}000 F.',
      );
    });

    test('chambre à louer', () {
      expect(
        PropertyDescriptionComposer.compose(
          draft(
            kind: PropertyKind.room,
            transaction: TransactionKind.rent,
            price: 75000,
            surface: 16,
            rooms: 1,
            neighbourhood: 'Grand Dakar',
          ),
        ),
        'Chambre à louer, quartier Grand Dakar. 16 m², 75${nb}000 F par mois.',
      );
    });

    test('chambre à vendre', () {
      expect(
        PropertyDescriptionComposer.compose(
          draft(
            kind: PropertyKind.room,
            transaction: TransactionKind.sale,
            price: 4000000,
            surface: 20,
            neighbourhood: 'Grand Dakar',
          ),
        ),
        'Chambre à vendre, quartier Grand Dakar. 20 m², 4${nb}000${nb}000 F.',
      );
    });

    test('les dix combinaisons produisent une phrase complète et ponctuée', () {
      for (final PropertyKind kind in PropertyKind.values) {
        for (final TransactionKind transaction in TransactionKind.values) {
          final String text = PropertyDescriptionComposer.compose(
            draft(kind: kind, transaction: transaction, surface: 60, rooms: 2),
          );

          expect(text, endsWith('.'), reason: '$kind/$transaction');
          expect(text, isNot(contains('  ')), reason: '$kind/$transaction');
          expect(text, isNot(contains(' ,')), reason: '$kind/$transaction');
          expect(text, isNot(contains('..')), reason: '$kind/$transaction');
          expect(text, isNot(contains(', .')), reason: '$kind/$transaction');
        }
      }
    });
  });

  group('pièces', () {
    test('une seule pièce reste au singulier', () {
      expect(
        PropertyDescriptionComposer.compose(
          draft(kind: PropertyKind.apartment, rooms: 1, surface: 40),
        ),
        contains('1 pièce, 40 m²'),
      );
    });

    test('deux pièces passent au pluriel', () {
      expect(
        PropertyDescriptionComposer.compose(
          draft(kind: PropertyKind.apartment, rooms: 2, surface: 40),
        ),
        contains('2 pièces, 40 m²'),
      );
    });

    test('un terrain n\'annonce jamais de pièces, même si la donnée en a', () {
      final String text = PropertyDescriptionComposer.compose(
        draft(
          kind: PropertyKind.land,
          transaction: TransactionKind.sale,
          rooms: 3,
          surface: 300,
        ),
      );

      expect(text, isNot(contains('pièce')));
      expect(text, contains('300 m²'));
    });

    test('une chambre ne se répète pas « 1 pièce »', () {
      expect(
        PropertyDescriptionComposer.compose(
          draft(kind: PropertyKind.room, rooms: 1, surface: 16),
        ),
        isNot(contains('pièce')),
      );
    });

    test('un studio ne se répète pas « 1 pièce »', () {
      expect(
        PropertyDescriptionComposer.compose(
          draft(kind: PropertyKind.studio, rooms: 1, surface: 30),
        ),
        isNot(contains('pièce')),
      );
    });

    test('un studio à deux pièces le dit', () {
      expect(
        PropertyDescriptionComposer.compose(
          draft(kind: PropertyKind.studio, rooms: 2, surface: 40),
        ),
        contains('2 pièces'),
      );
    });

    test('zéro ou un nombre négatif de pièces ne sort pas', () {
      for (final int rooms in <int>[0, -3]) {
        expect(
          PropertyDescriptionComposer.compose(
            draft(kind: PropertyKind.house, rooms: rooms, surface: 90),
          ),
          isNot(contains('pièce')),
          reason: 'rooms=$rooms',
        );
      }
    });
  });

  group('champs manquants', () {
    test('surface absente : aucune clause en suspens', () {
      final String text = PropertyDescriptionComposer.compose(
        draft(kind: PropertyKind.house, rooms: 3, price: 300000),
      );

      expect(
        text,
        'Maison à louer, quartier Médina. '
        '3 pièces, 300${nb}000 F par mois.',
      );
      expect(text, isNot(contains('m²')));
    });

    test('pièces absentes : la phrase saute au chiffre suivant', () {
      expect(
        PropertyDescriptionComposer.compose(
          draft(kind: PropertyKind.house, surface: 90, price: 300000),
        ),
        'Maison à louer, quartier Médina. 90 m², 300${nb}000 F par mois.',
      );
    });

    test('ni surface ni pièces : il reste le prix', () {
      expect(
        PropertyDescriptionComposer.compose(
          draft(
            kind: PropertyKind.house,
            transaction: TransactionKind.sale,
            price: 31000000,
            neighbourhood: 'Yeumbeul',
          ),
        ),
        'Maison à vendre, quartier Yeumbeul. 31${nb}000${nb}000 F.',
      );
    });

    test('surface nulle ou négative est ignorée', () {
      for (final int surface in <int>[0, -12]) {
        expect(
          PropertyDescriptionComposer.compose(
            draft(kind: PropertyKind.land, surface: surface),
          ),
          isNot(contains('m²')),
          reason: 'surface=$surface',
        );
      }
    });

    test('prix pas encore saisi : aucune annonce à zéro franc', () {
      final String text = PropertyDescriptionComposer.compose(
        draft(kind: PropertyKind.house, price: 0, surface: 90, rooms: 3),
      );

      expect(text, 'Maison à louer, quartier Médina. 3 pièces, 90 m².');
      expect(text, isNot(contains(' F')));
    });

    test('quartier vide ou en blancs : pas d\'apposition vide', () {
      for (final String place in <String>['', '   ']) {
        expect(
          PropertyDescriptionComposer.compose(
            draft(kind: PropertyKind.room, neighbourhood: place, price: 75000),
          ),
          'Chambre à louer. 75${nb}000 F par mois.',
          reason: 'quartier="$place"',
        );
      }
    });

    test('quartier saisi avec des espaces de bord est nettoyé', () {
      expect(
        PropertyDescriptionComposer.compose(
          draft(neighbourhood: '  Ngor  ', price: 900000, surface: 140),
        ),
        startsWith('Appartement à louer, quartier Ngor.'),
      );
    });

    test('tout est absent sauf le minimum obligatoire', () {
      expect(
        PropertyDescriptionComposer.compose(
          draft(
            kind: PropertyKind.land,
            transaction: TransactionKind.sale,
            price: 0,
            neighbourhood: '',
          ),
        ),
        'Terrain à vendre.',
      );
    });
  });

  group('déterminisme', () {
    test('cent compositions de la même saisie sont identiques', () {
      final PropertyDescriptionDraft input = draft(
        kind: PropertyKind.house,
        transaction: TransactionKind.sale,
        price: 31000000,
        surface: 150,
        rooms: 5,
        neighbourhood: 'Yeumbeul',
      );
      final String first = PropertyDescriptionComposer.compose(input);

      for (int i = 0; i < 100; i++) {
        expect(PropertyDescriptionComposer.compose(input), first);
      }
    });

    test('deux brouillons égaux champ à champ donnent la même phrase', () {
      for (final PropertyKind kind in PropertyKind.values) {
        for (final TransactionKind transaction in TransactionKind.values) {
          expect(
            PropertyDescriptionComposer.compose(
              draft(
                kind: kind,
                transaction: transaction,
                surface: 80,
                rooms: 3,
              ),
            ),
            PropertyDescriptionComposer.compose(
              draft(
                kind: kind,
                transaction: transaction,
                surface: 80,
                rooms: 3,
              ),
            ),
            reason: '$kind/$transaction',
          );
        }
      }
    });
  });

  group('reconnaître une suggestion intacte', () {
    final Property property = Property(
      id: 'prp-001',
      brokerId: 'brk-moussa',
      kind: PropertyKind.house,
      transaction: TransactionKind.rent,
      title: 'Maison 4 pièces à Médina',
      price: 350000,
      surface: 120,
      rooms: 4,
      position: const GeoPoint(14.6790, -17.4510),
      neighbourhood: 'Médina',
      createdAt: DateTime.utc(2026, 7, 1),
      description: PropertyDescriptionComposer.compose(
        const PropertyDescriptionDraft(
          kind: PropertyKind.house,
          transaction: TransactionKind.rent,
          price: 350000,
          surface: 120,
          rooms: 4,
          neighbourhood: 'Médina',
        ),
      ),
    );

    test('la sortie du composeur est reconnue', () {
      expect(PropertyDescriptionComposer.isComposedFor(property), isTrue);
    });

    test('une description écrite à la main ne l\'est pas', () {
      expect(
        PropertyDescriptionComposer.isComposed(
          'Maison familiale avec cour, proche du marché.',
          PropertyDescriptionDraft.of(property),
        ),
        isFalse,
      );
    });

    test('une description vide ne l\'est pas', () {
      expect(
        PropertyDescriptionComposer.isComposed(
          '',
          PropertyDescriptionDraft.of(property),
        ),
        isFalse,
      );
    });

    test(
      'les espaces de bord et répétés ne comptent pas pour une retouche',
      () {
        final PropertyDescriptionDraft input = PropertyDescriptionDraft.of(
          property,
        );
        final String composed = PropertyDescriptionComposer.compose(input);

        expect(
          PropertyDescriptionComposer.isComposed('  $composed \n', input),
          isTrue,
        );
        expect(
          PropertyDescriptionComposer.isComposed(
            composed.replaceAll('. ', '.   '),
            input,
          ),
          isTrue,
        );
      },
    );

    test('un seul mot changé compte pour une retouche', () {
      final PropertyDescriptionDraft input = PropertyDescriptionDraft.of(
        property,
      );
      final String composed = PropertyDescriptionComposer.compose(input);

      expect(
        PropertyDescriptionComposer.isComposed(
          '$composed Eau et courant réguliers.',
          input,
        ),
        isFalse,
      );
      expect(
        PropertyDescriptionComposer.isComposed(
          composed.replaceAll('Maison', 'maison'),
          input,
        ),
        isFalse,
      );
    });

    test(
      'la suggestion d\'un autre brouillon n\'est pas celle de celui-ci',
      () {
        final String other = PropertyDescriptionComposer.compose(
          draft(
            kind: PropertyKind.house,
            price: 400000,
            surface: 120,
            rooms: 4,
          ),
        );

        expect(
          PropertyDescriptionComposer.isComposed(
            other,
            PropertyDescriptionDraft.of(property),
          ),
          isFalse,
        );
      },
    );

    test('composeFor et compose(of(...)) coïncident', () {
      expect(
        PropertyDescriptionComposer.composeFor(property),
        PropertyDescriptionComposer.compose(
          PropertyDescriptionDraft.of(property),
        ),
      );
    });
  });

  group('ce que le composeur ne dit pas', () {
    test('aucun agrément inventé', () {
      const List<String> invented = <String>[
        'cour',
        'balcon',
        'meublé',
        'lumineux',
        'calme',
        'proche',
        'marché',
        'eau',
        'courant',
        'étage',
      ];

      for (final PropertyKind kind in PropertyKind.values) {
        for (final TransactionKind transaction in TransactionKind.values) {
          final String text = PropertyDescriptionComposer.compose(
            draft(kind: kind, transaction: transaction, surface: 80, rooms: 3),
          ).toLowerCase();

          for (final String word in invented) {
            expect(
              text,
              isNot(contains(word)),
              reason: '$kind/$transaction ne doit pas dire « $word »',
            );
          }
        }
      }
    });
  });
}
