// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_property_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CreatePropertyDtoKindEnum _$createPropertyDtoKindEnum_APARTMENT =
    const CreatePropertyDtoKindEnum._('APARTMENT');
const CreatePropertyDtoKindEnum _$createPropertyDtoKindEnum_HOUSE =
    const CreatePropertyDtoKindEnum._('HOUSE');
const CreatePropertyDtoKindEnum _$createPropertyDtoKindEnum_LAND =
    const CreatePropertyDtoKindEnum._('LAND');
const CreatePropertyDtoKindEnum _$createPropertyDtoKindEnum_STUDIO =
    const CreatePropertyDtoKindEnum._('STUDIO');
const CreatePropertyDtoKindEnum _$createPropertyDtoKindEnum_ROOM =
    const CreatePropertyDtoKindEnum._('ROOM');

CreatePropertyDtoKindEnum _$createPropertyDtoKindEnumValueOf(String name) {
  switch (name) {
    case 'APARTMENT':
      return _$createPropertyDtoKindEnum_APARTMENT;
    case 'HOUSE':
      return _$createPropertyDtoKindEnum_HOUSE;
    case 'LAND':
      return _$createPropertyDtoKindEnum_LAND;
    case 'STUDIO':
      return _$createPropertyDtoKindEnum_STUDIO;
    case 'ROOM':
      return _$createPropertyDtoKindEnum_ROOM;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CreatePropertyDtoKindEnum> _$createPropertyDtoKindEnumValues =
    BuiltSet<CreatePropertyDtoKindEnum>(const <CreatePropertyDtoKindEnum>[
  _$createPropertyDtoKindEnum_APARTMENT,
  _$createPropertyDtoKindEnum_HOUSE,
  _$createPropertyDtoKindEnum_LAND,
  _$createPropertyDtoKindEnum_STUDIO,
  _$createPropertyDtoKindEnum_ROOM,
]);

const CreatePropertyDtoTransactionEnum _$createPropertyDtoTransactionEnum_RENT =
    const CreatePropertyDtoTransactionEnum._('RENT');
const CreatePropertyDtoTransactionEnum _$createPropertyDtoTransactionEnum_SALE =
    const CreatePropertyDtoTransactionEnum._('SALE');

CreatePropertyDtoTransactionEnum _$createPropertyDtoTransactionEnumValueOf(
    String name) {
  switch (name) {
    case 'RENT':
      return _$createPropertyDtoTransactionEnum_RENT;
    case 'SALE':
      return _$createPropertyDtoTransactionEnum_SALE;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CreatePropertyDtoTransactionEnum>
    _$createPropertyDtoTransactionEnumValues = BuiltSet<
        CreatePropertyDtoTransactionEnum>(const <CreatePropertyDtoTransactionEnum>[
  _$createPropertyDtoTransactionEnum_RENT,
  _$createPropertyDtoTransactionEnum_SALE,
]);

const CreatePropertyDtoStatusEnum _$createPropertyDtoStatusEnum_AVAILABLE =
    const CreatePropertyDtoStatusEnum._('AVAILABLE');
const CreatePropertyDtoStatusEnum _$createPropertyDtoStatusEnum_RESERVED =
    const CreatePropertyDtoStatusEnum._('RESERVED');
const CreatePropertyDtoStatusEnum _$createPropertyDtoStatusEnum_CLOSED =
    const CreatePropertyDtoStatusEnum._('CLOSED');

CreatePropertyDtoStatusEnum _$createPropertyDtoStatusEnumValueOf(String name) {
  switch (name) {
    case 'AVAILABLE':
      return _$createPropertyDtoStatusEnum_AVAILABLE;
    case 'RESERVED':
      return _$createPropertyDtoStatusEnum_RESERVED;
    case 'CLOSED':
      return _$createPropertyDtoStatusEnum_CLOSED;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CreatePropertyDtoStatusEnum>
    _$createPropertyDtoStatusEnumValues =
    BuiltSet<CreatePropertyDtoStatusEnum>(const <CreatePropertyDtoStatusEnum>[
  _$createPropertyDtoStatusEnum_AVAILABLE,
  _$createPropertyDtoStatusEnum_RESERVED,
  _$createPropertyDtoStatusEnum_CLOSED,
]);

Serializer<CreatePropertyDtoKindEnum> _$createPropertyDtoKindEnumSerializer =
    _$CreatePropertyDtoKindEnumSerializer();
Serializer<CreatePropertyDtoTransactionEnum>
    _$createPropertyDtoTransactionEnumSerializer =
    _$CreatePropertyDtoTransactionEnumSerializer();
Serializer<CreatePropertyDtoStatusEnum>
    _$createPropertyDtoStatusEnumSerializer =
    _$CreatePropertyDtoStatusEnumSerializer();

class _$CreatePropertyDtoKindEnumSerializer
    implements PrimitiveSerializer<CreatePropertyDtoKindEnum> {
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
  final Iterable<Type> types = const <Type>[CreatePropertyDtoKindEnum];
  @override
  final String wireName = 'CreatePropertyDtoKindEnum';

  @override
  Object serialize(Serializers serializers, CreatePropertyDtoKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CreatePropertyDtoKindEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CreatePropertyDtoKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CreatePropertyDtoTransactionEnumSerializer
    implements PrimitiveSerializer<CreatePropertyDtoTransactionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'RENT': 'RENT',
    'SALE': 'SALE',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'RENT': 'RENT',
    'SALE': 'SALE',
  };

  @override
  final Iterable<Type> types = const <Type>[CreatePropertyDtoTransactionEnum];
  @override
  final String wireName = 'CreatePropertyDtoTransactionEnum';

  @override
  Object serialize(
          Serializers serializers, CreatePropertyDtoTransactionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CreatePropertyDtoTransactionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CreatePropertyDtoTransactionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CreatePropertyDtoStatusEnumSerializer
    implements PrimitiveSerializer<CreatePropertyDtoStatusEnum> {
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
  final Iterable<Type> types = const <Type>[CreatePropertyDtoStatusEnum];
  @override
  final String wireName = 'CreatePropertyDtoStatusEnum';

  @override
  Object serialize(Serializers serializers, CreatePropertyDtoStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CreatePropertyDtoStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CreatePropertyDtoStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CreatePropertyDto extends CreatePropertyDto {
  @override
  final CreatePropertyDtoKindEnum kind;
  @override
  final CreatePropertyDtoTransactionEnum transaction;
  @override
  final String title;
  @override
  final String? description;
  @override
  final num price;
  @override
  final num? surface;
  @override
  final num? rooms;
  @override
  final num latitude;
  @override
  final num longitude;
  @override
  final String neighbourhood;
  @override
  final CreatePropertyDtoStatusEnum? status;
  @override
  final BuiltList<String>? photoAssets;
  @override
  final BuiltList<UploadPhotoDto>? newPhotos;
  @override
  final String? voiceAsset;
  @override
  final UploadVoiceNoteDto? newVoiceNote;

  factory _$CreatePropertyDto(
          [void Function(CreatePropertyDtoBuilder)? updates]) =>
      (CreatePropertyDtoBuilder()..update(updates))._build();

  _$CreatePropertyDto._(
      {required this.kind,
      required this.transaction,
      required this.title,
      this.description,
      required this.price,
      this.surface,
      this.rooms,
      required this.latitude,
      required this.longitude,
      required this.neighbourhood,
      this.status,
      this.photoAssets,
      this.newPhotos,
      this.voiceAsset,
      this.newVoiceNote})
      : super._();
  @override
  CreatePropertyDto rebuild(void Function(CreatePropertyDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreatePropertyDtoBuilder toBuilder() =>
      CreatePropertyDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreatePropertyDto &&
        kind == other.kind &&
        transaction == other.transaction &&
        title == other.title &&
        description == other.description &&
        price == other.price &&
        surface == other.surface &&
        rooms == other.rooms &&
        latitude == other.latitude &&
        longitude == other.longitude &&
        neighbourhood == other.neighbourhood &&
        status == other.status &&
        photoAssets == other.photoAssets &&
        newPhotos == other.newPhotos &&
        voiceAsset == other.voiceAsset &&
        newVoiceNote == other.newVoiceNote;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, transaction.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, price.hashCode);
    _$hash = $jc(_$hash, surface.hashCode);
    _$hash = $jc(_$hash, rooms.hashCode);
    _$hash = $jc(_$hash, latitude.hashCode);
    _$hash = $jc(_$hash, longitude.hashCode);
    _$hash = $jc(_$hash, neighbourhood.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, photoAssets.hashCode);
    _$hash = $jc(_$hash, newPhotos.hashCode);
    _$hash = $jc(_$hash, voiceAsset.hashCode);
    _$hash = $jc(_$hash, newVoiceNote.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreatePropertyDto')
          ..add('kind', kind)
          ..add('transaction', transaction)
          ..add('title', title)
          ..add('description', description)
          ..add('price', price)
          ..add('surface', surface)
          ..add('rooms', rooms)
          ..add('latitude', latitude)
          ..add('longitude', longitude)
          ..add('neighbourhood', neighbourhood)
          ..add('status', status)
          ..add('photoAssets', photoAssets)
          ..add('newPhotos', newPhotos)
          ..add('voiceAsset', voiceAsset)
          ..add('newVoiceNote', newVoiceNote))
        .toString();
  }
}

class CreatePropertyDtoBuilder
    implements Builder<CreatePropertyDto, CreatePropertyDtoBuilder> {
  _$CreatePropertyDto? _$v;

  CreatePropertyDtoKindEnum? _kind;
  CreatePropertyDtoKindEnum? get kind => _$this._kind;
  set kind(CreatePropertyDtoKindEnum? kind) => _$this._kind = kind;

  CreatePropertyDtoTransactionEnum? _transaction;
  CreatePropertyDtoTransactionEnum? get transaction => _$this._transaction;
  set transaction(CreatePropertyDtoTransactionEnum? transaction) =>
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

  num? _latitude;
  num? get latitude => _$this._latitude;
  set latitude(num? latitude) => _$this._latitude = latitude;

  num? _longitude;
  num? get longitude => _$this._longitude;
  set longitude(num? longitude) => _$this._longitude = longitude;

  String? _neighbourhood;
  String? get neighbourhood => _$this._neighbourhood;
  set neighbourhood(String? neighbourhood) =>
      _$this._neighbourhood = neighbourhood;

  CreatePropertyDtoStatusEnum? _status;
  CreatePropertyDtoStatusEnum? get status => _$this._status;
  set status(CreatePropertyDtoStatusEnum? status) => _$this._status = status;

  ListBuilder<String>? _photoAssets;
  ListBuilder<String> get photoAssets =>
      _$this._photoAssets ??= ListBuilder<String>();
  set photoAssets(ListBuilder<String>? photoAssets) =>
      _$this._photoAssets = photoAssets;

  ListBuilder<UploadPhotoDto>? _newPhotos;
  ListBuilder<UploadPhotoDto> get newPhotos =>
      _$this._newPhotos ??= ListBuilder<UploadPhotoDto>();
  set newPhotos(ListBuilder<UploadPhotoDto>? newPhotos) =>
      _$this._newPhotos = newPhotos;

  String? _voiceAsset;
  String? get voiceAsset => _$this._voiceAsset;
  set voiceAsset(String? voiceAsset) => _$this._voiceAsset = voiceAsset;

  UploadVoiceNoteDtoBuilder? _newVoiceNote;
  UploadVoiceNoteDtoBuilder get newVoiceNote =>
      _$this._newVoiceNote ??= UploadVoiceNoteDtoBuilder();
  set newVoiceNote(UploadVoiceNoteDtoBuilder? newVoiceNote) =>
      _$this._newVoiceNote = newVoiceNote;

  CreatePropertyDtoBuilder() {
    CreatePropertyDto._defaults(this);
  }

  CreatePropertyDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _kind = $v.kind;
      _transaction = $v.transaction;
      _title = $v.title;
      _description = $v.description;
      _price = $v.price;
      _surface = $v.surface;
      _rooms = $v.rooms;
      _latitude = $v.latitude;
      _longitude = $v.longitude;
      _neighbourhood = $v.neighbourhood;
      _status = $v.status;
      _photoAssets = $v.photoAssets?.toBuilder();
      _newPhotos = $v.newPhotos?.toBuilder();
      _voiceAsset = $v.voiceAsset;
      _newVoiceNote = $v.newVoiceNote?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreatePropertyDto other) {
    _$v = other as _$CreatePropertyDto;
  }

  @override
  void update(void Function(CreatePropertyDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreatePropertyDto build() => _build();

  _$CreatePropertyDto _build() {
    _$CreatePropertyDto _$result;
    try {
      _$result = _$v ??
          _$CreatePropertyDto._(
            kind: BuiltValueNullFieldError.checkNotNull(
                kind, r'CreatePropertyDto', 'kind'),
            transaction: BuiltValueNullFieldError.checkNotNull(
                transaction, r'CreatePropertyDto', 'transaction'),
            title: BuiltValueNullFieldError.checkNotNull(
                title, r'CreatePropertyDto', 'title'),
            description: description,
            price: BuiltValueNullFieldError.checkNotNull(
                price, r'CreatePropertyDto', 'price'),
            surface: surface,
            rooms: rooms,
            latitude: BuiltValueNullFieldError.checkNotNull(
                latitude, r'CreatePropertyDto', 'latitude'),
            longitude: BuiltValueNullFieldError.checkNotNull(
                longitude, r'CreatePropertyDto', 'longitude'),
            neighbourhood: BuiltValueNullFieldError.checkNotNull(
                neighbourhood, r'CreatePropertyDto', 'neighbourhood'),
            status: status,
            photoAssets: _photoAssets?.build(),
            newPhotos: _newPhotos?.build(),
            voiceAsset: voiceAsset,
            newVoiceNote: _newVoiceNote?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'photoAssets';
        _photoAssets?.build();
        _$failedField = 'newPhotos';
        _newPhotos?.build();

        _$failedField = 'newVoiceNote';
        _newVoiceNote?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'CreatePropertyDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
