import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:woutalma_keur/app/domain/photo_service.dart';

/// Sélection réelle, suivie d'une compression systématique.
class ImagePickerPhotoService implements PhotoService {
  ImagePickerPhotoService({
    this.constraints = const PhotoConstraints(),
    ImagePicker? picker,
  }) : _picker = picker ?? ImagePicker();

  final PhotoConstraints constraints;
  final ImagePicker _picker;

  @override
  int get maxPerProperty => constraints.maxPerProperty;

  @override
  Future<String?> pick(PhotoSource source) async {
    final XFile? picked = await _picker.pickImage(
      source: source == PhotoSource.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      // Première réduction dès la sélection : éviter de charger 12 Mpx en
      // mémoire sur un téléphone qui n'en a pas les moyens.
      maxWidth: constraints.maxWidth.toDouble(),
      imageQuality: constraints.quality,
    );
    if (picked == null) {
      return null;
    }

    try {
      final Directory dir = await getApplicationDocumentsDirectory();
      final String target =
          '${dir.path}/wk-${DateTime.now().microsecondsSinceEpoch}.jpg';

      final XFile? compressed = await FlutterImageCompress.compressAndGetFile(
        picked.path,
        target,
        quality: constraints.quality,
        minWidth: constraints.maxWidth,
        // La hauteur suit le ratio ; on ne déforme jamais une photo de
        // logement.
        minHeight: 1,
      );
      return compressed?.path ?? picked.path;
    } on Object {
      // Compression impossible : on garde l'original plutôt que de perdre la
      // photo. Plus lourde, mais présente.
      return picked.path;
    }
  }
}
