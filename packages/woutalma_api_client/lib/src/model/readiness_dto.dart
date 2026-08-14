//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'readiness_dto.g.dart';

/// ReadinessDto
///
/// Properties:
/// * [status]
/// * [database]
/// * [latencyMs] - Round-trip time of the readiness query.
/// * [uptimeSeconds]
@BuiltValue()
abstract class ReadinessDto
    implements Built<ReadinessDto, ReadinessDtoBuilder> {
  @BuiltValueField(wireName: r'status')
  ReadinessDtoStatusEnum get status;
  // enum statusEnum {  ok,  degraded,  };

  @BuiltValueField(wireName: r'database')
  ReadinessDtoDatabaseEnum get database;
  // enum databaseEnum {  up,  down,  };

  /// Round-trip time of the readiness query.
  @BuiltValueField(wireName: r'latencyMs')
  num get latencyMs;

  @BuiltValueField(wireName: r'uptimeSeconds')
  num get uptimeSeconds;

  ReadinessDto._();

  factory ReadinessDto([void updates(ReadinessDtoBuilder b)]) = _$ReadinessDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReadinessDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReadinessDto> get serializer => _$ReadinessDtoSerializer();
}

class _$ReadinessDtoSerializer implements PrimitiveSerializer<ReadinessDto> {
  @override
  final Iterable<Type> types = const [ReadinessDto, _$ReadinessDto];

  @override
  final String wireName = r'ReadinessDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReadinessDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(ReadinessDtoStatusEnum),
    );
    yield r'database';
    yield serializers.serialize(
      object.database,
      specifiedType: const FullType(ReadinessDtoDatabaseEnum),
    );
    yield r'latencyMs';
    yield serializers.serialize(
      object.latencyMs,
      specifiedType: const FullType(num),
    );
    yield r'uptimeSeconds';
    yield serializers.serialize(
      object.uptimeSeconds,
      specifiedType: const FullType(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ReadinessDto object, {
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
    required ReadinessDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ReadinessDtoStatusEnum),
          ) as ReadinessDtoStatusEnum;
          result.status = valueDes;
          break;
        case r'database':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ReadinessDtoDatabaseEnum),
          ) as ReadinessDtoDatabaseEnum;
          result.database = valueDes;
          break;
        case r'latencyMs':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.latencyMs = valueDes;
          break;
        case r'uptimeSeconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.uptimeSeconds = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ReadinessDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReadinessDtoBuilder();
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

class ReadinessDtoStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'ok')
  static const ReadinessDtoStatusEnum ok = _$readinessDtoStatusEnum_ok;
  @BuiltValueEnumConst(wireName: r'degraded')
  static const ReadinessDtoStatusEnum degraded =
      _$readinessDtoStatusEnum_degraded;

  static Serializer<ReadinessDtoStatusEnum> get serializer =>
      _$readinessDtoStatusEnumSerializer;

  const ReadinessDtoStatusEnum._(String name) : super(name);

  static BuiltSet<ReadinessDtoStatusEnum> get values =>
      _$readinessDtoStatusEnumValues;
  static ReadinessDtoStatusEnum valueOf(String name) =>
      _$readinessDtoStatusEnumValueOf(name);
}

class ReadinessDtoDatabaseEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'up')
  static const ReadinessDtoDatabaseEnum up = _$readinessDtoDatabaseEnum_up;
  @BuiltValueEnumConst(wireName: r'down')
  static const ReadinessDtoDatabaseEnum down = _$readinessDtoDatabaseEnum_down;

  static Serializer<ReadinessDtoDatabaseEnum> get serializer =>
      _$readinessDtoDatabaseEnumSerializer;

  const ReadinessDtoDatabaseEnum._(String name) : super(name);

  static BuiltSet<ReadinessDtoDatabaseEnum> get values =>
      _$readinessDtoDatabaseEnumValues;
  static ReadinessDtoDatabaseEnum valueOf(String name) =>
      _$readinessDtoDatabaseEnumValueOf(name);
}
