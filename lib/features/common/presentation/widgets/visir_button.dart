import 'dart:async';

import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/widget_tooltip/widget_tooltip.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/widgets/custom_circualr_loading_indicator.dart';
import 'package:Visir/features/common/presentation/widgets/keyboard_shortcut.dart';
import 'package:Visir/features/common/presentation/widgets/multi_finger_gesture_detector.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:change_case/change_case.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum VisirButtonAnimationType { scale, opacity, scaleAndOpacity, none }

extension VisirButtonAnimationTypeX on VisirButtonAnimationType {
  bool get isHoverEnabled {
    switch (this) {
      case VisirButtonAnimationType.scale:
      case VisirButtonAnimationType.scaleAndOpacity:
        return true;
      case VisirButtonAnimationType.opacity:
      case VisirButtonAnimationType.none:
        return false;
    }
  }
}

enum VisirButtonTooltipLocation { top, bottom, right, left, pointer, none }

extension VisirButtonTooltipLocationX on VisirButtonTooltipLocation {
  WidgetTooltipDirection get widgetTooltipDirection {
    switch (this) {
      case VisirButtonTooltipLocation.right:
        return WidgetTooltipDirection.right;
      case VisirButtonTooltipLocation.left:
        return WidgetTooltipDirection.left;
      case VisirButtonTooltipLocation.top:
        return WidgetTooltipDirection.top;
      case VisirButtonTooltipLocation.bottom:
        return WidgetTooltipDirection.bottom;
      case VisirButtonTooltipLocation.pointer:
        return WidgetTooltipDirection.pointer;
      case VisirButtonTooltipLocation.none:
        return WidgetTooltipDirection.pointer;
    }
  }
}

extension LogicalKeyboardKeyListX on List<LogicalKeyboardKey> {
  bool get isControlPressed {
    return this.contains(LogicalKeyboardKey.controlLeft) || this.contains(LogicalKeyboardKey.controlRight) || this.contains(LogicalKeyboardKey.control);
  }

  bool get isShiftPressed {
    return this.contains(LogicalKeyboardKey.shiftLeft) || this.contains(LogicalKeyboardKey.shiftRight) || this.contains(LogicalKeyboardKey.shift);
  }

  bool get isMetaPressed {
    return this.contains(LogicalKeyboardKey.metaLeft) || this.contains(LogicalKeyboardKey.metaRight) || this.contains(LogicalKeyboardKey.meta);
  }

  bool get isAltPressed {
    return this.contains(LogicalKeyboardKey.altLeft) || this.contains(LogicalKeyboardKey.altRight) || this.contains(LogicalKeyboardKey.alt);
  }

  bool get isEscapePressed {
    return this.contains(LogicalKeyboardKey.escape);
  }

  List<LogicalKeyboardKey> get ordered {
    this.sort((a, b) => b.keyId.compareTo(a.keyId));
    return this;
  }
}

extension LogicalKeyboardKeyX on LogicalKeyboardKey {
  String get title {
    switch (this) {
      case LogicalKeyboardKey.meta:
      case LogicalKeyboardKey.metaLeft:
      case LogicalKeyboardKey.metaRight:
        return '⌘';
      case LogicalKeyboardKey.control:
      case LogicalKeyboardKey.controlLeft:
      case LogicalKeyboardKey.controlRight:
        return 'Ctrl';
      case LogicalKeyboardKey.shift:
      case LogicalKeyboardKey.shiftLeft:
      case LogicalKeyboardKey.shiftRight:
        return PlatformX.isApple ? '⇧' : 'Shift';
      case LogicalKeyboardKey.alt:
      case LogicalKeyboardKey.altLeft:
      case LogicalKeyboardKey.altRight:
        return PlatformX.isApple ? '⌥' : 'Alt';
      case LogicalKeyboardKey.escape:
        return 'Esc';
      case LogicalKeyboardKey.backspace:
        return PlatformX.isApple ? '⌫' : 'Backspace';
      case LogicalKeyboardKey.enter:
        return PlatformX.isApple ? '⏎' : 'Enter';
      case LogicalKeyboardKey.arrowRight:
        return '→';
      case LogicalKeyboardKey.arrowLeft:
        return '←';
      case LogicalKeyboardKey.arrowUp:
        return '↑';
      case LogicalKeyboardKey.arrowDown:
        return '↓';
      case LogicalKeyboardKey.space:
        return 'Spacebar';
      default:
        return keyLabel;
    }
  }

  bool get isMeta {
    return this == (LogicalKeyboardKey.metaLeft) || this == (LogicalKeyboardKey.metaRight) || this == (LogicalKeyboardKey.meta);
  }

  bool get isControl {
    return this == (LogicalKeyboardKey.controlLeft) || this == (LogicalKeyboardKey.controlRight) || this == (LogicalKeyboardKey.control);
  }

  bool get isShift {
    return this == (LogicalKeyboardKey.shiftLeft) || this == (LogicalKeyboardKey.shiftRight) || this == (LogicalKeyboardKey.shift);
  }

  bool get isAlt {
    return this == (LogicalKeyboardKey.altLeft) || this == (LogicalKeyboardKey.altRight) || this == (LogicalKeyboardKey.alt);
  }

  bool get isEscape {
    return this == (LogicalKeyboardKey.escape);
  }
}

class VisirButtonOptions<T> {
  final List<VisirButtonKeyboardShortcut<T>>? shortcuts;
  final VisirButtonTooltipLocation? tooltipLocation;
  final TabType? tabType;
  final bool? bypassTextField;
  final bool? bypassMailEditScreen;
  final String? customShortcutTooltip;
  final String? message;
  final InlineSpan? span;
  final double? verticalOffset;
  final bool? doNotConvertCase;
  final bool? autoTriggerOnTapUpAtInit;

  const VisirButtonOptions({
    this.shortcuts,
    this.message,
    this.span,
    this.tooltipLocation,
    this.tabType,
    this.bypassTextField,
    this.bypassMailEditScreen,
    this.customShortcutTooltip,
    this.verticalOffset,
    this.doNotConvertCase,
    this.autoTriggerOnTapUpAtInit,
  });
}

class VisirButtonKeyboardShortcut<T> {
  final String message;
  final List<LogicalKeyboardKey> keys;
  final List<List<LogicalKeyboardKey>>? subkeys;
  final bool Function()? onTrigger;
  final bool? triggerOnRepeat;
  final bool Function(KeyEvent)? prevOnKeyDown;
  final bool Function(KeyEvent)? prevOnKeyRepeat;

  final String? itemTitle;

  const VisirButtonKeyboardShortcut({
    required this.keys,
    required this.message,
    this.onTrigger,
    this.triggerOnRepeat,
    this.subkeys,
    this.prevOnKeyDown,
    this.prevOnKeyRepeat,
    this.itemTitle,
  });
}

class VisirButtonStyle {
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final EdgeInsets? clickMargin;
  final bool? transparentHitTest;
  final Color? hoverColor;
  final Color? backgroundColor;
  final Color? selectedColor;
  final BorderRadius? borderRadius;
  final BorderRadius? selectedBorderRadius;
  final double? width;
  final double? height;
  final Alignment? alignment;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final Clip? clipBehavior;
  final BoxConstraints? constraints;
  final bool? autofocus;
  final MouseCursor? cursor;
  final Offset? translate;
  final BoxBorder? hoverBorder;

  const VisirButtonStyle({
    this.padding,
    this.margin,
    this.clickMargin,
    this.transparentHitTest,
    this.hoverColor,
    this.backgroundColor,
    this.selectedColor,
    this.borderRadius,
    this.selectedBorderRadius,
    this.width,
    this.height,
    this.alignment,
    this.border,
    this.boxShadow,
    this.clipBehavior,
    this.constraints,
    this.autofocus,
    this.cursor,
    this.hoverBorder,
    this.translate,
  });
}

class VisirButton extends StatefulWidget {
  final Widget? child;
  final FutureOr<void> Function()? onTap;
  final FutureOr<void> Function()? onDoubleTap;
  final VoidCallback? onLongPress;
  final VisirButtonAnimationType type;
  final VisirButtonStyle style;
  final void Function(PointerEnterEvent event)? onEnter;
  final void Function(PointerExitEvent event)? onExit;
  final void Function(bool hover)? onHover;
  final bool? isSelected;
  final HitTestBehavior? behavior;
  final Widget Function(bool isHover)? builder;
  final String? id;

  final VisirButtonOptions? options;

  final FocusNode? focusNode;
  final String? debugKey;
  final bool? enabled;

  final void Function(TapDownDetails details)? onSecondaryTapDown;
  final void Function()? onTwoFingerDragSelect;
  final void Function()? onTwoFingerDragDisselect;
  final void Function(TapUpDetails details)? onTapUp;
  final void Function(TapDownDetails details)? onTapDown;
  final void Function()? onTapCancel;
  final void Function(LongPressStartDetails details)? onLongPressStart;
  final void Function(bool focus)? onFocusChange;

  final MultiFingerGestureController? multiFingerGestureController;

  static List<BoxShadow> fabShadow = [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2), spreadRadius: 1)];

  static List<BoxShadow> toastShadow = [BoxShadow(color: Colors.black12, blurRadius: 1, offset: Offset(0, 2), spreadRadius: 1)];

  const VisirButton({
    Key? key,
    this.id,
    this.child,
    this.debugKey,
    this.type = VisirButtonAnimationType.scaleAndOpacity,
    required this.style,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onEnter,
    this.onExit,
    this.onHover,
    this.behavior,
    this.builder,
    this.onSecondaryTapDown,
    this.onLongPressStart,
    this.onTapUp,
    this.onTapDown,
    this.onTapCancel,
    this.focusNode,
    this.onFocusChange,
    this.isSelected,
    this.multiFingerGestureController,
    this.onTwoFingerDragSelect,
    this.onTwoFingerDragDisselect,
    this.options,
    this.enabled,
  }) : assert(
         (onTwoFingerDragSelect == null && onTwoFingerDragDisselect == null) || multiFingerGestureController != null,
         'multiFingerGestureController must be provided if onTwoFingerDragIn or onTwoFingerDragOut is used',
       ),
       super(key: key);

  @override
  VisirButtonState createState() => VisirButtonState();
}

class VisirButtonState extends State<VisirButton> with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  TooltipController? tooltipController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _borderRadiusAnimation;
  late FocusNode _focusNode;

  GlobalKey containerKey = GlobalKey();

  bool get isNotActionable => widget.onTap == null && widget.onTapUp == null && widget.onLongPress == null;
  bool get scaleAnimationEnabled => widget.type == VisirButtonAnimationType.scale || widget.type == VisirButtonAnimationType.scaleAndOpacity;
  bool get opacityAnimationEnabled => widget.type == VisirButtonAnimationType.opacity || widget.type == VisirButtonAnimationType.scaleAndOpacity;

  bool _isHover = false;
  ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);

  void onTap() async {
    Completer<void> completer = Completer<void>();
    EasyThrottle.throttle('${hashCode}:taskeyButton', Duration(milliseconds: 500), () {
      if (_isLoading.value) return completer.complete();

      final result = widget.onTap?.call();
      if (result is Future) {
        _isLoading.value = true;
        result.then((_) {
          if (mounted) {
            _isLoading.value = false;
          }
          completer.complete();
        });
      }
    });
    return completer.future;
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(duration: const Duration(milliseconds: 250), vsync: this);

    tooltipController = TooltipController();

    _scaleAnimation = Tween<double>(begin: 1.0, end: scaleAnimationEnabled ? 0.95 : 1).animate(CurvedAnimation(parent: _controller!, curve: Curves.easeInOut));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: opacityAnimationEnabled ? 0.5 : 1,
    ).animate(CurvedAnimation(parent: _controller!, curve: Curves.easeInOut));

    _borderRadiusAnimation = Tween<double>(begin: 0, end: 6).animate(CurvedAnimation(parent: _controller!, curve: Curves.easeInOut));

    _focusNode = widget.focusNode ?? FocusNode();

    widget.multiFingerGestureController?.addTwoFingerMoveListener(onTwoFingerMove);
    widget.multiFingerGestureController?.addTwoFingerDownListener(onTwoFingerDown);
    widget.multiFingerGestureController?.addTapDownFromWidgetListener(startAnimation);
    widget.multiFingerGestureController?.addTapUpFromWidgetListener(endAnimation);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.options?.autoTriggerOnTapUpAtInit == true) {
        final renderBox = containerKey.currentContext?.findRenderObject() as RenderBox?;
        final position = renderBox?.localToGlobal(Offset.zero);
        if (position != null && renderBox?.size != null) {
          widget.onTapUp?.call(
            TapUpDetails(
              globalPosition: Offset(position.dx + renderBox!.size.width / 2, position.dy + renderBox.size.height / 2),
              kind: PointerDeviceKind.touch,
            ),
          );
        }
      }
    });
  }

  bool isTwoFingerDragIn = false;
  bool isTwoFingerSelect = false;
  bool? inFromUp;
  bool? firstInDirectionUp;
  int inCount = 0;
  int outCount = 0;
  void onTwoFingerMove(Offset offset, Offset delta) {
    final renderBox = containerKey.currentContext?.findRenderObject() as RenderBox?;
    final position = renderBox?.localToGlobal(Offset.zero);
    if (position == null) return;
    final rect = Rect.fromLTWH(position.dx, position.dy, renderBox!.size.width, renderBox.size.height);

    if (!isTwoFingerDragIn && rect.contains(offset)) {
      if (inCount == outCount) {
        inCount += 1;
        inFromUp = delta.dy < 0;
        isTwoFingerSelect = true;

        widget.onTwoFingerDragSelect?.call();
      }
    } else if (isTwoFingerDragIn && !rect.contains(offset)) {
      if (inCount == outCount + 1) {
        outCount += 1;
        final outToDown = delta.dy < 0;
        if (outCount % 2 == 1 && inFromUp != outToDown) {
          widget.onTwoFingerDragDisselect?.call();
          clearTwoFingerData();
        }

        if (outCount % 2 == 0 && inFromUp == outToDown) {
          widget.onTwoFingerDragDisselect?.call();
          clearTwoFingerData();
        }
      }
    }

    isTwoFingerDragIn = rect.contains(offset);
  }

  void onTwoFingerDown() {
    clearTwoFingerData();
  }

  void clearTwoFingerData() {
    isTwoFingerDragIn = false;
    isTwoFingerSelect = false;
    inFromUp = null;
    firstInDirectionUp = null;
    inCount = 0;
    outCount = 0;
  }

  void startAnimation(List<String> ids) {
    if (ids.contains(widget.id)) _controller?.forward();
  }

  void endAnimation(List<String> ids) {
    if (ids.contains(widget.id)) _controller?.reverse();
  }

  @override
  void dispose() {
    _isLoading.dispose();
    widget.multiFingerGestureController?.removeTwoFingerMoveListener(onTwoFingerMove);
    widget.multiFingerGestureController?.removeTwoFingerDownListener(onTwoFingerDown);
    widget.multiFingerGestureController?.removeTapDownFromWidgetListener(startAnimation);
    widget.multiFingerGestureController?.removeTapUpFromWidgetListener(endAnimation);
    if (_controller?.isAnimating != true && _controller?.value == 1) {
      _controller?.reverse();
    }
    _controller?.dispose();
    _controller = null;
    tooltipController?.dismiss();
    tooltipController?.dispose();
    super.dispose();
  }

  void _onTapDown(dynamic details) {
    if (isNotActionable) return;
    if (widget.enabled == false) return;
    _isHover = true;
    setState(() {});
    _controller?.forward();
    widget.onLongPressStart?.call(LongPressStartDetails(globalPosition: details.globalPosition, localPosition: details.localPosition));
    widget.onTapDown?.call(details);

    Future.delayed(kLongPressTimeout, () {
      if (_controller?.isAnimating != true && _controller?.value == 1) {
        _controller?.reverse();
      }
    });
  }

  void _onTapUp(dynamic details) {
    if (isNotActionable) return;
    if (widget.enabled == false) return;
    _isHover = false;
    setState(() {});
    _controller?.reverse();
    onTap();
    widget.onTapUp?.call(details);
  }

  void _onTapCancel() {
    if (isNotActionable) return;
    if (widget.enabled == false) return;
    _isHover = false;
    setState(() {});
    _controller?.reverse();
    widget.onTapCancel?.call();
  }

  void _onLongPress() {
    if (isNotActionable) return;
    if (widget.enabled == false) return;
    _isHover = false;
    setState(() {});
    _controller?.reverse();
    widget.onLongPress?.call();
    HapticFeedback.mediumImpact();
  }

  void _onDoubleTap() {
    if (isNotActionable) return;
    if (widget.enabled == false) return;
    _isHover = false;
    setState(() {});
    _controller?.reverse();
    widget.onDoubleTap?.call();
  }

  Widget buildTooltip({required Widget child}) {
    if (widget.type == VisirButtonAnimationType.none) return child;
    if (widget.options?.tooltipLocation == VisirButtonTooltipLocation.none) return child;
    if (widget.enabled == false) return child;

    if ((widget.options?.message != null || widget.options?.span != null || widget.options?.shortcuts?.isNotEmpty == true)) {
      final tooltipDirection = (widget.options?.tooltipLocation ?? VisirButtonTooltipLocation.bottom).widgetTooltipDirection;
      final axis = [WidgetTooltipDirection.bottom, WidgetTooltipDirection.top].contains(tooltipDirection) ? Axis.vertical : Axis.horizontal;

      return WidgetTooltip(
        triggerMode: WidgetTooltipTriggerMode.hover,
        dismissMode: WidgetTooltipDismissMode.hover,
        triangleSize: Size(1, 1),
        controller: tooltipController,
        triangleColor: Colors.transparent,
        padding: axis == Axis.vertical ? EdgeInsets.symmetric(vertical: 16, horizontal: 6) : EdgeInsets.symmetric(horizontal: 16),
        axis: axis,
        messageDecoration: BoxDecoration(color: context.surface, borderRadius: BorderRadius.circular(4), boxShadow: PopupMenu.popupShadow),
        direction: tooltipDirection,
        messagePadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        message: Text.rich(
          textAlign: TextAlign.center,
          style: context.bodyMedium?.textColor(context.onSurface),
          TextSpan(
            children: [
              if (widget.options?.message != null || widget.options?.span != null) widget.options?.span ?? TextSpan(text: widget.options?.message),
              if (widget.options != null && widget.options?.customShortcutTooltip?.isNotEmpty == true) ...[
                TextSpan(
                  text: '  ',
                  style: TextStyle(color: context.surfaceTint),
                ),
                TextSpan(
                  text: widget.options?.doNotConvertCase == true
                      ? '${widget.options?.customShortcutTooltip}'
                      : '${widget.options?.customShortcutTooltip}'.toSentenceCase(),
                  style: TextStyle(color: context.surfaceTint),
                ),
              ],
              if (widget.options?.shortcuts != null && widget.options?.customShortcutTooltip == null)
                ...widget.options!.shortcuts!
                    .map((shortcut) {
                      final string = [
                        shortcut.keys.ordered.map((e) => e.title).join(' '),
                        ...(shortcut.subkeys?.map((e) => e.ordered.map((k) => k.title).join(' ')) ?? List<String>.from([])),
                      ];

                      if (string.contains('⌘ Delete') && string.contains('⌘ ⌫')) {
                        string.removeWhere((e) => e == '⌘ Delete');
                      }

                      return [
                        TextSpan(
                          text: shortcut.message.isEmpty
                              ? ''
                              : '${widget.options?.doNotConvertCase == true ? shortcut.message : shortcut.message.toSentenceCase()}  ',
                          children: [
                            TextSpan(
                              text: '${string.join(' / ')}',
                              style: TextStyle(color: context.surfaceTint),
                            ),
                          ],
                        ),
                        if (widget.options!.shortcuts!.last != shortcut) TextSpan(text: '\n'),
                      ];
                    })
                    .expand((e) => e),
            ],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        // verticalOffset: widget.style.tooltipVerticalOffset ?? 20,
        child: child,
      );
    }

    return child;
  }

  bool onKeyDown(KeyEvent event, {required bool isRepeat}) {
    if (widget.options?.shortcuts == null) return false;
    if (widget.enabled == false) return false;

    final optionKeys = [
      LogicalKeyboardKey.escape,
      LogicalKeyboardKey.shift,
      LogicalKeyboardKey.shiftRight,
      LogicalKeyboardKey.shiftLeft,
      LogicalKeyboardKey.control,
      LogicalKeyboardKey.controlRight,
      LogicalKeyboardKey.controlLeft,
      LogicalKeyboardKey.meta,
      LogicalKeyboardKey.metaRight,
      LogicalKeyboardKey.metaLeft,
      LogicalKeyboardKey.alt,
      LogicalKeyboardKey.altLeft,
      LogicalKeyboardKey.altRight,
    ];

    final logicalKeyPressed = ServicesBinding.instance.keyboard.logicalKeysPressed.where((e) => !optionKeys.contains(e)).toList();
    final logicalKeyPressedWithOptions = ServicesBinding.instance.keyboard.logicalKeysPressed.where((e) => e != LogicalKeyboardKey.escape).toList();
    final keyboardControlPressed =
        (logicalKeyPressedWithOptions.isMetaPressed && PlatformX.isApple) || (logicalKeyPressedWithOptions.isControlPressed && !PlatformX.isApple);
    final keyboardShiftPressed = logicalKeyPressedWithOptions.isShiftPressed;
    final keyboardAltPressed = logicalKeyPressedWithOptions.isAltPressed;
    final keyboardEscapePressed =
        ServicesBinding.instance.keyboard.logicalKeysPressed.length == 1 &&
        ServicesBinding.instance.keyboard.logicalKeysPressed.contains(LogicalKeyboardKey.escape);

    for (final shortcut in widget.options!.shortcuts!) {
      if (shortcut.triggerOnRepeat != true && isRepeat) continue;

      final targetKeyPressed = shortcut.keys.where((e) => !optionKeys.contains(e));
      final targetControlPressed = (shortcut.keys.isMetaPressed && PlatformX.isApple) || (shortcut.keys.isControlPressed && !PlatformX.isApple);
      final targetShiftPressed = shortcut.keys.isShiftPressed;
      final targetAltPressed = shortcut.keys.isAltPressed;
      final targetEscapePressed = shortcut.keys.isEscapePressed && shortcut.keys.length == 1;

      if ((!shortcut.keys.contains(LogicalKeyboardKey.escape) && shortcut.keys.isNotEmpty) || (targetEscapePressed && keyboardEscapePressed)) {
        final lists = [logicalKeyPressed, targetKeyPressed];
        final commonElements = lists.fold<Set>(lists.first.toSet(), (a, b) => a.intersection(b.toSet()));
        if ((commonElements.length == targetKeyPressed.length &&
            keyboardControlPressed == targetControlPressed &&
            keyboardShiftPressed == targetShiftPressed &&
            keyboardAltPressed == targetAltPressed)) {
          if (!isRepeat && shortcut.prevOnKeyDown?.call(event) == true) {
            return false;
          }
          if (isRepeat && shortcut.prevOnKeyRepeat?.call(event) == true) {
            return false;
          }

          if (shortcut.onTrigger != null) return shortcut.onTrigger!.call();
          onTap();

          final renderBox = containerKey.currentContext?.findRenderObject() as RenderBox?;
          final position = renderBox?.localToGlobal(Offset.zero);
          if (position != null && renderBox?.size != null) {
            widget.onTapUp?.call(
              TapUpDetails(
                globalPosition: Offset(position.dx + renderBox!.size.width / 2, position.dy + renderBox.size.height / 2),
                kind: PointerDeviceKind.touch,
              ),
            );
          }
          return true;
        }
      }

      if (shortcut.subkeys != null) {
        for (final subkeys in shortcut.subkeys!) {
          final targetKeyPressed = subkeys.where((e) => !optionKeys.contains(e));
          final targetControlPressed = (subkeys.isMetaPressed && PlatformX.isApple) || (subkeys.isControlPressed && !PlatformX.isApple);
          final targetShiftPressed = subkeys.isShiftPressed;
          final targetAltPressed = subkeys.isAltPressed;
          final targetEscapePressed = subkeys.isEscapePressed && subkeys.length == 1;

          if ((!subkeys.contains(LogicalKeyboardKey.escape) && subkeys.isNotEmpty) || (keyboardEscapePressed && targetEscapePressed)) {
            final lists = [logicalKeyPressed, targetKeyPressed];
            final commonElements = lists.fold<Set>(lists.first.toSet(), (a, b) => a.intersection(b.toSet()));
            if (commonElements.length == targetKeyPressed.length &&
                keyboardControlPressed == targetControlPressed &&
                keyboardShiftPressed == targetShiftPressed &&
                keyboardAltPressed == targetAltPressed) {
              if (!isRepeat && shortcut.prevOnKeyDown?.call(event) == true) {
                return false;
              }
              if (isRepeat && shortcut.prevOnKeyRepeat?.call(event) == true) {
                return false;
              }

              if (shortcut.onTrigger != null) return shortcut.onTrigger!.call();
              onTap();

              final renderBox = containerKey.currentContext?.findRenderObject() as RenderBox?;
              final position = renderBox?.localToGlobal(Offset.zero);
              if (position != null && renderBox?.size != null) {
                widget.onTapUp?.call(
                  TapUpDetails(
                    globalPosition: Offset(position.dx + renderBox!.size.width / 2, position.dy + renderBox.size.height / 2),
                    kind: PointerDeviceKind.touch,
                  ),
                );
              }
              return true;
            }
          }
        }
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    Color? backgroundColor = widget.style.backgroundColor;
    backgroundColor = widget.isSelected == true ? (widget.style.selectedColor ?? backgroundColor) : backgroundColor;

    bool needExtendGestureArea = widget.style.clickMargin != null;

    final child = GestureDetector(
      key: containerKey,
      behavior: widget.behavior,
      onTapDown: widget.onTapUp == null && widget.onTap == null && widget.onLongPressStart == null ? null : _onTapDown,
      onTapUp: widget.onTapUp == null && widget.onTap == null ? null : _onTapUp,
      onTapCancel: widget.onTapUp == null && widget.onTap == null ? null : _onTapCancel,
      onLongPress: widget.onLongPress == null ? null : _onLongPress,
      onDoubleTap: widget.onDoubleTap == null ? null : _onDoubleTap,
      onSecondaryTapDown: widget.onSecondaryTapDown,
      child: RepaintBoundary(
        child: MouseRegion(
          onEnter: (event) {
            widget.onEnter?.call(event);
            widget.onHover?.call(true);

            tooltipController?.show();

            _isHover = true;
            setState(() {});
          },
          onExit: (event) {
            widget.onExit?.call(event);
            widget.onHover?.call(false);

            tooltipController?.dismiss();

            _isHover = false;
            setState(() {});
          },
          child: DefaultSelectionStyle(
            mouseCursor: isNotActionable || widget.enabled == false
                ? SystemMouseCursors.basic
                : widget.style.cursor ?? (widget.type.isHoverEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic),
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: AnimatedBuilder(
                  animation: _borderRadiusAnimation,
                  builder: (context, child) {
                    return RepaintBoundary(
                      child: Container(
                        width: widget.style.width,
                        height: widget.style.height,
                        alignment: widget.style.alignment ?? Alignment.center,
                        clipBehavior: widget.style.clipBehavior ?? Clip.none,
                        constraints: widget.style.constraints,
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: widget.style.borderRadius ?? BorderRadius.circular(_borderRadiusAnimation.value),
                          border: widget.enabled == false || isNotActionable || !_isHover || !widget.type.isHoverEnabled
                              ? widget.style.border
                              : widget.style.hoverBorder ?? widget.style.border,
                          boxShadow: widget.style.boxShadow,
                        ),
                        child: ClipRRect(
                          borderRadius: (widget.style.borderRadius ?? BorderRadius.circular(_borderRadiusAnimation.value)).subtract(
                            BorderRadius.circular(widget.style.border?.top.width ?? 0),
                          ),
                          child: Container(
                            width: widget.style.width,
                            height: widget.style.height,
                            alignment: widget.style.alignment ?? Alignment.center,
                            decoration: BoxDecoration(
                              color: widget.enabled == false
                                  ? null
                                  : widget.isSelected == true
                                  ? widget.style.selectedColor ?? context.outlineVariant.withValues(alpha: 0.07)
                                  : null,
                              borderRadius: widget.style.selectedBorderRadius,
                            ),
                            child: RepaintBoundary(
                              child: Container(
                                width: widget.style.width,
                                height: widget.style.height,
                                alignment: widget.style.alignment ?? Alignment.center,
                                color: widget.enabled == false || isNotActionable || !_isHover || !widget.type.isHoverEnabled
                                    ? null
                                    : widget.style.hoverColor ?? context.outlineVariant.withValues(alpha: 0.05),
                                padding: widget.style.padding ?? EdgeInsets.zero,
                                child: Opacity(
                                  opacity: widget.enabled == false ? 0.5 : 1,
                                  child: ValueListenableBuilder(
                                    valueListenable: _isLoading,
                                    builder: (context, _isLoadingVal, child) {
                                      return Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Opacity(opacity: _isLoadingVal ? 0 : 1, child: widget.builder?.call(_isHover) ?? widget.child),
                                          AnimatedCrossFade(
                                            firstChild: SizedBox.shrink(),
                                            secondChild: CustomCircularLoadingIndicator(size: 14, color: context.onPrimary),
                                            crossFadeState: !_isLoadingVal ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                                            duration: Duration(milliseconds: 200),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return RepaintBoundary(
      child: KeyboardShortcut(
        targetTab: widget.options?.tabType,
        bypassTextField: widget.options?.bypassTextField,
        bypassMailEditScreen: widget.options?.bypassMailEditScreen,
        onKeyDown: (event) => onKeyDown(event, isRepeat: false),
        onKeyRepeat: (event) => onKeyDown(event, isRepeat: true),
        debugKey: widget.debugKey,
        child: Padding(
          padding: widget.style.margin ?? EdgeInsets.zero,
          child: buildTooltip(
            child: Material(
              color: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              child: Focus(
                skipTraversal: true,
                focusNode: _focusNode,
                autofocus: widget.style.autofocus ?? false,
                onFocusChange: widget.onFocusChange,
                child: needExtendGestureArea
                    ? RepaintBoundary(
                        child: ExtendGestureAreaConsumer(
                          gesturePadding: widget.style.clickMargin,
                          transparentHitTest: widget.style.transparentHitTest,
                          translate: widget.style.translate,
                          child: child,
                        ),
                      )
                    : child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExtendGestureTarget {
  final _ExtendGestureAreaConsumerState state;
  final EdgeInsets extendedTapArea;
  final bool transparentHitTest;
  final Offset translate;

  const _ExtendGestureTarget({required this.state, required this.extendedTapArea, required this.transparentHitTest, required this.translate});
}

class _ExtendGestureAreaValues extends InheritedWidget {
  const _ExtendGestureAreaValues({required this.targets, required this.setGestureAreaValues, required this.ratio, required super.child});

  final Map<int, _ExtendGestureTarget> targets;
  final double ratio;

  final void Function({required _ExtendGestureTarget target}) setGestureAreaValues;

  static _ExtendGestureAreaValues? of(BuildContext context) => context.getInheritedWidgetOfExactType<_ExtendGestureAreaValues>();

  @override
  bool updateShouldNotify(covariant _ExtendGestureAreaValues oldWidget) {
    return oldWidget != this;
  }
}

class ExtendGestureAreaConsumer extends StatefulWidget {
  const ExtendGestureAreaConsumer({required this.child, required this.gesturePadding, required this.transparentHitTest, required this.translate, super.key});

  final Widget child;
  final EdgeInsets? gesturePadding;
  final bool? transparentHitTest;
  final Offset? translate;

  @override
  State<ExtendGestureAreaConsumer> createState() => _ExtendGestureAreaConsumerState();
}

class _ExtendGestureAreaConsumerState extends State<ExtendGestureAreaConsumer> {
  _ExtendGestureAreaValues? ancestor;

  @override
  void initState() {
    super.initState();
    if (widget.gesturePadding == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ancestor = _ExtendGestureAreaValues.of(context);
      ancestor?.setGestureAreaValues(
        target: _ExtendGestureTarget(
          extendedTapArea: widget.gesturePadding!,
          state: this,
          transparentHitTest: widget.transparentHitTest ?? false,
          translate: widget.translate ?? Offset.zero,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class ExtendGestureAreaDetector extends ConsumerStatefulWidget {
  const ExtendGestureAreaDetector({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<ExtendGestureAreaDetector> createState() => _ExtendGestureAreaDetectorState();
}

class _ExtendGestureAreaDetectorState extends ConsumerState<ExtendGestureAreaDetector> {
  final Map<int, _ExtendGestureTarget> targets = {};

  void setValues({required _ExtendGestureTarget target}) {
    targets[target.state.hashCode] = target;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final ratio = ref.read(zoomRatioProvider);
    return _ExtendGestureAreaValues(
      targets: targets,
      setGestureAreaValues: setValues,
      ratio: ratio,
      child: RepaintBoundary(
        child: _ExtendGestureAreaRenderObjectWidget(child: widget.child, ratio: ratio),
      ),
    );
  }
}

class _ExtendGestureAreaRenderObjectWidget extends SingleChildRenderObjectWidget {
  final double ratio;
  _ExtendGestureAreaRenderObjectWidget({required Widget super.child, required this.ratio});

  @override
  RenderObject createRenderObject(BuildContext context) => _ExtendGestureAreaRenderBox(ratio: ratio);

  @override
  void updateRenderObject(BuildContext context, covariant _ExtendGestureAreaRenderBox renderObject) {
    final customGestureAreaValues = _ExtendGestureAreaValues.of(context);
    renderObject..targets = customGestureAreaValues?.targets ?? {};
    renderObject..isMobileView = PlatformX.isMobileView;
  }
}

class _ExtendGestureAreaRenderBox extends RenderBox with RenderObjectWithChildMixin<RenderBox> {
  final double ratio;

  _ExtendGestureAreaRenderBox({required this.ratio});

  Map<int, _ExtendGestureTarget> targets = {};
  bool isMobileView = false;

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    Rect? targetViewArea;
    RenderBox? targetRenderBox;
    Offset? targetPosition;
    bool targetTransparentHitTest = false;

    Rect? parentViewArea;
    RenderBox? parentRenderBox;

    final globalTapPosition = localToGlobal(position);
    final currentStartPosition = this.localToGlobal(Offset.zero);

    targets.keys.forEach((hash) {
      final target = targets[hash];
      if (target == null) return;
      if (!target.state.mounted) return;

      final renderBox = (target.state.context as Element).renderObject as RenderBox?;
      if (renderBox == null) return;

      final globalStartingPoint = renderBox.localToGlobal(Offset.zero);
      final startPositionDiff = globalStartingPoint - currentStartPosition;
      final viewSize = renderBox.size;

      final viewArea = Rect.fromLTRB(
        globalStartingPoint.dx,
        globalStartingPoint.dy,
        globalStartingPoint.dx + viewSize.width,
        globalStartingPoint.dy + viewSize.height,
      );

      final hitArea = Rect.fromLTRB(
        globalStartingPoint.dx - target.extendedTapArea.left * ratio,
        globalStartingPoint.dy - target.extendedTapArea.top * ratio,
        globalStartingPoint.dx + viewSize.width * ratio + target.extendedTapArea.right * ratio,
        globalStartingPoint.dy + viewSize.height * ratio + target.extendedTapArea.bottom * ratio,
      );

      if (targetViewArea == null && hitArea.contains(globalTapPosition)) {
        targetViewArea = viewArea;
        targetRenderBox = renderBox;
        targetTransparentHitTest = target.transparentHitTest;
        targetPosition = viewArea.contains(globalTapPosition) ? position - startPositionDiff : Offset.zero;
      }

      if (targetViewArea != null &&
          targetViewArea!.contains(viewArea.bottomLeft) &&
          targetViewArea!.contains(viewArea.bottomRight) &&
          targetViewArea!.contains(viewArea.topLeft) &&
          targetViewArea!.contains(viewArea.topRight) &&
          hitArea.contains(globalTapPosition)) {
        targetViewArea = viewArea;
        targetRenderBox = renderBox;
        targetTransparentHitTest = target.transparentHitTest;
        targetPosition = viewArea.contains(globalTapPosition) ? position - startPositionDiff : Offset.zero;
      }
    });

    if (targetTransparentHitTest) {
      targets.keys.forEach((hash) {
        final target = targets[hash];
        if (target == null) return;
        if (!target.state.mounted) return;

        final renderBox = (target.state.context as Element).renderObject as RenderBox?;
        if (renderBox == null) return;

        final globalStartingPoint = renderBox.localToGlobal(Offset.zero);
        final viewSize = renderBox.size;

        final viewArea = Rect.fromLTRB(
          globalStartingPoint.dx,
          globalStartingPoint.dy,
          globalStartingPoint.dx + viewSize.width,
          globalStartingPoint.dy + viewSize.height,
        );

        final hitArea = Rect.fromLTRB(
          globalStartingPoint.dx - target.extendedTapArea.left * ratio,
          globalStartingPoint.dy - target.extendedTapArea.top * ratio,
          globalStartingPoint.dx + viewSize.width * ratio + target.extendedTapArea.right * ratio,
          globalStartingPoint.dy + viewSize.height * ratio + target.extendedTapArea.bottom * ratio,
        );

        final containsTargetRenderBox =
            viewArea.contains(targetViewArea!.bottomLeft) &&
            viewArea.contains(targetViewArea!.bottomRight) &&
            viewArea.contains(targetViewArea!.topLeft) &&
            viewArea.contains(targetViewArea!.topRight) &&
            targetRenderBox != renderBox;

        if (parentViewArea == null && hitArea.contains(globalTapPosition) && containsTargetRenderBox) {
          parentViewArea = viewArea;
          parentRenderBox = renderBox;
        }

        if (parentViewArea != null &&
            parentViewArea!.contains(viewArea.bottomLeft) &&
            parentViewArea!.contains(viewArea.bottomRight) &&
            parentViewArea!.contains(viewArea.topLeft) &&
            parentViewArea!.contains(viewArea.topRight) &&
            containsTargetRenderBox &&
            hitArea.contains(globalTapPosition)) {
          parentViewArea = viewArea;
          parentRenderBox = renderBox;
        }
      });
    }

    if (targetRenderBox != null) {
      final parentStartPosition = parentRenderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
      final startPositionDiff = currentStartPosition - parentStartPosition;
      final superPosition = position + startPositionDiff;
      final superResult = parentRenderBox?.hitTest(result, position: superPosition) ?? false;
      final targetResult = targetRenderBox!.hitTest(result, position: targetPosition!);
      return superResult || targetResult;
    }

    return super.hitTest(result, position: position);
  }

  @override
  void performLayout() {
    if (child != null) {
      child!.layout(constraints.loosen(), parentUsesSize: true);
      size = Size(constraints.constrainWidth(child!.size.width), constraints.constrainHeight(child!.size.height));
    } else {
      size = Size(constraints.constrainWidth(constraints.maxWidth), constraints.constrainHeight(constraints.minHeight));
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      context.paintChild(child!, offset);
    }
  }
}
