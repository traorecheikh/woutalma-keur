//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'broker_contact_log_dto.g.dart';

/// BrokerContactLogDto
///
/// Properties:
/// * [id]
/// * [brokerId]
/// * [propertyId]
/// * [channel]
/// * [outcome]
/// * [hasReview]
/// * [createdAt]
@BuiltValue()
abstract class BrokerContactLogDto
    implements Built<BrokerContactLogDto, BrokerContactLogDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'brokerId')
  String get brokerId;

  @BuiltValueField(wireName: r'propertyId')
  String? get propertyId;

  @BuiltValueField(wireName: r'channel')
  BrokerContactLogDtoChannelEnum get channel;
  // enum channelEnum {  CALL,  SMS,  WHATSAPP,  VOICE_MESSAGE,  };

  @BuiltValueField(wireName: r'outcome')
  BrokerContactLogDtoOutcomeEnum get outcome;
  // enum outcomeEnum {  ATTEMPTED,  REACHED,  NO_ANSWER,  };

  @BuiltValueField(wireName: r'hasReview')
  bool get hasReview;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  BrokerContactLogDto._();

  factory BrokerContactLogDto([void updates(BrokerContactLogDtoBuilder b)]) =
      _$BrokerContactLogDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BrokerContactLogDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BrokerContactLogDto> get serializer =>
      _$BrokerContactLogDtoSerializer();
}

class _$BrokerContactLogDtoSerializer
    implements PrimitiveSerializer<BrokerContactLogDto> {
  @override
  final Iterable<Type> types = const [
    BrokerContactLogDto,
    _$BrokerContactLogDto
  ];

  @override
  final String wireName = r'BrokerContactLogDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BrokerContactLogDto object, {
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
      specifiedType: const FullType(BrokerContactLogDtoChannelEnum),
    );
    yield r'outcome';
    yield serializers.serialize(
      object.outcome,
      specifiedType: const FullType(BrokerContactLogDtoOutcomeEnum),
    );
    yield r'hasReview';
    yield serializers.serialize(
      object.hasReview,
      specifiedType: const FullType(bool),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BrokerContactLogDto object, {
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
    required BrokerContactLogDtoBuilder result,
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
            specifiedType: const FullType(BrokerContactLogDtoChannelEnum),
          ) as BrokerContactLogDtoChannelEnum;
          result.channel = valueDes;
          break;
        case r'outcome':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BrokerContactLogDtoOutcomeEnum),
          ) as BrokerContactLogDtoOutcomeEnum;
          result.outcome = valueDes;
          break;
        case r'hasReview':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.hasReview = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BrokerContactLogDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BrokerContactLogDtoBuilder();
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

class BrokerContactLogDtoChannelEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'CALL')
  static const BrokerContactLogDtoChannelEnum CALL =
      _$brokerContactLogDtoChannelEnum_CALL;
  @BuiltValueEnumConst(wireName: r'SMS')
  static const BrokerContactLogDtoChannelEnum SMS =
      _$brokerContactLogDtoChannelEnum_SMS;
  @BuiltValueEnumConst(wireName: r'WHATSAPP')
  static const BrokerContactLogDtoChannelEnum WHATSAPP =
      _$brokerContactLogDtoChannelEnum_WHATSAPP;
  @BuiltValueEnumConst(wireName: r'VOICE_MESSAGE')
  static const BrokerContactLogDtoChannelEnum VOICE_MESSAGE =
      _$brokerContactLogDtoChannelEnum_VOICE_MESSAGE;

  static Serializer<BrokerContactLogDtoChannelEnum> get serializer =>
      _$brokerContactLogDtoChannelEnumSerializer;

  const BrokerContactLogDtoChannelEnum._(String name) : super(name);

  static BuiltSet<BrokerContactLogDtoChannelEnum> get values =>
      _$brokerContactLogDtoChannelEnumValues;
  static BrokerContactLogDtoChannelEnum valueOf(String name) =>
      _$brokerContactLogDtoChannelEnumValueOf(name);
}

class BrokerContactLogDtoOutcomeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'ATTEMPTED')
  static const BrokerContactLogDtoOutcomeEnum ATTEMPTED =
      _$brokerContactLogDtoOutcomeEnum_ATTEMPTED;
  @BuiltValueEnumConst(wireName: r'REACHED')
  static const BrokerContactLogDtoOutcomeEnum REACHED =
      _$brokerContactLogDtoOutcomeEnum_REACHED;
  @BuiltValueEnumConst(wireName: r'NO_ANSWER')
  static const BrokerContactLogDtoOutcomeEnum NO_ANSWER =
      _$brokerContactLogDtoOutcomeEnum_NO_ANSWER;

  static Serializer<BrokerContactLogDtoOutcomeEnum> get serializer =>
      _$brokerContactLogDtoOutcomeEnumSerializer;

  const BrokerContactLogDtoOutcomeEnum._(String name) : super(name);

  static BuiltSet<BrokerContactLogDtoOutcomeEnum> get values =>
      _$brokerContactLogDtoOutcomeEnumValues;
  static BrokerContactLogDtoOutcomeEnum valueOf(String name) =>
      _$brokerContactLogDtoOutcomeEnumValueOf(name);
}
