import 'package:flutter/material.dart';

import '../foundation/visir_enums.dart';
import '../theme/visir_theme.dart';

class VisirSpinner extends StatefulWidget {
  const VisirSpinner({
    super.key,
    this.size = VisirSpinnerSize.md,
    this.tone = VisirSpinnerTone.primary,
    this.turns,
  });

  final VisirSpinnerSize size;
  final VisirSpinnerTone tone;
  final Animation<double>? turns;

  @override
  State<VisirSpinner> createState() => _VisirSpinnerState();
}

class _VisirSpinnerState extends State<VisirSpinner>
    with SingleTickerProviderStateMixin {
  static const _defaultDuration = Duration(milliseconds: 900);

  late final AnimationController _controller;
  late final Animation<double> _defaultTurns;

  Animation<double> get _effectiveTurns => widget.turns ?? _defaultTurns;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _defaultDuration)
      ..repeat();
    _defaultTurns = _controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = VisirTheme.of(context);
    final colors = theme.tokens.colors;
    final feedback = theme.components.feedback;
    final color = switch (widget.tone) {
      VisirSpinnerTone.neutral => colors.textMuted,
      VisirSpinnerTone.primary => colors.text,
      VisirSpinnerTone.inverse => colors.textInverse,
    };
    final spinnerSize = feedback.sizeFor(widget.size);

    return RotationTransition(
      turns: _effectiveTurns,
      child: SizedBox(
        width: spinnerSize,
        height: spinnerSize,
        child: CircularProgressIndicator(
          strokeWidth: feedback.strokeWidth,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ),
    );
  }
}
