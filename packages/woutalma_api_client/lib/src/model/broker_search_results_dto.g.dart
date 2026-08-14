// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'broker_search_results_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BrokerSearchResultsDto extends BrokerSearchResultsDto {
  @override
  final BuiltList<BrokerListingDto> items;
  @override
  final num totalCount;
  @override
  final num limit;
  @override
  final num offset;

  factory _$BrokerSearchResultsDto(
          [void Function(BrokerSearchResultsDtoBuilder)? updates]) =>
      (BrokerSearchResultsDtoBuilder()..update(updates))._build();

  _$BrokerSearchResultsDto._(
      {required this.items,
      required this.totalCount,
      required this.limit,
      required this.offset})
      : super._();
  @override
  BrokerSearchResultsDto rebuild(
          void Function(BrokerSearchResultsDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BrokerSearchResultsDtoBuilder toBuilder() =>
      BrokerSearchResultsDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BrokerSearchResultsDto &&
        items == other.items &&
        totalCount == other.totalCount &&
        limit == other.limit &&
        offset == other.offset;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jc(_$hash, totalCount.hashCode);
    _$hash = $jc(_$hash, limit.hashCode);
    _$hash = $jc(_$hash, offset.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BrokerSearchResultsDto')
          ..add('items', items)
          ..add('totalCount', totalCount)
          ..add('limit', limit)
          ..add('offset', offset))
        .toString();
  }
}

class BrokerSearchResultsDtoBuilder
    implements Builder<BrokerSearchResultsDto, BrokerSearchResultsDtoBuilder> {
  _$BrokerSearchResultsDto? _$v;

  ListBuilder<BrokerListingDto>? _items;
  ListBuilder<BrokerListingDto> get items =>
      _$this._items ??= ListBuilder<BrokerListingDto>();
  set items(ListBuilder<BrokerListingDto>? items) => _$this._items = items;

  num? _totalCount;
  num? get totalCount => _$this._totalCount;
  set totalCount(num? totalCount) => _$this._totalCount = totalCount;

  num? _limit;
  num? get limit => _$this._limit;
  set limit(num? limit) => _$this._limit = limit;

  num? _offset;
  num? get offset => _$this._offset;
  set offset(num? offset) => _$this._offset = offset;

  BrokerSearchResultsDtoBuilder() {
    BrokerSearchResultsDto._defaults(this);
  }

  BrokerSearchResultsDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _totalCount = $v.totalCount;
      _limit = $v.limit;
      _offset = $v.offset;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BrokerSearchResultsDto other) {
    _$v = other as _$BrokerSearchResultsDto;
  }

  @override
  void update(void Function(BrokerSearchResultsDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BrokerSearchResultsDto build() => _build();

  _$BrokerSearchResultsDto _build() {
    _$BrokerSearchResultsDto _$result;
    try {
      _$result = _$v ??
          _$BrokerSearchResultsDto._(
            items: items.build(),
            totalCount: BuiltValueNullFieldError.checkNotNull(
                totalCount, r'BrokerSearchResultsDto', 'totalCount'),
            limit: BuiltValueNullFieldError.checkNotNull(
                limit, r'BrokerSearchResultsDto', 'limit'),
            offset: BuiltValueNullFieldError.checkNotNull(
                offset, r'BrokerSearchResultsDto', 'offset'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'BrokerSearchResultsDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
