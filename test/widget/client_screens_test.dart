import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/data/repositories/in_memory_repositories.dart';
import 'package:woutalma_keur/app/data/seed/demo_seed.dart';
import 'package:woutalma_keur/app/domain/auth_service.dart';
import 'package:woutalma_keur/app/domain/contact_launcher.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/location_service.dart';
import 'package:woutalma_keur/app/domain/repositories.dart';
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
  final List<ContactChannel> opened = <ContactChannel>[];

  @override
  Future<bool> open(ContactChannel channel, Broker broker) async {
    opened.add(channel);
    return true;
  }
}

/// Ce que répond l'API quand personne n'est identifié.
class _UnauthorizedContacts implements ContactRepository {
  @override
  Future<List<ContactLog>> all() async => throw DioException(
    requestOptions: RequestOptions(path: '/contacts'),
    response: Response<void>(
      requestOptions: RequestOptions(path: '/contacts'),
      statusCode: 401,
    ),
  );

  @override
  Future<ContactLog?> byId(String id) async => null;
  @override
  Future<ContactLog> log({
    required String brokerId,
    String? propertyId,
    required ContactChannel channel,
  }) => throw UnimplementedError();
  @override
  Future<List<ContactLog>> receivedBy(String brokerId) async => <ContactLog>[];
  @override
  Future<void> update(ContactLog contact) async {}
  @override
  Future<void> updateAll(List<ContactLog> contacts) async {}
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
          child: BrokerScreen(
            onBack: () {},
            onOpenProperty: (_) {},
            onSignIn: () {},
          ),
        ),
        surfaceSize: const Size(360, 640),
        textScale: scale,
      );
      await tester.pumpAndSettle();
      expect(find.text('Agence Teranga Immo'), findsWidgets);
      expect(find.text('Contacter'), findsOneWidget);
      // Le numéro était invisible : sans crédit data, la fiche ne servait à
      // rien.
      expect(find.textContaining('+221'), findsWidgets);
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

  testWidgets('sans session, C02 propose de s\'identifier ou d\'appeler', (
    tester,
  ) async {
    final launcher = _NoopLauncher();
    final contacts = InMemoryContactRepository(
      store,
      now: () => DateTime(2026, 1, 1),
    );
    final model = BrokerViewModel(
      brokerId: 'brk-teranga',
      brokers: InMemoryBrokerRepository(store),
      properties: InMemoryPropertyRepository(store),
      reviews: InMemoryReviewRepository(store),
      contact: ContactService(contacts: contacts, launcher: launcher),
      from: DemoSeed.clientPosition,
    );
    await model.load();
    addTearDown(model.dispose);

    final int loggedBefore = (await contacts.all()).length;
    var askedToSignIn = 0;
    await pumpWk(
      tester,
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>.value(
            value: SimulatedAuthService(),
          ),
          ChangeNotifierProvider<BrokerViewModel>.value(value: model),
        ],
        child: BrokerScreen(
          onBack: () {},
          onOpenProperty: (_) {},
          onSignIn: () => askedToSignIn++,
        ),
      ),
      surfaceSize: const Size(360, 760),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Contacter'));
    await tester.pumpAndSettle();
    expect(find.text('Pour contacter, entrez votre numéro'), findsOneWidget);

    // Refuser le compte ne doit pas priver de téléphone.
    await tester.tap(find.text('Appeler sans compte'));
    await tester.pumpAndSettle();
    expect(launcher.opened, [ContactChannel.call]);
    expect((await contacts.all()).length, loggedBefore);
    expect(askedToSignIn, 0);

    await tester.tap(find.text('Contacter'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Entrer mon numéro'));
    await tester.pumpAndSettle();
    expect(askedToSignIn, 1);
  });

  testWidgets('M05 est posée au retour de l\'application externe', (
    tester,
  ) async {
    final contacts = InMemoryContactRepository(
      store,
      now: () => DateTime(2026, 1, 1),
    );
    final model = BrokerViewModel(
      brokerId: 'brk-teranga',
      brokers: InMemoryBrokerRepository(store),
      properties: InMemoryPropertyRepository(store),
      reviews: InMemoryReviewRepository(store),
      contact: ContactService(contacts: contacts, launcher: _NoopLauncher()),
      from: DemoSeed.clientPosition,
    );
    await model.load();
    addTearDown(model.dispose);

    await pumpWk(
      tester,
      ChangeNotifierProvider<BrokerViewModel>.value(
        value: model,
        child: BrokerScreen(
          onBack: () {},
          onOpenProperty: (_) {},
          onSignIn: () {},
        ),
      ),
      surfaceSize: const Size(360, 760),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Contacter'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Appeler'));
    await tester.pumpAndSettle();

    for (final state in [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }
    await tester.pumpAndSettle();

    // Sans cette question, le contact restait « tentative » et aucun avis ne
    // s'ouvrait jamais.
    expect(find.text('Avez-vous pu lui parler ?'), findsOneWidget);
    await tester.tap(find.text('Oui, on a échangé').first);
    await tester.pumpAndSettle();
    final logged = (await contacts.all()).firstWhere(
      (c) => c.createdAt == DateTime(2026, 1, 1),
    );
    expect(logged.outcome, ContactOutcome.reached);
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
        child: HistoryScreen(
          onSearch: () {},
          onReview: (_) {},
          onCallAgain: (_) {},
          onSignIn: () {},
        ),
      ),
      surfaceSize: const Size(360, 760),
      textScale: 1.3,
    );
    await tester.pumpAndSettle();
    expect(find.text('Avez-vous eu cette personne ?'), findsWidgets);
    expect(find.text('Rappeler'), findsWidgets);
  });

  testWidgets('C04 sans session invite à s\'identifier', (tester) async {
    final model = HistoryViewModel(
      contacts: _UnauthorizedContacts(),
      brokers: InMemoryBrokerRepository(store),
      eligibility: ReviewEligibilityService(
        InMemoryContactRepository(store, now: DateTime.now),
      ),
    );
    await model.load();
    addTearDown(model.dispose);
    expect(model.signedOut, isTrue);

    var asked = 0;
    await pumpWk(
      tester,
      ChangeNotifierProvider<HistoryViewModel>.value(
        value: model,
        child: HistoryScreen(
          onSearch: () {},
          onReview: (_) {},
          onCallAgain: (_) {},
          onSignIn: () => asked++,
        ),
      ),
      surfaceSize: const Size(360, 760),
    );
    await tester.pumpAndSettle();
    expect(find.text('Identifiez-vous pour voir vos contacts'), findsOneWidget);
    await tester.tap(find.text('Entrer mon numéro'));
    await tester.pumpAndSettle();
    expect(asked, 1);
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
