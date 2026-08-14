// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'readiness_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ReadinessDtoStatusEnum _$readinessDtoStatusEnum_ok =
    const ReadinessDtoStatusEnum._('ok');
const ReadinessDtoStatusEnum _$readinessDtoStatusEnum_degraded =
    const ReadinessDtoStatusEnum._('degraded');

ReadinessDtoStatusEnum _$readinessDtoStatusEnumValueOf(String name) {
  switch (name) {
    case 'ok':
      return _$readinessDtoStatusEnum_ok;
    case 'degraded':
      return _$readinessDtoStatusEnum_degraded;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ReadinessDtoStatusEnum> _$readinessDtoStatusEnumValues =
    BuiltSet<ReadinessDtoStatusEnum>(const <ReadinessDtoStatusEnum>[
  _$readinessDtoStatusEnum_ok,
  _$readinessDtoStatusEnum_degraded,
]);

const ReadinessDtoDatabaseEnum _$readinessDtoDatabaseEnum_up =
    const ReadinessDtoDatabaseEnum._('up');
const ReadinessDtoDatabaseEnum _$readinessDtoDatabaseEnum_down =
    const ReadinessDtoDatabaseEnum._('down');

ReadinessDtoDatabaseEnum _$readinessDtoDatabaseEnumValueOf(String name) {
  switch (name) {
    case 'up':
      return _$readinessDtoDatabaseEnum_up;
    case 'down':
      return _$readinessDtoDatabaseEnum_down;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ReadinessDtoDatabaseEnum> _$readinessDtoDatabaseEnumValues =
    BuiltSet<ReadinessDtoDatabaseEnum>(const <ReadinessDtoDatabaseEnum>[
  _$readinessDtoDatabaseEnum_up,
  _$readinessDtoDatabaseEnum_down,
]);

Serializer<ReadinessDtoStatusEnum> _$readinessDtoStatusEnumSerializer =
    _$ReadinessDtoStatusEnumSerializer();
Serializer<ReadinessDtoDatabaseEnum> _$readinessDtoDatabaseEnumSerializer =
    _$ReadinessDtoDatabaseEnumSerializer();

class _$ReadinessDtoStatusEnumSerializer
    implements PrimitiveSerializer<ReadinessDtoStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ok': 'ok',
    'degraded': 'degraded',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ok': 'ok',
    'degraded': 'degraded',
  };

  @override
  final Iterable<Type> types = const <Type>[ReadinessDtoStatusEnum];
  @override
  final String wireName = 'ReadinessDtoStatusEnum';

  @override
  Object serialize(Serializers serializers, ReadinessDtoStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ReadinessDtoStatusEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ReadinessDtoStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ReadinessDtoDatabaseEnumSerializer
    implements PrimitiveSerializer<ReadinessDtoDatabaseEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'up': 'up',
    'down': 'down',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'up': 'up',
    'down': 'down',
  };

  @override
  final Iterable<Type> types = const <Type>[ReadinessDtoDatabaseEnum];
  @override
  final String wireName = 'ReadinessDtoDatabaseEnum';

  @override
  Object serialize(Serializers serializers, ReadinessDtoDatabaseEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ReadinessDtoDatabaseEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ReadinessDtoDatabaseEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ReadinessDto extends ReadinessDto {
  @override
  final ReadinessDtoStatusEnum status;
  @override
  final ReadinessDtoDatabaseEnum database;
  @override
  final num latencyMs;
  @override
  final num uptimeSeconds;

  factory _$ReadinessDto([void Function(ReadinessDtoBuilder)? updates]) =>
      (ReadinessDtoBuilder()..update(updates))._build();

  _$ReadinessDto._(
      {required this.status,
      required this.database,
      required this.latencyMs,
      required this.uptimeSeconds})
      : super._();
  @override
  ReadinessDto rebuild(void Function(ReadinessDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReadinessDtoBuilder toBuilder() => ReadinessDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReadinessDto &&
        status == other.status &&
        database == other.database &&
        latencyMs == other.latencyMs &&
        uptimeSeconds == other.uptimeSeconds;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, database.hashCode);
    _$hash = $jc(_$hash, latencyMs.hashCode);
    _$hash = $jc(_$hash, uptimeSeconds.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ReadinessDto')
          ..add('status', status)
          ..add('database', database)
          ..add('latencyMs', latencyMs)
          ..add('uptimeSeconds', uptimeSeconds))
        .toString();
  }
}

class ReadinessDtoBuilder
    implements Builder<ReadinessDto, ReadinessDtoBuilder> {
  _$ReadinessDto? _$v;

  ReadinessDtoStatusEnum? _status;
  ReadinessDtoStatusEnum? get status => _$this._status;
  set status(ReadinessDtoStatusEnum? status) => _$this._status = status;

  ReadinessDtoDatabaseEnum? _database;
  ReadinessDtoDatabaseEnum? get database => _$this._database;
  set database(ReadinessDtoDatabaseEnum? database) =>
      _$this._database = database;

  num? _latencyMs;
  num? get latencyMs => _$this._latencyMs;
  set latencyMs(num? latencyMs) => _$this._latencyMs = latencyMs;

  num? _uptimeSeconds;
  num? get uptimeSeconds => _$this._uptimeSeconds;
  set uptimeSeconds(num? uptimeSeconds) =>
      _$this._uptimeSeconds = uptimeSeconds;

  ReadinessDtoBuilder() {
    ReadinessDto._defaults(this);
  }

  ReadinessDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _status = $v.status;
      _database = $v.database;
      _latencyMs = $v.latencyMs;
      _uptimeSeconds = $v.uptimeSeconds;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReadinessDto other) {
    _$v = other as _$ReadinessDto;
  }

  @override
  void update(void Function(ReadinessDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReadinessDto build() => _build();

  _$ReadinessDto _build() {
    final _$result = _$v ??
        _$ReadinessDto._(
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'ReadinessDto', 'status'),
          database: BuiltValueNullFieldError.checkNotNull(
              database, r'ReadinessDto', 'database'),
          latencyMs: BuiltValueNullFieldError.checkNotNull(
              latencyMs, r'ReadinessDto', 'latencyMs'),
          uptimeSeconds: BuiltValueNullFieldError.checkNotNull(
              uptimeSeconds, r'ReadinessDto', 'uptimeSeconds'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
