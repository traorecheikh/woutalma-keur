import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_keur/app/core/location/client_position_controller.dart';
import 'package:woutalma_keur/app/data/local/cache_meta_store.dart';
import 'package:woutalma_keur/app/data/seed/demo_seed.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/location_service.dart';

import '../support/fake_location.dart';

void main() {
  const GeoPoint ngor = GeoPoint(14.7500, -17.5140);

  test('une position trouvée remplace le repli et prévient', () async {
    final FakeLocationService location = FakeLocationService(
      result: const LocationFound(ngor),
    );
    final ClientPositionController positions = fakePositions(
      location: location,
    );
    var notified = 0;
    positions.addListener(() => notified++);

    await positions.locate();

    expect(positions.position, ngor);
    expect(positions.isFromGps, isTrue);
    expect(notified, 1);
  });

  test('un refus garde le repli et n\'invente aucune position', () async {
    final FakeLocationService location = FakeLocationService(
      result: const LocationRefused(LocationRefusal.denied),
    );
    final ClientPositionController positions = fakePositions(
      location: location,
    );

    await positions.locate();

    expect(positions.position, DemoSeed.clientPosition);
    expect(positions.isFromGps, isFalse);
    // La barre doit dire « Dakar · position inconnue » : « Près de vous »
    // au-dessus de résultats classés depuis le Plateau est faux.
    expect(positions.gpsFailed, isTrue);
  });

  test('un choix manuel efface l\'échec du GPS', () async {
    final ClientPositionController positions = fakePositions(
      location: FakeLocationService(
        result: const LocationRefused(LocationRefusal.unavailable),
      ),
    );
    await positions.locate();

    positions.moveTo(
      const Neighbourhood(name: 'Plateau', position: DemoSeed.clientPosition),
    );

    expect(positions.gpsFailed, isFalse);
  });

  test('relire la même position ne prévient personne', () async {
    final ClientPositionController positions = fakePositions(
      location: FakeLocationService(result: const LocationFound(ngor)),
    );
    await positions.locate();
    var notified = 0;
    positions.addListener(() => notified++);

    // Chaque notification relance deux recherches sur l'accueil : relire une
    // position inchangée les payait pour rien.
    await positions.locate();

    expect(notified, 0);
  });

  test(
    'un choix manuel l\'emporte sur une position GPS déjà obtenue',
    () async {
      final ClientPositionController positions = fakePositions(
        location: FakeLocationService(result: const LocationFound(ngor)),
      );
      await positions.locate();

      positions.moveTo(
        const Neighbourhood(
          name: 'Keur Massar',
          position: GeoPoint(14.7822, -17.3188),
        ),
      );

      expect(positions.placeName, 'Keur Massar');
      expect(positions.isFromGps, isFalse);
    },
  );

  test('le GPS efface le nom de quartier : on est « près de vous »', () async {
    final ClientPositionController positions = fakePositions(
      location: FakeLocationService(result: const LocationFound(ngor)),
    );
    positions.moveTo(
      const Neighbourhood(name: 'Plateau', position: DemoSeed.clientPosition),
    );

    await positions.locate();

    expect(positions.placeName, isNull);
  });

  test(
    'l\'amorçage ne se marque qu\'une fois et survit à un redémarrage',
    () async {
      final CacheMetaStore meta = InMemoryCacheMetaStore();
      final ClientPositionController first = fakePositions(
        meta: meta,
        primed: false,
      );

      expect(first.hasBeenPrimed, isFalse);
      await first.markPrimed();
      expect(first.hasBeenPrimed, isTrue);

      // Nouveau lancement, même stockage : l'explication ne se rejoue pas.
      final ClientPositionController second = fakePositions(
        meta: meta,
        primed: false,
      );
      await second.restore();
      expect(second.hasBeenPrimed, isTrue);
    },
  );
}
