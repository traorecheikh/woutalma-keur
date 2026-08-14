//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'liveness_dto.g.dart';

/// LivenessDto
///
/// Properties:
/// * [status]
/// * [uptimeSeconds]
@BuiltValue()
abstract class LivenessDto implements Built<LivenessDto, LivenessDtoBuilder> {
  @BuiltValueField(wireName: r'status')
  String get status;

  @BuiltValueField(wireName: r'uptimeSeconds')
  num get uptimeSeconds;

  LivenessDto._();

  factory LivenessDto([void updates(LivenessDtoBuilder b)]) = _$LivenessDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(LivenessDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<LivenessDto> get serializer => _$LivenessDtoSerializer();
}

class _$LivenessDtoSerializer implements PrimitiveSerializer<LivenessDto> {
  @override
  final Iterable<Type> types = const [LivenessDto, _$LivenessDto];

  @override
  final String wireName = r'LivenessDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    LivenessDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(String),
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
    LivenessDto object, {
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
    required LivenessDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.status = valueDes;
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
  LivenessDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = LivenessDtoBuilder();
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
