//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:woutalma_api_client/src/model/geo_point_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'broker_dto.g.dart';

/// BrokerDto
///
/// Properties:
/// * [id]
/// * [kind]
/// * [name]
/// * [phone]
/// * [whatsapp]
/// * [position]
/// * [coverage]
/// * [logoAsset]
/// * [verification]
/// * [responseRate] - Between 0 and 1.
/// * [pinned]
/// * [isVerified]
@BuiltValue()
abstract class BrokerDto implements Built<BrokerDto, BrokerDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'kind')
  BrokerDtoKindEnum get kind;
  // enum kindEnum {  INDIVIDUAL,  AGENCY,  };

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'phone')
  String get phone;

  @BuiltValueField(wireName: r'whatsapp')
  String? get whatsapp;

  @BuiltValueField(wireName: r'position')
  GeoPointDto get position;

  @BuiltValueField(wireName: r'coverage')
  BuiltList<String> get coverage;

  @BuiltValueField(wireName: r'logoAsset')
  String? get logoAsset;

  @BuiltValueField(wireName: r'verification')
  BrokerDtoVerificationEnum get verification;
  // enum verificationEnum {  NONE,  PENDING,  VERIFIED,  REJECTED,  };

  /// Between 0 and 1.
  @BuiltValueField(wireName: r'responseRate')
  num get responseRate;

  @BuiltValueField(wireName: r'pinned')
  bool get pinned;

  @BuiltValueField(wireName: r'isVerified')
  bool get isVerified;

  BrokerDto._();

  factory BrokerDto([void updates(BrokerDtoBuilder b)]) = _$BrokerDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BrokerDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BrokerDto> get serializer => _$BrokerDtoSerializer();
}

class _$BrokerDtoSerializer implements PrimitiveSerializer<BrokerDto> {
  @override
  final Iterable<Type> types = const [BrokerDto, _$BrokerDto];

  @override
  final String wireName = r'BrokerDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BrokerDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(BrokerDtoKindEnum),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'phone';
    yield serializers.serialize(
      object.phone,
      specifiedType: const FullType(String),
    );
    if (object.whatsapp != null) {
      yield r'whatsapp';
      yield serializers.serialize(
        object.whatsapp,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'position';
    yield serializers.serialize(
      object.position,
      specifiedType: const FullType(GeoPointDto),
    );
    yield r'coverage';
    yield serializers.serialize(
      object.coverage,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    if (object.logoAsset != null) {
      yield r'logoAsset';
      yield serializers.serialize(
        object.logoAsset,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'verification';
    yield serializers.serialize(
      object.verification,
      specifiedType: const FullType(BrokerDtoVerificationEnum),
    );
    yield r'responseRate';
    yield serializers.serialize(
      object.responseRate,
      specifiedType: const FullType(num),
    );
    yield r'pinned';
    yield serializers.serialize(
      object.pinned,
      specifiedType: const FullType(bool),
    );
    yield r'isVerified';
    yield serializers.serialize(
      object.isVerified,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BrokerDto object, {
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
    required BrokerDtoBuilder result,
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
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BrokerDtoKindEnum),
          ) as BrokerDtoKindEnum;
          result.kind = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'phone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.phone = valueDes;
          break;
        case r'whatsapp':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.whatsapp = valueDes;
          break;
        case r'position':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GeoPointDto),
          ) as GeoPointDto;
          result.position.replace(valueDes);
          break;
        case r'coverage':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.coverage.replace(valueDes);
          break;
        case r'logoAsset':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.logoAsset = valueDes;
          break;
        case r'verification':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BrokerDtoVerificationEnum),
          ) as BrokerDtoVerificationEnum;
          result.verification = valueDes;
          break;
        case r'responseRate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.responseRate = valueDes;
          break;
        case r'pinned':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.pinned = valueDes;
          break;
        case r'isVerified':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isVerified = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BrokerDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BrokerDtoBuilder();
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

class BrokerDtoKindEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'INDIVIDUAL')
  static const BrokerDtoKindEnum INDIVIDUAL = _$brokerDtoKindEnum_INDIVIDUAL;
  @BuiltValueEnumConst(wireName: r'AGENCY')
  static const BrokerDtoKindEnum AGENCY = _$brokerDtoKindEnum_AGENCY;

  static Serializer<BrokerDtoKindEnum> get serializer =>
      _$brokerDtoKindEnumSerializer;

  const BrokerDtoKindEnum._(String name) : super(name);

  static BuiltSet<BrokerDtoKindEnum> get values => _$brokerDtoKindEnumValues;
  static BrokerDtoKindEnum valueOf(String name) =>
      _$brokerDtoKindEnumValueOf(name);
}

class BrokerDtoVerificationEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'NONE')
  static const BrokerDtoVerificationEnum NONE =
      _$brokerDtoVerificationEnum_NONE;
  @BuiltValueEnumConst(wireName: r'PENDING')
  static const BrokerDtoVerificationEnum PENDING =
      _$brokerDtoVerificationEnum_PENDING;
  @BuiltValueEnumConst(wireName: r'VERIFIED')
  static const BrokerDtoVerificationEnum VERIFIED =
      _$brokerDtoVerificationEnum_VERIFIED;
  @BuiltValueEnumConst(wireName: r'REJECTED')
  static const BrokerDtoVerificationEnum REJECTED =
      _$brokerDtoVerificationEnum_REJECTED;

  static Serializer<BrokerDtoVerificationEnum> get serializer =>
      _$brokerDtoVerificationEnumSerializer;

  const BrokerDtoVerificationEnum._(String name) : super(name);

  static BuiltSet<BrokerDtoVerificationEnum> get values =>
      _$brokerDtoVerificationEnumValues;
  static BrokerDtoVerificationEnum valueOf(String name) =>
      _$brokerDtoVerificationEnumValueOf(name);
}
