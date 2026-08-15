import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/domain/auth_service.dart';
import 'package:woutalma_keur/app/modules/auth/auth_screens.dart';

import '../support/pump.dart';

void main() {
  testWidgets('phone screen sends a normalized Senegal number', (
    WidgetTester tester,
  ) async {
    final SimulatedAuthService auth = SimulatedAuthService();
    String? sentPhone;

    await pumpWk(
      tester,
      ChangeNotifierProvider<AuthService>.value(
        value: auth,
        child: PhoneScreen(
          reason: 'Test',
          onBack: () {},
          onCodeSent: (String phone, String? _, bool _) => sentPhone = phone,
          onSignedIn: () {},
        ),
      ),
      surfaceSize: const Size(360, 640),
      textScale: 1.3,
    );

    expectNoClippedText(tester, userContent: <String>{'77 123 45 67'});
    expectTouchTargets(tester);

    await tester.enterText(find.byType(TextField), '77 123 45 67');
    await tester.tap(find.text('Recevoir le code'));
    await tester.pump();

    expect(sentPhone, '+221771234567');
    expect(find.text('Sénégal +221'), findsOneWidget);
    expect(find.textContaining('+ 221 + 221'), findsNothing);
  });

  testWidgets(
    'phone screen signs in with Google using required button colors',
    (WidgetTester tester) async {
      final SimulatedAuthService auth = SimulatedAuthService();
      bool signedIn = false;

      await pumpWk(
        tester,
        ChangeNotifierProvider<AuthService>.value(
          value: auth,
          child: PhoneScreen(
            reason: 'Test',
            onBack: () {},
            onCodeSent: (_, _, _) {},
            onSignedIn: () => signedIn = true,
          ),
        ),
        surfaceSize: const Size(360, 720),
        textScale: 1.3,
      );

      expect(find.text('Continuer avec Google'), findsOneWidget);
      expect(
        find.image(
          const AssetImage('assets/brand/google_signin_light_square_2x.png'),
        ),
        findsOneWidget,
      );
      expectNoClippedText(tester, userContent: <String>{'77 123 45 67'});
      expectTouchTargets(tester);

      final Material googleButton = tester.widget<Material>(
        find
            .ancestor(
              of: find.text('Continuer avec Google'),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(googleButton.color, const Color(0xFFFFFFFF));
      expect(
        (googleButton.shape! as RoundedRectangleBorder).side.color,
        const Color(0xFF747775),
      );

      await tester.tap(find.text('Continuer avec Google'));
      await tester.pump();

      expect(signedIn, isTrue);
      expect(auth.current?.linkedProviders, contains(AuthProvider.google));
    },
  );

  testWidgets('otp screen verifies automatically after six digits', (
    WidgetTester tester,
  ) async {
    bool verified = false;

    await pumpWk(
      tester,
      ChangeNotifierProvider<AuthService>.value(
        value: SimulatedAuthService(),
        child: OtpScreen(
          phone: '+221771234567',
          simulatedCode: '123456',
          onBack: () {},
          onVerified: () => verified = true,
        ),
      ),
      surfaceSize: const Size(360, 640),
      textScale: 1.3,
    );

    expect(find.text('Code de démonstration : 123456'), findsOneWidget);
    expectNoClippedText(tester);
    expectTouchTargets(tester);

    await tester.enterText(find.byType(TextField), '123456');
    await tester.pump();

    expect(verified, isTrue);
  });
}
