import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:woutalma_keur/app/core/app_dependencies.dart';
import 'package:woutalma_keur/app/routes/app_router.dart';
import 'package:woutalma_keur/app/routes/app_routes.dart';

/// Les chemins courtier, tels que `go_router` les résout.
///
/// L'aperçu et l'éditeur partageaient `/broker/properties/edit` et ne
/// portaient l'identifiant que dans `extra` : un lien profond, ou une reprise
/// d'état, ouvrait « Modifier le bien » sans bien à modifier.
void main() {
  late GoRouter router;

  setUp(() async {
    final TestWidgetsFlutterBinding binding =
        TestWidgetsFlutterBinding.ensureInitialized();
    // L'assemblage des dépendances construit l'enregistreur réel, qui parle
    // tout de suite à sa plateforme.
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('com.llfbandit.record/messages'),
      (MethodCall call) async => null,
    );
    router = buildRouter(await AppDependencies.inMemory());
  });

  test('chaque écran courtier a son chemin, sans collision', () {
    expect(AppRoutes.propertyEditorNew, '/broker/properties/new');
    expect(AppRoutes.propertyPreviewPath('prp-1'), '/broker/properties/prp-1');
    expect(
      AppRoutes.propertyEditPath('prp-1'),
      '/broker/properties/prp-1/edit',
    );
  });

  test('une adresse d\'aperçu porte l\'identifiant du bien', () {
    router.go(AppRoutes.propertyPreviewPath('prp-001'));

    final RouteMatchList matches = router.configuration.findMatch(
      Uri.parse(AppRoutes.propertyPreviewPath('prp-001')),
    );
    expect(matches.isError, isFalse);
    expect(matches.pathParameters['id'], 'prp-001');
  });

  test('« nouveau bien » ne se fait pas prendre pour un identifiant', () {
    final RouteMatchList matches = router.configuration.findMatch(
      Uri.parse(AppRoutes.propertyEditorNew),
    );

    expect(matches.isError, isFalse);
    expect(matches.pathParameters, isEmpty);
  });

  test('l\'éditeur d\'un bien existant résout son identifiant', () {
    final RouteMatchList matches = router.configuration.findMatch(
      Uri.parse(AppRoutes.propertyEditPath('prp-001')),
    );

    expect(matches.isError, isFalse);
    expect(matches.pathParameters['id'], 'prp-001');
  });
}
