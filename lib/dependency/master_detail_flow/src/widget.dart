import 'dart:async';

import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/master_detail_flow/src/enums.dart';
import 'package:Visir/dependency/master_detail_flow/src/flow_settings.dart';
import 'package:Visir/dependency/master_detail_flow/src/master_item.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/desktop_scaffold.dart';
import 'package:Visir/features/common/presentation/widgets/platform_scroll_physics.dart';
import 'package:Visir/features/common/presentation/widgets/wave_refresh_footer.dart';
import 'package:Visir/features/common/presentation/widgets/wave_refresh_header.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:animations/animations.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/cupertino.dart' hide Focus;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide Focus;
import 'package:flutter_resizable_container/flutter_resizable_container.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

/// A widgets that builds an adaptive M3 master <-> details flow. To start just
/// create a scaffold with it't only child being the [MasterDetailsFlow].
class MasterDetailsFlow extends ConsumerStatefulWidget {
  /// Creates the flow
  const MasterDetailsFlow({
    required this.items,
    this.leadings,
    this.actions,
    this.autoImplyLeading = true,
    this.breakpoint = 1200,
    this.initialPage,
    this.initialFocus = Focus.details,
    this.initialMasterPanelWidth,
    this.initialDetailPanelWidth,
    this.detailsPanelCornersRadius = 12.0,
    this.lateralListTileTheme,

    this.nothingSelectedWidget,
    this.lateralDetailsAppBar = DetailsAppBarSize.medium,
    this.pageDetailsAppBar = DetailsAppBarSize.large,
    this.masterAppBar = DetailsAppBarSize.small,
    this.transitionAnimationDuration = const Duration(milliseconds: 0),
    this.topPadding,
    this.scrollPhysics,
    this.onRefresh,
    this.onLoading,
    this.onTwoLevel,
    this.refreshController,
    this.builder,
    this.scrollDirection,
    this.reverse,
    required this.scrollController,
    this.listController,
    this.primary,
    this.cacheExtent,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.appbarSize,
    this.detailBackgroundColor,
    this.masterBackgroundColor,
    this.showAppBarDivider,
    this.isDetailExpanded = true,
    this.bottom,
    this.onDragDone,
    this.separatorColor,
    this.masterLoadingNotifier,
    this.masterSuccessNotifier,
    this.debugKey,
    this.minMasterResizableWidth,
    this.minDetailResizableWidth,
    this.disableOpenDetailsOnTap,
    this.enableMasterSelection,
    this.enableDetailsSelection,
    this.dividerColor,
    this.refocusOnItemDeleted,
    this.beforeOpenDetails,
    this.afterOpenDetails,
    this.masterShowLoadingNotifier,
    this.isResizable,
    required this.onTargetResized,
    this.enableDropTarget,
    this.bodyWrapper,
    this.onDetailsClosed,
    this.tabType,
    this.maxMasterResizableWidth,
    this.customVerticalPadding,
    super.key,
  });

  final Widget Function(Widget child)? bodyWrapper;

  final void Function(String id)? beforeOpenDetails;
  final void Function(String id)? afterOpenDetails;
  final VoidCallback? onDetailsClosed;
  final bool? refocusOnItemDeleted;
  final bool? enableMasterSelection;
  final bool? enableDetailsSelection;

  final Color? masterBackgroundColor;
  final Color? detailBackgroundColor;
  final FutureOr<void> Function()? onRefresh;
  final FutureOr<bool> Function()? onLoading;
  final FutureOr<void> Function(bool result)? onTwoLevel;
  final RefreshController? refreshController;
  final RefresherBuilder? builder;
  final Axis? scrollDirection;
  final bool? reverse;
  final ScrollController scrollController;
  final ListController? listController;
  final bool? primary;
  final double? cacheExtent;
  final int? semanticChildCount;
  final DragStartBehavior? dragStartBehavior;
  final bool? enableDropTarget;
  final TabType? tabType;

  final bool? showAppBarDivider;
  final Color? dividerColor;
  final ValueNotifier<bool?>? masterLoadingNotifier;
  final ValueNotifier<bool?>? masterSuccessNotifier;
  final ValueNotifier<bool?>? masterShowLoadingNotifier;

  final ScrollPhysics? scrollPhysics;
  final double? appbarSize;

  /// A widget to display before the toolbar's [title].
  ///
  /// Typically the [leading] widget is an [Icon] or an [IconButton].
  final List<Widget>? leadings;

  /// A list of Widgets to display in a row after the [title] widget.
  ///
  /// Typically these widgets are [IconButton]s representing common operations.
  /// For less common operations, consider using a [PopupMenuButton] as the
  /// last action.
  final List<Widget>? actions;

  final double? topPadding;

  /// Controls whether we should try to imply the leading widget if null.
  ///
  /// If true and [leading] is null, automatically try to deduce what the leading
  /// widget should be. If false and [leading] is null, leading space is given to [title].
  /// If leading widget is not null, this parameter has no effect.
  final bool autoImplyLeading;

  /// If the screen width is larger than breakpoint it moves to lateral view,
  /// otherwise is in page mode.
  ///
  /// Defaults to 700.
  final int breakpoint;

  /// The width of the lateral panel that hold the tiles.
  ///
  /// Defaults to 300.0
  final double? initialMasterPanelWidth;
  final double? initialDetailPanelWidth;
  final double? minMasterResizableWidth;
  final double? minDetailResizableWidth;
  final double? maxMasterResizableWidth;

  /// The corners radius of the details panel
  ///
  /// Defaults to 12
  final double detailsPanelCornersRadius;

  /// The theme used by the selectable tiles on the lateral panel
  final ListTileThemeData? lateralListTileTheme;

  /// The option title to be showed on the master app bar.

  /// A widget to be showed in case there is no master selected. If not provided
  /// there will be used a simple text mentioning that no item is selected.
  final Widget? nothingSelectedWidget;

  /// The required list of items.
  final List<MasterItemBase> items;

  /// An optional integer to specify if the masterFlow should start with a
  /// selected page.
  final int? initialPage;

  /// Sets the initial focus on either the master or details page.
  ///
  /// Defaults to [Focus.details]
  ///
  /// See:
  ///   * [Focus]
  final Focus initialFocus;

  /// Selects the app bar style used when details page is in lateral view.
  ///
  /// See:
  ///   * [DetailsAppBarSize]
  final DetailsAppBarSize lateralDetailsAppBar;

  /// Selects the app bar style used when details page is in page view.
  ///
  /// See:
  ///   * [DetailsAppBarSize]
  final DetailsAppBarSize pageDetailsAppBar;

  /// Selects the app bar style used when the master list is in page view.
  ///
  /// See:
  ///   * [DetailsAppBarSize]
  final DetailsAppBarSize masterAppBar;

  /// The default transition animation duration
  final Duration transitionAnimationDuration;

  final bool? isDetailExpanded;
  final Widget? bottom;
  final void Function(DropDoneDetails)? onDragDone;
  final Color? separatorColor;
  final String? debugKey;
  final void Function(double width) onTargetResized;
  final bool? disableOpenDetailsOnTap;
  final bool? isResizable;
  final double? customVerticalPadding;

  @override
  ConsumerState<MasterDetailsFlow> createState() => MasterDetailsFlowState();
}

class MasterDetailsFlowState extends ConsumerState<MasterDetailsFlow> {
  Focus focus = Focus.master;
  MasterItem? selectedItem;
  int? currentIndex;

  late RefreshController refreshController;

  FocusNode? masterFocusNode;
  FocusNode? detailsFocusNode;

  GlobalKey smartRefresherKey = GlobalKey();

  bool get isDetailOpened => focus == Focus.details;

  @override
  void initState() {
    super.initState();
    refreshController = widget.refreshController ?? RefreshController(initialRefresh: false);

    if (widget.initialPage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        openDetails(id: widget.items[widget.initialPage!].id);
      });
    }

    if (widget.enableMasterSelection == true && widget.enableDetailsSelection == true) {
      masterFocusNode = FocusNode();
      detailsFocusNode = FocusNode();
      masterFocusNode?.addListener(masterFocusListener);
      detailsFocusNode?.addListener(detailsFocusListener);
    }

    widget.masterLoadingNotifier?.addListener(checkLoadingBarListener);
    widget.masterShowLoadingNotifier?.addListener(checkLoadingBarListener);
  }

  bool enableRefresh = true;
  void checkLoadingBarListener() {
    if (widget.masterLoadingNotifier?.value == true && widget.masterShowLoadingNotifier?.value == true) {
      enableRefresh = false;
    } else {
      enableRefresh = true;
    }

    setState(() {});
  }

  void masterFocusListener() {
    if (masterFocusNode?.hasFocus == true) {
      detailsFocusNode?.unfocus();
    }
  }

  void detailsFocusListener() {
    if (detailsFocusNode?.hasFocus == true) {
      masterFocusNode?.unfocus();
    }
  }

  @override
  void didUpdateWidget(MasterDetailsFlow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (PlatformX.isDesktopView) {
      if (selectedItem != null && widget.items.where((e) => e.id == selectedItem?.id).isEmpty && widget.refocusOnItemDeleted == true) {
        if (currentIndex != null && widget.items.length > currentIndex!) {
          selectedItem = widget.items[currentIndex!] as MasterItem?;
          focus = Focus.details;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.beforeOpenDetails?.call(selectedItem!.id);
            widget.afterOpenDetails?.call(selectedItem!.id);
          });
        }
      }
    } else {
      if (selectedItem != null && widget.items.where((e) => e.id == selectedItem?.id).isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          closeDetails();
        });
      }
    }
  }

  @override
  void dispose() {
    refreshController.dispose();
    masterFocusNode?.removeListener(masterFocusListener);
    detailsFocusNode?.removeListener(detailsFocusListener);
    widget.masterLoadingNotifier?.removeListener(checkLoadingBarListener);
    widget.masterShowLoadingNotifier?.removeListener(checkLoadingBarListener);
    super.dispose();
  }

  String? selectNext({bool? doNotOpenDetails}) {
    final index = currentIndex ?? 0;
    if (index == widget.items.length - 1) return null;
    if (widget.items.length <= index + 1) return null;

    selectedItem = widget.items[index + 1] as MasterItem;
    if (doNotOpenDetails != true) {
      openDetails(id: selectedItem!.id);
    }

    int? minVisible = widget.listController?.visibleRange?.$1;
    int? maxVisible = widget.listController?.visibleRange?.$2;
    if (minVisible == null || maxVisible == null) return null;
    if (index + 1 <= minVisible || index + 1 >= maxVisible) {
      widget.listController?.jumpToItem(
        index: index + 1,
        scrollController: widget.scrollController,
        alignment: 1,
        // duration: (distance) => Duration(milliseconds: 200),
        // curve: (distance) => Curves.easeInOut,
      );
    }

    if (index + 2 == widget.items.length) {
      refreshController.requestLoading();
    }

    return selectedItem?.id;
  }

  void refocus() {
    final index = currentIndex;
    if (index == null || widget.items.length <= index) return;
    selectedItem = widget.items[index] as MasterItem;
    openDetails(id: selectedItem!.id);
  }

  String? selectPrev({bool? doNotOpenDetails}) {
    final index = currentIndex;
    if (index == 0) return null;
    if (index == null || 0 > index - 1) return null;
    selectedItem = widget.items[index - 1] as MasterItem;
    if (doNotOpenDetails != true) {
      openDetails(id: selectedItem!.id);
    }

    int? minVisible = widget.listController?.visibleRange?.$1;
    int? maxVisible = widget.listController?.visibleRange?.$2;
    if (minVisible == null || maxVisible == null) return null;
    if (index - 1 <= minVisible || index - 1 >= maxVisible) {
      widget.listController?.jumpToItem(
        index: index - 1,
        scrollController: widget.scrollController,
        alignment: 0,
        // duration: (distance) => Duration(milliseconds: 200),
        // curve: (distance) => Curves.easeInOut,
      );
    }

    return selectedItem?.id;
  }

  String? prevItemId(String? id) {
    final index = widget.items.indexWhere((e) => e.id == id);
    if (index == 0) return null;
    if (index < 0 || 0 > index - 1) return null;

    if (widget.listController?.isAttached == true) {
      int? minVisible = widget.listController?.visibleRange?.$1;
      int? maxVisible = widget.listController?.visibleRange?.$2;
      if (minVisible != null && maxVisible != null) {
        if (index - 1 <= minVisible || index - 1 >= maxVisible) {
          widget.listController?.jumpToItem(
            index: index - 1,
            scrollController: widget.scrollController,
            alignment: 0,
            // duration: (distance) => Duration(milliseconds: 200),
            // curve: (distance) => Curves.easeInOut,
          );
        }
      }
    }

    return (widget.items[index - 1] as MasterItem).id;
  }

  String? nextItemId(String? id) {
    final index = widget.items.indexWhere((e) => e.id == id);
    if (index == widget.items.length - 1) return null;
    if (index < 0 || widget.items.length <= index + 1) return null;

    if (widget.listController?.isAttached == true) {
      int? minVisible = widget.listController?.visibleRange?.$1;
      int? maxVisible = widget.listController?.visibleRange?.$2;
      if (minVisible != null && maxVisible != null) {
        if (index + 1 <= minVisible || index + 1 >= maxVisible) {
          widget.listController?.jumpToItem(
            index: index + 1,
            scrollController: widget.scrollController,
            alignment: 1,
            // duration: (distance) => Duration(milliseconds: 200),
            // curve: (distance) => Curves.easeInOut,
          );
        }
      }
    }

    if (index + 2 == widget.items.length) {
      refreshController.requestLoading();
    }

    return (widget.items[index + 1] as MasterItem).id;
  }

  MasterDetailsFlowSettings? detailWidget(BuildContext buildContext, String? id, bool large, bool isSmall) {
    final detail = (widget.items.where((e) => e.id == id).firstOrNull as MasterItem?)?.detailsBuilder == null
        ? null
        : Container(
            key: ValueKey(id),
            color: widget.detailBackgroundColor ?? Colors.transparent,
            child: (widget.items.where((e) => e.id == id).first as MasterItem).detailsBuilder!(buildContext, isSmall, () {
              if (PlatformX.isMobileView) {
                selectedItem = null;
                currentIndex = null;
                focus = Focus.master;
              }
            }),
          );

    if (detail == null) return null;

    return MasterDetailsFlowSettings(
      key: ValueKey<Focus>(focus),
      large: large,
      appBarSize: widget.pageDetailsAppBar,
      selfPage: true,
      goBack: closeDetails,
      child: widget.enableDetailsSelection == true && PlatformX.isDesktopView
          ? GestureDetector(
              onTap: () {
                masterFocusNode?.unfocus();
                detailsFocusNode?.unfocus();
              },
              child: SelectionArea(
                focusNode: detailsFocusNode,
                child: DefaultSelectionStyle(mouseCursor: SystemMouseCursors.basic, child: detail),
              ),
            )
          : detail,
    );
  }

  double get appBarHeight => 47;

  bool openDetails({required String id, bool? animateToDetail, bool? forceOpen}) {
    widget.beforeOpenDetails?.call(id);

    if (!mounted) return false;

    bool needToClose = PlatformX.isMobileView && selectedItem != null;

    bool _animateToDetail = animateToDetail ?? false;
    final val = widget.items.where((e) => e.id == id).firstOrNull;

    if (val == null) return false;

    final prevSelectedItemId = selectedItem?.id;

    selectedItem = val as MasterItem;
    currentIndex = widget.items.indexOf(selectedItem!);
    focus = Focus.details;

    if (!PlatformX.isDesktopView) {
      final item = val;
      if (item.detailsBuilder != null) {
        if (forceOpen != true) {
          if (prevSelectedItemId == selectedItem!.id) return false;
        }

        final tabNavigator = Navigator.of(Utils.mobileTabContexts[tabNotifier.value] ?? context);
        final currentNavigator = Navigator.of(context);
        final navigator = tabNavigator == currentNavigator ? tabNavigator : currentNavigator;

        if (needToClose) {
          navigator.popUntil((route) => route.isFirst);
          navigator.push(
            CupertinoPageRoute(
              builder: (routeContext) => detailWidget(routeContext, id, false, true)!,
              settings: RouteSettings(name: id),
            ),
          );
        } else {
          navigator.push(
            CupertinoPageRoute(
              builder: (routeContext) => detailWidget(routeContext, id, false, true)!,
              settings: RouteSettings(name: id),
            ),
          );
        }
      }
    } else {
      setState(() {});
      if (currentIndex != null && _animateToDetail) {
        widget.listController?.animateToItem(
          index: currentIndex!,
          scrollController: widget.scrollController,
          alignment: 0.95,
          duration: (distance) => Duration(milliseconds: 200),
          curve: (distance) => Curves.easeInOut,
        );
      }
    }
    widget.afterOpenDetails?.call(id);
    return true;
  }

  Widget? getDetails({required String id}) {
    widget.beforeOpenDetails?.call(id);
    if (!mounted) return null;
    final val = widget.items.where((e) => e.id == id).firstOrNull;
    if (val == null) return null;
    selectedItem = val as MasterItem;
    currentIndex = widget.items.indexOf(selectedItem!);
    focus = Focus.details;
    return detailWidget(context, id, false, true);
  }

  Future<void> closeDetails({bool? toFirst}) async {
    selectedItem = null;
    currentIndex = null;
    focus = Focus.master;

    if (!PlatformX.isDesktopView) {
      final tabNavigator = Navigator.of(Utils.mobileTabContexts[tabNotifier.value] ?? context);
      final currentNavigator = Navigator.of(context);
      final navigator = tabNavigator == currentNavigator ? tabNavigator : currentNavigator;
      if (toFirst == true) {
        navigator.popUntil((route) => route.isFirst);
      } else {
        await navigator.maybePop();
      }
    } else {
      setState(() {});
    }

    widget.onDetailsClosed?.call();
  }

  Widget? desktopSelectedItemArea(bool large) {
    final emptyWidget = Container(
      color: context.background,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 24),
              constraints: BoxConstraints(maxWidth: 300, maxHeight: 300),
              child: Image.asset('assets/illust/noselection.png', fit: BoxFit.contain),
            ),
            SizedBox(height: 12),
            Text(context.tr.no_selection, style: context.headlineMedium?.textColor(context.inversePrimary)),
          ],
        ),
      ),
    );
    if (detailWidget(context, selectedItem?.id, large, false) == null) return null;

    return AnimatedSwitcher(
      key: ValueKey<MasterItem?>(selectedItem),
      duration: widget.transitionAnimationDuration,
      transitionBuilder: (Widget child, Animation<double> animation) =>
          const FadeUpwardsPageTransitionsBuilder().buildTransitions<void>(null, null, animation, null, child),
      child: Material(
        elevation: 0,
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        child: selectedItem != null ? (detailWidget(context, selectedItem?.id, large, false) ?? emptyWidget) : emptyWidget,
      ),
    );
  }

  PlatformScrollController platformScrollController = PlatformScrollController(enableTwoFingerDrag: true);

  Widget masterWidget(bool large) {
    Widget child = CustomScrollView(
      controller: widget.scrollController,
      physics: PlatformScrollPhysics(parent: widget.scrollPhysics, controller: platformScrollController),
      reverse: widget.reverse ?? false,
      slivers: <Widget>[
        if (widget.reverse == true) SliverToBoxAdapter(child: SizedBox(height: widget.customVerticalPadding ?? scrollViewBottomPadding.bottom)),
        SuperSliverList(
          listController: widget.listController,
          delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
            final MasterItemBase itemBase = widget.items[index];
            if (itemBase is Widget) {
              return itemBase as Widget;
            }
            final MasterItem item = itemBase as MasterItem;

            return item.customWidget != null
                ? GestureDetector(
                    key: GlobalObjectKey(item.id),
                    onTap:
                        item.onTap ??
                        () {
                          if (!(widget.disableOpenDetailsOnTap ?? false)) {
                            if (item.id == selectedItem?.id) return;
                            openDetails(id: item.id);
                          }
                        },
                    child: item.customWidget!.call(selectedItem?.id == item.id && large),
                  )
                : listTileBuilder(item, index, page: false, large: large);
          }, childCount: widget.items.length),
        ),
        if (widget.reverse != true) SliverToBoxAdapter(child: SizedBox(height: widget.customVerticalPadding ?? scrollViewBottomPadding.bottom)),
      ],
    );

    final bodyWrapper = (Widget child) => widget.bodyWrapper?.call(child) ?? child;

    Widget master = Column(
      key: ValueKey(isDetailOpened),
      children: [
        _appBar(),
        Expanded(
          child: bodyWrapper(
            Container(
              color: widget.masterBackgroundColor,
              child: SmartRefresher(
                key: smartRefresherKey,
                controller: refreshController,
                enablePullDown: widget.onRefresh != null && enableRefresh,
                enablePullUp: widget.onLoading != null,
                header: WaveRefreshHeader(),
                footer: WaveRefreshFooter(),
                onRefresh: () async {
                  try {
                    await widget.onRefresh?.call();
                    refreshController.refreshCompleted();
                  } catch (e) {
                    refreshController.refreshFailed();
                  }
                },
                onLoading: () async {
                  try {
                    final canLoadMore = await widget.onLoading?.call();
                    if (canLoadMore == true) {
                      refreshController.loadComplete();
                    } else {
                      refreshController.loadNoData();
                    }
                  } catch (e) {
                    refreshController.loadFailed();
                  }
                },
                onTwoLevel: (result) async {
                  await widget.onTwoLevel?.call(result);
                  refreshController.twoLevelComplete();
                },
                enableTwoLevel: false,
                scrollDirection: widget.scrollDirection ?? Axis.vertical,
                reverse: widget.reverse ?? false,
                primary: widget.primary,
                cacheExtent: widget.cacheExtent,
                semanticChildCount: widget.semanticChildCount,
                dragStartBehavior: widget.dragStartBehavior ?? DragStartBehavior.start,
                physics: PlatformScrollPhysics(parent: widget.scrollPhysics, controller: platformScrollController),
                child: child,
              ),
            ),
          ),
        ),
        if (widget.bottom != null) widget.bottom!,
      ],
    );

    final listener = Listener(
      onPointerDown: (event) {
        platformScrollController.addPointer();
      },
      onPointerUp: (event) {
        platformScrollController.removePointer();
      },
      onPointerCancel: (event) {
        platformScrollController.removePointer();
      },
      child: master,
    );

    if (widget.enableMasterSelection == true && PlatformX.isDesktopView) {
      return GestureDetector(
        onTap: () {
          masterFocusNode?.unfocus();
          detailsFocusNode?.unfocus();
        },
        child: SelectionArea(
          focusNode: masterFocusNode,
          contextMenuBuilder: (context, editableTextState) {
            return const SizedBox.shrink();
          },
          child: DefaultSelectionStyle(mouseCursor: SystemMouseCursors.basic, child: listener),
        ),
      );
    }

    return listener;
  }

  @override
  Widget build(BuildContext context) {
    final resizableClosableWidget = widget.tabType != null ? ref.watch(resizableClosableWidgetProvider(widget.tabType!)) : null;
    final resizableClosableDrawer = widget.tabType != null ? ref.watch(resizableClosableDrawerProvider(widget.tabType!)) : null;

    return Material(
      color: Colors.transparent,
      child: LayoutBuilder(
        builder: (context, constratins) {
          final double screenWidth = constratins.maxWidth;
          final bool large = screenWidth >= widget.breakpoint;

          if (large) {
            final largeDetail = desktopSelectedItemArea(large);
            return RepaintBoundary(
              child: ResizableContainer(
                direction: Axis.horizontal,
                children: [
                  if (resizableClosableDrawer != null)
                    ResizableChild(
                      size: ResizableSize.expand(min: 120, max: 220),
                      child: DesktopCard(child: resizableClosableDrawer),
                      divider: ResizableDivider(thickness: DesktopScaffold.cardPadding, color: Colors.transparent),
                    ),
                  ResizableChild(
                    size: ResizableSize.expand(min: widget.minMasterResizableWidth ?? 120, max: widget.maxMasterResizableWidth),
                    child: DesktopCard(
                      child: DropTarget(enable: widget.enableDropTarget ?? true, onDragDone: widget.onDragDone, child: masterWidget(large)),
                    ),
                    divider: ResizableDivider(thickness: DesktopScaffold.cardPadding, color: Colors.transparent),
                  ),
                  if (largeDetail != null)
                    ResizableChild(
                      size: ResizableSize.expand(min: widget.minDetailResizableWidth ?? 120),
                      child: DesktopCard(child: largeDetail),
                      divider: selectedItem != null ? ResizableDivider(thickness: DesktopScaffold.cardPadding, color: Colors.transparent) : ResizableDivider(),
                    ),
                  if (selectedItem != null && resizableClosableWidget != null)
                    ResizableChild(
                      size: ResizableSize.expand(min: resizableClosableWidget.minWidth ?? 120),
                      child: DesktopCard(child: resizableClosableWidget.widget!),
                      divider: ResizableDivider(),
                    ),
                ],
              ),
            );
          } else {
            if (!PlatformX.isDesktopView) {
              return Container(color: context.background, child: masterWidget(large));
            }

            return PageTransitionSwitcher(
              duration: const Duration(milliseconds: 0),
              reverse: focus == Focus.master,
              transitionBuilder: (Widget child, Animation<double> primaryAnimation, Animation<double> secondaryAnimation) {
                return SharedAxisPageTransitionsBuilder(
                  transitionType: SharedAxisTransitionType.horizontal,
                  fillColor: widget.masterBackgroundColor,
                ).buildTransitions<Object>(null, null, primaryAnimation, secondaryAnimation, child);
              },
              child: focus == Focus.details && selectedItem != null
                  ? Builder(builder: (ctx) => detailWidget(ctx, selectedItem!.id, large, true) ?? Container(color: context.background))
                  : Container(color: context.background, child: masterWidget(large)),
            );
          }
        },
      ),
    );
  }

  ListTile listTileBuilder(MasterItem item, int index, {bool page = false, required bool large}) {
    final Widget? subtitle = item.subtitle != null ? Text(item.subtitle!) : null;

    return ListTile(
      title: Text(item.title),
      subtitle: subtitle,
      leading: item.leading,
      trailing: item.trailing,
      selected: (selectedItem?.title == item.title) && !page,
      onTap:
          item.onTap ??
          () {
            if (!(widget.disableOpenDetailsOnTap ?? false)) {
              if (item.id == selectedItem?.id) return;
              openDetails(id: item.id);
            }
          },
    );
  }

  Widget _appBar() {
    if (widget.leadings == null && widget.actions == null) return SizedBox.shrink();
    return Container(
      width: double.maxFinite,
      height: widget.appbarSize == -1 ? null : appBarHeight,
      color: widget.masterBackgroundColor,
      child: Row(
        children: [
          Expanded(child: Row(children: [...(widget.leadings ?? [])])),
          // Expanded(child: widget.title ?? SizedBox.shrink()),
          ...(widget.actions ?? []),
        ],
      ),
    );
  }
}
