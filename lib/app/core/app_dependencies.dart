import 'package:woutalma_keur/app/core/feedback/interaction_feedback.dart';
import 'package:woutalma_keur/app/data/local/persistent_bootstrap.dart'
    if (dart.library.js_interop) 'package:woutalma_keur/app/data/local/persistent_bootstrap_web.dart';
import 'package:woutalma_keur/app/core/feedback/platform_interaction_feedback.dart';
import 'package:woutalma_keur/app/data/repositories/in_memory_repositories.dart';
import 'package:woutalma_keur/app/data/seed/demo_seed.dart';
import 'package:woutalma_keur/app/data/services/geolocator_location_service.dart';
import 'package:woutalma_keur/app/data/services/image_picker_photo_service.dart';
import 'package:woutalma_keur/app/data/services/url_contact_launcher.dart';
import 'package:woutalma_keur/app/domain/auth_service.dart';
import 'package:woutalma_keur/app/domain/contact_launcher.dart';
import 'package:woutalma_keur/app/domain/discovery.dart';
import 'package:woutalma_keur/app/domain/location_service.dart';
import 'package:woutalma_keur/app/domain/photo_service.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/repositories.dart';
import 'package:woutalma_keur/app/domain/review_eligibility.dart';
import 'package:woutalma_keur/app/domain/voice_service.dart';
import 'package:woutalma_keur/app/modules/settings/settings_view_model.dart';

/// Assemble l'application une seule fois, au démarrage.
///
/// Un seul endroit sait quelle implémentation concrète est branchée : les
/// écrans ne connaissent que les contrats de `repositories.dart`.
class AppDependencies {
  AppDependencies._({
    required this.brokers,
    required this.properties,
    required this.reviews,
    required this.contacts,
    required this.seed,
    required this.discovery,
    required this.contact,
    required this.eligibility,
    required this.feedback,
    required this.settings,
    required this.voice,
    required this.auth,
    required this.location,
    required this.photos,
  });

  final BrokerRepository brokers;
  final PropertyRepository properties;
  final ReviewRepository reviews;
  final ContactRepository contacts;
  final SeedRepository seed;
  final DiscoveryService discovery;
  final ContactService contact;
  final ReviewEligibilityService eligibility;
  final InteractionFeedbackService feedback;

  /// Vit aussi longtemps que l'application : le mode et les préférences
  /// survivent à la navigation.
  final SettingsViewModel settings;

  /// Reconnaissance vocale. Simulée en phase UX ; l'interface est la même que
  /// celle qu'un moteur réel devra remplir.
  final VoiceService voice;

  /// Identification. Simulée en phase UX : aucun SMS n'est envoyé et le code
  /// est affiché à l'écran plutôt que caché.
  final AuthService auth;

  /// Position du téléphone. La saisie manuelle de quartier reste toujours
  /// disponible : le GPS est un raccourci, jamais un péage.
  final LocationService location;

  /// Photos de biens, systématiquement allégées avant stockage.
  final PhotoService photos;

  /// Position du client. Le GPS réel la remplacera ; en attendant, le seed
  /// place le client au Plateau pour que les distances aient un sens.
  GeoPoint clientPosition = DemoSeed.clientPosition;

  /// Courtier connecté, déduit de l'identification.
  ///
  /// Un numéro du jeu de démonstration ouvre le profil correspondant ; sinon
  /// on retombe sur le profil de démonstration pour que la gestion reste
  /// explorable sans compte.
  String get currentBrokerId => auth.current?.brokerId ?? 'brk-moussa';

  /// Démarrage réel : base persistante sur le disque du téléphone.
  ///
  /// Le seed n'est chargé qu'à la **première** ouverture. Le recharger à
  /// chaque lancement effacerait ce que l'utilisateur vient de saisir — c'est
  /// exactement ce qu'un mode démonstration ne doit jamais faire tout seul.
  static Future<AppDependencies> bootstrap() async {
    if (!supportsPersistence) {
      return inMemory();
    }

    final PersistentRepositories repos = await openPersistentRepositories();

    if (await repos.seed.itemCount() == 0) {
      await repos.seed.loadDemoSeed();
    }

    return _assemble(
      brokers: repos.brokers,
      properties: repos.properties,
      reviews: repos.reviews,
      contacts: repos.contacts,
      seed: repos.seed,
      mode: await repos.seed.itemCount() > 0 ? AppMode.demo : AppMode.real,
    );
  }

  /// Démarrage en mémoire, pour les tests et les aperçus.
  ///
  /// Même chemin de code métier : seuls les dépôts changent.
  static Future<AppDependencies> inMemory({bool loadDemoSeed = true}) async {
    final InMemoryStore store = InMemoryStore();
    final SeedRepository seed = InMemorySeedRepository(store);
    if (loadDemoSeed) {
      await seed.loadDemoSeed();
    }

    return _assemble(
      brokers: InMemoryBrokerRepository(store),
      properties: InMemoryPropertyRepository(store),
      reviews: InMemoryReviewRepository(store),
      contacts: InMemoryContactRepository(store, now: DateTime.now),
      seed: seed,
      mode: loadDemoSeed ? AppMode.demo : AppMode.real,
    );
  }

  static AppDependencies _assemble({
    required BrokerRepository brokers,
    required PropertyRepository properties,
    required ReviewRepository reviews,
    required ContactRepository contacts,
    required SeedRepository seed,
    required AppMode mode,
  }) {
    return AppDependencies._(
      brokers: brokers,
      properties: properties,
      reviews: reviews,
      contacts: contacts,
      seed: seed,
      discovery: DiscoveryService(
        brokers: brokers,
        properties: properties,
        reviews: reviews,
      ),
      contact: ContactService(
        contacts: contacts,
        launcher: const UrlContactLauncher(),
      ),
      eligibility: ReviewEligibilityService(contacts),
      feedback: PlatformInteractionFeedbackService(),
      settings: SettingsViewModel(seed: seed, mode: mode),
      voice: SimulatedVoiceService(),
      location: const GeolocatorLocationService(),
      photos: ImagePickerPhotoService(),
      auth: SimulatedAuthService(
        // Les numéros du seed ouvrent leur propre espace courtier.
        brokerByPhone: <String, String>{
          '221771234567': 'brk-moussa',
          '221338211234': 'brk-teranga',
          '221775558899': 'brk-fatou',
        },
      ),
    );
  }
}
