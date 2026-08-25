import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:woutalma_keur/app/core/app_config.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/core/feedback/interaction_feedback.dart';
import 'package:woutalma_keur/app/domain/auth_service.dart';
import 'package:woutalma_keur/app/modules/settings/settings_view_model.dart';
import 'package:woutalma_keur/app/shared/theme/wk_motion.dart';
import 'package:woutalma_keur/app/shared/theme/wk_spacing.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_avatar.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_busy_indicator.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_button.dart';
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
    required this.onSignedOut,
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

  /// Ramène à l'accueil client : après une déconnexion, rester sur un onglet
  /// courtier n'a plus de sens.
  final VoidCallback onSignedOut;

  @override
  Widget build(BuildContext context) {
    final SettingsViewModel model = context.watch<SettingsViewModel>();

    return WkScaffold(
      topBar: WkTopBar(
        title: onBack == null
            ? context.l10n.tabProfile
            : context.l10n.settingsTitle,
        onBack: onBack,
      ),
      extendBody: true,
      body: ListView(
        padding: EdgeInsets.only(
          bottom: WkScaffold.bottomInset(context) + WkSpacing.md,
        ),
        children: <Widget>[
          _ProfileHeader(role: model.role, onSignIn: onSignIn),
          Builder(
            builder: (BuildContext context) {
              final Account? account = context.watch<AuthService>().current;
              if (account == null) {
                return const SizedBox.shrink();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SizedBox(height: WkSpacing.lg),
                  _SectionTitle(context.l10n.settingsSectionAccount),
                  _ActionRow(
                    label: context.l10n.settingsSignedInAs(
                      account.displayIdentity,
                    ),
                    icon: Icons.verified_user_outlined,
                    onTap: () => _confirmSignOut(context),
                  ),
                ],
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
          // L'interrupteur de démonstration appartient au build hors ligne.
          // Quand les données viennent du serveur il ne peut rien faire :
          // `toggleMode()` refuse, et confirmer aboutissait à une erreur au
          // bout d'une feuille destructive. Il disparaît donc de l'application
          // livrée, au lieu d'y rester en promettant quelque chose de faux.
          if (model.mode != AppMode.remote) ...<Widget>[
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
          ],
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
              // « Guidage vocal » retiré avec le chemin vocal : le réglage ne
              // commandait plus rien, et un interrupteur sans effet apprend à
              // se méfier de tous les autres.
            ],
          ),
          // Le catalogue des composants est un outil de conception, pas une
          // page de l'application : visible seulement en build de debug, et
          // jamais dans ce qu'on donne à tester.
          if (kDebugMode && AppConfig.showDeveloperTools) ...<Widget>[
            const SizedBox(height: WkSpacing.lg),
            _SectionTitle(context.l10n.settingsSectionDeveloper),
            _ActionRow(
              label: context.l10n.settingsCatalog,
              icon: Icons.widgets_outlined,
              onTap: onOpenCatalog,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final bool? out = await WkConfirmSheet.show(
      context,
      title: context.l10n.settingsSignOutTitle,
      body: context.l10n.settingsSignOutBody,
      confirmLabel: context.l10n.settingsSignOut,
      cancelLabel: context.l10n.commonCancel,
    );
    if (out != true || !context.mounted) {
      return;
    }
    context.read<AuthService>().signOut();
    // Le rôle courtier n'a plus de profil derrière lui une fois la session
    // fermée : y rester afficherait quatre écrans verrouillés.
    context.read<SettingsViewModel>().setRole(UserRole.client);
    onSignedOut();
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

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.role, required this.onSignIn});

  final UserRole role;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    final Account? account = context.watch<AuthService>().current;
    final String identity = account?.displayIdentity ?? '';
    final String name = account?.name ?? identity;
    final Color dim = context.colors.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.all(WkSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(WkRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.colors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: account?.name == null
                    ? Icon(
                        Icons.person_outline,
                        color: context.colors.onPrimaryContainer,
                        size: 28,
                      )
                    : Text(
                        WkAvatar.initials(name.isEmpty ? '?' : name),
                        style: context.text.titleLarge?.copyWith(
                          color: context.colors.onPrimaryContainer,
                        ),
                      ),
              ),
              const SizedBox(width: WkSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      account == null ? context.l10n.profileVisitor : name,
                      style: context.text.headlineMedium,
                    ),
                    Text(
                      account == null
                          ? context.l10n.profileSignInHint
                          : role == UserRole.broker
                          ? context.l10n.profileRoleBroker
                          : context.l10n.profileRoleClient,
                      style: context.text.bodySmall?.copyWith(color: dim),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (account == null) ...<Widget>[
            const SizedBox(height: WkSpacing.md),
            WkButton(
              label: context.l10n.settingsSignIn,
              icon: Icons.login,
              onPressed: onSignIn,
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
