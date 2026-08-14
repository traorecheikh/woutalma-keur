//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:woutalma_api_client/src/model/broker_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'broker_listing_dto.g.dart';

/// BrokerListingDto
///
/// Properties:
/// * [broker]
/// * [distanceMeters]
/// * [averageRating]
/// * [reviewCount]
/// * [availableProperties]
/// * [score]
@BuiltValue()
abstract class BrokerListingDto
    implements Built<BrokerListingDto, BrokerListingDtoBuilder> {
  @BuiltValueField(wireName: r'broker')
  BrokerDto get broker;

  @BuiltValueField(wireName: r'distanceMeters')
  num get distanceMeters;

  @BuiltValueField(wireName: r'averageRating')
  num get averageRating;

  @BuiltValueField(wireName: r'reviewCount')
  num get reviewCount;

  @BuiltValueField(wireName: r'availableProperties')
  num get availableProperties;

  @BuiltValueField(wireName: r'score')
  num get score;

  BrokerListingDto._();

  factory BrokerListingDto([void updates(BrokerListingDtoBuilder b)]) =
      _$BrokerListingDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BrokerListingDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BrokerListingDto> get serializer =>
      _$BrokerListingDtoSerializer();
}

class _$BrokerListingDtoSerializer
    implements PrimitiveSerializer<BrokerListingDto> {
  @override
  final Iterable<Type> types = const [BrokerListingDto, _$BrokerListingDto];

  @override
  final String wireName = r'BrokerListingDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BrokerListingDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'broker';
    yield serializers.serialize(
      object.broker,
      specifiedType: const FullType(BrokerDto),
    );
    yield r'distanceMeters';
    yield serializers.serialize(
      object.distanceMeters,
      specifiedType: const FullType(num),
    );
    yield r'averageRating';
    yield serializers.serialize(
      object.averageRating,
      specifiedType: const FullType(num),
    );
    yield r'reviewCount';
    yield serializers.serialize(
      object.reviewCount,
      specifiedType: const FullType(num),
    );
    yield r'availableProperties';
    yield serializers.serialize(
      object.availableProperties,
      specifiedType: const FullType(num),
    );
    yield r'score';
    yield serializers.serialize(
      object.score,
      specifiedType: const FullType(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BrokerListingDto object, {
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
    required BrokerListingDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'broker':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BrokerDto),
          ) as BrokerDto;
          result.broker.replace(valueDes);
          break;
        case r'distanceMeters':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.distanceMeters = valueDes;
          break;
        case r'averageRating':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.averageRating = valueDes;
          break;
        case r'reviewCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.reviewCount = valueDes;
          break;
        case r'availableProperties':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.availableProperties = valueDes;
          break;
        case r'score':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.score = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BrokerListingDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BrokerListingDtoBuilder();
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
