// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'google_sign_in_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GoogleSignInDto extends GoogleSignInDto {
  @override
  final String idToken;

  factory _$GoogleSignInDto([void Function(GoogleSignInDtoBuilder)? updates]) =>
      (GoogleSignInDtoBuilder()..update(updates))._build();

  _$GoogleSignInDto._({required this.idToken}) : super._();
  @override
  GoogleSignInDto rebuild(void Function(GoogleSignInDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GoogleSignInDtoBuilder toBuilder() => GoogleSignInDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GoogleSignInDto && idToken == other.idToken;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, idToken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GoogleSignInDto')
          ..add('idToken', idToken))
        .toString();
  }
}

class GoogleSignInDtoBuilder
    implements Builder<GoogleSignInDto, GoogleSignInDtoBuilder> {
  _$GoogleSignInDto? _$v;

  String? _idToken;
  String? get idToken => _$this._idToken;
  set idToken(String? idToken) => _$this._idToken = idToken;

  GoogleSignInDtoBuilder() {
    GoogleSignInDto._defaults(this);
  }

  GoogleSignInDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _idToken = $v.idToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GoogleSignInDto other) {
    _$v = other as _$GoogleSignInDto;
  }

  @override
  void update(void Function(GoogleSignInDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GoogleSignInDto build() => _build();

  _$GoogleSignInDto _build() {
    final _$result = _$v ??
        _$GoogleSignInDto._(
          idToken: BuiltValueNullFieldError.checkNotNull(
              idToken, r'GoogleSignInDto', 'idToken'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
