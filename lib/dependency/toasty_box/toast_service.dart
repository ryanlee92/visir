import 'dart:math';

import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/desktop_scaffold.dart';
import 'package:Visir/features/common/presentation/widgets/visir_app_bar.dart';
import 'package:flutter/material.dart';

import 'custom_toast.dart';
import 'toast_enums.dart';

class ToastService {
  static final List<OverlayEntry?> _overlayEntries = [];
  static final List<double> _overlayPositions = [];
  static final List<double> _overlayOpacities = [];
  static final List<int> _overlayIndexList = [];
  static final List<AnimationController?> _animationControllers = [];
  static OverlayState? _overlayState;

  static void showToastNumber(int val) {
    assert(val > 0, "Show toast number can't be negative or zero. Default show toast number is 5.");
    if (val > 0) {}
  }

  static void _reverseAnimation(int index) {
    if (_overlayIndexList.contains(index)) {
      _animationControllers[index]?.reverse().then((_) async {
        await Future.delayed(const Duration(milliseconds: 50));
        _removeOverlayEntry(index);
      });
    }
  }

  static void _removeOverlayEntry(int index) {
    _overlayEntries[index]?.remove();
    _animationControllers[index]?.dispose();
    _overlayIndexList.remove(index);
  }

  static void _forwardAnimation(int index) {
    _overlayState?.insert(_overlayEntries[index]!);
    _animationControllers[index]?.forward();
  }

  static double _calculatePosition(int index) {
    return _overlayPositions[index] + (PlatformX.isDesktopView ? 0 : Utils.mainContext.padding.bottom);
  }

  static double _calculateOpacity(int index) {
    return _overlayOpacities[index];
  }

  static void _addOverlayPosition(int index) {
    _overlayPositions.add((PlatformX.isMobileView ? 52 : -74));
    _overlayOpacities.add(0);
    _overlayIndexList.add(index);
  }

  static bool _isToastInFront(int index) => index > _overlayPositions.length - 5;

  static void _updateOverlayPositions({bool isReverse = false, required int pos}) {
    if (isReverse) {
      _reverseUpdatePositions(pos);
    } else {
      _forwardUpdatePositions(pos);
    }
  }

  static void _reverseUpdatePositions(int index) {
    _overlayOpacities[index] = 0;
    _overlayPositions[index] = _overlayPositions[index] - (PlatformX.isMobileView ? 16 : 90);
    _overlayEntries[index]?.markNeedsBuild();
  }

  static void _forwardUpdatePositions(int index) {
    _overlayOpacities[index] = 1;
    _overlayPositions[index] = _overlayPositions[index] + (PlatformX.isMobileView ? 16 : 90);
    _overlayEntries[index]?.markNeedsBuild();
  }

  static void _toggleExpand(int index) {
    // if (_expandedIndex.value == index) {
    //   _expandedIndex.value = -1;
    // } else {
    //   _expandedIndex.value = index;
    // }
    // _rebuildPositions();
  }

  static Duration _toastDuration(ToastLength length) {
    switch (length) {
      case ToastLength.short:
        return const Duration(milliseconds: 2000);
      case ToastLength.medium:
        return const Duration(milliseconds: 3500);
      case ToastLength.long:
        return const Duration(milliseconds: 5000);
      case ToastLength.ages:
        return const Duration(minutes: 2);
      default:
        return const Duration(hours: 24);
    }
  }

  static Future<void> hideToast(int index) async {
    // _updateOverlayPositions(isReverse: true, pos: index);
    _removeOverlayEntry(index);
  }

  static Future<void> _showToast(
    BuildContext context, {
    String? message,
    TextStyle? messageStyle,
    Widget? leading,
    double? width,
    bool isClosable = false,
    double expandedHeight = 100,
    Color? backgroundColor,
    Color? shadowColor,
    Curve? slideCurve,
    Curve positionCurve = Curves.easeInOut,
    ToastLength length = ToastLength.long,
    DismissDirection dismissDirection = DismissDirection.down,
    required Widget Function(int index) builder,
  }) async {
    assert(expandedHeight >= 0.0, "Expanded height should not be a negative number!");
    if (context.mounted) {
      _overlayState = Overlay.of(context);
      final controller = AnimationController(
        vsync: _overlayState!,
        duration: const Duration(milliseconds: 250),
        reverseDuration: const Duration(milliseconds: 250),
      );
      _animationControllers.add(controller);
      int controllerIndex = _animationControllers.indexOf(controller);
      _addOverlayPosition(controllerIndex);
      final overlayEntry = OverlayEntry(
        builder: (context) {
          final opacity = _calculateOpacity(controllerIndex);
          final width = PlatformX.isDesktopView ? 380.0 : context.width - 12;

          return AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              return AnimatedPositioned(
                top: (PlatformX.isDesktopView ? 8 : max(context.padding.top - 8, 20)) + 12 - (1 - controller.value) * 16,
                height: PlatformX.isDesktopView ? 32 + DesktopScaffold.backgroundPadding + DesktopScaffold.cardPadding : VisirAppBar.height,
                left: (context.width - width) / 2,
                right: (context.width - width) / 2,
                duration: const Duration(milliseconds: 500),
                curve: positionCurve,
                child: child!,
              );
            },
            child: AnimatedOpacity(
              opacity: opacity,
              duration: const Duration(milliseconds: 500),
              curve: positionCurve,
              child: Dismissible(
                key: Key(UniqueKey().toString()),
                direction: dismissDirection,
                onDismissed: (_) {
                  hideToast(_animationControllers.indexOf(controller));
                },
                child: CustomToast(
                  message: message,
                  width: width,
                  messageStyle: messageStyle,
                  backgroundColor: backgroundColor,
                  shadowColor: shadowColor,
                  curve: slideCurve,
                  isClosable: isClosable,
                  isInFront: _isToastInFront(_animationControllers.indexOf(controller)),
                  controller: controller,
                  onTap: () => _toggleExpand(controllerIndex),
                  onClose: () {
                    hideToast(_animationControllers.indexOf(controller));
                  },
                  leading: leading,
                  child: builder(_animationControllers.indexOf(controller)),
                ),
              ),
            ),
          );
        },
      );
      _overlayEntries.add(overlayEntry);
      _forwardAnimation(_animationControllers.indexOf(controller));
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        _updateOverlayPositions(pos: _animationControllers.indexOf(controller));
        Future.delayed(Duration(milliseconds: 2000), () {
          _updateOverlayPositions(pos: _animationControllers.indexOf(controller), isReverse: true);
          _reverseAnimation(_animationControllers.indexOf(controller));
        });
      });
    }
  }

  static Future<void> showToast(
    BuildContext context, {
    String? message,
    TextStyle? messageStyle,
    Widget? leading,
    bool isClosable = false,
    double expandedHeight = 100,
    Color? backgroundColor,
    Color? shadowColor,
    Curve? slideCurve,
    Curve positionCurve = Curves.easeInOut,
    ToastLength length = ToastLength.short,
    DismissDirection dismissDirection = DismissDirection.down,
    required Widget Function(int index) builder,
  }) async {
    _showToast(
      context,
      message: message,
      messageStyle: messageStyle,
      isClosable: isClosable,
      expandedHeight: expandedHeight,
      backgroundColor: backgroundColor,
      shadowColor: shadowColor,
      positionCurve: positionCurve,
      length: length,
      dismissDirection: dismissDirection,
      leading: leading,
      builder: builder,
    );
  }

  static Future<void> showWidgetToast(
    BuildContext context, {
    bool isClosable = false,
    double expandedHeight = 100,
    Color? backgroundColor,
    double? width,
    Color? shadowColor,
    Curve? slideCurve,
    Curve positionCurve = Curves.easeInOut,
    ToastLength length = ToastLength.short,
    DismissDirection dismissDirection = DismissDirection.down,
    required Widget Function(int index) builder,
  }) async {
    _showToast(
      context,
      width: width,
      isClosable: isClosable,
      expandedHeight: expandedHeight,
      backgroundColor: backgroundColor,
      shadowColor: shadowColor,
      positionCurve: positionCurve,
      length: length,
      dismissDirection: dismissDirection,
      builder: builder,
    );
  }

  static Future<void> showSuccessToast(
    BuildContext context, {
    String? message,
    Widget? leading,
    bool isClosable = false,
    double expandedHeight = 100,
    Color? backgroundColor,
    Color? shadowColor,
    Curve? slideCurve,
    Curve positionCurve = Curves.easeInOut,
    ToastLength length = ToastLength.short,
    DismissDirection dismissDirection = DismissDirection.down,
    required Widget Function(int index) builder,
  }) async {
    _showToast(
      context,
      message: message,
      messageStyle: const TextStyle(color: Colors.white),
      isClosable: isClosable,
      expandedHeight: expandedHeight,
      backgroundColor: backgroundColor ?? context.errorContainer,
      shadowColor: shadowColor ?? context.errorContainer,
      positionCurve: positionCurve,
      length: length,
      dismissDirection: dismissDirection,
      leading: leading ?? const Icon(Icons.check_circle, color: Colors.white),
      builder: builder,
    );
  }

  static Future<void> showErrorToast(
    BuildContext context, {
    String? message,
    bool isClosable = false,
    double expandedHeight = 100,
    Color? backgroundColor,
    Color? shadowColor,
    Curve? slideCurve,
    Curve positionCurve = Curves.easeInOut,
    ToastLength length = ToastLength.short,
    DismissDirection dismissDirection = DismissDirection.down,
    required Widget Function(int index) builder,
  }) async {
    _showToast(
      context,
      message: message,
      messageStyle: const TextStyle(color: Colors.white),
      isClosable: isClosable,
      expandedHeight: expandedHeight,
      backgroundColor: backgroundColor ?? Colors.red,
      shadowColor: shadowColor ?? Colors.red.shade500,
      positionCurve: positionCurve,
      length: length,
      dismissDirection: dismissDirection,
      leading: const Icon(Icons.error, color: Colors.white),
      builder: builder,
    );
  }

  static Future<void> showWarningToast(
    BuildContext context, {
    String? message,
    bool isClosable = false,
    double expandedHeight = 100,
    Color? backgroundColor,
    Color? shadowColor,
    Curve? slideCurve,
    Curve positionCurve = Curves.easeInOut,
    ToastLength length = ToastLength.short,
    DismissDirection dismissDirection = DismissDirection.down,
    required Widget Function(int index) builder,
  }) async {
    _showToast(
      context,
      message: message,
      messageStyle: const TextStyle(color: Colors.white),
      isClosable: isClosable,
      expandedHeight: expandedHeight,
      backgroundColor: backgroundColor ?? Colors.orange,
      shadowColor: shadowColor ?? Colors.orange.shade500,
      positionCurve: positionCurve,
      length: length,
      dismissDirection: dismissDirection,
      leading: const Icon(Icons.warning, color: Colors.white),
      builder: builder,
    );
  }
}
