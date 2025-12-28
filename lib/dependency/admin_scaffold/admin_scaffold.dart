import 'package:Visir/config/providers.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/desktop_scaffold.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_resizable_container/flutter_resizable_container.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/side_bar.dart';

export 'src/admin_menu_item.dart';
export 'src/side_bar.dart';

class AdminScaffold extends ConsumerStatefulWidget {
  const AdminScaffold({
    Key? key,
    this.tabType,
    this.appBar,
    this.backgroundColor,
    this.onSidebarResized,
    required this.sideBar,
    required this.body,
    this.initialSideBarWidth = 200,
    this.minSideBarWidth = 120,
    this.maxSideBarWidth = 200,
  }) : super(key: key);

  final TabType? tabType;
  final AppBar? appBar;
  final SideBar sideBar;
  final Widget body;
  final Color? backgroundColor;
  final double initialSideBarWidth;
  final double minSideBarWidth;
  final double maxSideBarWidth;
  final void Function(double sidebarWidth)? onSidebarResized;

  @override
  AdminScaffoldState createState() => AdminScaffoldState();
}

class AdminScaffoldState extends ConsumerState<AdminScaffold> {
  double _screenWidth = 0;

  late ResizableController resizableController;

  bool get isDrawerOpen => _drawerKey.currentState?.widget.isDrawerOpen ?? false;
  bool get breakpoint => Utils.mainContext.screenSize.width < 1200;

  @override
  void initState() {
    super.initState();

    resizableController = ResizableController();
    resizableController.addListener(onResize);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _screenWidth = MediaQuery.of(context).size.width;
      setState(() {});
    });
  }

  void onResize() {
    widget.onSidebarResized?.call(resizableController.pixels[0]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mediaQuery = MediaQuery.of(context);
    if (_screenWidth == mediaQuery.size.width) {
      return;
    }

    setState(() {
      _screenWidth = mediaQuery.size.width;
    });
  }

  @override
  void dispose() {
    resizableController.removeListener(onResize);
    resizableController.dispose();
    super.dispose();
  }

  void toggleSidebar() {
    if (!isDrawerOpen) {
      _drawerKey.currentState?.open();
    } else {
      _drawerKey.currentState?.close();
    }
  }

  final GlobalKey<DrawerControllerState> _drawerKey = GlobalKey<DrawerControllerState>();

  void openSidebar() {
    _drawerKey.currentState?.open();
  }

  void closeSidebar() {
    _drawerKey.currentState?.close();
  }

  @override
  Widget build(BuildContext context) {
    final showSidebar = ref.watch(desktopShowSidebarProvider);
    return LayoutBuilder(
      builder: (context, constraints) {
        final resizerWidget = ref.read(resizableClosableDrawerProvider(widget.tabType!));
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          if (breakpoint && resizerWidget != null && widget.tabType != null) {
            ref.read(resizableClosableDrawerProvider(widget.tabType!).notifier).update();
          } else if (PlatformX.isDesktopView && widget.tabType != null && resizerWidget == null && !breakpoint) {
            ref.read(resizableClosableDrawerProvider(widget.tabType!).notifier).update();
          }
        });

        return PlatformX.isMobileView || breakpoint || !showSidebar
            ? Stack(
                children: [
                  Positioned.fill(child: widget.body),
                  Positioned.fill(
                    child: DrawerController(
                      key: _drawerKey,
                      scrimColor: Colors.transparent,
                      alignment: DrawerAlignment.start,
                      child: Drawer(
                        shadowColor: Colors.transparent,
                        elevation: 0,
                        backgroundColor: Colors.transparent,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: context.padding.bottom),
                          child: Container(
                            margin: EdgeInsets.all(DesktopScaffold.cardPadding),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(PlatformX.isMobileView ? 20 : DesktopScaffold.cardRadius),
                              color: context.surface,
                              boxShadow: PopupMenu.popupShadow,
                            ),
                            child: widget.sideBar,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : widget.body;
      },
    );
  }
}
