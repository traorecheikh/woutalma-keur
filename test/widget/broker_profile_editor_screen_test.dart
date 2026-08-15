import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/data/repositories/in_memory_repositories.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/repositories.dart';
import 'package:woutalma_keur/app/modules/broker/broker_profile_editor_screen.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_states.dart';

import '../support/pump.dart';

/// Un dépôt qui lit bien mais n'écrit jamais : le réseau du courtier tombe
/// pile au moment d'enregistrer.
class _WriteFailsBrokers implements BrokerRepository {
  _WriteFailsBrokers(this._inner);

  final BrokerRepository _inner;

  @override
  Future<List<Broker>> all() => _inner.all();
  @override
  Future<Broker?> byId(String id) => _inner.byId(id);
  @override
  Future<void> save(Broker broker) async =>
      throw DioException(requestOptions: RequestOptions(path: '/brokers'));
  @override
  Future<void> saveAll(List<Broker> brokers) async => save(brokers.first);

  @override
  Future<Broker> requestVerification(String brokerId) async {
    throw UnimplementedError('non utilisé par ce test');
  }
}

void main() {
  late InMemoryStore store;

  setUp(() async {
    store = InMemoryStore();
    await InMemorySeedRepository(store).loadDemoSeed();
  });

  Future<BrokerProfileEditorViewModel> pumpEditor(
    WidgetTester tester, {
    BrokerRepository? brokers,
    double textScale = 1,
  }) async {
    final BrokerProfileEditorViewModel model = BrokerProfileEditorViewModel(
      brokers: brokers ?? InMemoryBrokerRepository(store),
      brokerId: 'brk-moussa',
    );
    addTearDown(model.dispose);
    await model.load();

    await pumpWk(
      tester,
      ChangeNotifierProvider<BrokerProfileEditorViewModel>.value(
        value: model,
        child: BrokerProfileEditorScreen(onBack: () {}, onSaved: () {}),
      ),
      textScale: textScale,
    );
    await tester.pumpAndSettle();
    return model;
  }

  testWidgets('le profil chargé remplit les champs, en saisie locale', (
    WidgetTester tester,
  ) async {
    await pumpEditor(tester);

    expect(find.text('Moussa Ndiaye'), findsOneWidget);
    // Stocké « +221771234567 », saisi « 771234567 » : personne ne retape
    // l'indicatif de son propre pays.
    expect(find.text('771234567'), findsWidgets);
    expect(find.text('Modifier mon profil'), findsWidgets);
  });

  testWidgets('enregistrer écrit le nouveau nom', (WidgetTester tester) async {
    final BrokerProfileEditorViewModel model = await pumpEditor(tester);

    await tester.enterText(
      find.widgetWithText(TextField, 'Moussa Ndiaye'),
      'Moussa Ndiaye Immobilier',
    );
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();

    expect(model.broker!.name, 'Moussa Ndiaye Immobilier');
  });

  testWidgets('un enregistrement refusé dit la vraie cause', (
    WidgetTester tester,
  ) async {
    await pumpEditor(
      tester,
      brokers: _WriteFailsBrokers(InMemoryBrokerRepository(store)),
    );

    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();

    // Ni « Profil enregistré », ni un écran figé : la coupure est nommée.
    expect(find.text('Profil enregistré'), findsNothing);
    expect(
      find.text('Pas de connexion. Réessayez quand le réseau revient.'),
      findsOneWidget,
    );
  });

  testWidgets('un profil illisible rend une erreur réutilisable', (
    WidgetTester tester,
  ) async {
    final BrokerProfileEditorViewModel model = BrokerProfileEditorViewModel(
      brokers: InMemoryBrokerRepository(InMemoryStore()),
      brokerId: 'brk-inconnu',
    );
    addTearDown(model.dispose);
    await model.load();

    await pumpWk(
      tester,
      ChangeNotifierProvider<BrokerProfileEditorViewModel>.value(
        value: model,
        child: BrokerProfileEditorScreen(onBack: () {}, onSaved: () {}),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(WkErrorState), findsOneWidget);
  });

  testWidgets('le formulaire reste lisible à ×1.3', (
    WidgetTester tester,
  ) async {
    await pumpEditor(tester, textScale: 1.3);

    expectNoClippedText(tester);
    expectTouchTargets(tester);
  });
}
