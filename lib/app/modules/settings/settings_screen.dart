import 'package:flutter/material.dart';
import 'package:forui/forui.dart' show FSwitch;
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/domain/auth_service.dart';
import 'package:woutalma_keur/app/modules/settings/settings_view_model.dart';
import 'package:woutalma_keur/app/ui/ui.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    required this.onRoleChanged,
    required this.onSignIn,
    required this.onSignedOut,
    this.onBack,
    this.onOpenCatalog,
    this.onModeChanged,
    super.key,
  });

  final VoidCallback? onBack;

  /// Le rôle a changé : l'application repart sur l'arbre de l'autre rôle.
  final VoidCallback onRoleChanged;

  /// Ouvre G03. Le numéro n'est jamais demandé à l'ouverture de l'app.
  final VoidCallback onSignIn;

  /// Ramène à l'accueil client : après une déconnexion, rester sur un onglet
  /// courtier n'a plus de sens.
  final VoidCallback onSignedOut;

  final VoidCallback? onOpenCatalog, onModeChanged;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SettingsViewModel>();
    final account = context.watch<AuthService>().current;
    final l = context.l10n;
    return AppScaffold(
      title: onBack == null ? l.tabProfile : l.settingsTitle,
      onBack: onBack,
      showBack: onBack != null,
      body: ListView(
        padding: const EdgeInsets.only(bottom: 120),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Insets.page),
            child: _Profile(role: model.role, onSignIn: onSignIn),
          ),
          if (account != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Insets.page,
                Insets.md,
                Insets.page,
                0,
              ),
              child: AppCard.rows([
                AppRow(
                  leading: const Icon(FIcons.logOut),
                  title: l.settingsSignOut,
                  danger: true,
                  onTap: () => _signOut(context),
                ),
              ]),
            ),
          AppSection(l.settingsSectionRole),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Insets.page),
            child: AppCard.rows([
              AppRow(
                leading: Icon(_roleIcon(model.role)),
                title: _roleLabel(context, model.role),
                onTap: () => _pickRole(context, model),
              ),
            ]),
          ),
          AppSection(l.settingsSectionFeedback),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Insets.page),
            child: AppCard.rows([
              AppRow(
                leading: const Icon(FIcons.vibrate),
                title: l.settingsHaptics,
                onTap: () => _setHaptics(model, !model.preferences.haptics),
                trailing: FSwitch(
                  value: model.preferences.haptics,
                  semanticsLabel: l.settingsHaptics,
                  onChange: (v) => _setHaptics(model, v),
                ),
              ),
              AppRow(
                leading: const Icon(FIcons.volume2),
                title: l.settingsSounds,
                onTap: () => _setSounds(model, !model.preferences.sounds),
                trailing: FSwitch(
                  value: model.preferences.sounds,
                  semanticsLabel: l.settingsSounds,
                  onChange: (v) => _setSounds(model, v),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    final l = context.l10n;
    final out = await confirm(
      context,
      title: l.settingsSignOutTitle,
      message: l.settingsSignOutBody,
      action: l.settingsSignOut,
      danger: true,
    );
    if (!out || !context.mounted) return;
    context.read<AuthService>().signOut();
    // Le rôle courtier n'a plus de profil derrière lui une fois la session
    // fermée : y rester afficherait quatre écrans verrouillés.
    context.read<SettingsViewModel>().setRole(UserRole.client);
    onSignedOut();
  }

  Future<void> _pickRole(BuildContext context, SettingsViewModel model) async {
    final picked = await pick<UserRole>(
      context,
      title: context.l10n.settingsSectionRole,
      options: UserRole.values,
      selected: model.role,
      label: (r) => _roleLabel(context, r),
      icon: _roleIcon,
    );
    if (picked == null || picked == model.role) return;
    model.setRole(picked);
    onRoleChanged();
  }
}

class _Profile extends StatelessWidget {
  const _Profile({required this.role, required this.onSignIn});
  final UserRole role;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    final account = context.watch<AuthService>().current;
    final l = context.l10n;
    final name = account?.name;
    return AppCard(
      padding: const EdgeInsets.all(Insets.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (name == null)
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: context.tones.sunken,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    FIcons.user,
                    size: 28,
                    color: context.colors.onSurface,
                  ),
                )
              else
                AppAvatar(name: name, size: 56),
              const SizedBox(width: Insets.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name ?? account?.displayIdentity ?? l.profileVisitor,
                      style: context.text.titleLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      account == null
                          ? l.profileSignInHint
                          : l.settingsSignedInAs(account.displayIdentity),
                      style: context.text.bodySmall!.copyWith(
                        color: context.tones.inkSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Insets.md),
          if (account == null)
            AppButton(l.settingsSignIn, icon: FIcons.logIn, onPressed: onSignIn)
          else
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: AppTag(
                _roleLabel(context, role),
                tone: AppTone.accent,
                icon: _roleIcon(role),
              ),
            ),
        ],
      ),
    );
  }
}

void _setHaptics(SettingsViewModel model, bool value) =>
    model.setPreferences(model.preferences.copyWith(haptics: value));

void _setSounds(SettingsViewModel model, bool value) =>
    model.setPreferences(model.preferences.copyWith(sounds: value));

String _roleLabel(BuildContext context, UserRole role) => switch (role) {
  UserRole.client => context.l10n.roleClient,
  UserRole.broker => context.l10n.roleBroker,
};

IconData _roleIcon(UserRole role) => switch (role) {
  UserRole.client => FIcons.userSearch,
  UserRole.broker => FIcons.store,
};
