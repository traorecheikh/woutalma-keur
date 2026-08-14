import 'package:dio/dio.dart';
import 'package:woutalma_api_client/woutalma_api_client.dart' as api;
import 'package:woutalma_keur/app/data/repositories/remote_mappers.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/repositories.dart';

/// Network-backed repository set for `real` mode. Same contracts as
/// InMemory*/Isar*Repository (lib/app/domain/repositories.dart docstring:
/// "Une implémentation Isar ou distante se substitue sans qu'un widget
/// bouge.") — screens and domain services stay unaware which one is wired.
///
/// Broker/Property *writes*, and review/contact *listing*, are not in the
/// Phase 1 API surface (see docs/PRODUCT.md §8bis — broker-side management
/// stays on Isar for now); those methods throw a clear UnimplementedError
/// rather than silently no-op-ing.

class RemoteBrokerRepository implements BrokerRepository {
  RemoteBrokerRepository(this._api);

  final api.BrokersApi _api;

  @override
  Future<List<Broker>> all() async {
    final response = await _api.brokersControllerFindAll();
    return (response.data ?? const <api.BrokerDto>[]).map(mapBroker).toList();
  }

  @override
  Future<Broker?> byId(String id) async {
    try {
      final response = await _api.brokersControllerFindById(id: id);
      final dto = response.data;
      return dto == null ? null : mapBroker(dto);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<void> save(Broker broker) {
    throw UnimplementedError(
      'RemoteBrokerRepository.save: broker profile writes are not in the Phase 1 API — see docs/PRODUCT.md §8bis.',
    );
  }
}

class RemotePropertyRepository implements PropertyRepository {
  RemotePropertyRepository(this._propertiesApi, this._brokersApi);

  final api.PropertiesApi _propertiesApi;

  // brokers/:id/properties lives on BrokersApi, not PropertiesApi — kept
  // private so callers of this repository never need to know that.
  final api.BrokersApi _brokersApi;

  @override
  Future<List<Property>> all() async {
    final response = await _propertiesApi.propertiesControllerFindAll(
      discoverableOnly: 'false',
    );
    return (response.data ?? const <api.PropertyDto>[])
        .map(mapProperty)
        .toList();
  }

  @override
  Future<List<Property>> discoverable() async {
    final response = await _propertiesApi.propertiesControllerFindAll(
      discoverableOnly: 'true',
    );
    return (response.data ?? const <api.PropertyDto>[])
        .map(mapProperty)
        .toList();
  }

  @override
  Future<List<Property>> byBroker(
    String brokerId, {
    bool onlyDiscoverable = false,
  }) async {
    final response = await _brokersApi.brokersControllerFindProperties(
      id: brokerId,
      onlyDiscoverable: onlyDiscoverable,
    );
    return (response.data ?? const <api.PropertyDto>[])
        .map(mapProperty)
        .toList();
  }

  @override
  Future<Property?> byId(String id) async {
    try {
      final response = await _propertiesApi.propertiesControllerFindById(
        id: id,
      );
      final dto = response.data;
      return dto == null ? null : mapProperty(dto);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<void> save(Property property) {
    throw UnimplementedError(
      'RemotePropertyRepository.save: property writes are not in the Phase 1 API — see docs/PRODUCT.md §8bis.',
    );
  }

  @override
  Future<void> delete(String id) {
    throw UnimplementedError(
      'RemotePropertyRepository.delete: property writes are not in the Phase 1 API — see docs/PRODUCT.md §8bis.',
    );
  }
}

class RemoteReviewRepository implements ReviewRepository {
  const RemoteReviewRepository();

  @override
  Future<List<Review>> byBroker(String brokerId, {bool onlyPublic = false}) {
    // No GET /reviews endpoint in Phase 1 (broker-detail's review list is
    // still served from Isar/InMemory in real mode this phase) — only the
    // write path (submitting a review) is remote. See docs/PRODUCT.md §8bis.
    throw UnimplementedError(
      'RemoteReviewRepository.byBroker: review listing is not in the Phase 1 API yet — see docs/PRODUCT.md §8bis.',
    );
  }

  @override
  Future<List<Review>> all() {
    throw UnimplementedError(
      'RemoteReviewRepository.all: review listing is not in the Phase 1 API yet — see docs/PRODUCT.md §8bis.',
    );
  }

  @override
  Future<void> save(Review review) {
    throw UnimplementedError(
      'RemoteReviewRepository.save: use the review submission flow (POST /reviews) instead — server-side '
      'eligibility (review_eligibility.dart parity) only runs on that path.',
    );
  }
}

class RemoteContactRepository implements ContactRepository {
  RemoteContactRepository(this._api);

  final api.ContactsApi _api;

  @override
  Future<List<ContactLog>> all() {
    throw UnimplementedError(
      'RemoteContactRepository.all: contact history listing is not in the Phase 1 API yet.',
    );
  }

  @override
  Future<ContactLog?> byId(String id) {
    throw UnimplementedError(
      'RemoteContactRepository.byId: not in the Phase 1 API yet.',
    );
  }

  /// Mirrors ContactRepository.log — logs BEFORE the caller opens the
  /// external channel (see ContactService.contact in contact_launcher.dart),
  /// and the row is durably committed server-side by the time this returns.
  @override
  Future<ContactLog> log({
    required String brokerId,
    String? propertyId,
    required ContactChannel channel,
  }) async {
    final response = await _api.contactsControllerLog(
      createContactDto: api.CreateContactDto((b) {
        b.brokerId = brokerId;
        b.propertyId = propertyId;
        b.channel = mapContactChannelToApi(channel);
      }),
    );
    return mapContactLog(response.data!);
  }

  @override
  Future<void> update(ContactLog contact) async {
    await _api.contactsControllerUpdateOutcome(
      id: contact.id,
      updateContactOutcomeDto: api.UpdateContactOutcomeDto((b) {
        b.outcome = mapContactOutcomeToApi(contact.outcome);
      }),
    );
  }
}

/// Phase 1 has no server-side seed/demo concept for `real` mode — `demo`
/// stays 100% local (docs/PRODUCT.md §5). Present only so AppDependencies.
/// remote() can satisfy AppDependencies._assemble's shared signature.
class RemoteSeedRepository implements SeedRepository {
  const RemoteSeedRepository();

  @override
  Future<void> clearAll() async {}

  @override
  Future<void> loadDemoSeed() async {}

  @override
  Future<int> itemCount() async => 0;
}
