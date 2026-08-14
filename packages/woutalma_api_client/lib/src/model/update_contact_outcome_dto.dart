//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'update_contact_outcome_dto.g.dart';

/// UpdateContactOutcomeDto
///
/// Properties:
/// * [outcome]
@BuiltValue()
abstract class UpdateContactOutcomeDto
    implements Built<UpdateContactOutcomeDto, UpdateContactOutcomeDtoBuilder> {
  @BuiltValueField(wireName: r'outcome')
  UpdateContactOutcomeDtoOutcomeEnum get outcome;
  // enum outcomeEnum {  ATTEMPTED,  REACHED,  NO_ANSWER,  };

  UpdateContactOutcomeDto._();

  factory UpdateContactOutcomeDto(
          [void updates(UpdateContactOutcomeDtoBuilder b)]) =
      _$UpdateContactOutcomeDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UpdateContactOutcomeDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UpdateContactOutcomeDto> get serializer =>
      _$UpdateContactOutcomeDtoSerializer();
}

class _$UpdateContactOutcomeDtoSerializer
    implements PrimitiveSerializer<UpdateContactOutcomeDto> {
  @override
  final Iterable<Type> types = const [
    UpdateContactOutcomeDto,
    _$UpdateContactOutcomeDto
  ];

  @override
  final String wireName = r'UpdateContactOutcomeDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UpdateContactOutcomeDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'outcome';
    yield serializers.serialize(
      object.outcome,
      specifiedType: const FullType(UpdateContactOutcomeDtoOutcomeEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    UpdateContactOutcomeDto object, {
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
    required UpdateContactOutcomeDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'outcome':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(UpdateContactOutcomeDtoOutcomeEnum),
          ) as UpdateContactOutcomeDtoOutcomeEnum;
          result.outcome = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UpdateContactOutcomeDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UpdateContactOutcomeDtoBuilder();
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

class UpdateContactOutcomeDtoOutcomeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'ATTEMPTED')
  static const UpdateContactOutcomeDtoOutcomeEnum ATTEMPTED =
      _$updateContactOutcomeDtoOutcomeEnum_ATTEMPTED;
  @BuiltValueEnumConst(wireName: r'REACHED')
  static const UpdateContactOutcomeDtoOutcomeEnum REACHED =
      _$updateContactOutcomeDtoOutcomeEnum_REACHED;
  @BuiltValueEnumConst(wireName: r'NO_ANSWER')
  static const UpdateContactOutcomeDtoOutcomeEnum NO_ANSWER =
      _$updateContactOutcomeDtoOutcomeEnum_NO_ANSWER;

  static Serializer<UpdateContactOutcomeDtoOutcomeEnum> get serializer =>
      _$updateContactOutcomeDtoOutcomeEnumSerializer;

  const UpdateContactOutcomeDtoOutcomeEnum._(String name) : super(name);

  static BuiltSet<UpdateContactOutcomeDtoOutcomeEnum> get values =>
      _$updateContactOutcomeDtoOutcomeEnumValues;
  static UpdateContactOutcomeDtoOutcomeEnum valueOf(String name) =>
      _$updateContactOutcomeDtoOutcomeEnumValueOf(name);
}
