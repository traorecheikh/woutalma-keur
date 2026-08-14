//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'search_suggestions_dto.g.dart';

/// SearchSuggestionsDto
///
/// Properties:
/// * [items]
@BuiltValue()
abstract class SearchSuggestionsDto
    implements Built<SearchSuggestionsDto, SearchSuggestionsDtoBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<String> get items;

  SearchSuggestionsDto._();

  factory SearchSuggestionsDto([void updates(SearchSuggestionsDtoBuilder b)]) =
      _$SearchSuggestionsDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SearchSuggestionsDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SearchSuggestionsDto> get serializer =>
      _$SearchSuggestionsDtoSerializer();
}

class _$SearchSuggestionsDtoSerializer
    implements PrimitiveSerializer<SearchSuggestionsDto> {
  @override
  final Iterable<Type> types = const [
    SearchSuggestionsDto,
    _$SearchSuggestionsDto
  ];

  @override
  final String wireName = r'SearchSuggestionsDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SearchSuggestionsDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SearchSuggestionsDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SearchSuggestionsDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.items.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SearchSuggestionsDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SearchSuggestionsDtoBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}
