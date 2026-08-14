//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'contact_log_dto.g.dart';

/// ContactLogDto
///
/// Properties:
/// * [id]
/// * [brokerId]
/// * [propertyId]
/// * [channel]
/// * [outcome]
/// * [reviewId]
/// * [createdAt]
/// * [allowsReview]
@BuiltValue()
abstract class ContactLogDto
    implements Built<ContactLogDto, ContactLogDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'brokerId')
  String get brokerId;

  @BuiltValueField(wireName: r'propertyId')
  String? get propertyId;

  @BuiltValueField(wireName: r'channel')
  ContactLogDtoChannelEnum get channel;
  // enum channelEnum {  CALL,  SMS,  WHATSAPP,  VOICE_MESSAGE,  };

  @BuiltValueField(wireName: r'outcome')
  ContactLogDtoOutcomeEnum get outcome;
  // enum outcomeEnum {  ATTEMPTED,  REACHED,  NO_ANSWER,  };

  @BuiltValueField(wireName: r'reviewId')
  String? get reviewId;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'allowsReview')
  bool get allowsReview;

  ContactLogDto._();

  factory ContactLogDto([void updates(ContactLogDtoBuilder b)]) =
      _$ContactLogDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ContactLogDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ContactLogDto> get serializer =>
      _$ContactLogDtoSerializer();
}

class _$ContactLogDtoSerializer implements PrimitiveSerializer<ContactLogDto> {
  @override
  final Iterable<Type> types = const [ContactLogDto, _$ContactLogDto];

  @override
  final String wireName = r'ContactLogDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ContactLogDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'brokerId';
    yield serializers.serialize(
      object.brokerId,
      specifiedType: const FullType(String),
    );
    if (object.propertyId != null) {
      yield r'propertyId';
      yield serializers.serialize(
        object.propertyId,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'channel';
    yield serializers.serialize(
      object.channel,
      specifiedType: const FullType(ContactLogDtoChannelEnum),
    );
    yield r'outcome';
    yield serializers.serialize(
      object.outcome,
      specifiedType: const FullType(ContactLogDtoOutcomeEnum),
    );
    if (object.reviewId != null) {
      yield r'reviewId';
      yield serializers.serialize(
        object.reviewId,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'allowsReview';
    yield serializers.serialize(
      object.allowsReview,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ContactLogDto object, {
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
    required ContactLogDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
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
            specifiedType: const FullType(ContactLogDtoChannelEnum),
          ) as ContactLogDtoChannelEnum;
          result.channel = valueDes;
          break;
        case r'outcome':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ContactLogDtoOutcomeEnum),
          ) as ContactLogDtoOutcomeEnum;
          result.outcome = valueDes;
          break;
        case r'reviewId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.reviewId = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'allowsReview':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.allowsReview = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ContactLogDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ContactLogDtoBuilder();
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

class ContactLogDtoChannelEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'CALL')
  static const ContactLogDtoChannelEnum CALL = _$contactLogDtoChannelEnum_CALL;
  @BuiltValueEnumConst(wireName: r'SMS')
  static const ContactLogDtoChannelEnum SMS = _$contactLogDtoChannelEnum_SMS;
  @BuiltValueEnumConst(wireName: r'WHATSAPP')
  static const ContactLogDtoChannelEnum WHATSAPP =
      _$contactLogDtoChannelEnum_WHATSAPP;
  @BuiltValueEnumConst(wireName: r'VOICE_MESSAGE')
  static const ContactLogDtoChannelEnum VOICE_MESSAGE =
      _$contactLogDtoChannelEnum_VOICE_MESSAGE;

  static Serializer<ContactLogDtoChannelEnum> get serializer =>
      _$contactLogDtoChannelEnumSerializer;

  const ContactLogDtoChannelEnum._(String name) : super(name);

  static BuiltSet<ContactLogDtoChannelEnum> get values =>
      _$contactLogDtoChannelEnumValues;
  static ContactLogDtoChannelEnum valueOf(String name) =>
      _$contactLogDtoChannelEnumValueOf(name);
}

class ContactLogDtoOutcomeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'ATTEMPTED')
  static const ContactLogDtoOutcomeEnum ATTEMPTED =
      _$contactLogDtoOutcomeEnum_ATTEMPTED;
  @BuiltValueEnumConst(wireName: r'REACHED')
  static const ContactLogDtoOutcomeEnum REACHED =
      _$contactLogDtoOutcomeEnum_REACHED;
  @BuiltValueEnumConst(wireName: r'NO_ANSWER')
  static const ContactLogDtoOutcomeEnum NO_ANSWER =
      _$contactLogDtoOutcomeEnum_NO_ANSWER;

  static Serializer<ContactLogDtoOutcomeEnum> get serializer =>
      _$contactLogDtoOutcomeEnumSerializer;

  const ContactLogDtoOutcomeEnum._(String name) : super(name);

  static BuiltSet<ContactLogDtoOutcomeEnum> get values =>
      _$contactLogDtoOutcomeEnumValues;
  static ContactLogDtoOutcomeEnum valueOf(String name) =>
      _$contactLogDtoOutcomeEnumValueOf(name);
}
