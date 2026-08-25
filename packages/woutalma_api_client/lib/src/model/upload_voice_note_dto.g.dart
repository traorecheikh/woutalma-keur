// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_voice_note_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const UploadVoiceNoteDtoMimeTypeEnum
    _$uploadVoiceNoteDtoMimeTypeEnum_audioSlashMp4 =
    const UploadVoiceNoteDtoMimeTypeEnum._('audioSlashMp4');
const UploadVoiceNoteDtoMimeTypeEnum
    _$uploadVoiceNoteDtoMimeTypeEnum_audioSlashAac =
    const UploadVoiceNoteDtoMimeTypeEnum._('audioSlashAac');
const UploadVoiceNoteDtoMimeTypeEnum
    _$uploadVoiceNoteDtoMimeTypeEnum_audioSlashMpeg =
    const UploadVoiceNoteDtoMimeTypeEnum._('audioSlashMpeg');
const UploadVoiceNoteDtoMimeTypeEnum
    _$uploadVoiceNoteDtoMimeTypeEnum_audioSlashOgg =
    const UploadVoiceNoteDtoMimeTypeEnum._('audioSlashOgg');
const UploadVoiceNoteDtoMimeTypeEnum
    _$uploadVoiceNoteDtoMimeTypeEnum_audioSlashWebm =
    const UploadVoiceNoteDtoMimeTypeEnum._('audioSlashWebm');

UploadVoiceNoteDtoMimeTypeEnum _$uploadVoiceNoteDtoMimeTypeEnumValueOf(
    String name) {
  switch (name) {
    case 'audioSlashMp4':
      return _$uploadVoiceNoteDtoMimeTypeEnum_audioSlashMp4;
    case 'audioSlashAac':
      return _$uploadVoiceNoteDtoMimeTypeEnum_audioSlashAac;
    case 'audioSlashMpeg':
      return _$uploadVoiceNoteDtoMimeTypeEnum_audioSlashMpeg;
    case 'audioSlashOgg':
      return _$uploadVoiceNoteDtoMimeTypeEnum_audioSlashOgg;
    case 'audioSlashWebm':
      return _$uploadVoiceNoteDtoMimeTypeEnum_audioSlashWebm;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<UploadVoiceNoteDtoMimeTypeEnum>
    _$uploadVoiceNoteDtoMimeTypeEnumValues = BuiltSet<
        UploadVoiceNoteDtoMimeTypeEnum>(const <UploadVoiceNoteDtoMimeTypeEnum>[
  _$uploadVoiceNoteDtoMimeTypeEnum_audioSlashMp4,
  _$uploadVoiceNoteDtoMimeTypeEnum_audioSlashAac,
  _$uploadVoiceNoteDtoMimeTypeEnum_audioSlashMpeg,
  _$uploadVoiceNoteDtoMimeTypeEnum_audioSlashOgg,
  _$uploadVoiceNoteDtoMimeTypeEnum_audioSlashWebm,
]);

Serializer<UploadVoiceNoteDtoMimeTypeEnum>
    _$uploadVoiceNoteDtoMimeTypeEnumSerializer =
    _$UploadVoiceNoteDtoMimeTypeEnumSerializer();

class _$UploadVoiceNoteDtoMimeTypeEnumSerializer
    implements PrimitiveSerializer<UploadVoiceNoteDtoMimeTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'audioSlashMp4': 'audio/mp4',
    'audioSlashAac': 'audio/aac',
    'audioSlashMpeg': 'audio/mpeg',
    'audioSlashOgg': 'audio/ogg',
    'audioSlashWebm': 'audio/webm',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'audio/mp4': 'audioSlashMp4',
    'audio/aac': 'audioSlashAac',
    'audio/mpeg': 'audioSlashMpeg',
    'audio/ogg': 'audioSlashOgg',
    'audio/webm': 'audioSlashWebm',
  };

  @override
  final Iterable<Type> types = const <Type>[UploadVoiceNoteDtoMimeTypeEnum];
  @override
  final String wireName = 'UploadVoiceNoteDtoMimeTypeEnum';

  @override
  Object serialize(
          Serializers serializers, UploadVoiceNoteDtoMimeTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  UploadVoiceNoteDtoMimeTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      UploadVoiceNoteDtoMimeTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$UploadVoiceNoteDto extends UploadVoiceNoteDto {
  @override
  final UploadVoiceNoteDtoMimeTypeEnum mimeType;
  @override
  final String dataBase64;

  factory _$UploadVoiceNoteDto(
          [void Function(UploadVoiceNoteDtoBuilder)? updates]) =>
      (UploadVoiceNoteDtoBuilder()..update(updates))._build();

  _$UploadVoiceNoteDto._({required this.mimeType, required this.dataBase64})
      : super._();
  @override
  UploadVoiceNoteDto rebuild(
          void Function(UploadVoiceNoteDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UploadVoiceNoteDtoBuilder toBuilder() =>
      UploadVoiceNoteDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UploadVoiceNoteDto &&
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
    return (newBuiltValueToStringHelper(r'UploadVoiceNoteDto')
          ..add('mimeType', mimeType)
          ..add('dataBase64', dataBase64))
        .toString();
  }
}

class UploadVoiceNoteDtoBuilder
    implements Builder<UploadVoiceNoteDto, UploadVoiceNoteDtoBuilder> {
  _$UploadVoiceNoteDto? _$v;

  UploadVoiceNoteDtoMimeTypeEnum? _mimeType;
  UploadVoiceNoteDtoMimeTypeEnum? get mimeType => _$this._mimeType;
  set mimeType(UploadVoiceNoteDtoMimeTypeEnum? mimeType) =>
      _$this._mimeType = mimeType;

  String? _dataBase64;
  String? get dataBase64 => _$this._dataBase64;
  set dataBase64(String? dataBase64) => _$this._dataBase64 = dataBase64;

  UploadVoiceNoteDtoBuilder() {
    UploadVoiceNoteDto._defaults(this);
  }

  UploadVoiceNoteDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _mimeType = $v.mimeType;
      _dataBase64 = $v.dataBase64;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UploadVoiceNoteDto other) {
    _$v = other as _$UploadVoiceNoteDto;
  }

  @override
  void update(void Function(UploadVoiceNoteDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UploadVoiceNoteDto build() => _build();

  _$UploadVoiceNoteDto _build() {
    final _$result = _$v ??
        _$UploadVoiceNoteDto._(
          mimeType: BuiltValueNullFieldError.checkNotNull(
              mimeType, r'UploadVoiceNoteDto', 'mimeType'),
          dataBase64: BuiltValueNullFieldError.checkNotNull(
              dataBase64, r'UploadVoiceNoteDto', 'dataBase64'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
