import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:woutalma_keur/app/core/state/mutation_state.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/location_service.dart';
import 'package:woutalma_keur/app/domain/property_surface.dart';
import 'package:woutalma_keur/app/domain/repositories.dart';
import 'package:woutalma_keur/app/modules/broker/broker_failures.dart';
import 'package:woutalma_keur/app/modules/broker/property_editor_draft.dart';

/// Nombres de pièces proposés.
///
/// Au-delà de six, on ne compte plus les pièces d'une annonce : la valeur est
/// gardée telle quelle si elle existe déjà, mais rien ne la propose.
const List<int> kRoomSteps = <int>[1, 2, 3, 4, 5, 6];

/// Coordonne B03, l'éditeur de bien.
///
/// Sert la création comme la modification : ce sont les mêmes champs et les
/// mêmes règles, seuls le titre de l'écran et l'identifiant changent.
///
/// Le quartier, la surface et le nombre de pièces sont des **choix**, pas des
/// saisies : ils vivent donc ici, typés, plutôt que dans des contrôleurs de
/// texte que l'écran devrait reparser à chaque enregistrement.
class PropertyEditorViewModel extends ChangeNotifier with BrokerFailures {
  PropertyEditorViewModel({
    required PropertyRepository properties,
    required String brokerId,
    required GeoPoint fallbackPosition,
    required DateTime Function() now,
    Property? existing,
    Property? previous,
    PropertyDraftStore drafts = const PropertyDraftStore(),
  }) : _properties = properties,
       _brokerId = brokerId,
       _fallbackPosition = fallbackPosition,
       _now = now,
       _drafts = drafts,
       _existing = existing {
    if (existing != null) {
      kind = existing.kind;
      transaction = existing.transaction;
      status = existing.status;
      surface = existing.surface;
      rooms = existing.rooms;
      // La position **déjà enregistrée** voyage avec le nom : rouvrir une
      // annonce pour corriger son prix ne doit pas la déplacer au centre
      // approximatif de son quartier.
      neighbourhood = Neighbourhood(
        name: existing.neighbourhood,
        position: existing.position,
      );
    } else if (previous != null) {
      // Deuxième bien : on reprend ce qui se répète d'une annonce à l'autre.
      // Les valeurs reprises sont signalées à l'écran — une valeur devinée
      // qu'on ne remarque pas devient une annonce fausse publiée sous son nom.
      kind = previous.kind;
      transaction = previous.transaction;
      neighbourhood = Neighbourhood(
        name: previous.neighbourhood,
        position: previous.position,
      );
      prefilledFromPrevious = true;
    }
  }

  final PropertyRepository _properties;
  final String _brokerId;
  final GeoPoint _fallbackPosition;
  final DateTime Function() _now;
  final PropertyDraftStore _drafts;
  final Property? _existing;

  /// Frappé une fois, gardé d'un essai à l'autre : c'est la clé d'idempotence
  /// que le serveur reconnaît. Le regénérer à chaque appui publiait deux fois
  /// la même annonce quand le premier envoi avait dépassé le délai.
  late final String _draftId = 'prp-${_now().microsecondsSinceEpoch}';

  Timer? _persist;

  PropertyKind kind = PropertyKind.apartment;
  TransactionKind transaction = TransactionKind.rent;
  PropertyStatus status = PropertyStatus.available;

  /// Quartier choisi. Porte son propre point : c'est ce qui remplace l'étape
  /// « position » du contrat, qui n'a jamais rien demandé d'autre.
  Neighbourhood? neighbourhood;

  /// Surface en m², facultative : un terrain et une chambre ne se décrivent
  /// pas avec la même exigence.
  int? surface;

  /// Nombre de pièces, facultatif et sans objet pour un terrain.
  int? rooms;

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

  late String? voiceNote = _existing?.voiceAsset;

  void setVoiceNote(String? value) {
    voiceNote = value;
    notifyListeners();
  }

  MutationState _submission = const MutationState.idle();
  MutationState get submission => _submission;

  bool get isEditing => _existing != null;
  Property? get existing => _existing;

  /// Un terrain n'a pas de pièces. Le demander quand même, c'est faire lire
  /// une question qui n'a pas de réponse.
  bool get asksRooms => propertyKindHasRooms(kind);

  /// Quartiers proposables.
  ///
  /// La liste canonique, plus le quartier déjà enregistré s'il n'en fait pas
  /// partie : une annonce ancienne ne perd pas son quartier parce que la
  /// liste a changé.
  List<Neighbourhood> get neighbourhoodOptions {
    final Neighbourhood? current = neighbourhood;
    if (current == null || dakarNeighbourhoods.contains(current)) {
      return dakarNeighbourhoods;
    }
    return <Neighbourhood>[current, ...dakarNeighbourhoods];
  }

  /// Paliers de surface pour le type de bien courant.
  ///
  /// Le barème appartient au domaine — une chambre, un appartement et un
  /// terrain ne se mesurent pas à la même échelle, et le composeur de
  /// description s'appuie sur le même fichier. L'éditeur ne redéfinit donc pas
  /// ses propres paliers : il passe la valeur déjà enregistrée pour qu'elle
  /// garde sa place même si elle tombe entre deux crans.
  List<int> get surfaceOptions =>
      PropertySurfaceCatalogue.valuesFor(kind, include: surface);

  /// Nombres de pièces proposables, valeur déjà enregistrée comprise.
  List<int> get roomOptions {
    final int? current = rooms;
    if (current == null || kRoomSteps.contains(current)) {
      return kRoomSteps;
    }
    return <int>[...kRoomSteps, current]..sort();
  }

  void setKind(PropertyKind value) {
    kind = value;
    if (!asksRooms) {
      // Sinon un bien passé en terrain garderait « 3 pièces » invisible dans
      // le formulaire et visible dans l'annonce publiée.
      rooms = null;
    }
    prefilledFromPrevious = false;
    notifyListeners();
  }

  void setTransaction(TransactionKind value) {
    transaction = value;
    prefilledFromPrevious = false;
    notifyListeners();
  }

  void setNeighbourhood(Neighbourhood value) {
    neighbourhood = value;
    prefilledFromPrevious = false;
    notifyListeners();
  }

  void setSurface(int? value) {
    surface = value;
    notifyListeners();
  }

  void setRooms(int? value) {
    rooms = value;
    notifyListeners();
  }

  void setStatus(PropertyStatus value) {
    status = value;
    notifyListeners();
  }

  /// Enregistre. Renvoie l'identifiant du bien, ou `null` si la saisie n'est
  /// pas exploitable **ou** si l'enregistrement a échoué.
  ///
  /// Les deux cas se distinguent par [submission] : une saisie refusée laisse
  /// la soumission à `idle`, un échec d'écriture porte une
  /// [MutationFailure]. Sans cette distinction, l'écran renvoyait à une étape
  /// du formulaire en annonçant « corrigez d'abord » alors que rien n'était à
  /// corriger.
  Future<String?> save({
    required String title,
    required String priceText,
    String description = '',
  }) async {
    final int? price = parsePrice(priceText);
    final Neighbourhood? area = neighbourhood;
    if (title.trim().isEmpty ||
        area == null ||
        price == null ||
        price <= 0 ||
        isPriceTooHigh(price)) {
      // Rien n'est parti sur le réseau : la soumission repart de zéro, sinon
      // un échec précédent resterait affiché comme s'il venait d'arriver.
      _submission = const MutationState.idle();
      notifyListeners();
      return null;
    }

    _submission = const MutationState.submitting();
    notifyListeners();

    final Property property = Property(
      id: _existing?.id ?? _draftId,
      brokerId: _brokerId,
      kind: kind,
      transaction: transaction,
      title: title.trim(),
      description: description.trim(),
      price: price,
      surface: surface,
      rooms: asksRooms ? rooms : null,
      // Le quartier choisi porte son point : plus besoin d'une étape carte
      // pour éviter des coordonnées nulles au large du golfe de Guinée.
      position: area.position,
      neighbourhood: area.name,
      photoAssets: photos,
      voiceAsset: voiceNote,
      status: status,
      createdAt: _existing?.createdAt ?? _now(),
    );

    final String savedId;
    try {
      // L'identifiant qui compte est celui rendu par le dépôt : en distant, le
      // serveur frappe le sien et `prp-<micros>` n'a jamais existé.
      savedId = (await _properties.save(property)).id;
      _submission = const MutationState.success();
    } on Object catch (error) {
      // Le dépôt est distant : annoncer « base locale indisponible » à
      // quelqu'un qui a perdu le réseau envoie chercher la panne au mauvais
      // endroit. Le brouillon reste : c'est tout ce qu'il lui reste.
      _submission = MutationState.failure(onWriteError(error));
      notifyListeners();
      return null;
    }
    _persist?.cancel();
    await _drafts.clear();
    notifyListeners();
    return savedId;
  }

  /// Brouillon laissé par une saisie que rien n'a publiée, ou `null`.
  ///
  /// Seulement en création : rouvrir un bien existant part de ce que le
  /// serveur en dit, pas d'une saisie abandonnée sur un autre bien.
  Future<PropertyDraft?> pendingDraft() =>
      isEditing ? Future<PropertyDraft?>.value() : _drafts.read();

  /// Reprend le brouillon. Le titre, le prix et la description sont rendus à
  /// l'écran, qui possède leurs contrôleurs.
  void restore(PropertyDraft draft) {
    kind = draft.kind;
    transaction = draft.transaction;
    surface = draft.surface;
    rooms = draft.rooms;
    neighbourhood = draft.neighbourhood;
    photos = List<String>.of(draft.photos);
    voiceNote = draft.voiceNote;
    prefilledFromPrevious = false;
    notifyListeners();
  }

  Future<void> discardDraft() {
    _persist?.cancel();
    return _drafts.clear();
  }

  /// Enregistre la saisie en cours, une fois la frappe retombée : écrire à
  /// chaque caractère ferait tourner le disque d'un téléphone d'entrée de
  /// gamme pendant toute la saisie.
  void rememberDraft({
    required String title,
    required String priceText,
    required String description,
  }) {
    if (isEditing) return;
    _persist?.cancel();
    _persist = Timer(const Duration(milliseconds: 600), () {
      _drafts.write(
        PropertyDraft(
          id: _draftId,
          kind: kind,
          transaction: transaction,
          title: title,
          description: description,
          priceText: priceText,
          surface: surface,
          rooms: rooms,
          neighbourhood: neighbourhood,
          photos: photos,
          voiceNote: voiceNote,
        ),
      );
    });
  }

  @override
  void dispose() {
    _persist?.cancel();
    super.dispose();
  }

  /// Plafond du serveur (`MAX_PRICE_CFA`). Un zéro de trop passait le
  /// formulaire et se faisait refuser après l'envoi, sans dire lequel des
  /// champs était en cause.
  static const int maxPriceCfa = 10000000000;

  static int? parsePrice(String text) =>
      int.tryParse(text.replaceAll(RegExp(r'\D'), ''));

  bool isPriceTooHigh(int? price) => price != null && price > maxPriceCfa;

  /// Position connue du téléphone, fournie par la route.
  ///
  /// Elle ne place plus aucun bien : depuis que le quartier est un choix, il
  /// porte son propre point. Conservée parce que la route la fournit et
  /// qu'une position d'appareil restera utile le jour où l'éditeur proposera
  /// le quartier le plus proche.
  GeoPoint get devicePosition => _fallbackPosition;
}
