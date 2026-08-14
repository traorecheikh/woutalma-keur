import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
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
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kDebugMode) {
    // Matérialise l'arbre sémantique en debug. L'accessibilité est une
    // contrainte produit ici : elle doit être inspectable à tout moment, pas
    // seulement quand un lecteur d'écran tourne.
    SemanticsBinding.instance.ensureSemantics();
  }
  // `bootstrap` retombe seul sur le magasin mémoire là où aucune base native
  // n'existe : l'appelant n'a pas à connaître la plateforme.
  final AppDependencies deps = await AppDependencies.bootstrap();
  runApp(WoutalmaKeurApp(deps: deps));
}

/// Toutes les délégations de localisation de l'application.
///
/// Nommée plutôt qu'écrite en ligne : c'est ce qu'un test peut vérifier, et
/// c'est la liste que le prochain paquet à traduire devra rejoindre. Sans
/// celles de `phone_form_field`, le sélecteur de pays s'ouvrait en anglais —
/// « Search », « Algeria », « Germany » — au milieu d'une application qui ne
/// parle que français.
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
        Provider<AuthService>.value(value: widget.deps.auth),
        ChangeNotifierProvider<CacheStatus>.value(
          value: widget.deps.cacheStatus,
        ),
        ChangeNotifierProvider<ClientPositionController>.value(
          value: widget.deps.clientPosition,
        ),
        // Nul en mode local : il n'y a rien à réveiller.
        Provider<BackendWarmup?>.value(value: widget.deps.warmup),
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
