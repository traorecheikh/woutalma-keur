import 'package:flutter/foundation.dart';
import 'package:woutalma_keur/app/data/local/cache_meta_store.dart';
import 'package:woutalma_keur/app/data/seed/demo_seed.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/location_service.dart';
import 'package:woutalma_keur/app/domain/ranking.dart';

/// D'où l'on cherche.
///
/// Avant, `AppDependencies.clientPosition` était un simple champ que **rien**
/// n'assignait jamais : le service de géolocalisation existait, fonctionnait,
/// et son résultat n'atteignait aucun écran. Toute recherche partait donc du
/// Plateau, quelle que soit la position réelle.
///
/// Notifiable, parce que C01 vit dans un `StatefulShellRoute` : la position
/// arrive après le premier rendu, et l'écran déjà construit doit reclasser
/// ses résultats sans être reconstruit.
class ClientPositionController extends ChangeNotifier {
  ClientPositionController({
    required LocationService location,
    required CacheMetaStore meta,
    GeoPoint fallback = DemoSeed.clientPosition,
    bool primed = false,
  }) : _location = location,
       _meta = meta,
       _position = fallback,
       _hasBeenPrimed = primed;

  final LocationService _location;
  final CacheMetaStore _meta;

  GeoPoint _position;
  String? _placeName;
  bool _isFromGps = false;
  bool _isOutsideServiceArea = false;
  bool _hasBeenPrimed;

  /// Au-delà, le téléphone n'est pas à Dakar : classer six courtiers à
  /// 4 000 km n'aide personne, on repart du centre-ville.
  static const double serviceAreaRadiusMeters = 120000;

  /// Jamais nulle : sans GPS ni choix manuel, on part du centre de Dakar,
  /// pour que les distances affichées veuillent dire quelque chose.
  GeoPoint get position => _position;

  /// Quartier choisi à la main. `null` tant que rien n'a été choisi — la barre
  /// affiche alors « Près de vous ».
  String? get placeName => _placeName;

  bool get isFromGps => _isFromGps;

  /// Le GPS a répondu, mais loin de la zone couverte. La recherche part de
  /// Dakar et la barre le dit, au lieu d'annoncer « près de vous ».
  bool get isOutsideServiceArea => _isOutsideServiceArea;

  /// L'explication de la permission a déjà été montrée une fois.
  ///
  /// Persistée : `docs/screen-contracts/client-discovery.md` interdit toute
  /// boucle de permission, donc un refus ne doit jamais être redemandé au
  /// lancement suivant. Le bouton GPS de M02 reste la porte d'entrée manuelle.
  bool get hasBeenPrimed => _hasBeenPrimed;

  Future<void> restore() async {
    _hasBeenPrimed =
        await _meta.read(CacheMetaStore.locationPrimedKey) == 'true';
  }

  Future<void> markPrimed() async {
    if (_hasBeenPrimed) {
      return;
    }
    _hasBeenPrimed = true;
    await _meta.write(CacheMetaStore.locationPrimedKey, 'true');
  }

  /// Demande la position au système. L'appelant a déjà expliqué pourquoi.
  Future<LocationResult> locate() async {
    final LocationResult result = await _location.current();
    if (result is LocationFound) {
      final bool outside =
          distanceMeters(DemoSeed.clientPosition, result.position) >
          serviceAreaRadiusMeters;
      _position = outside ? DemoSeed.clientPosition : result.position;
      _isFromGps = !outside;
      _isOutsideServiceArea = outside;
      // Le nom retombe à null : on est « près de vous », pas dans un quartier
      // nommé, et afficher l'ancien quartier serait faux.
      _placeName = null;
      notifyListeners();
    }
    return result;
  }

  /// Relit la position à chaque lancement, mais seulement si l'autorisation
  /// est déjà accordée.
  ///
  /// Sans cela, l'amorçage n'ayant lieu qu'une fois dans la vie de
  /// l'installation, la position resterait figée à sa valeur de repli à tous
  /// les lancements suivants — le GPS aurait été demandé une fois puis jamais
  /// relu. Aucun dialogue ici : on vérifie, on ne redemande pas.
  Future<void> refreshIfPermitted() async {
    if (await _location.hasPermission()) {
      await locate();
    }
  }

  /// Ouvre les réglages système. Proposé seulement après un refus définitif.
  Future<void> openSettings() => _location.openSettings();

  /// Choix manuel. Il l'emporte sur le GPS : c'est une intention explicite.
  void moveTo(Neighbourhood place) {
    if (_placeName == place.name && !_isFromGps) {
      return;
    }
    _position = place.position;
    _placeName = place.name;
    _isFromGps = false;
    _isOutsideServiceArea = false;
    notifyListeners();
  }
}
