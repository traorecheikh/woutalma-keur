import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/location_service.dart';

/// Saisie de B03 non encore publiée.
///
/// Le courtier remplit trois écrans sur un téléphone qui ferme les
/// applications en arrière-plan : sans cette copie, revenir dans l'éditeur
/// après un appel reçu recommençait tout, y compris les photos déjà prises.
@immutable
class PropertyDraft {
  const PropertyDraft({
    required this.id,
    required this.kind,
    required this.transaction,
    required this.title,
    required this.description,
    required this.priceText,
    required this.photos,
    this.surface,
    this.rooms,
    this.neighbourhood,
    this.voiceNote,
  });

  factory PropertyDraft.fromJson(Map<String, Object?> json) {
    final Object? area = json['neighbourhood'];
    return PropertyDraft(
      id: json['id']! as String,
      kind: PropertyKind.values.byName(json['kind']! as String),
      transaction: TransactionKind.values.byName(
        json['transaction']! as String,
      ),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      priceText: json['priceText'] as String? ?? '',
      surface: json['surface'] as int?,
      rooms: json['rooms'] as int?,
      neighbourhood: area is Map<String, Object?>
          ? Neighbourhood(
              name: area['name']! as String,
              position: GeoPoint(
                (area['latitude']! as num).toDouble(),
                (area['longitude']! as num).toDouble(),
              ),
            )
          : null,
      photos: (json['photos'] as List<Object?>? ?? const <Object?>[])
          .cast<String>(),
      voiceNote: json['voiceNote'] as String?,
    );
  }

  final String id;
  final PropertyKind kind;
  final TransactionKind transaction;
  final String title;
  final String description;

  /// Tel que tapé : reprendre un brouillon ne doit pas reformater le prix
  /// sous les yeux de quelqu'un qui n'a rien demandé.
  final String priceText;
  final int? surface;
  final int? rooms;
  final Neighbourhood? neighbourhood;
  final List<String> photos;
  final String? voiceNote;

  bool get isEmpty =>
      title.trim().isEmpty &&
      description.trim().isEmpty &&
      priceText.trim().isEmpty &&
      photos.isEmpty &&
      voiceNote == null &&
      neighbourhood == null;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'kind': kind.name,
    'transaction': transaction.name,
    'title': title,
    'description': description,
    'priceText': priceText,
    'surface': surface,
    'rooms': rooms,
    if (neighbourhood != null)
      'neighbourhood': <String, Object?>{
        'name': neighbourhood!.name,
        'latitude': neighbourhood!.position.latitude,
        'longitude': neighbourhood!.position.longitude,
      },
    'photos': photos,
    'voiceNote': voiceNote,
  };
}

/// Un seul brouillon à la fois, dans un fichier du dossier documents.
///
/// Pas dans Isar : ce n'est pas une copie de l'API mais une saisie en cours,
/// et la base ne doit pas contenir de bien qui n'existe nulle part.
class PropertyDraftStore {
  const PropertyDraftStore();

  static const String _fileName = 'wk-property-draft.json';

  Future<File> _file() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<PropertyDraft?> read() async {
    try {
      final File file = await _file();
      if (!await file.exists()) {
        return null;
      }
      final Object? json = jsonDecode(await file.readAsString());
      if (json is! Map<String, Object?>) {
        return null;
      }
      final PropertyDraft draft = PropertyDraft.fromJson(json);
      return draft.isEmpty ? null : draft;
    } on Object {
      // Fichier tronqué par une fermeture brutale : un brouillon illisible
      // n'a pas à empêcher d'ouvrir l'éditeur.
      return null;
    }
  }

  Future<void> write(PropertyDraft draft) async {
    try {
      await (await _file()).writeAsString(jsonEncode(draft.toJson()));
    } on Object {
      // Rien à annoncer : la sauvegarde est un filet, pas une promesse.
    }
  }

  Future<void> clear() async {
    try {
      final File file = await _file();
      if (await file.exists()) {
        await file.delete();
      }
    } on Object {
      // Idem.
    }
  }
}
