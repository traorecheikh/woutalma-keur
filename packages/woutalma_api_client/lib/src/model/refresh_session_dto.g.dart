// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'refresh_session_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RefreshSessionDto extends RefreshSessionDto {
  @override
  final String refreshToken;

  factory _$RefreshSessionDto(
          [void Function(RefreshSessionDtoBuilder)? updates]) =>
      (RefreshSessionDtoBuilder()..update(updates))._build();

  _$RefreshSessionDto._({required this.refreshToken}) : super._();
  @override
  RefreshSessionDto rebuild(void Function(RefreshSessionDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RefreshSessionDtoBuilder toBuilder() =>
      RefreshSessionDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RefreshSessionDto && refreshToken == other.refreshToken;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, refreshToken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RefreshSessionDto')
          ..add('refreshToken', refreshToken))
        .toString();
  }
}

class RefreshSessionDtoBuilder
    implements Builder<RefreshSessionDto, RefreshSessionDtoBuilder> {
  _$RefreshSessionDto? _$v;

  String? _refreshToken;
  String? get refreshToken => _$this._refreshToken;
  set refreshToken(String? refreshToken) => _$this._refreshToken = refreshToken;

  RefreshSessionDtoBuilder() {
    RefreshSessionDto._defaults(this);
  }

  RefreshSessionDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _refreshToken = $v.refreshToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RefreshSessionDto other) {
    _$v = other as _$RefreshSessionDto;
  }

  @override
  void update(void Function(RefreshSessionDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RefreshSessionDto build() => _build();

  _$RefreshSessionDto _build() {
    final _$result = _$v ??
        _$RefreshSessionDto._(
          refreshToken: BuiltValueNullFieldError.checkNotNull(
              refreshToken, r'RefreshSessionDto', 'refreshToken'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
