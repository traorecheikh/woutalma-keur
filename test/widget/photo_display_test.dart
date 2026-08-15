import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_keur/app/core/app_config.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_property_photo.dart';

import '../support/pump.dart';

void main() {
  test('une clé `api:` se résout vers la route du serveur', () {
    // C'est la forme que rend le serveur pour toute photo téléversée par un
    // courtier. Sans cette résolution, elle finissait dans `Image.file` et ne
    // s'affichait que sur le téléphone qui l'avait publiée.
    expect(
      WkPropertyPhoto.resolve('api:ckph1'),
      '${AppConfig.apiBaseUrl}/properties/photos/ckph1',
    );
  });

  test('les deux autres provenances ne bougent pas', () {
    expect(
      WkPropertyPhoto.resolve('demo:house:medina:front'),
      'assets/seed/photos/house-medina-front.webp',
    );
    expect(
      WkPropertyPhoto.resolve('/data/user/0/wk-1.jpg'),
      '/data/user/0/wk-1.jpg',
    );
  });

  testWidgets('une photo `api:` est demandée au réseau', (
    WidgetTester tester,
  ) async {
    await pumpWk(
      tester,
      const SizedBox(
        width: 120,
        height: 120,
        child: WkPropertyPhoto(path: 'api:ckph1', fallbackIcon: Icons.home),
      ),
    );

    final Image image = tester.widget<Image>(find.byType(Image));
    expect(
      image.image,
      isA<NetworkImage>().having(
        (NetworkImage provider) => provider.url,
        'url',
        '${AppConfig.apiBaseUrl}/properties/photos/ckph1',
      ),
    );
  });

  testWidgets('une photo de démonstration reste un asset embarqué', (
    WidgetTester tester,
  ) async {
    await pumpWk(
      tester,
      const SizedBox(
        width: 120,
        height: 120,
        child: WkPropertyPhoto(
          path: 'demo:house:medina:front',
          fallbackIcon: Icons.home,
        ),
      ),
    );

    // Aucun réseau au premier lancement : le seed doit rester local.
    expect(tester.widget<Image>(find.byType(Image)).image, isA<AssetImage>());
  });
}
