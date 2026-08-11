import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/data/repositories/in_memory_repositories.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/review_eligibility.dart';
import 'package:woutalma_keur/app/modules/client/history/history_screen.dart';
import 'package:woutalma_keur/app/modules/client/history/history_view_model.dart';

import '../support/pump.dart';

void main() {
  late InMemoryStore store;
  late ContactRepositoryHandle handle;

  setUp(() async {
    store = InMemoryStore();
    await InMemorySeedRepository(store).loadDemoSeed();
    handle = ContactRepositoryHandle(
      InMemoryContactRepository(store, now: () => DateTime.utc(2026, 8, 1)),
    );
  });

  Future<HistoryViewModel> pumpHistory(
    WidgetTester tester, {
    double textScale = 1,
  }) async {
    final HistoryViewModel model = HistoryViewModel(
      contacts: handle.repository,
      brokers: InMemoryBrokerRepository(store),
      eligibility: ReviewEligibilityService(handle.repository),
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
      textScale: textScale,
    );
    await tester.pumpAndSettle();
    return model;
  }

  testWidgets('un contact sans issue connue demande ce qui s\'est passé', (
    WidgetTester tester,
  ) async {
    // Le droit de noter exige un échange confirmé, et rien à l'écran ne
    // permettait de le confirmer : hors données de démonstration, personne
    // n'aurait jamais pu laisser d'avis.
    // `log()` est le seul chemin d'entrée : il crée le contact avec l'issue
    // « tentée », exactement comme un vrai appel depuis une fiche.
    await handle.repository.log(
      brokerId: 'brk-moussa',
      channel: ContactChannel.call,
    );

    await pumpHistory(tester);

    // Le seed contient déjà un contact resté « tenté » : la question
    // apparaît donc plus d'une fois, ce qui est exactement le problème.
    expect(find.text('Avez-vous eu cette personne ?'), findsWidgets);

    final int before = await handle.attemptedCount();
    expect(before, greaterThan(0));

    await tester.tap(find.text('Oui, on a échangé').first);
    await tester.pumpAndSettle();

    // Un contact de moins en attente, et le bouton d'avis qui apparaît :
    // répondre à la question est bien ce qui ouvre la notation.
    expect(await handle.attemptedCount(), before - 1);
    expect(find.text('Donner un avis'), findsWidgets);
  });

  testWidgets('un contact sans réponse dit pourquoi il n\'est pas notable', (
    WidgetTester tester,
  ) async {
    // Une ligne sans bouton et sans un mot se lit comme une action disparue.
    await pumpHistory(tester);

    expect(
      find.text('Pas de réponse : on ne note que quelqu\'un à qui on a parlé.'),
      findsWidgets,
    );
  });

  testWidgets('les contacts récents portent leur date en premier', (
    WidgetTester tester,
  ) async {
    await pumpHistory(tester);

    expect(find.text('SMS · 30 juin 2026'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Fatou Sarr')).dy,
      lessThan(tester.getTopLeft(find.text('Ibrahima Diop')).dy),
    );
  });

  testWidgets('les cartes de contact restent lisibles à ×1.3', (
    WidgetTester tester,
  ) async {
    await pumpHistory(tester, textScale: 1.3);

    expectNoClippedText(tester);
    expectTouchTargets(tester);
  });
}

/// Garde une seule instance du dépôt : le view model et le test doivent lire
/// le même magasin.
class ContactRepositoryHandle {
  ContactRepositoryHandle(this.repository);

  final InMemoryContactRepository repository;

  Future<int> attemptedCount() async {
    final List<ContactLog> all = await repository.all();
    return all
        .where((ContactLog c) => c.outcome == ContactOutcome.attempted)
        .length;
  }
}
