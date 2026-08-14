//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_contact_dto.g.dart';

/// CreateContactDto
///
/// Properties:
/// * [brokerId]
/// * [propertyId]
/// * [channel]
/// * [clientRequestId] - Stable client-generated key for retry-safe contact logging.
@BuiltValue()
abstract class CreateContactDto
    implements Built<CreateContactDto, CreateContactDtoBuilder> {
  @BuiltValueField(wireName: r'brokerId')
  String get brokerId;

  @BuiltValueField(wireName: r'propertyId')
  String? get propertyId;

  @BuiltValueField(wireName: r'channel')
  CreateContactDtoChannelEnum get channel;
  // enum channelEnum {  CALL,  SMS,  WHATSAPP,  VOICE_MESSAGE,  };

  /// Stable client-generated key for retry-safe contact logging.
  @BuiltValueField(wireName: r'clientRequestId')
  String? get clientRequestId;

  CreateContactDto._();

  factory CreateContactDto([void updates(CreateContactDtoBuilder b)]) =
      _$CreateContactDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateContactDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateContactDto> get serializer =>
      _$CreateContactDtoSerializer();
}

class _$CreateContactDtoSerializer
    implements PrimitiveSerializer<CreateContactDto> {
  @override
  final Iterable<Type> types = const [CreateContactDto, _$CreateContactDto];

  @override
  final String wireName = r'CreateContactDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateContactDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'brokerId';
    yield serializers.serialize(
      object.brokerId,
      specifiedType: const FullType(String),
    );
    if (object.propertyId != null) {
      yield r'propertyId';
      yield serializers.serialize(
        object.propertyId,
        specifiedType: const FullType(String),
      );
    }
    yield r'channel';
    yield serializers.serialize(
      object.channel,
      specifiedType: const FullType(CreateContactDtoChannelEnum),
    );
    if (object.clientRequestId != null) {
      yield r'clientRequestId';
      yield serializers.serialize(
        object.clientRequestId,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CreateContactDto object, {
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
    required CreateContactDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'brokerId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.brokerId = valueDes;
          break;
        case r'propertyId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.propertyId = valueDes;
          break;
        case r'channel':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CreateContactDtoChannelEnum),
          ) as CreateContactDtoChannelEnum;
          result.channel = valueDes;
          break;
        case r'clientRequestId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.clientRequestId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CreateContactDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateContactDtoBuilder();
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

class CreateContactDtoChannelEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'CALL')
  static const CreateContactDtoChannelEnum CALL =
      _$createContactDtoChannelEnum_CALL;
  @BuiltValueEnumConst(wireName: r'SMS')
  static const CreateContactDtoChannelEnum SMS =
      _$createContactDtoChannelEnum_SMS;
  @BuiltValueEnumConst(wireName: r'WHATSAPP')
  static const CreateContactDtoChannelEnum WHATSAPP =
      _$createContactDtoChannelEnum_WHATSAPP;
  @BuiltValueEnumConst(wireName: r'VOICE_MESSAGE')
  static const CreateContactDtoChannelEnum VOICE_MESSAGE =
      _$createContactDtoChannelEnum_VOICE_MESSAGE;

  static Serializer<CreateContactDtoChannelEnum> get serializer =>
      _$createContactDtoChannelEnumSerializer;

  const CreateContactDtoChannelEnum._(String name) : super(name);

  static BuiltSet<CreateContactDtoChannelEnum> get values =>
      _$createContactDtoChannelEnumValues;
  static CreateContactDtoChannelEnum valueOf(String name) =>
      _$createContactDtoChannelEnumValueOf(name);
}
