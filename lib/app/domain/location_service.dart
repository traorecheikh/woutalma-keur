import 'package:flutter/foundation.dart';
import 'package:woutalma_keur/app/domain/entities.dart';

/// Un quartier nommé, tel qu'on le dit localement.
@immutable
class Neighbourhood {
  const Neighbourhood({required this.name, required this.position});

  final String name;
  final GeoPoint position;

  @override
  bool operator ==(Object other) =>
      other is Neighbourhood && other.name == name;

  @override
  int get hashCode => name.hashCode;
}

/// Pourquoi la position n'a pas pu être obtenue.
enum LocationRefusal {
  /// L'utilisateur a refusé, ou n'a pas encore accepté.
  denied,

  /// Refus définitif : seul un passage par les réglages système le lève.
  deniedForever,

  /// Service coupé, ou aucune position disponible.
  unavailable,
}

/// Résultat d'une demande de position.
sealed class LocationResult {
  const LocationResult();
}

final class LocationFound extends LocationResult {
  const LocationFound(this.position);

  final GeoPoint position;
}

final class LocationRefused extends LocationResult {
  const LocationRefused(this.reason);

  final LocationRefusal reason;
}

/// Donne la position du téléphone.
///
/// La saisie manuelle de quartier reste **toujours** disponible : le GPS est
/// un raccourci, jamais un péage. Un refus n'enlève rien au parcours.
abstract class LocationService {
  Future<LocationResult> current();

  /// L'autorisation est-elle déjà accordée ?
  ///
  /// Distinct de [current] : celle-ci **demande** si besoin, donc peut ouvrir
  /// un dialogue système. Il faut pouvoir savoir sans demander, pour relire la
  /// position aux lancements suivants sans jamais rouvrir un dialogue — ce que
  /// docs/screen-contracts/client-discovery.md interdit.
  Future<bool> hasPermission();

  /// Ouvre les réglages système. Proposé seulement après un refus définitif.
  Future<void> openSettings();

  /// Quartiers connus, pour la saisie manuelle.
  List<Neighbourhood> knownNeighbourhoods();
}

/// Quartiers de Dakar et de sa banlieue, avec leurs positions approximatives.
///
/// Codés en dur volontairement : un géocodeur pour vingt quartiers connus
/// coûterait un appel réseau là où la cible a justement peu de réseau.
const List<Neighbourhood> dakarNeighbourhoods = <Neighbourhood>[
  Neighbourhood(name: 'Plateau', position: GeoPoint(14.6690, -17.4380)),
  Neighbourhood(name: 'Médina', position: GeoPoint(14.6790, -17.4510)),
  Neighbourhood(name: 'Fann', position: GeoPoint(14.6880, -17.4650)),
  Neighbourhood(name: 'Point E', position: GeoPoint(14.6889, -17.4640)),
  Neighbourhood(name: 'Mermoz', position: GeoPoint(14.6952, -17.4611)),
  Neighbourhood(name: 'Sacré-Cœur', position: GeoPoint(14.6935, -17.4570)),
  Neighbourhood(name: 'Grand Dakar', position: GeoPoint(14.6821, -17.4455)),
  Neighbourhood(name: 'Liberté 6', position: GeoPoint(14.7115, -17.4602)),
  Neighbourhood(name: 'Ouakam', position: GeoPoint(14.7220, -17.4890)),
  Neighbourhood(name: 'Almadies', position: GeoPoint(14.7448, -17.5098)),
  Neighbourhood(name: 'Ngor', position: GeoPoint(14.7500, -17.5140)),
  Neighbourhood(name: 'Yoff', position: GeoPoint(14.7550, -17.4700)),
  Neighbourhood(
    name: 'Parcelles Assainies',
    position: GeoPoint(14.7691, -17.3920),
  ),
  Neighbourhood(name: 'Pikine', position: GeoPoint(14.7550, -17.3900)),
  Neighbourhood(name: 'Guédiawaye', position: GeoPoint(14.7700, -17.4100)),
  Neighbourhood(name: 'Yeumbeul', position: GeoPoint(14.7760, -17.3400)),
  Neighbourhood(name: 'Keur Massar', position: GeoPoint(14.7822, -17.3188)),
  Neighbourhood(name: 'Rufisque', position: GeoPoint(14.7167, -17.2667)),
];
