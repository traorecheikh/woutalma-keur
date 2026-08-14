//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'update_broker_dto.g.dart';

/// UpdateBrokerDto
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
abstract class UpdateBrokerDto
    implements Built<UpdateBrokerDto, UpdateBrokerDtoBuilder> {
  @BuiltValueField(wireName: r'kind')
  UpdateBrokerDtoKindEnum? get kind;
  // enum kindEnum {  INDIVIDUAL,  AGENCY,  };

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'phone')
  String? get phone;

  @BuiltValueField(wireName: r'whatsapp')
  String? get whatsapp;

  @BuiltValueField(wireName: r'latitude')
  num? get latitude;

  @BuiltValueField(wireName: r'longitude')
  num? get longitude;

  @BuiltValueField(wireName: r'coverage')
  BuiltList<String>? get coverage;

  @BuiltValueField(wireName: r'logoAsset')
  String? get logoAsset;

  UpdateBrokerDto._();

  factory UpdateBrokerDto([void updates(UpdateBrokerDtoBuilder b)]) =
      _$UpdateBrokerDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UpdateBrokerDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UpdateBrokerDto> get serializer =>
      _$UpdateBrokerDtoSerializer();
}

class _$UpdateBrokerDtoSerializer
    implements PrimitiveSerializer<UpdateBrokerDto> {
  @override
  final Iterable<Type> types = const [UpdateBrokerDto, _$UpdateBrokerDto];

  @override
  final String wireName = r'UpdateBrokerDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UpdateBrokerDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.kind != null) {
      yield r'kind';
      yield serializers.serialize(
        object.kind,
        specifiedType: const FullType(UpdateBrokerDtoKindEnum),
      );
    }
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
    if (object.phone != null) {
      yield r'phone';
      yield serializers.serialize(
        object.phone,
        specifiedType: const FullType(String),
      );
    }
    if (object.whatsapp != null) {
      yield r'whatsapp';
      yield serializers.serialize(
        object.whatsapp,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.latitude != null) {
      yield r'latitude';
      yield serializers.serialize(
        object.latitude,
        specifiedType: const FullType(num),
      );
    }
    if (object.longitude != null) {
      yield r'longitude';
      yield serializers.serialize(
        object.longitude,
        specifiedType: const FullType(num),
      );
    }
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
    UpdateBrokerDto object, {
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
    required UpdateBrokerDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(UpdateBrokerDtoKindEnum),
          ) as UpdateBrokerDtoKindEnum?;
          if (valueDes == null) continue;
          result.kind = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.name = valueDes;
          break;
        case r'phone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
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
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.latitude = valueDes;
          break;
        case r'longitude':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
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
  UpdateBrokerDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UpdateBrokerDtoBuilder();
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

class UpdateBrokerDtoKindEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'INDIVIDUAL')
  static const UpdateBrokerDtoKindEnum INDIVIDUAL =
      _$updateBrokerDtoKindEnum_INDIVIDUAL;
  @BuiltValueEnumConst(wireName: r'AGENCY')
  static const UpdateBrokerDtoKindEnum AGENCY =
      _$updateBrokerDtoKindEnum_AGENCY;

  static Serializer<UpdateBrokerDtoKindEnum> get serializer =>
      _$updateBrokerDtoKindEnumSerializer;

  const UpdateBrokerDtoKindEnum._(String name) : super(name);

  static BuiltSet<UpdateBrokerDtoKindEnum> get values =>
      _$updateBrokerDtoKindEnumValues;
  static UpdateBrokerDtoKindEnum valueOf(String name) =>
      _$updateBrokerDtoKindEnumValueOf(name);
}
