//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'refresh_session_dto.g.dart';

/// RefreshSessionDto
///
/// Properties:
/// * [refreshToken] - The refreshToken from a previous AuthSessionDto.
@BuiltValue()
abstract class RefreshSessionDto
    implements Built<RefreshSessionDto, RefreshSessionDtoBuilder> {
  /// The refreshToken from a previous AuthSessionDto.
  @BuiltValueField(wireName: r'refreshToken')
  String get refreshToken;

  RefreshSessionDto._();

  factory RefreshSessionDto([void updates(RefreshSessionDtoBuilder b)]) =
      _$RefreshSessionDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RefreshSessionDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RefreshSessionDto> get serializer =>
      _$RefreshSessionDtoSerializer();
}

class _$RefreshSessionDtoSerializer
    implements PrimitiveSerializer<RefreshSessionDto> {
  @override
  final Iterable<Type> types = const [RefreshSessionDto, _$RefreshSessionDto];

  @override
  final String wireName = r'RefreshSessionDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RefreshSessionDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'refreshToken';
    yield serializers.serialize(
      object.refreshToken,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RefreshSessionDto object, {
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
    required RefreshSessionDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'refreshToken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.refreshToken = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RefreshSessionDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RefreshSessionDtoBuilder();
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
