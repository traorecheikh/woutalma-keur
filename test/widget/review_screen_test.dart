import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/data/repositories/in_memory_repositories.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/modules/client/review/review_screen.dart';

import '../support/pump.dart';

void main() {
  testWidgets('le formulaire avis reste utilisable à 320 dp', (
    WidgetTester tester,
  ) async {
    final InMemoryStore store = InMemoryStore();
    final InMemoryContactRepository contacts = InMemoryContactRepository(
      store,
      now: () => DateTime.utc(2026, 8, 1),
    );
    final InMemoryReviewRepository reviews = InMemoryReviewRepository(store);
    final ContactLog contact = await contacts.log(
      brokerId: 'brk-moussa',
      channel: ContactChannel.call,
    );
    await contacts.update(contact.copyWith(outcome: ContactOutcome.reached));

    final ReviewViewModel model = ReviewViewModel(
      contact: contact.copyWith(outcome: ContactOutcome.reached),
      reviews: reviews,
      contacts: contacts,
      now: () => DateTime.utc(2026, 8, 1),
    );
    addTearDown(model.dispose);

    bool done = false;
    await pumpWk(
      tester,
      ChangeNotifierProvider<ReviewViewModel>.value(
        value: model,
        child: ReviewScreen(
          brokerName: 'Moussa Ndiaye',
          onDone: () => done = true,
          onBack: () {},
        ),
      ),
      surfaceSize: const Size(320, 720),
      textScale: 1.3,
    );

    expectNoClippedText(tester);
    expectTouchTargets(tester);
    expect(tester.takeException(), isNull);
    expect(find.text('Réactivité'), findsOneWidget);
    expect(find.text('Informations exactes'), findsOneWidget);
    expect(find.text('Courtoisie'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.star_border).at(3));
    await tester.pumpAndSettle();
    model.setResponsiveness(5);
    model.setAccuracy(4);
    model.setCourtesy(5);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Envoyer l\'avis'));
    await tester.pumpAndSettle();

    expect(done, isTrue);
    final List<Review> saved = await reviews.all();
    expect(saved.single.responsiveness, 5);
    expect(saved.single.accuracy, 4);
    expect(saved.single.courtesy, 5);
  });
}
