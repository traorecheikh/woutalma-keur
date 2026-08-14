// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_review_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateReviewDto extends CreateReviewDto {
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

  factory _$CreateReviewDto([void Function(CreateReviewDtoBuilder)? updates]) =>
      (CreateReviewDtoBuilder()..update(updates))._build();

  _$CreateReviewDto._(
      {required this.contactId,
      required this.rating,
      this.responsiveness,
      this.accuracy,
      this.courtesy,
      this.comment})
      : super._();
  @override
  CreateReviewDto rebuild(void Function(CreateReviewDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateReviewDtoBuilder toBuilder() => CreateReviewDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateReviewDto &&
        contactId == other.contactId &&
        rating == other.rating &&
        responsiveness == other.responsiveness &&
        accuracy == other.accuracy &&
        courtesy == other.courtesy &&
        comment == other.comment;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, contactId.hashCode);
    _$hash = $jc(_$hash, rating.hashCode);
    _$hash = $jc(_$hash, responsiveness.hashCode);
    _$hash = $jc(_$hash, accuracy.hashCode);
    _$hash = $jc(_$hash, courtesy.hashCode);
    _$hash = $jc(_$hash, comment.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateReviewDto')
          ..add('contactId', contactId)
          ..add('rating', rating)
          ..add('responsiveness', responsiveness)
          ..add('accuracy', accuracy)
          ..add('courtesy', courtesy)
          ..add('comment', comment))
        .toString();
  }
}

class CreateReviewDtoBuilder
    implements Builder<CreateReviewDto, CreateReviewDtoBuilder> {
  _$CreateReviewDto? _$v;

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

  CreateReviewDtoBuilder() {
    CreateReviewDto._defaults(this);
  }

  CreateReviewDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _contactId = $v.contactId;
      _rating = $v.rating;
      _responsiveness = $v.responsiveness;
      _accuracy = $v.accuracy;
      _courtesy = $v.courtesy;
      _comment = $v.comment;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateReviewDto other) {
    _$v = other as _$CreateReviewDto;
  }

  @override
  void update(void Function(CreateReviewDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateReviewDto build() => _build();

  _$CreateReviewDto _build() {
    final _$result = _$v ??
        _$CreateReviewDto._(
          contactId: BuiltValueNullFieldError.checkNotNull(
              contactId, r'CreateReviewDto', 'contactId'),
          rating: BuiltValueNullFieldError.checkNotNull(
              rating, r'CreateReviewDto', 'rating'),
          responsiveness: responsiveness,
          accuracy: accuracy,
          courtesy: courtesy,
          comment: comment,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
