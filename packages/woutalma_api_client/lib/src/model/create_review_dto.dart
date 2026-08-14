//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_review_dto.g.dart';

/// CreateReviewDto
///
/// Properties:
/// * [contactId]
/// * [rating]
/// * [responsiveness]
/// * [accuracy]
/// * [courtesy]
/// * [comment]
@BuiltValue()
abstract class CreateReviewDto
    implements Built<CreateReviewDto, CreateReviewDtoBuilder> {
  @BuiltValueField(wireName: r'contactId')
  String get contactId;

  @BuiltValueField(wireName: r'rating')
  num get rating;

  @BuiltValueField(wireName: r'responsiveness')
  num? get responsiveness;

  @BuiltValueField(wireName: r'accuracy')
  num? get accuracy;

  @BuiltValueField(wireName: r'courtesy')
  num? get courtesy;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  CreateReviewDto._();

  factory CreateReviewDto([void updates(CreateReviewDtoBuilder b)]) =
      _$CreateReviewDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateReviewDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateReviewDto> get serializer =>
      _$CreateReviewDtoSerializer();
}

class _$CreateReviewDtoSerializer
    implements PrimitiveSerializer<CreateReviewDto> {
  @override
  final Iterable<Type> types = const [CreateReviewDto, _$CreateReviewDto];

  @override
  final String wireName = r'CreateReviewDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateReviewDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'contactId';
    yield serializers.serialize(
      object.contactId,
      specifiedType: const FullType(String),
    );
    yield r'rating';
    yield serializers.serialize(
      object.rating,
      specifiedType: const FullType(num),
    );
    if (object.responsiveness != null) {
      yield r'responsiveness';
      yield serializers.serialize(
        object.responsiveness,
        specifiedType: const FullType(num),
      );
    }
    if (object.accuracy != null) {
      yield r'accuracy';
      yield serializers.serialize(
        object.accuracy,
        specifiedType: const FullType(num),
      );
    }
    if (object.courtesy != null) {
      yield r'courtesy';
      yield serializers.serialize(
        object.courtesy,
        specifiedType: const FullType(num),
      );
    }
    if (object.comment != null) {
      yield r'comment';
      yield serializers.serialize(
        object.comment,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CreateReviewDto object, {
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
    required CreateReviewDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'contactId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.contactId = valueDes;
          break;
        case r'rating':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.rating = valueDes;
          break;
        case r'responsiveness':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.responsiveness = valueDes;
          break;
        case r'accuracy':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.accuracy = valueDes;
          break;
        case r'courtesy':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.courtesy = valueDes;
          break;
        case r'comment':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.comment = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CreateReviewDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateReviewDtoBuilder();
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
