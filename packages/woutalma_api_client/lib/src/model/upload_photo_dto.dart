//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'upload_photo_dto.g.dart';

/// UploadPhotoDto
///
/// Properties:
/// * [mimeType]
/// * [dataBase64] - Base64-encoded image bytes. Decoded size must not exceed 163840 bytes — compress before sending.
@BuiltValue()
abstract class UploadPhotoDto
    implements Built<UploadPhotoDto, UploadPhotoDtoBuilder> {
  @BuiltValueField(wireName: r'mimeType')
  UploadPhotoDtoMimeTypeEnum get mimeType;
  // enum mimeTypeEnum {  image/jpeg,  image/png,  image/webp,  };

  /// Base64-encoded image bytes. Decoded size must not exceed 163840 bytes — compress before sending.
  @BuiltValueField(wireName: r'dataBase64')
  String get dataBase64;

  UploadPhotoDto._();

  factory UploadPhotoDto([void updates(UploadPhotoDtoBuilder b)]) =
      _$UploadPhotoDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UploadPhotoDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UploadPhotoDto> get serializer =>
      _$UploadPhotoDtoSerializer();
}

class _$UploadPhotoDtoSerializer
    implements PrimitiveSerializer<UploadPhotoDto> {
  @override
  final Iterable<Type> types = const [UploadPhotoDto, _$UploadPhotoDto];

  @override
  final String wireName = r'UploadPhotoDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UploadPhotoDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'mimeType';
    yield serializers.serialize(
      object.mimeType,
      specifiedType: const FullType(UploadPhotoDtoMimeTypeEnum),
    );
    yield r'dataBase64';
    yield serializers.serialize(
      object.dataBase64,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    UploadPhotoDto object, {
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
    required UploadPhotoDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'mimeType':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(UploadPhotoDtoMimeTypeEnum),
          ) as UploadPhotoDtoMimeTypeEnum;
          result.mimeType = valueDes;
          break;
        case r'dataBase64':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.dataBase64 = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UploadPhotoDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UploadPhotoDtoBuilder();
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

class UploadPhotoDtoMimeTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'image/jpeg')
  static const UploadPhotoDtoMimeTypeEnum imageSlashJpeg =
      _$uploadPhotoDtoMimeTypeEnum_imageSlashJpeg;
  @BuiltValueEnumConst(wireName: r'image/png')
  static const UploadPhotoDtoMimeTypeEnum imageSlashPng =
      _$uploadPhotoDtoMimeTypeEnum_imageSlashPng;
  @BuiltValueEnumConst(wireName: r'image/webp')
  static const UploadPhotoDtoMimeTypeEnum imageSlashWebp =
      _$uploadPhotoDtoMimeTypeEnum_imageSlashWebp;

  static Serializer<UploadPhotoDtoMimeTypeEnum> get serializer =>
      _$uploadPhotoDtoMimeTypeEnumSerializer;

  const UploadPhotoDtoMimeTypeEnum._(String name) : super(name);

  static BuiltSet<UploadPhotoDtoMimeTypeEnum> get values =>
      _$uploadPhotoDtoMimeTypeEnumValues;
  static UploadPhotoDtoMimeTypeEnum valueOf(String name) =>
      _$uploadPhotoDtoMimeTypeEnumValueOf(name);
}
