import 'package:woutalma_keur/app/data/local/cache_meta_store.dart';
import 'package:woutalma_keur/app/domain/repositories.dart';

/// Même forme que la version native, sans Isar.
class PersistentRepositories {
  const PersistentRepositories({
    required this.brokers,
    required this.properties,
    required this.reviews,
    required this.contacts,
    required this.seed,
    required this.meta,
  });

  final BrokerRepository brokers;
  final PropertyRepository properties;
  final ReviewRepository reviews;
  final ContactRepository contacts;
  final SeedRepository seed;
  final CacheMetaStore meta;
}

/// Faux sur le web : aucune base native n'y est disponible.
///
/// L'application y démarre sur le magasin mémoire. Le web sert à regarder les
/// écrans, pas à livrer : la cible reste Android d'entrée de gamme.
const bool supportsPersistence = false;

Future<PersistentRepositories> openPersistentRepositories() {
  throw UnsupportedError(
    'Aucune persistance sur le web. Utiliser AppDependencies.inMemory().',
  );
}
