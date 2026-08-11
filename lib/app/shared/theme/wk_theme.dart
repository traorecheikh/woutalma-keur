import 'package:flutter/material.dart';
import 'package:woutalma_keur/app/l10n/generated/app_l10n.dart';
import 'package:woutalma_keur/app/shared/theme/wk_colors.dart';
import 'package:woutalma_keur/app/shared/theme/wk_motion.dart';
import 'package:woutalma_keur/app/shared/theme/wk_typography.dart';

/// Construit les deux thèmes à partir des jetons de `docs/DESIGN.md`.
abstract final class WkTheme {
  static ThemeData light() => _build(WkColors.light, Brightness.light);
  static ThemeData dark() => _build(WkColors.dark, Brightness.dark);

  static ThemeData _build(WkColors colors, Brightness brightness) {
    final TextTheme textTheme = WkTypography.textTheme(colors.onSurface);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: colors.background,
      canvasColor: colors.surface,
      textTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[colors],
      // La palette Material n'est pas la source de vérité — `context.colors`
      // l'est. Ce schéma existe pour les widgets du framework que l'on ne
      // contrôle pas (curseur de champ, sélection de texte, ripple).
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colors.primary,
        onPrimary: colors.onPrimary,
        primaryContainer: colors.primaryContainer,
        onPrimaryContainer: colors.onPrimaryContainer,
        secondary: colors.primary,
        onSecondary: colors.onPrimary,
        error: colors.error,
        onError: colors.onError,
        errorContainer: colors.errorContainer,
        onErrorContainer: colors.onErrorContainer,
        surface: colors.surface,
        onSurface: colors.onSurface,
        outline: colors.outline,
        outlineVariant: colors.outlineVariant,
      ),
      splashFactory: InkRipple.splashFactory,
      pageTransitionsTheme: const PageTransitionsTheme(),
    );
  }
}

/// Accès aux jetons depuis un écran.
///
/// `context.colors` plutôt que `Colors.*`, `context.l10n` plutôt qu'une chaîne
/// en dur, `context.motion` plutôt qu'une `Duration` écrite à la main.
extension WkThemeContext on BuildContext {
  WkColors get colors => Theme.of(this).extension<WkColors>()!;

  TextTheme get text => Theme.of(this).textTheme;

  WkMotion get motion => WkMotion.of(this);

  AppL10n get l10n => AppL10n.of(this);
}
