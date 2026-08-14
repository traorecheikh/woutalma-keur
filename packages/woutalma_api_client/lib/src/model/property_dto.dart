//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:woutalma_api_client/src/model/geo_point_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'property_dto.g.dart';

/// PropertyDto
///
/// Properties:
/// * [id]
/// * [brokerId]
/// * [kind]
/// * [transaction]
/// * [title]
/// * [description]
/// * [price] - CFA francs, integer.
/// * [surface]
/// * [rooms]
/// * [position]
/// * [neighbourhood]
/// * [photoAssets]
/// * [status]
/// * [createdAt]
/// * [isDiscoverable]
@BuiltValue()
abstract class PropertyDto implements Built<PropertyDto, PropertyDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'brokerId')
  String get brokerId;

  @BuiltValueField(wireName: r'kind')
  PropertyDtoKindEnum get kind;
  // enum kindEnum {  APARTMENT,  HOUSE,  LAND,  STUDIO,  ROOM,  };

  @BuiltValueField(wireName: r'transaction')
  PropertyDtoTransactionEnum get transaction;
  // enum transactionEnum {  RENT,  SALE,  };

  @BuiltValueField(wireName: r'title')
  String get title;

  @BuiltValueField(wireName: r'description')
  String get description;

  /// CFA francs, integer.
  @BuiltValueField(wireName: r'price')
  num get price;

  @BuiltValueField(wireName: r'surface')
  num? get surface;

  @BuiltValueField(wireName: r'rooms')
  num? get rooms;

  @BuiltValueField(wireName: r'position')
  GeoPointDto get position;

  @BuiltValueField(wireName: r'neighbourhood')
  String get neighbourhood;

  @BuiltValueField(wireName: r'photoAssets')
  BuiltList<String> get photoAssets;

  @BuiltValueField(wireName: r'status')
  PropertyDtoStatusEnum get status;
  // enum statusEnum {  AVAILABLE,  RESERVED,  CLOSED,  };

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'isDiscoverable')
  bool get isDiscoverable;

  PropertyDto._();

  factory PropertyDto([void updates(PropertyDtoBuilder b)]) = _$PropertyDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PropertyDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PropertyDto> get serializer => _$PropertyDtoSerializer();
}

class _$PropertyDtoSerializer implements PrimitiveSerializer<PropertyDto> {
  @override
  final Iterable<Type> types = const [PropertyDto, _$PropertyDto];

  @override
  final String wireName = r'PropertyDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PropertyDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'brokerId';
    yield serializers.serialize(
      object.brokerId,
      specifiedType: const FullType(String),
    );
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(PropertyDtoKindEnum),
    );
    yield r'transaction';
    yield serializers.serialize(
      object.transaction,
      specifiedType: const FullType(PropertyDtoTransactionEnum),
    );
    yield r'title';
    yield serializers.serialize(
      object.title,
      specifiedType: const FullType(String),
    );
    yield r'description';
    yield serializers.serialize(
      object.description,
      specifiedType: const FullType(String),
    );
    yield r'price';
    yield serializers.serialize(
      object.price,
      specifiedType: const FullType(num),
    );
    if (object.surface != null) {
      yield r'surface';
      yield serializers.serialize(
        object.surface,
        specifiedType: const FullType.nullable(num),
      );
    }
    if (object.rooms != null) {
      yield r'rooms';
      yield serializers.serialize(
        object.rooms,
        specifiedType: const FullType.nullable(num),
      );
    }
    yield r'position';
    yield serializers.serialize(
      object.position,
      specifiedType: const FullType(GeoPointDto),
    );
    yield r'neighbourhood';
    yield serializers.serialize(
      object.neighbourhood,
      specifiedType: const FullType(String),
    );
    yield r'photoAssets';
    yield serializers.serialize(
      object.photoAssets,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(PropertyDtoStatusEnum),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'isDiscoverable';
    yield serializers.serialize(
      object.isDiscoverable,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PropertyDto object, {
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
    required PropertyDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'brokerId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.brokerId = valueDes;
          break;
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PropertyDtoKindEnum),
          ) as PropertyDtoKindEnum;
          result.kind = valueDes;
          break;
        case r'transaction':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PropertyDtoTransactionEnum),
          ) as PropertyDtoTransactionEnum;
          result.transaction = valueDes;
          break;
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        case r'description':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.description = valueDes;
          break;
        case r'price':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.price = valueDes;
          break;
        case r'surface':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.surface = valueDes;
          break;
        case r'rooms':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.rooms = valueDes;
          break;
        case r'position':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GeoPointDto),
          ) as GeoPointDto;
          result.position.replace(valueDes);
          break;
        case r'neighbourhood':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.neighbourhood = valueDes;
          break;
        case r'photoAssets':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.photoAssets.replace(valueDes);
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PropertyDtoStatusEnum),
          ) as PropertyDtoStatusEnum;
          result.status = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'isDiscoverable':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isDiscoverable = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PropertyDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PropertyDtoBuilder();
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

class PropertyDtoKindEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'APARTMENT')
  static const PropertyDtoKindEnum APARTMENT = _$propertyDtoKindEnum_APARTMENT;
  @BuiltValueEnumConst(wireName: r'HOUSE')
  static const PropertyDtoKindEnum HOUSE = _$propertyDtoKindEnum_HOUSE;
  @BuiltValueEnumConst(wireName: r'LAND')
  static const PropertyDtoKindEnum LAND = _$propertyDtoKindEnum_LAND;
  @BuiltValueEnumConst(wireName: r'STUDIO')
  static const PropertyDtoKindEnum STUDIO = _$propertyDtoKindEnum_STUDIO;
  @BuiltValueEnumConst(wireName: r'ROOM')
  static const PropertyDtoKindEnum ROOM = _$propertyDtoKindEnum_ROOM;

  static Serializer<PropertyDtoKindEnum> get serializer =>
      _$propertyDtoKindEnumSerializer;

  const PropertyDtoKindEnum._(String name) : super(name);

  static BuiltSet<PropertyDtoKindEnum> get values =>
      _$propertyDtoKindEnumValues;
  static PropertyDtoKindEnum valueOf(String name) =>
      _$propertyDtoKindEnumValueOf(name);
}

class PropertyDtoTransactionEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'RENT')
  static const PropertyDtoTransactionEnum RENT =
      _$propertyDtoTransactionEnum_RENT;
  @BuiltValueEnumConst(wireName: r'SALE')
  static const PropertyDtoTransactionEnum SALE =
      _$propertyDtoTransactionEnum_SALE;

  static Serializer<PropertyDtoTransactionEnum> get serializer =>
      _$propertyDtoTransactionEnumSerializer;

  const PropertyDtoTransactionEnum._(String name) : super(name);

  static BuiltSet<PropertyDtoTransactionEnum> get values =>
      _$propertyDtoTransactionEnumValues;
  static PropertyDtoTransactionEnum valueOf(String name) =>
      _$propertyDtoTransactionEnumValueOf(name);
}

class PropertyDtoStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'AVAILABLE')
  static const PropertyDtoStatusEnum AVAILABLE =
      _$propertyDtoStatusEnum_AVAILABLE;
  @BuiltValueEnumConst(wireName: r'RESERVED')
  static const PropertyDtoStatusEnum RESERVED =
      _$propertyDtoStatusEnum_RESERVED;
  @BuiltValueEnumConst(wireName: r'CLOSED')
  static const PropertyDtoStatusEnum CLOSED = _$propertyDtoStatusEnum_CLOSED;

  static Serializer<PropertyDtoStatusEnum> get serializer =>
      _$propertyDtoStatusEnumSerializer;

  const PropertyDtoStatusEnum._(String name) : super(name);

  static BuiltSet<PropertyDtoStatusEnum> get values =>
      _$propertyDtoStatusEnumValues;
  static PropertyDtoStatusEnum valueOf(String name) =>
      _$propertyDtoStatusEnumValueOf(name);
}
