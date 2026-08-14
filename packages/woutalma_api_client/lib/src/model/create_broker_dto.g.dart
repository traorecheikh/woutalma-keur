// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_broker_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CreateBrokerDtoKindEnum _$createBrokerDtoKindEnum_INDIVIDUAL =
    const CreateBrokerDtoKindEnum._('INDIVIDUAL');
const CreateBrokerDtoKindEnum _$createBrokerDtoKindEnum_AGENCY =
    const CreateBrokerDtoKindEnum._('AGENCY');

CreateBrokerDtoKindEnum _$createBrokerDtoKindEnumValueOf(String name) {
  switch (name) {
    case 'INDIVIDUAL':
      return _$createBrokerDtoKindEnum_INDIVIDUAL;
    case 'AGENCY':
      return _$createBrokerDtoKindEnum_AGENCY;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CreateBrokerDtoKindEnum> _$createBrokerDtoKindEnumValues =
    BuiltSet<CreateBrokerDtoKindEnum>(const <CreateBrokerDtoKindEnum>[
  _$createBrokerDtoKindEnum_INDIVIDUAL,
  _$createBrokerDtoKindEnum_AGENCY,
]);

Serializer<CreateBrokerDtoKindEnum> _$createBrokerDtoKindEnumSerializer =
    _$CreateBrokerDtoKindEnumSerializer();

class _$CreateBrokerDtoKindEnumSerializer
    implements PrimitiveSerializer<CreateBrokerDtoKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'INDIVIDUAL': 'INDIVIDUAL',
    'AGENCY': 'AGENCY',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'INDIVIDUAL': 'INDIVIDUAL',
    'AGENCY': 'AGENCY',
  };

  @override
  final Iterable<Type> types = const <Type>[CreateBrokerDtoKindEnum];
  @override
  final String wireName = 'CreateBrokerDtoKindEnum';

  @override
  Object serialize(Serializers serializers, CreateBrokerDtoKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CreateBrokerDtoKindEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CreateBrokerDtoKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CreateBrokerDto extends CreateBrokerDto {
  @override
  final CreateBrokerDtoKindEnum kind;
  @override
  final String name;
  @override
  final String phone;
  @override
  final String? whatsapp;
  @override
  final num latitude;
  @override
  final num longitude;
  @override
  final BuiltList<String>? coverage;
  @override
  final String? logoAsset;

  factory _$CreateBrokerDto([void Function(CreateBrokerDtoBuilder)? updates]) =>
      (CreateBrokerDtoBuilder()..update(updates))._build();

  _$CreateBrokerDto._(
      {required this.kind,
      required this.name,
      required this.phone,
      this.whatsapp,
      required this.latitude,
      required this.longitude,
      this.coverage,
      this.logoAsset})
      : super._();
  @override
  CreateBrokerDto rebuild(void Function(CreateBrokerDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateBrokerDtoBuilder toBuilder() => CreateBrokerDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateBrokerDto &&
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
    return (newBuiltValueToStringHelper(r'CreateBrokerDto')
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

class CreateBrokerDtoBuilder
    implements Builder<CreateBrokerDto, CreateBrokerDtoBuilder> {
  _$CreateBrokerDto? _$v;

  CreateBrokerDtoKindEnum? _kind;
  CreateBrokerDtoKindEnum? get kind => _$this._kind;
  set kind(CreateBrokerDtoKindEnum? kind) => _$this._kind = kind;

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

  CreateBrokerDtoBuilder() {
    CreateBrokerDto._defaults(this);
  }

  CreateBrokerDtoBuilder get _$this {
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
  void replace(CreateBrokerDto other) {
    _$v = other as _$CreateBrokerDto;
  }

  @override
  void update(void Function(CreateBrokerDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateBrokerDto build() => _build();

  _$CreateBrokerDto _build() {
    _$CreateBrokerDto _$result;
    try {
      _$result = _$v ??
          _$CreateBrokerDto._(
            kind: BuiltValueNullFieldError.checkNotNull(
                kind, r'CreateBrokerDto', 'kind'),
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'CreateBrokerDto', 'name'),
            phone: BuiltValueNullFieldError.checkNotNull(
                phone, r'CreateBrokerDto', 'phone'),
            whatsapp: whatsapp,
            latitude: BuiltValueNullFieldError.checkNotNull(
                latitude, r'CreateBrokerDto', 'latitude'),
            longitude: BuiltValueNullFieldError.checkNotNull(
                longitude, r'CreateBrokerDto', 'longitude'),
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
            r'CreateBrokerDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
