// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_review_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ReportReviewDto extends ReportReviewDto {
  @override
  final String? reason;

  factory _$ReportReviewDto([void Function(ReportReviewDtoBuilder)? updates]) =>
      (ReportReviewDtoBuilder()..update(updates))._build();

  _$ReportReviewDto._({this.reason}) : super._();
  @override
  ReportReviewDto rebuild(void Function(ReportReviewDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReportReviewDtoBuilder toBuilder() => ReportReviewDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReportReviewDto && reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ReportReviewDto')
          ..add('reason', reason))
        .toString();
  }
}

class ReportReviewDtoBuilder
    implements Builder<ReportReviewDto, ReportReviewDtoBuilder> {
  _$ReportReviewDto? _$v;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  ReportReviewDtoBuilder() {
    ReportReviewDto._defaults(this);
  }

  ReportReviewDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReportReviewDto other) {
    _$v = other as _$ReportReviewDto;
  }

  @override
  void update(void Function(ReportReviewDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReportReviewDto build() => _build();

  _$ReportReviewDto _build() {
    final _$result = _$v ??
        _$ReportReviewDto._(
          reason: reason,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
