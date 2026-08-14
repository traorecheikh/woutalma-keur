// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_broker_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const UpdateBrokerDtoKindEnum _$updateBrokerDtoKindEnum_INDIVIDUAL =
    const UpdateBrokerDtoKindEnum._('INDIVIDUAL');
const UpdateBrokerDtoKindEnum _$updateBrokerDtoKindEnum_AGENCY =
    const UpdateBrokerDtoKindEnum._('AGENCY');

UpdateBrokerDtoKindEnum _$updateBrokerDtoKindEnumValueOf(String name) {
  switch (name) {
    case 'INDIVIDUAL':
      return _$updateBrokerDtoKindEnum_INDIVIDUAL;
    case 'AGENCY':
      return _$updateBrokerDtoKindEnum_AGENCY;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<UpdateBrokerDtoKindEnum> _$updateBrokerDtoKindEnumValues =
    BuiltSet<UpdateBrokerDtoKindEnum>(const <UpdateBrokerDtoKindEnum>[
  _$updateBrokerDtoKindEnum_INDIVIDUAL,
  _$updateBrokerDtoKindEnum_AGENCY,
]);

Serializer<UpdateBrokerDtoKindEnum> _$updateBrokerDtoKindEnumSerializer =
    _$UpdateBrokerDtoKindEnumSerializer();

class _$UpdateBrokerDtoKindEnumSerializer
    implements PrimitiveSerializer<UpdateBrokerDtoKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'INDIVIDUAL': 'INDIVIDUAL',
    'AGENCY': 'AGENCY',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'INDIVIDUAL': 'INDIVIDUAL',
    'AGENCY': 'AGENCY',
  };

  @override
  final Iterable<Type> types = const <Type>[UpdateBrokerDtoKindEnum];
  @override
  final String wireName = 'UpdateBrokerDtoKindEnum';

  @override
  Object serialize(Serializers serializers, UpdateBrokerDtoKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  UpdateBrokerDtoKindEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      UpdateBrokerDtoKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$UpdateBrokerDto extends UpdateBrokerDto {
  @override
  final UpdateBrokerDtoKindEnum? kind;
  @override
  final String? name;
  @override
  final String? phone;
  @override
  final String? whatsapp;
  @override
  final num? latitude;
  @override
  final num? longitude;
  @override
  final BuiltList<String>? coverage;
  @override
  final String? logoAsset;

  factory _$UpdateBrokerDto([void Function(UpdateBrokerDtoBuilder)? updates]) =>
      (UpdateBrokerDtoBuilder()..update(updates))._build();

  _$UpdateBrokerDto._(
      {this.kind,
      this.name,
      this.phone,
      this.whatsapp,
      this.latitude,
      this.longitude,
      this.coverage,
      this.logoAsset})
      : super._();
  @override
  UpdateBrokerDto rebuild(void Function(UpdateBrokerDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UpdateBrokerDtoBuilder toBuilder() => UpdateBrokerDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UpdateBrokerDto &&
        kind == other.kind &&
        name == other.name &&
        phone == other.phone &&
        whatsapp == other.whatsapp &&
        latitude == other.latitude &&
        longitude == other.longitude &&
        coverage == other.coverage &&
        logoAsset == other.logoAsset;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, phone.hashCode);
    _$hash = $jc(_$hash, whatsapp.hashCode);
    _$hash = $jc(_$hash, latitude.hashCode);
    _$hash = $jc(_$hash, longitude.hashCode);
    _$hash = $jc(_$hash, coverage.hashCode);
    _$hash = $jc(_$hash, logoAsset.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UpdateBrokerDto')
          ..add('kind', kind)
          ..add('name', name)
          ..add('phone', phone)
          ..add('whatsapp', whatsapp)
          ..add('latitude', latitude)
          ..add('longitude', longitude)
          ..add('coverage', coverage)
          ..add('logoAsset', logoAsset))
        .toString();
  }
}

class UpdateBrokerDtoBuilder
    implements Builder<UpdateBrokerDto, UpdateBrokerDtoBuilder> {
  _$UpdateBrokerDto? _$v;

  UpdateBrokerDtoKindEnum? _kind;
  UpdateBrokerDtoKindEnum? get kind => _$this._kind;
  set kind(UpdateBrokerDtoKindEnum? kind) => _$this._kind = kind;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _phone;
  String? get phone => _$this._phone;
  set phone(String? phone) => _$this._phone = phone;

  String? _whatsapp;
  String? get whatsapp => _$this._whatsapp;
  set whatsapp(String? whatsapp) => _$this._whatsapp = whatsapp;

  num? _latitude;
  num? get latitude => _$this._latitude;
  set latitude(num? latitude) => _$this._latitude = latitude;

  num? _longitude;
  num? get longitude => _$this._longitude;
  set longitude(num? longitude) => _$this._longitude = longitude;

  ListBuilder<String>? _coverage;
  ListBuilder<String> get coverage =>
      _$this._coverage ??= ListBuilder<String>();
  set coverage(ListBuilder<String>? coverage) => _$this._coverage = coverage;

  String? _logoAsset;
  String? get logoAsset => _$this._logoAsset;
  set logoAsset(String? logoAsset) => _$this._logoAsset = logoAsset;

  UpdateBrokerDtoBuilder() {
    UpdateBrokerDto._defaults(this);
  }

  UpdateBrokerDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _kind = $v.kind;
      _name = $v.name;
      _phone = $v.phone;
      _whatsapp = $v.whatsapp;
      _latitude = $v.latitude;
      _longitude = $v.longitude;
      _coverage = $v.coverage?.toBuilder();
      _logoAsset = $v.logoAsset;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UpdateBrokerDto other) {
    _$v = other as _$UpdateBrokerDto;
  }

  @override
  void update(void Function(UpdateBrokerDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UpdateBrokerDto build() => _build();

  _$UpdateBrokerDto _build() {
    _$UpdateBrokerDto _$result;
    try {
      _$result = _$v ??
          _$UpdateBrokerDto._(
            kind: kind,
            name: name,
            phone: phone,
            whatsapp: whatsapp,
            latitude: latitude,
            longitude: longitude,
            coverage: _coverage?.build(),
            logoAsset: logoAsset,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'coverage';
        _coverage?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'UpdateBrokerDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
