//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'dev_request_code_response_dto.g.dart';

/// DevRequestCodeResponseDto
///
/// Properties:
/// * [code] - The code, returned in the response because no SMS is sent. Only ever exposed on a deployment that has explicitly enabled dev auth.
/// * [phone]
@BuiltValue()
abstract class DevRequestCodeResponseDto
    implements
        Built<DevRequestCodeResponseDto, DevRequestCodeResponseDtoBuilder> {
  /// The code, returned in the response because no SMS is sent. Only ever exposed on a deployment that has explicitly enabled dev auth.
  @BuiltValueField(wireName: r'code')
  String get code;

  @BuiltValueField(wireName: r'phone')
  String get phone;

  DevRequestCodeResponseDto._();

  factory DevRequestCodeResponseDto(
          [void updates(DevRequestCodeResponseDtoBuilder b)]) =
      _$DevRequestCodeResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DevRequestCodeResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DevRequestCodeResponseDto> get serializer =>
      _$DevRequestCodeResponseDtoSerializer();
}

class _$DevRequestCodeResponseDtoSerializer
    implements PrimitiveSerializer<DevRequestCodeResponseDto> {
  @override
  final Iterable<Type> types = const [
    DevRequestCodeResponseDto,
    _$DevRequestCodeResponseDto
  ];

  @override
  final String wireName = r'DevRequestCodeResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DevRequestCodeResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
    yield r'phone';
    yield serializers.serialize(
      object.phone,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DevRequestCodeResponseDto object, {
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
    required DevRequestCodeResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.code = valueDes;
          break;
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
  DevRequestCodeResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DevRequestCodeResponseDtoBuilder();
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
