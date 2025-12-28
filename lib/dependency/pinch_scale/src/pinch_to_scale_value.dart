import 'dart:math';

import 'package:flutter/material.dart';

class PinchScale extends StatefulWidget {
  final Widget child;

  PinchScale({
    Key? key,
    required this.child,
    required this.currentValue,
    required this.onValueChanged,
    required this.baseValue,
    this.ratioForUpdateValueUp = 1.1,
    this.ratioForUpdateValueDown = 0.9,
    this.minValue = 0.5,
    this.maxValue = 15.0,
  }) : super(key: key);
  final double baseValue;

  final double minValue;
  final double maxValue;

  final double ratioForUpdateValueUp;
  final double ratioForUpdateValueDown;

  final double Function() currentValue;
  final Function(double newFontSize) onValueChanged;

  @override
  State<PinchScale> createState() => _PinchScaleState();
}

class _PinchScaleState extends State<PinchScale> {
  late final double baseSize;
  double baseScale = 1.0;
  double scale = 1.0;
  double size = 24.0;

  bool scaleWithScroll = false;

  @override
  void initState() {
    baseSize = widget.baseValue;
    size = widget.currentValue();
    baseScale = size / baseSize;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      trackpadScrollCausesScale: scaleWithScroll,
      onScaleStart: (details) {
        baseScale = scale;
      },
      onScaleUpdate: (details) {
        final _fontScale = max((baseScale * details.scale), widget.minValue / baseSize);
        size = _fontScale;
        scale = _fontScale;
        widget.onValueChanged(_fontScale * baseSize);
      },
      onScaleEnd: (details) {},
      child: widget.child,
    );
  }
}
