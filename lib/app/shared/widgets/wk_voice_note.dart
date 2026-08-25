import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/core/app_config.dart';
import 'package:woutalma_keur/app/core/feedback/interaction_feedback.dart';
import 'package:woutalma_keur/app/domain/voice_note_service.dart';
import 'package:woutalma_keur/app/shared/theme/wk_motion.dart';
import 'package:woutalma_keur/app/shared/theme/wk_spacing.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_button.dart';

Source voiceNoteSource(String asset) {
  const String prefix = 'api:';
  if (asset.startsWith(prefix)) {
    return UrlSource(
      '${AppConfig.apiBaseUrl}/properties/voice-notes/'
      '${asset.substring(prefix.length)}',
    );
  }
  if (asset.startsWith('http://') || asset.startsWith('https://')) {
    return UrlSource(asset);
  }
  return DeviceFileSource(asset);
}

String _clock(Duration d) {
  final int minutes = d.inMinutes;
  final int seconds = d.inSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

/// Lecteur d'un message vocal.
class WkVoiceNotePlayer extends StatefulWidget {
  const WkVoiceNotePlayer({required this.asset, this.title, super.key});

  final String asset;

  final String? title;

  @override
  State<WkVoiceNotePlayer> createState() => _WkVoiceNotePlayerState();
}

class _WkVoiceNotePlayerState extends State<WkVoiceNotePlayer> {
  final AudioPlayer _player = AudioPlayer();
  final List<StreamSubscription<Object?>> _subscriptions =
      <StreamSubscription<Object?>>[];
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  PlayerState _state = PlayerState.stopped;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _player.setReleaseMode(ReleaseMode.stop);
    _subscriptions.addAll(<StreamSubscription<Object?>>[
      _player.onDurationChanged.listen((Duration d) {
        if (mounted) setState(() => _duration = d);
      }),
      _player.onPositionChanged.listen((Duration p) {
        if (mounted) setState(() => _position = p);
      }),
      _player.onPlayerStateChanged.listen((PlayerState s) {
        if (mounted) setState(() => _state = s);
      }),
      _player.onPlayerComplete.listen((_) {
        if (mounted) setState(() => _position = Duration.zero);
      }),
    ]);
  }

  @override
  void didUpdateWidget(WkVoiceNotePlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.asset != widget.asset) {
      unawaited(_player.stop());
      _position = Duration.zero;
      _duration = Duration.zero;
      _failed = false;
    }
  }

  @override
  void dispose() {
    for (final StreamSubscription<Object?> s in _subscriptions) {
      unawaited(s.cancel());
    }
    unawaited(_player.dispose());
    super.dispose();
  }

  Future<void> _toggle() async {
    context.read<InteractionFeedbackService?>()?.emit(FeedbackIntent.selection);
    try {
      if (_state == PlayerState.playing) {
        await _player.pause();
      } else if (_state == PlayerState.paused) {
        await _player.resume();
      } else {
        await _player.play(voiceNoteSource(widget.asset));
      }
      if (_failed && mounted) setState(() => _failed = false);
    } on Object catch (error) {
      debugPrint('[wk] lecture vocale impossible : $error');
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool playing = _state == PlayerState.playing;
    final double progress = _duration.inMilliseconds == 0
        ? 0
        : (_position.inMilliseconds / _duration.inMilliseconds).clamp(0, 1);
    final String time = _duration == Duration.zero
        ? _clock(_position)
        : '${_clock(_position)} / ${_clock(_duration)}';

    return Container(
      padding: const EdgeInsets.all(WkSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.primaryContainer,
        borderRadius: BorderRadius.circular(WkRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (widget.title != null) ...<Widget>[
            Text(
              widget.title!,
              style: context.text.labelMedium?.copyWith(
                color: context.colors.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: WkSpacing.sm),
          ],
          Row(
            children: <Widget>[
              Semantics(
                button: true,
                label: playing
                    ? context.l10n.voiceNotePause
                    : context.l10n.voiceNotePlay,
                child: Material(
                  color: context.colors.primary,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _toggle,
                    child: SizedBox(
                      width: WkTouch.min,
                      height: WkTouch.min,
                      child: Icon(
                        playing ? Icons.pause : Icons.play_arrow,
                        size: 32,
                        color: context.colors.onPrimary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: WkSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _Bar(value: progress, color: context.colors.primary),
                    const SizedBox(height: WkSpacing.sm),
                    Text(
                      _failed ? context.l10n.voiceNoteUnavailable : time,
                      style: context.text.bodySmall?.copyWith(
                        color: _failed
                            ? context.colors.error
                            : context.colors.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Enregistreur de B03 : repos, enregistrement, vocal prêt.
class WkVoiceNoteRecorder extends StatefulWidget {
  const WkVoiceNoteRecorder({
    required this.asset,
    required this.recorder,
    required this.onChanged,
    this.constraints = const VoiceNoteConstraints(),
    super.key,
  });

  final String? asset;
  final VoiceNoteRecorder recorder;
  final ValueChanged<String?> onChanged;
  final VoiceNoteConstraints constraints;

  @override
  State<WkVoiceNoteRecorder> createState() => _WkVoiceNoteRecorderState();
}

class _WkVoiceNoteRecorderState extends State<WkVoiceNoteRecorder> {
  bool _recording = false;
  int _elapsedSeconds = 0;
  Timer? _ticker;
  String? _error;

  @override
  void dispose() {
    _ticker?.cancel();
    if (_recording) {
      unawaited(widget.recorder.cancel());
    }
    super.dispose();
  }

  Future<void> _start() async {
    final InteractionFeedbackService? feedback = context
        .read<InteractionFeedbackService?>();
    if (!await widget.recorder.requestPermission()) {
      if (!mounted) return;
      setState(() => _error = context.l10n.voiceNotePermissionDenied);
      feedback?.emit(FeedbackIntent.error);
      return;
    }
    try {
      await widget.recorder.start();
    } on Object catch (error) {
      debugPrint('[wk] enregistrement impossible : $error');
      if (!mounted) return;
      setState(() => _error = context.l10n.voiceNoteFailed);
      feedback?.emit(FeedbackIntent.error);
      return;
    }
    if (!mounted) return;
    feedback?.emit(FeedbackIntent.selection);
    setState(() {
      _recording = true;
      _elapsedSeconds = 0;
      _error = null;
    });
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _elapsedSeconds++);
      if (_elapsedSeconds >= widget.constraints.maxDuration.inSeconds) {
        unawaited(_stop());
      }
    });
  }

  Future<void> _stop() async {
    _ticker?.cancel();
    _ticker = null;
    if (!_recording) return;
    _recording = false;
    final String? path = await widget.recorder.stop();
    if (!mounted) return;
    if (path == null) {
      setState(() => _error = context.l10n.voiceNoteFailed);
      context.read<InteractionFeedbackService?>()?.emit(FeedbackIntent.error);
      return;
    }
    setState(() {});
    context.read<InteractionFeedbackService?>()?.emit(FeedbackIntent.success);
    widget.onChanged(path);
  }

  void _delete() {
    final String? asset = widget.asset;
    if (asset != null && !asset.startsWith('api:') && !kIsWeb) {
      unawaited(File(asset).delete().catchError((_) => File(asset)));
    }
    context.read<InteractionFeedbackService?>()?.emit(FeedbackIntent.selection);
    widget.onChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    final String? asset = widget.asset;
    final WkMotion motion = WkMotion.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          context.l10n.voiceNoteLabel,
          style: context.text.labelMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: WkSpacing.sm),
        AnimatedSwitcher(
          duration: motion.standard,
          child: _recording
              ? _RecordingCard(
                  key: const ValueKey<String>('recording'),
                  seconds: _elapsedSeconds,
                  maxSeconds: widget.constraints.maxDuration.inSeconds,
                  onStop: _stop,
                )
              : asset == null || asset.isEmpty
              ? Column(
                  key: const ValueKey<String>('idle'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    WkButton(
                      label: context.l10n.voiceNoteRecord,
                      icon: Icons.mic_none_outlined,
                      variant: WkButtonVariant.secondary,
                      onPressed: _start,
                    ),
                    const SizedBox(height: WkSpacing.xs),
                    Text(
                      context.l10n.voiceNoteHint,
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                )
              : Column(
                  key: const ValueKey<String>('ready'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    WkVoiceNotePlayer(
                      asset: asset,
                      title: context.l10n.voiceNoteReady,
                    ),
                    const SizedBox(height: WkSpacing.sm),
                    Row(
                      children: <Widget>[
                        WkButton(
                          label: context.l10n.voiceNoteRedo,
                          icon: Icons.mic_none_outlined,
                          variant: WkButtonVariant.ghost,
                          expand: false,
                          onPressed: _start,
                        ),
                        const SizedBox(width: WkSpacing.sm),
                        WkButton(
                          label: context.l10n.voiceNoteDelete,
                          icon: Icons.delete_outline,
                          variant: WkButtonVariant.dangerGhost,
                          expand: false,
                          onPressed: _delete,
                        ),
                      ],
                    ),
                  ],
                ),
        ),
        if (_error != null) ...<Widget>[
          const SizedBox(height: WkSpacing.xs),
          Semantics(
            liveRegion: true,
            child: Text(
              _error!,
              style: context.text.bodySmall?.copyWith(
                color: context.colors.error,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _RecordingCard extends StatelessWidget {
  const _RecordingCard({
    required this.seconds,
    required this.maxSeconds,
    required this.onStop,
    super.key,
  });

  final int seconds;
  final int maxSeconds;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(WkSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.errorContainer,
        borderRadius: BorderRadius.circular(WkRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: WkTouch.min,
                height: WkTouch.min,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.colors.error,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.mic, color: context.colors.onError, size: 28),
              ),
              const SizedBox(width: WkSpacing.md),
              Expanded(
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    context.l10n.voiceNoteRecording(seconds),
                    style: context.text.titleMedium?.copyWith(
                      color: context.colors.onErrorContainer,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: WkSpacing.sm),
          _Bar(value: seconds / maxSeconds, color: context.colors.error),
          const SizedBox(height: WkSpacing.md),
          WkButton(
            label: context.l10n.voiceNoteStop,
            icon: Icons.stop_circle_outlined,
            variant: WkButtonVariant.secondary,
            onPressed: onStop,
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.value, required this.color});

  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(WkRadius.full),
      child: SizedBox(
        height: 6,
        child: ColoredBox(
          color: context.colors.surface,
          child: FractionallySizedBox(
            alignment: AlignmentDirectional.centerStart,
            widthFactor: value.clamp(0, 1),
            child: ColoredBox(color: color),
          ),
        ),
      ),
    );
  }
}
