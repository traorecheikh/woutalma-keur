import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_keur/app/data/repositories/in_memory_repositories.dart';
import 'package:woutalma_keur/app/domain/repositories.dart';
import 'package:woutalma_keur/app/modules/settings/settings_view_model.dart';

void main() {
  late InMemoryStore store;
  late SeedRepository seed;
  late SettingsViewModel model;

  setUp(() async {
    store = InMemoryStore();
    seed = InMemorySeedRepository(store);
    await seed.loadDemoSeed();
    model = SettingsViewModel(seed: seed);
  });

  test('l\'impact annoncé correspond à ce qui sera supprimé', () async {
    final int announced = await model.impactCount();

    expect(announced, greaterThan(0));
    expect(announced, store.itemCount);
  });

  test('quitter le mode démo vide réellement la base', () async {
    expect(model.mode, AppMode.demo);

    final bool ok = await model.toggleMode();

    expect(ok, isTrue);
    expect(model.mode, AppMode.real);
    expect(store.itemCount, 0);
  });

  test('revenir en démo recharge le même jeu, sans doublon', () async {
    final int before = store.itemCount;

    await model.toggleMode();
    await model.toggleMode();

    expect(model.mode, AppMode.demo);
    expect(store.itemCount, before);
  });

  test('un aller-retour ne laisse jamais un mélange', () async {
    // La purge et le chargement sont enchaînés dans la même bascule : à aucun
    // moment la base ne contient un demi-jeu.
    await model.toggleMode();
    expect(store.itemCount, 0);

    await model.toggleMode();
    expect(store.brokers.length, greaterThan(0));
    expect(store.properties.length, greaterThan(0));
  });

  test('une bascule en cours refuse la suivante', () async {
    final Future<bool> first = model.toggleMode();
    final bool second = await model.toggleMode();

    expect(second, isFalse, reason: 'double bascule concurrente acceptée');
    await first;
  });

  test('les préférences de retour se règlent séparément', () async {
    model.setPreferences(model.preferences.copyWith(haptics: false));

    expect(model.preferences.haptics, isFalse);
    // Couper les vibrations ne coupe pas les sons.
    expect(model.preferences.sounds, isTrue);
  });
}
