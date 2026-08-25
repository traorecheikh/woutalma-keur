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
import 'package:woutalma_keur/app/domain/auth_service.dart';
import 'package:woutalma_keur/app/l10n/generated/app_l10n.dart';
import 'package:woutalma_keur/app/routes/app_router.dart';
import 'package:woutalma_keur/app/ui/theme.dart';

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
  if (kDebugMode) SemanticsBinding.instance.ensureSemantics();
  final AppDependencies deps = await AppDependencies.bootstrap();
  runApp(WoutalmaKeurApp(deps: deps));
}

const List<LocalizationsDelegate<Object?>> wkLocalizationsDelegates =
    <LocalizationsDelegate<Object?>>[
      ...AppL10n.localizationsDelegates,
      ...PhoneFieldLocalization.delegates,
      FLocalizations.delegate,
    ];

final _forui = {for (final b in Brightness.values) b: buildForuiTheme(b)};

class WoutalmaKeurApp extends StatefulWidget {
  const WoutalmaKeurApp({required this.deps, super.key});

  final AppDependencies deps;

  @override
  State<WoutalmaKeurApp> createState() => _WoutalmaKeurAppState();
}

class _WoutalmaKeurAppState extends State<WoutalmaKeurApp> {
  late final GoRouter _router = buildRouter(widget.deps);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<InteractionFeedbackService>.value(value: widget.deps.feedback),
        ChangeNotifierProvider<AuthService>.value(value: widget.deps.auth),
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
        themeMode: ThemeMode.light,
        localizationsDelegates: wkLocalizationsDelegates,
        supportedLocales: AppL10n.supportedLocales,
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
        builder: (context, child) => FTheme(
          data: _forui[Theme.of(context).brightness]!,
          child: FToaster(child: child!),
        ),
      ),
    );
  }
}
