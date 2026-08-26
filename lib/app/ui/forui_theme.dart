import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'package:woutalma_keur/app/ui/theme.dart';

FColors foruiColors(Brightness brightness) =>
    brightness == Brightness.dark ? _dark : _light;

const _light = FColors(
  brightness: .light,
  systemOverlayStyle: .dark,
  barrier: Color(0x33000000),
  background: Color(0xFFF6F7F9),
  foreground: Color(0xFF0F1419),
  primary: Color(0xFF0F1419),
  primaryForeground: Color(0xFFFFFFFF),
  secondary: Color(0xFFF1F2F4),
  secondaryForeground: Color(0xFF0F1419),
  muted: Color(0xFFF1F2F4),
  mutedForeground: Color(0xFF52525B),
  destructive: Color(0xFFC42B1C),
  destructiveForeground: Color(0xFFFFFFFF),
  error: Color(0xFFC42B1C),
  errorForeground: Color(0xFFFFFFFF),
  card: Color(0xFFFFFFFF),
  border: Color(0xFFE7E7EA),
);

const _dark = FColors(
  brightness: .dark,
  systemOverlayStyle: .light,
  barrier: Color(0x66000000),
  background: Color(0xFF101014),
  foreground: Color(0xFFECECEF),
  primary: Color(0xFFECECEF),
  primaryForeground: Color(0xFF101014),
  secondary: Color(0xFF26262E),
  secondaryForeground: Color(0xFFECECEF),
  muted: Color(0xFF26262E),
  mutedForeground: Color(0xFFA6A6B0),
  destructive: Color(0xFFFF7A6B),
  destructiveForeground: Color(0xFF101014),
  error: Color(0xFFFF7A6B),
  errorForeground: Color(0xFF101014),
  card: Color(0xFF1D1D23),
  border: Color(0xFF2C2C34),
);

const _radius = FBorderRadius(
  xs2: Radii.control,
  xs: Radii.control,
  sm: Radii.control,
  md: Radii.control,
  lg: Radii.container,
  xl: Radii.card,
  xl2: Radii.card,
  xl3: Radii.card,
  pill: Radii.full,
);

/// Passe un bouton en pastille : à combiner avec les variantes primary (sélectionnée) et secondary.
final pillButton = FButtonStyleDelta.delta(
  decoration: FVariantsDelta.delta([
    FVariantOperation.all(
      const DecorationDelta.shapeDelta(
        shape: RoundedSuperellipseBorder(borderRadius: Radii.full),
      ),
    ),
  ]),
);

TextStyle _t(
  Color ink,
  double size, {
  FontWeight? weight,
  double height = 1.5,
  double spacing = 0,
}) => TextStyle(
  fontFamily: fontFamily,
  color: ink,
  fontSize: size,
  fontWeight: weight,
  height: height,
  letterSpacing: spacing,
);

FTypography _typography(Color ink) => FTypography(
  fontFamily: fontFamily,
  xs3: _t(ink, 12, height: 1.4, spacing: 0.1),
  xs2: _t(ink, 12, height: 1.4, spacing: 0.1),
  xs: _t(ink, 14),
  sm: _t(ink, 16),
  md: _t(ink, 16, weight: FontWeight.w600, height: 1.3),
  lg: _t(ink, 20, weight: FontWeight.w600, height: 1.2, spacing: -0.2),
  xl: _t(ink, 24, weight: FontWeight.w600, height: 1.2, spacing: -0.3),
  xl2: _t(ink, 28, weight: FontWeight.w700, height: 1.15, spacing: -0.5),
  xl3: _t(ink, 34, weight: FontWeight.w700, height: 1.12, spacing: -0.7),
  xl4: _t(ink, 48, weight: FontWeight.w700, height: 1.1),
  xl5: _t(ink, 60, weight: FontWeight.w700, height: 1.1),
  xl6: _t(ink, 72, weight: FontWeight.w700, height: 1.1),
  xl7: _t(ink, 96, weight: FontWeight.w700, height: 1.1),
  xl8: _t(ink, 108, weight: FontWeight.w700, height: 1.1),
);

FVariants<
  FTappableVariantConstraint,
  FTappableVariant,
  Decoration,
  DecorationDelta
>
_decoration(
  FColors colors, {
  Color? fill,
  Color? border,
  required Color pressed,
}) => FVariants.from(
  ShapeDecoration(
    shape: RoundedSuperellipseBorder(
      borderRadius: Radii.control,
      side: border == null ? BorderSide.none : BorderSide(color: border),
    ),
    color: fill,
  ),
  variants: {
    [.hovered, .pressed]: DecorationDelta.shapeDelta(color: pressed),
    [.disabled]: fill == null
        ? const DecorationDelta.shapeDelta()
        : DecorationDelta.shapeDelta(color: colors.disable(fill)),
  },
);

/// Quatre tailles : xs 36, sm 40 (pastilles), md 52 (bouton standard), lg 56.
FButtonSizeStyles _button(
  FColors colors,
  FTypography typography,
  FStyle style, {
  Color? fill,
  Color? border,
  required Color text,
  required Color pressed,
}) {
  final decoration = _decoration(
    colors,
    fill: fill,
    border: border,
    pressed: pressed,
  );
  FButtonStyle size(double min, EdgeInsets padding, double icon) =>
      FButtonStyle.inherit(
        style: style,
        decoration: decoration,
        textStyle: typography.xs,
        foregroundColor: text,
        disabledForegroundColor: colors.disable(text),
        contentConstraints: BoxConstraints(minWidth: min, minHeight: min),
        contentPadding: padding,
        contentSpacing: Insets.sm,
        iconConstraints: BoxConstraints(minWidth: min, minHeight: min),
        iconSize: icon,
        iconPadding: EdgeInsets.all((min - icon) / 2),
      );
  final md = size(
    52,
    const EdgeInsets.symmetric(horizontal: Insets.page, vertical: Insets.lg),
    24,
  );
  return FButtonSizeStyles(
    FVariants(
      md,
      variants: {
        [.xs]: size(
          36,
          const EdgeInsets.symmetric(
            horizontal: Insets.md,
            vertical: Insets.sm,
          ),
          18,
        ),
        [.sm]: size(
          40,
          const EdgeInsets.symmetric(horizontal: Insets.lg, vertical: 10),
          20,
        ),
        [.md]: md,
        [.lg]: size(
          56,
          const EdgeInsets.symmetric(horizontal: Insets.xl, vertical: 18),
          24,
        ),
      },
    ),
  );
}

FVariants<
  FTappableVariantConstraint,
  FTappableVariant,
  TextStyle,
  TextStyleDelta
>
_text(FColors colors, TextStyle base) => FVariants.from(
  base,
  variants: {
    [.disabled]: TextStyleDelta.delta(color: colors.disable(base.color!)),
  },
);

FVariants<
  FTappableVariantConstraint,
  FTappableVariant,
  IconThemeData,
  IconThemeDataDelta
>
_icon(FColors colors, Color color, double size) => FVariants.from(
  IconThemeData(color: color, size: size),
  variants: {
    [.disabled]: IconThemeDataDelta.delta(color: colors.disable(color)),
  },
);

/// Ligne de 64 dp minimum avec un avatar de 44 : titre 16/600, sous-titre et détail 14, chevron discret.
FTileStyle _tile(
  FColors colors,
  FTypography typography,
  FStyle style,
  Tones tones, {
  required Color fg,
  required Color muted,
  required Color icon,
}) => FTileStyle(
  backgroundColor: const FVariants.all(Colors.transparent),
  decoration: FVariants.from(
    const ShapeDecoration(shape: RoundedRectangleBorder()),
    variants: {
      [.hovered, .pressed]: DecorationDelta.shapeDelta(color: tones.sunken),
    },
  ),
  contentStyle: FTileContentStyle(
    prefixIconStyle: _icon(colors, fg, 24),
    titleTextStyle: _text(colors, typography.md.copyWith(color: fg)),
    subtitleTextStyle: _text(colors, typography.xs.copyWith(color: muted)),
    detailsTextStyle: _text(colors, typography.xs.copyWith(color: muted)),
    suffixIconStyle: _icon(colors, icon, 22),
    suffixedPadding: const EdgeInsets.fromLTRB(
      Insets.page,
      Insets.md,
      Insets.lg,
      Insets.md,
    ),
    unsuffixedPadding: const EdgeInsets.symmetric(
      horizontal: Insets.page,
      vertical: Insets.md,
    ),
    prefixIconSpacing: Insets.lg,
    titleSpacing: 2,
    middleSpacing: Insets.md,
    suffixIconSpacing: Insets.sm,
  ),
  rawItemContentStyle: FRawTileContentStyle.inherit(
    colors: colors,
    typography: typography,
    prefix: fg,
    color: fg,
  ),
  tappableStyle: style.tappableStyle.copyWith(
    motion: FTappableMotion.none,
    pressedEnterDuration: Duration.zero,
    pressedExitDuration: const Duration(milliseconds: 25),
  ),
  focusedOutlineStyle: style.focusedOutlineStyle,
  shape: const RoundedRectangleBorder(),
);

OutlineInputBorder _fieldBorder(Color color) => OutlineInputBorder(
  borderRadius: Radii.control,
  borderSide: BorderSide(color: color, width: 2),
);

FThemeData buildForuiTheme(Brightness brightness, {bool reduceMotion = false}) {
  final dark = brightness == Brightness.dark;
  final colors = foruiColors(brightness);
  final tones = dark ? Tones.dark : Tones.light;
  final typography = _typography(colors.foreground);
  final ink = colors.foreground;
  final card = BoxDecoration(
    color: colors.card,
    borderRadius: Radii.card,
    boxShadow: dark ? null : AppShadow.card,
  );
  final style = FStyle(
    formFieldStyle: FFormFieldStyle(
      labelTextStyle: FVariants.from(
        typography.xs3.copyWith(
          color: tones.inkSecondary,
          fontWeight: FontWeight.w600,
        ),
        variants: {
          [.disabled]: TextStyleDelta.delta(
            color: colors.disable(tones.inkSecondary),
          ),
        },
      ),
      descriptionTextStyle: FVariants.from(
        typography.xs3.copyWith(color: tones.inkSecondary),
        variants: {},
      ),
      errorTextStyle: FVariants.from(
        typography.xs3.copyWith(color: colors.error),
        variants: {},
      ),
    ),
    focusedOutlineStyle: FFocusedOutlineStyle(
      color: ink,
      borderRadius: Radii.control,
    ),
    sizes: FSizes.inherit(touch: true),
    iconStyle: IconThemeData(color: ink, size: 24),
    tappableStyle: FTappableStyle(
      motion: reduceMotion
          ? FTappableMotion.none
          : const FTappableMotion(
              bounceDownDuration: Motion.fast,
              bounceUpDuration: Motion.fast,
            ),
    ),
    borderRadius: _radius,
    pagePadding: const EdgeInsets.symmetric(horizontal: Insets.page),
    shadow: dark ? const [] : AppShadow.card,
  );
  final tile = _tile(
    colors,
    typography,
    style,
    tones,
    fg: ink,
    muted: tones.inkSecondary,
    icon: tones.inkTertiary,
  );
  final dangerTile = _tile(
    colors,
    typography,
    style,
    tones,
    fg: tones.danger,
    muted: tones.danger,
    icon: tones.danger,
  );
  final FVariants<
    FItemVariantConstraint,
    FItemVariant,
    FTileStyle,
    FTileStyleDelta
  >
  tiles = FVariants(
    tile,
    variants: {
      [.primary]: tile,
      [.destructive]: dangerTile,
    },
  );

  return FThemeData(
    colors: colors,
    touch: true,
    typography: typography,
    style: style,
    extensions: [tones],
    buttonStyles: FVariants(
      _button(
        colors,
        typography,
        style,
        fill: colors.primary,
        text: colors.primaryForeground,
        pressed: colors.hover(colors.primary),
      ),
      variants: {
        [.secondary]: _button(
          colors,
          typography,
          style,
          fill: tones.sunken,
          text: ink,
          pressed: colors.hover(tones.sunken),
        ),
        [.outline]: _button(
          colors,
          typography,
          style,
          fill: colors.card,
          // `colors.border` est un filet décoratif à 1,2:1 : invisible dehors,
          // et sous les 3:1 exigés d'une bordure porteuse de sens.
          border: tones.inkTertiary,
          text: ink,
          pressed: tones.sunken,
        ),
        [.ghost]: _button(
          colors,
          typography,
          style,
          text: tones.accent,
          pressed: tones.sunken,
        ),
        [.destructive]: _button(
          colors,
          typography,
          style,
          fill: tones.danger,
          text: colors.background,
          pressed: colors.hover(tones.danger),
        ),
      },
    ),
    cardStyle: FCardStyle(
      decoration: card,
      contentStyle: FCardContentStyle(
        titleTextStyle: typography.xs.copyWith(color: tones.inkSecondary),
        subtitleTextStyle: typography.xl,
        titleSpacing: Insets.xs,
        subtitleSpacing: Insets.md,
        padding: const EdgeInsets.all(Insets.page),
      ),
    ),
    avatarStyle: FAvatarStyle(
      backgroundColor: tones.sunken,
      foregroundColor: ink,
      textStyle: typography.xs.copyWith(
        color: ink,
        fontWeight: FontWeight.w600,
      ),
    ),
    tileStyles: tiles,
    tileGroupStyle: FTileGroupStyle(
      decoration: card,
      dividerColor: FVariants.all(colors.border),
      dividerWidth: 1,
      tileStyles: FTileStyles(tiles),
      labelTextStyle: style.formFieldStyle.labelTextStyle,
      descriptionTextStyle: style.formFieldStyle.descriptionTextStyle,
      errorTextStyle: style.formFieldStyle.errorTextStyle,
      slidePressHapticFeedback: style.hapticFeedback.selectionClick,
    ),
    headerStyles:
        FHeaderStyles.inherit(
          colors: colors,
          typography: typography,
          style: style,
          touch: true,
        ).apply([
          FVariantOperation.all(
            FHeaderStyleDelta.delta(
              padding: const EdgeInsetsGeometryDelta.value(
                EdgeInsets.symmetric(horizontal: Insets.sm),
              ),
              constraints: const BoxConstraints(minHeight: 52),
              titleTextStyle: TextStyleDelta.delta(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ]),
    textFieldStyles:
        FTextFieldSizeStyles.inherit(
          colors: colors,
          typography: typography,
          style: style,
          touch: true,
        ).apply([
          FVariantOperation.all(
            FTextFieldStyleDelta.delta(
              cursorColor: ink,
              contentPadding: const EdgeInsetsGeometryDelta.value(
                EdgeInsets.all(Insets.lg),
              ),
              color: FVariants(
                tones.sunken,
                variants: {
                  [.disabled]: colors.disable(tones.sunken),
                },
              ),
              border: FVariants(
                _fieldBorder(Colors.transparent),
                variants: {
                  [.focused]: _fieldBorder(ink),
                  [.error]: _fieldBorder(colors.error),
                  [.error.and(.focused)]: _fieldBorder(colors.error),
                },
              ),
            ),
          ),
        ]),
    dividerStyles: FVariants.all(
      FDividerStyle(color: colors.border, padding: EdgeInsets.zero),
    ),
    bottomNavigationBarStyle: FBottomNavigationBarStyle(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: Radii.full,
        border: dark ? Border.all(color: colors.border) : null,
        boxShadow: dark
            ? null
            : const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 32,
                  offset: Offset(0, 10),
                ),
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
      ),
      padding: const EdgeInsets.symmetric(
        vertical: Insets.md,
        horizontal: Insets.sm,
      ),
      itemStyle: FBottomNavigationBarItemStyle(
        iconStyle: FVariants.from(
          IconThemeData(color: tones.inkSecondary, size: 24),
          variants: {
            [.selected]: IconThemeDataDelta.delta(color: tones.accent),
          },
        ),
        textStyle: FVariants.from(
          typography.xs3.copyWith(color: tones.inkSecondary),
          variants: {
            [.selected]: TextStyleDelta.delta(
              color: tones.accent,
              fontWeight: FontWeight.w600,
            ),
          },
        ),
        tappableStyle: style.tappableStyle,
        focusedOutlineStyle: style.focusedOutlineStyle,
        spacing: Insets.xs,
      ),
    ),
  );
}
