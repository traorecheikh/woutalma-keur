// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'liveness_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$LivenessDto extends LivenessDto {
  @override
  final String status;
  @override
  final num uptimeSeconds;

  factory _$LivenessDto([void Function(LivenessDtoBuilder)? updates]) =>
      (LivenessDtoBuilder()..update(updates))._build();

  _$LivenessDto._({required this.status, required this.uptimeSeconds})
      : super._();
  @override
  LivenessDto rebuild(void Function(LivenessDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  LivenessDtoBuilder toBuilder() => LivenessDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is LivenessDto &&
        status == other.status &&
        uptimeSeconds == other.uptimeSeconds;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, uptimeSeconds.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'LivenessDto')
          ..add('status', status)
          ..add('uptimeSeconds', uptimeSeconds))
        .toString();
  }
}

class LivenessDtoBuilder implements Builder<LivenessDto, LivenessDtoBuilder> {
  _$LivenessDto? _$v;

  String? _status;
  String? get status => _$this._status;
  set status(String? status) => _$this._status = status;

  num? _uptimeSeconds;
  num? get uptimeSeconds => _$this._uptimeSeconds;
  set uptimeSeconds(num? uptimeSeconds) =>
      _$this._uptimeSeconds = uptimeSeconds;

  LivenessDtoBuilder() {
    LivenessDto._defaults(this);
  }

  LivenessDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _status = $v.status;
      _uptimeSeconds = $v.uptimeSeconds;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(LivenessDto other) {
    _$v = other as _$LivenessDto;
  }

  @override
  void update(void Function(LivenessDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  LivenessDto build() => _build();

  _$LivenessDto _build() {
    final _$result = _$v ??
        _$LivenessDto._(
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'LivenessDto', 'status'),
          uptimeSeconds: BuiltValueNullFieldError.checkNotNull(
              uptimeSeconds, r'LivenessDto', 'uptimeSeconds'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
