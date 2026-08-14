// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'broker_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const BrokerDtoKindEnum _$brokerDtoKindEnum_INDIVIDUAL =
    const BrokerDtoKindEnum._('INDIVIDUAL');
const BrokerDtoKindEnum _$brokerDtoKindEnum_AGENCY =
    const BrokerDtoKindEnum._('AGENCY');

BrokerDtoKindEnum _$brokerDtoKindEnumValueOf(String name) {
  switch (name) {
    case 'INDIVIDUAL':
      return _$brokerDtoKindEnum_INDIVIDUAL;
    case 'AGENCY':
      return _$brokerDtoKindEnum_AGENCY;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<BrokerDtoKindEnum> _$brokerDtoKindEnumValues =
    BuiltSet<BrokerDtoKindEnum>(const <BrokerDtoKindEnum>[
  _$brokerDtoKindEnum_INDIVIDUAL,
  _$brokerDtoKindEnum_AGENCY,
]);

const BrokerDtoVerificationEnum _$brokerDtoVerificationEnum_NONE =
    const BrokerDtoVerificationEnum._('NONE');
const BrokerDtoVerificationEnum _$brokerDtoVerificationEnum_PENDING =
    const BrokerDtoVerificationEnum._('PENDING');
const BrokerDtoVerificationEnum _$brokerDtoVerificationEnum_VERIFIED =
    const BrokerDtoVerificationEnum._('VERIFIED');
const BrokerDtoVerificationEnum _$brokerDtoVerificationEnum_REJECTED =
    const BrokerDtoVerificationEnum._('REJECTED');

BrokerDtoVerificationEnum _$brokerDtoVerificationEnumValueOf(String name) {
  switch (name) {
    case 'NONE':
      return _$brokerDtoVerificationEnum_NONE;
    case 'PENDING':
      return _$brokerDtoVerificationEnum_PENDING;
    case 'VERIFIED':
      return _$brokerDtoVerificationEnum_VERIFIED;
    case 'REJECTED':
      return _$brokerDtoVerificationEnum_REJECTED;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<BrokerDtoVerificationEnum> _$brokerDtoVerificationEnumValues =
    BuiltSet<BrokerDtoVerificationEnum>(const <BrokerDtoVerificationEnum>[
  _$brokerDtoVerificationEnum_NONE,
  _$brokerDtoVerificationEnum_PENDING,
  _$brokerDtoVerificationEnum_VERIFIED,
  _$brokerDtoVerificationEnum_REJECTED,
]);

Serializer<BrokerDtoKindEnum> _$brokerDtoKindEnumSerializer =
    _$BrokerDtoKindEnumSerializer();
Serializer<BrokerDtoVerificationEnum> _$brokerDtoVerificationEnumSerializer =
    _$BrokerDtoVerificationEnumSerializer();

class _$BrokerDtoKindEnumSerializer
    implements PrimitiveSerializer<BrokerDtoKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'INDIVIDUAL': 'INDIVIDUAL',
    'AGENCY': 'AGENCY',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'INDIVIDUAL': 'INDIVIDUAL',
    'AGENCY': 'AGENCY',
  };

  @override
  final Iterable<Type> types = const <Type>[BrokerDtoKindEnum];
  @override
  final String wireName = 'BrokerDtoKindEnum';

  @override
  Object serialize(Serializers serializers, BrokerDtoKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  BrokerDtoKindEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      BrokerDtoKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$BrokerDtoVerificationEnumSerializer
    implements PrimitiveSerializer<BrokerDtoVerificationEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'NONE': 'NONE',
    'PENDING': 'PENDING',
    'VERIFIED': 'VERIFIED',
    'REJECTED': 'REJECTED',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'NONE': 'NONE',
    'PENDING': 'PENDING',
    'VERIFIED': 'VERIFIED',
    'REJECTED': 'REJECTED',
  };

  @override
  final Iterable<Type> types = const <Type>[BrokerDtoVerificationEnum];
  @override
  final String wireName = 'BrokerDtoVerificationEnum';

  @override
  Object serialize(Serializers serializers, BrokerDtoVerificationEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  BrokerDtoVerificationEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      BrokerDtoVerificationEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$BrokerDto extends BrokerDto {
  @override
  final String id;
  @override
  final BrokerDtoKindEnum kind;
  @override
  final String name;
  @override
  final String phone;
  @override
  final String? whatsapp;
  @override
  final GeoPointDto position;
  @override
  final BuiltList<String> coverage;
  @override
  final String? logoAsset;
  @override
  final BrokerDtoVerificationEnum verification;
  @override
  final num responseRate;
  @override
  final bool pinned;
  @override
  final bool isVerified;

  factory _$BrokerDto([void Function(BrokerDtoBuilder)? updates]) =>
      (BrokerDtoBuilder()..update(updates))._build();

  _$BrokerDto._(
      {required this.id,
      required this.kind,
      required this.name,
      required this.phone,
      this.whatsapp,
      required this.position,
      required this.coverage,
      this.logoAsset,
      required this.verification,
      required this.responseRate,
      required this.pinned,
      required this.isVerified})
      : super._();
  @override
  BrokerDto rebuild(void Function(BrokerDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BrokerDtoBuilder toBuilder() => BrokerDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BrokerDto &&
        id == other.id &&
        kind == other.kind &&
        name == other.name &&
        phone == other.phone &&
        whatsapp == other.whatsapp &&
        position == other.position &&
        coverage == other.coverage &&
        logoAsset == other.logoAsset &&
        verification == other.verification &&
        responseRate == other.responseRate &&
        pinned == other.pinned &&
        isVerified == other.isVerified;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, phone.hashCode);
    _$hash = $jc(_$hash, whatsapp.hashCode);
    _$hash = $jc(_$hash, position.hashCode);
    _$hash = $jc(_$hash, coverage.hashCode);
    _$hash = $jc(_$hash, logoAsset.hashCode);
    _$hash = $jc(_$hash, verification.hashCode);
    _$hash = $jc(_$hash, responseRate.hashCode);
    _$hash = $jc(_$hash, pinned.hashCode);
    _$hash = $jc(_$hash, isVerified.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BrokerDto')
          ..add('id', id)
          ..add('kind', kind)
          ..add('name', name)
          ..add('phone', phone)
          ..add('whatsapp', whatsapp)
          ..add('position', position)
          ..add('coverage', coverage)
          ..add('logoAsset', logoAsset)
          ..add('verification', verification)
          ..add('responseRate', responseRate)
          ..add('pinned', pinned)
          ..add('isVerified', isVerified))
        .toString();
  }
}

class BrokerDtoBuilder implements Builder<BrokerDto, BrokerDtoBuilder> {
  _$BrokerDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  BrokerDtoKindEnum? _kind;
  BrokerDtoKindEnum? get kind => _$this._kind;
  set kind(BrokerDtoKindEnum? kind) => _$this._kind = kind;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _phone;
  String? get phone => _$this._phone;
  set phone(String? phone) => _$this._phone = phone;

  String? _whatsapp;
  String? get whatsapp => _$this._whatsapp;
  set whatsapp(String? whatsapp) => _$this._whatsapp = whatsapp;

  GeoPointDtoBuilder? _position;
  GeoPointDtoBuilder get position => _$this._position ??= GeoPointDtoBuilder();
  set position(GeoPointDtoBuilder? position) => _$this._position = position;

  ListBuilder<String>? _coverage;
  ListBuilder<String> get coverage =>
      _$this._coverage ??= ListBuilder<String>();
  set coverage(ListBuilder<String>? coverage) => _$this._coverage = coverage;

  String? _logoAsset;
  String? get logoAsset => _$this._logoAsset;
  set logoAsset(String? logoAsset) => _$this._logoAsset = logoAsset;

  BrokerDtoVerificationEnum? _verification;
  BrokerDtoVerificationEnum? get verification => _$this._verification;
  set verification(BrokerDtoVerificationEnum? verification) =>
      _$this._verification = verification;

  num? _responseRate;
  num? get responseRate => _$this._responseRate;
  set responseRate(num? responseRate) => _$this._responseRate = responseRate;

  bool? _pinned;
  bool? get pinned => _$this._pinned;
  set pinned(bool? pinned) => _$this._pinned = pinned;

  bool? _isVerified;
  bool? get isVerified => _$this._isVerified;
  set isVerified(bool? isVerified) => _$this._isVerified = isVerified;

  BrokerDtoBuilder() {
    BrokerDto._defaults(this);
  }

  BrokerDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _kind = $v.kind;
      _name = $v.name;
      _phone = $v.phone;
      _whatsapp = $v.whatsapp;
      _position = $v.position.toBuilder();
      _coverage = $v.coverage.toBuilder();
      _logoAsset = $v.logoAsset;
      _verification = $v.verification;
      _responseRate = $v.responseRate;
      _pinned = $v.pinned;
      _isVerified = $v.isVerified;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BrokerDto other) {
    _$v = other as _$BrokerDto;
  }

  @override
  void update(void Function(BrokerDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BrokerDto build() => _build();

  _$BrokerDto _build() {
    _$BrokerDto _$result;
    try {
      _$result = _$v ??
          _$BrokerDto._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'BrokerDto', 'id'),
            kind: BuiltValueNullFieldError.checkNotNull(
                kind, r'BrokerDto', 'kind'),
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'BrokerDto', 'name'),
            phone: BuiltValueNullFieldError.checkNotNull(
                phone, r'BrokerDto', 'phone'),
            whatsapp: whatsapp,
            position: position.build(),
            coverage: coverage.build(),
            logoAsset: logoAsset,
            verification: BuiltValueNullFieldError.checkNotNull(
                verification, r'BrokerDto', 'verification'),
            responseRate: BuiltValueNullFieldError.checkNotNull(
                responseRate, r'BrokerDto', 'responseRate'),
            pinned: BuiltValueNullFieldError.checkNotNull(
                pinned, r'BrokerDto', 'pinned'),
            isVerified: BuiltValueNullFieldError.checkNotNull(
                isVerified, r'BrokerDto', 'isVerified'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'position';
        position.build();
        _$failedField = 'coverage';
        coverage.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'BrokerDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
