import 'dart:math';

import 'package:flutter/material.dart';

enum VisirTooltipDirection { top, bottom, left, right, pointer }

enum VisirTooltipTriggerMode { tap, longPress, doubleTap, manual, hover }

enum VisirTooltipDismissMode {
  tapOutside,
  tapAnyWhere,
  tapInside,
  manual,
  hover,
}

class VisirTooltipController extends ChangeNotifier {
  bool _isShow = false;

  bool get isShow => _isShow;

  void show() {
    _isShow = true;
    notifyListeners();
  }

  void dismiss([PointerDownEvent? event]) {
    _isShow = false;
    notifyListeners();
  }

  void toggle() => _isShow ? dismiss() : show();
}

final ValueNotifier<int> currentVisirTooltipHashcode = ValueNotifier(0);

class VisirTooltip extends StatefulWidget {
  const VisirTooltip({
    super.key,
    required this.message,
    required this.child,
    this.triangleColor = Colors.black,
    this.triangleSize = const Size(10, 10),
    this.targetPadding = 6,
    this.triangleRadius = 2,
    this.onShow,
    this.onDismiss,
    this.controller,
    this.messagePadding = const EdgeInsets.symmetric(
      vertical: 6,
      horizontal: 12,
    ),
    this.messageDecoration = const BoxDecoration(
      color: Colors.black,
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    this.messageStyle = const TextStyle(color: Colors.white, fontSize: 12),
    this.padding = const EdgeInsets.all(16),
    this.axis = Axis.vertical,
    this.triggerMode,
    this.dismissMode,
    this.offsetIgnore = false,
    this.direction,
  });

  final Widget message;
  final Widget child;
  final Color triangleColor;
  final Size triangleSize;
  final double targetPadding;
  final double triangleRadius;
  final VoidCallback? onShow;
  final VoidCallback? onDismiss;
  final VisirTooltipController? controller;
  final EdgeInsetsGeometry messagePadding;
  final BoxDecoration messageDecoration;
  final TextStyle? messageStyle;
  final EdgeInsetsGeometry padding;
  final Axis axis;
  final VisirTooltipTriggerMode? triggerMode;
  final VisirTooltipDismissMode? dismissMode;
  final bool offsetIgnore;
  final VisirTooltipDirection? direction;

  @override
  State<VisirTooltip> createState() => _VisirTooltipState();
}

class _VisirTooltipState extends State<VisirTooltip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animation;
  late final VisirTooltipController _controller;
  VisirTooltipTriggerMode? _triggerMode;
  VisirTooltipDismissMode? _dismissMode;

  final key = GlobalKey();
  final messageBoxKey = GlobalKey();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _controller = widget.controller ?? VisirTooltipController();
    _controller.addListener(listener);

    initProperties();
    super.initState();

    currentVisirTooltipHashcode.addListener(onCurrentTooltipHashcodeChange);
  }

  void onCurrentTooltipHashcodeChange() {
    if (currentVisirTooltipHashcode.value != widget.hashCode) {
      dismiss();
    }
  }

  @override
  void didUpdateWidget(covariant VisirTooltip oldWidget) {
    initProperties();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    dismiss();
    currentVisirTooltipHashcode.removeListener(onCurrentTooltipHashcodeChange);
    _overlayEntry?.remove();
    _controller.removeListener(listener);
    if (widget.controller == null) {
      _controller.dispose();
    }

    _animationController.dispose();
    super.dispose();
  }

  void listener() {
    if (_controller.isShow == true) {
      show();
    } else {
      dismiss();
    }
  }

  void initProperties() {
    _triggerMode = switch (widget.controller) {
      null => widget.triggerMode ?? VisirTooltipTriggerMode.hover,
      _ => widget.triggerMode,
    };

    _dismissMode = switch (widget.controller) {
      null => widget.dismissMode ?? VisirTooltipDismissMode.hover,
      _ => widget.dismissMode,
    };
  }

  @override
  Widget build(BuildContext context) {
    final child = CompositedTransformTarget(
      link: _layerLink,
      child: MouseRegion(
        key: key,
        cursor: SystemMouseCursors.click,
        hitTestBehavior: HitTestBehavior.opaque,
        onEnter: switch (_triggerMode) {
          VisirTooltipTriggerMode.hover => (_) => _controller.show(),
          _ => null,
        },
        onExit: switch (_dismissMode) {
          VisirTooltipDismissMode.hover => (_) => _controller.dismiss(),
          _ => null,
        },
        child: widget.child,
      ),
    );

    return child;
  }

  void show() {
    if (!mounted || _animationController.isAnimating) return;

    final messageBox = Material(
      type: MaterialType.transparency,
      color: Colors.transparent,
      child: Container(
        key: messageBoxKey,
        padding: widget.messagePadding,
        decoration: widget.messageDecoration,
        constraints: const BoxConstraints(maxWidth: 200),
        child: DefaultTextStyle.merge(
          style: widget.messageStyle,
          child: widget.message,
        ),
      ),
    );

    _overlayEntry = OverlayEntry(
      builder: (_) => Stack(
        children: [FadeTransition(opacity: _animation, child: messageBox)],
      ),
    );

    final overlay = Overlay.of(context, rootOverlay: true);
    overlay.insert(_overlayEntry!);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_controller.isShow) return;

      final messageBoxRenderBox =
          messageBoxKey.currentContext?.findRenderObject() as RenderBox?;
      final messageBoxSize = messageBoxRenderBox?.size;

      _overlayEntry?.remove();
      _overlayEntry = null;

      if (messageBoxSize == null) return;

      final builder = _builder(messageBoxSize);
      if (builder == null) return;

      final offset = switch (builder.targetAnchor) {
        Alignment.bottomCenter when widget.offsetIgnore => Offset(
          0,
          widget.triangleSize.height + widget.targetPadding - 1,
        ),
        Alignment.topCenter when widget.offsetIgnore => Offset(
          0,
          -widget.triangleSize.height - widget.targetPadding + 1,
        ),
        Alignment.centerLeft when widget.offsetIgnore => Offset(
          -widget.targetPadding - widget.triangleSize.width + 1,
          0,
        ),
        Alignment.centerRight when widget.offsetIgnore => Offset(
          widget.targetPadding + widget.triangleSize.width - 1,
          0,
        ),
        Alignment.bottomCenter => Offset(
          builder.offset.dx,
          widget.triangleSize.height + widget.targetPadding - 1,
        ),
        Alignment.topCenter => Offset(
          builder.offset.dx,
          -widget.triangleSize.height - widget.targetPadding + 1,
        ),
        Alignment.centerLeft => Offset(
          -widget.targetPadding - widget.triangleSize.width + 1,
          builder.offset.dy,
        ),
        Alignment.centerRight => Offset(
          widget.targetPadding + widget.triangleSize.width - 1,
          builder.offset.dy,
        ),
        _ => Offset.zero,
      };

      _overlayEntry = OverlayEntry(
        builder: (_) {
          return IgnorePointer(
            child: FadeTransition(
              opacity: _animation,
              child: TapRegion(
                onTapInside: switch (_dismissMode) {
                  VisirTooltipDismissMode.tapInside => _controller.dismiss,
                  VisirTooltipDismissMode.tapAnyWhere => _controller.dismiss,
                  _ => null,
                },
                onTapOutside: switch (_dismissMode) {
                  VisirTooltipDismissMode.tapOutside => _controller.dismiss,
                  VisirTooltipDismissMode.tapAnyWhere => _controller.dismiss,
                  _ => null,
                },
                child: Stack(
                  children: [
                    const SizedBox.expand(),
                    if (widget.direction == VisirTooltipDirection.pointer)
                      ValueListenableBuilder(
                        valueListenable: mousePosition,
                        builder: (context, value, child) {
                          return Positioned(
                            top: max(6, value.dy - messageBoxSize.height - 6),
                            left: max(6, value.dx),
                            child: Opacity(
                              opacity: value.dy == 0 && value.dx == 0 ? 0 : 1,
                              child: messageBox,
                            ),
                          );
                        },
                      )
                    else
                      CompositedTransformFollower(
                        link: _layerLink,
                        showWhenUnlinked: false,
                        targetAnchor: builder.targetAnchor,
                        followerAnchor: builder.followerAnchor,
                        offset: offset,
                        child: messageBox,
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      );

      overlay.insert(_overlayEntry!);
      _animationController.forward();
    });

    widget.onShow?.call();
    currentVisirTooltipHashcode.value = widget.hashCode;
  }

  void dismiss() async {
    if (_overlayEntry != null) {
      try {
        await _animationController.reverse();
      } finally {
        if (_overlayEntry != null && _overlayEntry!.mounted) {
          _overlayEntry?.remove();
        }
        _overlayEntry = null;
        widget.onDismiss?.call();
      }
    }
  }

  ValueNotifier<Offset> mousePosition = ValueNotifier(Offset.zero);

  ({Alignment targetAnchor, Alignment followerAnchor, Offset offset})? _builder(
    Size messageBoxSize,
  ) {
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null) {
      return null;
    }

    final targetSize = renderBox.size;
    final targetPosition = renderBox.localToGlobal(Offset.zero);
    final targetCenterPosition = Offset(
      targetPosition.dx + targetSize.width / 2,
      targetPosition.dy + targetSize.height / 2,
    );

    final bool isLeft = switch (widget.direction) {
      VisirTooltipDirection.left => false,
      VisirTooltipDirection.right => true,
      _ => targetCenterPosition.dx <= MediaQuery.of(context).size.width / 2,
    };

    final bool isRight = switch (widget.direction) {
      VisirTooltipDirection.left => true,
      VisirTooltipDirection.right => false,
      _ => targetCenterPosition.dx > MediaQuery.of(context).size.width / 2,
    };

    final bool isBottom = switch (widget.direction) {
      VisirTooltipDirection.top => true,
      VisirTooltipDirection.bottom => false,
      _ => targetCenterPosition.dy > MediaQuery.of(context).size.height / 2,
    };

    final bool isTop = switch (widget.direction) {
      VisirTooltipDirection.top => false,
      VisirTooltipDirection.bottom => true,
      _ => targetCenterPosition.dy <= MediaQuery.of(context).size.height / 2,
    };

    final Alignment targetAnchor = switch (widget.axis) {
      Axis.horizontal when isRight => Alignment.centerLeft,
      Axis.horizontal when isLeft => Alignment.centerRight,
      Axis.vertical when isTop => Alignment.bottomCenter,
      Axis.vertical when isBottom => Alignment.topCenter,
      _ => Alignment.center,
    };

    final Alignment followerAnchor = switch (widget.axis) {
      Axis.horizontal when isRight => Alignment.centerRight,
      Axis.horizontal when isLeft => Alignment.centerLeft,
      Axis.vertical when isTop => Alignment.topCenter,
      Axis.vertical when isBottom => Alignment.bottomCenter,
      _ => Alignment.center,
    };

    final double overflowWidth = (messageBoxSize.width - targetSize.width) / 2;
    final edgeFromLeft = targetPosition.dx - overflowWidth;
    final edgeFromRight =
        MediaQuery.of(context).size.width -
        (targetPosition.dx + targetSize.width + overflowWidth);
    final edgeFromHorizontal = min(edgeFromLeft, edgeFromRight);

    double dx = 0;

    if (edgeFromHorizontal < widget.padding.horizontal / 2) {
      if (isLeft) {
        dx = (widget.padding.horizontal / 2) - edgeFromHorizontal;
      } else if (isRight) {
        dx = -(widget.padding.horizontal / 2) + edgeFromHorizontal;
      }
    }

    final double overflowHeight =
        (messageBoxSize.height - targetSize.height) / 2;
    final edgeFromTop = targetPosition.dy - overflowHeight;
    final edgeFromBottom =
        MediaQuery.of(context).size.height -
        (targetPosition.dy + targetSize.height + overflowHeight);
    final edgeFromVertical = min(edgeFromTop, edgeFromBottom);

    double dy = 0;

    if (edgeFromVertical < widget.padding.vertical / 2) {
      if (isTop) {
        dy =
            MediaQuery.of(context).padding.top +
            (widget.padding.vertical / 2) -
            edgeFromVertical;
      } else if (isBottom) {
        dy =
            MediaQuery.of(context).padding.bottom -
            (widget.padding.vertical / 2) +
            edgeFromVertical;
      }
    }

    return (
      targetAnchor: targetAnchor,
      followerAnchor: followerAnchor,
      offset: Offset(dx, dy),
    );
  }
}
