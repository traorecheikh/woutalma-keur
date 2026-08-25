import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/data/repositories/in_memory_repositories.dart';
import 'package:woutalma_keur/app/domain/auth_service.dart';
import 'package:woutalma_keur/app/modules/settings/settings_screen.dart';
import 'package:woutalma_keur/app/modules/settings/settings_view_model.dart';

import '../support/pump.dart';

void main() {
  testWidgets('les réglages restent lisibles à ×1.3', (
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
      textScale: 1.3,
    );

    expect(find.text('Profil'), findsWidgets);
    expect(find.text('Je cherche un logement'), findsWidgets);
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(find.text('Mode démonstration'), findsWidgets);
    expectNoClippedText(tester);
    expectTouchTargets(tester);
  });
}
