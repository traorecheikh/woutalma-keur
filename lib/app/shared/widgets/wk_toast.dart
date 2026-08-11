import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/core/feedback/interaction_feedback.dart';
import 'package:woutalma_keur/app/shared/theme/wk_motion.dart';
import 'package:woutalma_keur/app/shared/theme/wk_spacing.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';

/// Message transitoire. Remplace `SnackBar`.
///
/// Ne porte jamais la seule explication d'une erreur, ni la seule action
/// destructive. Peut porter une annulation — et dans ce cas l'action n'a pas
/// eu de confirmation préalable, jamais les deux.
abstract final class WkToast {
  /// Affiche [message] pendant la durée prévue par
  /// `docs/INTERACTION-FEEDBACK.md` : 6 s, 10 s en gros texte ou avec un
  /// lecteur d'écran, parce qu'il faut le temps de lire avant de pouvoir
  /// revenir en arrière.
  static void show(
    BuildContext context, {
    required String message,
    String? undoLabel,
    VoidCallback? onUndo,
  }) {
    final OverlayState? overlay = Overlay.maybeOf(context);
    if (overlay == null) {
      return;
    }

    context.read<InteractionFeedbackService?>()?.announce(message);

    final Duration duration = WkMotion.transientFor(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (BuildContext ctx) => _ToastHost(
        message: message,
        undoLabel: undoLabel,
        onUndo: onUndo == null
            ? null
            : () {
                onUndo();
                if (entry.mounted) {
                  entry.remove();
                }
              },
        duration: duration,
        onExpired: () {
          if (entry.mounted) {
            entry.remove();
          }
        },
      ),
    );

    overlay.insert(entry);
  }
}

class _ToastHost extends StatefulWidget {
  const _ToastHost({
    required this.message,
    required this.duration,
    required this.onExpired,
    this.undoLabel,
    this.onUndo,
  });

  final String message;
  final String? undoLabel;
  final VoidCallback? onUndo;
  final Duration duration;
  final VoidCallback onExpired;

  @override
  State<_ToastHost> createState() => _ToastHostState();
}

class _ToastHostState extends State<_ToastHost> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Un `Timer` annulable, pas un `Future.delayed` : sans annulation, il
    // survit à l'écran qui l'a créé et continue de tourner pour rien.
    _timer = Timer(widget.duration, () {
      if (mounted) {
        widget.onExpired();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: WkSpacing.page,
      right: WkSpacing.page,
      bottom: WkSpacing.xl + MediaQuery.viewPaddingOf(context).bottom,
      child: Semantics(
        liveRegion: true,
        child: Material(
          color: context.colors.onSurface,
          borderRadius: BorderRadius.circular(WkRadius.lg),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: WkSpacing.md,
              vertical: WkSpacing.sm,
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    widget.message,
                    style: context.text.bodyMedium?.copyWith(
                      color: context.colors.surface,
                    ),
                  ),
                ),
                if (widget.undoLabel != null && widget.onUndo != null)
                  InkWell(
                    onTap: widget.onUndo,
                    child: Container(
                      constraints: const BoxConstraints(
                        minHeight: WkTouch.min,
                        minWidth: WkTouch.min,
                      ),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                        horizontal: WkSpacing.sm,
                      ),
                      child: Text(
                        widget.undoLabel!,
                        style: context.text.labelMedium?.copyWith(
                          color: context.colors.surface,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
