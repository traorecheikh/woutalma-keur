import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:woutalma_keur/app/data/local/isar_rows.dart';
import 'package:woutalma_keur/app/data/repositories/isar_repositories.dart';
import 'package:woutalma_keur/app/domain/repositories.dart';

/// Dépôts persistants d'une plateforme native.
class PersistentRepositories {
  const PersistentRepositories({
    required this.brokers,
    required this.properties,
    required this.reviews,
    required this.contacts,
    required this.seed,
  });

  final BrokerRepository brokers;
  final PropertyRepository properties;
  final ReviewRepository reviews;
  final ContactRepository contacts;
  final SeedRepository seed;
}

/// Vrai quand la plateforme sait stocker durablement.
const bool supportsPersistence = true;

/// Ouvre la base locale et rend les dépôts persistants.
///
/// Isolé derrière un import conditionnel : le code généré d'Isar contient des
/// entiers 64 bits que JavaScript ne peut pas représenter, donc il ne doit
/// jamais entrer dans une compilation web, même inutilisé.
Future<PersistentRepositories> openPersistentRepositories() async {
  final Isar isar = await Isar.open(<CollectionSchema<dynamic>>[
    BrokerRowSchema,
    PropertyRowSchema,
    ReviewRowSchema,
    ContactRowSchema,
  ], directory: (await getApplicationDocumentsDirectory()).path);

  return PersistentRepositories(
    brokers: IsarBrokerRepository(isar),
    properties: IsarPropertyRepository(isar),
    reviews: IsarReviewRepository(isar),
    contacts: IsarContactRepository(isar, now: DateTime.now),
    seed: IsarSeedRepository(isar),
  );
}
