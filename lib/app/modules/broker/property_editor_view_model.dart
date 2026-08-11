import 'package:flutter/foundation.dart';
import 'package:woutalma_keur/app/core/state/mutation_state.dart';
import 'package:woutalma_keur/app/core/state/screen_state.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/repositories.dart';

/// Coordonne B03, l'éditeur de bien.
///
/// Sert la création comme la modification : ce sont les mêmes champs et les
/// mêmes règles, seuls le titre de l'écran et l'identifiant changent.
class PropertyEditorViewModel extends ChangeNotifier {
  PropertyEditorViewModel({
    required PropertyRepository properties,
    required String brokerId,
    required GeoPoint fallbackPosition,
    required DateTime Function() now,
    Property? existing,
    Property? previous,
  }) : _properties = properties,
       _brokerId = brokerId,
       _fallbackPosition = fallbackPosition,
       _now = now,
       _existing = existing {
    if (existing != null) {
      kind = existing.kind;
      transaction = existing.transaction;
      status = existing.status;
    } else if (previous != null) {
      // Deuxième bien : on reprend ce qui se répète d'une annonce à l'autre.
      // Les valeurs reprises sont signalées à l'écran — une valeur devinée
      // qu'on ne remarque pas devient une annonce fausse publiée sous son nom.
      kind = previous.kind;
      transaction = previous.transaction;
      prefilledFromPrevious = true;
    }
  }

  final PropertyRepository _properties;
  final String _brokerId;
  final GeoPoint _fallbackPosition;
  final DateTime Function() _now;
  final Property? _existing;

  PropertyKind kind = PropertyKind.apartment;
  TransactionKind transaction = TransactionKind.rent;
  PropertyStatus status = PropertyStatus.available;

  /// Vrai quand des valeurs viennent du bien précédent.
  bool prefilledFromPrevious = false;

  /// Photos du bien, déjà allégées.
  late List<String> photos = List<String>.of(
    _existing?.photoAssets ?? const <String>[],
  );

  void setPhotos(List<String> value) {
    photos = value;
    notifyListeners();
  }

  MutationState _submission = const MutationState.idle();
  MutationState get submission => _submission;

  bool get isEditing => _existing != null;
  Property? get existing => _existing;

  void setKind(PropertyKind value) {
    kind = value;
    prefilledFromPrevious = false;
    notifyListeners();
  }

  void setTransaction(TransactionKind value) {
    transaction = value;
    prefilledFromPrevious = false;
    notifyListeners();
  }

  void setStatus(PropertyStatus value) {
    status = value;
    notifyListeners();
  }

  /// Enregistre. Renvoie l'identifiant du bien, ou `null` si la saisie n'est
  /// pas exploitable.
  Future<String?> save({
    required String title,
    required String priceText,
    required String neighbourhood,
    String description = '',
    String surfaceText = '',
    String roomsText = '',
  }) async {
    final int? price = int.tryParse(priceText.replaceAll(RegExp(r'\D'), ''));
    if (title.trim().isEmpty ||
        neighbourhood.trim().isEmpty ||
        price == null ||
        price <= 0) {
      return null;
    }

    _submission = const MutationState.submitting();
    notifyListeners();

    final String id = _existing?.id ?? 'prp-${_now().microsecondsSinceEpoch}';
    final Property property = Property(
      id: id,
      brokerId: _brokerId,
      kind: kind,
      transaction: transaction,
      title: title.trim(),
      description: description.trim(),
      price: price,
      surface: int.tryParse(surfaceText.replaceAll(RegExp(r'\D'), '')),
      rooms: int.tryParse(roomsText.replaceAll(RegExp(r'\D'), '')),
      // La position précise se choisira sur la carte ; en attendant, le bien
      // est rattaché à la position connue plutôt qu'à des coordonnées nulles
      // qui le placeraient au large du golfe de Guinée.
      position: _existing?.position ?? _fallbackPosition,
      neighbourhood: neighbourhood.trim(),
      photoAssets: photos,
      status: status,
      createdAt: _existing?.createdAt ?? _now(),
    );

    try {
      await _properties.save(property);
      _submission = const MutationState.success();
    } on Object {
      _submission = const MutationState.failure(WkFailure.localStorage);
      notifyListeners();
      return null;
    }
    notifyListeners();
    return id;
  }
}
