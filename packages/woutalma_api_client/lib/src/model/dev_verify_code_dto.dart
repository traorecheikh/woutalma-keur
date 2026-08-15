//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'dev_verify_code_dto.g.dart';

/// DevVerifyCodeDto
///
/// Properties:
/// * [phone]
/// * [code]
/// * [asBroker] - Give this account a broker profile if it has none, so the broker side is reachable without an operator. Dev auth only.
@BuiltValue()
abstract class DevVerifyCodeDto
    implements Built<DevVerifyCodeDto, DevVerifyCodeDtoBuilder> {
  @BuiltValueField(wireName: r'phone')
  String get phone;

  @BuiltValueField(wireName: r'code')
  String get code;

  /// Give this account a broker profile if it has none, so the broker side is reachable without an operator. Dev auth only.
  @BuiltValueField(wireName: r'asBroker')
  bool? get asBroker;

  DevVerifyCodeDto._();

  factory DevVerifyCodeDto([void updates(DevVerifyCodeDtoBuilder b)]) =
      _$DevVerifyCodeDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DevVerifyCodeDtoBuilder b) => b..asBroker = false;

  @BuiltValueSerializer(custom: true)
  static Serializer<DevVerifyCodeDto> get serializer =>
      _$DevVerifyCodeDtoSerializer();
}

class _$DevVerifyCodeDtoSerializer
    implements PrimitiveSerializer<DevVerifyCodeDto> {
  @override
  final Iterable<Type> types = const [DevVerifyCodeDto, _$DevVerifyCodeDto];

  @override
  final String wireName = r'DevVerifyCodeDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DevVerifyCodeDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'phone';
    yield serializers.serialize(
      object.phone,
      specifiedType: const FullType(String),
    );
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
    if (object.asBroker != null) {
      yield r'asBroker';
      yield serializers.serialize(
        object.asBroker,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    DevVerifyCodeDto object, {
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
    required DevVerifyCodeDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'phone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.phone = valueDes;
          break;
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.code = valueDes;
          break;
        case r'asBroker':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.asBroker = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DevVerifyCodeDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DevVerifyCodeDtoBuilder();
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
