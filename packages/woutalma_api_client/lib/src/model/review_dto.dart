//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'review_dto.g.dart';

/// ReviewDto
///
/// Properties:
/// * [id]
/// * [brokerId]
/// * [contactId]
/// * [rating]
/// * [responsiveness]
/// * [accuracy]
/// * [courtesy]
/// * [comment]
/// * [moderation]
/// * [brokerReply]
/// * [createdAt]
/// * [isPublic]
@BuiltValue()
abstract class ReviewDto implements Built<ReviewDto, ReviewDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'brokerId')
  String get brokerId;

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

  @BuiltValueField(wireName: r'moderation')
  ReviewDtoModerationEnum get moderation;
  // enum moderationEnum {  PENDING,  PUBLISHED,  REJECTED,  };

  @BuiltValueField(wireName: r'brokerReply')
  String? get brokerReply;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'isPublic')
  bool get isPublic;

  ReviewDto._();

  factory ReviewDto([void updates(ReviewDtoBuilder b)]) = _$ReviewDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReviewDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReviewDto> get serializer => _$ReviewDtoSerializer();
}

class _$ReviewDtoSerializer implements PrimitiveSerializer<ReviewDto> {
  @override
  final Iterable<Type> types = const [ReviewDto, _$ReviewDto];

  @override
  final String wireName = r'ReviewDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReviewDto object, {
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
        specifiedType: const FullType.nullable(num),
      );
    }
    if (object.accuracy != null) {
      yield r'accuracy';
      yield serializers.serialize(
        object.accuracy,
        specifiedType: const FullType.nullable(num),
      );
    }
    if (object.courtesy != null) {
      yield r'courtesy';
      yield serializers.serialize(
        object.courtesy,
        specifiedType: const FullType.nullable(num),
      );
    }
    if (object.comment != null) {
      yield r'comment';
      yield serializers.serialize(
        object.comment,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'moderation';
    yield serializers.serialize(
      object.moderation,
      specifiedType: const FullType(ReviewDtoModerationEnum),
    );
    if (object.brokerReply != null) {
      yield r'brokerReply';
      yield serializers.serialize(
        object.brokerReply,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'isPublic';
    yield serializers.serialize(
      object.isPublic,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ReviewDto object, {
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
    required ReviewDtoBuilder result,
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
        case r'moderation':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ReviewDtoModerationEnum),
          ) as ReviewDtoModerationEnum;
          result.moderation = valueDes;
          break;
        case r'brokerReply':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.brokerReply = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'isPublic':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isPublic = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ReviewDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReviewDtoBuilder();
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

class ReviewDtoModerationEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'PENDING')
  static const ReviewDtoModerationEnum PENDING =
      _$reviewDtoModerationEnum_PENDING;
  @BuiltValueEnumConst(wireName: r'PUBLISHED')
  static const ReviewDtoModerationEnum PUBLISHED =
      _$reviewDtoModerationEnum_PUBLISHED;
  @BuiltValueEnumConst(wireName: r'REJECTED')
  static const ReviewDtoModerationEnum REJECTED =
      _$reviewDtoModerationEnum_REJECTED;

  static Serializer<ReviewDtoModerationEnum> get serializer =>
      _$reviewDtoModerationEnumSerializer;

  const ReviewDtoModerationEnum._(String name) : super(name);

  static BuiltSet<ReviewDtoModerationEnum> get values =>
      _$reviewDtoModerationEnumValues;
  static ReviewDtoModerationEnum valueOf(String name) =>
      _$reviewDtoModerationEnumValueOf(name);
}
