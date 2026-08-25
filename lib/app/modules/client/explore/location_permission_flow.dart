import 'package:flutter/material.dart';
import 'package:woutalma_keur/app/core/location/client_position_controller.dart';
import 'package:woutalma_keur/app/domain/location_service.dart';
import 'package:woutalma_keur/app/ui/ui.dart';

/// M06 — expliquer avant de demander.
///
/// Une seule implémentation dans l'application, donc un seul chemin « refus
/// définitif → réglages ». Deux appelants : l'amorçage au premier lancement et
/// le bouton GPS de M02.
Future<LocationResult?> requestClientPosition(
  BuildContext context,
  ClientPositionController positions, {

  /// Au premier lancement, enchaîner une seconde feuille sur un refus serait
  /// la boucle de permission que le contrat interdit.
  bool offerSettingsOnPermanentDenial = true,
}) async {
  final l = context.l10n;
  final go = await _ask(
    context,
    title: l.permissionLocationTitle,
    body: l.permissionLocationBody,
    action: l.permissionContinue,
  );
  // Marqué quelle que soit la réponse : « pas maintenant » est un choix, et il
  // ne se redemande pas au lancement suivant.
  await positions.markPrimed();
  if (!go || !context.mounted) return null;

  final result = await positions.locate();
  if (!context.mounted) return result;

  if (result is LocationRefused &&
      result.reason == LocationRefusal.deniedForever &&
      offerSettingsOnPermanentDenial) {
    final open = await _ask(
      context,
      title: l.permissionLocationTitle,
      body: l.locationDenied,
      action: l.permissionOpenSettings,
    );
    if (open) await positions.openSettings();
  }
  return result;
}

Future<bool> _ask(
  BuildContext context, {
  required String title,
  required String body,
  required String action,
}) async {
  final chosen = await showAppSheet<bool>(
    context,
    title: title,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          body,
          style: context.text.bodyLarge!.copyWith(
            color: context.tones.inkSecondary,
          ),
        ),
        const SizedBox(height: Insets.xl),
        AppButton(
          action,
          icon: FIcons.locateFixed,
          onPressed: () => popSheet(context, true),
        ),
        const SizedBox(height: Insets.sm),
        AppButton(
          context.l10n.permissionNotNow,
          variant: AppButtonVariant.ghost,
          onPressed: () => popSheet(context, false),
        ),
      ],
    ),
  );
  return chosen ?? false;
}
