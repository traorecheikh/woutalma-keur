// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dev_request_code_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DevRequestCodeResponseDto extends DevRequestCodeResponseDto {
  @override
  final String code;
  @override
  final String phone;

  factory _$DevRequestCodeResponseDto(
          [void Function(DevRequestCodeResponseDtoBuilder)? updates]) =>
      (DevRequestCodeResponseDtoBuilder()..update(updates))._build();

  _$DevRequestCodeResponseDto._({required this.code, required this.phone})
      : super._();
  @override
  DevRequestCodeResponseDto rebuild(
          void Function(DevRequestCodeResponseDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DevRequestCodeResponseDtoBuilder toBuilder() =>
      DevRequestCodeResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DevRequestCodeResponseDto &&
        code == other.code &&
        phone == other.phone;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, phone.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DevRequestCodeResponseDto')
          ..add('code', code)
          ..add('phone', phone))
        .toString();
  }
}

class DevRequestCodeResponseDtoBuilder
    implements
        Builder<DevRequestCodeResponseDto, DevRequestCodeResponseDtoBuilder> {
  _$DevRequestCodeResponseDto? _$v;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  String? _phone;
  String? get phone => _$this._phone;
  set phone(String? phone) => _$this._phone = phone;

  DevRequestCodeResponseDtoBuilder() {
    DevRequestCodeResponseDto._defaults(this);
  }

  DevRequestCodeResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _code = $v.code;
      _phone = $v.phone;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DevRequestCodeResponseDto other) {
    _$v = other as _$DevRequestCodeResponseDto;
  }

  @override
  void update(void Function(DevRequestCodeResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DevRequestCodeResponseDto build() => _build();

  _$DevRequestCodeResponseDto _build() {
    final _$result = _$v ??
        _$DevRequestCodeResponseDto._(
          code: BuiltValueNullFieldError.checkNotNull(
              code, r'DevRequestCodeResponseDto', 'code'),
          phone: BuiltValueNullFieldError.checkNotNull(
              phone, r'DevRequestCodeResponseDto', 'phone'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
