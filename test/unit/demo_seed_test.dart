import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_keur/app/data/seed/demo_seed.dart';
import 'package:woutalma_keur/app/domain/entities.dart';

void main() {
  test('chaque bien seedé a une galerie démo locale', () {
    final List<Property> properties = const DemoSeed().properties();

    expect(properties, isNotEmpty);
    for (final Property property in properties) {
      expect(
        property.photoAssets,
        hasLength(greaterThanOrEqualTo(2)),
        reason: property.id,
      );
      expect(
        property.photoAssets.every((String path) => path.startsWith('demo:')),
        isTrue,
        reason: property.id,
      );
    }
  });
}
