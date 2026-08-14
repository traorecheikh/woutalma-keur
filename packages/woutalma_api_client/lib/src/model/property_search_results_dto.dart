//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:woutalma_api_client/src/model/property_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'property_search_results_dto.g.dart';

/// PropertySearchResultsDto
///
/// Properties:
/// * [items]
/// * [totalCount]
/// * [limit]
/// * [offset]
@BuiltValue()
abstract class PropertySearchResultsDto
    implements
        Built<PropertySearchResultsDto, PropertySearchResultsDtoBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<PropertyDto> get items;

  @BuiltValueField(wireName: r'totalCount')
  num get totalCount;

  @BuiltValueField(wireName: r'limit')
  num get limit;

  @BuiltValueField(wireName: r'offset')
  num get offset;

  PropertySearchResultsDto._();

  factory PropertySearchResultsDto(
          [void updates(PropertySearchResultsDtoBuilder b)]) =
      _$PropertySearchResultsDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PropertySearchResultsDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PropertySearchResultsDto> get serializer =>
      _$PropertySearchResultsDtoSerializer();
}

class _$PropertySearchResultsDtoSerializer
    implements PrimitiveSerializer<PropertySearchResultsDto> {
  @override
  final Iterable<Type> types = const [
    PropertySearchResultsDto,
    _$PropertySearchResultsDto
  ];

  @override
  final String wireName = r'PropertySearchResultsDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PropertySearchResultsDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(PropertyDto)]),
    );
    yield r'totalCount';
    yield serializers.serialize(
      object.totalCount,
      specifiedType: const FullType(num),
    );
    yield r'limit';
    yield serializers.serialize(
      object.limit,
      specifiedType: const FullType(num),
    );
    yield r'offset';
    yield serializers.serialize(
      object.offset,
      specifiedType: const FullType(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PropertySearchResultsDto object, {
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
    required PropertySearchResultsDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(PropertyDto)]),
          ) as BuiltList<PropertyDto>;
          result.items.replace(valueDes);
          break;
        case r'totalCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.totalCount = valueDes;
          break;
        case r'limit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.limit = valueDes;
          break;
        case r'offset':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.offset = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PropertySearchResultsDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PropertySearchResultsDtoBuilder();
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
