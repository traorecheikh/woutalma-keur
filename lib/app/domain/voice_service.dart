import 'package:flutter/foundation.dart';
import 'package:woutalma_keur/app/domain/discovery.dart';
import 'package:woutalma_keur/app/domain/entities.dart';

/// Ce que le service a cru entendre.
@immutable
class VoiceCommand {
  const VoiceCommand({required this.transcript, required this.filters});

  /// Ce qui sera relu à l'utilisateur avant d'appliquer quoi que ce soit.
  final String transcript;

  /// Les filtres extraits. Toujours montrés avant application : appliquer
  /// une interprétation sans la relire, c'est faire disparaître des résultats
  /// sans que personne comprenne pourquoi.
  final DiscoveryFilters filters;
}

/// Écoute et interprète une commande parlée.
///
/// Abstrait dès maintenant alors que l'implémentation est simulée : le jour
/// où un moteur réel arrive, il prend cette place et **aucun écran ne bouge**.
abstract class VoiceService {
  /// Écoute, puis renvoie ce qui a été compris — ou `null` si rien ne l'a été.
  Future<VoiceCommand?> listen();

  /// Vrai quand la reconnaissance est jouée et non réelle. L'interface le dit
  /// à l'utilisateur : laisser croire à une capacité inexistante se paie au
  /// premier essai raté.
  bool get isSimulated;
}

/// Implémentation de la phase UX : aucune reconnaissance, une rotation de
/// commandes plausibles.
///
/// Elle existe pour que le parcours vocal complet — bouton, écoute, relecture,
/// application — soit conçu, testé et corrigé avant qu'un moteur coûteux ne
/// soit choisi.
class SimulatedVoiceService implements VoiceService {
  SimulatedVoiceService({
    this.delay = const Duration(milliseconds: 900),
    List<VoiceCommand>? script,
  }) : _script = script ?? _defaultScript;

  /// Temps d'écoute simulé. Assez long pour que l'état d'écoute se voie,
  /// assez court pour ne pas faire attendre.
  final Duration delay;

  final List<VoiceCommand> _script;
  int _next = 0;

  @override
  bool get isSimulated => true;

  @override
  Future<VoiceCommand?> listen() async {
    await Future<void>.delayed(delay);
    if (_script.isEmpty) {
      return null;
    }
    final VoiceCommand command = _script[_next % _script.length];
    _next++;
    return command;
  }

  /// Couvre volontairement le cas « rien compris » : c'est celui qui décide
  /// si le parcours vocal est utilisable ou non.
  static final List<VoiceCommand> _defaultScript = <VoiceCommand>[
    const VoiceCommand(
      transcript: 'Maison à louer près d\'ici',
      filters: DiscoveryFilters(
        transaction: TransactionKind.rent,
        kind: PropertyKind.house,
        radiusMeters: 5000,
      ),
    ),
    const VoiceCommand(
      transcript: 'Terrain à vendre',
      filters: DiscoveryFilters(
        transaction: TransactionKind.sale,
        kind: PropertyKind.land,
      ),
    ),
    const VoiceCommand(
      transcript: 'Chambre pas chère',
      filters: DiscoveryFilters(kind: PropertyKind.room, maxPrice: 100000),
    ),
  ];
}
