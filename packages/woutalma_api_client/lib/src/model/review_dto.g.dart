// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ReviewDtoModerationEnum _$reviewDtoModerationEnum_PENDING =
    const ReviewDtoModerationEnum._('PENDING');
const ReviewDtoModerationEnum _$reviewDtoModerationEnum_PUBLISHED =
    const ReviewDtoModerationEnum._('PUBLISHED');
const ReviewDtoModerationEnum _$reviewDtoModerationEnum_REJECTED =
    const ReviewDtoModerationEnum._('REJECTED');

ReviewDtoModerationEnum _$reviewDtoModerationEnumValueOf(String name) {
  switch (name) {
    case 'PENDING':
      return _$reviewDtoModerationEnum_PENDING;
    case 'PUBLISHED':
      return _$reviewDtoModerationEnum_PUBLISHED;
    case 'REJECTED':
      return _$reviewDtoModerationEnum_REJECTED;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ReviewDtoModerationEnum> _$reviewDtoModerationEnumValues =
    BuiltSet<ReviewDtoModerationEnum>(const <ReviewDtoModerationEnum>[
  _$reviewDtoModerationEnum_PENDING,
  _$reviewDtoModerationEnum_PUBLISHED,
  _$reviewDtoModerationEnum_REJECTED,
]);

Serializer<ReviewDtoModerationEnum> _$reviewDtoModerationEnumSerializer =
    _$ReviewDtoModerationEnumSerializer();

class _$ReviewDtoModerationEnumSerializer
    implements PrimitiveSerializer<ReviewDtoModerationEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'PENDING': 'PENDING',
    'PUBLISHED': 'PUBLISHED',
    'REJECTED': 'REJECTED',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'PENDING': 'PENDING',
    'PUBLISHED': 'PUBLISHED',
    'REJECTED': 'REJECTED',
  };

  @override
  final Iterable<Type> types = const <Type>[ReviewDtoModerationEnum];
  @override
  final String wireName = 'ReviewDtoModerationEnum';

  @override
  Object serialize(Serializers serializers, ReviewDtoModerationEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ReviewDtoModerationEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ReviewDtoModerationEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ReviewDto extends ReviewDto {
  @override
  final String id;
  @override
  final String brokerId;
  @override
  final String contactId;
  @override
  final num rating;
  @override
  final num? responsiveness;
  @override
  final num? accuracy;
  @override
  final num? courtesy;
  @override
  final String? comment;
  @override
  final ReviewDtoModerationEnum moderation;
  @override
  final String? brokerReply;
  @override
  final DateTime createdAt;
  @override
  final bool isPublic;

  factory _$ReviewDto([void Function(ReviewDtoBuilder)? updates]) =>
      (ReviewDtoBuilder()..update(updates))._build();

  _$ReviewDto._(
      {required this.id,
      required this.brokerId,
      required this.contactId,
      required this.rating,
      this.responsiveness,
      this.accuracy,
      this.courtesy,
      this.comment,
      required this.moderation,
      this.brokerReply,
      required this.createdAt,
      required this.isPublic})
      : super._();
  @override
  ReviewDto rebuild(void Function(ReviewDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReviewDtoBuilder toBuilder() => ReviewDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReviewDto &&
        id == other.id &&
        brokerId == other.brokerId &&
        contactId == other.contactId &&
        rating == other.rating &&
        responsiveness == other.responsiveness &&
        accuracy == other.accuracy &&
        courtesy == other.courtesy &&
        comment == other.comment &&
        moderation == other.moderation &&
        brokerReply == other.brokerReply &&
        createdAt == other.createdAt &&
        isPublic == other.isPublic;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, brokerId.hashCode);
    _$hash = $jc(_$hash, contactId.hashCode);
    _$hash = $jc(_$hash, rating.hashCode);
    _$hash = $jc(_$hash, responsiveness.hashCode);
    _$hash = $jc(_$hash, accuracy.hashCode);
    _$hash = $jc(_$hash, courtesy.hashCode);
    _$hash = $jc(_$hash, comment.hashCode);
    _$hash = $jc(_$hash, moderation.hashCode);
    _$hash = $jc(_$hash, brokerReply.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, isPublic.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ReviewDto')
          ..add('id', id)
          ..add('brokerId', brokerId)
          ..add('contactId', contactId)
          ..add('rating', rating)
          ..add('responsiveness', responsiveness)
          ..add('accuracy', accuracy)
          ..add('courtesy', courtesy)
          ..add('comment', comment)
          ..add('moderation', moderation)
          ..add('brokerReply', brokerReply)
          ..add('createdAt', createdAt)
          ..add('isPublic', isPublic))
        .toString();
  }
}

class ReviewDtoBuilder implements Builder<ReviewDto, ReviewDtoBuilder> {
  _$ReviewDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _brokerId;
  String? get brokerId => _$this._brokerId;
  set brokerId(String? brokerId) => _$this._brokerId = brokerId;

  String? _contactId;
  String? get contactId => _$this._contactId;
  set contactId(String? contactId) => _$this._contactId = contactId;

  num? _rating;
  num? get rating => _$this._rating;
  set rating(num? rating) => _$this._rating = rating;

  num? _responsiveness;
  num? get responsiveness => _$this._responsiveness;
  set responsiveness(num? responsiveness) =>
      _$this._responsiveness = responsiveness;

  num? _accuracy;
  num? get accuracy => _$this._accuracy;
  set accuracy(num? accuracy) => _$this._accuracy = accuracy;

  num? _courtesy;
  num? get courtesy => _$this._courtesy;
  set courtesy(num? courtesy) => _$this._courtesy = courtesy;

  String? _comment;
  String? get comment => _$this._comment;
  set comment(String? comment) => _$this._comment = comment;

  ReviewDtoModerationEnum? _moderation;
  ReviewDtoModerationEnum? get moderation => _$this._moderation;
  set moderation(ReviewDtoModerationEnum? moderation) =>
      _$this._moderation = moderation;

  String? _brokerReply;
  String? get brokerReply => _$this._brokerReply;
  set brokerReply(String? brokerReply) => _$this._brokerReply = brokerReply;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  bool? _isPublic;
  bool? get isPublic => _$this._isPublic;
  set isPublic(bool? isPublic) => _$this._isPublic = isPublic;

  ReviewDtoBuilder() {
    ReviewDto._defaults(this);
  }

  ReviewDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _brokerId = $v.brokerId;
      _contactId = $v.contactId;
      _rating = $v.rating;
      _responsiveness = $v.responsiveness;
      _accuracy = $v.accuracy;
      _courtesy = $v.courtesy;
      _comment = $v.comment;
      _moderation = $v.moderation;
      _brokerReply = $v.brokerReply;
      _createdAt = $v.createdAt;
      _isPublic = $v.isPublic;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReviewDto other) {
    _$v = other as _$ReviewDto;
  }

  @override
  void update(void Function(ReviewDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReviewDto build() => _build();

  _$ReviewDto _build() {
    final _$result = _$v ??
        _$ReviewDto._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'ReviewDto', 'id'),
          brokerId: BuiltValueNullFieldError.checkNotNull(
              brokerId, r'ReviewDto', 'brokerId'),
          contactId: BuiltValueNullFieldError.checkNotNull(
              contactId, r'ReviewDto', 'contactId'),
          rating: BuiltValueNullFieldError.checkNotNull(
              rating, r'ReviewDto', 'rating'),
          responsiveness: responsiveness,
          accuracy: accuracy,
          courtesy: courtesy,
          comment: comment,
          moderation: BuiltValueNullFieldError.checkNotNull(
              moderation, r'ReviewDto', 'moderation'),
          brokerReply: brokerReply,
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'ReviewDto', 'createdAt'),
          isPublic: BuiltValueNullFieldError.checkNotNull(
              isPublic, r'ReviewDto', 'isPublic'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
