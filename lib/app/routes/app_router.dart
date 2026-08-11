import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/core/app_dependencies.dart';
import 'package:woutalma_keur/app/core/state/screen_state.dart';
import 'package:woutalma_keur/app/modules/catalog/catalog_screen.dart';
import 'package:woutalma_keur/app/modules/client/broker/broker_screen.dart';
import 'package:woutalma_keur/app/modules/client/broker/broker_view_model.dart';
import 'package:woutalma_keur/app/modules/auth/auth_screens.dart';
import 'package:woutalma_keur/app/modules/broker/broker_activity_screen.dart';
import 'package:woutalma_keur/app/modules/broker/broker_home_screen.dart';
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
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_states.dart';

/// Routeur de l'application.
///
/// Seuls les chemins réellement implémentés sont déclarés : une route sans
/// écran casse un lien profond sans prévenir.
GoRouter buildRouter(AppDependencies deps) {
  final GlobalKey<NavigatorState> rootKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: AppRoutes.explore,
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
                        voice: deps.voice,
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
                          extra: context.l10n.authPhoneReasonContact,
                        ),
                        onModeChanged: () => context.go(AppRoutes.explore),
                        onRoleChanged: () => context.go(
                          deps.settings.role == UserRole.broker
                              ? AppRoutes.brokerHome
                              : AppRoutes.explore,
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
              from: deps.clientPosition,
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
              from: deps.clientPosition,
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
        builder: (BuildContext context, GoRouterState state) => PhoneScreen(
          reason:
              (state.extra as String?) ?? context.l10n.authPhoneReasonContact,
          onBack: () => context.pop(),
          onCodeSent: (String phone, String? code) => context.push(
            AppRoutes.authOtp,
            extra: <String, String?>{'phone': phone, 'code': code},
          ),
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootKey,
        path: AppRoutes.authOtp,
        builder: (BuildContext context, GoRouterState state) {
          final Map<String, String?> args =
              (state.extra as Map<String, String?>?) ?? <String, String?>{};
          final String? phone = args['phone'];
          if (phone == null) {
            return const WkErrorState(failure: WkFailure.notFound);
          }
          return OtpScreen(
            phone: phone,
            simulatedCode: args['code'],
            onBack: () => context.pop(),
            onVerified: () => context.go(
              deps.auth.current?.brokerId != null
                  ? AppRoutes.brokerHome
                  : AppRoutes.explore,
            ),
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
                  extra: deps.settings.role == UserRole.broker
                      ? context.l10n.authPhoneReasonBroker
                      : context.l10n.authPhoneReasonContact,
                ),
                // Les données ont changé sous les pieds de l'application :
                // on repart de la racine plutôt que d'afficher un écran
                // construit sur l'ancien jeu.
                onModeChanged: () => context.go(AppRoutes.explore),
                // Changer de rôle change tout l'arbre : on repart de la
                // racine du nouveau rôle plutôt que d'empiler deux mondes.
                onRoleChanged: () => context.go(
                  deps.settings.role == UserRole.broker
                      ? AppRoutes.brokerHome
                      : AppRoutes.explore,
                ),
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
                    ChangeNotifierProvider<BrokerHomeViewModel>(
                      create: (_) => BrokerHomeViewModel(
                        brokers: deps.brokers,
                        properties: deps.properties,
                        reviews: deps.reviews,
                        contacts: deps.contacts,
                        brokerId: deps.currentBrokerId,
                      )..load(),
                      child: BrokerHomeScreen(
                        onAddProperty: () =>
                            context.push(AppRoutes.propertyEditor),
                        onOpenSettings: () => context.push(AppRoutes.settings),
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
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.brokerProperties,
                builder: (BuildContext context, GoRouterState state) =>
                    ChangeNotifierProvider<BrokerPropertiesViewModel>(
                      create: (_) => BrokerPropertiesViewModel(
                        properties: deps.properties,
                        brokerId: deps.currentBrokerId,
                      )..load(),
                      child: Builder(
                        builder: (BuildContext inner) => BrokerPropertiesScreen(
                          onAdd: () => inner.push(AppRoutes.propertyEditor),
                          onEdit: (Property property) => inner.push(
                            AppRoutes.propertyEditor,
                            extra: property,
                          ),
                          onPreview: (Property property) => inner.push(
                            AppRoutes.propertyPreview,
                            extra: property,
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
                    ChangeNotifierProvider<BrokerActivityViewModel>(
                      create: (_) => BrokerActivityViewModel(
                        contacts: deps.contacts,
                        properties: deps.properties,
                        brokerId: deps.currentBrokerId,
                      )..load(),
                      child: const BrokerActivityScreen(),
                    ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.brokerProfile,
                builder: (BuildContext context, GoRouterState state) =>
                    ChangeNotifierProvider<BrokerViewModel>(
                      create: (_) => BrokerViewModel(
                        brokerId: deps.currentBrokerId,
                        brokers: deps.brokers,
                        properties: deps.properties,
                        reviews: deps.reviews,
                        contact: deps.contact,
                        from: deps.clientPosition,
                      )..load(),
                      child: BrokerProfileScreen(
                        onOpenSettings: () => context.push(AppRoutes.settings),
                        onOpenVerification: () =>
                            context.push(AppRoutes.brokerVerification),
                        onOpenRanking: () =>
                            context.push(AppRoutes.brokerRanking),
                        onOpenProperty: (Property property) => context.push(
                          AppRoutes.propertyPreview,
                          extra: property,
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
              from: deps.clientPosition,
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
        path: AppRoutes.brokerVerification,
        builder: (BuildContext context, GoRouterState state) =>
            ChangeNotifierProvider<BrokerTrustViewModel>(
              create: (_) => BrokerTrustViewModel(
                brokers: deps.brokers,
                reviews: deps.reviews,
                brokerId: deps.currentBrokerId,
              )..load(),
              child: BrokerVerificationScreen(onBack: () => context.pop()),
            ),
      ),
      GoRoute(
        parentNavigatorKey: rootKey,
        path: AppRoutes.brokerRanking,
        builder: (BuildContext context, GoRouterState state) =>
            ChangeNotifierProvider<BrokerTrustViewModel>(
              create: (_) => BrokerTrustViewModel(
                brokers: deps.brokers,
                reviews: deps.reviews,
                brokerId: deps.currentBrokerId,
              )..load(),
              child: BrokerRankingScreen(onBack: () => context.pop()),
            ),
      ),
      GoRoute(
        parentNavigatorKey: rootKey,
        path: AppRoutes.brokerReviews,
        builder: (BuildContext context, GoRouterState state) =>
            ChangeNotifierProvider<BrokerReviewsViewModel>(
              create: (_) => BrokerReviewsViewModel(
                reviews: deps.reviews,
                brokerId: deps.currentBrokerId,
              )..load(),
              child: BrokerReviewsScreen(onBack: () => context.pop()),
            ),
      ),
      GoRoute(
        parentNavigatorKey: rootKey,
        path: AppRoutes.propertyEditor,
        builder: (BuildContext context, GoRouterState state) =>
            ChangeNotifierProvider<PropertyEditorViewModel>(
              create: (_) => PropertyEditorViewModel(
                properties: deps.properties,
                brokerId: deps.currentBrokerId,
                fallbackPosition: deps.clientPosition,
                now: DateTime.now,
                existing: state.extra as Property?,
              ),
              child: PropertyEditorScreen(
                photos: deps.photos,
                onBack: () => context.pop(),
                // Retour à la liste, qui se recharge : le bien publié doit
                // apparaître immédiatement, sinon on doute d'avoir réussi.
                onSaved: (String _) => context.go(AppRoutes.brokerProperties),
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
