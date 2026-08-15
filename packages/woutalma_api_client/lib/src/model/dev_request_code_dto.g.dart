// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dev_request_code_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DevRequestCodeDto extends DevRequestCodeDto {
  @override
  final String phone;

  factory _$DevRequestCodeDto(
          [void Function(DevRequestCodeDtoBuilder)? updates]) =>
      (DevRequestCodeDtoBuilder()..update(updates))._build();

  _$DevRequestCodeDto._({required this.phone}) : super._();
  @override
  DevRequestCodeDto rebuild(void Function(DevRequestCodeDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DevRequestCodeDtoBuilder toBuilder() =>
      DevRequestCodeDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DevRequestCodeDto && phone == other.phone;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, phone.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DevRequestCodeDto')
          ..add('phone', phone))
        .toString();
  }
}

class DevRequestCodeDtoBuilder
    implements Builder<DevRequestCodeDto, DevRequestCodeDtoBuilder> {
  _$DevRequestCodeDto? _$v;

  String? _phone;
  String? get phone => _$this._phone;
  set phone(String? phone) => _$this._phone = phone;

  DevRequestCodeDtoBuilder() {
    DevRequestCodeDto._defaults(this);
  }

  DevRequestCodeDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _phone = $v.phone;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DevRequestCodeDto other) {
    _$v = other as _$DevRequestCodeDto;
  }

  @override
  void update(void Function(DevRequestCodeDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DevRequestCodeDto build() => _build();

  _$DevRequestCodeDto _build() {
    final _$result = _$v ??
        _$DevRequestCodeDto._(
          phone: BuiltValueNullFieldError.checkNotNull(
              phone, r'DevRequestCodeDto', 'phone'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
