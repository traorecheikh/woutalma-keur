// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_suggestions_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SearchSuggestionsDto extends SearchSuggestionsDto {
  @override
  final BuiltList<String> items;

  factory _$SearchSuggestionsDto(
          [void Function(SearchSuggestionsDtoBuilder)? updates]) =>
      (SearchSuggestionsDtoBuilder()..update(updates))._build();

  _$SearchSuggestionsDto._({required this.items}) : super._();
  @override
  SearchSuggestionsDto rebuild(
          void Function(SearchSuggestionsDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SearchSuggestionsDtoBuilder toBuilder() =>
      SearchSuggestionsDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SearchSuggestionsDto && items == other.items;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SearchSuggestionsDto')
          ..add('items', items))
        .toString();
  }
}

class SearchSuggestionsDtoBuilder
    implements Builder<SearchSuggestionsDto, SearchSuggestionsDtoBuilder> {
  _$SearchSuggestionsDto? _$v;

  ListBuilder<String>? _items;
  ListBuilder<String> get items => _$this._items ??= ListBuilder<String>();
  set items(ListBuilder<String>? items) => _$this._items = items;

  SearchSuggestionsDtoBuilder() {
    SearchSuggestionsDto._defaults(this);
  }

  SearchSuggestionsDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SearchSuggestionsDto other) {
    _$v = other as _$SearchSuggestionsDto;
  }

  @override
  void update(void Function(SearchSuggestionsDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SearchSuggestionsDto build() => _build();

  _$SearchSuggestionsDto _build() {
    _$SearchSuggestionsDto _$result;
    try {
      _$result = _$v ??
          _$SearchSuggestionsDto._(
            items: items.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'SearchSuggestionsDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
