import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/core/feedback/interaction_feedback.dart';
import 'package:woutalma_keur/app/domain/discovery.dart';
import 'package:woutalma_keur/app/domain/voice_service.dart';
import 'package:woutalma_keur/app/shared/theme/wk_motion.dart';
import 'package:woutalma_keur/app/shared/theme/wk_spacing.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_button.dart';

enum _VoicePhase { listening, processing, understood, failed }

/// M03 — Écoute vocale plein écran.
///
/// Trois états distinguables **sans lire** : écoute en rouge avec un cercle
/// qui respire, traitement en marine, résultat relu avant application. Rien
/// n'est appliqué sans que l'utilisateur ait vu ce qui a été compris.
class VoiceOverlay extends StatefulWidget {
  const VoiceOverlay({required this.service, super.key});

  final VoiceService service;

  static Future<DiscoveryFilters?> show(
    BuildContext context, {
    required VoiceService service,
  }) {
    return showModalBottomSheet<DiscoveryFilters>(
      context: context,
      // Racine, pas la branche : une feuille ouverte dans le Navigator
      // d'un onglet laisserait la barre d'onglets cliquable au-dessus de
      // sa propre barrière modale.
      useRootNavigator: true,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(WkRadius.xxl)),
      ),
      builder: (_) => VoiceOverlay(service: service),
    );
  }

  @override
  State<VoiceOverlay> createState() => _VoiceOverlayState();
}

class _VoiceOverlayState extends State<VoiceOverlay> {
  _VoicePhase _phase = _VoicePhase.listening;
  VoiceCommand? _command;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _listen());
  }

  Future<void> _listen() async {
    final InteractionFeedbackService? feedback = context
        .read<InteractionFeedbackService?>();
    setState(() {
      _phase = _VoicePhase.listening;
      _command = null;
    });
    // L'entrée en écoute est confirmée au doigt : il ne faut pas avoir à
    // regarder pour savoir que le micro est ouvert.
    feedback?.emit(FeedbackIntent.recordingStarted);

    final VoiceCommand? heard = await widget.service.listen();
    if (!mounted) {
      return;
    }

    feedback?.emit(FeedbackIntent.recordingStopped);
    setState(() {
      _command = heard;
      _phase = heard == null ? _VoicePhase.failed : _VoicePhase.understood;
    });

    if (heard == null) {
      feedback?.emit(FeedbackIntent.error);
    } else {
      feedback?.announce(heard.transcript);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      // Défilable : à ×1.3 le titre, la transcription et l'aide passent
      // chacun sur deux lignes et la dernière ligne sortait de l'écran, sans
      // rien pour aller la chercher.
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(WkSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(child: _Indicator(phase: _phase)),
            const SizedBox(height: WkSpacing.lg),
            Semantics(
              liveRegion: true,
              child: Text(
                switch (_phase) {
                  _VoicePhase.listening => context.l10n.voiceListening,
                  _VoicePhase.processing => context.l10n.voiceProcessing,
                  _VoicePhase.understood => context.l10n.voiceHeard,
                  _VoicePhase.failed => context.l10n.voiceNotUnderstood,
                },
                style: context.text.headlineMedium,
                textAlign: TextAlign.center,
              ),
            ),
            if (_command != null) ...<Widget>[
              const SizedBox(height: WkSpacing.sm),
              Text(
                _command!.transcript,
                style: context.text.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
            if (_phase == _VoicePhase.failed) ...<Widget>[
              const SizedBox(height: WkSpacing.sm),
              Text(
                context.l10n.voiceNotUnderstoodHelp,
                style: context.text.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: WkSpacing.lg),
            if (_phase == _VoicePhase.understood)
              WkButton(
                label: context.l10n.voiceApply,
                icon: Icons.search,
                // Relu avant d'être appliqué : on ne fait jamais disparaître
                // des résultats sur une interprétation que personne n'a vue.
                onPressed: () => Navigator.of(context).pop(_command!.filters),
              ),
            if (_phase == _VoicePhase.failed)
              WkButton(
                label: context.l10n.voiceRetry,
                icon: Icons.mic,
                onPressed: _listen,
              ),
            const SizedBox(height: WkSpacing.betweenTargets),
            WkButton(
              label: context.l10n.commonCancel,
              variant: WkButtonVariant.secondary,
              onPressed: () => Navigator.of(context).pop(),
            ),
            if (widget.service.isSimulated) ...<Widget>[
              const SizedBox(height: WkSpacing.md),
              Text(
                context.l10n.voiceSimulated,
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Indicator extends StatelessWidget {
  const _Indicator({required this.phase});

  final _VoicePhase phase;

  @override
  Widget build(BuildContext context) {
    // L'écoute était peinte en rouge d'erreur et l'échec en gris neutre : les
    // deux rôles étaient inversés. Quelqu'un qui a appris « rouge = c'est
    // raté » lisait « je vous écoute » comme une panne. Le rouge revient à
    // l'échec, l'écoute prend la couleur de marque, et c'est le mot affiché
    // au-dessus qui porte l'état.
    final Color background = switch (phase) {
      _VoicePhase.failed => context.colors.error,
      _ => context.colors.primary,
    };
    final IconData icon = switch (phase) {
      _VoicePhase.listening => Icons.mic,
      _VoicePhase.processing => Icons.more_horiz,
      _VoicePhase.understood => Icons.check,
      _VoicePhase.failed => Icons.mic_off,
    };

    return AnimatedContainer(
      // Une seule propriété animée, et pas d'onde continue : sur un Android
      // d'entrée de gamme, une animation permanente fait perdre des frames et
      // se lit comme « l'app ne m'a pas entendu ».
      duration: context.motion.standard,
      curve: WkMotion.standardCurve,
      width: WkTouch.voice,
      height: WkTouch.voice,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Icon(
        icon,
        size: 44,
        color: phase == _VoicePhase.failed
            ? context.colors.onError
            : context.colors.onPrimary,
      ),
    );
  }
}
