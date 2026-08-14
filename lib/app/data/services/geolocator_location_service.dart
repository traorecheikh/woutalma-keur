import 'package:geolocator/geolocator.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/location_service.dart';

/// Position réelle du téléphone.
///
/// La permission est demandée **au moment où on s'en sert**, jamais au
/// démarrage : une autorisation réclamée sans contexte se refuse.
class GeolocatorLocationService implements LocationService {
  const GeolocatorLocationService();

  @override
  List<Neighbourhood> knownNeighbourhoods() => dakarNeighbourhoods;

  @override
  Future<void> openSettings() async {
    await Geolocator.openAppSettings();
  }

  @override
  Future<bool> hasPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return false;
    }
    final LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  @override
  Future<LocationResult> current() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return const LocationRefused(LocationRefusal.unavailable);
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    switch (permission) {
      case LocationPermission.denied:
        return const LocationRefused(LocationRefusal.denied);
      case LocationPermission.deniedForever:
        // Seul un passage par les réglages système lève ce refus : l'écran
        // propose ce chemin plutôt que de redemander en boucle.
        return const LocationRefused(LocationRefusal.deniedForever);
      case LocationPermission.always:
      case LocationPermission.whileInUse:
      case LocationPermission.unableToDetermine:
        break;
    }

    try {
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          // Le quartier suffit : viser le mètre coûterait de la batterie et
          // du temps pour trier une liste de courtiers.
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return LocationFound(GeoPoint(position.latitude, position.longitude));
    } on Object {
      // Un GPS qui ne répond pas est un cas normal en ville dense, pas une
      // erreur à faire remonter comme un plantage.
      return const LocationRefused(LocationRefusal.unavailable);
    }
  }
}
