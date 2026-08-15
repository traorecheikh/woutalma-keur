// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reply_review_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ReplyReviewDto extends ReplyReviewDto {
  @override
  final String reply;

  factory _$ReplyReviewDto([void Function(ReplyReviewDtoBuilder)? updates]) =>
      (ReplyReviewDtoBuilder()..update(updates))._build();

  _$ReplyReviewDto._({required this.reply}) : super._();
  @override
  ReplyReviewDto rebuild(void Function(ReplyReviewDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReplyReviewDtoBuilder toBuilder() => ReplyReviewDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReplyReviewDto && reply == other.reply;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, reply.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ReplyReviewDto')..add('reply', reply))
        .toString();
  }
}

class ReplyReviewDtoBuilder
    implements Builder<ReplyReviewDto, ReplyReviewDtoBuilder> {
  _$ReplyReviewDto? _$v;

  String? _reply;
  String? get reply => _$this._reply;
  set reply(String? reply) => _$this._reply = reply;

  ReplyReviewDtoBuilder() {
    ReplyReviewDto._defaults(this);
  }

  ReplyReviewDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _reply = $v.reply;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReplyReviewDto other) {
    _$v = other as _$ReplyReviewDto;
  }

  @override
  void update(void Function(ReplyReviewDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReplyReviewDto build() => _build();

  _$ReplyReviewDto _build() {
    final _$result = _$v ??
        _$ReplyReviewDto._(
          reply: BuiltValueNullFieldError.checkNotNull(
              reply, r'ReplyReviewDto', 'reply'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
