import 'package:Visir/dependency/contextmenu/src/ContextMenuArea.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:flutter/material.dart';

class VisirAppBarButton {
  final Key? key;
  final VisirIconType? icon;
  final Color? foregroundColor;
  final Color? popupBackgroundColor;
  final Color? backgroundColor;
  final Color? hoverColor;
  final String? image;
  final Widget? child;
  final VoidCallback? onTap;

  final bool? isDivider;
  final Widget? popup;
  final double? popupWidth;
  final Clip? clipBehavior;
  final bool? hideShadow;
  final bool? squareForChild;
  final VisirButtonOptions? options;
  final bool? enabled;
  final EdgeInsets? margin;
  final Border? border;
  final bool hightlight;
  final bool? isContainer;
  final Offset? popupForceShiftOffset;
  final PopupMenuLocation? popupLocation;

  VisirAppBarButton({
    this.key,
    this.icon,
    this.foregroundColor,
    this.popupBackgroundColor,
    this.backgroundColor,
    this.hoverColor,
    this.image,
    this.onTap,
    this.popup,
    this.popupWidth,
    this.isDivider,
    this.child,
    this.clipBehavior,
    this.hideShadow,
    this.squareForChild,
    this.popupForceShiftOffset,
    this.popupLocation,
    this.options,
    this.enabled,
    this.margin,
    this.border,
    this.hightlight = false,
    this.isContainer = false,
  });
}

extension VisirAppBarButtonExtension on VisirAppBarButton {
  bool get isMobileView => PlatformX.isMobileView;
  double get iconSize => isMobileView
      ? icon == VisirIconType.close || icon == VisirIconType.check || icon == VisirIconType.arrowLeft
            ? 24
            : 20
      : icon == VisirIconType.close || icon == VisirIconType.check || icon == VisirIconType.arrowLeft
      ? 20
      : 16;
  EdgeInsets get buttonMargin => EdgeInsets.all(2);
  Widget getButton({required BuildContext context, Animation<Color?>? animation}) {
    final e = this;
    final buttonWidth = e.icon == null && e.image == null && e.child != null
        ? e.squareForChild == true
              ? 32.0
              : null
        : 32.0;
    final buttonPadding = e.icon == null && e.image == null && e.child != null
        ? e.squareForChild == true
              ? null
              : EdgeInsets.symmetric(horizontal: 10, vertical: 6)
        : null;

    if (e.isDivider == true) {
      return Center(
        child: Container(
          width: 2,
          height: 16,
          margin: EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(color: context.surfaceVariant),
        ),
      );
    }

    if (e.isContainer == true) {
      return Padding(
        padding: e.margin != null ? EdgeInsets.zero : buttonMargin,
        child: VisirButton(
          key: e.key,
          enabled: e.enabled,
          type: VisirButtonAnimationType.none,
          style: VisirButtonStyle(
            margin: e.margin,
            borderRadius: BorderRadius.circular(6),
            hoverColor: (e.hoverColor ?? context.outlineVariant.withValues(alpha: 0.1)),
            backgroundColor: e.hightlight ? (animation?.value ?? e.backgroundColor) : e.backgroundColor,
            width: buttonWidth,
            padding: buttonPadding,
            cursor: e.onTap == null ? SystemMouseCursors.basic : SystemMouseCursors.click,
            border: e.border,
          ),
          options: e.options,
          onTap: e.onTap,
          child: e.icon != null
              ? VisirIcon(
                  type: e.icon!,
                  size: iconSize,
                  color: e.foregroundColor,
                  isSelected:
                      (e.icon == VisirIconType.arrowLeft ||
                          e.icon == VisirIconType.arrowRight ||
                          e.icon == VisirIconType.arrowDown ||
                          e.icon == VisirIconType.arrowUp)
                      ? null
                      : true,
                )
              : e.image != null
              ? Image.asset(e.image!, width: iconSize, height: iconSize)
              : e.child,
        ),
      );
    }

    if (e.popup != null || e.onTap == null) {
      return Padding(
        padding: e.margin != null ? EdgeInsets.zero : buttonMargin,
        child: PopupMenu(
          key: e.key,
          enabled: e.enabled,
          forcePopup: true,
          location: e.popupLocation ?? PopupMenuLocation.bottom,
          width: e.popupWidth ?? 180,
          type: ContextMenuActionType.tap,
          borderRadius: 6,
          clipBehavior: e.clipBehavior,
          hideShadow: e.hideShadow,
          forceShiftOffset: e.popupForceShiftOffset,
          popup: e.popup,
          backgroundColor: e.popupBackgroundColor,
          style: VisirButtonStyle(
            margin: e.margin,
            borderRadius: BorderRadius.circular(6),
            hoverColor: (e.hoverColor ?? context.outlineVariant.withValues(alpha: 0.1)),
            backgroundColor: e.hightlight ? (animation?.value ?? e.backgroundColor) : e.backgroundColor,
            width: buttonWidth,
            padding: buttonPadding,
            height: 32,
            cursor: SystemMouseCursors.click,
            border: e.border,
          ),
          options: e.options,
          child: e.icon != null
              ? VisirIcon(
                  type: e.icon!,
                  size: iconSize,
                  color: e.foregroundColor,
                  isSelected:
                      (e.icon == VisirIconType.arrowLeft ||
                          e.icon == VisirIconType.arrowRight ||
                          e.icon == VisirIconType.arrowDown ||
                          e.icon == VisirIconType.arrowUp)
                      ? null
                      : true,
                )
              : e.image != null
              ? Image.asset(e.image!, width: iconSize, height: iconSize)
              : e.child ?? SizedBox.shrink(),
        ),
      );
    }

    return Padding(
      padding: e.margin != null ? EdgeInsets.zero : buttonMargin,
      child: VisirButton(
        key: e.key,
        enabled: e.enabled,
        type: VisirButtonAnimationType.scaleAndOpacity,
        style: VisirButtonStyle(
          margin: e.margin,
          borderRadius: BorderRadius.circular(6),
          hoverColor: (e.hoverColor ?? context.outlineVariant.withValues(alpha: 0.1)),
          backgroundColor: e.hightlight ? (animation?.value ?? e.backgroundColor) : e.backgroundColor,
          width: buttonWidth,
          padding: buttonPadding,
          height: 32,
          cursor: e.onTap == null ? SystemMouseCursors.basic : SystemMouseCursors.click,
          border: e.border,
        ),
        options: e.options,
        onTap: e.onTap,
        child: e.icon != null
            ? VisirIcon(
                type: e.icon!,
                size: iconSize,
                color: e.foregroundColor,
                isSelected:
                    (e.icon == VisirIconType.arrowLeft ||
                        e.icon == VisirIconType.arrowRight ||
                        e.icon == VisirIconType.arrowDown ||
                        e.icon == VisirIconType.arrowUp)
                    ? null
                    : true,
              )
            : e.image != null
            ? Image.asset(e.image!, width: iconSize, height: iconSize)
            : e.child,
      ),
    );
  }
}

class VisirAppBar extends StatefulWidget {
  final String title;
  final Color? backgroundColor;
  final List<VisirAppBarButton> leadings;
  final List<VisirAppBarButton> trailings;
  static const double height = 47;

  VisirAppBar({Key? key, required this.title, required this.leadings, required this.trailings, this.backgroundColor}) : super(key: key);

  @override
  _VisirAppBarState createState() => _VisirAppBarState();
}

class _VisirAppBarState extends State<VisirAppBar> with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  bool get isMobileView => PlatformX.isMobileView;

  late AnimationController _controller;
  late Animation<Color?> _animation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500), // 한 번 깜빡이는 시간
      vsync: this,
    );

    if (widget.leadings.any((e) => e.hightlight) || widget.trailings.any((e) => e.hightlight)) {
      _controller.repeat(reverse: true);
    }

    _animation = ColorTween(begin: Utils.mainContext.primary.withValues(alpha: 0.25), end: Utils.mainContext.primary).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: VisirAppBar.height,
          decoration: BoxDecoration(color: widget.backgroundColor),
          child: Row(
            children: [
              SizedBox(width: 6),
              ...widget.leadings.map((e) => e.getButton(context: context, animation: _animation)),
              if (widget.leadings.isEmpty) SizedBox(width: 6) else SizedBox(width: 4),
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(1),
                  child: Text(
                    widget.title,
                    style: context.titleLarge?.textColor(context.outlineVariant).textBold.appFont(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              if (widget.trailings.isEmpty) SizedBox(width: 6),
              ...widget.trailings.map((e) => e.getButton(context: context, animation: _animation)),
              SizedBox(width: 6),
            ],
          ),
        );
      },
    );
  }
}
