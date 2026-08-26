import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:woutalma_keur/app/ui/forui_theme.dart';

export 'package:woutalma_keur/app/ui/forui_theme.dart'
    show buildForuiTheme, pillButton;

const fontFamily = 'PlusJakartaSans';

abstract final class Insets {
  static const double xs = 4,
      sm = 8,
      md = 12,
      lg = 16,
      page = 20,
      xl = 24,
      xxl = 32,
      xxxl = 48;
}

abstract final class Radii {
  static const control = BorderRadius.all(Radius.circular(12));
  static const container = BorderRadius.all(Radius.circular(16));
  static const card = BorderRadius.all(Radius.circular(24));
  static const sheet = BorderRadius.vertical(top: Radius.circular(24));
  static const full = BorderRadius.all(Radius.circular(999));
}

abstract final class AppShadow {
  static const card = [
    BoxShadow(color: Color(0x0F000000), blurRadius: 24, offset: Offset(0, 6)),
    BoxShadow(color: Color(0x08000000), blurRadius: 2, offset: Offset(0, 1)),
  ];
}

abstract final class Motion {
  static const fast = Duration(milliseconds: 120);
  static const base = Duration(milliseconds: 250);
  static const enter = Duration(milliseconds: 350);

  /// Zéro quand le système demande moins d'animation : l'état change tout de
  /// suite, le retour haptique et sémantique reste entier.
  static Duration of(BuildContext context, Duration duration) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;
}

abstract final class Touch {
  /// Plancher absolu d'une cible tactile (`docs/WOUTALMA-UI.md` §1).
  static const double min = 56;

  /// Action primaire, champ, ligne actionnable.
  static const double comfy = 64;

  /// Action de tête d'écran, fantôme et discrète.
  static const double compact = 48;
}

abstract final class AppText {
  static const _tnum = [FontFeature.tabularFigures()];
  static const label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.1,
  );
  static const moneyXl = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -0.5,
    fontFeatures: _tnum,
  );
  static const moneyLg = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.2,
    fontFeatures: _tnum,
  );
  static const moneyMd = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.2,
    fontFeatures: _tnum,
  );
}

class Tones extends ThemeExtension<Tones> {
  const Tones({
    required this.success,
    required this.warning,
    required this.danger,
    required this.accent,
    required this.whatsapp,
    required this.inkSecondary,
    required this.inkTertiary,
    required this.hairline,
    required this.sunken,
    required this.surfaceLow,
  });

  final Color success,
      warning,
      danger,
      accent,
      whatsapp,
      inkSecondary,
      inkTertiary,
      hairline,
      sunken,
      surfaceLow;

  static const light = Tones(
    success: Color(0xFF0F7B3F),
    warning: Color(0xFF8A4B00),
    danger: Color(0xFFC42B1C),
    accent: Color(0xFF0B3B66),
    whatsapp: Color(0xFF12833E),
    inkSecondary: Color(0xFF52525B),
    inkTertiary: Color(0xFF6B6B75),
    hairline: Color(0xFFE7E7EA),
    sunken: Color(0xFFF1F2F4),
    surfaceLow: Color(0xFFFAFAF9),
  );
  static const dark = Tones(
    success: Color(0xFF4FBF80),
    warning: Color(0xFFE5A93C),
    danger: Color(0xFFFF7A6B),
    accent: Color(0xFF7FB3E0),
    whatsapp: Color(0xFF25D366),
    inkSecondary: Color(0xFFA6A6B0),
    inkTertiary: Color(0xFF8E8E9A),
    hairline: Color(0xFF2C2C34),
    sunken: Color(0xFF26262E),
    surfaceLow: Color(0xFF17171C),
  );

  @override
  Tones copyWith() => this;

  @override
  Tones lerp(Tones? o, double t) => o == null
      ? this
      : Tones(
          success: Color.lerp(success, o.success, t)!,
          warning: Color.lerp(warning, o.warning, t)!,
          danger: Color.lerp(danger, o.danger, t)!,
          accent: Color.lerp(accent, o.accent, t)!,
          whatsapp: Color.lerp(whatsapp, o.whatsapp, t)!,
          inkSecondary: Color.lerp(inkSecondary, o.inkSecondary, t)!,
          inkTertiary: Color.lerp(inkTertiary, o.inkTertiary, t)!,
          hairline: Color.lerp(hairline, o.hairline, t)!,
          sunken: Color.lerp(sunken, o.sunken, t)!,
          surfaceLow: Color.lerp(surfaceLow, o.surfaceLow, t)!,
        );
}

extension ThemeX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => theme.colorScheme;
  TextTheme get text => theme.textTheme;
  Tones get tones => theme.extension<Tones>()!;
}

ThemeData buildTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final tones = dark ? Tones.dark : Tones.light;
  final palette = foruiColors(brightness);
  final ink = palette.foreground, canvas = palette.background;

  final scheme = ColorScheme(
    brightness: brightness,
    primary: ink,
    onPrimary: palette.card,
    secondary: tones.accent,
    onSecondary: palette.card,
    error: tones.danger,
    onError: palette.card,
    surface: palette.card,
    onSurface: ink,
    onSurfaceVariant: tones.inkSecondary,
    surfaceContainerLow: tones.surfaceLow,
    surfaceContainer: palette.card,
    surfaceContainerHighest: tones.sunken,
    outline: tones.inkTertiary,
    outlineVariant: tones.hairline,
  );

  final text = const TextTheme(
    displayLarge: TextStyle(
      fontSize: 34,
      fontWeight: FontWeight.w700,
      height: 1.12,
      letterSpacing: -0.7,
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      height: 1.15,
      letterSpacing: -0.5,
    ),
    headlineMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 1.2,
      letterSpacing: -0.3,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 1.2,
      letterSpacing: -0.2,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.3,
    ),
    bodyLarge: TextStyle(fontSize: 16, height: 1.5),
    bodyMedium: TextStyle(fontSize: 14, height: 1.5),
    labelLarge: AppText.label,
    bodySmall: TextStyle(fontSize: 12, height: 1.4, letterSpacing: 0.1),
  ).apply(bodyColor: ink, displayColor: ink);

  return ThemeData(
    colorScheme: scheme,
    fontFamily: fontFamily,
    textTheme: text,
    extensions: [tones],
    scaffoldBackgroundColor: canvas,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    sliderTheme: SliderThemeData(
      activeTrackColor: ink,
      inactiveTrackColor: tones.hairline,
      thumbColor: ink,
      overlayColor: ink.withValues(alpha: .1),
      trackHeight: 4,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: canvas,
      foregroundColor: ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
    ),
    dividerTheme: DividerThemeData(
      color: tones.hairline,
      thickness: 1,
      space: 1,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
