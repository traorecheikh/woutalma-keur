// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'property_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PropertyDtoKindEnum _$propertyDtoKindEnum_APARTMENT =
    const PropertyDtoKindEnum._('APARTMENT');
const PropertyDtoKindEnum _$propertyDtoKindEnum_HOUSE =
    const PropertyDtoKindEnum._('HOUSE');
const PropertyDtoKindEnum _$propertyDtoKindEnum_LAND =
    const PropertyDtoKindEnum._('LAND');
const PropertyDtoKindEnum _$propertyDtoKindEnum_STUDIO =
    const PropertyDtoKindEnum._('STUDIO');
const PropertyDtoKindEnum _$propertyDtoKindEnum_ROOM =
    const PropertyDtoKindEnum._('ROOM');

PropertyDtoKindEnum _$propertyDtoKindEnumValueOf(String name) {
  switch (name) {
    case 'APARTMENT':
      return _$propertyDtoKindEnum_APARTMENT;
    case 'HOUSE':
      return _$propertyDtoKindEnum_HOUSE;
    case 'LAND':
      return _$propertyDtoKindEnum_LAND;
    case 'STUDIO':
      return _$propertyDtoKindEnum_STUDIO;
    case 'ROOM':
      return _$propertyDtoKindEnum_ROOM;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PropertyDtoKindEnum> _$propertyDtoKindEnumValues =
    BuiltSet<PropertyDtoKindEnum>(const <PropertyDtoKindEnum>[
  _$propertyDtoKindEnum_APARTMENT,
  _$propertyDtoKindEnum_HOUSE,
  _$propertyDtoKindEnum_LAND,
  _$propertyDtoKindEnum_STUDIO,
  _$propertyDtoKindEnum_ROOM,
]);

const PropertyDtoTransactionEnum _$propertyDtoTransactionEnum_RENT =
    const PropertyDtoTransactionEnum._('RENT');
const PropertyDtoTransactionEnum _$propertyDtoTransactionEnum_SALE =
    const PropertyDtoTransactionEnum._('SALE');

PropertyDtoTransactionEnum _$propertyDtoTransactionEnumValueOf(String name) {
  switch (name) {
    case 'RENT':
      return _$propertyDtoTransactionEnum_RENT;
    case 'SALE':
      return _$propertyDtoTransactionEnum_SALE;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PropertyDtoTransactionEnum> _$propertyDtoTransactionEnumValues =
    BuiltSet<PropertyDtoTransactionEnum>(const <PropertyDtoTransactionEnum>[
  _$propertyDtoTransactionEnum_RENT,
  _$propertyDtoTransactionEnum_SALE,
]);

const PropertyDtoStatusEnum _$propertyDtoStatusEnum_AVAILABLE =
    const PropertyDtoStatusEnum._('AVAILABLE');
const PropertyDtoStatusEnum _$propertyDtoStatusEnum_RESERVED =
    const PropertyDtoStatusEnum._('RESERVED');
const PropertyDtoStatusEnum _$propertyDtoStatusEnum_CLOSED =
    const PropertyDtoStatusEnum._('CLOSED');

PropertyDtoStatusEnum _$propertyDtoStatusEnumValueOf(String name) {
  switch (name) {
    case 'AVAILABLE':
      return _$propertyDtoStatusEnum_AVAILABLE;
    case 'RESERVED':
      return _$propertyDtoStatusEnum_RESERVED;
    case 'CLOSED':
      return _$propertyDtoStatusEnum_CLOSED;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PropertyDtoStatusEnum> _$propertyDtoStatusEnumValues =
    BuiltSet<PropertyDtoStatusEnum>(const <PropertyDtoStatusEnum>[
  _$propertyDtoStatusEnum_AVAILABLE,
  _$propertyDtoStatusEnum_RESERVED,
  _$propertyDtoStatusEnum_CLOSED,
]);

Serializer<PropertyDtoKindEnum> _$propertyDtoKindEnumSerializer =
    _$PropertyDtoKindEnumSerializer();
Serializer<PropertyDtoTransactionEnum> _$propertyDtoTransactionEnumSerializer =
    _$PropertyDtoTransactionEnumSerializer();
Serializer<PropertyDtoStatusEnum> _$propertyDtoStatusEnumSerializer =
    _$PropertyDtoStatusEnumSerializer();

class _$PropertyDtoKindEnumSerializer
    implements PrimitiveSerializer<PropertyDtoKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'APARTMENT': 'APARTMENT',
    'HOUSE': 'HOUSE',
    'LAND': 'LAND',
    'STUDIO': 'STUDIO',
    'ROOM': 'ROOM',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'APARTMENT': 'APARTMENT',
    'HOUSE': 'HOUSE',
    'LAND': 'LAND',
    'STUDIO': 'STUDIO',
    'ROOM': 'ROOM',
  };

  @override
  final Iterable<Type> types = const <Type>[PropertyDtoKindEnum];
  @override
  final String wireName = 'PropertyDtoKindEnum';

  @override
  Object serialize(Serializers serializers, PropertyDtoKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PropertyDtoKindEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PropertyDtoKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PropertyDtoTransactionEnumSerializer
    implements PrimitiveSerializer<PropertyDtoTransactionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'RENT': 'RENT',
    'SALE': 'SALE',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'RENT': 'RENT',
    'SALE': 'SALE',
  };

  @override
  final Iterable<Type> types = const <Type>[PropertyDtoTransactionEnum];
  @override
  final String wireName = 'PropertyDtoTransactionEnum';

  @override
  Object serialize(Serializers serializers, PropertyDtoTransactionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PropertyDtoTransactionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PropertyDtoTransactionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PropertyDtoStatusEnumSerializer
    implements PrimitiveSerializer<PropertyDtoStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'AVAILABLE': 'AVAILABLE',
    'RESERVED': 'RESERVED',
    'CLOSED': 'CLOSED',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'AVAILABLE': 'AVAILABLE',
    'RESERVED': 'RESERVED',
    'CLOSED': 'CLOSED',
  };

  @override
  final Iterable<Type> types = const <Type>[PropertyDtoStatusEnum];
  @override
  final String wireName = 'PropertyDtoStatusEnum';

  @override
  Object serialize(Serializers serializers, PropertyDtoStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PropertyDtoStatusEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PropertyDtoStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PropertyDto extends PropertyDto {
  @override
  final String id;
  @override
  final String brokerId;
  @override
  final PropertyDtoKindEnum kind;
  @override
  final PropertyDtoTransactionEnum transaction;
  @override
  final String title;
  @override
  final String description;
  @override
  final num price;
  @override
  final num? surface;
  @override
  final num? rooms;
  @override
  final GeoPointDto position;
  @override
  final String neighbourhood;
  @override
  final BuiltList<String> photoAssets;
  @override
  final PropertyDtoStatusEnum status;
  @override
  final DateTime createdAt;
  @override
  final bool isDiscoverable;

  factory _$PropertyDto([void Function(PropertyDtoBuilder)? updates]) =>
      (PropertyDtoBuilder()..update(updates))._build();

  _$PropertyDto._(
      {required this.id,
      required this.brokerId,
      required this.kind,
      required this.transaction,
      required this.title,
      required this.description,
      required this.price,
      this.surface,
      this.rooms,
      required this.position,
      required this.neighbourhood,
      required this.photoAssets,
      required this.status,
      required this.createdAt,
      required this.isDiscoverable})
      : super._();
  @override
  PropertyDto rebuild(void Function(PropertyDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PropertyDtoBuilder toBuilder() => PropertyDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PropertyDto &&
        id == other.id &&
        brokerId == other.brokerId &&
        kind == other.kind &&
        transaction == other.transaction &&
        title == other.title &&
        description == other.description &&
        price == other.price &&
        surface == other.surface &&
        rooms == other.rooms &&
        position == other.position &&
        neighbourhood == other.neighbourhood &&
        photoAssets == other.photoAssets &&
        status == other.status &&
        createdAt == other.createdAt &&
        isDiscoverable == other.isDiscoverable;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, brokerId.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, transaction.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, price.hashCode);
    _$hash = $jc(_$hash, surface.hashCode);
    _$hash = $jc(_$hash, rooms.hashCode);
    _$hash = $jc(_$hash, position.hashCode);
    _$hash = $jc(_$hash, neighbourhood.hashCode);
    _$hash = $jc(_$hash, photoAssets.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, isDiscoverable.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PropertyDto')
          ..add('id', id)
          ..add('brokerId', brokerId)
          ..add('kind', kind)
          ..add('transaction', transaction)
          ..add('title', title)
          ..add('description', description)
          ..add('price', price)
          ..add('surface', surface)
          ..add('rooms', rooms)
          ..add('position', position)
          ..add('neighbourhood', neighbourhood)
          ..add('photoAssets', photoAssets)
          ..add('status', status)
          ..add('createdAt', createdAt)
          ..add('isDiscoverable', isDiscoverable))
        .toString();
  }
}

class PropertyDtoBuilder implements Builder<PropertyDto, PropertyDtoBuilder> {
  _$PropertyDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _brokerId;
  String? get brokerId => _$this._brokerId;
  set brokerId(String? brokerId) => _$this._brokerId = brokerId;

  PropertyDtoKindEnum? _kind;
  PropertyDtoKindEnum? get kind => _$this._kind;
  set kind(PropertyDtoKindEnum? kind) => _$this._kind = kind;

  PropertyDtoTransactionEnum? _transaction;
  PropertyDtoTransactionEnum? get transaction => _$this._transaction;
  set transaction(PropertyDtoTransactionEnum? transaction) =>
      _$this._transaction = transaction;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  num? _price;
  num? get price => _$this._price;
  set price(num? price) => _$this._price = price;

  num? _surface;
  num? get surface => _$this._surface;
  set surface(num? surface) => _$this._surface = surface;

  num? _rooms;
  num? get rooms => _$this._rooms;
  set rooms(num? rooms) => _$this._rooms = rooms;

  GeoPointDtoBuilder? _position;
  GeoPointDtoBuilder get position => _$this._position ??= GeoPointDtoBuilder();
  set position(GeoPointDtoBuilder? position) => _$this._position = position;

  String? _neighbourhood;
  String? get neighbourhood => _$this._neighbourhood;
  set neighbourhood(String? neighbourhood) =>
      _$this._neighbourhood = neighbourhood;

  ListBuilder<String>? _photoAssets;
  ListBuilder<String> get photoAssets =>
      _$this._photoAssets ??= ListBuilder<String>();
  set photoAssets(ListBuilder<String>? photoAssets) =>
      _$this._photoAssets = photoAssets;

  PropertyDtoStatusEnum? _status;
  PropertyDtoStatusEnum? get status => _$this._status;
  set status(PropertyDtoStatusEnum? status) => _$this._status = status;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  bool? _isDiscoverable;
  bool? get isDiscoverable => _$this._isDiscoverable;
  set isDiscoverable(bool? isDiscoverable) =>
      _$this._isDiscoverable = isDiscoverable;

  PropertyDtoBuilder() {
    PropertyDto._defaults(this);
  }

  PropertyDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _brokerId = $v.brokerId;
      _kind = $v.kind;
      _transaction = $v.transaction;
      _title = $v.title;
      _description = $v.description;
      _price = $v.price;
      _surface = $v.surface;
      _rooms = $v.rooms;
      _position = $v.position.toBuilder();
      _neighbourhood = $v.neighbourhood;
      _photoAssets = $v.photoAssets.toBuilder();
      _status = $v.status;
      _createdAt = $v.createdAt;
      _isDiscoverable = $v.isDiscoverable;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PropertyDto other) {
    _$v = other as _$PropertyDto;
  }

  @override
  void update(void Function(PropertyDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PropertyDto build() => _build();

  _$PropertyDto _build() {
    _$PropertyDto _$result;
    try {
      _$result = _$v ??
          _$PropertyDto._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'PropertyDto', 'id'),
            brokerId: BuiltValueNullFieldError.checkNotNull(
                brokerId, r'PropertyDto', 'brokerId'),
            kind: BuiltValueNullFieldError.checkNotNull(
                kind, r'PropertyDto', 'kind'),
            transaction: BuiltValueNullFieldError.checkNotNull(
                transaction, r'PropertyDto', 'transaction'),
            title: BuiltValueNullFieldError.checkNotNull(
                title, r'PropertyDto', 'title'),
            description: BuiltValueNullFieldError.checkNotNull(
                description, r'PropertyDto', 'description'),
            price: BuiltValueNullFieldError.checkNotNull(
                price, r'PropertyDto', 'price'),
            surface: surface,
            rooms: rooms,
            position: position.build(),
            neighbourhood: BuiltValueNullFieldError.checkNotNull(
                neighbourhood, r'PropertyDto', 'neighbourhood'),
            photoAssets: photoAssets.build(),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'PropertyDto', 'status'),
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'PropertyDto', 'createdAt'),
            isDiscoverable: BuiltValueNullFieldError.checkNotNull(
                isDiscoverable, r'PropertyDto', 'isDiscoverable'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'position';
        position.build();

        _$failedField = 'photoAssets';
        photoAssets.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PropertyDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
