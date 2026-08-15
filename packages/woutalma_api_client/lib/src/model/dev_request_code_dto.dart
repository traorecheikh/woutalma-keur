//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'dev_request_code_dto.g.dart';

/// DevRequestCodeDto
///
/// Properties:
/// * [phone]
@BuiltValue()
abstract class DevRequestCodeDto
    implements Built<DevRequestCodeDto, DevRequestCodeDtoBuilder> {
  @BuiltValueField(wireName: r'phone')
  String get phone;

  DevRequestCodeDto._();

  factory DevRequestCodeDto([void updates(DevRequestCodeDtoBuilder b)]) =
      _$DevRequestCodeDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DevRequestCodeDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DevRequestCodeDto> get serializer =>
      _$DevRequestCodeDtoSerializer();
}

class _$DevRequestCodeDtoSerializer
    implements PrimitiveSerializer<DevRequestCodeDto> {
  @override
  final Iterable<Type> types = const [DevRequestCodeDto, _$DevRequestCodeDto];

  @override
  final String wireName = r'DevRequestCodeDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DevRequestCodeDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'phone';
    yield serializers.serialize(
      object.phone,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DevRequestCodeDto object, {
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
    required DevRequestCodeDtoBuilder result,
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DevRequestCodeDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DevRequestCodeDtoBuilder();
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
