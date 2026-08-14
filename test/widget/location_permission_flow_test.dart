import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_keur/app/core/location/client_position_controller.dart';
import 'package:woutalma_keur/app/domain/location_service.dart';
import 'package:woutalma_keur/app/l10n/generated/app_l10n.dart';
import 'package:woutalma_keur/app/modules/client/explore/location_permission_flow.dart';

import '../support/fake_location.dart';
import '../support/pump.dart';

/// Aligne la vue de test sur un téléphone d'entrée de gamme.
void _useRealisticView(WidgetTester tester) {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// Bouton nu qui déclenche M06, pour tester le flux sans monter C01 entier.
class _Trigger extends StatelessWidget {
  const _Trigger({required this.positions, this.offerSettings = true});

  final ClientPositionController positions;
  final bool offerSettings;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () => requestClientPosition(
          context,
          positions,
          offerSettingsOnPermanentDenial: offerSettings,
        ),
        child: const Text('go'),
      ),
    );
  }
}

void main() {
  // `setSurfaceSize` redimensionne l'arbre, pas la vue. Une feuille modale est
  // ancrée à la vue, donc sans cela ses boutons se posent hors de l'écran de
  // test et deviennent intouchables — un artefact du harnais, pas un défaut de
  // la feuille.
  testWidgets('l\'explication précède la demande système', (
    WidgetTester tester,
  ) async {
    _useRealisticView(tester);
    final FakeLocationService location = FakeLocationService();
    final ClientPositionController positions = fakePositions(
      location: location,
      primed: false,
    );

    await pumpWk(tester, _Trigger(positions: positions), positions: positions);
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();

    // La feuille est là, et rien n'a encore été demandé au système : c'est
    // tout l'objet de M06, une autorisation refusée par réflexe ne se
    // redemande pas.
    final AppL10n l10n = AppL10n.of(tester.element(find.text('go')));
    expect(find.text(l10n.permissionLocationTitle), findsOneWidget);
    expect(location.calls, 0);
  });

  testWidgets('« Pas maintenant » n\'appelle jamais le système', (
    WidgetTester tester,
  ) async {
    _useRealisticView(tester);
    final FakeLocationService location = FakeLocationService();
    final ClientPositionController positions = fakePositions(
      location: location,
      primed: false,
    );

    await pumpWk(tester, _Trigger(positions: positions), positions: positions);
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();

    final AppL10n l10n = AppL10n.of(tester.element(find.text('go')));
    await tester.tap(find.text(l10n.permissionNotNow));
    await tester.pumpAndSettle();

    expect(location.calls, 0);
    // Refuser reste un choix : il est mémorisé, donc pas de relance.
    expect(positions.hasBeenPrimed, isTrue);
  });

  testWidgets('continuer demande la position une seule fois', (
    WidgetTester tester,
  ) async {
    _useRealisticView(tester);
    final FakeLocationService location = FakeLocationService();
    final ClientPositionController positions = fakePositions(
      location: location,
      primed: false,
    );

    await pumpWk(tester, _Trigger(positions: positions), positions: positions);
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();

    final AppL10n l10n = AppL10n.of(tester.element(find.text('go')));
    await tester.ensureVisible(find.text(l10n.permissionContinue));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.permissionContinue));
    await tester.pumpAndSettle();

    expect(location.calls, 1);
    expect(positions.isFromGps, isTrue);
  });

  testWidgets(
    'un refus définitif ne propose les réglages que sur le chemin explicite',
    (WidgetTester tester) async {
      _useRealisticView(tester);
      final FakeLocationService location = FakeLocationService(
        result: const LocationRefused(LocationRefusal.deniedForever),
      );
      final ClientPositionController positions = fakePositions(
        location: location,
        primed: false,
      );

      // Chemin premier lancement : pas de seconde feuille, ce serait la
      // boucle de permission que le contrat d'écran interdit.
      await pumpWk(
        tester,
        _Trigger(positions: positions, offerSettings: false),
        positions: positions,
      );
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      final AppL10n l10n = AppL10n.of(tester.element(find.text('go')));
      await tester.ensureVisible(find.text(l10n.permissionContinue));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.permissionContinue));
      await tester.pumpAndSettle();

      expect(find.text(l10n.permissionOpenSettings), findsNothing);
      expect(location.settingsOpened, 0);
    },
  );
}
