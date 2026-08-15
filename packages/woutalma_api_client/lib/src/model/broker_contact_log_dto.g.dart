// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'broker_contact_log_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const BrokerContactLogDtoChannelEnum _$brokerContactLogDtoChannelEnum_CALL =
    const BrokerContactLogDtoChannelEnum._('CALL');
const BrokerContactLogDtoChannelEnum _$brokerContactLogDtoChannelEnum_SMS =
    const BrokerContactLogDtoChannelEnum._('SMS');
const BrokerContactLogDtoChannelEnum _$brokerContactLogDtoChannelEnum_WHATSAPP =
    const BrokerContactLogDtoChannelEnum._('WHATSAPP');
const BrokerContactLogDtoChannelEnum
    _$brokerContactLogDtoChannelEnum_VOICE_MESSAGE =
    const BrokerContactLogDtoChannelEnum._('VOICE_MESSAGE');

BrokerContactLogDtoChannelEnum _$brokerContactLogDtoChannelEnumValueOf(
    String name) {
  switch (name) {
    case 'CALL':
      return _$brokerContactLogDtoChannelEnum_CALL;
    case 'SMS':
      return _$brokerContactLogDtoChannelEnum_SMS;
    case 'WHATSAPP':
      return _$brokerContactLogDtoChannelEnum_WHATSAPP;
    case 'VOICE_MESSAGE':
      return _$brokerContactLogDtoChannelEnum_VOICE_MESSAGE;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<BrokerContactLogDtoChannelEnum>
    _$brokerContactLogDtoChannelEnumValues = BuiltSet<
        BrokerContactLogDtoChannelEnum>(const <BrokerContactLogDtoChannelEnum>[
  _$brokerContactLogDtoChannelEnum_CALL,
  _$brokerContactLogDtoChannelEnum_SMS,
  _$brokerContactLogDtoChannelEnum_WHATSAPP,
  _$brokerContactLogDtoChannelEnum_VOICE_MESSAGE,
]);

const BrokerContactLogDtoOutcomeEnum
    _$brokerContactLogDtoOutcomeEnum_ATTEMPTED =
    const BrokerContactLogDtoOutcomeEnum._('ATTEMPTED');
const BrokerContactLogDtoOutcomeEnum _$brokerContactLogDtoOutcomeEnum_REACHED =
    const BrokerContactLogDtoOutcomeEnum._('REACHED');
const BrokerContactLogDtoOutcomeEnum
    _$brokerContactLogDtoOutcomeEnum_NO_ANSWER =
    const BrokerContactLogDtoOutcomeEnum._('NO_ANSWER');

BrokerContactLogDtoOutcomeEnum _$brokerContactLogDtoOutcomeEnumValueOf(
    String name) {
  switch (name) {
    case 'ATTEMPTED':
      return _$brokerContactLogDtoOutcomeEnum_ATTEMPTED;
    case 'REACHED':
      return _$brokerContactLogDtoOutcomeEnum_REACHED;
    case 'NO_ANSWER':
      return _$brokerContactLogDtoOutcomeEnum_NO_ANSWER;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<BrokerContactLogDtoOutcomeEnum>
    _$brokerContactLogDtoOutcomeEnumValues = BuiltSet<
        BrokerContactLogDtoOutcomeEnum>(const <BrokerContactLogDtoOutcomeEnum>[
  _$brokerContactLogDtoOutcomeEnum_ATTEMPTED,
  _$brokerContactLogDtoOutcomeEnum_REACHED,
  _$brokerContactLogDtoOutcomeEnum_NO_ANSWER,
]);

Serializer<BrokerContactLogDtoChannelEnum>
    _$brokerContactLogDtoChannelEnumSerializer =
    _$BrokerContactLogDtoChannelEnumSerializer();
Serializer<BrokerContactLogDtoOutcomeEnum>
    _$brokerContactLogDtoOutcomeEnumSerializer =
    _$BrokerContactLogDtoOutcomeEnumSerializer();

class _$BrokerContactLogDtoChannelEnumSerializer
    implements PrimitiveSerializer<BrokerContactLogDtoChannelEnum> {
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
  final Iterable<Type> types = const <Type>[BrokerContactLogDtoChannelEnum];
  @override
  final String wireName = 'BrokerContactLogDtoChannelEnum';

  @override
  Object serialize(
          Serializers serializers, BrokerContactLogDtoChannelEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  BrokerContactLogDtoChannelEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      BrokerContactLogDtoChannelEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$BrokerContactLogDtoOutcomeEnumSerializer
    implements PrimitiveSerializer<BrokerContactLogDtoOutcomeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ATTEMPTED': 'ATTEMPTED',
    'REACHED': 'REACHED',
    'NO_ANSWER': 'NO_ANSWER',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ATTEMPTED': 'ATTEMPTED',
    'REACHED': 'REACHED',
    'NO_ANSWER': 'NO_ANSWER',
  };

  @override
  final Iterable<Type> types = const <Type>[BrokerContactLogDtoOutcomeEnum];
  @override
  final String wireName = 'BrokerContactLogDtoOutcomeEnum';

  @override
  Object serialize(
          Serializers serializers, BrokerContactLogDtoOutcomeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  BrokerContactLogDtoOutcomeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      BrokerContactLogDtoOutcomeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$BrokerContactLogDto extends BrokerContactLogDto {
  @override
  final String id;
  @override
  final String brokerId;
  @override
  final String? propertyId;
  @override
  final BrokerContactLogDtoChannelEnum channel;
  @override
  final BrokerContactLogDtoOutcomeEnum outcome;
  @override
  final bool hasReview;
  @override
  final DateTime createdAt;

  factory _$BrokerContactLogDto(
          [void Function(BrokerContactLogDtoBuilder)? updates]) =>
      (BrokerContactLogDtoBuilder()..update(updates))._build();

  _$BrokerContactLogDto._(
      {required this.id,
      required this.brokerId,
      this.propertyId,
      required this.channel,
      required this.outcome,
      required this.hasReview,
      required this.createdAt})
      : super._();
  @override
  BrokerContactLogDto rebuild(
          void Function(BrokerContactLogDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BrokerContactLogDtoBuilder toBuilder() =>
      BrokerContactLogDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BrokerContactLogDto &&
        id == other.id &&
        brokerId == other.brokerId &&
        propertyId == other.propertyId &&
        channel == other.channel &&
        outcome == other.outcome &&
        hasReview == other.hasReview &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, brokerId.hashCode);
    _$hash = $jc(_$hash, propertyId.hashCode);
    _$hash = $jc(_$hash, channel.hashCode);
    _$hash = $jc(_$hash, outcome.hashCode);
    _$hash = $jc(_$hash, hasReview.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BrokerContactLogDto')
          ..add('id', id)
          ..add('brokerId', brokerId)
          ..add('propertyId', propertyId)
          ..add('channel', channel)
          ..add('outcome', outcome)
          ..add('hasReview', hasReview)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class BrokerContactLogDtoBuilder
    implements Builder<BrokerContactLogDto, BrokerContactLogDtoBuilder> {
  _$BrokerContactLogDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _brokerId;
  String? get brokerId => _$this._brokerId;
  set brokerId(String? brokerId) => _$this._brokerId = brokerId;

  String? _propertyId;
  String? get propertyId => _$this._propertyId;
  set propertyId(String? propertyId) => _$this._propertyId = propertyId;

  BrokerContactLogDtoChannelEnum? _channel;
  BrokerContactLogDtoChannelEnum? get channel => _$this._channel;
  set channel(BrokerContactLogDtoChannelEnum? channel) =>
      _$this._channel = channel;

  BrokerContactLogDtoOutcomeEnum? _outcome;
  BrokerContactLogDtoOutcomeEnum? get outcome => _$this._outcome;
  set outcome(BrokerContactLogDtoOutcomeEnum? outcome) =>
      _$this._outcome = outcome;

  bool? _hasReview;
  bool? get hasReview => _$this._hasReview;
  set hasReview(bool? hasReview) => _$this._hasReview = hasReview;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  BrokerContactLogDtoBuilder() {
    BrokerContactLogDto._defaults(this);
  }

  BrokerContactLogDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _brokerId = $v.brokerId;
      _propertyId = $v.propertyId;
      _channel = $v.channel;
      _outcome = $v.outcome;
      _hasReview = $v.hasReview;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BrokerContactLogDto other) {
    _$v = other as _$BrokerContactLogDto;
  }

  @override
  void update(void Function(BrokerContactLogDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BrokerContactLogDto build() => _build();

  _$BrokerContactLogDto _build() {
    final _$result = _$v ??
        _$BrokerContactLogDto._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'BrokerContactLogDto', 'id'),
          brokerId: BuiltValueNullFieldError.checkNotNull(
              brokerId, r'BrokerContactLogDto', 'brokerId'),
          propertyId: propertyId,
          channel: BuiltValueNullFieldError.checkNotNull(
              channel, r'BrokerContactLogDto', 'channel'),
          outcome: BuiltValueNullFieldError.checkNotNull(
              outcome, r'BrokerContactLogDto', 'outcome'),
          hasReview: BuiltValueNullFieldError.checkNotNull(
              hasReview, r'BrokerContactLogDto', 'hasReview'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'BrokerContactLogDto', 'createdAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
