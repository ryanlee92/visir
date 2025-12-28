import 'dart:math';

import 'package:Visir/app.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/desktop_scaffold.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const double _kMinTileHeight = 24;

/// The actual [ContextMenu] to be displayed
///
/// You will most likely use [showContextMenu] to manually display a [ContextMenu].
///
/// If you just want to use a normal [ContextMenu], please use [ContextMenuArea].

class ContextMenu extends ConsumerStatefulWidget {
  /// The [Offset] from coordinate origin the [ContextMenu] will be displayed at.
  final Offset topLeft;
  final Offset bottomRight;

  /// The items to be displayed. [ListTile] is very useful in most cases.
  final Widget child;

  /// The padding value at the top an bottom between the edge of the [ContextMenu] and the first / last item
  final double verticalPadding;
  final double borderRaidus;

  /// The width for the [ContextMenu]. 320 by default according to Material Design specs.
  final double width;
  final double? height;

  final Color? backgroundColor;
  final Color? shadowColor;
  final ScrollPhysics? scrollPhysics;

  final Clip? clipBehavior;

  final bool isPopupMenu;
  final Size? popupParentSize;
  final PopupMenuLocation? popupMenuLocation;
  final bool? hideShadow;
  final bool? doNotResizePopup;

  const ContextMenu({
    Key? key,
    required this.topLeft,
    required this.bottomRight,
    required this.child,
    required this.isPopupMenu,
    this.verticalPadding = 8,
    this.borderRaidus = 12,
    this.width = 320,
    this.height,
    this.backgroundColor,
    this.shadowColor,
    this.hideShadow,
    this.scrollPhysics,
    this.clipBehavior,
    this.popupParentSize,
    this.popupMenuLocation,
    this.doNotResizePopup,
  }) : super(key: key);

  @override
  _ContextMenuState createState() => _ContextMenuState();
}

class _ContextMenuState extends ConsumerState<ContextMenu> with WidgetsBindingObserver {
  Map<ValueKey, double> _heights = Map();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final ratio = 1.0;

    final backgroundColor = widget.backgroundColor ?? (context.context.surface);

    double height = widget.height ?? 0;
    final screenRatio = ref.watch(zoomRatioProvider);
    final margin = 6.0 * screenRatio;

    if (widget.height == null) {
      _heights.values.forEach((element) {
        height = element;
      });
    }

    final screenHeight = (context.screenSize.height - context.padding.top * screenRatio - context.padding.bottom * screenRatio);
    final screenWidth = context.screenSize.width;
    final screenPadding = context.padding;

    final resizedWidthDiff = 0;
    //widget.width * screenRatio - widget.width;
    final resizedHeightDiff = 0;
    //widget.height != null ? widget.height! * screenRatio - widget.height! : 0;

    if (height > screenHeight) height = screenHeight;

    if (height == screenHeight) {
      height = (height - Constants.desktopTitleBarHeight.toDouble()) / ratio - margin;
    }

    final width = widget.width * screenRatio;
    height = height * screenRatio;

    double paddingLeft = widget.topLeft.dx / ratio + margin;
    double paddingTop = widget.topLeft.dy / ratio + margin;
    double paddingRight = screenWidth / ratio - paddingLeft - width;
    double paddingBottom = screenHeight / ratio - paddingTop - height;

    if (PopupMenuLocation.right == widget.popupMenuLocation) {
      paddingLeft = widget.bottomRight.dx / ratio + margin;
      paddingTop = (widget.topLeft.dy - (screenPadding.top * screenRatio)) / ratio;
      paddingRight = screenWidth / ratio - paddingLeft - width;
      paddingBottom = screenHeight / ratio - paddingTop - height;
    }

    if (PopupMenuLocation.bottom == widget.popupMenuLocation) {
      paddingLeft = widget.topLeft.dx / ratio;
      paddingTop = (widget.bottomRight.dy) / ratio - (screenPadding.top * screenRatio) + margin;
      paddingRight = screenWidth / ratio - paddingLeft - width;
      paddingBottom = screenHeight / ratio - paddingTop - height;
    }

    if (paddingLeft < margin + resizedWidthDiff) {
      paddingRight = paddingRight - (margin + resizedWidthDiff - paddingLeft);
      paddingLeft = margin + resizedWidthDiff;
    }

    if (paddingTop < margin + resizedHeightDiff) {
      paddingBottom = paddingBottom - (margin + resizedHeightDiff - paddingTop);
      paddingTop = margin + resizedHeightDiff;
    }

    if (paddingRight < margin + resizedWidthDiff) {
      paddingLeft += (paddingRight - margin - resizedWidthDiff);
      paddingRight = margin + resizedWidthDiff;
    }

    if (paddingBottom < margin + resizedHeightDiff) {
      paddingBottom = margin + resizedHeightDiff;
      paddingTop = screenHeight - paddingBottom - height;
      if (paddingTop < margin + resizedHeightDiff) paddingTop = margin + resizedHeightDiff;
      paddingBottom = margin + resizedHeightDiff;
    }

    if (PopupMenuLocation.right == widget.popupMenuLocation && paddingLeft > margin + width && paddingRight <= margin + resizedWidthDiff) {
      paddingLeft = widget.topLeft.dx - width - margin;
      paddingRight = screenWidth - widget.topLeft.dx + margin;
    }

    if (PopupMenuLocation.bottom == widget.popupMenuLocation && paddingTop > margin + height && paddingBottom <= margin + resizedHeightDiff) {
      paddingBottom = screenHeight - widget.topLeft.dy + margin;
      paddingTop = screenHeight - paddingBottom - height;
    }

    final child = Material(
      color: backgroundColor,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: SingleChildScrollView(
          physics: widget.scrollPhysics,
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: true),
            child: widget.doNotResizePopup == true
                ? widget.child
                : _GrowingWidget(
                    child: widget.child,
                    onHeightChange: (height) {
                      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                        _heights[ValueKey(widget.child)] = height;
                        setState(() {});
                      });
                    },
                  ),
          ),
        ),
      ),
    );

    // GestureDetector를 제거하고 showModal의 barrier가 탭을 처리하도록 함
    // 메뉴 영역만 배치하고, 백그라운드 탭은 showModal의 barrier가 처리
    return Padding(
      padding: EdgeInsets.fromLTRB(max(0, paddingLeft), max(0, paddingTop), max(0, paddingRight), max(0, paddingBottom)),
      child: SizedBox(
        width: widget.width * screenRatio,
        height: widget.height != null ? widget.height! * screenRatio : null,
        child: DevicePixelRatio(
          child: Container(
            key: ValueKey('context_menu_${WidgetsBinding.instance.platformDispatcher.platformBrightness}'),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(DesktopScaffold.cardRadius),
              color: widget.hideShadow == true ? null : context.surface,
              border: widget.hideShadow == true ? null : Border.all(color: context.outline, width: 0.5),
              boxShadow: widget.hideShadow == true ? null : PopupMenu.popupShadow,
            ),
            child: widget.hideShadow == true ? child : ClipRRect(borderRadius: BorderRadius.circular(DesktopScaffold.cardRadius), child: child),
          ),
        ),
      ),
    );
  }
}

class _GrowingWidget extends StatefulWidget {
  final Widget child;
  final ValueChanged<double> onHeightChange;

  const _GrowingWidget({Key? key, required this.child, required this.onHeightChange}) : super(key: key);

  @override
  __GrowingWidgetState createState() => __GrowingWidgetState();
}

class __GrowingWidgetState extends State<_GrowingWidget> {
  @override
  Widget build(BuildContext context) {
    return NotificationListener<SizeReporterNotification>(
      onNotification: (notification) {
        widget.onHeightChange.call(notification.size.height);
        return true;
      },
      child: SizeReporter(child: widget.child),
    );
  }
}

/// Extends from Notification.
class SizeReporterNotification extends Notification {
  const SizeReporterNotification(this.size);

  /// Notification data.
  final Size size;
}

/// A widget that reports its child's size to the notification system.
class SizeReporter extends SingleChildRenderObjectWidget {
  const SizeReporter({super.key, required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSizeReporter(context: context);
  }

  @override
  void updateRenderObject(BuildContext context, RenderSizeReporter renderObject) {
    /// Update any additional properties added later.
  }
}

/// The render object that reports its size to the notification system.
class RenderSizeReporter extends RenderProxyBox {
  RenderSizeReporter({required BuildContext context, RenderBox? child}) : _context = context, super(child);

  /// Required to access the [BuildContext] to dispatch the notification.
  final BuildContext _context;

  /// The previous size of the child.
  Size? _oldSize;

  @override
  void performLayout() {
    /// Takes care of laying out the child and making sure its size is usable.
    super.performLayout();

    final newSize = child!.size;

    /// Only dispatch the notification if the size has changed.
    if (_oldSize != newSize) {
      _oldSize = newSize;
      SizeReporterNotification(newSize).dispatch(_context);
    }
  }
}
