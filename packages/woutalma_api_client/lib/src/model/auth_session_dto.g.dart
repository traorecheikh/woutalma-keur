// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_session_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AuthSessionDtoActiveRoleEnum _$authSessionDtoActiveRoleEnum_CLIENT =
    const AuthSessionDtoActiveRoleEnum._('CLIENT');
const AuthSessionDtoActiveRoleEnum _$authSessionDtoActiveRoleEnum_BROKER =
    const AuthSessionDtoActiveRoleEnum._('BROKER');

AuthSessionDtoActiveRoleEnum _$authSessionDtoActiveRoleEnumValueOf(
    String name) {
  switch (name) {
    case 'CLIENT':
      return _$authSessionDtoActiveRoleEnum_CLIENT;
    case 'BROKER':
      return _$authSessionDtoActiveRoleEnum_BROKER;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AuthSessionDtoActiveRoleEnum>
    _$authSessionDtoActiveRoleEnumValues =
    BuiltSet<AuthSessionDtoActiveRoleEnum>(const <AuthSessionDtoActiveRoleEnum>[
  _$authSessionDtoActiveRoleEnum_CLIENT,
  _$authSessionDtoActiveRoleEnum_BROKER,
]);

Serializer<AuthSessionDtoActiveRoleEnum>
    _$authSessionDtoActiveRoleEnumSerializer =
    _$AuthSessionDtoActiveRoleEnumSerializer();

class _$AuthSessionDtoActiveRoleEnumSerializer
    implements PrimitiveSerializer<AuthSessionDtoActiveRoleEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'CLIENT': 'CLIENT',
    'BROKER': 'BROKER',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'CLIENT': 'CLIENT',
    'BROKER': 'BROKER',
  };

  @override
  final Iterable<Type> types = const <Type>[AuthSessionDtoActiveRoleEnum];
  @override
  final String wireName = 'AuthSessionDtoActiveRoleEnum';

  @override
  Object serialize(Serializers serializers, AuthSessionDtoActiveRoleEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  AuthSessionDtoActiveRoleEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      AuthSessionDtoActiveRoleEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$AuthSessionDto extends AuthSessionDto {
  @override
  final String accessToken;
  @override
  final String refreshToken;
  @override
  final String userId;
  @override
  final AuthSessionDtoActiveRoleEnum activeRole;
  @override
  final String? brokerId;

  factory _$AuthSessionDto([void Function(AuthSessionDtoBuilder)? updates]) =>
      (AuthSessionDtoBuilder()..update(updates))._build();

  _$AuthSessionDto._(
      {required this.accessToken,
      required this.refreshToken,
      required this.userId,
      required this.activeRole,
      this.brokerId})
      : super._();
  @override
  AuthSessionDto rebuild(void Function(AuthSessionDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AuthSessionDtoBuilder toBuilder() => AuthSessionDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthSessionDto &&
        accessToken == other.accessToken &&
        refreshToken == other.refreshToken &&
        userId == other.userId &&
        activeRole == other.activeRole &&
        brokerId == other.brokerId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, accessToken.hashCode);
    _$hash = $jc(_$hash, refreshToken.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, activeRole.hashCode);
    _$hash = $jc(_$hash, brokerId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AuthSessionDto')
          ..add('accessToken', accessToken)
          ..add('refreshToken', refreshToken)
          ..add('userId', userId)
          ..add('activeRole', activeRole)
          ..add('brokerId', brokerId))
        .toString();
  }
}

class AuthSessionDtoBuilder
    implements Builder<AuthSessionDto, AuthSessionDtoBuilder> {
  _$AuthSessionDto? _$v;

  String? _accessToken;
  String? get accessToken => _$this._accessToken;
  set accessToken(String? accessToken) => _$this._accessToken = accessToken;

  String? _refreshToken;
  String? get refreshToken => _$this._refreshToken;
  set refreshToken(String? refreshToken) => _$this._refreshToken = refreshToken;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  AuthSessionDtoActiveRoleEnum? _activeRole;
  AuthSessionDtoActiveRoleEnum? get activeRole => _$this._activeRole;
  set activeRole(AuthSessionDtoActiveRoleEnum? activeRole) =>
      _$this._activeRole = activeRole;

  String? _brokerId;
  String? get brokerId => _$this._brokerId;
  set brokerId(String? brokerId) => _$this._brokerId = brokerId;

  AuthSessionDtoBuilder() {
    AuthSessionDto._defaults(this);
  }

  AuthSessionDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _accessToken = $v.accessToken;
      _refreshToken = $v.refreshToken;
      _userId = $v.userId;
      _activeRole = $v.activeRole;
      _brokerId = $v.brokerId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuthSessionDto other) {
    _$v = other as _$AuthSessionDto;
  }

  @override
  void update(void Function(AuthSessionDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthSessionDto build() => _build();

  _$AuthSessionDto _build() {
    final _$result = _$v ??
        _$AuthSessionDto._(
          accessToken: BuiltValueNullFieldError.checkNotNull(
              accessToken, r'AuthSessionDto', 'accessToken'),
          refreshToken: BuiltValueNullFieldError.checkNotNull(
              refreshToken, r'AuthSessionDto', 'refreshToken'),
          userId: BuiltValueNullFieldError.checkNotNull(
              userId, r'AuthSessionDto', 'userId'),
          activeRole: BuiltValueNullFieldError.checkNotNull(
              activeRole, r'AuthSessionDto', 'activeRole'),
          brokerId: brokerId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
