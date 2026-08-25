import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/core/app_dependencies.dart';
import 'package:woutalma_keur/app/core/state/screen_state.dart';
import 'package:woutalma_keur/app/domain/auth_service.dart';
import 'package:woutalma_keur/app/modules/catalog/catalog_screen.dart';
import 'package:woutalma_keur/app/modules/client/broker/broker_screen.dart';
import 'package:woutalma_keur/app/modules/client/broker/broker_view_model.dart';
import 'package:woutalma_keur/app/modules/auth/auth_screens.dart';
import 'package:woutalma_keur/app/modules/broker/broker_activity_screen.dart';
import 'package:woutalma_keur/app/modules/broker/broker_home_screen.dart';
import 'package:woutalma_keur/app/modules/broker/broker_profile_editor_screen.dart';
import 'package:woutalma_keur/app/modules/broker/broker_profile_screen.dart';
import 'package:woutalma_keur/app/modules/broker/broker_trust_screens.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_shell.dart';
import 'package:woutalma_keur/app/modules/client/explore/explore_screen.dart';
import 'package:woutalma_keur/app/modules/client/explore/explore_view_model.dart';
import 'package:woutalma_keur/app/modules/client/history/history_screen.dart';
import 'package:woutalma_keur/app/modules/client/history/history_view_model.dart';
import 'package:woutalma_keur/app/modules/broker/broker_properties_screen.dart';
import 'package:woutalma_keur/app/modules/broker/broker_reviews_screen.dart';
import 'package:woutalma_keur/app/modules/broker/property_editor_screen.dart';
import 'package:woutalma_keur/app/modules/broker/property_editor_view_model.dart';
import 'package:woutalma_keur/app/modules/client/property/property_screen.dart';
import 'package:woutalma_keur/app/modules/client/review/review_screen.dart';
import 'package:woutalma_keur/app/modules/settings/settings_screen.dart';
import 'package:woutalma_keur/app/modules/settings/settings_view_model.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/routes/app_routes.dart';
import 'package:woutalma_keur/app/routes/reload_on_return.dart';
import 'package:woutalma_keur/app/routes/session_landing.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_states.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_top_bar.dart';

/// Routeur de l'application.
///
/// Seuls les chemins réellement implémentés sont déclarés : une route sans
/// écran casse un lien profond sans prévenir.
/// Ce qu'on demande à G03 selon l'endroit d'où l'on vient.
///
/// Le rôle choisi décide : quelqu'un qui se dit courtier et n'a pas encore de
/// profil doit en ouvrir un en s'identifiant, sinon il retombe indéfiniment
/// sur l'écran verrouillé.
AuthRequest _authRequest(BuildContext context, AppDependencies deps) {
  final bool broker = deps.settings.role == UserRole.broker;
  return AuthRequest(
    reason: broker
        ? context.l10n.authPhoneReasonBroker
        : context.l10n.authPhoneReasonContact,
    asBroker: broker && deps.currentBrokerId == null,
  );
}

GoRouter buildRouter(AppDependencies deps, {Duration? sessionLandingWindow}) {
  final GlobalKey<NavigatorState> rootKey = GlobalKey<NavigatorState>();

  /// Où se rouvrir quand une session dormait sur le téléphone.
  final SessionLanding landing = SessionLanding(
    restore: deps.sessionRestore,
    // La condition est celle de `requireBroker`, exprès : on ne peut pas
    // atterrir sur un espace qui se verrouillerait aussitôt.
    belongsToBrokerSpace: () => deps.auth.current?.brokerId != null,
    window: sessionLandingWindow ?? SessionLanding.defaultWindow,
  );

  /// Les écrans courtier ont besoin d'un profil qui existe vraiment.
  ///
  /// En mode local on retombe sur le courtier du seed, donc l'identifiant
  /// n'est jamais nul. En mode distant il l'est tant que personne n'est
  /// connecté, et fabriquer un identifiant ferait rendre quatre écrans
  /// d'erreur 404 au lieu d'une invitation à se connecter.
  Widget requireBroker(
    BuildContext context,
    Widget Function(String brokerId) build,
  ) {
    // `watch` : les branches d'un StatefulShellRoute sont construites une fois
    // et gardées vivantes. L'onglet Accueil, construit avant l'ouverture de
    // session, restait donc verrouillé pendant que les autres — construits
    // après — fonctionnaient.
    context.watch<AuthService>();
    final String? brokerId = deps.currentBrokerId;
    if (brokerId == null) {
      // Sortie de secours. Les quatre onglets courtier se verrouillent
      // ensemble : sans porte, il ne restait qu'à tuer l'application. Une
      // session expirée en cours d'usage suffisait à y tomber.
      void leave() {
        if (context.canPop()) {
          // Écran poussé : l'espace d'où l'on vient est encore dessous.
          context.pop();
          return;
        }
        // Racine d'onglet : on quitte l'espace courtier, et le rôle repasse
        // en client puisque aucun profil ne le porte.
        deps.syncRoleWithSession();
        context.go(AppRoutes.explore);
      }

      return Scaffold(
        body: SafeArea(
          child: Column(
            children: <Widget>[
              WkTopBar(
                title: context.l10n.brokerSignInRequiredTitle,
                onBack: leave,
              ),
              Expanded(
                child: WkEmptyState(
                  icon: Icons.storefront_outlined,
                  title: context.l10n.brokerSignInRequiredHeading,
                  body: context.l10n.brokerSignInRequiredBody,
                  actionLabel: context.l10n.brokerSignInRequiredAction,
                  // Avec le motif client, on rouvrait une session cliente et
                  // cette même porte se refermait derrière : la boucle
                  // signalée.
                  onAction: () => context.push(
                    AppRoutes.authPhone,
                    extra: AuthRequest(
                      reason: context.l10n.authPhoneReasonBroker,
                      asBroker: true,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return build(brokerId);
  }

  /// Après un changement de rôle en S01.
  ///
  /// Se dire courtier sans profil ouvrait l'espace courtier entièrement
  /// verrouillé : on demande d'abord l'identification, sans quitter l'espace
  /// client, et c'est `_postAuthRoute` qui décide ensuite où l'on atterrit.
  void goToRoleHome(BuildContext context) {
    if (deps.settings.role == UserRole.broker && deps.currentBrokerId == null) {
      context.push(AppRoutes.authPhone, extra: _authRequest(context, deps));
      return;
    }
    // Changer de rôle change tout l'arbre : on repart de la racine du nouveau
    // rôle plutôt que d'empiler deux mondes.
    context.go(
      deps.settings.role == UserRole.broker
          ? AppRoutes.brokerHome
          : AppRoutes.explore,
    );
  }

  return GoRouter(
    navigatorKey: rootKey,
    // La découverte est publique : on la peint sans rien attendre, puis
    // `landing` corrige la destination si une session courtier se réveille.
    initialLocation: AppRoutes.explore,
    refreshListenable: landing,
    redirect: (BuildContext context, GoRouterState state) =>
        landing.redirect(state.matchedLocation),
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        builder:
            (
              BuildContext context,
              GoRouterState _,
              StatefulNavigationShell shell,
            ) => WkShell(
              navigationShell: shell,
              destinations: <(IconData, String)>[
                // Libellés d'onglet de `docs/UX-FLOWS.md` §4, pas les titres
                // d'écran : un onglet partage la largeur avec ses voisins.
                (Icons.travel_explore, context.l10n.tabExplore),
                (Icons.history, context.l10n.tabContacts),
                (Icons.person_outline, context.l10n.tabProfile),
              ],
            ),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.explore,
                builder: (BuildContext context, GoRouterState state) =>
                    // Pas de `ReloadOnReturn` ici : une recherche est un
                    // instantané demandé par l'utilisateur, et revenir d'une
                    // fiche courtier est le geste le plus fréquent de
                    // l'application. La relancer à chaque retour coûterait une
                    // requête et effacerait la liste sous les yeux, sur des
                    // réseaux qui ne le supportent pas. Rien d'autre que
                    // l'utilisateur ne périme ces résultats.
                    ChangeNotifierProvider<ExploreViewModel>(
                      create: (_) => ExploreViewModel(
                        discovery: deps.discovery,
                        position: deps.clientPosition,
                      )..load(),
                      child: ExploreScreen(
                        onOpenBroker: (String id) =>
                            context.push(AppRoutes.brokerPath(id)),
                        onOpenProperty: (String id) =>
                            context.push(AppRoutes.propertyPath(id)),
                        onOpenSettings: () => context.push(AppRoutes.settings),
                        location: deps.location,
                      ),
                    ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.contacts,
                builder: (BuildContext context, GoRouterState state) =>
                    ChangeNotifierProvider<HistoryViewModel>(
                      create: (_) => HistoryViewModel(
                        contacts: deps.contacts,
                        brokers: deps.brokers,
                        eligibility: deps.eligibility,
                      )..load(),
                      // Un avis déposé en C05, un contact enregistré depuis
                      // une fiche : l'historique doit dire vrai au retour.
                      child: ReloadOnReturn<HistoryViewModel>(
                        reload: (HistoryViewModel model) => model.load(),
                        child: Builder(
                          builder: (BuildContext inner) => HistoryScreen(
                            onSearch: () => inner.go(AppRoutes.explore),
                            onReview: (ContactEntry entry) => inner.push(
                              AppRoutes.reviewPath(entry.contact.id),
                              extra: entry,
                            ),
                          ),
                        ),
                      ),
                    ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.clientProfile,
                builder: (BuildContext context, GoRouterState state) =>
                    ChangeNotifierProvider<SettingsViewModel>.value(
                      value: deps.settings,
                      child: SettingsScreen(
                        onOpenCatalog: () => context.push(AppRoutes.catalog),
                        onSignIn: () => context.push(
                          AppRoutes.authPhone,
                          extra: _authRequest(context, deps),
                        ),
                        onSignedOut: () => context.go(AppRoutes.explore),
                        onModeChanged: () => context.go(AppRoutes.explore),
                        onRoleChanged: () => goToRoleHome(context),
                      ),
                    ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: rootKey,
        path: '${AppRoutes.explore}/brokers/:brokerId',
        builder: (BuildContext context, GoRouterState state) {
          final String id = state.pathParameters['brokerId']!;
          return ChangeNotifierProvider<BrokerViewModel>(
            create: (_) => BrokerViewModel(
              brokerId: id,
              brokers: deps.brokers,
              properties: deps.properties,
              reviews: deps.reviews,
              contact: deps.contact,
              from: deps.clientPosition.position,
            )..load(),
            child: BrokerScreen(
              onBack: () => context.pop(),
              onOpenProperty: (String pid) =>
                  context.push(AppRoutes.propertyPath(pid)),
            ),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootKey,
        path: '${AppRoutes.contacts}/:contactId/review',
        builder: (BuildContext context, GoRouterState state) {
          final ContactEntry? entry = state.extra as ContactEntry?;
          if (entry == null) {
            // Lien profond sans contexte : on le dit, on ne fabrique pas un
            // avis sur un contact inconnu.
            return const WkErrorState(failure: WkFailure.notFound);
          }
          return ChangeNotifierProvider<ReviewViewModel>(
            create: (_) => ReviewViewModel(
              contact: entry.contact,
              reviews: deps.reviews,
              contacts: deps.contacts,
              now: DateTime.now,
            ),
            child: ReviewScreen(
              brokerName: entry.broker?.name ?? '',
              onBack: () => context.pop(),
              onDone: () => context.pop(),
            ),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootKey,
        path: '${AppRoutes.explore}/properties/:propertyId',
        builder: (BuildContext context, GoRouterState state) {
          final String id = state.pathParameters['propertyId']!;
          return ChangeNotifierProvider<PropertyViewModel>(
            create: (_) => PropertyViewModel(
              propertyId: id,
              properties: deps.properties,
              brokers: deps.brokers,
              contact: deps.contact,
              from: deps.clientPosition.position,
            )..load(),
            child: PropertyScreen(
              onBack: () => context.pop(),
              onOpenBroker: (String bid) =>
                  context.push(AppRoutes.brokerPath(bid)),
            ),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootKey,
        path: AppRoutes.authPhone,
        builder: (BuildContext context, GoRouterState state) {
          final Object? extra = state.extra;
          final AuthRequest request = switch (extra) {
            AuthRequest() => extra,
            // Tolère l'ancien appel qui ne passait qu'un motif.
            final String reason => AuthRequest(reason: reason),
            _ => AuthRequest(reason: context.l10n.authPhoneReasonContact),
          };
          return PhoneScreen(
            reason: request.reason,
            asBroker: request.asBroker,
            onBack: () => context.pop(),
            onSignedIn: () => context.go(_postAuthRoute(deps)),
            onCodeSent: (String phone, String? code, bool asBroker) =>
                context.push(
                  AppRoutes.authOtp,
                  extra: <String, Object?>{
                    'phone': phone,
                    'code': code,
                    'asBroker': asBroker,
                  },
                ),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootKey,
        path: AppRoutes.authOtp,
        builder: (BuildContext context, GoRouterState state) {
          final Map<String, Object?> args =
              (state.extra as Map<String, Object?>?) ?? <String, Object?>{};
          final String? phone = args['phone'] as String?;
          if (phone == null) {
            return const WkErrorState(failure: WkFailure.notFound);
          }
          return OtpScreen(
            phone: phone,
            simulatedCode: args['code'] as String?,
            asBroker: args['asBroker'] == true,
            onBack: () => context.pop(),
            onVerified: () => context.go(_postAuthRoute(deps)),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootKey,
        path: AppRoutes.settings,
        builder: (BuildContext context, GoRouterState state) =>
            ChangeNotifierProvider<SettingsViewModel>.value(
              value: deps.settings,
              child: SettingsScreen(
                onBack: () => context.pop(),
                onOpenCatalog: () => context.push(AppRoutes.catalog),
                onSignIn: () => context.push(
                  AppRoutes.authPhone,
                  extra: _authRequest(context, deps),
                ),
                onSignedOut: () => context.go(AppRoutes.explore),
                // Les données ont changé sous les pieds de l'application :
                // on repart de la racine plutôt que d'afficher un écran
                // construit sur l'ancien jeu.
                onModeChanged: () => context.go(AppRoutes.explore),
                onRoleChanged: () => goToRoleHome(context),
              ),
            ),
      ),
      StatefulShellRoute.indexedStack(
        builder:
            (
              BuildContext context,
              GoRouterState _,
              StatefulNavigationShell shell,
            ) => WkShell(
              navigationShell: shell,
              destinations: <(IconData, String)>[
                (Icons.insights_outlined, context.l10n.brokerHomeTab),
                (Icons.home_work_outlined, context.l10n.tabBrokerProperties),
                (Icons.phone_in_talk_outlined, context.l10n.brokerActivityTab),
                (Icons.storefront_outlined, context.l10n.tabProfile),
              ],
            ),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.brokerHome,
                builder: (BuildContext context, GoRouterState state) =>
                    requireBroker(
                      context,
                      (String brokerId) =>
                          ChangeNotifierProvider<BrokerHomeViewModel>(
                            create: (_) => BrokerHomeViewModel(
                              brokers: deps.brokers,
                              properties: deps.properties,
                              reviews: deps.reviews,
                              contacts: deps.contacts,
                              brokerId: brokerId,
                            )..load(),
                            child: ReloadOnReturn<BrokerHomeViewModel>(
                              reload: (BrokerHomeViewModel model) =>
                                  model.load(),
                              child: BrokerHomeScreen(
                                onAddProperty: () =>
                                    context.push(AppRoutes.propertyEditor),
                                onOpenSettings: () =>
                                    context.push(AppRoutes.settings),
                                onOpenReviews: () =>
                                    context.push(AppRoutes.brokerReviews),
                                onOpenActivity: () =>
                                    context.go(AppRoutes.brokerActivity),
                                onOpenVerification: () =>
                                    context.push(AppRoutes.brokerVerification),
                                onOpenRanking: () =>
                                    context.push(AppRoutes.brokerRanking),
                              ),
                            ),
                          ),
                    ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.brokerProperties,
                builder: (BuildContext context, GoRouterState state) =>
                    requireBroker(
                      context,
                      (String brokerId) =>
                          ChangeNotifierProvider<BrokerPropertiesViewModel>(
                            create: (_) => BrokerPropertiesViewModel(
                              properties: deps.properties,
                              brokerId: brokerId,
                            )..load(),
                            // Le défaut signalé : un bien publié n'apparaissait
                            // pas au retour de l'éditeur, la branche étant
                            // construite une fois pour toutes.
                            child: ReloadOnReturn<BrokerPropertiesViewModel>(
                              reload: (BrokerPropertiesViewModel model) =>
                                  model.load(),
                              child: Builder(
                                builder: (BuildContext inner) =>
                                    BrokerPropertiesScreen(
                                      onAdd: () =>
                                          inner.push(AppRoutes.propertyEditor),
                                      onEdit: (Property property) => inner.push(
                                        AppRoutes.propertyEditor,
                                        extra: property,
                                      ),
                                      onPreview: (Property property) =>
                                          inner.push(
                                            AppRoutes.propertyPreview,
                                            extra: property,
                                          ),
                                    ),
                              ),
                            ),
                          ),
                    ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.brokerActivity,
                builder: (BuildContext context, GoRouterState state) =>
                    requireBroker(
                      context,
                      (String brokerId) =>
                          ChangeNotifierProvider<BrokerActivityViewModel>(
                            create: (_) => BrokerActivityViewModel(
                              contacts: deps.contacts,
                              properties: deps.properties,
                              brokerId: brokerId,
                            )..load(),
                            // Un contact reçu pendant qu'on regardait
                            // ailleurs : l'onglet le montre au retour.
                            child: ReloadOnReturn<BrokerActivityViewModel>(
                              reload: (BrokerActivityViewModel model) =>
                                  model.load(),
                              child: const BrokerActivityScreen(),
                            ),
                          ),
                    ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.brokerProfile,
                builder: (BuildContext context, GoRouterState state) =>
                    requireBroker(
                      context,
                      (String brokerId) =>
                          ChangeNotifierProvider<BrokerViewModel>(
                            create: (_) => BrokerViewModel(
                              brokerId: brokerId,
                              brokers: deps.brokers,
                              properties: deps.properties,
                              reviews: deps.reviews,
                              contact: deps.contact,
                              from: deps.clientPosition.position,
                            )..load(),
                            // B08 revient par un `pop` : sans relecture, le
                            // profil modifié affichait encore l'ancien numéro
                            // et on doutait d'avoir enregistré.
                            child: ReloadOnReturn<BrokerViewModel>(
                              reload: (BrokerViewModel model) => model.load(),
                              child: BrokerProfileScreen(
                                onEditProfile: () => context.push<void>(
                                  AppRoutes.brokerProfileEdit,
                                ),
                                onOpenSettings: () =>
                                    context.push(AppRoutes.settings),
                                onOpenVerification: () =>
                                    context.push(AppRoutes.brokerVerification),
                                onOpenRanking: () =>
                                    context.push(AppRoutes.brokerRanking),
                                onOpenProperty: (Property property) =>
                                    context.push(
                                      AppRoutes.propertyPreview,
                                      extra: property,
                                    ),
                              ),
                            ),
                          ),
                    ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: rootKey,
        path: AppRoutes.propertyPreview,
        builder: (BuildContext context, GoRouterState state) {
          final Property? property = state.extra as Property?;
          if (property == null) {
            return const WkErrorState(failure: WkFailure.notFound);
          }
          return ChangeNotifierProvider<PropertyViewModel>(
            create: (_) => PropertyViewModel(
              propertyId: property.id,
              properties: deps.properties,
              brokers: deps.brokers,
              contact: deps.contact,
              from: deps.clientPosition.position,
            )..load(),
            child: PropertyScreen(
              onBack: () => context.pop(),
              // Aperçu public : le bouton de contact n'a pas de sens pour le
              // courtier qui regarde son propre bien.
              onOpenBroker: (String _) {},
              publicPreview: true,
            ),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootKey,
        path: AppRoutes.brokerProfileEdit,
        builder: (BuildContext context, GoRouterState state) => requireBroker(
          context,
          (String brokerId) =>
              ChangeNotifierProvider<BrokerProfileEditorViewModel>(
                create: (_) => BrokerProfileEditorViewModel(
                  brokers: deps.brokers,
                  brokerId: brokerId,
                )..load(),
                child: BrokerProfileEditorScreen(
                  onBack: () => context.pop(),
                  // Retour à B07, qui se relit : le nouveau numéro doit se
                  // voir tout de suite, sinon on doute d'avoir enregistré.
                  onSaved: () => context.pop(),
                ),
              ),
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootKey,
        path: AppRoutes.brokerVerification,
        builder: (BuildContext context, GoRouterState state) => requireBroker(
          context,
          (String brokerId) => ChangeNotifierProvider<BrokerTrustViewModel>(
            create: (_) => BrokerTrustViewModel(
              brokers: deps.brokers,
              reviews: deps.reviews,
              brokerId: brokerId,
            )..load(),
            child: BrokerVerificationScreen(onBack: () => context.pop()),
          ),
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootKey,
        path: AppRoutes.brokerRanking,
        builder: (BuildContext context, GoRouterState state) => requireBroker(
          context,
          (String brokerId) => ChangeNotifierProvider<BrokerTrustViewModel>(
            create: (_) => BrokerTrustViewModel(
              brokers: deps.brokers,
              reviews: deps.reviews,
              brokerId: brokerId,
            )..load(),
            child: BrokerRankingScreen(onBack: () => context.pop()),
          ),
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootKey,
        path: AppRoutes.brokerReviews,
        builder: (BuildContext context, GoRouterState state) => requireBroker(
          context,
          (String brokerId) => ChangeNotifierProvider<BrokerReviewsViewModel>(
            create: (_) => BrokerReviewsViewModel(
              reviews: deps.reviews,
              brokerId: brokerId,
            )..load(),
            child: BrokerReviewsScreen(onBack: () => context.pop()),
          ),
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootKey,
        path: AppRoutes.propertyEditor,
        builder: (BuildContext context, GoRouterState state) => requireBroker(
          context,
          (String brokerId) => ChangeNotifierProvider<PropertyEditorViewModel>(
            create: (_) => PropertyEditorViewModel(
              properties: deps.properties,
              brokerId: brokerId,
              fallbackPosition: deps.clientPosition.position,
              now: DateTime.now,
              existing: state.extra as Property?,
            ),
            child: PropertyEditorScreen(
              photos: deps.photos,
              voiceNotes: deps.voiceNotes,
              onBack: () => context.pop(),
              // Retour à la liste, qui se recharge : le bien publié doit
              // apparaître immédiatement, sinon on doute d'avoir réussi.
              onSaved: (String _) => context.go(AppRoutes.brokerProperties),
            ),
          ),
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootKey,
        path: AppRoutes.catalog,
        builder: (_, _) => const CatalogScreen(),
      ),
    ],
  );
}

/// Où atterrir après G03/G04.
///
/// La règle de rôle est celle de `AppDependencies.syncRoleWithSession` — la
/// même qu'à la reprise de session — et la destination en découle :
///
/// - profil courtier rattaché : espace courtier, avec S01 qui dit « Courtier »
///   au lieu de continuer d'afficher « Client » derrière un shell courtier ;
/// - rôle courtier sans profil : on renvoyait vers l'espace courtier, lui-même
///   verrouillé faute de profil, et la personne revenait à l'écran
///   « Se connecter » qu'elle venait de quitter. On repasse en client, ce qui
///   est la vérité de son compte, plutôt que de la garder dans une porte
///   tournante.
String _postAuthRoute(AppDependencies deps) =>
    deps.syncRoleWithSession() == UserRole.broker
    ? AppRoutes.brokerHome
    : AppRoutes.explore;
