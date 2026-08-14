//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'dev_sign_in_dto.g.dart';

/// DevSignInDto
///
/// Properties:
/// * [persona] - Which seeded demo account to sign in as. Only available when the deployment sets DEV_AUTH_ENABLED=true.
@BuiltValue()
abstract class DevSignInDto
    implements Built<DevSignInDto, DevSignInDtoBuilder> {
  /// Which seeded demo account to sign in as. Only available when the deployment sets DEV_AUTH_ENABLED=true.
  @BuiltValueField(wireName: r'persona')
  DevSignInDtoPersonaEnum get persona;
  // enum personaEnum {  client,  broker,  };

  DevSignInDto._();

  factory DevSignInDto([void updates(DevSignInDtoBuilder b)]) = _$DevSignInDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DevSignInDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DevSignInDto> get serializer => _$DevSignInDtoSerializer();
}

class _$DevSignInDtoSerializer implements PrimitiveSerializer<DevSignInDto> {
  @override
  final Iterable<Type> types = const [DevSignInDto, _$DevSignInDto];

  @override
  final String wireName = r'DevSignInDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DevSignInDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'persona';
    yield serializers.serialize(
      object.persona,
      specifiedType: const FullType(DevSignInDtoPersonaEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DevSignInDto object, {
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
    required DevSignInDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'persona':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DevSignInDtoPersonaEnum),
          ) as DevSignInDtoPersonaEnum;
          result.persona = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DevSignInDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DevSignInDtoBuilder();
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

class DevSignInDtoPersonaEnum extends EnumClass {
  /// Which seeded demo account to sign in as. Only available when the deployment sets DEV_AUTH_ENABLED=true.
  @BuiltValueEnumConst(wireName: r'client')
  static const DevSignInDtoPersonaEnum client =
      _$devSignInDtoPersonaEnum_client;

  /// Which seeded demo account to sign in as. Only available when the deployment sets DEV_AUTH_ENABLED=true.
  @BuiltValueEnumConst(wireName: r'broker')
  static const DevSignInDtoPersonaEnum broker =
      _$devSignInDtoPersonaEnum_broker;

  static Serializer<DevSignInDtoPersonaEnum> get serializer =>
      _$devSignInDtoPersonaEnumSerializer;

  const DevSignInDtoPersonaEnum._(String name) : super(name);

  static BuiltSet<DevSignInDtoPersonaEnum> get values =>
      _$devSignInDtoPersonaEnumValues;
  static DevSignInDtoPersonaEnum valueOf(String name) =>
      _$devSignInDtoPersonaEnumValueOf(name);
}
