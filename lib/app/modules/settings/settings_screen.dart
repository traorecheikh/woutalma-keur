import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/core/feedback/interaction_feedback.dart';
import 'package:woutalma_keur/app/domain/auth_service.dart';
import 'package:woutalma_keur/app/modules/settings/settings_view_model.dart';
import 'package:woutalma_keur/app/shared/theme/wk_motion.dart';
import 'package:woutalma_keur/app/shared/theme/wk_spacing.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_busy_indicator.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_confirm_sheet.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_option_sheet.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_scaffold.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_toast.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_top_bar.dart';

/// S01 — Réglages.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    required this.onOpenCatalog,
    required this.onModeChanged,
    required this.onRoleChanged,
    required this.onSignIn,
    this.onBack,
    super.key,
  });

  final VoidCallback? onBack;
  final VoidCallback onOpenCatalog;

  /// Prévient l'application que les données ont été remplacées, pour qu'elle
  /// reparte d'un état propre.
  final VoidCallback onModeChanged;

  /// Le rôle a changé : l'application repart sur l'arbre de l'autre rôle.
  final VoidCallback onRoleChanged;

  /// Ouvre G03. Le numéro n'est jamais demandé à l'ouverture de l'app.
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    final SettingsViewModel model = context.watch<SettingsViewModel>();

    return WkScaffold(
      topBar: WkTopBar(title: context.l10n.settingsTitle, onBack: onBack),
      extendBody: true,
      body: ListView(
        padding: EdgeInsets.only(
          bottom: WkScaffold.bottomInset(context) + WkSpacing.md,
        ),
        children: <Widget>[
          _SectionTitle(context.l10n.settingsSectionAccount),
          Builder(
            builder: (BuildContext context) {
              final Account? account = context.read<AuthService>().current;
              return _ActionRow(
                label: account == null
                    ? context.l10n.settingsSignIn
                    : context.l10n.settingsSignedInAs(account.displayIdentity),
                icon: account == null
                    ? Icons.login
                    : Icons.verified_user_outlined,
                onTap: onSignIn,
              );
            },
          ),
          const SizedBox(height: WkSpacing.lg),
          _SectionTitle(context.l10n.settingsSectionRole),
          _ActionRow(
            label: model.role == UserRole.client
                ? context.l10n.roleClient
                : context.l10n.roleBroker,
            icon: model.role == UserRole.client
                ? Icons.person_search_outlined
                : Icons.storefront_outlined,
            onTap: () => _switchRole(context, model),
          ),
          const SizedBox(height: WkSpacing.lg),
          _SectionTitle(context.l10n.settingsSectionData),
          _SettingGroup(
            children: <Widget>[
              _SwitchRow(
                label: context.l10n.settingsDemoMode,
                icon: Icons.storage_outlined,
                description: model.mode == AppMode.demo
                    ? context.l10n.settingsDemoModeOn
                    : context.l10n.settingsDemoModeOff,
                value: model.mode == AppMode.demo,
                busy: model.switching.isSubmitting,
                onChanged: (_) => _confirmToggle(context, model),
              ),
            ],
          ),
          const SizedBox(height: WkSpacing.lg),
          _SectionTitle(context.l10n.settingsSectionFeedback),
          _SettingGroup(
            children: <Widget>[
              _SwitchRow(
                label: context.l10n.settingsHaptics,
                icon: Icons.vibration,
                value: model.preferences.haptics,
                onChanged: (bool v) => model.setPreferences(
                  model.preferences.copyWith(haptics: v),
                ),
              ),
              _SwitchRow(
                label: context.l10n.settingsSounds,
                icon: Icons.volume_up_outlined,
                value: model.preferences.sounds,
                onChanged: (bool v) =>
                    model.setPreferences(model.preferences.copyWith(sounds: v)),
              ),
              _SwitchRow(
                label: context.l10n.settingsGuidedVoice,
                icon: Icons.record_voice_over_outlined,
                // Quand un lecteur d'écran tourne, le guidage se tait. On le dit,
                // plutôt que de le laisser muet sans raison visible.
                description: MediaQuery.accessibleNavigationOf(context)
                    ? context.l10n.settingsGuidedVoiceSuppressed
                    : null,
                value: model.preferences.guidedVoice,
                onChanged: (bool v) => model.setPreferences(
                  model.preferences.copyWith(guidedVoice: v),
                ),
              ),
            ],
          ),
          const SizedBox(height: WkSpacing.lg),
          _SectionTitle(context.l10n.settingsSectionDeveloper),
          _ActionRow(
            label: context.l10n.settingsCatalog,
            icon: Icons.widgets_outlined,
            onTap: onOpenCatalog,
          ),
        ],
      ),
    );
  }

  Future<void> _switchRole(
    BuildContext context,
    SettingsViewModel model,
  ) async {
    final List<UserRole>? picked = await WkOptionSheet.show<UserRole>(
      context,
      title: context.l10n.settingsSectionRole,
      selected: model.role,
      options: <WkOption<UserRole>>[
        WkOption<UserRole>(
          value: UserRole.client,
          label: context.l10n.roleClient,
          icon: Icons.person_search_outlined,
        ),
        WkOption<UserRole>(
          value: UserRole.broker,
          label: context.l10n.roleBroker,
          icon: Icons.storefront_outlined,
        ),
      ],
    );
    if (picked == null || picked.first == model.role) {
      return;
    }
    model.setRole(picked.first);
    onRoleChanged();
  }

  Future<void> _confirmToggle(
    BuildContext context,
    SettingsViewModel model,
  ) async {
    final int count = await model.impactCount();
    if (!context.mounted) {
      return;
    }

    final bool? confirmed = await WkConfirmSheet.show(
      context,
      title: model.mode == AppMode.demo
          ? context.l10n.settingsDemoDisableTitle
          : context.l10n.settingsDemoEnableTitle,
      body: context.l10n.settingsDemoImpact(count),
      confirmLabel: context.l10n.settingsDemoConfirm,
      cancelLabel: context.l10n.commonCancel,
      destructive: true,
    );
    if (confirmed != true || !context.mounted) {
      return;
    }

    final bool ok = await model.toggleMode();
    if (!context.mounted) {
      return;
    }
    if (ok) {
      context.read<InteractionFeedbackService?>()?.emit(
        FeedbackIntent.success,
        eventId: 'S01:success:mode-${model.mode.name}',
      );
      WkToast.show(context, message: context.l10n.settingsDemoDone);
      onModeChanged();
    } else {
      WkToast.show(context, message: context.l10n.failureSeed);
    }
  }
}

class _SettingGroup extends StatelessWidget {
  const _SettingGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(WkRadius.lg),
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: Column(
        children: <Widget>[
          for (int i = 0; i < children.length; i++) ...<Widget>[
            children[i],
            if (i < children.length - 1)
              Divider(
                height: 1,
                indent: WkTouch.min + WkSpacing.md,
                color: context.colors.outlineVariant,
              ),
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: WkSpacing.sm),
      child: Semantics(
        header: true,
        child: Text(label, style: context.text.headlineMedium),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
    this.description,
    this.busy = false,
  });

  final String label;
  final String? description;
  final IconData icon;
  final bool value;
  final bool busy;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      label: label,
      child: InkWell(
        onTap: busy ? null : () => onChanged(!value),
        borderRadius: BorderRadius.circular(WkRadius.lg),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: WkSpacing.md,
            vertical: WkSpacing.sm,
          ),
          child: Row(
            children: <Widget>[
              _IconBubble(icon: icon),
              const SizedBox(width: WkSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(label, style: context.text.bodyLarge),
                    if (description != null)
                      Text(
                        description!,
                        style: context.text.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              if (busy)
                WkBusyIndicator(color: context.colors.primary, size: 24)
              else
                _TogglePill(value: value, onChanged: onChanged),
            ],
          ),
        ),
      ),
    );
  }
}

class _TogglePill extends StatelessWidget {
  const _TogglePill({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(WkRadius.full),
        child: SizedBox(
          width: WkTouch.comfy,
          height: WkTouch.min,
          child: Center(
            child: AnimatedContainer(
              duration: context.motion.fast,
              curve: WkMotion.standardCurve,
              width: WkTouch.comfy,
              height: WkSpacing.xl + WkSpacing.sm,
              padding: const EdgeInsets.all(WkSpacing.xs),
              decoration: BoxDecoration(
                color: value
                    ? context.colors.primaryContainer
                    : context.colors.surfaceVariant,
                borderRadius: BorderRadius.circular(WkRadius.full),
                border: Border.all(
                  color: value
                      ? context.colors.primary
                      : context.colors.outline,
                  width: 1.5,
                ),
              ),
              child: AnimatedAlign(
                duration: context.motion.fast,
                curve: WkMotion.standardCurve,
                alignment: value
                    ? AlignmentDirectional.centerEnd
                    : AlignmentDirectional.centerStart,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: value
                        ? context.colors.primary
                        : context.colors.onSurfaceVariant,
                    borderRadius: BorderRadius.circular(WkRadius.full),
                  ),
                  child: const SizedBox(
                    width: WkSpacing.xl - WkSpacing.xs,
                    height: WkSpacing.xl - WkSpacing.xs,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(WkRadius.lg),
        child: Container(
          constraints: const BoxConstraints(minHeight: WkTouch.comfy),
          padding: const EdgeInsets.all(WkSpacing.md),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(WkRadius.lg),
            border: Border.all(color: context.colors.outlineVariant),
          ),
          child: Row(
            children: <Widget>[
              _IconBubble(icon: icon),
              const SizedBox(width: WkSpacing.md),
              Expanded(child: Text(label, style: context.text.bodyLarge)),
              Icon(Icons.chevron_right, color: context.colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconBubble extends StatelessWidget {
  const _IconBubble({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.primaryContainer,
        borderRadius: BorderRadius.circular(WkRadius.full),
      ),
      child: SizedBox(
        width: WkTouch.min,
        height: WkTouch.min,
        child: Icon(icon, color: context.colors.onPrimaryContainer),
      ),
    );
  }
}
