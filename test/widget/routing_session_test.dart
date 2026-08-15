import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' show TileProvider;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/core/app_dependencies.dart';
import 'package:woutalma_keur/app/core/feedback/interaction_feedback.dart';
import 'package:woutalma_keur/app/core/location/client_position_controller.dart';
import 'package:woutalma_keur/app/data/local/cache_status.dart';
import 'package:woutalma_keur/app/data/services/backend_warmup.dart';
import 'package:woutalma_keur/app/domain/auth_service.dart';
import 'package:woutalma_keur/app/modules/auth/auth_screens.dart';
import 'package:woutalma_keur/app/l10n/generated/app_l10n.dart';
import 'package:woutalma_keur/app/modules/settings/settings_view_model.dart';
import 'package:woutalma_keur/app/routes/app_router.dart';
import 'package:woutalma_keur/app/routes/app_routes.dart';
import 'package:woutalma_keur/app/routes/session_landing.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';
import 'package:woutalma_keur/main.dart';

import '../support/fake_location.dart';
import '../support/recording_feedback_service.dart';

/// Le numéro que le jeu de démonstration rattache au profil `brk-moussa`.
const String _brokerPhone = '221771234567';
const String _clientPhone = '221770000000';

/// Monte l'application entière — routeur compris — comme `main.dart`.
Future<GoRouter> _pumpApp(
  WidgetTester tester,
  AppDependencies deps, {
  Duration? landingWindow,
}) async {
  await tester.binding.setSurfaceSize(const Size(360, 800));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final GoRouter router = buildRouter(
    deps,
    sessionLandingWindow: landingWindow,
  );
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<InteractionFeedbackService>.value(
          value: RecordingFeedbackService(),
        ),
        ChangeNotifierProvider<AuthService>.value(value: deps.auth),
        ChangeNotifierProvider<CacheStatus>.value(value: deps.cacheStatus),
        ChangeNotifierProvider<ClientPositionController>.value(
          value: deps.clientPosition,
        ),
        ChangeNotifierProvider<BackendWarmup>.value(value: deps.warmup),
        Provider<TileProvider?>.value(value: null),
      ],
      child: MaterialApp.router(
        theme: WkTheme.light(),
        localizationsDelegates: wkLocalizationsDelegates,
        supportedLocales: AppL10n.supportedLocales,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

String _location(GoRouter router) =>
    router.routerDelegate.currentConfiguration.uri.path;

Future<AppDependencies> _deps() async {
  final AppDependencies deps = await AppDependencies.inMemory(
    location: FakeLocationService(),
  );
  // C01 n'ouvre pas la feuille d'explication M06 au premier rendu : ce n'est
  // pas ce qui est testé ici.
  await deps.clientPosition.markPrimed();
  return deps;
}

void main() {
  group('SessionLanding', () {
    test('rejoint l\'espace courtier quand la session revient', () async {
      final Completer<void> restore = Completer<void>();
      final SessionLanding landing = SessionLanding(
        restore: restore.future,
        belongsToBrokerSpace: () => true,
      );

      // Premier écran : la réponse n'est pas là, on ne déplace personne.
      expect(landing.redirect(AppRoutes.explore), isNull);

      restore.complete();
      await Future<void>.delayed(Duration.zero);

      expect(landing.redirect(AppRoutes.explore), AppRoutes.brokerHome);
      // Une seule fois : la redirection ne se rejoue pas à chaque navigation.
      expect(landing.redirect(AppRoutes.explore), isNull);
    });

    test('ne déplace pas un compte sans profil courtier', () async {
      final SessionLanding landing = SessionLanding(
        restore: Future<void>.value(),
        belongsToBrokerSpace: () => false,
      );
      await Future<void>.delayed(Duration.zero);

      expect(landing.redirect(AppRoutes.explore), isNull);
    });

    test('ne déplace personne qui est déjà parti ailleurs', () async {
      final Completer<void> restore = Completer<void>();
      final SessionLanding landing = SessionLanding(
        restore: restore.future,
        belongsToBrokerSpace: () => true,
      );

      // L'utilisateur ouvre un autre onglet avant la réponse du serveur.
      expect(landing.redirect(AppRoutes.contacts), isNull);
      expect(landing.settled, isTrue);

      restore.complete();
      await Future<void>.delayed(Duration.zero);

      expect(landing.redirect(AppRoutes.explore), isNull);
    });

    test('une réponse trop tardive n\'est plus une reprise', () async {
      final SessionLanding landing = SessionLanding(
        restore: Future<void>.value(),
        belongsToBrokerSpace: () => true,
        window: Duration.zero,
      );
      await Future<void>.delayed(const Duration(milliseconds: 5));

      expect(landing.redirect(AppRoutes.explore), isNull);
    });
  });

  testWidgets('une session courtier reprise rouvre l\'espace courtier', (
    WidgetTester tester,
  ) async {
    final AppDependencies deps = await _deps();
    final Completer<void> restore = Completer<void>();
    deps.sessionRestore = restore.future;

    final GoRouter router = await _pumpApp(tester, deps);

    // Le premier écran est peint sans attendre le réseau : c'est la
    // découverte, publique.
    expect(_location(router), AppRoutes.explore);

    // Le serveur répond : le compte porte un profil courtier.
    await deps.auth.requestCode(_brokerPhone);
    await deps.auth.verify(_brokerPhone, '123456');
    // Ce que fait `AppDependencies.bootstrap` juste avant de rendre la main :
    // la même règle de rôle, au même moment.
    deps.syncRoleWithSession();
    restore.complete();
    await tester.pumpAndSettle();

    expect(_location(router), AppRoutes.brokerHome);
    // Et S01 dit « Courtier » : le shell et le rôle ne se contredisent pas.
    expect(deps.settings.role, UserRole.broker);
  });

  testWidgets('une session cliente laisse l\'application où elle est', (
    WidgetTester tester,
  ) async {
    final AppDependencies deps = await _deps();
    final Completer<void> restore = Completer<void>();
    deps.sessionRestore = restore.future;

    final GoRouter router = await _pumpApp(tester, deps);

    await deps.auth.requestCode(_clientPhone);
    await deps.auth.verify(_clientPhone, '123456');
    deps.syncRoleWithSession();
    restore.complete();
    await tester.pumpAndSettle();

    expect(_location(router), AppRoutes.explore);
  });

  testWidgets('une réponse tardive ne déplace pas quelqu\'un qui navigue', (
    WidgetTester tester,
  ) async {
    final AppDependencies deps = await _deps();
    final Completer<void> restore = Completer<void>();
    deps.sessionRestore = restore.future;

    final GoRouter router = await _pumpApp(tester, deps);
    router.go(AppRoutes.contacts);
    await tester.pumpAndSettle();

    await deps.auth.requestCode(_brokerPhone);
    await deps.auth.verify(_brokerPhone, '123456');
    deps.syncRoleWithSession();
    restore.complete();
    await tester.pumpAndSettle();

    expect(_location(router), AppRoutes.contacts);
  });

  testWidgets('l\'espace courtier verrouillé garde une porte de sortie', (
    WidgetTester tester,
  ) async {
    final AppDependencies deps = await _deps();
    final GoRouter router = await _pumpApp(tester, deps);

    // Personne n'est identifié : c'est exactement l'état où les quatre
    // onglets courtier se verrouillent ensemble.
    deps.settings.setRole(UserRole.broker);
    router.go(AppRoutes.brokerHome);
    await tester.pumpAndSettle();

    final AppL10n l10n = AppL10n.of(
      tester.element(find.byType(Scaffold).first),
    );
    expect(find.text(l10n.brokerSignInRequiredBody), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(_location(router), AppRoutes.explore);
    // Le rôle suit : rester « courtier » ferait revenir sur la même porte.
    expect(deps.settings.role, UserRole.client);
  });

  testWidgets('changer de rôle sans profil courtier demande d\'abord le '
      'téléphone', (WidgetTester tester) async {
    final AppDependencies deps = await _deps();
    final GoRouter router = await _pumpApp(tester, deps);

    router.go(AppRoutes.clientProfile);
    await tester.pumpAndSettle();

    final AppL10n l10n = AppL10n.of(
      tester.element(find.byType(Scaffold).first),
    );
    await tester.tap(find.text(l10n.roleClient).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.roleBroker).last);
    await tester.pumpAndSettle();

    // On ne bascule pas dans un espace courtier qui n'aurait que des écrans
    // verrouillés à offrir : G03 s'ouvre par-dessus l'espace client, qui reste
    // dessous — annuler ramène donc aux réglages, pas sur une porte fermée.
    expect(deps.settings.role, UserRole.broker);
    expect(find.byType(PhoneScreen), findsOneWidget);
    expect(_location(router), AppRoutes.clientProfile);
  });
}
