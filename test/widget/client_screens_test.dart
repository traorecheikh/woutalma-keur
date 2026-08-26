import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/data/repositories/in_memory_repositories.dart';
import 'package:woutalma_keur/app/data/seed/demo_seed.dart';
import 'package:woutalma_keur/app/domain/auth_service.dart';
import 'package:woutalma_keur/app/domain/contact_launcher.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/location_service.dart';
import 'package:woutalma_keur/app/domain/review_eligibility.dart';
import 'package:woutalma_keur/app/modules/auth/auth_screens.dart';
import 'package:woutalma_keur/app/modules/client/broker/broker_screen.dart';
import 'package:woutalma_keur/app/modules/client/broker/broker_view_model.dart';
import 'package:woutalma_keur/app/modules/client/broker/contact_sheet.dart';
import 'package:woutalma_keur/app/modules/client/explore/location_sheet.dart';
import 'package:woutalma_keur/app/modules/client/history/history_screen.dart';
import 'package:woutalma_keur/app/modules/client/history/history_view_model.dart';
import 'package:woutalma_keur/app/modules/client/review/review_screen.dart';
import 'package:woutalma_keur/app/modules/settings/settings_screen.dart';
import 'package:woutalma_keur/app/modules/settings/settings_view_model.dart';
import 'package:woutalma_keur/app/ui/ui.dart';

import '../support/fake_location.dart';
import '../support/fonts.dart';
import '../support/pump.dart';

class _NoopLauncher implements ContactLauncher {
  @override
  Future<bool> open(ContactChannel channel, Broker broker) async => true;
}

class _Location implements LocationService {
  @override
  Future<LocationResult> current() async =>
      const LocationFound(DemoSeed.clientPosition);
  @override
  Future<bool> hasPermission() async => false;
  @override
  Future<void> openSettings() async {}
  @override
  List<Neighbourhood> knownNeighbourhoods() => dakarNeighbourhoods;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadAppFonts);
  late InMemoryStore store;

  setUp(() async {
    store = InMemoryStore();
    await InMemorySeedRepository(store).loadDemoSeed();
  });

  for (final scale in [1.0, 1.3]) {
    testWidgets('C02 rend la fiche courtier ×$scale', (tester) async {
      final model = BrokerViewModel(
        brokerId: 'brk-teranga',
        brokers: InMemoryBrokerRepository(store),
        properties: InMemoryPropertyRepository(store),
        reviews: InMemoryReviewRepository(store),
        contact: ContactService(
          contacts: InMemoryContactRepository(
            store,
            now: () => DateTime(2026, 1, 1),
          ),
          launcher: _NoopLauncher(),
        ),
        from: DemoSeed.clientPosition,
      );
      await model.load();
      addTearDown(model.dispose);

      await pumpWk(
        tester,
        ChangeNotifierProvider<BrokerViewModel>.value(
          value: model,
          child: BrokerScreen(onBack: () {}, onOpenProperty: (_) {}),
        ),
        surfaceSize: const Size(360, 640),
        textScale: scale,
      );
      await tester.pumpAndSettle();
      expect(find.text('Agence Teranga Immo'), findsWidgets);
      expect(find.text('Contacter'), findsOneWidget);
    });
  }

  testWidgets('M04 ouvre la feuille de contact et rend le canal', (
    tester,
  ) async {
    final broker = (await InMemoryBrokerRepository(store).byId('brk-teranga'))!;
    ContactChannel? picked;
    await pumpWk(
      tester,
      Builder(
        builder: (context) => Center(
          child: AppButton(
            'ouvrir',
            onPressed: () async =>
                picked = await ContactSheet.show(context, broker: broker),
          ),
        ),
      ),
      surfaceSize: const Size(360, 720),
    );
    await tester.tap(find.text('ouvrir'));
    await tester.pumpAndSettle();
    expect(find.text('Appeler'), findsOneWidget);
    expect(find.text('Écrire sur WhatsApp'), findsOneWidget);
    await tester.tap(find.text('Appeler'));
    await tester.pumpAndSettle();
    expect(picked, ContactChannel.call);
  });

  testWidgets('M05 rend le résultat du contact', (tester) async {
    ContactOutcome? outcome;
    await pumpWk(
      tester,
      Builder(
        builder: (context) => Center(
          child: AppButton(
            'ouvrir',
            onPressed: () async =>
                outcome = await ContactOutcomeSheet.show(context),
          ),
        ),
      ),
    );
    await tester.tap(find.text('ouvrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Oui, on a échangé').first);
    await tester.pumpAndSettle();
    expect(outcome, ContactOutcome.reached);
  });

  testWidgets('C04 groupe les contacts par courtier', (tester) async {
    final contacts = InMemoryContactRepository(
      store,
      now: () => DateTime.utc(2026, 8, 1),
    );
    await contacts.log(brokerId: 'brk-moussa', channel: ContactChannel.call);
    final model = HistoryViewModel(
      contacts: contacts,
      brokers: InMemoryBrokerRepository(store),
      eligibility: ReviewEligibilityService(contacts),
    );
    await model.load();
    addTearDown(model.dispose);

    await pumpWk(
      tester,
      ChangeNotifierProvider<HistoryViewModel>.value(
        value: model,
        child: HistoryScreen(onSearch: () {}, onReview: (_) {}),
      ),
      surfaceSize: const Size(360, 760),
      textScale: 1.3,
    );
    await tester.pumpAndSettle();
    expect(find.text('Avez-vous eu cette personne ?'), findsWidgets);
  });

  testWidgets('C05 passe des étoiles au commentaire', (tester) async {
    final contacts = InMemoryContactRepository(
      store,
      now: () => DateTime.utc(2026, 8, 1),
    );
    final log = await contacts.log(
      brokerId: 'brk-moussa',
      channel: ContactChannel.call,
    );
    final model = ReviewViewModel(
      contact: log,
      reviews: InMemoryReviewRepository(store),
      contacts: contacts,
      now: () => DateTime.utc(2026, 8, 2),
    );
    addTearDown(model.dispose);

    await pumpWk(
      tester,
      ChangeNotifierProvider<ReviewViewModel>.value(
        value: model,
        child: ReviewScreen(brokerName: 'Moussa', onDone: () {}, onBack: () {}),
      ),
      surfaceSize: const Size(360, 760),
      textScale: 1.3,
    );
    await tester.pumpAndSettle();
    expect(find.text('Choisissez d\'abord une note'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('4 étoiles').first);
    await tester.pumpAndSettle();
    expect(model.rating, 4);
    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();
    expect(find.text('Envoyer l\'avis'), findsOneWidget);
  });

  testWidgets('S01 rend le profil signé et non signé', (tester) async {
    final auth = SimulatedAuthService();
    final settings = SettingsViewModel(seed: InMemorySeedRepository(store));
    addTearDown(settings.dispose);

    await pumpWk(
      tester,
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>.value(value: auth),
          ChangeNotifierProvider<SettingsViewModel>.value(value: settings),
        ],
        child: SettingsScreen(
          onRoleChanged: () {},
          onSignIn: () {},
          onSignedOut: () {},
        ),
      ),
      surfaceSize: const Size(360, 760),
      textScale: 1.3,
    );
    await tester.pumpAndSettle();
    expect(find.text('Visiteur'), findsOneWidget);
    expect(find.text('M\'identifier'), findsOneWidget);
    expect(find.text('Mode démonstration'), findsNothing);
    expect(find.text('Catalogue des composants'), findsNothing);

    await auth.requestCode('+221771234567');
    await auth.verify('+221771234567', '123456');
    await tester.pumpAndSettle();
    expect(find.text('Sortir de mon compte'), findsOneWidget);
  });

  testWidgets('G03 rend le champ téléphone', (tester) async {
    final auth = SimulatedAuthService();
    await pumpWk(
      tester,
      ChangeNotifierProvider<AuthService>.value(
        value: auth,
        child: PhoneScreen(
          reason: 'Pour contacter ce courtier',
          onBack: () {},
          onCodeSent: (_, _, _) {},
          onSignedIn: () {},
        ),
      ),
      surfaceSize: const Size(360, 720),
      textScale: 1.3,
    );
    await tester.pumpAndSettle();
    expect(find.text('Pour contacter ce courtier'), findsOneWidget);
    expect(find.text('Recevoir le code'), findsOneWidget);
  });

  testWidgets('G04 rend les six cases et le code de démonstration', (
    tester,
  ) async {
    final auth = SimulatedAuthService();
    await pumpWk(
      tester,
      ChangeNotifierProvider<AuthService>.value(
        value: auth,
        child: OtpScreen(
          phone: '+221771234567',
          simulatedCode: '123456',
          onBack: () {},
          onVerified: () {},
        ),
      ),
      surfaceSize: const Size(360, 720),
      textScale: 1.3,
    );
    await tester.pump();
    expect(find.textContaining('Code de démonstration'), findsOneWidget);
  });

  testWidgets('M02 liste les quartiers et rend celui choisi', (tester) async {
    Neighbourhood? chosen;
    await pumpWk(
      tester,
      Builder(
        builder: (context) => Center(
          child: AppButton(
            'ouvrir',
            onPressed: () async => chosen = await LocationSheet.show(
              context,
              service: _Location(),
              positions: fakePositions(),
              recents: const [],
            ),
          ),
        ),
      ),
      surfaceSize: const Size(360, 760),
    );
    await tester.tap(find.text('ouvrir'));
    await tester.pumpAndSettle();
    expect(find.text('Utiliser ma position'), findsOneWidget);
    await tester.tap(find.text('Mermoz'));
    await tester.pumpAndSettle();
    expect(chosen?.name, 'Mermoz');
  });
}
