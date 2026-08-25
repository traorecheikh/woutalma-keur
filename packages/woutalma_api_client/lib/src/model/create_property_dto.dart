//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:woutalma_api_client/src/model/upload_photo_dto.dart';
import 'package:woutalma_api_client/src/model/upload_voice_note_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_property_dto.g.dart';

/// CreatePropertyDto
///
/// Properties:
/// * [kind]
/// * [transaction]
/// * [title] - Trimmed, and runs of whitespace collapsed to one space, before storage. Accents and non-Latin scripts are preserved. Must not be empty once trimmed.
/// * [description] - Composed by the editor from the entered data, overridable by the broker. Trimmed at the ends; internal line breaks are kept.
/// * [price] - CFA francs, integer. At least 1 — a free listing is not a product feature — and at most 10000000000.
/// * [surface] - Square metres. Omit or send null when unknown, never 0. At most 1000000.
/// * [rooms] - Room count. 0 is accepted and meaningful for a LAND listing; null/omitted means unstated. At most 50.
/// * [latitude]
/// * [longitude]
/// * [neighbourhood] - Quartier name. The client offers a picker of known Dakar quartiers, but any non-empty name is accepted — the list is not exhaustive. Trimmed and whitespace-collapsed before storage.
/// * [status]
/// * [photoAssets]
/// * [newPhotos]
/// * [voiceAsset] - Existing `api:<id>` key to keep. Send an empty string to remove the voice note. Omit to leave it unchanged.
/// * [newVoiceNote]
@BuiltValue()
abstract class CreatePropertyDto
    implements Built<CreatePropertyDto, CreatePropertyDtoBuilder> {
  @BuiltValueField(wireName: r'kind')
  CreatePropertyDtoKindEnum get kind;
  // enum kindEnum {  APARTMENT,  HOUSE,  LAND,  STUDIO,  ROOM,  };

  @BuiltValueField(wireName: r'transaction')
  CreatePropertyDtoTransactionEnum get transaction;
  // enum transactionEnum {  RENT,  SALE,  };

  /// Trimmed, and runs of whitespace collapsed to one space, before storage. Accents and non-Latin scripts are preserved. Must not be empty once trimmed.
  @BuiltValueField(wireName: r'title')
  String get title;

  /// Composed by the editor from the entered data, overridable by the broker. Trimmed at the ends; internal line breaks are kept.
  @BuiltValueField(wireName: r'description')
  String? get description;

  /// CFA francs, integer. At least 1 — a free listing is not a product feature — and at most 10000000000.
  @BuiltValueField(wireName: r'price')
  num get price;

  /// Square metres. Omit or send null when unknown, never 0. At most 1000000.
  @BuiltValueField(wireName: r'surface')
  num? get surface;

  /// Room count. 0 is accepted and meaningful for a LAND listing; null/omitted means unstated. At most 50.
  @BuiltValueField(wireName: r'rooms')
  num? get rooms;

  @BuiltValueField(wireName: r'latitude')
  num get latitude;

  @BuiltValueField(wireName: r'longitude')
  num get longitude;

  /// Quartier name. The client offers a picker of known Dakar quartiers, but any non-empty name is accepted — the list is not exhaustive. Trimmed and whitespace-collapsed before storage.
  @BuiltValueField(wireName: r'neighbourhood')
  String get neighbourhood;

  @BuiltValueField(wireName: r'status')
  CreatePropertyDtoStatusEnum? get status;
  // enum statusEnum {  AVAILABLE,  RESERVED,  CLOSED,  };

  @BuiltValueField(wireName: r'photoAssets')
  BuiltList<String>? get photoAssets;

  @BuiltValueField(wireName: r'newPhotos')
  BuiltList<UploadPhotoDto>? get newPhotos;

  /// Existing `api:<id>` key to keep. Send an empty string to remove the voice note. Omit to leave it unchanged.
  @BuiltValueField(wireName: r'voiceAsset')
  String? get voiceAsset;

  @BuiltValueField(wireName: r'newVoiceNote')
  UploadVoiceNoteDto? get newVoiceNote;

  CreatePropertyDto._();

  factory CreatePropertyDto([void updates(CreatePropertyDtoBuilder b)]) =
      _$CreatePropertyDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreatePropertyDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreatePropertyDto> get serializer =>
      _$CreatePropertyDtoSerializer();
}

class _$CreatePropertyDtoSerializer
    implements PrimitiveSerializer<CreatePropertyDto> {
  @override
  final Iterable<Type> types = const [CreatePropertyDto, _$CreatePropertyDto];

  @override
  final String wireName = r'CreatePropertyDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreatePropertyDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(CreatePropertyDtoKindEnum),
    );
    yield r'transaction';
    yield serializers.serialize(
      object.transaction,
      specifiedType: const FullType(CreatePropertyDtoTransactionEnum),
    );
    yield r'title';
    yield serializers.serialize(
      object.title,
      specifiedType: const FullType(String),
    );
    if (object.description != null) {
      yield r'description';
      yield serializers.serialize(
        object.description,
        specifiedType: const FullType(String),
      );
    }
    yield r'price';
    yield serializers.serialize(
      object.price,
      specifiedType: const FullType(num),
    );
    if (object.surface != null) {
      yield r'surface';
      yield serializers.serialize(
        object.surface,
        specifiedType: const FullType.nullable(num),
      );
    }
    if (object.rooms != null) {
      yield r'rooms';
      yield serializers.serialize(
        object.rooms,
        specifiedType: const FullType.nullable(num),
      );
    }
    yield r'latitude';
    yield serializers.serialize(
      object.latitude,
      specifiedType: const FullType(num),
    );
    yield r'longitude';
    yield serializers.serialize(
      object.longitude,
      specifiedType: const FullType(num),
    );
    yield r'neighbourhood';
    yield serializers.serialize(
      object.neighbourhood,
      specifiedType: const FullType(String),
    );
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(CreatePropertyDtoStatusEnum),
      );
    }
    if (object.photoAssets != null) {
      yield r'photoAssets';
      yield serializers.serialize(
        object.photoAssets,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
    if (object.newPhotos != null) {
      yield r'newPhotos';
      yield serializers.serialize(
        object.newPhotos,
        specifiedType: const FullType(BuiltList, [FullType(UploadPhotoDto)]),
      );
    }
    if (object.voiceAsset != null) {
      yield r'voiceAsset';
      yield serializers.serialize(
        object.voiceAsset,
        specifiedType: const FullType(String),
      );
    }
    if (object.newVoiceNote != null) {
      yield r'newVoiceNote';
      yield serializers.serialize(
        object.newVoiceNote,
        specifiedType: const FullType(UploadVoiceNoteDto),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CreatePropertyDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CreatePropertyDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CreatePropertyDtoKindEnum),
          ) as CreatePropertyDtoKindEnum;
          result.kind = valueDes;
          break;
        case r'transaction':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CreatePropertyDtoTransactionEnum),
          ) as CreatePropertyDtoTransactionEnum;
          result.transaction = valueDes;
          break;
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        case r'description':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.description = valueDes;
          break;
        case r'price':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.price = valueDes;
          break;
        case r'surface':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.surface = valueDes;
          break;
        case r'rooms':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.rooms = valueDes;
          break;
        case r'latitude':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.latitude = valueDes;
          break;
        case r'longitude':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.longitude = valueDes;
          break;
        case r'neighbourhood':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.neighbourhood = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(CreatePropertyDtoStatusEnum),
          ) as CreatePropertyDtoStatusEnum?;
          if (valueDes == null) continue;
          result.status = valueDes;
          break;
        case r'photoAssets':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.photoAssets.replace(valueDes);
          break;
        case r'newPhotos':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(BuiltList, [FullType(UploadPhotoDto)]),
          ) as BuiltList<UploadPhotoDto>?;
          if (valueDes == null) continue;
          result.newPhotos.replace(valueDes);
          break;
        case r'voiceAsset':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.voiceAsset = valueDes;
          break;
        case r'newVoiceNote':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(UploadVoiceNoteDto),
          ) as UploadVoiceNoteDto?;
          if (valueDes == null) continue;
          result.newVoiceNote.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CreatePropertyDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreatePropertyDtoBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}

class CreatePropertyDtoKindEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'APARTMENT')
  static const CreatePropertyDtoKindEnum APARTMENT =
      _$createPropertyDtoKindEnum_APARTMENT;
  @BuiltValueEnumConst(wireName: r'HOUSE')
  static const CreatePropertyDtoKindEnum HOUSE =
      _$createPropertyDtoKindEnum_HOUSE;
  @BuiltValueEnumConst(wireName: r'LAND')
  static const CreatePropertyDtoKindEnum LAND =
      _$createPropertyDtoKindEnum_LAND;
  @BuiltValueEnumConst(wireName: r'STUDIO')
  static const CreatePropertyDtoKindEnum STUDIO =
      _$createPropertyDtoKindEnum_STUDIO;
  @BuiltValueEnumConst(wireName: r'ROOM')
  static const CreatePropertyDtoKindEnum ROOM =
      _$createPropertyDtoKindEnum_ROOM;

  static Serializer<CreatePropertyDtoKindEnum> get serializer =>
      _$createPropertyDtoKindEnumSerializer;

  const CreatePropertyDtoKindEnum._(String name) : super(name);

  static BuiltSet<CreatePropertyDtoKindEnum> get values =>
      _$createPropertyDtoKindEnumValues;
  static CreatePropertyDtoKindEnum valueOf(String name) =>
      _$createPropertyDtoKindEnumValueOf(name);
}

class CreatePropertyDtoTransactionEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'RENT')
  static const CreatePropertyDtoTransactionEnum RENT =
      _$createPropertyDtoTransactionEnum_RENT;
  @BuiltValueEnumConst(wireName: r'SALE')
  static const CreatePropertyDtoTransactionEnum SALE =
      _$createPropertyDtoTransactionEnum_SALE;

  static Serializer<CreatePropertyDtoTransactionEnum> get serializer =>
      _$createPropertyDtoTransactionEnumSerializer;

  const CreatePropertyDtoTransactionEnum._(String name) : super(name);

  static BuiltSet<CreatePropertyDtoTransactionEnum> get values =>
      _$createPropertyDtoTransactionEnumValues;
  static CreatePropertyDtoTransactionEnum valueOf(String name) =>
      _$createPropertyDtoTransactionEnumValueOf(name);
}

class CreatePropertyDtoStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'AVAILABLE')
  static const CreatePropertyDtoStatusEnum AVAILABLE =
      _$createPropertyDtoStatusEnum_AVAILABLE;
  @BuiltValueEnumConst(wireName: r'RESERVED')
  static const CreatePropertyDtoStatusEnum RESERVED =
      _$createPropertyDtoStatusEnum_RESERVED;
  @BuiltValueEnumConst(wireName: r'CLOSED')
  static const CreatePropertyDtoStatusEnum CLOSED =
      _$createPropertyDtoStatusEnum_CLOSED;

  static Serializer<CreatePropertyDtoStatusEnum> get serializer =>
      _$createPropertyDtoStatusEnumSerializer;

  const CreatePropertyDtoStatusEnum._(String name) : super(name);

  static BuiltSet<CreatePropertyDtoStatusEnum> get values =>
      _$createPropertyDtoStatusEnumValues;
  static CreatePropertyDtoStatusEnum valueOf(String name) =>
      _$createPropertyDtoStatusEnumValueOf(name);
}
