import 'package:Visir/dependency/xen_popup_card/src/appbar.dart';
import 'package:Visir/dependency/xen_popup_card/src/gutter.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/widgets/keyboard_shortcut.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

class XenPopupCard extends StatefulWidget {
  const XenPopupCard({
    required this.body,
    Key? key,
    this.padding,
    this.appBar,
    this.gutter,
    this.maxSize,
    this.cardBgColor,
    this.borderRadius,
    this.disableEscapeClose,
    required this.isMedia,
    required this.isFlexibleHeightPopup,
  }) : super(key: key);

  final Widget body;
  final Size? maxSize;
  final double? padding;
  final XenCardAppBar? appBar;
  final XenCardGutter? gutter;
  final double? borderRadius;
  final Color? cardBgColor;

  final bool? disableEscapeClose;
  final bool isMedia;
  final bool isFlexibleHeightPopup;

  @override
  State<XenPopupCard> createState() => _XenPopupCardState();
}

class _XenPopupCardState extends State<XenPopupCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).focusedChild?.unfocus();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final child = Stack(
      children: [
        Center(
          child: widget.isFlexibleHeightPopup
              ? FittedBox(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: widget.maxSize?.width ?? 440),
                    padding: EdgeInsets.all(widget.padding ?? 0),
                    child: Material(
                      borderRadius: BorderRadius.circular(widget.borderRadius ?? 20),
                      color: widget.cardBgColor ?? context.background,
                      child: Stack(
                        children: [
                          // body
                          widget.body,
                          // appbar
                          if (!widget.isMedia) Align(alignment: Alignment.topCenter, child: widget.appBar ?? const SizedBox()),
                          // gutter
                          if (!widget.isMedia) Align(alignment: Alignment.bottomCenter, child: widget.gutter ?? const SizedBox()),
                        ],
                      ),
                    ),
                  ),
                )
              : Container(
                  constraints: widget.isMedia ? null : BoxConstraints(maxWidth: widget.maxSize?.width ?? 440, maxHeight: widget.maxSize?.height ?? 560),
                  padding: EdgeInsets.all(widget.padding ?? 0),
                  child: Material(
                    borderRadius: BorderRadius.circular(widget.borderRadius ?? 20),
                    color: widget.cardBgColor ?? context.background,
                    child: Stack(
                      children: [
                        // body
                        widget.body,
                        // appbar
                        if (!widget.isMedia) Align(alignment: Alignment.topCenter, child: widget.appBar ?? const SizedBox()),
                        // gutter
                        if (!widget.isMedia) Align(alignment: Alignment.bottomCenter, child: widget.gutter ?? const SizedBox()),
                      ],
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).maybePop();
          },
          onPanStart: (details) async {
            if (!PlatformX.isWeb && PlatformX.isDesktop) {
              appWindow.startDragging();
            }
          },
          child: Container(width: double.infinity, height: Constants.desktopTitleBarHeight.toDouble(), color: Colors.transparent),
        ),
      ],
    );
    if (widget.disableEscapeClose == true) return child;
    return KeyboardShortcut(child: child);
  }
}
