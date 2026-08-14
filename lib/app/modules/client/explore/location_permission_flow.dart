import 'package:flutter/material.dart';
import 'package:woutalma_keur/app/core/location/client_position_controller.dart';
import 'package:woutalma_keur/app/domain/location_service.dart';
import 'package:woutalma_keur/app/l10n/generated/app_l10n.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_confirm_sheet.dart';

/// M06 — expliquer avant de demander.
///
/// Extrait de `location_sheet.dart` pour qu'il n'existe qu'une seule
/// implémentation de M06 et un seul chemin « refus définitif → réglages ».
/// Deux appelants : l'amorçage au premier lancement, et le bouton GPS de M02.
///
/// `docs/UX-FLOWS.md` §M06 définit ce moment comme une feuille, pas un écran :
/// une page plein écran posée devant le premier rendu serait un péage, ce que
/// `docs/screen-contracts/client-discovery.md` interdit explicitement.
Future<LocationResult?> requestClientPosition(
  BuildContext context,
  ClientPositionController positions, {

  /// Proposer les réglages système après un refus définitif.
  ///
  /// Seulement quand l'utilisateur a lui-même appuyé sur « Utiliser ma
  /// position ». Au premier lancement, enchaîner une seconde feuille sur un
  /// refus serait précisément la boucle de permission que le contrat interdit.
  bool offerSettingsOnPermanentDenial = true,
}) async {
  final AppL10n l10n = AppL10n.of(context);

  final bool? go = await WkConfirmSheet.show(
    context,
    title: l10n.permissionLocationTitle,
    body: l10n.permissionLocationBody,
    confirmLabel: l10n.permissionContinue,
    cancelLabel: l10n.permissionNotNow,
  );
  // Marqué quelle que soit la réponse : « pas maintenant » est un choix, et il
  // ne se redemande pas au lancement suivant.
  await positions.markPrimed();
  if (go != true || !context.mounted) {
    return null;
  }

  final LocationResult result = await positions.locate();
  if (!context.mounted) {
    return result;
  }

  if (result is LocationRefused &&
      result.reason == LocationRefusal.deniedForever &&
      offerSettingsOnPermanentDenial) {
    final bool? open = await WkConfirmSheet.show(
      context,
      title: l10n.permissionLocationTitle,
      body: l10n.locationDenied,
      confirmLabel: l10n.permissionOpenSettings,
      cancelLabel: l10n.permissionNotNow,
    );
    if (open == true) {
      await positions.openSettings();
    }
  }
  return result;
}
