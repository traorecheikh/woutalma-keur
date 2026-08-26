import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/data/repositories/in_memory_repositories.dart';
import 'package:woutalma_keur/app/domain/auth_service.dart';
import 'package:woutalma_keur/app/domain/discovery.dart';
import 'package:woutalma_keur/app/modules/client/explore/filters_sheet.dart';
import 'package:woutalma_keur/app/modules/settings/settings_screen.dart';
import 'package:woutalma_keur/app/modules/settings/settings_view_model.dart';
import 'package:woutalma_keur/app/ui/ui.dart';

import '../support/pump.dart';
import '../support/recording_feedback_service.dart';

/// Annonces parties vers le lecteur d'écran pendant le test.
List<String> _captureAnnouncements(WidgetTester tester) {
  final captured = <String>[];
  tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler<dynamic>(
    SystemChannels.accessibility,
    (dynamic message) async {
      final data = message! as Map<Object?, Object?>;
      if (data['type'] == 'announce') {
        final args = data['data']! as Map<Object?, Object?>;
        captured.add(args['message']! as String);
      }
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger
        .setMockDecodedMessageHandler<dynamic>(
          SystemChannels.accessibility,
          null,
        ),
  );
  return captured;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('un message court est aussi annoncé', (tester) async {
    final announcements = _captureAnnouncements(tester);
    await pumpWk(
      tester,
      Builder(
        builder: (context) => Center(
          child: AppButton(
            'montrer',
            onPressed: () => toast(context, 'Avis envoyé'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('montrer'));
    await tester.pump();

    expect(announcements, contains('Avis envoyé'));

    // Laisse expirer le toast et l'animation d'appui.
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('une icône seule garde son action et son nom', (tester) async {
    final handle = tester.ensureSemantics();
    var tapped = false;
    await pumpWk(
      tester,
      Center(
        child: AppIconButton(
          icon: FIcons.arrowLeft,
          label: 'Retour',
          onTap: () => tapped = true,
        ),
      ),
    );

    final node = tester.getSemantics(find.byType(AppIconButton));
    final data = node.getSemanticsData();
    expect(
      data.hasAction(SemanticsAction.tap),
      isTrue,
      reason:
          'sans action « appuyer », TalkBack ne peut pas déclencher le '
          'bouton',
    );
    expect(data.label, 'Retour');

    await tester.tap(find.byType(AppIconButton));
    await tester.pumpAndSettle();
    expect(tapped, isTrue);
    handle.dispose();
  });

  testWidgets('« Écouter » fait lire le texte de l\'écran', (tester) async {
    final service = RecordingFeedbackService();
    await pumpWk(
      tester,
      const Center(child: AppListenButton(text: _spoken)),
      feedback: service,
    );

    await tester.tap(find.text('Écouter'));
    await tester.pumpAndSettle();

    expect(service.spoken, contains('6 résultats'));
  });

  testWidgets('une rangée de pastilles tient à ×1.3', (tester) async {
    await pumpWk(
      tester,
      Center(
        child: AppPillRow(
          children: [
            for (final label in [
              'Filtres',
              'À louer',
              'À vendre',
              'Appartement',
              'Maison',
              'Terrain',
            ])
              AppPill(label, selected: false, onTap: () {}),
          ],
        ),
      ),
      textScale: 1.3,
      surfaceSize: const Size(320, 640),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('une tranche de prix met à jour le nombre de résultats', (
    tester,
  ) async {
    await pumpWk(
      tester,
      SingleChildScrollView(
        child: FiltersSheet(
          initial: const DiscoveryFilters(),
          countResults: (f) async => f.maxPrice == null ? 12 : 3,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Voir 12 résultats'), findsOneWidget);

    // L'espace des milliers vient d'ICU : on cherche la tranche, pas l'octet.
    final tranche = find.textContaining('50').first;
    await tester.ensureVisible(tranche);
    await tester.pumpAndSettle();
    await tester.tap(tranche);
    // Le recomptage attend 250 ms avant de partir.
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(find.byType(Slider), findsNothing);
    expect(find.text('Voir 3 résultats'), findsOneWidget);
  });

  testWidgets('les interrupteurs de S01 arrivent jusqu\'au service', (
    tester,
  ) async {
    final service = RecordingFeedbackService();
    final store = InMemoryStore();
    final settings = SettingsViewModel(seed: InMemorySeedRepository(store));
    addTearDown(settings.dispose);

    await pumpWk(
      tester,
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>.value(
            value: SimulatedAuthService(),
          ),
          ChangeNotifierProvider<SettingsViewModel>.value(value: settings),
        ],
        child: SettingsScreen(
          onRoleChanged: () {},
          onSignIn: () {},
          onSignedOut: () {},
        ),
      ),
      feedback: service,
      surfaceSize: const Size(360, 760),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Vibrations'));
    await tester.pumpAndSettle();
    expect(settings.preferences.haptics, isFalse);
    expect(service.preferences.haptics, isFalse);

    await tester.tap(find.text('Voix guidée'));
    await tester.pumpAndSettle();
    expect(service.preferences.guidedVoice, isTrue);
    expect(service.spoken, isNotEmpty);
  });
}

String _spoken() => '6 résultats';
