import 'package:dio/dio.dart';
import 'package:woutalma_api_client/woutalma_api_client.dart' as api;
import 'package:woutalma_keur/app/core/app_config.dart';
import 'package:woutalma_keur/app/core/feedback/interaction_feedback.dart';
import 'package:woutalma_keur/app/core/location/client_position_controller.dart';
import 'package:woutalma_keur/app/data/local/cache_meta_store.dart';
import 'package:woutalma_keur/app/data/local/cache_status.dart';
import 'package:woutalma_keur/app/data/local/persistent_bootstrap.dart'
    if (dart.library.js_interop) 'package:woutalma_keur/app/data/local/persistent_bootstrap_web.dart';
import 'package:woutalma_keur/app/core/feedback/platform_interaction_feedback.dart';
import 'package:woutalma_keur/app/data/repositories/cached_repositories.dart';
import 'package:woutalma_keur/app/data/repositories/in_memory_repositories.dart';
import 'package:woutalma_keur/app/data/repositories/remote_discovery.dart';
import 'package:woutalma_keur/app/data/repositories/remote_repositories.dart';
import 'package:woutalma_keur/app/data/services/backend_warmup.dart';
import 'package:woutalma_keur/app/data/services/dev_backend_auth_service.dart';
import 'package:woutalma_keur/app/data/services/dio_auth_interceptor.dart';
import 'package:woutalma_keur/app/data/services/geolocator_location_service.dart';
import 'package:woutalma_keur/app/data/services/google_backend_auth_service.dart';
import 'package:woutalma_keur/app/data/services/image_picker_photo_service.dart';
import 'package:woutalma_keur/app/data/services/session_expiry.dart';
import 'package:woutalma_keur/app/data/services/token_store.dart';
import 'package:woutalma_keur/app/data/services/url_contact_launcher.dart';
import 'package:woutalma_keur/app/domain/auth_service.dart';
import 'package:woutalma_keur/app/domain/contact_launcher.dart';
import 'package:woutalma_keur/app/domain/discovery.dart';
import 'package:woutalma_keur/app/domain/location_service.dart';
import 'package:woutalma_keur/app/domain/photo_service.dart';
import 'package:woutalma_keur/app/domain/repositories.dart';
import 'package:woutalma_keur/app/domain/review_eligibility.dart';
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
    required this.auth,
    required this.location,
    required this.photos,
    required this.clientPosition,
    required this.cacheStatus,
    required this.sessionExpiry,
    this.warmup,
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

  /// Identification.
  final AuthService auth;

  /// Position du téléphone.
  final LocationService location;

  /// Photos de biens, systématiquement allégées avant stockage.
  final PhotoService photos;

  /// Position retenue pour la recherche : celle du GPS dès qu'elle arrive,
  /// sinon le quartier choisi à la main.
  final ClientPositionController clientPosition;

  /// Dit à l'interface si ce qu'elle montre vient du serveur ou de la
  /// dernière copie reçue. Toujours « frais » en mode local.
  final CacheStatus cacheStatus;

  /// Signale qu'une session a expiré sans pouvoir être renouvelée.
  final SessionExpiry sessionExpiry;

  /// Réveille l'instance gratuite pendant que l'application se peint. `null`
  /// en mode local, où il n'y a rien à réveiller.
  final BackendWarmup? warmup;

  /// Courtier connecté, déduit de l'identification.
  ///
  /// En mode distant il n'y a pas de repli possible : un identifiant de
  /// démonstration renverrait 404 sur chaque écran courtier. En mode local on
  /// retombe sur le profil du seed pour que la gestion reste explorable sans
  /// compte.
  String? get currentBrokerId =>
      auth.current?.brokerId ?? (AppConfig.isRemote ? null : 'brk-moussa');

  /// Le rôle courtier n'est atteignable que si un profil existe vraiment.
  bool get canActAsBroker => currentBrokerId != null;

  /// Démarrage réel.
  ///
  /// Trois issues, dans l'ordre :
  /// - pas de persistance (web) : magasin mémoire ;
  /// - pas d'URL d'API : Isar seul, jeu de démonstration au premier lancement ;
  /// - sinon : API en source de vérité, Isar rétrogradé en copie hors ligne.
  static Future<AppDependencies> bootstrap() async {
    if (!supportsPersistence) {
      return inMemory();
    }

    final PersistentRepositories repos = await openPersistentRepositories();

    if (!AppConfig.isRemote) {
      // Le seed n'est chargé qu'à la **première** ouverture. Le recharger à
      // chaque lancement effacerait ce que l'utilisateur vient de saisir.
      if (await repos.seed.itemCount() == 0) {
        await repos.seed.loadDemoSeed();
      }
      return _assemble(
        brokers: repos.brokers,
        properties: repos.properties,
        reviews: repos.reviews,
        contacts: repos.contacts,
        seed: repos.seed,
        meta: repos.meta,
        mode: await repos.seed.itemCount() > 0 ? AppMode.demo : AppMode.real,
        discovery: LocalDiscoveryService(
          brokers: repos.brokers,
          properties: repos.properties,
          reviews: repos.reviews,
        ),
      );
    }

    // Une installation qui tournait en démonstration contient déjà les 28
    // lignes du seed. Les servir comme copie hors ligne du serveur serait
    // exactement la fabrication de données que le mode distant interdit.
    final String? kind = await repos.meta.read(CacheMetaStore.storeKindKey);
    if (kind != CacheMetaStore.remoteStoreKind) {
      await repos.seed.clearAll();
      await repos.meta.write(
        CacheMetaStore.storeKindKey,
        CacheMetaStore.remoteStoreKind,
      );
    }

    // La session est relue avant le premier écran : lecture locale, rapide,
    // et sans elle un jeton d'accès de quinze minutes ferait mourir toute
    // session au premier redémarrage du processus.
    final TokenStore tokens = TokenStore();
    await tokens.restore();

    final AppDependencies deps = remote(
      baseUrl: AppConfig.apiBaseUrl,
      cache: repos,
      tokens: tokens,
    );
    await deps.clientPosition.restore();
    return deps;
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

    final BrokerRepository brokers = InMemoryBrokerRepository(store);
    final PropertyRepository properties = InMemoryPropertyRepository(store);
    final ReviewRepository reviews = InMemoryReviewRepository(store);

    return _assemble(
      brokers: brokers,
      properties: properties,
      reviews: reviews,
      contacts: InMemoryContactRepository(store, now: DateTime.now),
      seed: seed,
      meta: InMemoryCacheMetaStore(),
      mode: loadDemoSeed ? AppMode.demo : AppMode.real,
      discovery: LocalDiscoveryService(
        brokers: brokers,
        properties: properties,
        reviews: reviews,
      ),
    );
  }

  /// Démarrage distant : l'API est la source de vérité, Isar sert de copie
  /// hors ligne en lecture seule.
  static AppDependencies remote({
    required String baseUrl,
    required PersistentRepositories cache,
    required TokenStore tokens,
  }) {
    final SessionExpiry sessionExpiry = SessionExpiry();
    final CacheStatus cacheStatus = CacheStatus();

    // Le démarrage à froid d'une instance gratuite prend une cinquantaine de
    // secondes. Les délais par défaut de Dio garantiraient un échec au premier
    // lancement.
    final BaseOptions options = BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 60),
    );
    final api.WoutalmaApiClient client = api.WoutalmaApiClient(
      basePathOverride: baseUrl,
      dio: Dio(options..baseUrl = baseUrl),
    );
    client.dio.interceptors.add(
      DioAuthInterceptor(
        tokens: tokens,
        baseUrl: baseUrl,
        options: options,
        onSessionExpired: sessionExpiry.expire,
      ),
    );

    final api.BrokersApi brokersApi = client.getBrokersApi();
    final api.PropertiesApi propertiesApi = client.getPropertiesApi();
    final api.ContactsApi contactsApi = client.getContactsApi();
    final api.ReviewsApi reviewsApi = client.getReviewsApi();
    final api.SearchApi searchApi = client.getSearchApi();
    final api.AuthApi authApi = client.getAuthApi();

    final BrokerRepository brokers = CachedBrokerRepository(
      remote: RemoteBrokerRepository(brokersApi),
      cache: cache.brokers,
      status: cacheStatus,
    );
    final PropertyRepository properties = CachedPropertyRepository(
      remote: RemotePropertyRepository(propertiesApi, brokersApi),
      cache: cache.properties,
      status: cacheStatus,
    );
    final ReviewRepository reviews = CachedReviewRepository(
      remote: RemoteReviewRepository(reviewsApi),
      cache: cache.reviews,
      status: cacheStatus,
    );
    final ContactRepository contacts = CachedContactRepository(
      remote: RemoteContactRepository(contactsApi),
      cache: cache.contacts,
      status: cacheStatus,
    );

    final BackendWarmup warmup = BackendWarmup(health: client.getHealthApi())
      ..start();

    return _assemble(
      brokers: brokers,
      properties: properties,
      reviews: reviews,
      contacts: contacts,
      seed: CacheSeedRepository(cache.seed),
      meta: cache.meta,
      mode: AppMode.remote,
      // Le classement part côté serveur : PostGIS pour les distances, index
      // GIN pour le texte, au lieu de trois collections entières rapatriées à
      // chaque frappe.
      discovery: RemoteDiscoveryService(searchApi),
      cacheStatus: cacheStatus,
      sessionExpiry: sessionExpiry,
      warmup: warmup,
      auth: AppConfig.devAuth
          ? DevBackendAuthService(
              authApi: authApi,
              tokens: tokens,
              secret: AppConfig.devAuthSecret,
            )
          : GoogleBackendAuthService(authApi: authApi, tokens: tokens),
    );
  }

  static AppDependencies _assemble({
    required BrokerRepository brokers,
    required PropertyRepository properties,
    required ReviewRepository reviews,
    required ContactRepository contacts,
    required SeedRepository seed,
    required CacheMetaStore meta,
    required AppMode mode,
    required DiscoveryService discovery,
    CacheStatus? cacheStatus,
    SessionExpiry? sessionExpiry,
    BackendWarmup? warmup,
    AuthService? auth,
    LocationService? location,
  }) {
    final LocationService locationService =
        location ?? const GeolocatorLocationService();
    return AppDependencies._(
      brokers: brokers,
      properties: properties,
      reviews: reviews,
      contacts: contacts,
      seed: seed,
      discovery: discovery,
      contact: ContactService(
        contacts: contacts,
        launcher: const UrlContactLauncher(),
      ),
      eligibility: ReviewEligibilityService(contacts),
      feedback: PlatformInteractionFeedbackService(),
      settings: SettingsViewModel(seed: seed, mode: mode),
      location: locationService,
      photos: ImagePickerPhotoService(),
      clientPosition: ClientPositionController(
        location: locationService,
        meta: meta,
      ),
      cacheStatus: cacheStatus ?? CacheStatus(),
      sessionExpiry: sessionExpiry ?? SessionExpiry(),
      warmup: warmup,
      auth:
          auth ??
          SimulatedAuthService(
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
