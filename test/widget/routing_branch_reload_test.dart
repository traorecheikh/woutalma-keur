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
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/l10n/generated/app_l10n.dart';
import 'package:woutalma_keur/app/routes/app_router.dart';
import 'package:woutalma_keur/app/routes/app_routes.dart';
import 'package:woutalma_keur/app/routes/reload_on_return.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';
import 'package:woutalma_keur/main.dart';

import '../support/fake_location.dart';
import '../support/recording_feedback_service.dart';

const String _brokerPhone = '221771234567';

/// Modèle minimal : seul le fait d'être relu compte ici.
class _Counter extends ChangeNotifier {
  int loads = 0;

  void load() => loads++;
}

/// Reproduit ce que `StatefulShellRoute.indexedStack` fait de ses branches :
/// tout reste construit, seul le `TickerMode` distingue l'onglet visible.
class _Branches extends StatefulWidget {
  const _Branches({required this.model});

  final _Counter model;

  @override
  State<_Branches> createState() => _BranchesState();
}

class _BranchesState extends State<_Branches> {
  int _index = 0;

  void show(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: _index,
      children: <Widget>[
        Offstage(
          offstage: _index != 0,
          child: TickerMode(
            enabled: _index == 0,
            child: ChangeNotifierProvider<_Counter>.value(
              value: widget.model,
              child: ReloadOnReturn<_Counter>(
                reload: (_Counter model) => model.load(),
                child: const SizedBox.shrink(),
              ),
            ),
          ),
        ),
        Offstage(
          offstage: _index != 1,
          child: TickerMode(
            enabled: _index == 1,
            child: const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}

Future<GoRouter> _pumpApp(WidgetTester tester, AppDependencies deps) async {
  await tester.binding.setSurfaceSize(const Size(360, 800));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final GoRouter router = buildRouter(deps);
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

void main() {
  testWidgets('la première construction ne relit pas : le modèle vient d\'être '
      'chargé', (WidgetTester tester) async {
    final _Counter model = _Counter();
    await tester.pumpWidget(MaterialApp(home: _Branches(model: model)));

    expect(model.loads, 0);
  });

  testWidgets('revenir sur une branche la relit, la quitter ne fait rien', (
    WidgetTester tester,
  ) async {
    final _Counter model = _Counter();
    await tester.pumpWidget(MaterialApp(home: _Branches(model: model)));
    final _BranchesState branches = tester.state(find.byType(_Branches));

    branches.show(1);
    await tester.pumpAndSettle();
    expect(model.loads, 0, reason: 'quitter un onglet ne relit rien');

    branches.show(0);
    await tester.pumpAndSettle();
    expect(model.loads, 1);

    // Et pas une relecture par reconstruction : rester sur place ne coûte
    // aucune requête.
    await tester.pump();
    expect(model.loads, 1);
  });

  testWidgets('« Mes biens » montre un bien créé pendant qu\'on était '
      'ailleurs', (WidgetTester tester) async {
    final AppDependencies deps = await AppDependencies.inMemory(
      location: FakeLocationService(),
    );
    await deps.clientPosition.markPrimed();
    await deps.auth.requestCode(_brokerPhone);
    await deps.auth.verify(_brokerPhone, '123456');

    final GoRouter router = await _pumpApp(tester, deps);
    router.go(AppRoutes.brokerProperties);
    await tester.pumpAndSettle();

    const String title = 'Villa neuve aux Almadies';
    // La branche est bien construite et chargée avant qu'on la quitte.
    expect(find.text('Maison 4 pièces à Médina'), findsOneWidget);
    expect(find.text(title), findsNothing);

    // On part sur un autre onglet, et le bien est publié entre-temps —
    // exactement ce que fait l'éditeur B03 avant de revenir par `go`.
    router.go(AppRoutes.brokerHome);
    await tester.pumpAndSettle();
    await deps.properties.save(
      Property(
        id: 'prp-test',
        brokerId: 'brk-moussa',
        kind: PropertyKind.house,
        transaction: TransactionKind.sale,
        title: title,
        price: 95000000,
        position: const GeoPoint(14.744, -17.513),
        neighbourhood: 'Almadies',
        createdAt: DateTime(2026, 8, 13),
      ),
    );

    router.go(AppRoutes.brokerProperties);
    await tester.pumpAndSettle();

    // Le défaut signalé : la liste restait sur « Aucun bien publié », ou sur
    // son ancien contenu, parce que la branche n'était construite qu'une fois.
    expect(find.text(title), findsOneWidget);
  });

  testWidgets('le profil courtier revient à jour après une modification', (
    WidgetTester tester,
  ) async {
    final AppDependencies deps = await AppDependencies.inMemory(
      location: FakeLocationService(),
    );
    await deps.clientPosition.markPrimed();
    await deps.auth.requestCode(_brokerPhone);
    await deps.auth.verify(_brokerPhone, '123456');

    final GoRouter router = await _pumpApp(tester, deps);
    router.go(AppRoutes.brokerProfile);
    await tester.pumpAndSettle();

    final Broker before = (await deps.brokers.byId('brk-moussa'))!;
    expect(find.text(before.name), findsWidgets);

    // B08 enregistre puis revient par un `pop` : sans relecture, B07
    // affichait encore l'ancienne fiche et on doutait d'avoir enregistré.
    router.go(AppRoutes.brokerHome);
    await tester.pumpAndSettle();
    await deps.brokers.save(
      Broker(
        id: before.id,
        kind: before.kind,
        name: 'Moussa Diop et Fils',
        phone: before.phone,
        position: before.position,
        coverage: before.coverage,
        whatsapp: before.whatsapp,
        logoAsset: before.logoAsset,
        verification: before.verification,
        responseRate: before.responseRate,
        pinned: before.pinned,
      ),
    );

    router.go(AppRoutes.brokerProfile);
    await tester.pumpAndSettle();

    expect(find.text('Moussa Diop et Fils'), findsWidgets);
  });
}
