import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/presentation/widgets/visir_badge.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/common/presentation/widgets/visir_list_item.dart';
import 'package:Visir/features/common/presentation/widgets/visir_list_section.dart';
import 'package:flutter/material.dart';

import 'admin_menu_item.dart';

class SideBarItem extends StatefulWidget {
  const SideBarItem({
    required this.items,
    required this.index,
    this.onSelected,
    required this.selectedRoute,
    this.depth = 0,
    this.iconColor,
    this.activeIconColor,
    required this.textStyle,
    required this.activeTextStyle,
    required this.backgroundColor,
    required this.activeBackgroundColor,
    required this.hoverBackgroundColor,
    required this.borderColor,
    required this.subtextStyle,
    required this.activeSubtextStyle,
    this.draggedItemNotifier,
    this.draggedTargetNotifier,
  });

  final List<AdminMenuItem> items;
  final int index;
  final void Function(AdminMenuItem item)? onSelected;
  final String selectedRoute;
  final int depth;
  final Color? iconColor;
  final Color? activeIconColor;
  final TextStyle textStyle;
  final TextStyle activeTextStyle;
  final TextStyle subtextStyle;
  final TextStyle activeSubtextStyle;
  final Color backgroundColor;
  final Color activeBackgroundColor;
  final Color hoverBackgroundColor;
  final Color borderColor;
  final ValueNotifier<AdminMenuItem?>? draggedItemNotifier;
  final ValueNotifier<String?>? draggedTargetNotifier;

  @override
  State<SideBarItem> createState() => _SideBarItemState();
}

class _SideBarItemState extends State<SideBarItem> {
  bool get isLast => widget.index == widget.items.length - 1;
  bool arrowUp = false;

  Map<String, bool> _expanded = {};

  @override
  void didUpdateWidget(SideBarItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedRoute != widget.selectedRoute) {
      if (_isSelected(widget.selectedRoute, widget.items[widget.index].children)) {
        _expanded[widget.items[widget.index].route] = true;
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.depth > 0 && isLast) {
      return _buildTiles(context, widget.items[widget.index]);
    }
    return Container(
      decoration: BoxDecoration(
        // border: Border(bottom: BorderSide(color: widget.borderColor)),
      ),
      child: _buildTiles(context, widget.items[widget.index]),
    );
  }

  double textStyleToHeight(TextStyle style) {
    return (style.fontSize! * style.height!);
  }

  Widget _buildTile(AdminMenuItem item, int depth, VoidCallback onTap, bool isExpanded, bool isSelected, bool hasChildren) {
    if (item.isSection == true) {
      return ValueListenableBuilder(
        valueListenable: widget.draggedItemNotifier ?? ValueNotifier<AdminMenuItem?>(null),
        builder: (context, draggedItem, child) {
          return DragTarget<AdminMenuItem>(
            onMove: (details) {
              widget.draggedTargetNotifier?.value = item.sectionId;
            },
            onAcceptWithDetails: (details) async {
              final item = widget.draggedItemNotifier?.value;
              final sectionId = widget.draggedTargetNotifier?.value;
              if (sectionId != null && item != null) item.onDragEnded?.call(sectionId, item);
              widget.draggedTargetNotifier?.value = null;
              widget.draggedItemNotifier?.value = null;
            },
            onLeave: (details) {
              widget.draggedTargetNotifier?.value = null;
            },
            builder: (context, candidateData, rejectedData) {
              return VisirListSection(
                hoverDisabled: draggedItem != null,
                removeTopMargin: widget.index == 0,
                isSelected: false,
                onTap: onTap,
                buttonOptions: item.options,
                titleBuilder: (height, style, verticalPadding, horizontalPadding) {
                  return TextSpan(
                    children: [
                      if (item.color != null)
                        WidgetSpan(
                          child: Padding(
                            padding: EdgeInsets.only(right: horizontalPadding),
                            child: Container(
                              width: 4,
                              height: height,
                              decoration: BoxDecoration(color: item.color, borderRadius: BorderRadius.circular(2)),
                            ),
                          ),
                        ),
                      if (item.icon != null)
                        WidgetSpan(
                          child: Padding(
                            padding: EdgeInsets.only(right: horizontalPadding),
                            child: item.icon!(height),
                          ),
                        ),
                      TextSpan(text: _expanded[item.route] == true ? item.titleOnExpanded ?? item.title ?? item.route : item.title ?? item.route),
                    ],
                  );
                },

                titleTrailingBuilder: !hasChildren
                    ? null
                    : (height, style, verticalPadding, horizontalPadding) {
                        return TextSpan(
                          children: [
                            WidgetSpan(
                              child: VisirIcon(type: isExpanded ? VisirIconType.subtract : VisirIconType.arrowDown, size: height),
                            ),
                          ],
                        );
                      },
              );
            },
          );
        },
      );
    }

    final child = ValueListenableBuilder(
      valueListenable: widget.draggedItemNotifier ?? ValueNotifier<AdminMenuItem?>(null),
      builder: (context, draggedItem, child) {
        return DragTarget<AdminMenuItem>(
          onMove: (details) {
            widget.draggedTargetNotifier?.value = item.sectionId;
          },
          onAcceptWithDetails: (details) async {
            final item = widget.draggedItemNotifier?.value;
            final sectionId = widget.draggedTargetNotifier?.value;
            if (sectionId != null && item != null) item.onDragEnded?.call(sectionId, item);
            widget.draggedTargetNotifier?.value = null;
            widget.draggedItemNotifier?.value = null;
          },
          onLeave: (details) {
            widget.draggedTargetNotifier?.value = null;
          },
          builder: (context, candidateData, rejectedData) {
            return Padding(
              padding: EdgeInsets.only(left: depth * 8.0),
              child: VisirListItem(
                hoverDisabled: draggedItem != null,
                isSelected: item.isToggle != null || hasChildren == true
                    ? false
                    : item.isSelected == null
                    ? isSelected
                    : item.isSelected,
                onTap: onTap,
                buttonOptions: item.options,
                titleLeadingBuilder: item.icon != null || item.color != null
                    ? (height, style, verticalPadding, horizontalPadding) {
                        return TextSpan(
                          children: [
                            if (item.color != null)
                              WidgetSpan(
                                child: Container(
                                  width: 4,
                                  height: height,
                                  decoration: BoxDecoration(color: item.color, borderRadius: BorderRadius.circular(2)),
                                ),
                              ),

                            if (item.icon != null) WidgetSpan(child: item.icon!(height)),
                          ],
                        );
                      }
                    : null,
                titleBuilder: (height, style, verticalPadding, horizontalPadding) {
                  style = (item.subtext != true ? context.titleLarge : context.titleSmall)!.copyWith(color: depth > 0 ? context.inverseSurface : null);
                  height = style.fontSize! * style.height!;
                  return TextSpan(
                    children: [
                      TextSpan(
                        text: _expanded[item.route] == true ? item.titleOnExpanded ?? item.title ?? item.route : item.title ?? item.route,
                        style: TextStyle(fontWeight: item.titleBold == true ? FontWeight.bold : null, color: item.titleColor),
                      ),
                    ],
                  );
                },

                titleTrailingBuilder: !hasChildren
                    ? item.badge != null && item.badge! != 0
                          ? (height, style, verticalPadding, horizontalPadding) {
                              return TextSpan(
                                children: [
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: item.badge! < 0
                                        ? CircleAvatar(radius: 3, backgroundColor: context.primary)
                                        : VisirBadge(style: style!, text: item.badge.toString(), horizontalPadding: horizontalPadding),
                                  ),
                                ],
                              );
                            }
                          : item.isToggle != null
                          ? (height, style, verticalPadding, horizontalPadding) {
                              return TextSpan(
                                children: [
                                  WidgetSpan(
                                    child: VisirIcon(
                                      type: item.isToggle == true ? VisirIconType.checkWithCircle : VisirIconType.emptyCircle,
                                      size: height,
                                      isSelected: true,
                                      color: item.isToggle == true ? context.secondary : context.inverseSurface,
                                    ),
                                  ),
                                ],
                              );
                            }
                          : null
                    : (height, style, verticalPadding, horizontalPadding) {
                        return TextSpan(
                          children: [
                            WidgetSpan(
                              child: VisirIcon(type: isExpanded ? VisirIconType.subtract : VisirIconType.arrowDown, size: height),
                            ),
                          ],
                        );
                      },
              ),
            );
          },
        );
      },
    );

    if (item.isDraggable == true) {
      if (PlatformX.isDesktopView) {
        return Draggable(
          data: item,
          onDragStarted: () {
            widget.draggedItemNotifier?.value = item;
            widget.draggedTargetNotifier?.value = item.sectionId;
          },
          onDragEnd: (details) {
            widget.draggedItemNotifier?.value = null;
            widget.draggedTargetNotifier?.value = null;
          },
          feedback: Container(
            width: 200,
            padding: EdgeInsets.only(top: 6),
            decoration: BoxDecoration(color: context.surface, boxShadow: PopupMenu.popupShadow, borderRadius: BorderRadius.circular(6)),
            child: child,
          ),
          child: child,
        );
      } else {
        return LongPressDraggable(
          data: item,
          onDragStarted: () {
            widget.draggedItemNotifier?.value = item;
            widget.draggedTargetNotifier?.value = item.sectionId;
          },
          onDragEnd: (details) {
            widget.draggedItemNotifier?.value = null;
            widget.draggedTargetNotifier?.value = null;
          },
          feedback: Container(
            width: 200,
            padding: EdgeInsets.only(top: 6),
            decoration: BoxDecoration(color: context.surface, boxShadow: PopupMenu.popupShadow, borderRadius: BorderRadius.circular(6)),
            child: child,
          ),
          child: child,
        );
      }
    }

    return child;
  }

  Widget _buildTiles(BuildContext context, AdminMenuItem item) {
    bool selected = _isSelected(widget.selectedRoute, [item]);

    int index = 0;
    final childrenTiles = item.children.map((child) {
      return SideBarItem(
        items: item.children,
        index: index++,
        onSelected: widget.onSelected,
        selectedRoute: widget.selectedRoute,
        depth: item.isSection == true ? widget.depth : widget.depth + 1,
        iconColor: widget.iconColor,
        activeIconColor: widget.activeIconColor,
        textStyle: widget.textStyle,
        activeTextStyle: widget.activeTextStyle,
        backgroundColor: widget.backgroundColor,
        activeBackgroundColor: widget.activeBackgroundColor,
        hoverBackgroundColor: widget.hoverBackgroundColor,
        borderColor: widget.borderColor,
        subtextStyle: widget.subtextStyle,
        activeSubtextStyle: widget.activeSubtextStyle,
        draggedTargetNotifier: widget.draggedTargetNotifier,
        draggedItemNotifier: widget.draggedItemNotifier,
      );
    }).toList();

    Widget child = item.children.isEmpty
        ? _buildTile(item, widget.depth, () => widget.onSelected?.call(item), _expanded[item.route] ?? item.isSection == true, selected, false)
        : AnimatedCrossFade(
            duration: const Duration(milliseconds: 160),
            crossFadeState: _expanded[item.route] ?? item.isSection == true ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: _buildTile(
              item,
              widget.depth,
              () {
                _expanded[item.route] = true;
                setState(() {});
              },
              _expanded[item.route] ?? item.isSection == true,
              false,
              true,
            ),
            secondChild: Column(
              children: [
                _buildTile(
                  item,
                  widget.depth,
                  () {
                    _expanded[item.route] = false;
                    setState(() {});
                  },
                  _expanded[item.route] ?? item.isSection == true,
                  true,
                  true,
                ),
                ...childrenTiles,
              ],
            ),
          );

    return ValueListenableBuilder(
      valueListenable: widget.draggedTargetNotifier ?? ValueNotifier<String?>(null),
      builder: (context, targetSectionId, _) {
        bool isSelected = targetSectionId != null && item.sectionId == targetSectionId && item.isSection == true;
        return Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  margin: EdgeInsets.only(left: widget.depth * 8.0, top: widget.index == 0 ? 0 : 16),
                  decoration: BoxDecoration(
                    color: isSelected ? context.outlineVariant.withValues(alpha: 0.12) : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
            child,
          ],
        );
      },
    );
  }

  bool _isSelected(String route, List<AdminMenuItem> items) {
    for (final item in items) {
      if (item.route == route) {
        return true;
      }
      if (item.children.isNotEmpty) {
        return _isSelected(route, item.children);
      }
    }
    return false;
  }
}
