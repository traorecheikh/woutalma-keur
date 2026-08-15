import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_keur/app/data/local/cache_status.dart';
import 'package:woutalma_keur/app/l10n/generated/app_l10n.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_connection_banner.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_scaffold.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_top_bar.dart';

import 'package:woutalma_keur/main.dart';

import '../support/pump.dart';

void main() {
  testWidgets('la coquille pose le bandeau sur n\'importe quel écran', (
    WidgetTester tester,
  ) async {
    final CacheStatus status = CacheStatus()..markStale(DateTime.now());

    await pumpWk(
      tester,
      const WkScaffold(
        topBar: WkTopBar(title: 'Fiche courtier'),
        body: SizedBox.shrink(),
      ),
      cacheStatus: status,
    );

    // Le bandeau ne vivait que sur Explorer : ailleurs, une donnée vieille de
    // deux heures ressemblait à une donnée fraîche.
    expect(find.byType(WkConnectionBanner), findsOneWidget);
    expect(find.byIcon(Icons.cloud_off), findsOneWidget);
  });

  testWidgets('rien ne s\'affiche quand tout va bien', (
    WidgetTester tester,
  ) async {
    await pumpWk(
      tester,
      const WkScaffold(body: SizedBox.shrink()),
      cacheStatus: CacheStatus()..markFresh(DateTime.now()),
    );

    // Un bandeau permanent finit par ne plus être lu.
    expect(find.byIcon(Icons.cloud_off), findsNothing);
    expect(find.byIcon(Icons.hourglass_bottom), findsNothing);
  });

  testWidgets('un écran monté hors providers ne casse pas', (
    WidgetTester tester,
  ) async {
    // Thème et traductions, mais aucun CacheStatus ni BackendWarmup : la
    // coquille est désormais partout, y compris dans des tests qui ne montent
    // aucun de ces services. Absent le service, il n'y a rien à annoncer —
    // et surtout rien à faire planter.
    await tester.pumpWidget(
      MaterialApp(
        theme: WkTheme.light(),
        localizationsDelegates: wkLocalizationsDelegates,
        supportedLocales: AppL10n.supportedLocales,
        home: const WkScaffold(body: SizedBox.shrink()),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(WkConnectionBanner), findsOneWidget);
    expect(find.byIcon(Icons.cloud_off), findsNothing);
  });
}
