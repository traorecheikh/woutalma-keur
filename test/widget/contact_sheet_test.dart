import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/modules/client/broker/contact_sheet.dart';

import '../support/pump.dart';

void main() {
  const Broker broker = Broker(
    id: 'brk-test',
    kind: BrokerKind.agency,
    name: 'Agence Teranga',
    phone: '+221771234567',
    whatsapp: '+221771234567',
    position: GeoPoint(14.69, -17.45),
    coverage: <String>['Médina', 'Plateau', 'Mermoz'],
    verification: VerificationStatus.verified,
    responseRate: 0.82,
  );

  testWidgets('la feuille de contact donne le contexte avant les canaux', (
    WidgetTester tester,
  ) async {
    await pumpWk(
      tester,
      const ContactSheet(broker: broker),
      surfaceSize: const Size(360, 640),
      textScale: 1.3,
    );

    expect(find.text('Comment le joindre ?'), findsOneWidget);
    expect(find.text('Agence Teranga'), findsOneWidget);
    expect(find.text('Vérifié'), findsOneWidget);
    expect(find.text('Répond à 82 % des demandes'), findsOneWidget);
    expect(find.text('Médina'), findsOneWidget);
    expect(find.text('Appeler'), findsOneWidget);
    expect(find.text('Écrire sur WhatsApp'), findsOneWidget);
    expect(find.text('Envoyer un SMS'), findsOneWidget);
    expectNoClippedText(tester);
    expectTouchTargets(tester);
  });

  testWidgets('WhatsApp disparaît quand le courtier ne le propose pas', (
    WidgetTester tester,
  ) async {
    await pumpWk(
      tester,
      ContactSheet(broker: broker.copyWithoutWhatsapp()),
      surfaceSize: const Size(360, 640),
    );

    expect(find.text('Appeler'), findsOneWidget);
    expect(find.text('Écrire sur WhatsApp'), findsNothing);
    expect(find.text('Envoyer un SMS'), findsOneWidget);
  });
}

extension on Broker {
  Broker copyWithoutWhatsapp() {
    return Broker(
      id: id,
      kind: kind,
      name: name,
      phone: phone,
      position: position,
      coverage: coverage,
      logoAsset: logoAsset,
      verification: verification,
      responseRate: responseRate,
      pinned: pinned,
    );
  }
}
