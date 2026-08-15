import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/property_surface.dart';

/// Les champs structurés dont une description a besoin.
///
/// Volontairement plus petit que [Property] : le formulaire B03 compose la
/// phrase pendant la saisie, quand le bien n'existe pas encore et n'a ni
/// identifiant, ni date, ni position.
@immutable
class PropertyDescriptionDraft {
  const PropertyDescriptionDraft({
    required this.kind,
    required this.transaction,
    required this.price,
    this.surface,
    this.rooms,
    this.neighbourhood = '',
  });

  /// Vue sur un bien existant, pour recomposer ou vérifier une description
  /// déjà enregistrée.
  factory PropertyDescriptionDraft.of(Property property) {
    return PropertyDescriptionDraft(
      kind: property.kind,
      transaction: property.transaction,
      price: property.price,
      surface: property.surface,
      rooms: property.rooms,
      neighbourhood: property.neighbourhood,
    );
  }

  final PropertyKind kind;
  final TransactionKind transaction;

  /// En francs CFA. Une valeur nulle ou négative est traitée comme « pas
  /// encore saisie » : la phrase se compose sans prix plutôt que d'annoncer
  /// un bien à zéro franc.
  final int price;

  /// En mètres carrés, absente tant qu'elle n'est pas choisie.
  final int? surface;
  final int? rooms;
  final String neighbourhood;
}

/// Écrit la description d'un bien à partir de ce qui a déjà été saisi.
///
/// Le formulaire B03 demandait une description au clavier à quelqu'un qui lit
/// mal et tape sur un téléphone d'entrée de gamme. Le champ restait vide, ou
/// recevait trois mots. Or tout ce qu'une description utile contient — le
/// type, la transaction, le quartier, la surface, les pièces, le prix — a déjà
/// été choisi champ par champ deux écrans plus haut. La phrase est donc
/// déduite, pas demandée ; le courtier la corrige s'il veut dire autre chose.
///
/// Trois règles tiennent tout le reste :
///
/// 1. **Rien qui ne soit dans les données.** Aucun agrément, aucun « proche du
///    marché », aucun « lumineux ». Le seed en contient parce qu'un humain les
///    a écrits en connaissant le bien ; le composeur ne les connaît pas. Une
///    annonce générée qui invente une cour engage le courtier sur une chose
///    qu'il n'a pas dite.
/// 2. **Déterministe.** Même saisie, même phrase, à la milliseconde près comme
///    dans six mois : c'est ce qui permet à [isComposed] de reconnaître une
///    suggestion intacte, et aux captures de référence de rester comparables.
/// 3. **Deux phrases courtes plutôt qu'une longue.** « Maison à louer, quartier
///    Médina. 4 pièces, 120 m², 350 000 F par mois. » se lit et s'écoute mieux
///    qu'une seule ligne à cinq virgules — la description passe aussi par la
///    lecture à voix haute.
///
/// Le texte produit est en français seul, comme le reste du prototype. Il n'est
/// pas tiré des ARB, et c'est un choix : ce que ce composeur écrit atterrit
/// dans `Property.description`, une donnée d'annonce que son auteur possède et
/// modifie, pas une chaîne d'interface. Une annonce rédigée en français le
/// reste quelle que soit la langue du client qui la lit. Le jour où un courtier
/// rédige en wolof, c'est ce composeur qui prendra une langue en paramètre, pas
/// l'écran qui changera.
abstract final class PropertyDescriptionComposer {
  /// Compose la description de [draft].
  ///
  /// Rend toujours au moins une phrase : le type et la transaction sont
  /// obligatoires dans le formulaire, donc toujours disponibles.
  static String compose(PropertyDescriptionDraft draft) {
    final String identity = _identitySentence(draft);
    final String facts = _factsSentence(draft);
    return facts.isEmpty ? identity : '$identity $facts';
  }

  /// Raccourci pour un bien déjà construit.
  static String composeFor(Property property) =>
      compose(PropertyDescriptionDraft.of(property));

  /// Vrai si [description] est mot pour mot ce que [draft] produirait.
  ///
  /// C'est la réponse à « le courtier a-t-il écrit sa propre description, ou
  /// a-t-il laissé la suggestion ? » sans poser un drapeau sur l'entité. Un
  /// booléen `descriptionIsGenerated` sur [Property] aurait fallu le stocker,
  /// le migrer, le synchroniser avec le serveur, et il aurait menti dès la
  /// première modification faite hors du formulaire. La description se
  /// suffit : on la recompose et on compare.
  ///
  /// La comparaison ignore les espaces de bord et les espaces répétés — un
  /// champ de texte en ajoute sans que personne n'ait rien voulu dire — mais
  /// rien d'autre. Une majuscule changée est une intention.
  ///
  /// Conséquence à connaître côté formulaire : la référence est l'état
  /// structuré **au moment de l'appel**. Pour décider si une suggestion peut
  /// être remplacée après un changement de prix, il faut comparer avec le
  /// brouillon d'avant le changement, pas celui d'après.
  static bool isComposed(String description, PropertyDescriptionDraft draft) {
    return _normalise(description) == _normalise(compose(draft));
  }

  /// Vrai si la description enregistrée de [property] est encore celle que ses
  /// champs structurés produisent.
  static bool isComposedFor(Property property) =>
      isComposed(property.description, PropertyDescriptionDraft.of(property));

  /// Première phrase : ce que c'est, ce qu'on en fait, où.
  ///
  /// Le quartier est introduit par « quartier » et non par « à ». « à Médina »
  /// est juste, « à Plateau » et « à Parcelles Assainies » ne le sont pas — il
  /// faudrait « au » et « aux ». La contraction dépend de l'article du nom de
  /// quartier, que la donnée ne porte pas : `neighbourhood` est saisi
  /// librement et le seed le stocke sans article. Deviner cet article, c'est
  /// se tromper une fois sur trois sur des noms que les habitants lisent tous
  /// les jours. L'apposition évite la question et reste le registre des petites
  /// annonces d'ici.
  static String _identitySentence(PropertyDescriptionDraft draft) {
    final String noun = _kindNoun(draft.kind);
    final String action = switch (draft.transaction) {
      TransactionKind.rent => 'à louer',
      TransactionKind.sale => 'à vendre',
    };
    final String place = draft.neighbourhood.trim();
    if (place.isEmpty) {
      return '$noun $action.';
    }
    return '$noun $action, quartier $place.';
  }

  /// Seconde phrase : les chiffres, dans l'ordre où on les cherche.
  ///
  /// Fragment nominal assumé — « 4 pièces, 120 m², 350 000 F par mois. » — ;
  /// c'est déjà le registre des descriptions écrites à la main dans le jeu de
  /// démonstration, et une phrase complète autour de ces trois nombres les
  /// noierait.
  ///
  /// Vide si aucun des trois n'est disponible : mieux vaut une seule phrase
  /// qu'une seconde amputée.
  static String _factsSentence(PropertyDescriptionDraft draft) {
    final List<String> parts = <String>[];

    final int? rooms = draft.rooms;
    if (rooms != null && rooms > 0 && _mentionsRooms(draft.kind, rooms)) {
      parts.add(rooms == 1 ? '1 pièce' : '$rooms pièces');
    }

    final int? surface = draft.surface;
    if (surface != null && surface > 0) {
      parts.add('$surface m²');
    }

    if (draft.price > 0) {
      parts.add(_price(draft.price, draft.transaction));
    }

    return parts.isEmpty ? '' : '${parts.join(', ')}.';
  }

  /// Un terrain n'a pas de pièces, même si la donnée en porte : l'annoncer
  /// serait inventer un bâti. Et « Chambre […] 1 pièce » ou « Studio […]
  /// 1 pièce » répète le mot précédent — le type dit déjà que c'est une seule
  /// pièce. À partir de deux, l'information redevient utile, y compris pour un
  /// studio.
  static bool _mentionsRooms(PropertyKind kind, int rooms) {
    if (!propertyKindHasRooms(kind)) {
      return false;
    }
    final bool singleRoomByNature =
        kind == PropertyKind.room || kind == PropertyKind.studio;
    return !(singleRoomByNature && rooms == 1);
  }

  /// Prix en francs CFA.
  ///
  /// Le nombre est mis en forme exactement comme `WkFormat.price` le fait
  /// partout ailleurs — `NumberFormat('#,##0', 'fr')`, donc l'espace fine
  /// insécable française comme séparateur de milliers — et l'unité reste « F ».
  /// Ce composeur ne peut pas appeler `WkFormat` : celui-ci vit dans
  /// `lib/app/shared/` et dépend de `AppL10n`, donc de Flutter, alors que le
  /// domaine reste du Dart pur testable sans binding. La règle est donc
  /// recopiée, pas réinventée.
  ///
  /// Seule différence assumée : la périodicité s'écrit « par mois » et non
  /// « /mois ». La barre oblique va bien dans une puce de carte ; dans une
  /// phrase lue à voix haute, elle s'entend mal ou pas du tout.
  static String _price(int amount, TransactionKind transaction) {
    final String formatted = NumberFormat('#,##0', 'fr').format(amount);
    return transaction == TransactionKind.rent
        ? '$formatted F par mois'
        : '$formatted F';
  }

  static String _kindNoun(PropertyKind kind) {
    return switch (kind) {
      PropertyKind.apartment => 'Appartement',
      PropertyKind.house => 'Maison',
      PropertyKind.land => 'Terrain',
      PropertyKind.studio => 'Studio',
      PropertyKind.room => 'Chambre',
    };
  }

  /// Espaces de mise en page seulement : la classe exclut l'espace fine
  /// insécable des milliers, qui fait partie du nombre.
  static final RegExp _layoutSpaces = RegExp(r'[ \t\r\n]+');

  static String _normalise(String value) =>
      value.replaceAll(_layoutSpaces, ' ').trim();
}
