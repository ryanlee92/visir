import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/widgets/desktop_scaffold.dart';
import 'package:flutter/material.dart';

class PopupMenuContainer extends StatefulWidget {
  final Widget? appBar;
  final Widget child;
  final double? horizontalPadding;
  final Color? backgroundColor;
  final ScrollPhysics? physics;
  final ScrollController? controller;

  const PopupMenuContainer({super.key, required this.child, this.appBar, this.horizontalPadding, this.backgroundColor, this.physics, this.controller});

  @override
  State<PopupMenuContainer> createState() => _PopupMenuContainerState();
}

class _PopupMenuContainerState extends State<PopupMenuContainer> {
  bool get isDarkMode => context.isDarkMode;

  @override
  Widget build(BuildContext context) {
    final body = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.appBar != null) widget.appBar!,
        PlatformX.isMobileView
            ? Expanded(
                child: SingleChildScrollView(
                  physics: widget.physics,
                  controller: widget.controller ?? ScrollController(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding ?? 12),
                    child: widget.child,
                  ),
                ),
              )
            : Padding(
                padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding ?? 12),
                child: widget.child,
              ),
      ],
    );

    return PlatformX.isMobileView
        ? Material(color: context.surface, child: body)
        : ClipRRect(
            borderRadius: BorderRadius.circular(DesktopScaffold.cardRadius),
            child: Container(child: body, color: context.surface),
          );
  }
}
