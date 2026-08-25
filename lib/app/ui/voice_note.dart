import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:woutalma_keur/app/core/app_config.dart';
import 'package:woutalma_keur/app/domain/voice_note_service.dart';
import 'package:woutalma_keur/app/ui/ui.dart';

Source voiceNoteSource(String asset) {
  if (asset.startsWith('api:'))
    return UrlSource(
      '${AppConfig.apiBaseUrl}/properties/voice-notes/${asset.substring(4)}',
    );
  if (asset.startsWith('http')) return UrlSource(asset);
  return DeviceFileSource(asset);
}

String _clock(Duration d) =>
    '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

class AppVoiceNotePlayer extends StatefulWidget {
  const AppVoiceNotePlayer({super.key, required this.asset, this.title});
  final String asset;
  final String? title;
  @override
  State<AppVoiceNotePlayer> createState() => _PlayerState();
}

class _PlayerState extends State<AppVoiceNotePlayer> {
  final _player = AudioPlayer();
  final _subs = <StreamSubscription<Object?>>[];
  Duration _position = Duration.zero, _duration = Duration.zero;
  PlayerState _state = PlayerState.stopped;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _player.setReleaseMode(ReleaseMode.stop);
    _subs.addAll([
      _player.onDurationChanged.listen(
        (d) => mounted ? setState(() => _duration = d) : null,
      ),
      _player.onPositionChanged.listen(
        (p) => mounted ? setState(() => _position = p) : null,
      ),
      _player.onPlayerStateChanged.listen(
        (s) => mounted ? setState(() => _state = s) : null,
      ),
      _player.onPlayerComplete.listen(
        (_) => mounted ? setState(() => _position = Duration.zero) : null,
      ),
    ]);
  }

  @override
  void didUpdateWidget(AppVoiceNotePlayer old) {
    super.didUpdateWidget(old);
    if (old.asset != widget.asset) {
      unawaited(_player.stop());
      _position = _duration = Duration.zero;
      _failed = false;
    }
  }

  @override
  void dispose() {
    for (final s in _subs) unawaited(s.cancel());
    unawaited(_player.dispose());
    super.dispose();
  }

  Future<void> _toggle() async {
    try {
      if (_state == PlayerState.playing) {
        await _player.pause();
      } else if (_state == PlayerState.paused) {
        await _player.resume();
      } else {
        await _player.play(voiceNoteSource(widget.asset));
      }
      if (_failed && mounted) setState(() => _failed = false);
    } on Object catch (e) {
      debugPrint('[wk] lecture vocale impossible : $e');
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final playing = _state == PlayerState.playing;
    final progress = _duration.inMilliseconds == 0
        ? 0.0
        : (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0);
    final time = _duration == Duration.zero
        ? _clock(_position)
        : '${_clock(_position)} / ${_clock(_duration)}';
    final l = context.l10n;
    return AppCard(
      padding: const EdgeInsets.all(Insets.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.title != null) ...[
            Text(
              widget.title!,
              style: context.text.labelLarge!.copyWith(
                color: context.tones.inkSecondary,
              ),
            ),
            const SizedBox(height: Insets.md),
          ],
          Row(
            children: [
              Semantics(
                button: true,
                label: playing ? l.voiceNotePause : l.voiceNotePlay,
                excludeSemantics: true,
                child: FTappable(
                  onPress: _toggle,
                  child: Container(
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: context.colors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      playing ? FIcons.pause : FIcons.play,
                      color: context.colors.onPrimary,
                      size: 26,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: Insets.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Bar(value: progress, color: context.colors.primary),
                    const SizedBox(height: Insets.sm),
                    Text(
                      _failed ? l.voiceNoteUnavailable : time,
                      style: context.text.bodySmall!.copyWith(
                        color: _failed
                            ? context.tones.danger
                            : context.tones.inkSecondary,
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

class AppVoiceNoteRecorder extends StatefulWidget {
  const AppVoiceNoteRecorder({
    super.key,
    required this.asset,
    required this.recorder,
    required this.onChanged,
    this.constraints = const VoiceNoteConstraints(),
  });
  final String? asset;
  final VoiceNoteRecorder recorder;
  final ValueChanged<String?> onChanged;
  final VoiceNoteConstraints constraints;
  @override
  State<AppVoiceNoteRecorder> createState() => _RecorderState();
}

class _RecorderState extends State<AppVoiceNoteRecorder> {
  bool _recording = false;
  int _seconds = 0;
  Timer? _ticker;
  String? _error;

  @override
  void dispose() {
    _ticker?.cancel();
    if (_recording) unawaited(widget.recorder.cancel());
    super.dispose();
  }

  Future<void> _start() async {
    final l = context.l10n;
    if (!await widget.recorder.requestPermission()) {
      if (mounted) setState(() => _error = l.voiceNotePermissionDenied);
      return;
    }
    try {
      await widget.recorder.start();
    } on Object catch (e) {
      debugPrint('[wk] enregistrement impossible : $e');
      if (mounted) setState(() => _error = l.voiceNoteFailed);
      return;
    }
    if (!mounted) return;
    setState(() {
      _recording = true;
      _seconds = 0;
      _error = null;
    });
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _seconds++);
      if (_seconds >= widget.constraints.maxDuration.inSeconds)
        unawaited(_stop());
    });
  }

  Future<void> _stop() async {
    _ticker?.cancel();
    if (!_recording) return;
    _recording = false;
    final path = await widget.recorder.stop();
    if (!mounted) return;
    if (path == null) {
      setState(() => _error = context.l10n.voiceNoteFailed);
      return;
    }
    setState(() {});
    widget.onChanged(path);
  }

  void _delete() {
    final a = widget.asset;
    if (a != null && !a.startsWith('api:') && !kIsWeb)
      unawaited(File(a).delete().catchError((_) => File(a)));
    widget.onChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final asset = widget.asset;
    final Widget body;
    if (_recording) {
      body = AppCard(
        padding: const EdgeInsets.all(Insets.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: context.tones.danger,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(FIcons.mic, color: context.colors.onPrimary),
                ),
                const SizedBox(width: Insets.lg),
                Expanded(
                  child: Text(
                    l.voiceNoteRecording(_seconds),
                    style: context.text.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Insets.md),
            _Bar(
              value: _seconds / widget.constraints.maxDuration.inSeconds,
              color: context.tones.danger,
            ),
            const SizedBox(height: Insets.lg),
            AppButton(
              l.voiceNoteStop,
              icon: FIcons.square,
              variant: AppButtonVariant.secondary,
              onPressed: _stop,
            ),
          ],
        ),
      );
    } else if (asset == null || asset.isEmpty) {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppButton(
            l.voiceNoteRecord,
            icon: FIcons.mic,
            variant: AppButtonVariant.secondary,
            onPressed: _start,
          ),
          const SizedBox(height: Insets.sm),
          Text(
            l.voiceNoteHint,
            style: context.text.bodySmall!.copyWith(
              color: context.tones.inkSecondary,
            ),
          ),
        ],
      );
    } else {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppVoiceNotePlayer(asset: asset, title: l.voiceNoteReady),
          const SizedBox(height: Insets.sm),
          Row(
            children: [
              AppButton(
                l.voiceNoteRedo,
                icon: FIcons.mic,
                variant: AppButtonVariant.ghost,
                size: 40,
                onPressed: _start,
              ),
              const Spacer(),
              AppButton(
                l.voiceNoteDelete,
                icon: FIcons.trash2,
                variant: AppButtonVariant.ghost,
                size: 40,
                onPressed: _delete,
              ),
            ],
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l.voiceNoteLabel,
          style: context.text.labelLarge!.copyWith(
            color: context.tones.inkSecondary,
          ),
        ),
        const SizedBox(height: Insets.sm),
        body,
        if (_error != null) ...[
          const SizedBox(height: Insets.sm),
          Text(
            _error!,
            style: context.text.bodySmall!.copyWith(
              color: context.tones.danger,
            ),
          ),
        ],
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.value, required this.color});
  final double value;
  final Color color;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: Radii.full,
    child: SizedBox(
      height: 6,
      child: ColoredBox(
        color: context.tones.sunken,
        child: FractionallySizedBox(
          alignment: AlignmentDirectional.centerStart,
          widthFactor: value.clamp(0, 1),
          child: ColoredBox(color: color),
        ),
      ),
    ),
  );
}
