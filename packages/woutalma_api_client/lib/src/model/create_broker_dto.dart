//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_broker_dto.g.dart';

/// CreateBrokerDto
///
/// Properties:
/// * [kind]
/// * [name]
/// * [phone]
/// * [whatsapp]
/// * [latitude]
/// * [longitude]
/// * [coverage]
/// * [logoAsset]
@BuiltValue()
abstract class CreateBrokerDto
    implements Built<CreateBrokerDto, CreateBrokerDtoBuilder> {
  @BuiltValueField(wireName: r'kind')
  CreateBrokerDtoKindEnum get kind;
  // enum kindEnum {  INDIVIDUAL,  AGENCY,  };

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'phone')
  String get phone;

  @BuiltValueField(wireName: r'whatsapp')
  String? get whatsapp;

  @BuiltValueField(wireName: r'latitude')
  num get latitude;

  @BuiltValueField(wireName: r'longitude')
  num get longitude;

  @BuiltValueField(wireName: r'coverage')
  BuiltList<String>? get coverage;

  @BuiltValueField(wireName: r'logoAsset')
  String? get logoAsset;

  CreateBrokerDto._();

  factory CreateBrokerDto([void updates(CreateBrokerDtoBuilder b)]) =
      _$CreateBrokerDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateBrokerDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateBrokerDto> get serializer =>
      _$CreateBrokerDtoSerializer();
}

class _$CreateBrokerDtoSerializer
    implements PrimitiveSerializer<CreateBrokerDto> {
  @override
  final Iterable<Type> types = const [CreateBrokerDto, _$CreateBrokerDto];

  @override
  final String wireName = r'CreateBrokerDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateBrokerDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(CreateBrokerDtoKindEnum),
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
    if (object.coverage != null) {
      yield r'coverage';
      yield serializers.serialize(
        object.coverage,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
    if (object.logoAsset != null) {
      yield r'logoAsset';
      yield serializers.serialize(
        object.logoAsset,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CreateBrokerDto object, {
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
    required CreateBrokerDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CreateBrokerDtoKindEnum),
          ) as CreateBrokerDtoKindEnum;
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
        case r'coverage':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CreateBrokerDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateBrokerDtoBuilder();
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

class CreateBrokerDtoKindEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'INDIVIDUAL')
  static const CreateBrokerDtoKindEnum INDIVIDUAL =
      _$createBrokerDtoKindEnum_INDIVIDUAL;
  @BuiltValueEnumConst(wireName: r'AGENCY')
  static const CreateBrokerDtoKindEnum AGENCY =
      _$createBrokerDtoKindEnum_AGENCY;

  static Serializer<CreateBrokerDtoKindEnum> get serializer =>
      _$createBrokerDtoKindEnumSerializer;

  const CreateBrokerDtoKindEnum._(String name) : super(name);

  static BuiltSet<CreateBrokerDtoKindEnum> get values =>
      _$createBrokerDtoKindEnumValues;
  static CreateBrokerDtoKindEnum valueOf(String name) =>
      _$createBrokerDtoKindEnumValueOf(name);
}
