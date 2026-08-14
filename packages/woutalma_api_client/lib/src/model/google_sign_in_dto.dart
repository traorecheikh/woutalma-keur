//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'google_sign_in_dto.g.dart';

/// GoogleSignInDto
///
/// Properties:
/// * [idToken] - ID token returned by Google Sign-In on the device.
@BuiltValue()
abstract class GoogleSignInDto
    implements Built<GoogleSignInDto, GoogleSignInDtoBuilder> {
  /// ID token returned by Google Sign-In on the device.
  @BuiltValueField(wireName: r'idToken')
  String get idToken;

  GoogleSignInDto._();

  factory GoogleSignInDto([void updates(GoogleSignInDtoBuilder b)]) =
      _$GoogleSignInDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GoogleSignInDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GoogleSignInDto> get serializer =>
      _$GoogleSignInDtoSerializer();
}

class _$GoogleSignInDtoSerializer
    implements PrimitiveSerializer<GoogleSignInDto> {
  @override
  final Iterable<Type> types = const [GoogleSignInDto, _$GoogleSignInDto];

  @override
  final String wireName = r'GoogleSignInDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GoogleSignInDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'idToken';
    yield serializers.serialize(
      object.idToken,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GoogleSignInDto object, {
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
    required GoogleSignInDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'idToken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.idToken = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GoogleSignInDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GoogleSignInDtoBuilder();
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
