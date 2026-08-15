import 'package:flutter/foundation.dart';

/// D'où vient une photo.
enum PhotoSource { camera, gallery }

/// Sélectionne et allège les photos d'un bien.
///
/// La compression n'est pas une optimisation : sur la cible, une photo de
/// 4 Mo envoyée en 3G coûte de l'argent réel à celui qui la publie **et** à
/// celui qui la regarde.
abstract class PhotoService {
  /// Nombre maximal de photos par bien.
  int get maxPerProperty;

  /// Renvoie le chemin de la photo allégée, ou `null` si l'utilisateur a
  /// abandonné ou si la photo n'a pas pu être traitée.
  Future<String?> pick(PhotoSource source);
}

/// Contraintes de compression, partagées par l'implémentation réelle et les
/// tests.
@immutable
class PhotoConstraints {
  const PhotoConstraints({
    this.maxWidth = 1280,
    this.quality = 70,
    this.maxPerProperty = 3,
    this.maxUploadBytes = 160 * 1024,
  });

  /// Assez pour juger un logement sur un écran de téléphone, pas plus.
  final int maxWidth;

  /// Qualité JPEG. En dessous, les artefacts deviennent visibles sur les
  /// murs et les sols, exactement ce qu'on regarde.
  final int quality;

  /// Au-delà, personne ne fait défiler, et le poids double.
  ///
  /// C'est aussi la limite que le serveur impose
  /// (`MAX_PHOTOS_PER_PROPERTY`). Les deux doivent dire le même nombre :
  /// laisser le sélecteur en accepter davantage revient à faire prendre six
  /// photos pour en voir trois refusées à la publication.
  final int maxPerProperty;

  /// Poids maximal d'une photo **après décodage base64**, côté serveur.
  ///
  /// Miroir de `MAX_PHOTO_BYTES`. Une photo plus lourde est recompressée
  /// avant l'envoi plutôt que refusée : le courtier a déjà pris la photo.
  final int maxUploadBytes;

  /// Types acceptés par le serveur (`ALLOWED_PHOTO_MIME_TYPES`).
  static const Set<String> allowedMimeTypes = <String>{
    'image/jpeg',
    'image/png',
    'image/webp',
  };
}
