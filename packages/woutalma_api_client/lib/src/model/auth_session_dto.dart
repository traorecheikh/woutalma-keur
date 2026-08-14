//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_session_dto.g.dart';

/// AuthSessionDto
///
/// Properties:
/// * [accessToken]
/// * [refreshToken]
/// * [userId]
/// * [activeRole]
/// * [brokerId]
@BuiltValue()
abstract class AuthSessionDto
    implements Built<AuthSessionDto, AuthSessionDtoBuilder> {
  @BuiltValueField(wireName: r'accessToken')
  String get accessToken;

  @BuiltValueField(wireName: r'refreshToken')
  String get refreshToken;

  @BuiltValueField(wireName: r'userId')
  String get userId;

  @BuiltValueField(wireName: r'activeRole')
  AuthSessionDtoActiveRoleEnum get activeRole;
  // enum activeRoleEnum {  CLIENT,  BROKER,  };

  @BuiltValueField(wireName: r'brokerId')
  String? get brokerId;

  AuthSessionDto._();

  factory AuthSessionDto([void updates(AuthSessionDtoBuilder b)]) =
      _$AuthSessionDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthSessionDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthSessionDto> get serializer =>
      _$AuthSessionDtoSerializer();
}

class _$AuthSessionDtoSerializer
    implements PrimitiveSerializer<AuthSessionDto> {
  @override
  final Iterable<Type> types = const [AuthSessionDto, _$AuthSessionDto];

  @override
  final String wireName = r'AuthSessionDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthSessionDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'accessToken';
    yield serializers.serialize(
      object.accessToken,
      specifiedType: const FullType(String),
    );
    yield r'refreshToken';
    yield serializers.serialize(
      object.refreshToken,
      specifiedType: const FullType(String),
    );
    yield r'userId';
    yield serializers.serialize(
      object.userId,
      specifiedType: const FullType(String),
    );
    yield r'activeRole';
    yield serializers.serialize(
      object.activeRole,
      specifiedType: const FullType(AuthSessionDtoActiveRoleEnum),
    );
    if (object.brokerId != null) {
      yield r'brokerId';
      yield serializers.serialize(
        object.brokerId,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AuthSessionDto object, {
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
    required AuthSessionDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'accessToken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.accessToken = valueDes;
          break;
        case r'refreshToken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.refreshToken = valueDes;
          break;
        case r'userId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.userId = valueDes;
          break;
        case r'activeRole':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AuthSessionDtoActiveRoleEnum),
          ) as AuthSessionDtoActiveRoleEnum;
          result.activeRole = valueDes;
          break;
        case r'brokerId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.brokerId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AuthSessionDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthSessionDtoBuilder();
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

class AuthSessionDtoActiveRoleEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'CLIENT')
  static const AuthSessionDtoActiveRoleEnum CLIENT =
      _$authSessionDtoActiveRoleEnum_CLIENT;
  @BuiltValueEnumConst(wireName: r'BROKER')
  static const AuthSessionDtoActiveRoleEnum BROKER =
      _$authSessionDtoActiveRoleEnum_BROKER;

  static Serializer<AuthSessionDtoActiveRoleEnum> get serializer =>
      _$authSessionDtoActiveRoleEnumSerializer;

  const AuthSessionDtoActiveRoleEnum._(String name) : super(name);

  static BuiltSet<AuthSessionDtoActiveRoleEnum> get values =>
      _$authSessionDtoActiveRoleEnumValues;
  static AuthSessionDtoActiveRoleEnum valueOf(String name) =>
      _$authSessionDtoActiveRoleEnumValueOf(name);
}
