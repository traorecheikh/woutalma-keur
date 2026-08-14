// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dev_sign_in_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DevSignInDtoPersonaEnum _$devSignInDtoPersonaEnum_client =
    const DevSignInDtoPersonaEnum._('client');
const DevSignInDtoPersonaEnum _$devSignInDtoPersonaEnum_broker =
    const DevSignInDtoPersonaEnum._('broker');

DevSignInDtoPersonaEnum _$devSignInDtoPersonaEnumValueOf(String name) {
  switch (name) {
    case 'client':
      return _$devSignInDtoPersonaEnum_client;
    case 'broker':
      return _$devSignInDtoPersonaEnum_broker;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<DevSignInDtoPersonaEnum> _$devSignInDtoPersonaEnumValues =
    BuiltSet<DevSignInDtoPersonaEnum>(const <DevSignInDtoPersonaEnum>[
  _$devSignInDtoPersonaEnum_client,
  _$devSignInDtoPersonaEnum_broker,
]);

Serializer<DevSignInDtoPersonaEnum> _$devSignInDtoPersonaEnumSerializer =
    _$DevSignInDtoPersonaEnumSerializer();

class _$DevSignInDtoPersonaEnumSerializer
    implements PrimitiveSerializer<DevSignInDtoPersonaEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'client': 'client',
    'broker': 'broker',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'client': 'client',
    'broker': 'broker',
  };

  @override
  final Iterable<Type> types = const <Type>[DevSignInDtoPersonaEnum];
  @override
  final String wireName = 'DevSignInDtoPersonaEnum';

  @override
  Object serialize(Serializers serializers, DevSignInDtoPersonaEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  DevSignInDtoPersonaEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      DevSignInDtoPersonaEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$DevSignInDto extends DevSignInDto {
  @override
  final DevSignInDtoPersonaEnum persona;

  factory _$DevSignInDto([void Function(DevSignInDtoBuilder)? updates]) =>
      (DevSignInDtoBuilder()..update(updates))._build();

  _$DevSignInDto._({required this.persona}) : super._();
  @override
  DevSignInDto rebuild(void Function(DevSignInDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DevSignInDtoBuilder toBuilder() => DevSignInDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DevSignInDto && persona == other.persona;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, persona.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DevSignInDto')
          ..add('persona', persona))
        .toString();
  }
}

class DevSignInDtoBuilder
    implements Builder<DevSignInDto, DevSignInDtoBuilder> {
  _$DevSignInDto? _$v;

  DevSignInDtoPersonaEnum? _persona;
  DevSignInDtoPersonaEnum? get persona => _$this._persona;
  set persona(DevSignInDtoPersonaEnum? persona) => _$this._persona = persona;

  DevSignInDtoBuilder() {
    DevSignInDto._defaults(this);
  }

  DevSignInDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _persona = $v.persona;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DevSignInDto other) {
    _$v = other as _$DevSignInDto;
  }

  @override
  void update(void Function(DevSignInDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DevSignInDto build() => _build();

  _$DevSignInDto _build() {
    final _$result = _$v ??
        _$DevSignInDto._(
          persona: BuiltValueNullFieldError.checkNotNull(
              persona, r'DevSignInDto', 'persona'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
