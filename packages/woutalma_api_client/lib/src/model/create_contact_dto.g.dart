// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_contact_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CreateContactDtoChannelEnum _$createContactDtoChannelEnum_CALL =
    const CreateContactDtoChannelEnum._('CALL');
const CreateContactDtoChannelEnum _$createContactDtoChannelEnum_SMS =
    const CreateContactDtoChannelEnum._('SMS');
const CreateContactDtoChannelEnum _$createContactDtoChannelEnum_WHATSAPP =
    const CreateContactDtoChannelEnum._('WHATSAPP');
const CreateContactDtoChannelEnum _$createContactDtoChannelEnum_VOICE_MESSAGE =
    const CreateContactDtoChannelEnum._('VOICE_MESSAGE');

CreateContactDtoChannelEnum _$createContactDtoChannelEnumValueOf(String name) {
  switch (name) {
    case 'CALL':
      return _$createContactDtoChannelEnum_CALL;
    case 'SMS':
      return _$createContactDtoChannelEnum_SMS;
    case 'WHATSAPP':
      return _$createContactDtoChannelEnum_WHATSAPP;
    case 'VOICE_MESSAGE':
      return _$createContactDtoChannelEnum_VOICE_MESSAGE;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CreateContactDtoChannelEnum>
    _$createContactDtoChannelEnumValues =
    BuiltSet<CreateContactDtoChannelEnum>(const <CreateContactDtoChannelEnum>[
  _$createContactDtoChannelEnum_CALL,
  _$createContactDtoChannelEnum_SMS,
  _$createContactDtoChannelEnum_WHATSAPP,
  _$createContactDtoChannelEnum_VOICE_MESSAGE,
]);

Serializer<CreateContactDtoChannelEnum>
    _$createContactDtoChannelEnumSerializer =
    _$CreateContactDtoChannelEnumSerializer();

class _$CreateContactDtoChannelEnumSerializer
    implements PrimitiveSerializer<CreateContactDtoChannelEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'CALL': 'CALL',
    'SMS': 'SMS',
    'WHATSAPP': 'WHATSAPP',
    'VOICE_MESSAGE': 'VOICE_MESSAGE',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'CALL': 'CALL',
    'SMS': 'SMS',
    'WHATSAPP': 'WHATSAPP',
    'VOICE_MESSAGE': 'VOICE_MESSAGE',
  };

  @override
  final Iterable<Type> types = const <Type>[CreateContactDtoChannelEnum];
  @override
  final String wireName = 'CreateContactDtoChannelEnum';

  @override
  Object serialize(Serializers serializers, CreateContactDtoChannelEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CreateContactDtoChannelEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CreateContactDtoChannelEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CreateContactDto extends CreateContactDto {
  @override
  final String brokerId;
  @override
  final String? propertyId;
  @override
  final CreateContactDtoChannelEnum channel;
  @override
  final String? clientRequestId;

  factory _$CreateContactDto(
          [void Function(CreateContactDtoBuilder)? updates]) =>
      (CreateContactDtoBuilder()..update(updates))._build();

  _$CreateContactDto._(
      {required this.brokerId,
      this.propertyId,
      required this.channel,
      this.clientRequestId})
      : super._();
  @override
  CreateContactDto rebuild(void Function(CreateContactDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateContactDtoBuilder toBuilder() =>
      CreateContactDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateContactDto &&
        brokerId == other.brokerId &&
        propertyId == other.propertyId &&
        channel == other.channel &&
        clientRequestId == other.clientRequestId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, brokerId.hashCode);
    _$hash = $jc(_$hash, propertyId.hashCode);
    _$hash = $jc(_$hash, channel.hashCode);
    _$hash = $jc(_$hash, clientRequestId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateContactDto')
          ..add('brokerId', brokerId)
          ..add('propertyId', propertyId)
          ..add('channel', channel)
          ..add('clientRequestId', clientRequestId))
        .toString();
  }
}

class CreateContactDtoBuilder
    implements Builder<CreateContactDto, CreateContactDtoBuilder> {
  _$CreateContactDto? _$v;

  String? _brokerId;
  String? get brokerId => _$this._brokerId;
  set brokerId(String? brokerId) => _$this._brokerId = brokerId;

  String? _propertyId;
  String? get propertyId => _$this._propertyId;
  set propertyId(String? propertyId) => _$this._propertyId = propertyId;

  CreateContactDtoChannelEnum? _channel;
  CreateContactDtoChannelEnum? get channel => _$this._channel;
  set channel(CreateContactDtoChannelEnum? channel) =>
      _$this._channel = channel;

  String? _clientRequestId;
  String? get clientRequestId => _$this._clientRequestId;
  set clientRequestId(String? clientRequestId) =>
      _$this._clientRequestId = clientRequestId;

  CreateContactDtoBuilder() {
    CreateContactDto._defaults(this);
  }

  CreateContactDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _brokerId = $v.brokerId;
      _propertyId = $v.propertyId;
      _channel = $v.channel;
      _clientRequestId = $v.clientRequestId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateContactDto other) {
    _$v = other as _$CreateContactDto;
  }

  @override
  void update(void Function(CreateContactDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateContactDto build() => _build();

  _$CreateContactDto _build() {
    final _$result = _$v ??
        _$CreateContactDto._(
          brokerId: BuiltValueNullFieldError.checkNotNull(
              brokerId, r'CreateContactDto', 'brokerId'),
          propertyId: propertyId,
          channel: BuiltValueNullFieldError.checkNotNull(
              channel, r'CreateContactDto', 'channel'),
          clientRequestId: clientRequestId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
