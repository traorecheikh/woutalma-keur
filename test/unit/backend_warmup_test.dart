import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_keur/app/data/services/backend_warmup.dart';

void main() {
  test('la série de tentatives couvre un démarrage à froid de Render', () {
    // L'instance gratuite met une cinquantaine de secondes à revenir : une
    // série plus courte déclarait « injoignable » un serveur en train de se
    // lever.
    expect(
      BackendWarmup.backoffTotal,
      greaterThanOrEqualTo(const Duration(seconds: 90)),
    );
    expect(
      BackendWarmup.attemptTimeout,
      lessThanOrEqualTo(const Duration(seconds: 10)),
    );
  });

  test('sans serveur à réveiller, le réveil reste inerte', () {
    final BackendWarmup warmup = BackendWarmup.disabled()..start();
    expect(warmup.state, WarmupState.idle);
  });
}
