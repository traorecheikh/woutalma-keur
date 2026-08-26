import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_map/flutter_map.dart' show TileProvider;
import 'package:forui/forui.dart' show FLocalizations, FTheme, FToaster;
import 'package:go_router/go_router.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/core/app_dependencies.dart';
import 'package:woutalma_keur/app/core/feedback/interaction_feedback.dart';
import 'package:woutalma_keur/app/core/location/client_position_controller.dart';
import 'package:woutalma_keur/app/data/local/cache_status.dart';
import 'package:woutalma_keur/app/data/services/backend_warmup.dart';
import 'package:woutalma_keur/app/data/services/session_expiry.dart';
import 'package:woutalma_keur/app/domain/auth_service.dart';
import 'package:woutalma_keur/app/l10n/generated/app_l10n.dart';
import 'package:woutalma_keur/app/routes/app_router.dart';
import 'package:woutalma_keur/app/routes/app_routes.dart';
import 'package:woutalma_keur/app/ui/theme.dart';
import 'package:woutalma_keur/app/ui/ui.dart' show toast;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('[wk] erreur de rendu : ${details.exceptionAsString()}');
  };
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    // Rendre la main empêche l'application de mourir sur une erreur
    // asynchrone ; sans trace, elle mourait en silence et personne ne savait
    // pourquoi.
    if (kDebugMode) {
      FlutterError.presentError(
        FlutterErrorDetails(exception: error, stack: stack),
      );
    }
    debugPrint('[wk] erreur non capturée : $error\n$stack');
    return true;
  };
  if (kDebugMode) SemanticsBinding.instance.ensureSemantics();
  AppDependencies deps;
  try {
    deps = await AppDependencies.bootstrap();
  } on Object catch (error, stack) {
    // Disque plein, base abîmée, trousseau bloqué : l'application démarrait
    // sur un écran noir définitif. Elle repart sans copie hors ligne, et le
    // dit.
    debugPrint('[wk] démarrage sans stockage local : $error\n$stack');
    deps = await AppDependencies.withoutLocalStore();
  }
  runApp(WoutalmaKeurApp(deps: deps));
}

const List<LocalizationsDelegate<Object?>> wkLocalizationsDelegates =
    <LocalizationsDelegate<Object?>>[
      ...AppL10n.localizationsDelegates,
      ...PhoneFieldLocalization.delegates,
      FLocalizations.delegate,
    ];

class WoutalmaKeurApp extends StatefulWidget {
  const WoutalmaKeurApp({required this.deps, super.key});

  final AppDependencies deps;

  @override
  State<WoutalmaKeurApp> createState() => _WoutalmaKeurAppState();
}

class _WoutalmaKeurAppState extends State<WoutalmaKeurApp> {
  late final GoRouter _router = buildRouter(widget.deps);
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // Une instance gratuite se rendort au bout de quinze minutes : revenir
    // dans l'application est le bon moment pour la réveiller, et pour
    // rattraper une reprise de session que le démarrage à froid avait ratée.
    _lifecycle = AppLifecycleListener(
      onResume: () {
        widget.deps.warmup.start();
        widget.deps.refreshSession().ignore();
      },
    );
    widget.deps.sessionExpiry.addListener(_onSessionExpired);
  }

  @override
  void dispose() {
    widget.deps.sessionExpiry.removeListener(_onSessionExpired);
    _lifecycle.dispose();
    super.dispose();
  }

  /// Session morte et non renouvelable : on ferme ce qui reste ouvert et on
  /// ramène à l'identification, en le disant. Sans cela, le compte restait
  /// affiché comme connecté et chaque écran courtier répondait 401.
  void _onSessionExpired() {
    if (!widget.deps.sessionExpiry.isExpired) return;
    widget.deps.sessionExpiry.acknowledge();
    widget.deps.auth.signOut();
    widget.deps.syncRoleWithSession();
    _router.go(AppRoutes.authPhone);
    final BuildContext? shown =
        _router.routerDelegate.navigatorKey.currentContext;
    if (shown != null) toast(shown, AppL10n.of(shown).sessionExpired);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<InteractionFeedbackService>.value(value: widget.deps.feedback),
        ChangeNotifierProvider<AuthService>.value(value: widget.deps.auth),
        ChangeNotifierProvider<SessionExpiry>.value(
          value: widget.deps.sessionExpiry,
        ),
        ChangeNotifierProvider<CacheStatus>.value(
          value: widget.deps.cacheStatus,
        ),
        ChangeNotifierProvider<ClientPositionController>.value(
          value: widget.deps.clientPosition,
        ),
        ChangeNotifierProvider<BackendWarmup>.value(value: widget.deps.warmup),
        Provider<TileProvider?>.value(value: widget.deps.mapTiles),
      ],
      child: MaterialApp.router(
        onGenerateTitle: (BuildContext context) => AppL10n.of(context).appTitle,
        theme: buildTheme(Brightness.light),
        darkTheme: buildTheme(Brightness.dark),
        themeMode: ThemeMode.system,
        localizationsDelegates: wkLocalizationsDelegates,
        supportedLocales: AppL10n.supportedLocales,
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
        builder: (context, child) => FTheme(
          data: buildForuiTheme(
            Theme.of(context).brightness,
            reduceMotion: MediaQuery.disableAnimationsOf(context),
          ),
          child: FToaster(child: child!),
        ),
      ),
    );
  }
}
