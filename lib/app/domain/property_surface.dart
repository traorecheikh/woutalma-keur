import 'package:flutter/foundation.dart';
import 'package:woutalma_keur/app/domain/entities.dart';

/// Une tranche du barème : « jusqu'à [upTo] mètres carrés, on avance de
/// [step] en [step] ».
@immutable
class SurfaceBand {
  const SurfaceBand({required this.upTo, required this.step})
    : assert(step > 0, 'Un pas nul ou négatif ne produit aucune valeur.'),
      assert(upTo > 0, 'Une borne haute nulle ou négative ne vaut rien.');

  /// Borne haute incluse.
  final int upTo;

  /// Écart entre deux valeurs proposées dans cette tranche.
  final int step;
}

/// Barème de surfaces d'un type de bien.
///
/// Le formulaire courtier B03 remplace la saisie libre au clavier par un choix
/// dans une liste. La raison est celle de tout l'écran : la cible tape mal, et
/// un « 1 20 » ou un « 1200 » au lieu de « 120 » publie une annonce fausse que
/// personne ne relit. Un choix ne peut pas produire une surface impossible.
@immutable
class SurfaceScale {
  const SurfaceScale({required this.minimum, required this.bands});

  /// Plus petite valeur proposée. C'est aussi le plancher du premier pas.
  final int minimum;

  /// Tranches successives, du plus fin au plus grossier. La borne haute de
  /// chacune sert de plancher à la suivante.
  final List<SurfaceBand> bands;

  int get smallest => minimum;
  int get largest => bands.last.upTo;

  /// Les valeurs du barème, croissantes et sans doublon.
  ///
  /// Recalculées à chaque appel : la liste la plus longue fait quarante et
  /// quelques entiers, et un cache mutable dans le domaine coûterait plus cher
  /// à raisonner qu'à recalculer.
  List<int> values() {
    final List<int> result = <int>[minimum];
    int current = minimum;
    for (final SurfaceBand band in bands) {
      while (current + band.step <= band.upTo) {
        current += band.step;
        result.add(current);
      }
      // Une tranche dont la borne ne tombe pas juste sur le pas s'arrête
      // avant : la suivante repart de là où on en est, jamais de sa propre
      // borne, sinon un trou apparaît au raccord.
    }
    return result;
  }

  bool contains(int surface) => values().contains(surface);
}

/// Les surfaces proposées à la saisie, par type de bien.
///
/// Une chambre, un appartement et un terrain ne se mesurent pas à la même
/// échelle : proposer le même barème aux trois obligerait soit à faire défiler
/// deux cents lignes pour une chambre de seize mètres carrés, soit à sauter de
/// cent en cent sur un terrain. Le barème dépend donc du type — c'est la
/// réponse honnête, pas une complication.
///
/// Les paliers viennent de ce qui se loue et se vend réellement à Dakar :
/// chambres de six à trente mètres carrés, studios jusqu'à la quarantaine,
/// appartements autour de quatre-vingts à cent vingt, maisons de cent à
/// quelques centaines, et pour les terrains les formats de lotissement
/// courants — 150, 200, 225, 300, 400, 450, 500 m² — que le pas de 25 couvre
/// tous. Au-delà, l'écart s'élargit : personne ne distingue un terrain de
/// 3 000 m² d'un de 3 050 m², et l'exactitude au mètre près y est fausse.
abstract final class PropertySurfaceCatalogue {
  /// Chambre : ce qui se loue vraiment, d'une pièce de six mètres carrés à
  /// une grande chambre de trente. Pas de 2 : à cette échelle, cinq mètres
  /// carrés d'écart changent la nature du bien.
  static const SurfaceScale room = SurfaceScale(
    minimum: 6,
    bands: <SurfaceBand>[SurfaceBand(upTo: 30, step: 2)],
  );

  /// Studio : même finesse jusqu'à quarante, puis pas de 5. Au-delà de
  /// soixante, ce n'est plus un studio mais un appartement, et le courtier
  /// devrait changer de type plutôt que de forcer la surface.
  static const SurfaceScale studio = SurfaceScale(
    minimum: 12,
    bands: <SurfaceBand>[
      SurfaceBand(upTo: 40, step: 2),
      SurfaceBand(upTo: 60, step: 5),
    ],
  );

  /// Appartement : pas de 5 sur la zone dense — la quasi-totalité du parc
  /// dakarois tient entre 40 et 120 m² — puis pas de 10 pour les grands.
  static const SurfaceScale apartment = SurfaceScale(
    minimum: 25,
    bands: <SurfaceBand>[
      SurfaceBand(upTo: 120, step: 5),
      SurfaceBand(upTo: 250, step: 10),
    ],
  );

  /// Maison : pas de 10 jusqu'à 200, puis 25, puis 50. Une maison se décrit
  /// par son nombre de pièces bien plus que par ses mètres carrés exacts.
  static const SurfaceScale house = SurfaceScale(
    minimum: 50,
    bands: <SurfaceBand>[
      SurfaceBand(upTo: 200, step: 10),
      SurfaceBand(upTo: 400, step: 25),
      SurfaceBand(upTo: 600, step: 50),
    ],
  );

  /// Terrain : c'est l'échelle la plus étalée. Le pas de 25 jusqu'à 500 couvre
  /// les formats de lotissement, puis l'écart s'ouvre jusqu'à l'hectare. Le
  /// plafond à 10 000 m² est assumé : au-delà on quitte le foncier urbain que
  /// cette application couvre.
  static const SurfaceScale land = SurfaceScale(
    minimum: 100,
    bands: <SurfaceBand>[
      SurfaceBand(upTo: 500, step: 25),
      SurfaceBand(upTo: 1000, step: 50),
      SurfaceBand(upTo: 2500, step: 250),
      SurfaceBand(upTo: 5000, step: 500),
      SurfaceBand(upTo: 10000, step: 1000),
    ],
  );

  static SurfaceScale scaleFor(PropertyKind kind) {
    return switch (kind) {
      PropertyKind.apartment => apartment,
      PropertyKind.house => house,
      PropertyKind.land => land,
      PropertyKind.studio => studio,
      PropertyKind.room => room,
    };
  }

  /// Les surfaces à proposer pour [kind].
  ///
  /// [include] insère une valeur hors barème sans la déplacer : un bien déjà
  /// publié à 95 m² doit se rouvrir sur 95, pas être ramené en silence à 90 ou
  /// 100. Arrondir la donnée de quelqu'un d'autre pour qu'elle entre dans une
  /// liste, c'est publier un chiffre qu'il n'a pas écrit.
  ///
  /// Une valeur hors bornes est insérée elle aussi : la liste s'étend plutôt
  /// que d'effacer la saisie.
  static List<int> valuesFor(PropertyKind kind, {int? include}) {
    final List<int> values = scaleFor(kind).values();
    if (include == null || include <= 0 || values.contains(include)) {
      return values;
    }
    final int at = values.indexWhere((int value) => value > include);
    return <int>[...values]..insert(at < 0 ? values.length : at, include);
  }
}

/// Vrai si un nombre de pièces a un sens pour ce type de bien.
///
/// Un terrain n'a pas de pièces. Le champ ne doit pas seulement être vide : il
/// ne doit pas exister, sinon quelqu'un finira par y écrire un chiffre qui
/// sera affiché.
bool propertyKindHasRooms(PropertyKind kind) => kind != PropertyKind.land;
