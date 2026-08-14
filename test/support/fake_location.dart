import 'package:woutalma_keur/app/core/location/client_position_controller.dart';
import 'package:woutalma_keur/app/data/local/cache_meta_store.dart';
import 'package:woutalma_keur/app/data/seed/demo_seed.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/location_service.dart';

/// Service de position scriptable.
///
/// [calls] compte les demandes réelles au système : c'est ce qui permet de
/// vérifier que l'explication M06 vient **avant** le dialogue, et qu'un refus
/// ne relance rien.
class FakeLocationService implements LocationService {
  FakeLocationService({
    this.result = const LocationFound(DemoSeed.clientPosition),
  });

  LocationResult result;
  int calls = 0;
  int settingsOpened = 0;

  @override
  Future<LocationResult> current() async {
    calls++;
    return result;
  }

  @override
  Future<void> openSettings() async => settingsOpened++;

  @override
  List<Neighbourhood> knownNeighbourhoods() => dakarNeighbourhoods;
}

/// Contrôleur de position prêt à l'emploi, sans base ni canal de plateforme.
///
/// `primed` vaut vrai par défaut : l'explication M06 est un événement de
/// premier lancement, et un écran monté pour tester autre chose ne doit pas
/// ouvrir une feuille de permission par surprise. Les tests qui portent
/// justement sur l'amorçage passent `primed: false`.
ClientPositionController fakePositions({
  LocationService? location,
  CacheMetaStore? meta,
  GeoPoint fallback = DemoSeed.clientPosition,
  bool primed = true,
}) {
  return ClientPositionController(
    location: location ?? FakeLocationService(),
    meta: meta ?? InMemoryCacheMetaStore(),
    fallback: fallback,
    primed: primed,
  );
}
