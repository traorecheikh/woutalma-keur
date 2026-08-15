import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/property_surface.dart';

void main() {
  group('forme du barème', () {
    test('chaque type a un barème non vide, croissant et sans doublon', () {
      for (final PropertyKind kind in PropertyKind.values) {
        final List<int> values = PropertySurfaceCatalogue.valuesFor(kind);

        expect(values, isNotEmpty, reason: '$kind');
        expect(values.toSet().length, values.length, reason: '$kind doublon');
        expect(
          values,
          orderedEquals(<int>[...values]..sort()),
          reason: '$kind désordonné',
        );
        expect(values.first, greaterThan(0), reason: '$kind');
      }
    });

    test('les tranches se raccordent sans trou ni recul', () {
      for (final PropertyKind kind in PropertyKind.values) {
        final SurfaceScale scale = PropertySurfaceCatalogue.scaleFor(kind);
        final List<int> values = scale.values();
        final int coarsest = scale.bands
            .map((SurfaceBand band) => band.step)
            .reduce((int a, int b) => a > b ? a : b);

        for (int i = 1; i < values.length; i++) {
          final int gap = values[i] - values[i - 1];
          expect(gap, greaterThan(0), reason: '$kind à ${values[i]}');
          expect(gap, lessThanOrEqualTo(coarsest), reason: '$kind trou');
        }
        expect(values.first, scale.smallest, reason: '$kind');
        expect(values.last, lessThanOrEqualTo(scale.largest), reason: '$kind');
      }
    });

    test('une liste reste parcourable au pouce', () {
      // Ce barème remplace un clavier : s'il faut faire défiler cent lignes,
      // la saisie libre était moins pénible.
      for (final PropertyKind kind in PropertyKind.values) {
        expect(
          PropertySurfaceCatalogue.valuesFor(kind).length,
          lessThanOrEqualTo(50),
          reason: '$kind',
        );
      }
    });

    test('deux appels donnent la même liste', () {
      for (final PropertyKind kind in PropertyKind.values) {
        expect(
          PropertySurfaceCatalogue.valuesFor(kind),
          orderedEquals(PropertySurfaceCatalogue.valuesFor(kind)),
          reason: '$kind',
        );
      }
    });
  });

  group('les échelles sont bien différentes', () {
    test('une chambre ne se mesure pas comme un terrain', () {
      expect(
        PropertySurfaceCatalogue.room.largest,
        lessThan(PropertySurfaceCatalogue.studio.largest),
      );
      expect(
        PropertySurfaceCatalogue.studio.largest,
        lessThan(PropertySurfaceCatalogue.apartment.largest),
      );
      expect(
        PropertySurfaceCatalogue.apartment.largest,
        lessThan(PropertySurfaceCatalogue.house.largest),
      );
      expect(
        PropertySurfaceCatalogue.house.largest,
        lessThan(PropertySurfaceCatalogue.land.largest),
      );
    });

    test('le plancher monte avec le type de bien', () {
      expect(PropertySurfaceCatalogue.room.smallest, 6);
      expect(PropertySurfaceCatalogue.studio.smallest, 12);
      expect(PropertySurfaceCatalogue.apartment.smallest, 25);
      expect(PropertySurfaceCatalogue.house.smallest, 50);
      expect(PropertySurfaceCatalogue.land.smallest, 100);
    });

    test('scaleFor rend bien le barème du type', () {
      expect(
        PropertySurfaceCatalogue.scaleFor(PropertyKind.room),
        same(PropertySurfaceCatalogue.room),
      );
      expect(
        PropertySurfaceCatalogue.scaleFor(PropertyKind.studio),
        same(PropertySurfaceCatalogue.studio),
      );
      expect(
        PropertySurfaceCatalogue.scaleFor(PropertyKind.apartment),
        same(PropertySurfaceCatalogue.apartment),
      );
      expect(
        PropertySurfaceCatalogue.scaleFor(PropertyKind.house),
        same(PropertySurfaceCatalogue.house),
      );
      expect(
        PropertySurfaceCatalogue.scaleFor(PropertyKind.land),
        same(PropertySurfaceCatalogue.land),
      );
    });
  });

  group('valeurs de terrain courantes à Dakar', () {
    test('les formats de lotissement usuels sont proposés', () {
      final List<int> values = PropertySurfaceCatalogue.valuesFor(
        PropertyKind.land,
      );

      for (final int plot in <int>[150, 200, 225, 300, 400, 450, 500]) {
        expect(values, contains(plot), reason: 'terrain de $plot m²');
      }
    });

    test('un hectare reste atteignable', () {
      expect(
        PropertySurfaceCatalogue.valuesFor(PropertyKind.land),
        contains(10000),
      );
    });
  });

  group('les biens du jeu de démonstration entrent dans le barème', () {
    test('surfaces déjà publiées, sauf celles qui demandent include', () {
      expect(
        PropertySurfaceCatalogue.scaleFor(PropertyKind.room).contains(16),
        isTrue,
      );
      expect(
        PropertySurfaceCatalogue.scaleFor(PropertyKind.studio).contains(32),
        isTrue,
      );
      for (final int surface in <int>[85, 110, 140]) {
        expect(
          PropertySurfaceCatalogue.scaleFor(
            PropertyKind.apartment,
          ).contains(surface),
          isTrue,
          reason: 'appartement de $surface m²',
        );
      }
      for (final int surface in <int>[120, 150]) {
        expect(
          PropertySurfaceCatalogue.scaleFor(
            PropertyKind.house,
          ).contains(surface),
          isTrue,
          reason: 'maison de $surface m²',
        );
      }
      for (final int surface in <int>[200, 300]) {
        expect(
          PropertySurfaceCatalogue.scaleFor(
            PropertyKind.land,
          ).contains(surface),
          isTrue,
          reason: 'terrain de $surface m²',
        );
      }
    });

    test('une maison de 95 m² tombe hors barème et doit être conservée', () {
      expect(
        PropertySurfaceCatalogue.scaleFor(PropertyKind.house).contains(95),
        isFalse,
      );
      expect(
        PropertySurfaceCatalogue.valuesFor(PropertyKind.house, include: 95),
        contains(95),
      );
    });
  });

  group('include', () {
    test('insère une valeur hors barème à sa place, sans rien perdre', () {
      final List<int> plain = PropertySurfaceCatalogue.valuesFor(
        PropertyKind.house,
      );
      final List<int> withValue = PropertySurfaceCatalogue.valuesFor(
        PropertyKind.house,
        include: 95,
      );

      expect(withValue.length, plain.length + 1);
      expect(withValue, containsAll(plain));
      expect(withValue, orderedEquals(<int>[...withValue]..sort()));
      expect(withValue[withValue.indexOf(95) - 1], 90);
      expect(withValue[withValue.indexOf(95) + 1], 100);
    });

    test('une valeur déjà présente ne se duplique pas', () {
      expect(
        PropertySurfaceCatalogue.valuesFor(PropertyKind.house, include: 100),
        orderedEquals(PropertySurfaceCatalogue.valuesFor(PropertyKind.house)),
      );
    });

    test('une valeur sous le plancher étend la liste par le bas', () {
      final List<int> values = PropertySurfaceCatalogue.valuesFor(
        PropertyKind.house,
        include: 32,
      );

      expect(values.first, 32);
      expect(values[1], PropertySurfaceCatalogue.house.smallest);
    });

    test('une valeur au-dessus du plafond étend la liste par le haut', () {
      final List<int> values = PropertySurfaceCatalogue.valuesFor(
        PropertyKind.land,
        include: 25000,
      );

      expect(values.last, 25000);
    });

    test('null, zéro et négatif ne changent rien', () {
      final List<int> plain = PropertySurfaceCatalogue.valuesFor(
        PropertyKind.apartment,
      );

      for (final int? value in <int?>[null, 0, -40]) {
        expect(
          PropertySurfaceCatalogue.valuesFor(
            PropertyKind.apartment,
            include: value,
          ),
          orderedEquals(plain),
          reason: 'include=$value',
        );
      }
    });
  });

  group('pièces par type', () {
    test('un terrain n\'a pas de pièces, les autres si', () {
      expect(propertyKindHasRooms(PropertyKind.land), isFalse);
      for (final PropertyKind kind in PropertyKind.values) {
        if (kind == PropertyKind.land) {
          continue;
        }
        expect(propertyKindHasRooms(kind), isTrue, reason: '$kind');
      }
    });
  });
}
