//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'reply_review_dto.g.dart';

/// ReplyReviewDto
///
/// Properties:
/// * [reply]
@BuiltValue()
abstract class ReplyReviewDto
    implements Built<ReplyReviewDto, ReplyReviewDtoBuilder> {
  @BuiltValueField(wireName: r'reply')
  String get reply;

  ReplyReviewDto._();

  factory ReplyReviewDto([void updates(ReplyReviewDtoBuilder b)]) =
      _$ReplyReviewDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReplyReviewDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReplyReviewDto> get serializer =>
      _$ReplyReviewDtoSerializer();
}

class _$ReplyReviewDtoSerializer
    implements PrimitiveSerializer<ReplyReviewDto> {
  @override
  final Iterable<Type> types = const [ReplyReviewDto, _$ReplyReviewDto];

  @override
  final String wireName = r'ReplyReviewDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReplyReviewDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'reply';
    yield serializers.serialize(
      object.reply,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ReplyReviewDto object, {
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
    required ReplyReviewDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'reply':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.reply = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ReplyReviewDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReplyReviewDtoBuilder();
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
