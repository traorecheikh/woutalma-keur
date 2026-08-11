import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_keur/app/shared/theme/wk_colors.dart';
import 'package:woutalma_keur/app/shared/theme/wk_motion.dart';
import 'package:woutalma_keur/app/shared/theme/wk_spacing.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';
import 'package:woutalma_keur/app/shared/theme/wk_typography.dart';

void main() {
  Future<BuildContext> pumpThemed(
    WidgetTester tester, {
    ThemeData? theme,
    bool disableAnimations = false,
    double textScale = 1,
  }) async {
    late BuildContext captured;
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(
          disableAnimations: disableAnimations,
          textScaler: TextScaler.linear(textScale),
        ),
        child: MaterialApp(
          theme: theme ?? WkTheme.light(),
          home: Builder(
            builder: (BuildContext context) {
              captured = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    return captured;
  }

  group('jetons de couleur', () {
    testWidgets('context.colors sert le marine en thème clair', (
      WidgetTester tester,
    ) async {
      final BuildContext context = await pumpThemed(tester);

      expect(context.colors.primary, const Color(0xFF0B3B66));
      expect(context.colors.background, const Color(0xFFF3F5F7));
    });

    testWidgets('le thème sombre change le primaire, pas les sémantiques', (
      WidgetTester tester,
    ) async {
      final BuildContext context = await pumpThemed(
        tester,
        theme: WkTheme.dark(),
      );

      expect(context.colors.primary, const Color(0xFF7FB3E0));
      // Appeler et WhatsApp gardent leur identité dans les deux modes : ce
      // sont des marques externes reconnues avant lecture.
      expect(context.colors.call, WkColors.light.call);
      expect(context.colors.whatsapp, WkColors.light.whatsapp);
    });
  });

  group('typographie', () {
    testWidgets('le corps par défaut est à 18, pas à 16', (
      WidgetTester tester,
    ) async {
      final BuildContext context = await pumpThemed(tester);

      expect(context.text.bodyLarge?.fontSize, WkTypography.bodyDefaultSize);
      expect(WkTypography.bodyDefaultSize, 18);
    });

    testWidgets('aucun emplacement ne descend sous le plancher', (
      WidgetTester tester,
    ) async {
      final BuildContext context = await pumpThemed(tester);
      final TextTheme t = context.text;

      final Iterable<double?> sizes = <TextStyle?>[
        t.displayLarge,
        t.displayMedium,
        t.headlineLarge,
        t.headlineMedium,
        t.bodyLarge,
        t.bodyMedium,
        t.bodySmall,
        t.labelLarge,
        t.labelMedium,
        t.labelSmall,
      ].map((TextStyle? s) => s?.fontSize);

      for (final double? size in sizes) {
        expect(size, isNotNull);
        expect(size, greaterThanOrEqualTo(WkTypography.floorSize));
      }
    });

    test('notre échelle ne déclare aucune famille', () {
      // `ThemeData` résout ensuite vers la police de la plateforme — Roboto
      // sur Android, SF sur iOS. C'est exactement le but : on n'impose rien,
      // donc l'utilisateur garde la police de son système et ses réglages
      // d'accessibilité.
      final TextTheme ours = WkTypography.textTheme(const Color(0xFF000000));

      for (final TextStyle? style in <TextStyle?>[
        ours.displayLarge,
        ours.headlineLarge,
        ours.bodyLarge,
        ours.labelSmall,
      ]) {
        expect(style?.fontFamily, isNull);
      }
    });

    test('aucune police n\'est embarquée dans le paquet', () {
      // La règle « pas de police téléchargée ni embarquée » se vérifie ici et
      // pas dans une revue : sur 2G, une police distante afficherait un
      // substitut pendant plusieurs secondes, ou rien hors ligne.
      final String pubspec = File('pubspec.yaml').readAsStringSync();

      expect(pubspec.contains('google_fonts'), isFalse);
      expect(
        RegExp(r'^\s{2}fonts:', multiLine: true).hasMatch(pubspec),
        isFalse,
        reason: 'pubspec.yaml déclare une section fonts:',
      );
    });
  });

  group('mouvement', () {
    testWidgets('les durées tombent à zéro en mouvement réduit', (
      WidgetTester tester,
    ) async {
      final BuildContext context = await pumpThemed(
        tester,
        disableAnimations: true,
      );

      expect(context.motion.reduced, isTrue);
      expect(context.motion.standard, Duration.zero);
      expect(context.motion.instant, Duration.zero);
    });

    testWidgets('les durées nominales sortent les valeurs de DESIGN', (
      WidgetTester tester,
    ) async {
      final BuildContext context = await pumpThemed(tester);

      expect(context.motion.instant, const Duration(milliseconds: 80));
      expect(context.motion.fast, const Duration(milliseconds: 140));
      expect(context.motion.standard, const Duration(milliseconds: 220));
      expect(context.motion.slow, const Duration(milliseconds: 320));
    });

    testWidgets('un message transitoire dure plus longtemps en gros texte', (
      WidgetTester tester,
    ) async {
      final BuildContext normal = await pumpThemed(tester);
      expect(WkMotion.transientFor(normal), WkMotion.transient);

      final BuildContext large = await pumpThemed(tester, textScale: 1.3);
      expect(WkMotion.transientFor(large), WkMotion.transientAssisted);
    });

    test('l\'anti-rebond de validation est unique dans le cycle du champ', () {
      // Une seconde attente avant d'afficher le résultat ferait patienter
      // près d'une seconde sur un champ correct.
      expect(WkMotion.validationDebounce, const Duration(milliseconds: 400));
      expect(WkMotion.progressThreshold, const Duration(milliseconds: 300));
      expect(WkMotion.progressMinimum, const Duration(milliseconds: 400));
    });
  });

  group('cibles tactiles', () {
    test('l\'action primaire est plus grande que le plancher', () {
      expect(WkTouch.min, 56);
      expect(WkTouch.comfy, 64);
      expect(WkTouch.voice, 96);
      expect(WkTouch.comfy, greaterThan(WkTouch.min));
    });
  });
}
