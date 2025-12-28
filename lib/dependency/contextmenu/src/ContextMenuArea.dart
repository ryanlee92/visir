import 'package:Visir/app.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ContextMenu.dart';

/// Show a [ContextMenu] on the given [BuildContext]. For other parameters, see [ContextMenu].
void showContextMenu({
  required Offset topLeft,
  required Offset bottomRight,
  required BuildContext context,
  required Widget child,
  required double verticalPadding,
  required double borderRadius,
  required double width,
  required bool isPopupMenu,
  required bool hideShadow,
  double? height,
  Color? backgroundColor,
  Color? shadowColor,
  VoidCallback? beforePopup,
  VoidCallback? afterPopup,
  VoidCallback? onPopup,
  Clip? clipBehavior,
  Size? popupParentSize,
  PopupMenuLocation? popupMenuLocation,
  bool? barrierDismissible,
  bool? doNotResizePopup,
}) {
  beforePopup?.call();

  showModal(
        context: context,
        configuration: FadeTransitionConfiguration(
          barrierColor: Colors.transparent,
          barrierDismissible: barrierDismissible ?? true,
          transitionDuration: const Duration(milliseconds: 150),
          reverseTransitionDuration: const Duration(milliseconds: 150),
        ),
        builder: (context) => ReverseDevicePixelRatio(
          child: ContextMenu(
            topLeft: topLeft,
            bottomRight: bottomRight,
            child: child,
            verticalPadding: verticalPadding,
            borderRaidus: borderRadius,
            width: width,
            height: height,
            backgroundColor: backgroundColor,
            shadowColor: shadowColor,
            hideShadow: hideShadow,
            scrollPhysics: NeverScrollableScrollPhysics(),
            clipBehavior: clipBehavior,
            isPopupMenu: isPopupMenu,
            popupParentSize: popupParentSize,
            popupMenuLocation: popupMenuLocation,
            doNotResizePopup: doNotResizePopup,
          ),
        ),
      )
      .then((e) {
        afterPopup?.call();
      })
      .catchError((e) {
        afterPopup?.call();
      });
  onPopup?.call();
}

class FadeTransitionConfiguration extends ModalConfiguration {
  /// Creates the Material fade transition configuration.
  ///
  /// [barrierDismissible] configures whether or not tapping the modal's
  /// scrim dismisses the modal. [barrierLabel] sets the semantic label for
  /// a dismissible barrier. [barrierDismissible] cannot be null. If
  /// [barrierDismissible] is true, the [barrierLabel] cannot be null.
  const FadeTransitionConfiguration({
    super.barrierColor = Colors.black54,
    super.barrierDismissible = true,
    super.transitionDuration = const Duration(milliseconds: 80),
    super.reverseTransitionDuration = const Duration(milliseconds: 80),
    String super.barrierLabel = 'Dismiss',
  });

  @override
  Widget transitionBuilder(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(opacity: animation, child: child);
  }
}

/// The [ContextMenuArea] is the way to use a [ContextMenu]
///
/// It listens for right click and long press and executes [showContextMenu]
/// with the corresponding location [Offset].
///

enum ContextMenuActionType { none, tap, longPress, secondaryTap }

class ContextMenuArea extends ConsumerStatefulWidget {
  /// The widget displayed inside the [ContextMenuArea]
  final Widget child;

  /// A [List] of items to be displayed in an opened [ContextMenu]
  ///
  /// Usually, a [ListTile] might be the way to go.
  final Widget popup;

  /// The padding value at the top an bottom between the edge of the [ContextMenu] and the first / last item
  final double verticalPadding;

  /// The width for the [ContextMenu]. 320 by default according to Material Design specs.
  final double width;
  final double? height;
  final Color? backgroundColor;
  final Color? shadowColor;
  final double borderRadius;

  final ContextMenuActionType type;

  final ScrollPhysics? scrollPhysics;

  final PopupMenuLocation location;
  final VoidCallback? onPopup;
  final VoidCallback? beforePopup;
  final VoidCallback? afterPopup;
  final Clip? clipBehavior;
  final PopupMenuLocation? popupMenuLocation;
  final Offset? forceShiftOffset;
  final bool? hideShadow;
  final VisirButtonStyle style;
  final bool? noIntrinsicWidth;
  final bool? barrierDismissible;

  final VoidCallback? onTap;

  final VisirButtonOptions? tooltipOptions;
  final bool? doNotResizePopup;

  const ContextMenuArea({
    Key? key,
    required this.child,
    required this.popup,
    required this.type,
    required this.location,
    this.verticalPadding = 0,
    this.borderRadius = 12,
    this.width = 320,
    this.height,
    this.backgroundColor,
    this.shadowColor,
    this.scrollPhysics,
    this.onPopup,
    this.beforePopup,
    this.afterPopup,
    this.clipBehavior,
    this.popupMenuLocation,
    this.forceShiftOffset,
    this.hideShadow,
    this.noIntrinsicWidth,
    required this.style,
    this.tooltipOptions,
    this.onTap,
    this.barrierDismissible,
    this.doNotResizePopup,
  }) : super(key: key);

  @override
  ConsumerState<ContextMenuArea> createState() => ContextMenuAreaState();
}

class ContextMenuAreaState extends ConsumerState<ContextMenuArea> {
  final GlobalKey childKey = GlobalKey();

  Offset getTopLeftAnchorPosition(double ratio) {
    final RenderBox renderBox = childKey.currentContext?.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final screenRatio = ref.read(zoomRatioProvider);

    return Offset(offset.dx + (widget.forceShiftOffset?.dx ?? 0) * screenRatio, offset.dy + (widget.forceShiftOffset?.dy ?? 0) * screenRatio);
  }

  Offset getBottomRightAnchorPosition(double ratio) {
    final RenderBox renderBox = childKey.currentContext?.findRenderObject() as RenderBox;
    final Size size = renderBox.size;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final screenRatio = ref.read(zoomRatioProvider);

    return Offset(
      offset.dx + size.width * ratio + (widget.forceShiftOffset?.dx ?? 0) * screenRatio,
      offset.dy + size.height * ratio + (widget.forceShiftOffset?.dy ?? 0) * screenRatio,
    );
  }

  Size getChildSize() {
    final RenderBox renderBox = childKey.currentContext?.findRenderObject() as RenderBox;
    final Size size = renderBox.size;
    return Size(size.width, size.height);
  }

  void showPopup({Offset? globalPosition}) {
    final renderBox = childKey.currentContext?.findRenderObject() as RenderBox;
    final globalPosition = renderBox.localToGlobal(Offset.zero);
    final ratio = ref.read(zoomRatioProvider);
    showContextMenu(
      topLeft: Offset(
        widget.location != PopupMenuLocation.point
            ? getTopLeftAnchorPosition(ratio).dx
            : globalPosition == null
            ? 0
            : globalPosition.dx,
        widget.location != PopupMenuLocation.point
            ? getTopLeftAnchorPosition(ratio).dy
            : globalPosition == null
            ? 0
            : globalPosition.dy,
      ),
      bottomRight: Offset(
        widget.location != PopupMenuLocation.point
            ? getBottomRightAnchorPosition(ratio).dx
            : globalPosition == null
            ? 0
            : globalPosition.dx,
        widget.location != PopupMenuLocation.point
            ? getBottomRightAnchorPosition(ratio).dy
            : globalPosition == null
            ? 0
            : globalPosition.dy,
      ),
      context: Utils.mainContext,
      child: widget.popup,
      verticalPadding: widget.verticalPadding,
      borderRadius: widget.borderRadius,
      width: widget.width,
      height: widget.height,
      backgroundColor: widget.backgroundColor,
      shadowColor: widget.shadowColor,
      beforePopup: widget.beforePopup,
      afterPopup: widget.afterPopup,
      onPopup: widget.onPopup,
      clipBehavior: widget.clipBehavior,
      isPopupMenu: true,
      popupParentSize: getChildSize(),
      popupMenuLocation: widget.popupMenuLocation,
      hideShadow: widget.hideShadow ?? false,
      barrierDismissible: widget.barrierDismissible,
      doNotResizePopup: widget.doNotResizePopup,
    );
  }

  @override
  Widget build(BuildContext context) {
    // ref.watch(zoomRatioProvider);
    if (widget.type == ContextMenuActionType.none) {
      return widget.child;
    }

    final result = VisirButton(
      key: childKey,
      style: widget.style,
      options: widget.tooltipOptions,
      type: VisirButtonAnimationType.scaleAndOpacity,
      behavior: HitTestBehavior.translucent,
      onSecondaryTapDown: widget.type == ContextMenuActionType.secondaryTap ? (details) => showPopup(globalPosition: details.globalPosition) : null,
      onLongPressStart: widget.type == ContextMenuActionType.longPress ? (details) => showPopup(globalPosition: details.globalPosition) : null,
      onTapUp: widget.type == ContextMenuActionType.tap ? (details) => showPopup(globalPosition: details.globalPosition) : (details) => widget.onTap?.call(),
      child: widget.child,
    );

    if (widget.noIntrinsicWidth == true) return result;
    return IntrinsicWidth(child: result);
  }
}
