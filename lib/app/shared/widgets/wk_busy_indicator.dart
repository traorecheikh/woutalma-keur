import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:woutalma_keur/app/shared/theme/wk_motion.dart';
import 'package:woutalma_keur/app/shared/theme/wk_spacing.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';

/// Indicateur d'attente propre à Woutalma.
///
/// Remplace le spinner Material : trois points respirent, ce qui reste lisible
/// en petit dans un bouton et calme dans un état pleine page.
class WkBusyIndicator extends StatefulWidget {
  const WkBusyIndicator({this.color, this.size = 28, super.key});

  final Color? color;
  final double size;

  @override
  State<WkBusyIndicator> createState() => _WkBusyIndicatorState();
}

class _WkBusyIndicatorState extends State<WkBusyIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (WkMotion.of(context).reduced) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color color = widget.color ?? context.colors.primary;
    final double dot = widget.size / 3.6;

    return SizedBox(
      width: widget.size,
      height: dot,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, _) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List<Widget>.generate(3, (int index) {
              final double offset = index * math.pi / 2;
              final double phase = (_controller.value * math.pi * 2) + offset;
              final double wave = WkMotion.of(context).reduced
                  ? 0.5
                  : (math.sin(phase) + 1) / 2;
              return Transform.scale(
                scale: 0.75 + (wave * 0.25),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.45 + wave * 0.55),
                    borderRadius: BorderRadius.circular(WkRadius.full),
                  ),
                  child: SizedBox(width: dot, height: dot),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
