import 'package:isar_community/isar.dart';
import 'package:woutalma_keur/app/data/local/isar_rows.dart';

/// Clés/valeurs de service adossées à Isar.
///
/// Une interface plutôt qu'un accès direct : les tests et le web n'ont pas de
/// base, et rien ici ne mérite qu'un écran devienne asynchrone pour l'obtenir.
abstract class CacheMetaStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);

  /// Marque le type de données présentes dans la base locale.
  ///
  /// Une installation existante contient les 28 lignes du jeu de
  /// démonstration. Les servir comme s'il s'agissait d'une copie hors ligne de
  /// l'API serait exactement la fabrication de données que le mode distant
  /// interdit — d'où ce marqueur, vérifié au premier démarrage distant.
  ///
  /// La version suit le format des lignes : `remote-v2` stocke les énumérations
  /// par nom et non plus par rang, si bien qu'une base plus ancienne est vidée
  /// plutôt que relue de travers.
  static const String storeKindKey = 'store';
  static const String remoteStoreKind = 'remote-v2';

  /// L'explication de la permission de position a déjà été présentée.
  static const String locationPrimedKey = 'location-primed';

  /// Date du dernier succès réseau, pour que le bandeau hors ligne survive au
  /// redémarrage du processus.
  static const String fetchedAtKey = 'cache-fetched-at';
}

class IsarCacheMetaStore implements CacheMetaStore {
  IsarCacheMetaStore(this._isar);

  final Isar _isar;

  @override
  Future<String?> read(String key) async {
    final CacheMetaRow? row = await _isar.cacheMetaRows
        .filter()
        .keyEqualTo(key)
        .findFirst();
    return row?.value;
  }

  @override
  Future<void> write(String key, String value) async {
    await _isar.writeTxn(
      () => _isar.cacheMetaRows.put(
        CacheMetaRow()
          ..key = key
          ..value = value
          ..updatedAt = DateTime.now(),
      ),
    );
  }
}

/// Pour les tests et le web.
class InMemoryCacheMetaStore implements CacheMetaStore {
  InMemoryCacheMetaStore([Map<String, String>? initial])
    : _values = <String, String>{...?initial};

  final Map<String, String> _values;

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async => _values[key] = value;
}
