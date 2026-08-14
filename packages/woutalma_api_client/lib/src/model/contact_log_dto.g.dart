// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_log_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ContactLogDtoChannelEnum _$contactLogDtoChannelEnum_CALL =
    const ContactLogDtoChannelEnum._('CALL');
const ContactLogDtoChannelEnum _$contactLogDtoChannelEnum_SMS =
    const ContactLogDtoChannelEnum._('SMS');
const ContactLogDtoChannelEnum _$contactLogDtoChannelEnum_WHATSAPP =
    const ContactLogDtoChannelEnum._('WHATSAPP');
const ContactLogDtoChannelEnum _$contactLogDtoChannelEnum_VOICE_MESSAGE =
    const ContactLogDtoChannelEnum._('VOICE_MESSAGE');

ContactLogDtoChannelEnum _$contactLogDtoChannelEnumValueOf(String name) {
  switch (name) {
    case 'CALL':
      return _$contactLogDtoChannelEnum_CALL;
    case 'SMS':
      return _$contactLogDtoChannelEnum_SMS;
    case 'WHATSAPP':
      return _$contactLogDtoChannelEnum_WHATSAPP;
    case 'VOICE_MESSAGE':
      return _$contactLogDtoChannelEnum_VOICE_MESSAGE;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ContactLogDtoChannelEnum> _$contactLogDtoChannelEnumValues =
    BuiltSet<ContactLogDtoChannelEnum>(const <ContactLogDtoChannelEnum>[
  _$contactLogDtoChannelEnum_CALL,
  _$contactLogDtoChannelEnum_SMS,
  _$contactLogDtoChannelEnum_WHATSAPP,
  _$contactLogDtoChannelEnum_VOICE_MESSAGE,
]);

const ContactLogDtoOutcomeEnum _$contactLogDtoOutcomeEnum_ATTEMPTED =
    const ContactLogDtoOutcomeEnum._('ATTEMPTED');
const ContactLogDtoOutcomeEnum _$contactLogDtoOutcomeEnum_REACHED =
    const ContactLogDtoOutcomeEnum._('REACHED');
const ContactLogDtoOutcomeEnum _$contactLogDtoOutcomeEnum_NO_ANSWER =
    const ContactLogDtoOutcomeEnum._('NO_ANSWER');

ContactLogDtoOutcomeEnum _$contactLogDtoOutcomeEnumValueOf(String name) {
  switch (name) {
    case 'ATTEMPTED':
      return _$contactLogDtoOutcomeEnum_ATTEMPTED;
    case 'REACHED':
      return _$contactLogDtoOutcomeEnum_REACHED;
    case 'NO_ANSWER':
      return _$contactLogDtoOutcomeEnum_NO_ANSWER;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ContactLogDtoOutcomeEnum> _$contactLogDtoOutcomeEnumValues =
    BuiltSet<ContactLogDtoOutcomeEnum>(const <ContactLogDtoOutcomeEnum>[
  _$contactLogDtoOutcomeEnum_ATTEMPTED,
  _$contactLogDtoOutcomeEnum_REACHED,
  _$contactLogDtoOutcomeEnum_NO_ANSWER,
]);

Serializer<ContactLogDtoChannelEnum> _$contactLogDtoChannelEnumSerializer =
    _$ContactLogDtoChannelEnumSerializer();
Serializer<ContactLogDtoOutcomeEnum> _$contactLogDtoOutcomeEnumSerializer =
    _$ContactLogDtoOutcomeEnumSerializer();

class _$ContactLogDtoChannelEnumSerializer
    implements PrimitiveSerializer<ContactLogDtoChannelEnum> {
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
  final Iterable<Type> types = const <Type>[ContactLogDtoChannelEnum];
  @override
  final String wireName = 'ContactLogDtoChannelEnum';

  @override
  Object serialize(Serializers serializers, ContactLogDtoChannelEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ContactLogDtoChannelEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ContactLogDtoChannelEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ContactLogDtoOutcomeEnumSerializer
    implements PrimitiveSerializer<ContactLogDtoOutcomeEnum> {
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
  final Iterable<Type> types = const <Type>[ContactLogDtoOutcomeEnum];
  @override
  final String wireName = 'ContactLogDtoOutcomeEnum';

  @override
  Object serialize(Serializers serializers, ContactLogDtoOutcomeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ContactLogDtoOutcomeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ContactLogDtoOutcomeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ContactLogDto extends ContactLogDto {
  @override
  final String id;
  @override
  final String brokerId;
  @override
  final String? propertyId;
  @override
  final ContactLogDtoChannelEnum channel;
  @override
  final ContactLogDtoOutcomeEnum outcome;
  @override
  final String? reviewId;
  @override
  final DateTime createdAt;
  @override
  final bool allowsReview;

  factory _$ContactLogDto([void Function(ContactLogDtoBuilder)? updates]) =>
      (ContactLogDtoBuilder()..update(updates))._build();

  _$ContactLogDto._(
      {required this.id,
      required this.brokerId,
      this.propertyId,
      required this.channel,
      required this.outcome,
      this.reviewId,
      required this.createdAt,
      required this.allowsReview})
      : super._();
  @override
  ContactLogDto rebuild(void Function(ContactLogDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ContactLogDtoBuilder toBuilder() => ContactLogDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ContactLogDto &&
        id == other.id &&
        brokerId == other.brokerId &&
        propertyId == other.propertyId &&
        channel == other.channel &&
        outcome == other.outcome &&
        reviewId == other.reviewId &&
        createdAt == other.createdAt &&
        allowsReview == other.allowsReview;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, brokerId.hashCode);
    _$hash = $jc(_$hash, propertyId.hashCode);
    _$hash = $jc(_$hash, channel.hashCode);
    _$hash = $jc(_$hash, outcome.hashCode);
    _$hash = $jc(_$hash, reviewId.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, allowsReview.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ContactLogDto')
          ..add('id', id)
          ..add('brokerId', brokerId)
          ..add('propertyId', propertyId)
          ..add('channel', channel)
          ..add('outcome', outcome)
          ..add('reviewId', reviewId)
          ..add('createdAt', createdAt)
          ..add('allowsReview', allowsReview))
        .toString();
  }
}

class ContactLogDtoBuilder
    implements Builder<ContactLogDto, ContactLogDtoBuilder> {
  _$ContactLogDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _brokerId;
  String? get brokerId => _$this._brokerId;
  set brokerId(String? brokerId) => _$this._brokerId = brokerId;

  String? _propertyId;
  String? get propertyId => _$this._propertyId;
  set propertyId(String? propertyId) => _$this._propertyId = propertyId;

  ContactLogDtoChannelEnum? _channel;
  ContactLogDtoChannelEnum? get channel => _$this._channel;
  set channel(ContactLogDtoChannelEnum? channel) => _$this._channel = channel;

  ContactLogDtoOutcomeEnum? _outcome;
  ContactLogDtoOutcomeEnum? get outcome => _$this._outcome;
  set outcome(ContactLogDtoOutcomeEnum? outcome) => _$this._outcome = outcome;

  String? _reviewId;
  String? get reviewId => _$this._reviewId;
  set reviewId(String? reviewId) => _$this._reviewId = reviewId;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  bool? _allowsReview;
  bool? get allowsReview => _$this._allowsReview;
  set allowsReview(bool? allowsReview) => _$this._allowsReview = allowsReview;

  ContactLogDtoBuilder() {
    ContactLogDto._defaults(this);
  }

  ContactLogDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _brokerId = $v.brokerId;
      _propertyId = $v.propertyId;
      _channel = $v.channel;
      _outcome = $v.outcome;
      _reviewId = $v.reviewId;
      _createdAt = $v.createdAt;
      _allowsReview = $v.allowsReview;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ContactLogDto other) {
    _$v = other as _$ContactLogDto;
  }

  @override
  void update(void Function(ContactLogDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ContactLogDto build() => _build();

  _$ContactLogDto _build() {
    final _$result = _$v ??
        _$ContactLogDto._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'ContactLogDto', 'id'),
          brokerId: BuiltValueNullFieldError.checkNotNull(
              brokerId, r'ContactLogDto', 'brokerId'),
          propertyId: propertyId,
          channel: BuiltValueNullFieldError.checkNotNull(
              channel, r'ContactLogDto', 'channel'),
          outcome: BuiltValueNullFieldError.checkNotNull(
              outcome, r'ContactLogDto', 'outcome'),
          reviewId: reviewId,
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'ContactLogDto', 'createdAt'),
          allowsReview: BuiltValueNullFieldError.checkNotNull(
              allowsReview, r'ContactLogDto', 'allowsReview'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
