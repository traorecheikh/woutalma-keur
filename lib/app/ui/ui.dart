import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart' hide FThemeBuildContext;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/core/app_config.dart';
import 'package:woutalma_keur/app/core/state/screen_state.dart';
import 'package:woutalma_keur/app/data/local/cache_status.dart';
import 'package:woutalma_keur/app/data/services/backend_warmup.dart';
import 'package:woutalma_keur/app/l10n/generated/app_l10n.dart';
import 'package:woutalma_keur/app/ui/theme.dart';

export 'package:forui/forui.dart'
    show FIcons, FTappable, FCircularProgress, FAlert, FProgress;
export 'package:woutalma_keur/app/ui/theme.dart';

extension L10nX on BuildContext {
  AppL10n get l10n => AppL10n.of(this);
}

Widget _tap(
  Widget child, {
  VoidCallback? onTap,
  VoidCallback? onLongPress,
  String? label,
}) => onTap == null && onLongPress == null
    ? child
    : FTappable(
        onPress: onTap,
        onLongPress: onLongPress,
        semanticsLabel: label,
        behavior: HitTestBehavior.opaque,
        child: child,
      );

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.headerTitle,
    this.actions = const [],
    this.bottom,
    this.navBar,
    this.onRefresh,
    this.onBack,
    this.showBack = true,
  });
  final Widget body;
  final String? title, headerTitle;
  final List<Widget> actions;
  final Widget? bottom, navBar;
  final Future<void> Function()? onRefresh;
  final VoidCallback? onBack;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final canPop =
        showBack && (onBack != null || Navigator.of(context).canPop());
    final hasHeader = canPop || actions.isNotEmpty || headerTitle != null;
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Banner(),
        if (title != null) AppTitle(title!),
        Expanded(child: body),
      ],
    );
    if (onRefresh != null)
      content = RefreshIndicator(
        onRefresh: onRefresh!,
        color: context.colors.onSurface,
        child: content,
      );
    return Material(
      type: MaterialType.transparency,
      child: FScaffold(
        childPad: false,
        header: !hasHeader
            ? null
            : FHeader.nested(
                title: headerTitle == null
                    ? const SizedBox.shrink()
                    : Text(
                        headerTitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                prefixes: [
                  if (canPop)
                    AppIconButton(
                      icon: FIcons.arrowLeft,
                      label: context.l10n.commonBack,
                      onTap: onBack ?? () => Navigator.of(context).pop(),
                    ),
                ],
                suffixes: actions,
              ),
        footer: navBar ?? (bottom == null ? null : _ActionBar(child: bottom!)),
        child: SafeArea(
          top: !hasHeader,
          bottom: navBar == null && bottom == null,
          child: content,
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner();
  @override
  Widget build(BuildContext context) {
    final status = context.watch<CacheStatus?>();
    final warmup = context.watch<BackendWarmup?>();
    final l = context.l10n;
    final String? text = status != null && status.servedFromCache
        ? l.offlineCached(_age(l, status.fetchedAt))
        : warmup != null && warmup.state == WarmupState.warming
        ? l.backendWakingUp
        : null;
    if (text == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Insets.page,
        Insets.sm,
        Insets.page,
        0,
      ),
      child: FAlert(
        icon: Icon(
          status?.servedFromCache == true ? FIcons.wifiOff : FIcons.hourglass,
        ),
        title: Text(text),
      ),
    );
  }

  static String _age(AppL10n l, DateTime? at) {
    if (at == null) return l.offlineJustNow;
    final ago = DateTime.now().difference(at);
    if (ago.inMinutes < 1) return l.offlineJustNow;
    if (ago.inHours < 1) return l.offlineMinutesAgo(ago.inMinutes);
    if (ago.inDays < 1) return l.offlineHoursAgo(ago.inHours);
    return l.offlineDaysAgo(ago.inDays);
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: context.colors.surface,
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        Insets.page,
        Insets.md,
        Insets.page,
        Insets.md + MediaQuery.paddingOf(context).bottom,
      ),
      child: Row(children: [Expanded(child: child)]),
    ),
  );
}

class AppTitle extends StatelessWidget {
  const AppTitle(
    this.text, {
    super.key,
    this.large = false,
    this.centered = false,
  });
  final String text;
  final bool large, centered;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      Insets.page,
      Insets.sm,
      Insets.page,
      Insets.xl,
    ),
    child: SizedBox(
      width: double.infinity,
      child: Text(
        text,
        style: centered
            ? context.text.headlineMedium!.copyWith(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                height: 1.25,
              )
            : large
            ? context.text.displayLarge
            : context.text.displayMedium,
        textAlign: centered ? TextAlign.center : TextAlign.start,
        maxLines: centered ? 2 : null,
        overflow: centered ? TextOverflow.ellipsis : null,
      ),
    ),
  );
}

class AppSection extends StatelessWidget {
  const AppSection(this.text, {super.key, this.action, this.onAction});
  final String text;
  final String? action;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      Insets.page,
      Insets.xl,
      Insets.page,
      Insets.sm,
    ),
    child: Row(
      children: [
        Expanded(child: Text(text, style: context.text.titleLarge)),
        if (action != null)
          AppButton(
            action!,
            onPressed: onAction,
            variant: AppButtonVariant.ghost,
            size: 36,
          ),
      ],
    ),
  );
}

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.color,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? color;
  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    button: true,
    excludeSemantics: true,
    child: FButton.icon(
      variant: FButtonVariant.ghost,
      onPress: onTap,
      child: Icon(icon, color: color ?? context.colors.onSurface),
    ),
  );
}

class AppRow extends StatelessWidget with FTileMixin {
  const AppRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.danger = false,
  });
  final String title;
  final String? subtitle;
  final Widget? leading, trailing;
  final VoidCallback? onTap, onLongPress;
  final bool danger;

  @override
  Widget build(BuildContext context) => FTile(
    variant: danger ? FItemVariant.destructive : FItemVariant.primary,
    title: Text(title),
    subtitle: subtitle == null ? null : Text(subtitle!),
    prefix: leading,
    details: trailing,
    suffix: trailing == null && onTap != null
        ? const Icon(FIcons.chevronRight)
        : null,
    onPress: onTap,
    onLongPress: onLongPress,
  );
}

class AppDivider extends StatelessWidget {
  const AppDivider({super.key, this.inset = true});
  final bool inset;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: inset ? Insets.page : 0),
    child: const FDivider(),
  );
}

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required Widget this.child,
    this.padding,
    this.onTap,
    this.onLongPress,
  }) : rows = null;
  const AppCard.rows(
    List<FTileMixin> this.rows, {
    super.key,
    this.onTap,
    this.onLongPress,
  }) : child = null,
       padding = null;
  final Widget? child;
  final List<FTileMixin>? rows;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap, onLongPress;

  @override
  Widget build(BuildContext context) => _tap(
    rows != null
        ? FTileGroup(children: rows!)
        : FCard.raw(
            child: ClipRRect(
              borderRadius: Radii.card,
              child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
            ),
          ),
    onTap: onTap,
    onLongPress: onLongPress,
  );
}

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.name,
    this.size = 44,
    this.imagePath,
  });
  final String name;
  final double size;
  final String? imagePath;

  static String initials(String name) => name
      .trim()
      .split(RegExp(r'[\s-]+'))
      .where((w) => w.isNotEmpty)
      .take(2)
      .map((w) => w.characters.first.toUpperCase())
      .join();

  @override
  Widget build(BuildContext context) {
    final letters = initials(name);
    final dark = context.theme.brightness == Brightness.dark;
    final tint = HSLColor.fromAHSL(
      1,
      (name.hashCode % 360).toDouble(),
      .35,
      dark ? .28 : .88,
    ).toColor();
    final style = FAvatarStyleDelta.delta(
      backgroundColor: tint,
      textStyle: TextStyleDelta.delta(fontSize: size * .36),
    );
    final fallback = Text(letters.isEmpty ? '?' : letters);
    final provider = imageProviderFor(imagePath);
    final avatar = provider == null
        ? FAvatar.raw(size: size, style: style, child: fallback)
        : FAvatar(
            size: size,
            style: style,
            image: provider,
            fallback: fallback,
          );
    return Semantics(label: name, excludeSemantics: true, child: avatar);
  }
}

class AppKeyTile extends StatelessWidget {
  const AppKeyTile({
    super.key,
    required this.label,
    required this.value,
    this.onTap,
    this.color,
  });
  final String label;
  final Widget value;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final onInk = context.colors.onPrimary;
    final dim = onInk.withValues(alpha: .7);
    return _tap(
      FCard.raw(
        style: FCardStyleDelta.delta(
          decoration: DecorationDelta.boxDelta(
            color: color ?? context.colors.primary,
            boxShadow: const [],
          ),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 120),
          child: Padding(
            padding: const EdgeInsets.all(Insets.page),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: context.text.bodySmall!.copyWith(color: dim),
                      ),
                      const SizedBox(height: Insets.md),
                      Theme(
                        data: context.theme.copyWith(
                          colorScheme: context.colors.copyWith(
                            onSurface: onInk,
                          ),
                        ),
                        child: DefaultTextStyle.merge(
                          style: AppText.moneyXl.copyWith(color: onInk),
                          child: value,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onTap != null) Icon(FIcons.chevronRight, color: dim),
              ],
            ),
          ),
        ),
      ),
      onTap: onTap,
    );
  }
}

class AppStatCard extends StatelessWidget {
  const AppStatCard({
    super.key,
    required this.label,
    required this.value,
    this.footer,
    this.onTap,
  });
  final String label;
  final Widget value;
  final Widget? footer;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => _tap(
    FCard(
      title: Text(label),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DefaultTextStyle.merge(
            style: context.text.headlineMedium,
            child: value,
          ),
          if (footer != null) ...[const SizedBox(height: Insets.md), footer!],
        ],
      ),
    ),
    onTap: onTap,
  );
}

enum AppButtonVariant { primary, secondary, ghost, danger, call, whatsapp }

class AppButton extends StatelessWidget {
  const AppButton(
    this.label, {
    super.key,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.size = 52,
  });
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool loading;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = context.tones;
    final (fv, fill) = switch (variant) {
      AppButtonVariant.primary => (FButtonVariant.primary, null),
      AppButtonVariant.secondary => (FButtonVariant.outline, null),
      AppButtonVariant.ghost => (FButtonVariant.ghost, null),
      AppButtonVariant.danger => (FButtonVariant.destructive, null),
      AppButtonVariant.call => (FButtonVariant.primary, t.success),
      AppButtonVariant.whatsapp => (FButtonVariant.primary, t.whatsapp),
    };
    return SizedBox(
      height: size,
      child: FButton(
        variant: fv,
        size: size < 44 ? FButtonSizeVariant.xs : FButtonSizeVariant.md,
        style: fill == null
            ? const FButtonStyleDelta.delta()
            : FButtonStyleDelta.delta(
                decoration: FVariantsDelta.delta([
                  FVariantOperation.all(
                    DecorationDelta.shapeDelta(color: fill),
                  ),
                ]),
              ),
        onPress: loading ? () {} : onPressed,
        mainAxisSize: MainAxisSize.min,
        prefix: icon == null || loading ? null : Icon(icon, size: 20),
        child: loading
            ? const FCircularProgress()
            : Flexible(
                child: Text(
                  label,
                  style: AppText.label,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
      ),
    );
  }
}

class AppPill extends StatelessWidget {
  const AppPill(
    this.label, {
    super.key,
    required this.selected,
    required this.onTap,
    this.icon,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => FButton(
    variant: selected ? FButtonVariant.primary : FButtonVariant.secondary,
    size: FButtonSizeVariant.sm,
    style: pillButton,
    selected: selected,
    mainAxisSize: MainAxisSize.min,
    onPress: onTap,
    prefix: icon == null ? null : Icon(icon, size: 18),
    child: Text(label, style: AppText.label),
  );
}

class AppSegmented extends StatelessWidget {
  const AppSegmented({
    super.key,
    required this.options,
    required this.index,
    required this.onChanged,
  });
  final List<String> options;
  final int index;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: Insets.page,
      vertical: Insets.sm,
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: Insets.sm,
      children: [
        for (var i = 0; i < options.length; i++)
          AppPill(options[i], selected: i == index, onTap: () => onChanged(i)),
      ],
    ),
  );
}

class AppChoice<T> extends StatelessWidget {
  const AppChoice({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    required this.label,
    this.icon,
    this.scroll = false,
  });
  final List<T> options;
  final T? selected;
  final void Function(T) onChanged;
  final String Function(T) label;
  final IconData? Function(T)? icon;
  final bool scroll;
  @override
  Widget build(BuildContext context) {
    final pills = [
      for (final o in options)
        AppPill(
          label(o),
          selected: o == selected,
          onTap: () => onChanged(o),
          icon: icon?.call(o),
        ),
    ];
    if (!scroll)
      return Wrap(spacing: Insets.sm, runSpacing: Insets.sm, children: pills);
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Insets.page),
        itemCount: pills.length,
        separatorBuilder: (_, _) => const SizedBox(width: Insets.sm),
        itemBuilder: (_, i) => pills[i],
      ),
    );
  }
}

class AppField extends StatefulWidget {
  const AppField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.error,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    this.suffix,
    this.onChanged,
    this.autofocus = false,
    this.textInputAction,
    this.onSubmitted,
    this.readOnly = false,
    this.onTap,
    this.inputFormatters,
    this.focusNode,
  });
  final String label;
  final TextEditingController? controller;
  final String? hint, error;
  final TextInputType? keyboardType;
  final bool autofocus, readOnly;
  final int maxLines;
  final int? maxLength;
  final Widget? suffix;
  final ValueChanged<String>? onChanged, onSubmitted;
  final TextInputAction? textInputAction;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  @override
  State<AppField> createState() => _AppFieldState();
}

class _AppFieldState extends State<AppField> {
  late String? _last = widget.controller?.text;

  void _changed(TextEditingValue v) {
    if (v.text == _last) return;
    _last = v.text;
    widget.onChanged?.call(v.text);
  }

  @override
  Widget build(BuildContext context) {
    final w = widget;
    return FTextField(
      control: FTextFieldControl.managed(
        controller: w.controller,
        onChange: _changed,
      ),
      label: Text(w.label),
      hint: w.hint,
      error: w.error == null ? null : Text(w.error!),
      keyboardType: w.keyboardType,
      maxLines: w.maxLines,
      maxLength: w.maxLength,
      autofocus: w.autofocus,
      focusNode: w.focusNode,
      textInputAction: w.textInputAction,
      onSubmit: w.onSubmitted,
      readOnly: w.readOnly,
      onTap: w.onTap,
      inputFormatters: w.inputFormatters,
      suffixBuilder: w.suffix == null ? null : (_, _, _) => w.suffix!,
    );
  }
}

final _fr = NumberFormat.decimalPattern('fr');

String formatCfa(int amount, {bool short = false}) =>
    '${_fr.format(amount).replaceAll(RegExp(r'[\s ]'), ' ')} ${short ? 'F' : 'FCFA'}';

class AppMoney extends StatelessWidget {
  const AppMoney(
    this.amount, {
    super.key,
    this.style,
    this.short = false,
    this.color,
    this.suffix,
  });
  final int amount;
  final TextStyle? style;
  final bool short;
  final Color? color;
  final String? suffix;
  @override
  Widget build(BuildContext context) => Semantics(
    label: '${_fr.format(amount)} francs CFA${suffix ?? ''}',
    excludeSemantics: true,
    child: Text(
      '${formatCfa(amount, short: short)}${suffix ?? ''}',
      style: (style ?? AppText.moneyMd).copyWith(
        color: color ?? context.colors.onSurface,
      ),
    ),
  );
}

enum AppTone { neutral, success, warning, danger, accent }

class AppTag extends StatelessWidget {
  const AppTag(this.text, {super.key, this.tone = AppTone.neutral, this.icon});
  final String text;
  final AppTone tone;
  final IconData? icon;
  @override
  Widget build(BuildContext context) {
    final t = context.tones;
    final (fg, bg) = switch (tone) {
      AppTone.neutral => (t.inkSecondary, t.sunken),
      AppTone.success => (t.success, t.success.withValues(alpha: .12)),
      AppTone.warning => (t.warning, t.warning.withValues(alpha: .12)),
      AppTone.danger => (t.danger, t.danger.withValues(alpha: .12)),
      AppTone.accent => (t.accent, t.accent.withValues(alpha: .12)),
    };
    return FBadge(
      style: FBadgeStyle(
        decoration: BoxDecoration(color: bg, borderRadius: Radii.full),
        contentStyle: FBadgeContentStyle(
          labelTextStyle: context.text.bodySmall!.copyWith(
            color: fg,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: Insets.xs,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: Insets.xs,
        children: [
          if (icon != null) Icon(icon, size: 12, color: fg),
          Flexible(
            child: Text(text.toUpperCase(), overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

class AppOverlayChip extends StatelessWidget {
  const AppOverlayChip(this.text, {super.key, this.icon});
  final String text;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.colors.surface,
      borderRadius: Radii.full,
      boxShadow: AppShadow.card,
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: Insets.xs),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: Insets.xs,
        children: [
          if (icon != null)
            Icon(icon, size: 14, color: context.colors.onSurface),
          Text(
            text,
            style: context.text.bodySmall!.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}

enum AppStateKind { empty, offline, error, permission }

String failureText(AppL10n l, WkFailure f) => switch (f) {
  WkFailure.localStorage => l.failureLocalStorage,
  WkFailure.seed => l.failureSeed,
  WkFailure.permission => l.failurePermission,
  WkFailure.notFound => l.failureNotFound,
  WkFailure.network => l.failureNetwork,
  WkFailure.unknown => l.failureUnknown,
};

AppState failureState(
  BuildContext context,
  WkFailure f, {
  VoidCallback? onRetry,
}) => AppState(
  kind: f == WkFailure.network
      ? AppStateKind.offline
      : f == WkFailure.permission
      ? AppStateKind.permission
      : AppStateKind.error,
  title: context.l10n.stateErrorTitle,
  message: failureText(context.l10n, f),
  actionLabel: onRetry == null ? null : context.l10n.commonRetry,
  onAction: onRetry,
);

class AppState extends StatelessWidget {
  const AppState({
    super.key,
    required this.kind,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.icon,
  });
  final AppStateKind kind;
  final String title;
  final String? message, actionLabel;
  final VoidCallback? onAction;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final i =
        icon ??
        switch (kind) {
          AppStateKind.empty => FIcons.inbox,
          AppStateKind.offline => FIcons.wifiOff,
          AppStateKind.error => FIcons.circleAlert,
          AppStateKind.permission => FIcons.lock,
        };
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Insets.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(i, size: 44, color: context.tones.inkTertiary),
            const SizedBox(height: Insets.xl),
            Text(
              title,
              style: context.text.headlineMedium,
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: Insets.sm),
              Text(
                message!,
                style: context.text.bodyLarge!.copyWith(
                  color: context.tones.inkSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null) ...[
              const SizedBox(height: Insets.xxl),
              AppButton(
                actionLabel!,
                onPressed: onAction,
                variant: AppButtonVariant.secondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AppSkeleton extends StatelessWidget {
  const AppSkeleton({super.key, this.rows = 6, this.height = 64});
  final int rows;
  final double height;
  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.symmetric(
      horizontal: Insets.page,
      vertical: Insets.sm,
    ),
    itemCount: rows,
    separatorBuilder: (_, _) => const SizedBox(height: Insets.md),
    itemBuilder: (_, _) => FCard.raw(
      style: FCardStyleDelta.delta(
        decoration: DecorationDelta.boxDelta(
          color: context.tones.sunken,
          borderRadius: Radii.control,
          boxShadow: const [],
        ),
      ),
      child: SizedBox(height: height, width: double.infinity),
    ),
  );
}

String resolvePhoto(String path) {
  if (path.startsWith('demo:'))
    return 'assets/seed/photos/${path.substring(5).replaceAll(':', '-')}.webp';
  if (path.startsWith('api:'))
    return '${AppConfig.apiBaseUrl}/properties/photos/${path.substring(4)}';
  return path;
}

ImageProvider? imageProviderFor(String? path) {
  if (path == null || path.isEmpty) return null;
  final r = resolvePhoto(path);
  if (r.startsWith('assets/')) return AssetImage(r);
  if (r.startsWith('http') || kIsWeb) return NetworkImage(r);
  return FileImage(File(r));
}

class AppPhoto extends StatelessWidget {
  const AppPhoto(
    this.path, {
    super.key,
    this.fallbackIcon = FIcons.house,
    this.aspectRatio,
    this.radius = Radii.container,
    this.fit = BoxFit.cover,
  });
  final String? path;
  final IconData fallbackIcon;
  final double? aspectRatio;
  final BorderRadius radius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final fallback = ColoredBox(
      color: context.tones.sunken,
      child: Center(
        child: Icon(fallbackIcon, size: 40, color: context.tones.inkTertiary),
      ),
    );
    final provider = imageProviderFor(path);
    final image = provider == null
        ? fallback
        : Image(
            image: provider,
            fit: fit,
            gaplessPlayback: true,
            frameBuilder: (_, child, frame, sync) =>
                sync || frame != null ? child : fallback,
            errorBuilder: (_, _, _) => fallback,
          );
    return ClipRRect(
      borderRadius: radius,
      child: aspectRatio == null
          ? image
          : AspectRatio(aspectRatio: aspectRatio!, child: image),
    );
  }
}

class AppStars extends StatelessWidget {
  const AppStars(this.rating, {super.key, this.size = 16, this.count});
  final double rating;
  final double size;
  final int? count;
  @override
  Widget build(BuildContext context) => Semantics(
    label:
        '${NumberFormat('0.0', 'fr').format(rating)} / 5${count == null ? '' : ', $count avis'}',
    excludeSemantics: true,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      spacing: Insets.xs,
      children: [
        Icon(FIcons.star, size: size, color: context.colors.onSurface),
        Text(
          NumberFormat('0.0', 'fr').format(rating),
          style: context.text.labelLarge,
        ),
        if (count != null)
          Text(
            '($count)',
            style: context.text.bodySmall!.copyWith(
              color: context.tones.inkSecondary,
            ),
          ),
      ],
    ),
  );
}

void popSheet<T>(BuildContext context, [T? result]) =>
    Navigator.of(context, rootNavigator: true).pop(result);

Future<T?> showAppSheet<T>(
  BuildContext context, {
  required Widget child,
  String? title,
  bool scrollable = false,
}) => showFSheet<T>(
  context: context,
  side: FLayout.btt,
  mainAxisMaxRatio: scrollable ? .92 : null,
  useRootNavigator: true,
  builder: (ctx) => Material(
    type: MaterialType.transparency,
    child: FCard.raw(
      style: const FCardStyleDelta.delta(
        decoration: DecorationDelta.boxDelta(
          borderRadius: Radii.sheet,
          boxShadow: [],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          Insets.page,
          Insets.sm,
          Insets.page,
          Insets.page + MediaQuery.paddingOf(ctx).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: SizedBox(
                width: 36,
                child: FDivider(style: FDividerStyleDelta.delta(width: 4)),
              ),
            ),
            const SizedBox(height: Insets.lg),
            if (title != null) ...[
              Text(title, style: ctx.text.titleLarge),
              const SizedBox(height: Insets.lg),
            ],
            if (scrollable)
              Flexible(child: SingleChildScrollView(child: child))
            else
              child,
          ],
        ),
      ),
    ),
  ),
);

Future<bool> confirm(
  BuildContext context, {
  required String title,
  String? message,
  required String action,
  bool danger = false,
}) async {
  final r = await showAppSheet<bool>(
    context,
    title: title,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (message != null) ...[
          Text(
            message,
            style: context.text.bodyLarge!.copyWith(
              color: context.tones.inkSecondary,
            ),
          ),
          const SizedBox(height: Insets.xl),
        ],
        AppButton(
          action,
          variant: danger ? AppButtonVariant.danger : AppButtonVariant.primary,
          onPressed: () => popSheet(context, true),
        ),
        const SizedBox(height: Insets.sm),
        AppButton(
          context.l10n.commonCancel,
          variant: AppButtonVariant.ghost,
          onPressed: () => popSheet(context, false),
        ),
      ],
    ),
  );
  return r ?? false;
}

Future<T?> pick<T>(
  BuildContext context, {
  required String title,
  required List<T> options,
  required String Function(T) label,
  IconData? Function(T)? icon,
  T? selected,
}) => showAppSheet<T>(
  context,
  title: title,
  child: FSelectTileGroup<T>(
    maxHeight: MediaQuery.sizeOf(context).height * .6,
    control: FMultiValueControl.managedRadio(
      initial: selected,
      onChange: (v) => popSheet(context, v.firstOrNull),
    ),
    children: [
      for (final o in options)
        FSelectTile.suffix(
          title: Text(label(o)),
          prefix: icon?.call(o) == null ? null : Icon(icon!(o)!),
          value: o,
        ),
    ],
  ),
);

void toast(BuildContext context, String message) => showFToast(
  context: context,
  alignment: FToastAlignment.topCenter,
  title: Text(message),
  duration: const Duration(seconds: 3),
);

class AppNavItem {
  const AppNavItem(this.label, this.icon);
  final String label;
  final IconData icon;
}

class AppNavBar extends StatelessWidget {
  const AppNavBar({
    super.key,
    required this.items,
    required this.index,
    required this.onTap,
  });
  final List<AppNavItem> items;
  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final bg = context.theme.scaffoldBackgroundColor;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [bg.withValues(alpha: 0), bg],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          Insets.page,
          Insets.xl,
          Insets.page,
          MediaQuery.viewPaddingOf(context).bottom + Insets.sm,
        ),
        child: MediaQuery.removeViewPadding(
          context: context,
          removeBottom: true,
          child: FBottomNavigationBar(
            index: index,
            onChange: onTap,
            children: [
              for (final item in items)
                FBottomNavigationBarItem(
                  icon: Icon(item.icon),
                  label: Text(item.label),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppSearchPill extends StatelessWidget {
  const AppSearchPill({
    super.key,
    required this.hint,
    this.onTap,
    this.controller,
    this.focusNode,
    this.onSubmitted,
    this.autofocus = false,
    this.onClear,
  });
  final String hint;
  final VoidCallback? onTap, onClear;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final pill = DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: Radii.full,
        boxShadow: AppShadow.card,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Insets.page,
          Insets.xs,
          Insets.md,
          Insets.xs,
        ),
        child: Row(
          children: [
            Icon(FIcons.search, size: 20, color: context.colors.onSurface),
            const SizedBox(width: Insets.md),
            Expanded(
              child: controller == null
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: Insets.md),
                      child: Text(
                        hint,
                        style: context.text.bodyLarge!.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : FTextField(
                      control: FTextFieldControl.managed(
                        controller: controller,
                      ),
                      focusNode: focusNode,
                      hint: hint,
                      autofocus: autofocus,
                      textInputAction: TextInputAction.search,
                      onSubmit: onSubmitted,
                      style: FTextFieldStyleDelta.delta(
                        color: FVariantsValueDelta.delta([
                          FVariantValueDeltaOperation.all(Colors.transparent),
                        ]),
                        border: FVariantsValueDelta.delta([
                          FVariantValueDeltaOperation.all(InputBorder.none),
                        ]),
                      ),
                      suffixBuilder: onClear == null
                          ? null
                          : (_, _, _) => ListenableBuilder(
                              listenable: controller!,
                              builder: (_, _) => controller!.text.isEmpty
                                  ? const SizedBox.shrink()
                                  : FTappable(
                                      onPress: onClear,
                                      semanticsLabel: context.l10n.commonClose,
                                      excludeSemantics: true,
                                      child: Icon(
                                        FIcons.x,
                                        size: 18,
                                        color: context.tones.inkSecondary,
                                      ),
                                    ),
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
    return onTap == null
        ? pill
        : FTappable(
            onPress: onTap,
            semanticsLabel: hint,
            excludeSemantics: true,
            child: pill,
          );
  }
}

class AppStrip extends StatelessWidget {
  const AppStrip({super.key, required this.height, required this.children});
  final double height;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: Insets.page),
      itemCount: children.length,
      separatorBuilder: (_, _) => const SizedBox(width: Insets.md),
      itemBuilder: (_, i) => children[i],
    ),
  );
}
