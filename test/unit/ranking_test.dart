import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/ranking.dart';

void main() {
  const RankingService ranking = RankingService();

  group('distance', () {
    test('mesure une distance connue de Dakar', () {
      // Plateau → Almadies, environ 11 km à vol d'oiseau.
      const GeoPoint plateau = GeoPoint(14.6690, -17.4380);
      const GeoPoint almadies = GeoPoint(14.7450, -17.5100);

      final double meters = distanceMeters(plateau, almadies);

      expect(meters, greaterThan(10000));
      expect(meters, lessThan(12500));
    });

    test('un point avec lui-même vaut zéro', () {
      const GeoPoint p = GeoPoint(14.69, -17.44);
      expect(distanceMeters(p, p), closeTo(0, 0.001));
    });

    test('la distance est symétrique', () {
      const GeoPoint a = GeoPoint(14.69, -17.44);
      const GeoPoint b = GeoPoint(14.72, -17.47);

      expect(distanceMeters(a, b), closeTo(distanceMeters(b, a), 0.001));
    });
  });

  group('note bayésienne', () {
    test('un seul avis à 5 ne bat pas cinquante avis à 4,5', () {
      // Le cas qui casse tous les classements naïfs.
      final double newcomer = ranking.score(
        averageRating: 5,
        reviewCount: 1,
        distanceInMeters: 1000,
        responseRate: 0.5,
      );
      final double established = ranking.score(
        averageRating: 4.5,
        reviewCount: 50,
        distanceInMeters: 1000,
        responseRate: 0.5,
      );

      expect(established, greaterThan(newcomer));
    });

    test('sans avis, on est ramené à la moyenne globale', () {
      expect(ranking.bayesianRating(0, 0), 3.5);
    });

    test('avec beaucoup d\'avis, la note propre l\'emporte', () {
      final double value = ranking.bayesianRating(4.8, 500);
      expect(value, greaterThan(4.7));
    });
  });

  group('proximité', () {
    test('décroît sans falaise', () {
      final double near = ranking.proximityFactor(500);
      final double mid = ranking.proximityFactor(2000);
      final double far = ranking.proximityFactor(20000);

      expect(near, greaterThan(mid));
      expect(mid, greaterThan(far));
      // À la demi-vie, exactement la moitié du maximum.
      expect(mid, closeTo(0.5, 0.001));
      // Loin ne veut pas dire exclu.
      expect(far, greaterThan(0));
    });

    test('à égalité de note, le plus proche passe devant', () {
      final double close = ranking.score(
        averageRating: 4,
        reviewCount: 20,
        distanceInMeters: 300,
        responseRate: 0.8,
      );
      final double distant = ranking.score(
        averageRating: 4,
        reviewCount: 20,
        distanceInMeters: 9000,
        responseRate: 0.8,
      );

      expect(close, greaterThan(distant));
    });
  });

  group('tri', () {
    BrokerListing listing(
      String id, {
      required double score,
      double distance = 1000,
      bool pinned = false,
    }) {
      return BrokerListing(
        broker: Broker(
          id: id,
          kind: BrokerKind.individual,
          name: id,
          phone: '+221770000000',
          position: const GeoPoint(14.69, -17.44),
          coverage: const <String>[],
          pinned: pinned,
        ),
        distanceMeters: distance,
        averageRating: 4,
        reviewCount: 10,
        availableProperties: 2,
        score: score,
      );
    }

    test('classe par score décroissant', () {
      final List<BrokerListing> sorted = ranking.sort(<BrokerListing>[
        listing('b', score: 0.4),
        listing('a', score: 0.9),
        listing('c', score: 0.6),
      ]);

      expect(sorted.map((BrokerListing l) => l.broker.id), <String>[
        'a',
        'c',
        'b',
      ]);
    });

    test('un profil épinglé remonte sans perdre son score', () {
      final List<BrokerListing> sorted = ranking.sort(<BrokerListing>[
        listing('organique', score: 0.9),
        listing('épinglé', score: 0.2, pinned: true),
      ]);

      expect(sorted.first.broker.id, 'épinglé');
      // Le score n'est pas maquillé : l'écran doit pouvoir le signaler.
      expect(sorted.first.score, 0.2);
    });

    test('à score égal, l\'ordre reste déterministe', () {
      final List<BrokerListing> first = ranking.sort(<BrokerListing>[
        listing('z', score: 0.5, distance: 500),
        listing('a', score: 0.5, distance: 500),
      ]);
      final List<BrokerListing> second = ranking.sort(<BrokerListing>[
        listing('a', score: 0.5, distance: 500),
        listing('z', score: 0.5, distance: 500),
      ]);

      expect(
        first.map((BrokerListing l) => l.broker.id),
        second.map((BrokerListing l) => l.broker.id),
      );
    });
  });
}
