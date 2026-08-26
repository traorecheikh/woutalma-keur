import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/data/repositories/in_memory_repositories.dart';
import 'package:woutalma_keur/app/data/seed/demo_seed.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/photo_service.dart';
import 'package:woutalma_keur/app/domain/voice_note_service.dart';
import 'package:woutalma_keur/app/modules/broker/property_editor_draft.dart';
import 'package:woutalma_keur/app/modules/broker/property_editor_screen.dart';
import 'package:woutalma_keur/app/modules/broker/property_editor_view_model.dart';

import '../support/pump.dart';

class _NoPhotos implements PhotoService {
  @override
  int get maxPerProperty => 3;

  @override
  Future<String?> pick(PhotoSource source) async => null;
}

class _NoMic implements VoiceNoteRecorder {
  @override
  Future<void> cancel() async {}

  @override
  Future<void> dispose() async {}

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<void> start() async {}

  @override
  Future<String?> stop() async => null;
}

class _NoDrafts implements PropertyDraftStore {
  @override
  Future<void> clear() async {}

  @override
  Future<PropertyDraft?> read() async => null;

  @override
  Future<void> write(PropertyDraft draft) async {}
}

void main() {
  testWidgets('le retour système recule d\'une étape, il ne quitte pas', (
    WidgetTester tester,
  ) async {
    final InMemoryStore store = InMemoryStore();
    await InMemorySeedRepository(store).loadDemoSeed();
    final PropertyEditorViewModel model = PropertyEditorViewModel(
      properties: InMemoryPropertyRepository(store),
      brokerId: 'brk-moussa',
      fallbackPosition: DemoSeed.clientPosition,
      now: () => DateTime.utc(2026, 8, 1),
      drafts: _NoDrafts(),
    );
    addTearDown(model.dispose);

    bool left = false;
    await pumpWk(
      tester,
      ChangeNotifierProvider<PropertyEditorViewModel>.value(
        value: model,
        child: PropertyEditorScreen(
          photos: _NoPhotos(),
          voiceNotes: _NoMic(),
          onBack: () => left = true,
          onSaved: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();
    expect(find.text('Infos essentielles'), findsOneWidget);

    // Trois écrans remplis disparaissaient d'un geste qui ne voulait dire que
    // « revenir en arrière ».
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Le bien et son quartier'), findsOneWidget);
    expect(left, isFalse);
  });

  testWidgets('le libellé du prix porte l\'unité et la périodicité', (
    WidgetTester tester,
  ) async {
    final InMemoryStore store = InMemoryStore();
    final PropertyEditorViewModel model = PropertyEditorViewModel(
      properties: InMemoryPropertyRepository(store),
      brokerId: 'brk-moussa',
      fallbackPosition: DemoSeed.clientPosition,
      now: () => DateTime.utc(2026, 8, 1),
      drafts: _NoDrafts(),
    );
    addTearDown(model.dispose);

    await pumpWk(
      tester,
      ChangeNotifierProvider<PropertyEditorViewModel>.value(
        value: model,
        child: PropertyEditorScreen(
          photos: _NoPhotos(),
          voiceNotes: _NoMic(),
          onBack: () {},
          onSaved: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();

    expect(find.text('Prix par mois (F)'), findsOneWidget);

    model.setTransaction(TransactionKind.sale);
    await tester.pumpAndSettle();

    expect(find.text('Prix de vente (F)'), findsOneWidget);
  });
}
