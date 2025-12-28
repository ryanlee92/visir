import 'package:flutter/material.dart';

class MultiFingerGestureController {
  final List<Function(Offset offset, Offset delta)> _twoFingerMoveListeners = [];
  final List<Function()> _twoFingerDownListeners = [];
  final List<Function(List<String> ids)> _onTapDownListenersFromWidget = [];
  final List<Function(List<String> ids)> _onTapUpListenersFromWidget = [];

  void addTwoFingerMoveListener(Function(Offset offset, Offset delta) listener) {
    _twoFingerMoveListeners.add(listener);
  }

  void removeTwoFingerMoveListener(Function(Offset offset, Offset delta) listener) {
    _twoFingerMoveListeners.remove(listener);
  }

  void notifyTwoFingerMoveListeners(Offset offset, Offset delta) {
    for (var listener in _twoFingerMoveListeners) {
      listener(offset, delta);
    }
  }

  void addTwoFingerDownListener(Function() listener) {
    _twoFingerDownListeners.add(listener);
  }

  void removeTwoFingerDownListener(Function() listener) {
    _twoFingerDownListeners.remove(listener);
  }

  void notifyTwoFingerDownListeners() {
    for (var listener in _twoFingerDownListeners) {
      listener();
    }
  }

  void addTapDownFromWidgetListener(Function(List<String> ids) listener) {
    _onTapDownListenersFromWidget.add(listener);
  }

  void removeTapDownFromWidgetListener(Function(List<String> ids) listener) {
    _onTapDownListenersFromWidget.remove(listener);
  }

  void notifyTapDownFromWidgetListeners(List<String> ids) {
    for (var listener in _onTapDownListenersFromWidget) {
      listener(ids);
    }
  }

  void addTapUpFromWidgetListener(Function(List<String> ids) listener) {
    _onTapUpListenersFromWidget.add(listener);
  }

  void removeTapUpFromWidgetListener(Function(List<String> ids) listener) {
    _onTapUpListenersFromWidget.remove(listener);
  }

  void notifyTapUpFromWidgetListeners(List<String> ids) {
    for (var listener in _onTapUpListenersFromWidget) {
      listener(ids);
    }
  }
}

class MultiFingerGestureDetector extends StatefulWidget {
  final Widget Function(MultiFingerGestureController controller) builder;

  final VoidCallback? onTwoFingerDragStart;

  MultiFingerGestureDetector({
    Key? key,
    required this.builder,
    this.onTwoFingerDragStart,
  }) : super(key: key);

  @override
  _MultiFingerGestureDetectorState createState() => _MultiFingerGestureDetectorState();
}

class _MultiFingerGestureDetectorState extends State<MultiFingerGestureDetector> {
  final MultiFingerGestureController controller = MultiFingerGestureController();
  Set<int> _pointerPositions = Set();

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerMove: _handlePointerMove,
      onPointerDown: _handlePointerDown,
      onPointerUp: _handlePointerUp,
      onPointerCancel: _handlePointerCancel,
      child: widget.builder(controller),
    );
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (!_pointerPositions.contains(event.pointer)) _pointerPositions.add(event.pointer);
    if (_pointerPositions.length == 2) {
      if (event.pointer == _pointerPositions.last) controller.notifyTwoFingerMoveListeners(event.position, event.delta);
    }
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (!_pointerPositions.contains(event.pointer)) _pointerPositions.add(event.pointer);
    if (_pointerPositions.length == 2) {
      if (event.pointer == _pointerPositions.last) widget.onTwoFingerDragStart?.call();
      if (event.pointer == _pointerPositions.last) controller.notifyTwoFingerDownListeners();
    }
  }

  void _handlePointerUp(PointerUpEvent event) {
    _pointerPositions.remove(event.pointer);
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    _pointerPositions.remove(event.pointer);
  }
}
