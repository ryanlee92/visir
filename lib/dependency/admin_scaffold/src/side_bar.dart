import 'package:Visir/config/providers.dart';
import 'package:Visir/features/common/presentation/widgets/keyboard_shortcut.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

import 'admin_menu_item.dart';
import 'side_bar_item.dart';

class SideBar extends ConsumerStatefulWidget {
  const SideBar({
    Key? key,
    required this.items,
    required this.selectedRoute,
    this.onSelected,
    this.width = 240.0,
    this.iconColor,
    this.activeIconColor,
    this.textStyle = const TextStyle(color: Color(0xFF337ab7), fontSize: 12),
    this.activeTextStyle = const TextStyle(color: Color(0xFF337ab7), fontSize: 12),
    this.subtextStyle = const TextStyle(color: Color(0xFF337ab7), fontSize: 10),
    this.activeSubtextStyle = const TextStyle(color: Color(0xFF337ab7), fontSize: 10),
    this.backgroundColor = const Color(0xFFEEEEEE),
    required this.activeBackgroundColor,
    required this.hoverBackgroundColor,
    this.borderColor = const Color(0xFFE7E7E7),
    this.scrollController,
    this.header,
    this.footer,
    this.drawerCallback,
    required this.tabType,
  }) : super(key: key);

  final List<AdminMenuItem> items;
  final String selectedRoute;
  final void Function(AdminMenuItem item)? onSelected;
  final double width;
  final Color? iconColor;
  final Color? activeIconColor;
  final TextStyle textStyle;
  final TextStyle activeTextStyle;
  final Color backgroundColor;
  final Color activeBackgroundColor;
  final Color hoverBackgroundColor;
  final Color borderColor;
  final ScrollController? scrollController;
  final Widget? header;
  final Widget? footer;
  final TextStyle subtextStyle;
  final TextStyle activeSubtextStyle;
  final Function(bool isOpen)? drawerCallback;
  final TabType tabType;

  @override
  SideBarState createState() => SideBarState();
}

class SideBarState extends ConsumerState<SideBar> with SingleTickerProviderStateMixin {
  late double _sideBarWidth;
  String? selectedRoute;
  String? hoverRoute;

  ValueNotifier<AdminMenuItem?> draggedItemNotifier = ValueNotifier<AdminMenuItem?>(null);
  ValueNotifier<String?> draggedTargetNotifier = ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();
    _sideBarWidth = widget.width;
    selectedRoute = widget.selectedRoute;
  }

  @override
  void didUpdateWidget(SideBar oldWidget) {
    if (oldWidget.selectedRoute != widget.selectedRoute) {
      selectedRoute = widget.selectedRoute;
      setState(() {});
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    draggedItemNotifier.dispose();
    draggedTargetNotifier.dispose();
    super.dispose();
  }

  bool _onKeyDown(KeyEvent event) {
    final logicalKeyPressed = ServicesBinding.instance.keyboard.logicalKeysPressed.where((e) => e != LogicalKeyboardKey.escape).toList();
    if (logicalKeyPressed.length == 2) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown && logicalKeyPressed.isAltPressed) {
        final expandedItems = expandAll(widget.items);
        final index = expandedItems.indexWhere((e) => e.route == selectedRoute);
        AdminMenuItem? nextItem;
        if (index < expandedItems.length - 1) {
          nextItem = expandedItems[index + 1];
        }
        if (nextItem != null) {
          selectRoute(nextItem);
          return true;
        }
      }

      if (event.logicalKey == LogicalKeyboardKey.arrowUp && logicalKeyPressed.isAltPressed) {
        final expandedItems = expandAll(widget.items);
        final index = expandedItems.indexWhere((e) => e.route == selectedRoute);
        AdminMenuItem? prevItem;
        if (index > 0) {
          prevItem = expandedItems[index - 1];
        }

        if (prevItem != null) {
          selectRoute(prevItem);
          return true;
        }
      }
    }
    return false;
  }

  List<AdminMenuItem> expandAll(List<AdminMenuItem> items) {
    List<AdminMenuItem> newItems = [];
    for (var item in items) {
      if (item.children.isNotEmpty) {
        newItems.addAll(expandAll(item.children));
      } else {
        newItems.add(item);
      }
    }

    return newItems;
  }

  bool _onKeyRepeat(KeyEvent event) {
    final logicalKeyPressed = ServicesBinding.instance.keyboard.logicalKeysPressed.where((e) => e != LogicalKeyboardKey.escape).toList();
    if (logicalKeyPressed.length == 2) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown && logicalKeyPressed.isAltPressed) {
        final expandedItems = expandAll(widget.items);
        final index = expandedItems.indexWhere((e) => e.route == selectedRoute);
        AdminMenuItem? nextItem;
        if (index < expandedItems.length - 1) {
          nextItem = expandedItems[index + 1];
        }
        if (nextItem != null) {
          selectRoute(nextItem);
          return true;
        }
      }

      if (event.logicalKey == LogicalKeyboardKey.arrowUp && logicalKeyPressed.isAltPressed) {
        final expandedItems = expandAll(widget.items);
        final index = expandedItems.indexWhere((e) => e.route == selectedRoute);
        AdminMenuItem? prevItem;
        if (index > 0) {
          prevItem = expandedItems[index - 1];
        }

        if (prevItem != null) {
          selectRoute(prevItem);
          return true;
        }
      }
    }
    return false;
  }

  void selectRoute(AdminMenuItem route) {
    widget.onSelected?.call(route);
    selectedRoute = route.route;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: KeyboardShortcut(
        targetTab: widget.tabType,
        onKeyDown: _onKeyDown,
        onKeyRepeat: _onKeyRepeat,
        child: Container(
          width: _sideBarWidth,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.header != null) widget.header!,
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: SuperListView.builder(
                    padding: scrollViewBottomPadding,
                    itemCount: widget.items.length,
                    controller: widget.scrollController ?? ScrollController(),
                    itemBuilder: (BuildContext context, int index) {
                      return SideBarItem(
                        items: widget.items,
                        index: index,
                        onSelected: selectRoute,
                        selectedRoute: selectedRoute!,
                        draggedItemNotifier: draggedItemNotifier,
                        depth: 0,
                        iconColor: widget.iconColor,
                        activeIconColor: widget.activeIconColor,
                        textStyle: widget.textStyle,
                        activeTextStyle: widget.activeTextStyle,
                        backgroundColor: widget.backgroundColor,
                        hoverBackgroundColor: widget.hoverBackgroundColor,
                        activeBackgroundColor: widget.activeBackgroundColor,
                        borderColor: widget.borderColor,
                        subtextStyle: widget.subtextStyle,
                        draggedTargetNotifier: draggedTargetNotifier,
                        activeSubtextStyle: widget.activeSubtextStyle,
                      );
                    },
                  ),
                ),
              ),
              if (widget.footer != null) widget.footer!,
            ],
          ),
        ),
      ),
    );
  }
}
