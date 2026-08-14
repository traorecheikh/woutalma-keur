// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_photo_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const UploadPhotoDtoMimeTypeEnum _$uploadPhotoDtoMimeTypeEnum_imageSlashJpeg =
    const UploadPhotoDtoMimeTypeEnum._('imageSlashJpeg');
const UploadPhotoDtoMimeTypeEnum _$uploadPhotoDtoMimeTypeEnum_imageSlashPng =
    const UploadPhotoDtoMimeTypeEnum._('imageSlashPng');
const UploadPhotoDtoMimeTypeEnum _$uploadPhotoDtoMimeTypeEnum_imageSlashWebp =
    const UploadPhotoDtoMimeTypeEnum._('imageSlashWebp');

UploadPhotoDtoMimeTypeEnum _$uploadPhotoDtoMimeTypeEnumValueOf(String name) {
  switch (name) {
    case 'imageSlashJpeg':
      return _$uploadPhotoDtoMimeTypeEnum_imageSlashJpeg;
    case 'imageSlashPng':
      return _$uploadPhotoDtoMimeTypeEnum_imageSlashPng;
    case 'imageSlashWebp':
      return _$uploadPhotoDtoMimeTypeEnum_imageSlashWebp;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<UploadPhotoDtoMimeTypeEnum> _$uploadPhotoDtoMimeTypeEnumValues =
    BuiltSet<UploadPhotoDtoMimeTypeEnum>(const <UploadPhotoDtoMimeTypeEnum>[
  _$uploadPhotoDtoMimeTypeEnum_imageSlashJpeg,
  _$uploadPhotoDtoMimeTypeEnum_imageSlashPng,
  _$uploadPhotoDtoMimeTypeEnum_imageSlashWebp,
]);

Serializer<UploadPhotoDtoMimeTypeEnum> _$uploadPhotoDtoMimeTypeEnumSerializer =
    _$UploadPhotoDtoMimeTypeEnumSerializer();

class _$UploadPhotoDtoMimeTypeEnumSerializer
    implements PrimitiveSerializer<UploadPhotoDtoMimeTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'imageSlashJpeg': 'image/jpeg',
    'imageSlashPng': 'image/png',
    'imageSlashWebp': 'image/webp',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'image/jpeg': 'imageSlashJpeg',
    'image/png': 'imageSlashPng',
    'image/webp': 'imageSlashWebp',
  };

  @override
  final Iterable<Type> types = const <Type>[UploadPhotoDtoMimeTypeEnum];
  @override
  final String wireName = 'UploadPhotoDtoMimeTypeEnum';

  @override
  Object serialize(Serializers serializers, UploadPhotoDtoMimeTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  UploadPhotoDtoMimeTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      UploadPhotoDtoMimeTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$UploadPhotoDto extends UploadPhotoDto {
  @override
  final UploadPhotoDtoMimeTypeEnum mimeType;
  @override
  final String dataBase64;

  factory _$UploadPhotoDto([void Function(UploadPhotoDtoBuilder)? updates]) =>
      (UploadPhotoDtoBuilder()..update(updates))._build();

  _$UploadPhotoDto._({required this.mimeType, required this.dataBase64})
      : super._();
  @override
  UploadPhotoDto rebuild(void Function(UploadPhotoDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UploadPhotoDtoBuilder toBuilder() => UploadPhotoDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UploadPhotoDto &&
        mimeType == other.mimeType &&
        dataBase64 == other.dataBase64;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, mimeType.hashCode);
    _$hash = $jc(_$hash, dataBase64.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UploadPhotoDto')
          ..add('mimeType', mimeType)
          ..add('dataBase64', dataBase64))
        .toString();
  }
}

class UploadPhotoDtoBuilder
    implements Builder<UploadPhotoDto, UploadPhotoDtoBuilder> {
  _$UploadPhotoDto? _$v;

  UploadPhotoDtoMimeTypeEnum? _mimeType;
  UploadPhotoDtoMimeTypeEnum? get mimeType => _$this._mimeType;
  set mimeType(UploadPhotoDtoMimeTypeEnum? mimeType) =>
      _$this._mimeType = mimeType;

  String? _dataBase64;
  String? get dataBase64 => _$this._dataBase64;
  set dataBase64(String? dataBase64) => _$this._dataBase64 = dataBase64;

  UploadPhotoDtoBuilder() {
    UploadPhotoDto._defaults(this);
  }

  UploadPhotoDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _mimeType = $v.mimeType;
      _dataBase64 = $v.dataBase64;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UploadPhotoDto other) {
    _$v = other as _$UploadPhotoDto;
  }

  @override
  void update(void Function(UploadPhotoDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UploadPhotoDto build() => _build();

  _$UploadPhotoDto _build() {
    final _$result = _$v ??
        _$UploadPhotoDto._(
          mimeType: BuiltValueNullFieldError.checkNotNull(
              mimeType, r'UploadPhotoDto', 'mimeType'),
          dataBase64: BuiltValueNullFieldError.checkNotNull(
              dataBase64, r'UploadPhotoDto', 'dataBase64'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
