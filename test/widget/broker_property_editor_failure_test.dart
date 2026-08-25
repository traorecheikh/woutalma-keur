import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/data/repositories/in_memory_repositories.dart';
import 'package:woutalma_keur/app/data/seed/demo_seed.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/photo_service.dart';
import 'package:woutalma_keur/app/domain/repositories.dart';
import 'package:woutalma_keur/app/modules/broker/property_editor_screen.dart';
import 'package:woutalma_keur/app/modules/broker/property_editor_view_model.dart';

import '../support/fake_voice_note_recorder.dart';
import '../support/pump.dart';

/// Aucun accès à l'appareil photo dans un test, et une limite plus large que
/// celle du serveur : c'est justement ce que l'éditeur doit rattraper.
class _GenerousPhotoService implements PhotoService {
  @override
  int get maxPerProperty => 6;

  @override
  Future<String?> pick(PhotoSource source) async => null;
}

/// Un dépôt qui lit bien mais dont l'écriture n'arrive jamais au serveur.
class _WriteFailsProperties implements PropertyRepository {
  _WriteFailsProperties(this._inner);

  final PropertyRepository _inner;

  @override
  Future<List<Property>> all() => _inner.all();
  @override
  Future<List<Property>> discoverable() => _inner.discoverable();
  @override
  Future<List<Property>> byBroker(
    String brokerId, {
    bool onlyDiscoverable = false,
  }) => _inner.byBroker(brokerId, onlyDiscoverable: onlyDiscoverable);
  @override
  Future<Property?> byId(String id) => _inner.byId(id);
  @override
  Future<Property> save(Property property) async =>
      throw DioException(requestOptions: RequestOptions(path: '/properties'));
  @override
  Future<void> delete(String id) => _inner.delete(id);
  @override
  Future<void> saveAll(List<Property> properties) async =>
      _inner.saveAll(properties);
}

void main() {
  late InMemoryStore store;

  setUp(() async {
    store = InMemoryStore();
    await InMemorySeedRepository(store).loadDemoSeed();
  });

  Future<void> pumpEditor(
    WidgetTester tester, {
    required PropertyRepository properties,
  }) async {
    final PropertyEditorViewModel model = PropertyEditorViewModel(
      properties: properties,
      brokerId: 'brk-moussa',
      fallbackPosition: DemoSeed.clientPosition,
      now: () => DateTime.utc(2026, 8, 1),
    );
    addTearDown(model.dispose);

    await pumpWk(
      tester,
      ChangeNotifierProvider<PropertyEditorViewModel>.value(
        value: model,
        child: PropertyEditorScreen(
          photos: _GenerousPhotoService(),
          voiceNotes: FakeVoiceNoteRecorder(),
          onBack: () {},
          onSaved: (String _) {},
        ),
      ),
      surfaceSize: const Size(360, 1400),
    );
  }

  Future<void> fillAndPublish(WidgetTester tester) async {
    // Étape 1 : le quartier est un choix, et il porte la position du bien.
    await tester.tap(find.text('Quartier'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yoff').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'Studio à Yoff');
    await tester.enterText(find.byType(TextField).at(1), '120000');
    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Publier le bien'));
    await tester.pumpAndSettle();
  }

  testWidgets('la limite du serveur est dite avant de choisir une photo', (
    WidgetTester tester,
  ) async {
    await pumpEditor(tester, properties: InMemoryPropertyRepository(store));

    // Deux étapes plus loin, l'étape média.
    for (int i = 0; i < 2; i++) {
      await tester.tap(find.text('Suivant'));
      await tester.pumpAndSettle();
    }

    // Le service en propose six, le serveur en refuse une quatrième.
    expect(find.text('0 sur 3'), findsOneWidget);
    expect(
      find.text('3 photos maximum par bien pour l\'instant.'),
      findsOneWidget,
    );
  });

  testWidgets('un échec d\'enregistrement n\'est pas une faute de saisie', (
    WidgetTester tester,
  ) async {
    await pumpEditor(
      tester,
      properties: _WriteFailsProperties(InMemoryPropertyRepository(store)),
    );

    await fillAndPublish(tester);

    // L'écran restait sur l'étape 2 ou 3 en réclamant une correction : le
    // formulaire était pourtant complet.
    expect(find.text('Étape 3 sur 3'), findsOneWidget);
    expect(
      find.text('Pas de connexion. Réessayez quand le réseau revient.'),
      findsOneWidget,
    );
    expect(find.text('Bien publié'), findsNothing);
  });

  testWidgets('un formulaire incomplet renvoie bien au champ manquant', (
    WidgetTester tester,
  ) async {
    await pumpEditor(tester, properties: InMemoryPropertyRepository(store));

    for (int i = 0; i < 2; i++) {
      await tester.tap(find.text('Suivant'));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('Publier le bien'));
    await tester.pumpAndSettle();

    // Là, « corrigez d'abord » est la bonne réponse : rien n'a été saisi. La
    // première étape fautive est celle du quartier.
    expect(find.text('Étape 1 sur 3'), findsOneWidget);
  });
}
