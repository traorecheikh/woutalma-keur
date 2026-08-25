// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_property_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const UpdatePropertyDtoKindEnum _$updatePropertyDtoKindEnum_APARTMENT =
    const UpdatePropertyDtoKindEnum._('APARTMENT');
const UpdatePropertyDtoKindEnum _$updatePropertyDtoKindEnum_HOUSE =
    const UpdatePropertyDtoKindEnum._('HOUSE');
const UpdatePropertyDtoKindEnum _$updatePropertyDtoKindEnum_LAND =
    const UpdatePropertyDtoKindEnum._('LAND');
const UpdatePropertyDtoKindEnum _$updatePropertyDtoKindEnum_STUDIO =
    const UpdatePropertyDtoKindEnum._('STUDIO');
const UpdatePropertyDtoKindEnum _$updatePropertyDtoKindEnum_ROOM =
    const UpdatePropertyDtoKindEnum._('ROOM');

UpdatePropertyDtoKindEnum _$updatePropertyDtoKindEnumValueOf(String name) {
  switch (name) {
    case 'APARTMENT':
      return _$updatePropertyDtoKindEnum_APARTMENT;
    case 'HOUSE':
      return _$updatePropertyDtoKindEnum_HOUSE;
    case 'LAND':
      return _$updatePropertyDtoKindEnum_LAND;
    case 'STUDIO':
      return _$updatePropertyDtoKindEnum_STUDIO;
    case 'ROOM':
      return _$updatePropertyDtoKindEnum_ROOM;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<UpdatePropertyDtoKindEnum> _$updatePropertyDtoKindEnumValues =
    BuiltSet<UpdatePropertyDtoKindEnum>(const <UpdatePropertyDtoKindEnum>[
  _$updatePropertyDtoKindEnum_APARTMENT,
  _$updatePropertyDtoKindEnum_HOUSE,
  _$updatePropertyDtoKindEnum_LAND,
  _$updatePropertyDtoKindEnum_STUDIO,
  _$updatePropertyDtoKindEnum_ROOM,
]);

const UpdatePropertyDtoTransactionEnum _$updatePropertyDtoTransactionEnum_RENT =
    const UpdatePropertyDtoTransactionEnum._('RENT');
const UpdatePropertyDtoTransactionEnum _$updatePropertyDtoTransactionEnum_SALE =
    const UpdatePropertyDtoTransactionEnum._('SALE');

UpdatePropertyDtoTransactionEnum _$updatePropertyDtoTransactionEnumValueOf(
    String name) {
  switch (name) {
    case 'RENT':
      return _$updatePropertyDtoTransactionEnum_RENT;
    case 'SALE':
      return _$updatePropertyDtoTransactionEnum_SALE;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<UpdatePropertyDtoTransactionEnum>
    _$updatePropertyDtoTransactionEnumValues = BuiltSet<
        UpdatePropertyDtoTransactionEnum>(const <UpdatePropertyDtoTransactionEnum>[
  _$updatePropertyDtoTransactionEnum_RENT,
  _$updatePropertyDtoTransactionEnum_SALE,
]);

const UpdatePropertyDtoStatusEnum _$updatePropertyDtoStatusEnum_AVAILABLE =
    const UpdatePropertyDtoStatusEnum._('AVAILABLE');
const UpdatePropertyDtoStatusEnum _$updatePropertyDtoStatusEnum_RESERVED =
    const UpdatePropertyDtoStatusEnum._('RESERVED');
const UpdatePropertyDtoStatusEnum _$updatePropertyDtoStatusEnum_CLOSED =
    const UpdatePropertyDtoStatusEnum._('CLOSED');

UpdatePropertyDtoStatusEnum _$updatePropertyDtoStatusEnumValueOf(String name) {
  switch (name) {
    case 'AVAILABLE':
      return _$updatePropertyDtoStatusEnum_AVAILABLE;
    case 'RESERVED':
      return _$updatePropertyDtoStatusEnum_RESERVED;
    case 'CLOSED':
      return _$updatePropertyDtoStatusEnum_CLOSED;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<UpdatePropertyDtoStatusEnum>
    _$updatePropertyDtoStatusEnumValues =
    BuiltSet<UpdatePropertyDtoStatusEnum>(const <UpdatePropertyDtoStatusEnum>[
  _$updatePropertyDtoStatusEnum_AVAILABLE,
  _$updatePropertyDtoStatusEnum_RESERVED,
  _$updatePropertyDtoStatusEnum_CLOSED,
]);

Serializer<UpdatePropertyDtoKindEnum> _$updatePropertyDtoKindEnumSerializer =
    _$UpdatePropertyDtoKindEnumSerializer();
Serializer<UpdatePropertyDtoTransactionEnum>
    _$updatePropertyDtoTransactionEnumSerializer =
    _$UpdatePropertyDtoTransactionEnumSerializer();
Serializer<UpdatePropertyDtoStatusEnum>
    _$updatePropertyDtoStatusEnumSerializer =
    _$UpdatePropertyDtoStatusEnumSerializer();

class _$UpdatePropertyDtoKindEnumSerializer
    implements PrimitiveSerializer<UpdatePropertyDtoKindEnum> {
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
  final Iterable<Type> types = const <Type>[UpdatePropertyDtoKindEnum];
  @override
  final String wireName = 'UpdatePropertyDtoKindEnum';

  @override
  Object serialize(Serializers serializers, UpdatePropertyDtoKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  UpdatePropertyDtoKindEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      UpdatePropertyDtoKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$UpdatePropertyDtoTransactionEnumSerializer
    implements PrimitiveSerializer<UpdatePropertyDtoTransactionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'RENT': 'RENT',
    'SALE': 'SALE',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'RENT': 'RENT',
    'SALE': 'SALE',
  };

  @override
  final Iterable<Type> types = const <Type>[UpdatePropertyDtoTransactionEnum];
  @override
  final String wireName = 'UpdatePropertyDtoTransactionEnum';

  @override
  Object serialize(
          Serializers serializers, UpdatePropertyDtoTransactionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  UpdatePropertyDtoTransactionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      UpdatePropertyDtoTransactionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$UpdatePropertyDtoStatusEnumSerializer
    implements PrimitiveSerializer<UpdatePropertyDtoStatusEnum> {
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
  final Iterable<Type> types = const <Type>[UpdatePropertyDtoStatusEnum];
  @override
  final String wireName = 'UpdatePropertyDtoStatusEnum';

  @override
  Object serialize(Serializers serializers, UpdatePropertyDtoStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  UpdatePropertyDtoStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      UpdatePropertyDtoStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$UpdatePropertyDto extends UpdatePropertyDto {
  @override
  final UpdatePropertyDtoKindEnum? kind;
  @override
  final UpdatePropertyDtoTransactionEnum? transaction;
  @override
  final String? title;
  @override
  final String? description;
  @override
  final num? price;
  @override
  final num? surface;
  @override
  final num? rooms;
  @override
  final num? latitude;
  @override
  final num? longitude;
  @override
  final String? neighbourhood;
  @override
  final UpdatePropertyDtoStatusEnum? status;
  @override
  final BuiltList<String>? photoAssets;
  @override
  final BuiltList<UploadPhotoDto>? newPhotos;
  @override
  final String? voiceAsset;
  @override
  final UploadVoiceNoteDto? newVoiceNote;

  factory _$UpdatePropertyDto(
          [void Function(UpdatePropertyDtoBuilder)? updates]) =>
      (UpdatePropertyDtoBuilder()..update(updates))._build();

  _$UpdatePropertyDto._(
      {this.kind,
      this.transaction,
      this.title,
      this.description,
      this.price,
      this.surface,
      this.rooms,
      this.latitude,
      this.longitude,
      this.neighbourhood,
      this.status,
      this.photoAssets,
      this.newPhotos,
      this.voiceAsset,
      this.newVoiceNote})
      : super._();
  @override
  UpdatePropertyDto rebuild(void Function(UpdatePropertyDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UpdatePropertyDtoBuilder toBuilder() =>
      UpdatePropertyDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UpdatePropertyDto &&
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
    return (newBuiltValueToStringHelper(r'UpdatePropertyDto')
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

class UpdatePropertyDtoBuilder
    implements Builder<UpdatePropertyDto, UpdatePropertyDtoBuilder> {
  _$UpdatePropertyDto? _$v;

  UpdatePropertyDtoKindEnum? _kind;
  UpdatePropertyDtoKindEnum? get kind => _$this._kind;
  set kind(UpdatePropertyDtoKindEnum? kind) => _$this._kind = kind;

  UpdatePropertyDtoTransactionEnum? _transaction;
  UpdatePropertyDtoTransactionEnum? get transaction => _$this._transaction;
  set transaction(UpdatePropertyDtoTransactionEnum? transaction) =>
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

  UpdatePropertyDtoStatusEnum? _status;
  UpdatePropertyDtoStatusEnum? get status => _$this._status;
  set status(UpdatePropertyDtoStatusEnum? status) => _$this._status = status;

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

  UpdatePropertyDtoBuilder() {
    UpdatePropertyDto._defaults(this);
  }

  UpdatePropertyDtoBuilder get _$this {
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
  void replace(UpdatePropertyDto other) {
    _$v = other as _$UpdatePropertyDto;
  }

  @override
  void update(void Function(UpdatePropertyDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UpdatePropertyDto build() => _build();

  _$UpdatePropertyDto _build() {
    _$UpdatePropertyDto _$result;
    try {
      _$result = _$v ??
          _$UpdatePropertyDto._(
            kind: kind,
            transaction: transaction,
            title: title,
            description: description,
            price: price,
            surface: surface,
            rooms: rooms,
            latitude: latitude,
            longitude: longitude,
            neighbourhood: neighbourhood,
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
            r'UpdatePropertyDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
