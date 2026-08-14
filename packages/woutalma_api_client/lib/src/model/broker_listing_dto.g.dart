// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'broker_listing_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BrokerListingDto extends BrokerListingDto {
  @override
  final BrokerDto broker;
  @override
  final num distanceMeters;
  @override
  final num averageRating;
  @override
  final num reviewCount;
  @override
  final num availableProperties;
  @override
  final num score;

  factory _$BrokerListingDto(
          [void Function(BrokerListingDtoBuilder)? updates]) =>
      (BrokerListingDtoBuilder()..update(updates))._build();

  _$BrokerListingDto._(
      {required this.broker,
      required this.distanceMeters,
      required this.averageRating,
      required this.reviewCount,
      required this.availableProperties,
      required this.score})
      : super._();
  @override
  BrokerListingDto rebuild(void Function(BrokerListingDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BrokerListingDtoBuilder toBuilder() =>
      BrokerListingDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BrokerListingDto &&
        broker == other.broker &&
        distanceMeters == other.distanceMeters &&
        averageRating == other.averageRating &&
        reviewCount == other.reviewCount &&
        availableProperties == other.availableProperties &&
        score == other.score;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, broker.hashCode);
    _$hash = $jc(_$hash, distanceMeters.hashCode);
    _$hash = $jc(_$hash, averageRating.hashCode);
    _$hash = $jc(_$hash, reviewCount.hashCode);
    _$hash = $jc(_$hash, availableProperties.hashCode);
    _$hash = $jc(_$hash, score.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BrokerListingDto')
          ..add('broker', broker)
          ..add('distanceMeters', distanceMeters)
          ..add('averageRating', averageRating)
          ..add('reviewCount', reviewCount)
          ..add('availableProperties', availableProperties)
          ..add('score', score))
        .toString();
  }
}

class BrokerListingDtoBuilder
    implements Builder<BrokerListingDto, BrokerListingDtoBuilder> {
  _$BrokerListingDto? _$v;

  BrokerDtoBuilder? _broker;
  BrokerDtoBuilder get broker => _$this._broker ??= BrokerDtoBuilder();
  set broker(BrokerDtoBuilder? broker) => _$this._broker = broker;

  num? _distanceMeters;
  num? get distanceMeters => _$this._distanceMeters;
  set distanceMeters(num? distanceMeters) =>
      _$this._distanceMeters = distanceMeters;

  num? _averageRating;
  num? get averageRating => _$this._averageRating;
  set averageRating(num? averageRating) =>
      _$this._averageRating = averageRating;

  num? _reviewCount;
  num? get reviewCount => _$this._reviewCount;
  set reviewCount(num? reviewCount) => _$this._reviewCount = reviewCount;

  num? _availableProperties;
  num? get availableProperties => _$this._availableProperties;
  set availableProperties(num? availableProperties) =>
      _$this._availableProperties = availableProperties;

  num? _score;
  num? get score => _$this._score;
  set score(num? score) => _$this._score = score;

  BrokerListingDtoBuilder() {
    BrokerListingDto._defaults(this);
  }

  BrokerListingDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _broker = $v.broker.toBuilder();
      _distanceMeters = $v.distanceMeters;
      _averageRating = $v.averageRating;
      _reviewCount = $v.reviewCount;
      _availableProperties = $v.availableProperties;
      _score = $v.score;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BrokerListingDto other) {
    _$v = other as _$BrokerListingDto;
  }

  @override
  void update(void Function(BrokerListingDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BrokerListingDto build() => _build();

  _$BrokerListingDto _build() {
    _$BrokerListingDto _$result;
    try {
      _$result = _$v ??
          _$BrokerListingDto._(
            broker: broker.build(),
            distanceMeters: BuiltValueNullFieldError.checkNotNull(
                distanceMeters, r'BrokerListingDto', 'distanceMeters'),
            averageRating: BuiltValueNullFieldError.checkNotNull(
                averageRating, r'BrokerListingDto', 'averageRating'),
            reviewCount: BuiltValueNullFieldError.checkNotNull(
                reviewCount, r'BrokerListingDto', 'reviewCount'),
            availableProperties: BuiltValueNullFieldError.checkNotNull(
                availableProperties,
                r'BrokerListingDto',
                'availableProperties'),
            score: BuiltValueNullFieldError.checkNotNull(
                score, r'BrokerListingDto', 'score'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'broker';
        broker.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'BrokerListingDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
