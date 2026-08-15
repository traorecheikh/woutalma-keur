import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/data/repositories/in_memory_repositories.dart';
import 'package:woutalma_keur/app/domain/auth_service.dart';
import 'package:woutalma_keur/app/l10n/generated/app_l10n.dart';
import 'package:woutalma_keur/app/modules/settings/settings_screen.dart';
import 'package:woutalma_keur/app/modules/settings/settings_view_model.dart';

import '../support/pump.dart';

Widget _settings(SettingsViewModel model, AuthService auth) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<SettingsViewModel>.value(value: model),
      ChangeNotifierProvider<AuthService>.value(value: auth),
    ],
    child: SettingsScreen(
      onOpenCatalog: () {},
      onSignIn: () {},
      onSignedOut: () {},
      onModeChanged: () {},
      onRoleChanged: () {},
    ),
  );
}

void main() {
  late SettingsViewModel model;
  late SimulatedAuthService auth;

  setUp(() {
    model = SettingsViewModel(seed: InMemorySeedRepository(InMemoryStore()));
    auth = SimulatedAuthService(
      brokerByPhone: const <String, String>{'221771234567': 'brk-moussa'},
    );
  });

  testWidgets('se connecter pendant que l\'écran est ouvert le met à jour', (
    WidgetTester tester,
  ) async {
    await pumpWk(tester, _settings(model, auth));
    final AppL10n l10n = AppL10n.of(
      tester.element(find.byType(SettingsScreen)),
    );

    expect(find.text(l10n.settingsSignIn), findsOneWidget);

    // Le défaut signalé : la session s'ouvrait et les réglages continuaient
    // d'afficher « M'identifier », parce que l'écran lisait le compte une
    // seule fois et que le service ne prévenait personne.
    await auth.requestCode('+221771234567');
    await auth.verify('+221771234567', '123456');
    await tester.pumpAndSettle();

    expect(find.text(l10n.settingsSignIn), findsNothing);
    expect(find.text(l10n.settingsSignedInAs('+221771234567')), findsOneWidget);
  });

  testWidgets('fermer la session revient à « M\'identifier »', (
    WidgetTester tester,
  ) async {
    await auth.requestCode('+221771234567');
    await auth.verify('+221771234567', '123456');

    await pumpWk(tester, _settings(model, auth));
    final AppL10n l10n = AppL10n.of(
      tester.element(find.byType(SettingsScreen)),
    );

    expect(find.text(l10n.settingsSignIn), findsNothing);

    auth.signOut();
    await tester.pumpAndSettle();

    expect(find.text(l10n.settingsSignIn), findsOneWidget);
  });

  testWidgets('la déconnexion ramène au rôle client', (
    WidgetTester tester,
  ) async {
    await auth.requestCode('+221771234567');
    await auth.verify('+221771234567', '123456');
    model.setRole(UserRole.broker);

    await pumpWk(tester, _settings(model, auth));
    final AppL10n l10n = AppL10n.of(
      tester.element(find.byType(SettingsScreen)),
    );

    await tester.tap(find.text(l10n.settingsSignedInAs('+221771234567')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.settingsSignOut));
    await tester.pumpAndSettle();

    // Rester « courtier » sans session laisserait quatre onglets verrouillés
    // et aucun chemin de retour.
    expect(model.role, UserRole.client);
    expect(auth.current, isNull);
  });
}
