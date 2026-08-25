//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'upload_voice_note_dto.g.dart';

/// UploadVoiceNoteDto
///
/// Properties:
/// * [mimeType]
/// * [dataBase64] - Base64-encoded audio bytes. Decoded size must not exceed 524288 bytes — record short, at a speech bitrate.
@BuiltValue()
abstract class UploadVoiceNoteDto
    implements Built<UploadVoiceNoteDto, UploadVoiceNoteDtoBuilder> {
  @BuiltValueField(wireName: r'mimeType')
  UploadVoiceNoteDtoMimeTypeEnum get mimeType;
  // enum mimeTypeEnum {  audio/mp4,  audio/aac,  audio/mpeg,  audio/ogg,  audio/webm,  };

  /// Base64-encoded audio bytes. Decoded size must not exceed 524288 bytes — record short, at a speech bitrate.
  @BuiltValueField(wireName: r'dataBase64')
  String get dataBase64;

  UploadVoiceNoteDto._();

  factory UploadVoiceNoteDto([void updates(UploadVoiceNoteDtoBuilder b)]) =
      _$UploadVoiceNoteDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UploadVoiceNoteDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UploadVoiceNoteDto> get serializer =>
      _$UploadVoiceNoteDtoSerializer();
}

class _$UploadVoiceNoteDtoSerializer
    implements PrimitiveSerializer<UploadVoiceNoteDto> {
  @override
  final Iterable<Type> types = const [UploadVoiceNoteDto, _$UploadVoiceNoteDto];

  @override
  final String wireName = r'UploadVoiceNoteDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UploadVoiceNoteDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'mimeType';
    yield serializers.serialize(
      object.mimeType,
      specifiedType: const FullType(UploadVoiceNoteDtoMimeTypeEnum),
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
    UploadVoiceNoteDto object, {
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
    required UploadVoiceNoteDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'mimeType':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(UploadVoiceNoteDtoMimeTypeEnum),
          ) as UploadVoiceNoteDtoMimeTypeEnum;
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
  UploadVoiceNoteDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UploadVoiceNoteDtoBuilder();
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

class UploadVoiceNoteDtoMimeTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'audio/mp4')
  static const UploadVoiceNoteDtoMimeTypeEnum audioSlashMp4 =
      _$uploadVoiceNoteDtoMimeTypeEnum_audioSlashMp4;
  @BuiltValueEnumConst(wireName: r'audio/aac')
  static const UploadVoiceNoteDtoMimeTypeEnum audioSlashAac =
      _$uploadVoiceNoteDtoMimeTypeEnum_audioSlashAac;
  @BuiltValueEnumConst(wireName: r'audio/mpeg')
  static const UploadVoiceNoteDtoMimeTypeEnum audioSlashMpeg =
      _$uploadVoiceNoteDtoMimeTypeEnum_audioSlashMpeg;
  @BuiltValueEnumConst(wireName: r'audio/ogg')
  static const UploadVoiceNoteDtoMimeTypeEnum audioSlashOgg =
      _$uploadVoiceNoteDtoMimeTypeEnum_audioSlashOgg;
  @BuiltValueEnumConst(wireName: r'audio/webm')
  static const UploadVoiceNoteDtoMimeTypeEnum audioSlashWebm =
      _$uploadVoiceNoteDtoMimeTypeEnum_audioSlashWebm;

  static Serializer<UploadVoiceNoteDtoMimeTypeEnum> get serializer =>
      _$uploadVoiceNoteDtoMimeTypeEnumSerializer;

  const UploadVoiceNoteDtoMimeTypeEnum._(String name) : super(name);

  static BuiltSet<UploadVoiceNoteDtoMimeTypeEnum> get values =>
      _$uploadVoiceNoteDtoMimeTypeEnumValues;
  static UploadVoiceNoteDtoMimeTypeEnum valueOf(String name) =>
      _$uploadVoiceNoteDtoMimeTypeEnumValueOf(name);
}
