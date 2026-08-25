import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:go_router/go_router.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart' show TileProvider;
import 'package:woutalma_keur/app/core/app_dependencies.dart';
import 'package:woutalma_keur/app/core/feedback/interaction_feedback.dart';
import 'package:woutalma_keur/app/core/location/client_position_controller.dart';
import 'package:woutalma_keur/app/data/local/cache_status.dart';
import 'package:woutalma_keur/app/data/services/backend_warmup.dart';
import 'package:woutalma_keur/app/domain/auth_service.dart';
import 'package:woutalma_keur/app/l10n/generated/app_l10n.dart';
import 'package:woutalma_keur/app/routes/app_router.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('[wk] erreur de rendu : ${details.exceptionAsString()}');
  };
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint('[wk] erreur non capturée : $error');
    return true;
  };
  if (kDebugMode) {
    SemanticsBinding.instance.ensureSemantics();
  }
  final AppDependencies deps = await AppDependencies.bootstrap();
  runApp(WoutalmaKeurApp(deps: deps));
}

const List<LocalizationsDelegate<Object?>> wkLocalizationsDelegates =
    <LocalizationsDelegate<Object?>>[
      ...AppL10n.localizationsDelegates,
      ...PhoneFieldLocalization.delegates,
    ];

class WoutalmaKeurApp extends StatefulWidget {
  const WoutalmaKeurApp({required this.deps, super.key});

  final AppDependencies deps;

  @override
  State<WoutalmaKeurApp> createState() => _WoutalmaKeurAppState();
}

class _WoutalmaKeurAppState extends State<WoutalmaKeurApp> {
  /// Construit une seule fois : un routeur recréé à chaque build perdrait la
  /// pile de navigation.
  late final GoRouter _router = buildRouter(widget.deps);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<InteractionFeedbackService>.value(value: widget.deps.feedback),
        // Notifiable : les réglages doivent apprendre l'ouverture de session,
        // sinon ils continuent d'afficher « M'identifier » une fois connecté.
        ChangeNotifierProvider<AuthService>.value(value: widget.deps.auth),
        ChangeNotifierProvider<CacheStatus>.value(
          value: widget.deps.cacheStatus,
        ),
        ChangeNotifierProvider<ClientPositionController>.value(
          value: widget.deps.clientPosition,
        ),
        // Inerte en mode local : il n'y a rien à réveiller.
        ChangeNotifierProvider<BackendWarmup>.value(value: widget.deps.warmup),
        // Nul sur le web, où il n'y a pas de disque à remplir.
        Provider<TileProvider?>.value(value: widget.deps.mapTiles),
      ],
      child: MaterialApp.router(
        onGenerateTitle: (BuildContext context) => AppL10n.of(context).appTitle,
        theme: WkTheme.light(),
        darkTheme: WkTheme.dark(),
        // Le thème suit le système tant que le réglage S01 n'existe pas.
        themeMode: ThemeMode.system,
        localizationsDelegates: wkLocalizationsDelegates,
        // Dérivé des fichiers ARB présents : ajouter une langue ne touche pas
        // ce fichier.
        supportedLocales: AppL10n.supportedLocales,
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
