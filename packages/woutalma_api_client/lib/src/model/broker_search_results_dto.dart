//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:woutalma_api_client/src/model/broker_listing_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'broker_search_results_dto.g.dart';

/// BrokerSearchResultsDto
///
/// Properties:
/// * [items]
/// * [totalCount]
/// * [limit]
/// * [offset]
@BuiltValue()
abstract class BrokerSearchResultsDto
    implements Built<BrokerSearchResultsDto, BrokerSearchResultsDtoBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<BrokerListingDto> get items;

  @BuiltValueField(wireName: r'totalCount')
  num get totalCount;

  @BuiltValueField(wireName: r'limit')
  num get limit;

  @BuiltValueField(wireName: r'offset')
  num get offset;

  BrokerSearchResultsDto._();

  factory BrokerSearchResultsDto(
          [void updates(BrokerSearchResultsDtoBuilder b)]) =
      _$BrokerSearchResultsDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BrokerSearchResultsDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BrokerSearchResultsDto> get serializer =>
      _$BrokerSearchResultsDtoSerializer();
}

class _$BrokerSearchResultsDtoSerializer
    implements PrimitiveSerializer<BrokerSearchResultsDto> {
  @override
  final Iterable<Type> types = const [
    BrokerSearchResultsDto,
    _$BrokerSearchResultsDto
  ];

  @override
  final String wireName = r'BrokerSearchResultsDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BrokerSearchResultsDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(BrokerListingDto)]),
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
    BrokerSearchResultsDto object, {
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
    required BrokerSearchResultsDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(BrokerListingDto)]),
          ) as BuiltList<BrokerListingDto>;
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
  BrokerSearchResultsDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BrokerSearchResultsDtoBuilder();
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
