import 'package:Visir/dependency/contextmenu/contextmenu.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/selection_widget.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

enum PopupMenuLocation { point, bottom, right }

final forceShiftOffsetForMenu = Offset(0, -36);

class PopupMenu extends StatefulWidget {
  final Widget child;
  final Widget? popup;
  final Widget Function(ScrollController?)? popupBuilderOnMobileView;
  final bool? forcePopup;
  final double? width;
  final double? height;
  final double? borderRadius;
  final ContextMenuActionType type;
  final ScrollPhysics? scrollPhysics;
  final PopupMenuLocation location;
  final VoidCallback? onPopup;
  final VoidCallback? beforePopup;
  final VoidCallback? afterPopup;
  final Color? backgroundColor;
  final bool? enabled;
  final bool? closeOnTapWhenDisabled;
  final Offset? forceShiftOffset;
  final SystemMouseCursor? mouseCursor;
  final Clip? clipBehavior;
  final bool? hideShadow;
  final bool? doNotResizePopup;
  final VisirButtonStyle style;
  final VisirButtonOptions? options;
  final bool? noIntrinsicWidth;
  final VoidCallback? onTap;
  final bool? barrierDismissible;
  final String? mobiileBottomSheetTitle;
  final bool? mobileUseBottomSheet;

  static List<BoxShadow> popupShadow = [BoxShadow(color: Colors.black.withValues(alpha: 0.20), blurRadius: 12, offset: Offset(0, 4), spreadRadius: 0)];

  const PopupMenu({
    super.key,
    required this.child,
    required this.type,
    required this.location,
    required this.style,
    this.popup,
    this.popupBuilderOnMobileView,
    this.forcePopup,
    this.width,
    this.height,
    this.borderRadius,
    this.scrollPhysics,
    this.onPopup,
    this.beforePopup,
    this.afterPopup,
    this.backgroundColor,
    this.enabled,
    this.closeOnTapWhenDisabled,
    this.forceShiftOffset,
    this.mouseCursor,
    this.clipBehavior,
    this.hideShadow,
    this.noIntrinsicWidth,
    this.options,
    this.onTap,
    this.barrierDismissible,
    this.mobiileBottomSheetTitle,
    this.mobileUseBottomSheet,
    this.doNotResizePopup,
  });

  @override
  State<PopupMenu> createState() => PopupMenuState();
}

class PopupMenuState extends State<PopupMenu> with WidgetsBindingObserver {
  bool get _enabled => widget.enabled ?? true;

  GlobalKey<ContextMenuAreaState> contextMenuAreaKey = GlobalKey();

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
    if (mounted) setState(() {});
  }

  void showPopup() {
    contextMenuAreaKey.currentState?.showPopup();
  }

  @override
  Widget build(BuildContext context) {
    if (!_enabled)
      return RepaintBoundary(
        child: IntrinsicWidth(
          child: VisirButton(
            style: widget.style,
            options: widget.options,
            onTap: widget.closeOnTapWhenDisabled == true ? context.pop : null,
            type: VisirButtonAnimationType.none,
            behavior: HitTestBehavior.translucent,
            child: widget.child,
          ),
        ),
      );

    final width = widget.options?.shortcuts?.isNotEmpty == true && widget.popup == null && PlatformX.isMobileView && widget.width != null ? widget.width! - 20 : widget.width;

    final popup =
        widget.popup ??
        (widget.options?.shortcuts?.isNotEmpty == true
            ? SelectionWidget<VisirButtonKeyboardShortcut>(
                cellHeight: 36,
                onSelect: (item) => item.onTrigger?.call(),
                items: widget.options!.shortcuts!,
                options: (item) => VisirButtonOptions(
                  tooltipLocation: VisirButtonTooltipLocation.none,
                  shortcuts: [VisirButtonKeyboardShortcut(keys: item.keys, message: '', subkeys: item.subkeys)],
                ),
                getTitle: (item) => item.itemTitle!,
                getDescription: PlatformX.isMobileView
                    ? null
                    : (item) =>
                          '${[item.keys.ordered.map((e) => e.title).join(' '), ...(item.subkeys?.map((e) => e.ordered.map((k) => k.title).join(' ')) ?? List<String>.from([]))].join(' / ')}',
              )
            : SizedBox.shrink());

    if (PlatformX.isMobileView && widget.forcePopup != true && widget.type != ContextMenuActionType.none) {
      final result = VisirButton(
        style: widget.style,
        options: widget.options,
        type: VisirButtonAnimationType.scaleAndOpacity,
        behavior: HitTestBehavior.translucent,
        onTap: () {
          widget.beforePopup?.call();
          if (widget.mobileUseBottomSheet == true) {
            Utils.showBottomDialog(
              title: TextSpan(text: widget.mobiileBottomSheetTitle ?? ''),
              body: widget.popupBuilderOnMobileView?.call(null) ?? popup,
            );
          } else {
            Utils.showPopupDialog(child: widget.popupBuilderOnMobileView?.call(null) ?? popup);
          }
          widget.onPopup?.call();
        },
        child: widget.child,
      );

      if (widget.noIntrinsicWidth == true) return result;
      return RepaintBoundary(child: IntrinsicWidth(child: result));
    }

    return RepaintBoundary(
      child: ContextMenuArea(
        key: contextMenuAreaKey,
        type: widget.type,
        style: widget.style,
        child: widget.child,
        width: width ?? 320,
        height: widget.height,
        borderRadius: widget.borderRadius ?? 12,
        location: widget.location,
        popup: popup,
        scrollPhysics: widget.scrollPhysics,
        onPopup: widget.onPopup,
        beforePopup: widget.beforePopup,
        afterPopup: widget.afterPopup,
        backgroundColor: widget.backgroundColor,
        shadowColor: Colors.transparent,
        popupMenuLocation: widget.location,
        forceShiftOffset: widget.forceShiftOffset,
        clipBehavior: widget.clipBehavior,
        hideShadow: widget.hideShadow,
        noIntrinsicWidth: widget.noIntrinsicWidth,
        tooltipOptions: widget.options,
        onTap: widget.onTap,
        barrierDismissible: widget.barrierDismissible,
        doNotResizePopup: widget.doNotResizePopup,
      ),
    );
  }
}
