import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/core/app_config.dart';
import 'package:woutalma_keur/app/core/feedback/interaction_feedback.dart';
import 'package:woutalma_keur/app/domain/voice_note_service.dart';
import 'package:woutalma_keur/app/ui/ui.dart';

/// Source jouable pour [asset].
///
/// Le serveur sert les messages vocaux sans en-tête `Range` ; le lecteur
/// Android d'entrée de gamme échoue à les diffuser. On télécharge donc une
/// fois dans le cache, puis on lit un fichier local.
Future<Source> voiceNoteSource(String asset) async {
  if (asset.startsWith('api:') && !kIsWeb)
    return DeviceFileSource(await _download(asset.substring(4)));
  if (asset.startsWith('api:'))
    return UrlSource(
      '${AppConfig.apiBaseUrl}/properties/voice-notes/${asset.substring(4)}',
    );
  if (asset.startsWith('http')) return UrlSource(asset);
  return DeviceFileSource(asset);
}

Future<String> _download(String id) async {
  final dir = Directory('${(await getTemporaryDirectory()).path}/voice-notes');
  final file = File('${dir.path}/$id.m4a');
  if (file.existsSync()) return file.path;
  await dir.create(recursive: true);
  final request = await HttpClient().getUrl(
    Uri.parse('${AppConfig.apiBaseUrl}/properties/voice-notes/$id'),
  );
  final response = await request.close();
  if (response.statusCode != 200)
    throw HttpException('${response.statusCode}', uri: request.uri);
  // Fichier d'attente puis renommage : une coupure de réseau laisserait
  // sinon un fichier tronqué que la lecture suivante réutiliserait.
  final partial = File('${file.path}.part');
  await response.pipe(partial.openWrite());
  await partial.rename(file.path);
  return file.path;
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
  bool _failed = false, _loading = false;

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
    final feedback = context.read<InteractionFeedbackService?>();
    final l = context.l10n;
    try {
      if (_state == PlayerState.playing) {
        await _player.pause();
        feedback?.announce(l.voiceNotePaused);
      } else if (_state == PlayerState.paused) {
        await _player.resume();
        feedback?.announce(l.voiceNotePlaying);
      } else {
        setState(() => _loading = true);
        final source = await voiceNoteSource(widget.asset);
        if (!mounted) return;
        setState(() => _loading = false);
        await _player.play(source);
        feedback?.announce(l.voiceNotePlaying);
      }
      if (_failed && mounted) setState(() => _failed = false);
    } on Object catch (e) {
      debugPrint('[wk] lecture vocale impossible : $e');
      if (mounted) {
        setState(() {
          _loading = false;
          _failed = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final playing = _state == PlayerState.playing;
    final progress = _duration.inMilliseconds == 0
        ? 0.0
        : (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0);
    final l = context.l10n;
    final time = _loading
        ? l.stateLoading
        : _duration == Duration.zero
        ? _clock(_position)
        : '${_clock(_position)} / ${_clock(_duration)}';
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
              MergeSemantics(
                child: Semantics(
                  label: playing ? l.voiceNotePause : l.voiceNotePlay,
                  child: FTappable(
                    onPress: _toggle,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: Touch.min,
                      height: Touch.min,
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
    final feedback = context.read<InteractionFeedbackService?>();
    if (!await widget.recorder.requestPermission()) {
      if (mounted) setState(() => _error = l.voiceNotePermissionDenied);
      return;
    }
    try {
      await widget.recorder.start();
    } on Object catch (e) {
      debugPrint('[wk] enregistrement impossible : $e');
      feedback?.emit(FeedbackIntent.error);
      if (mounted) setState(() => _error = l.voiceNoteFailed);
      return;
    }
    if (!mounted) return;
    feedback?.emit(FeedbackIntent.recordingStarted);
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
    final l = context.l10n;
    final feedback = context.read<InteractionFeedbackService?>();
    String? path;
    try {
      path = await widget.recorder.stop();
    } on Object catch (e) {
      debugPrint('[wk] arrêt de l\'enregistrement impossible : $e');
    }
    if (!mounted) return;
    if (path == null) {
      feedback?.emit(FeedbackIntent.error);
      setState(() => _error = l.voiceNoteFailed);
      return;
    }
    feedback?.emit(FeedbackIntent.recordingStopped);
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
            Semantics(
              liveRegion: true,
              // Le compteur change chaque seconde : l'annoncer à chaque tic
              // couvrirait tout le reste. L'état, lui, s'annonce une fois.
              label: l.voiceNoteRecordingStarted,
              child: ExcludeSemantics(
                child: Row(
                  children: [
                    Container(
                      width: Touch.min,
                      height: Touch.min,
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
              ),
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
                onPressed: _start,
              ),
              const Spacer(),
              AppButton(
                l.voiceNoteDelete,
                icon: FIcons.trash2,
                variant: AppButtonVariant.ghost,
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
