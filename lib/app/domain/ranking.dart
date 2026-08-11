import 'dart:math' as math;

import 'package:woutalma_keur/app/domain/entities.dart';

/// Distance à vol d'oiseau, en mètres.
///
/// Haversine, pas d'index géospatial : sur quelques centaines de courtiers en
/// mémoire c'est instantané, et l'interface de dépôt reste la même le jour où
/// PostGIS s'en charge côté serveur.
double distanceMeters(GeoPoint a, GeoPoint b) {
  const double earthRadius = 6371000;
  final double dLat = _radians(b.latitude - a.latitude);
  final double dLon = _radians(b.longitude - a.longitude);
  final double lat1 = _radians(a.latitude);
  final double lat2 = _radians(b.latitude);

  final double h =
      math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.sin(dLon / 2) * math.sin(dLon / 2) * math.cos(lat1) * math.cos(lat2);

  return 2 * earthRadius * math.asin(math.min(1, math.sqrt(h)));
}

double _radians(double degrees) => degrees * math.pi / 180;

/// Calcule le score de classement d'un courtier.
///
/// Quatre facteurs, tous ramenés entre 0 et 1 :
/// note bayésienne, proximité, volume d'avis, taux de réponse.
class RankingService {
  const RankingService({
    this.ratingWeight = 0.45,
    this.proximityWeight = 0.25,
    this.volumeWeight = 0.15,
    this.responseWeight = 0.15,
    this.confidenceThreshold = 5,
    this.globalAverage = 3.5,
    this.proximityHalfLifeMeters = 2000,
    this.volumeSaturation = 50,
  });

  final double ratingWeight;
  final double proximityWeight;
  final double volumeWeight;
  final double responseWeight;

  /// Nombre d'avis à partir duquel la note propre pèse autant que la moyenne
  /// globale. C'est ce qui empêche « un seul avis à 5 étoiles » de dominer.
  final int confidenceThreshold;

  /// Moyenne vers laquelle un profil peu noté est ramené.
  final double globalAverage;

  /// Distance à laquelle le facteur de proximité vaut la moitié de son
  /// maximum. Une décroissance douce, pas une falaise : à 2,1 km on ne
  /// disparaît pas.
  final double proximityHalfLifeMeters;

  /// Volume d'avis au-delà duquel le facteur cesse de croître.
  final int volumeSaturation;

  /// Moyenne bayésienne : tire la note vers la moyenne globale tant que les
  /// avis sont peu nombreux.
  double bayesianRating(double average, int count) {
    if (count <= 0) {
      return globalAverage;
    }
    final double weight = count / (count + confidenceThreshold);
    return weight * average + (1 - weight) * globalAverage;
  }

  double proximityFactor(double meters) {
    if (meters <= 0) {
      return 1;
    }
    return 1 / (1 + meters / proximityHalfLifeMeters);
  }

  double volumeFactor(int count) {
    if (count <= 0) {
      return 0;
    }
    return math.min(1, math.log(1 + count) / math.log(1 + volumeSaturation));
  }

  /// Score final, entre 0 et 1.
  double score({
    required double averageRating,
    required int reviewCount,
    required double distanceInMeters,
    required double responseRate,
  }) {
    final double rating = bayesianRating(averageRating, reviewCount) / 5;
    return ratingWeight * rating +
        proximityWeight * proximityFactor(distanceInMeters) +
        volumeWeight * volumeFactor(reviewCount) +
        responseWeight * responseRate.clamp(0, 1);
  }

  /// Trie une liste déjà calculée. Les profils épinglés remontent, mais gardent
  /// leur score : l'affichage doit les signaler, jamais les déguiser en
  /// premier résultat organique.
  List<BrokerListing> sort(List<BrokerListing> listings) {
    final List<BrokerListing> sorted = List<BrokerListing>.of(listings)
      ..sort((BrokerListing a, BrokerListing b) {
        if (a.broker.pinned != b.broker.pinned) {
          return a.broker.pinned ? -1 : 1;
        }
        final int byScore = b.score.compareTo(a.score);
        if (byScore != 0) {
          return byScore;
        }
        // Départage stable : le plus proche, puis l'identifiant, pour qu'un
        // même jeu de données produise toujours le même ordre.
        final int byDistance = a.distanceMeters.compareTo(b.distanceMeters);
        return byDistance != 0
            ? byDistance
            : a.broker.id.compareTo(b.broker.id);
      });
    return sorted;
  }
}
