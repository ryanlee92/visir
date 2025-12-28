import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PlatformScrollPhysics extends ScrollPhysics {
  /// Creates scroll physics that does not let the user scroll.

  final PlatformScrollController? controller;
  PlatformScrollPhysics({super.parent, this.controller});

  @override
  PlatformScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return PlatformScrollPhysics(parent: buildParent(ancestor), controller: controller);
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    if (controller != null && controller!.enableShiftScroll && HardwareKeyboard.instance.isShiftPressed) return 0;
    if (controller != null && controller!.enableControlScroll && HardwareKeyboard.instance.isMetaPressed) return 0;
    if (controller != null && controller!.enableControlScroll && HardwareKeyboard.instance.isControlPressed) return 0;
    if (controller != null && controller!.enableTwoFingerDrag && controller!.pointer > 1) return 0;
    return super.applyPhysicsToUserOffset(position, offset);
  }

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) {
    if (controller != null && controller!.enableShiftScroll && HardwareKeyboard.instance.isShiftPressed) return false;
    if (controller != null && controller!.enableControlScroll && HardwareKeyboard.instance.isMetaPressed) return false;
    if (controller != null && controller!.enableControlScroll && HardwareKeyboard.instance.isControlPressed) return false;
    if (controller != null && controller!.enableTwoFingerDrag && controller!.pointer > 1) return false;
    return super.shouldAcceptUserOffset(position);
  }
}

class PlatformScrollController {
  int pointer = 0;
  bool enableControlScroll = false;
  bool enableShiftScroll = false;
  bool enableTwoFingerDrag = false;

  PlatformScrollController({
    this.enableControlScroll = false,
    this.enableShiftScroll = false,
    this.enableTwoFingerDrag = false,
  });

  addPointer() {
    pointer += 1;
  }

  removePointer() {
    pointer = max(0, pointer - 1);
  }
}
