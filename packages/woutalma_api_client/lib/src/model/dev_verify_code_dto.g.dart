// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dev_verify_code_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DevVerifyCodeDto extends DevVerifyCodeDto {
  @override
  final String phone;
  @override
  final String code;
  @override
  final bool? asBroker;

  factory _$DevVerifyCodeDto(
          [void Function(DevVerifyCodeDtoBuilder)? updates]) =>
      (DevVerifyCodeDtoBuilder()..update(updates))._build();

  _$DevVerifyCodeDto._({required this.phone, required this.code, this.asBroker})
      : super._();
  @override
  DevVerifyCodeDto rebuild(void Function(DevVerifyCodeDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DevVerifyCodeDtoBuilder toBuilder() =>
      DevVerifyCodeDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DevVerifyCodeDto &&
        phone == other.phone &&
        code == other.code &&
        asBroker == other.asBroker;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, phone.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, asBroker.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DevVerifyCodeDto')
          ..add('phone', phone)
          ..add('code', code)
          ..add('asBroker', asBroker))
        .toString();
  }
}

class DevVerifyCodeDtoBuilder
    implements Builder<DevVerifyCodeDto, DevVerifyCodeDtoBuilder> {
  _$DevVerifyCodeDto? _$v;

  String? _phone;
  String? get phone => _$this._phone;
  set phone(String? phone) => _$this._phone = phone;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  bool? _asBroker;
  bool? get asBroker => _$this._asBroker;
  set asBroker(bool? asBroker) => _$this._asBroker = asBroker;

  DevVerifyCodeDtoBuilder() {
    DevVerifyCodeDto._defaults(this);
  }

  DevVerifyCodeDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _phone = $v.phone;
      _code = $v.code;
      _asBroker = $v.asBroker;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DevVerifyCodeDto other) {
    _$v = other as _$DevVerifyCodeDto;
  }

  @override
  void update(void Function(DevVerifyCodeDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DevVerifyCodeDto build() => _build();

  _$DevVerifyCodeDto _build() {
    final _$result = _$v ??
        _$DevVerifyCodeDto._(
          phone: BuiltValueNullFieldError.checkNotNull(
              phone, r'DevVerifyCodeDto', 'phone'),
          code: BuiltValueNullFieldError.checkNotNull(
              code, r'DevVerifyCodeDto', 'code'),
          asBroker: asBroker,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
