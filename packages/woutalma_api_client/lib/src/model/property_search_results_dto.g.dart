// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'property_search_results_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PropertySearchResultsDto extends PropertySearchResultsDto {
  @override
  final BuiltList<PropertyDto> items;
  @override
  final num totalCount;
  @override
  final num limit;
  @override
  final num offset;

  factory _$PropertySearchResultsDto(
          [void Function(PropertySearchResultsDtoBuilder)? updates]) =>
      (PropertySearchResultsDtoBuilder()..update(updates))._build();

  _$PropertySearchResultsDto._(
      {required this.items,
      required this.totalCount,
      required this.limit,
      required this.offset})
      : super._();
  @override
  PropertySearchResultsDto rebuild(
          void Function(PropertySearchResultsDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PropertySearchResultsDtoBuilder toBuilder() =>
      PropertySearchResultsDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PropertySearchResultsDto &&
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
    return (newBuiltValueToStringHelper(r'PropertySearchResultsDto')
          ..add('items', items)
          ..add('totalCount', totalCount)
          ..add('limit', limit)
          ..add('offset', offset))
        .toString();
  }
}

class PropertySearchResultsDtoBuilder
    implements
        Builder<PropertySearchResultsDto, PropertySearchResultsDtoBuilder> {
  _$PropertySearchResultsDto? _$v;

  ListBuilder<PropertyDto>? _items;
  ListBuilder<PropertyDto> get items =>
      _$this._items ??= ListBuilder<PropertyDto>();
  set items(ListBuilder<PropertyDto>? items) => _$this._items = items;

  num? _totalCount;
  num? get totalCount => _$this._totalCount;
  set totalCount(num? totalCount) => _$this._totalCount = totalCount;

  num? _limit;
  num? get limit => _$this._limit;
  set limit(num? limit) => _$this._limit = limit;

  num? _offset;
  num? get offset => _$this._offset;
  set offset(num? offset) => _$this._offset = offset;

  PropertySearchResultsDtoBuilder() {
    PropertySearchResultsDto._defaults(this);
  }

  PropertySearchResultsDtoBuilder get _$this {
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
  void replace(PropertySearchResultsDto other) {
    _$v = other as _$PropertySearchResultsDto;
  }

  @override
  void update(void Function(PropertySearchResultsDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PropertySearchResultsDto build() => _build();

  _$PropertySearchResultsDto _build() {
    _$PropertySearchResultsDto _$result;
    try {
      _$result = _$v ??
          _$PropertySearchResultsDto._(
            items: items.build(),
            totalCount: BuiltValueNullFieldError.checkNotNull(
                totalCount, r'PropertySearchResultsDto', 'totalCount'),
            limit: BuiltValueNullFieldError.checkNotNull(
                limit, r'PropertySearchResultsDto', 'limit'),
            offset: BuiltValueNullFieldError.checkNotNull(
                offset, r'PropertySearchResultsDto', 'offset'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PropertySearchResultsDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
