//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'report_review_dto.g.dart';

/// ReportReviewDto
///
/// Properties:
/// * [reason]
@BuiltValue()
abstract class ReportReviewDto
    implements Built<ReportReviewDto, ReportReviewDtoBuilder> {
  @BuiltValueField(wireName: r'reason')
  String? get reason;

  ReportReviewDto._();

  factory ReportReviewDto([void updates(ReportReviewDtoBuilder b)]) =
      _$ReportReviewDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReportReviewDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReportReviewDto> get serializer =>
      _$ReportReviewDtoSerializer();
}

class _$ReportReviewDtoSerializer
    implements PrimitiveSerializer<ReportReviewDto> {
  @override
  final Iterable<Type> types = const [ReportReviewDto, _$ReportReviewDto];

  @override
  final String wireName = r'ReportReviewDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReportReviewDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.reason != null) {
      yield r'reason';
      yield serializers.serialize(
        object.reason,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ReportReviewDto object, {
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
    required ReportReviewDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.reason = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ReportReviewDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReportReviewDtoBuilder();
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
