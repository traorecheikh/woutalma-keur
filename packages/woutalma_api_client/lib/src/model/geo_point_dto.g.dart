// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geo_point_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GeoPointDto extends GeoPointDto {
  @override
  final num latitude;
  @override
  final num longitude;

  factory _$GeoPointDto([void Function(GeoPointDtoBuilder)? updates]) =>
      (GeoPointDtoBuilder()..update(updates))._build();

  _$GeoPointDto._({required this.latitude, required this.longitude})
      : super._();
  @override
  GeoPointDto rebuild(void Function(GeoPointDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GeoPointDtoBuilder toBuilder() => GeoPointDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GeoPointDto &&
        latitude == other.latitude &&
        longitude == other.longitude;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, latitude.hashCode);
    _$hash = $jc(_$hash, longitude.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GeoPointDto')
          ..add('latitude', latitude)
          ..add('longitude', longitude))
        .toString();
  }
}

class GeoPointDtoBuilder implements Builder<GeoPointDto, GeoPointDtoBuilder> {
  _$GeoPointDto? _$v;

  num? _latitude;
  num? get latitude => _$this._latitude;
  set latitude(num? latitude) => _$this._latitude = latitude;

  num? _longitude;
  num? get longitude => _$this._longitude;
  set longitude(num? longitude) => _$this._longitude = longitude;

  GeoPointDtoBuilder() {
    GeoPointDto._defaults(this);
  }

  GeoPointDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _latitude = $v.latitude;
      _longitude = $v.longitude;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GeoPointDto other) {
    _$v = other as _$GeoPointDto;
  }

  @override
  void update(void Function(GeoPointDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GeoPointDto build() => _build();

  _$GeoPointDto _build() {
    final _$result = _$v ??
        _$GeoPointDto._(
          latitude: BuiltValueNullFieldError.checkNotNull(
              latitude, r'GeoPointDto', 'latitude'),
          longitude: BuiltValueNullFieldError.checkNotNull(
              longitude, r'GeoPointDto', 'longitude'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
