import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:woutalma_api_client/woutalma_api_client.dart' as api;
import 'package:woutalma_keur/app/core/app_config.dart';
import 'package:woutalma_keur/app/core/feedback/interaction_feedback.dart';
import 'package:woutalma_keur/app/core/location/client_position_controller.dart';
import 'package:woutalma_keur/app/data/local/cache_meta_store.dart';
import 'package:woutalma_keur/app/data/local/cache_status.dart';
import 'package:woutalma_keur/app/data/local/persistent_bootstrap.dart'
    if (dart.library.js_interop) 'package:woutalma_keur/app/data/local/persistent_bootstrap_web.dart';
import 'package:woutalma_keur/app/core/feedback/platform_interaction_feedback.dart';
import 'package:woutalma_keur/app/data/repositories/cached_discovery.dart';
import 'package:woutalma_keur/app/data/repositories/cached_repositories.dart';
import 'package:woutalma_keur/app/data/repositories/in_memory_repositories.dart';
import 'package:woutalma_keur/app/data/repositories/remote_discovery.dart';
import 'package:woutalma_keur/app/data/repositories/remote_repositories.dart';
import 'package:flutter_map/flutter_map.dart' show TileProvider;
import 'package:woutalma_keur/app/data/services/backend_warmup.dart';
import 'package:woutalma_keur/app/data/services/cached_tile_provider.dart';
import 'package:woutalma_keur/app/data/services/dio_auth_interceptor.dart';
import 'package:woutalma_keur/app/data/services/dio_log_interceptor.dart';
import 'package:woutalma_keur/app/data/services/geolocator_location_service.dart';
import 'package:woutalma_keur/app/data/services/google_backend_auth_service.dart';
import 'package:woutalma_keur/app/data/services/image_picker_photo_service.dart';
import 'package:woutalma_keur/app/data/services/record_voice_note_recorder.dart';
import 'package:woutalma_keur/app/domain/voice_note_service.dart';
import 'package:woutalma_keur/app/data/services/session_expiry.dart';
import 'package:woutalma_keur/app/data/services/staging_auth_service.dart';
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
    required this.voiceNotes,
    required this.clientPosition,
    required this.cacheStatus,
    required this.sessionExpiry,
    required this.warmup,
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

  /// Message vocal d'un bien, enregistré dans B03.
  final VoiceNoteRecorder voiceNotes;

  /// Position retenue pour la recherche : celle du GPS dès qu'elle arrive,
  /// sinon le quartier choisi à la main.
  final ClientPositionController clientPosition;

  /// Dit à l'interface si ce qu'elle montre vient du serveur ou de la
  /// dernière copie reçue. Toujours « frais » en mode local.
  final CacheStatus cacheStatus;

  /// Signale qu'une session a expiré sans pouvoir être renouvelée.
  final SessionExpiry sessionExpiry;

  /// Réveille l'instance gratuite pendant que l'application se peint. Inerte
  /// en mode local, où il n'y a rien à réveiller.
  final BackendWarmup warmup;

  /// Tuiles de carte gardées sur le disque. `null` là où il n'y a pas de
  /// disque (web) : la carte retombe alors sur le réseau seul.
  TileProvider? mapTiles;

  /// Reprise de la session précédente, lancée au démarrage.
  ///
  /// Déjà terminée quand il n'y a rien à reprendre — mode local, ou aucun
  /// jeton sur le téléphone. Elle n'est **jamais** attendue avant le premier
  /// écran : la découverte est publique et doit se peindre tout de suite. Le
  /// routeur s'y abonne pour rejoindre l'espace courtier dès que la réponse
  /// arrive, au lieu de laisser un courtier dans l'espace client.
  ///
  /// Ne rejette jamais : une reprise impossible est un événement normal
  /// (avion, jeton révoqué) et se solde par une session close, pas par une
  /// erreur qui remonterait jusqu'au routeur.
  Future<void> sessionRestore = Future<void>.value();

  /// Aligne le rôle affiché sur ce que dit vraiment le compte, et renvoie le
  /// rôle retenu.
  ///
  /// Une seule règle, à un seul endroit : le démarrage et le routeur la
  /// suivaient chacun de leur côté et pouvaient diverger — l'espace courtier
  /// ouvert alors que S01 affichait encore « Client ».
  ///
  /// - un compte porteur d'un profil courtier ouvre l'espace courtier : c'est
  ///   ce qui rend une session reprise visible au bon endroit ;
  /// - se dire courtier sans profil enfermait la personne sur l'écran
  ///   verrouillé, alors on repasse en client, qui est la vérité du compte.
  UserRole syncRoleWithSession() {
    if (auth.current?.brokerId != null) {
      settings.setRole(UserRole.broker);
    } else if (settings.role == UserRole.broker) {
      settings.setRole(UserRole.client);
    }
    return settings.role;
  }

  /// Reprend la session puis remet le rôle d'accord avec elle.
  Future<void> _restoreSession() async {
    try {
      await auth.restoreSession();
    } on Object catch (error) {
      // Rien à reprendre, ou serveur injoignable : l'application continue en
      // visiteur. Le dire une fois vaut mieux qu'une erreur asynchrone
      // perdue.
      debugPrint('[wk] reprise de session impossible : $error');
    }
    syncRoleWithSession();
  }

  /// Nouvelle tentative de reprise, au retour au premier plan.
  ///
  /// Le démarrage à froid d'une instance endormie fait échouer la reprise
  /// lancée au lancement : sans cette seconde chance, un courtier restait
  /// visiteur jusqu'à ce qu'il tue l'application.
  Future<void> refreshSession() =>
      auth.current == null ? _restoreSession() : Future<void>.value();

  String? get currentBrokerId => auth.current?.brokerId;

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

    // Une base corrompue ou un disque plein ne rendent pas forcément la main :
    // sans délai, l'application restait sur un écran noir pour toujours.
    final PersistentRepositories repos = await openPersistentRepositories()
        .timeout(_storageTimeout);

    if (!AppConfig.isRemote) {
      // Le seed n'est chargé qu'à la **première** ouverture. Le recharger à
      // chaque lancement effacerait ce que l'utilisateur vient de saisir.
      if (await repos.seed.itemCount() == 0) {
        await repos.seed.loadDemoSeed();
      }
      final AppDependencies local = _assemble(
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
      await local.clientPosition.restore();
      local.mapTiles = await _openTileCache();
      return local;
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
    // Le trousseau Android peut rester bloqué sur un KeyStore abîmé : mieux
    // vaut repartir en visiteur que ne jamais peindre le premier écran.
    await tokens.restore().timeout(_storageTimeout);

    final AppDependencies deps = remote(
      baseUrl: AppConfig.apiBaseUrl,
      cache: repos,
      tokens: tokens,
    );
    deps.cacheStatus.restoreFetchedAt(
      DateTime.tryParse(
        await repos.meta.read(CacheMetaStore.fetchedAtKey) ?? '',
      ),
    );
    await deps.clientPosition.restore();
    deps.mapTiles = await _openTileCache();

    // Reprend la session précédente. Sans cela les jetons survivaient au
    // redémarrage mais le compte non : l'application se rouvrait déconnectée,
    // et un courtier repartait dans l'espace client. Non bloquant pour le
    // premier écran — la découverte est publique — mais lancé tout de suite,
    // pour que les réglages et l'espace courtier soient justes dès qu'on les
    // ouvre. Le rôle suit dans `_restoreSession`, pas ici : c'est la même
    // règle que celle du routeur après une identification.
    deps.sessionRestore = deps._restoreSession();
    return deps;
  }

  /// Au-delà, on considère que le stockage local ne répondra pas.
  static const Duration _storageTimeout = Duration(seconds: 15);

  /// Démarrage de secours, quand la base locale ou le trousseau refusent de
  /// s'ouvrir : disque plein, base abîmée, KeyStore cassé.
  ///
  /// L'application reste utilisable — en ligne seulement — au lieu de rester
  /// sur un écran noir. La session dormante est perdue pour ce lancement :
  /// sans trousseau il n'y a pas de jeton à relire.
  static Future<AppDependencies> withoutLocalStore() async {
    if (!AppConfig.isRemote) {
      final AppDependencies local = await inMemory(loadDemoSeed: false);
      local.cacheStatus.markCacheUnavailable();
      return local;
    }
    final InMemoryStore store = InMemoryStore();
    final AppDependencies deps = remote(
      baseUrl: AppConfig.apiBaseUrl,
      cache: PersistentRepositories(
        brokers: InMemoryBrokerRepository(store),
        properties: InMemoryPropertyRepository(store),
        reviews: InMemoryReviewRepository(store),
        contacts: InMemoryContactRepository(store, now: DateTime.now),
        seed: InMemorySeedRepository(store),
        meta: InMemoryCacheMetaStore(),
      ),
      tokens: TokenStore(InMemoryTokenStorage()),
    );
    deps.cacheStatus.markCacheUnavailable();
    return deps;
  }

  /// Cache disque des tuiles de carte. Sans lui, chaque ouverture de la carte
  /// retélécharge tout et le hors-ligne montre un fond vide.
  static Future<TileProvider?> _openTileCache() async {
    final String? path = await appSupportDirectory();
    if (path == null) {
      return null;
    }
    try {
      return await CachedTileProvider.open(path);
    } on Object {
      // Disque plein ou dossier refusé : la carte marche encore, en ligne.
      return null;
    }
  }

  /// Démarrage en mémoire, pour les tests et les aperçus.
  ///
  /// Même chemin de code métier : seuls les dépôts changent. [location] reste
  /// nul dans l'application ; un test qui monte l'arbre complet le fournit,
  /// faute de quoi C01 réveille le vrai GPS et son canal de plateforme.
  static Future<AppDependencies> inMemory({
    bool loadDemoSeed = true,
    LocationService? location,
  }) async {
    final InMemoryStore store = InMemoryStore();
    final SeedRepository seed = InMemorySeedRepository(store);
    if (loadDemoSeed) {
      await seed.loadDemoSeed();
    }

    final BrokerRepository brokers = InMemoryBrokerRepository(store);
    final PropertyRepository properties = InMemoryPropertyRepository(store);
    final ReviewRepository reviews = InMemoryReviewRepository(store);

    final AppDependencies deps = _assemble(
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
      location: location,
    );
    await deps.clientPosition.restore();
    return deps;
  }

  /// Démarrage distant : l'API est la source de vérité, Isar sert de copie
  /// hors ligne en lecture seule.
  static AppDependencies remote({
    required String baseUrl,
    required PersistentRepositories cache,
    required TokenStore tokens,
  }) {
    final SessionExpiry sessionExpiry = SessionExpiry();
    final CacheStatus cacheStatus = CacheStatus(
      persist: (DateTime at) =>
          cache.meta.write(CacheMetaStore.fetchedAtKey, at.toIso8601String()),
    );

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
    final BackendWarmup warmup = BackendWarmup(health: client.getHealthApi());

    client.dio.interceptors.addAll(<Interceptor>[
      DioAuthInterceptor(
        tokens: tokens,
        baseUrl: baseUrl,
        options: options,
        onSessionExpired: sessionExpiry.expire,
      ),
      // Après l'authentification, pour que la trace montre la requête telle
      // qu'elle part réellement. Silencieux en release.
      const DioLogInterceptor(),
      // Une coupure veut souvent dire « l'instance s'est rendormie ». On
      // relance le réveil ici plutôt que dans chaque dépôt.
      InterceptorsWrapper(
        onError: (DioException error, ErrorInterceptorHandler handler) {
          if (isOfflineFailure(error)) {
            warmup.retry();
          }
          handler.next(error);
        },
      ),
    ]);
    warmup.start();

    if (kDebugMode) {
      // La panne la plus coûteuse à diagnostiquer est un build lancé sans ses
      // `--dart-define` : l'application retombe alors sur Google, qui n'a pas
      // de client OAuth ici, et l'écran dit seulement « Connexion
      // impossible ». Autant l'écrire au démarrage.
      debugPrint(
        '[wk] API $baseUrl · identification '
        '${AppConfig.devAuth ? "recette (téléphone sans SMS)" : "Google"}'
        '${AppConfig.devAuth && AppConfig.devAuthSecret.isEmpty ? " · WK_DEV_AUTH_SECRET MANQUANT" : ""}',
      );
    }

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
      remote: RemoteContactRepository(contactsApi, brokersApi),
      cache: cache.contacts,
      status: cacheStatus,
    );

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
      // chaque frappe. Enveloppé pour que la recherche laisse une trace et
      // sache se rejouer hors ligne : sans cela, l'écran d'accueil était le
      // seul de l'application sans version hors ligne.
      discovery: CachedDiscoveryService(
        remote: RemoteDiscoveryService(searchApi),
        brokerCache: cache.brokers,
        propertyCache: cache.properties,
        reviewCache: cache.reviews,
        status: cacheStatus,
      ),
      cacheStatus: cacheStatus,
      sessionExpiry: sessionExpiry,
      warmup: warmup,
      // En recette, le parcours téléphone complet sans SMS : les écrans G03 et
      // G04 sont ceux de la production, seul le trajet du code change.
      auth: AppConfig.devAuth
          ? StagingAuthService(
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
      voiceNotes: RecordVoiceNoteRecorder(),
      clientPosition: ClientPositionController(
        location: locationService,
        meta: meta,
      ),
      cacheStatus: cacheStatus ?? CacheStatus(),
      sessionExpiry: sessionExpiry ?? SessionExpiry(),
      warmup: warmup ?? BackendWarmup.disabled(),
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
