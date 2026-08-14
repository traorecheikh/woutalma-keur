// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_contact_outcome_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const UpdateContactOutcomeDtoOutcomeEnum
    _$updateContactOutcomeDtoOutcomeEnum_ATTEMPTED =
    const UpdateContactOutcomeDtoOutcomeEnum._('ATTEMPTED');
const UpdateContactOutcomeDtoOutcomeEnum
    _$updateContactOutcomeDtoOutcomeEnum_REACHED =
    const UpdateContactOutcomeDtoOutcomeEnum._('REACHED');
const UpdateContactOutcomeDtoOutcomeEnum
    _$updateContactOutcomeDtoOutcomeEnum_NO_ANSWER =
    const UpdateContactOutcomeDtoOutcomeEnum._('NO_ANSWER');

UpdateContactOutcomeDtoOutcomeEnum _$updateContactOutcomeDtoOutcomeEnumValueOf(
    String name) {
  switch (name) {
    case 'ATTEMPTED':
      return _$updateContactOutcomeDtoOutcomeEnum_ATTEMPTED;
    case 'REACHED':
      return _$updateContactOutcomeDtoOutcomeEnum_REACHED;
    case 'NO_ANSWER':
      return _$updateContactOutcomeDtoOutcomeEnum_NO_ANSWER;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<UpdateContactOutcomeDtoOutcomeEnum>
    _$updateContactOutcomeDtoOutcomeEnumValues = BuiltSet<
        UpdateContactOutcomeDtoOutcomeEnum>(const <UpdateContactOutcomeDtoOutcomeEnum>[
  _$updateContactOutcomeDtoOutcomeEnum_ATTEMPTED,
  _$updateContactOutcomeDtoOutcomeEnum_REACHED,
  _$updateContactOutcomeDtoOutcomeEnum_NO_ANSWER,
]);

Serializer<UpdateContactOutcomeDtoOutcomeEnum>
    _$updateContactOutcomeDtoOutcomeEnumSerializer =
    _$UpdateContactOutcomeDtoOutcomeEnumSerializer();

class _$UpdateContactOutcomeDtoOutcomeEnumSerializer
    implements PrimitiveSerializer<UpdateContactOutcomeDtoOutcomeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ATTEMPTED': 'ATTEMPTED',
    'REACHED': 'REACHED',
    'NO_ANSWER': 'NO_ANSWER',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ATTEMPTED': 'ATTEMPTED',
    'REACHED': 'REACHED',
    'NO_ANSWER': 'NO_ANSWER',
  };

  @override
  final Iterable<Type> types = const <Type>[UpdateContactOutcomeDtoOutcomeEnum];
  @override
  final String wireName = 'UpdateContactOutcomeDtoOutcomeEnum';

  @override
  Object serialize(
          Serializers serializers, UpdateContactOutcomeDtoOutcomeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  UpdateContactOutcomeDtoOutcomeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      UpdateContactOutcomeDtoOutcomeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$UpdateContactOutcomeDto extends UpdateContactOutcomeDto {
  @override
  final UpdateContactOutcomeDtoOutcomeEnum outcome;

  factory _$UpdateContactOutcomeDto(
          [void Function(UpdateContactOutcomeDtoBuilder)? updates]) =>
      (UpdateContactOutcomeDtoBuilder()..update(updates))._build();

  _$UpdateContactOutcomeDto._({required this.outcome}) : super._();
  @override
  UpdateContactOutcomeDto rebuild(
          void Function(UpdateContactOutcomeDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UpdateContactOutcomeDtoBuilder toBuilder() =>
      UpdateContactOutcomeDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UpdateContactOutcomeDto && outcome == other.outcome;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, outcome.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UpdateContactOutcomeDto')
          ..add('outcome', outcome))
        .toString();
  }
}

class UpdateContactOutcomeDtoBuilder
    implements
        Builder<UpdateContactOutcomeDto, UpdateContactOutcomeDtoBuilder> {
  _$UpdateContactOutcomeDto? _$v;

  UpdateContactOutcomeDtoOutcomeEnum? _outcome;
  UpdateContactOutcomeDtoOutcomeEnum? get outcome => _$this._outcome;
  set outcome(UpdateContactOutcomeDtoOutcomeEnum? outcome) =>
      _$this._outcome = outcome;

  UpdateContactOutcomeDtoBuilder() {
    UpdateContactOutcomeDto._defaults(this);
  }

  UpdateContactOutcomeDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _outcome = $v.outcome;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UpdateContactOutcomeDto other) {
    _$v = other as _$UpdateContactOutcomeDto;
  }

  @override
  void update(void Function(UpdateContactOutcomeDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UpdateContactOutcomeDto build() => _build();

  _$UpdateContactOutcomeDto _build() {
    final _$result = _$v ??
        _$UpdateContactOutcomeDto._(
          outcome: BuiltValueNullFieldError.checkNotNull(
              outcome, r'UpdateContactOutcomeDto', 'outcome'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
