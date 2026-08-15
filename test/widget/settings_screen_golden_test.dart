import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/data/repositories/in_memory_repositories.dart';
import 'package:woutalma_keur/app/domain/auth_service.dart';
import 'package:woutalma_keur/app/modules/settings/settings_screen.dart';
import 'package:woutalma_keur/app/modules/settings/settings_view_model.dart';

import '../support/pump.dart';

void main() {
  // Plus de carte de résumé en tête : elle répétait le titre de l'écran
  // puis chaque réglage juste en dessous. L'écran commence par ses sections.
  testWidgets('les réglages commencent directement par leurs sections', (
    WidgetTester tester,
  ) async {
    final InMemoryStore store = InMemoryStore();
    final InMemorySeedRepository seed = InMemorySeedRepository(store);
    await seed.loadDemoSeed();
    final SettingsViewModel model = SettingsViewModel(seed: seed);
    addTearDown(model.dispose);

    await pumpWk(
      tester,
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>.value(
            value: SimulatedAuthService(),
          ),
          ChangeNotifierProvider<SettingsViewModel>.value(value: model),
        ],
        child: SettingsScreen(
          onOpenCatalog: () {},
          onModeChanged: () {},
          onRoleChanged: () {},
          onSignIn: () {},
          onSignedOut: () {},
        ),
      ),
      surfaceSize: const Size(390, 844),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(SettingsScreen),
      matchesGoldenFile('goldens/settings_screen.png'),
    );
  });
}
