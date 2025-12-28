import 'package:Visir/dependency/master_detail_flow/src/enums.dart';
import 'package:Visir/dependency/master_detail_flow/src/flow_settings.dart';
import 'package:Visir/features/common/presentation/widgets/visir_app_bar.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/common/presentation/widgets/wave_refresh_footer.dart';
import 'package:Visir/features/common/presentation/widgets/wave_refresh_header.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

/// An M3 details page to be used in a MasterDetailFlow. It adapts using
/// MasterDetailsFlowSettings provided by the MasterDetailsFlow
class DetailsItem extends StatefulWidget {
  /// Creates an M3 details page
  const DetailsItem({
    this.title,
    this.children,
    this.child,
    this.actions,
    this.leadings,
    this.lateralDetailsAppBar,
    this.pageDetailsAppBar,
    this.scrollPhysics,
    this.bodyPadding,
    this.appbarColor,
    this.dividerColor,
    this.bodyColor,
    this.removeDivider,
    this.scrollController,
    this.listController,
    this.hideBackButton,
    this.onLoading,
    this.onRefresh,
    this.reverse,
    this.loadingNotifier,
    this.successNotifier,
    this.showLoadingNotifier,
    this.bodyWrapper,
    this.appBarWrapper,
    this.customBottomPadding,
    super.key,
  });

  final bool? reverse;
  final Color? appbarColor;
  final Color? dividerColor;
  final Color? bodyColor;
  final ScrollPhysics? scrollPhysics;

  final ValueNotifier<bool?>? loadingNotifier;
  final ValueNotifier<bool?>? successNotifier;
  final ValueNotifier<bool?>? showLoadingNotifier;

  /// The title widget to be used in the app bar of the details page
  final String? title;

  /// A list of Widgets to display in a row after the [title] widget.
  ///
  /// Typically these widgets are [IconButton]s representing common operations.
  /// For less common operations, consider using a [PopupMenuButton] as the
  /// last action.
  final List<VisirAppBarButton>? leadings;
  final List<VisirAppBarButton>? actions;

  /// The children to be shown by the details page in a list
  final List<Widget>? children;
  final Widget? child;
  final double? customBottomPadding;

  final Widget Function(Widget child)? bodyWrapper;
  final Widget Function(Widget child)? appBarWrapper;

  /// Overrides for the parameters in [MasterDetailsFlow]. See
  /// [MasterDetailsFlow.lateralDetailsAppbar] and
  /// [MasterDetailsFlow.pageDetailsAppBar]
  final DetailsAppBarSize? lateralDetailsAppBar, pageDetailsAppBar;

  final EdgeInsets? bodyPadding;

  final bool? removeDivider;
  final bool? hideBackButton;

  final ScrollController? scrollController;
  final ListController? listController;

  final Future<void> Function()? onRefresh;
  final Future<bool> Function()? onLoading;

  @override
  State<DetailsItem> createState() => _DetailsItemState();
}

class _DetailsItemState extends State<DetailsItem> {
  late RefreshController refreshController;

  @override
  void initState() {
    super.initState();
    refreshController = RefreshController();
    widget.loadingNotifier?.addListener(checkLoadingBarListener);
    widget.showLoadingNotifier?.addListener(checkLoadingBarListener);
  }

  @override
  void dispose() {
    refreshController.dispose();
    widget.loadingNotifier?.removeListener(checkLoadingBarListener);
    widget.showLoadingNotifier?.removeListener(checkLoadingBarListener);
    super.dispose();
  }

  bool enableRefresh = true;
  void checkLoadingBarListener() {
    if (widget.loadingNotifier?.value == true && widget.showLoadingNotifier?.value == true) {
      enableRefresh = false;
    } else {
      enableRefresh = true;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MasterDetailsFlowSettings? settings = MasterDetailsFlowSettings.of(context);

    final bodyWrapper = (Widget child) => widget.bodyWrapper?.call(child) ?? child;

    return Material(
      color: Colors.transparent,
      child: Column(
        children: [
          widget.appBarWrapper?.call(_sliverAppBar(settings, theme, context, widget.removeDivider ?? false)) ??
              _sliverAppBar(settings, theme, context, widget.removeDivider ?? false),
          Expanded(
            child: bodyWrapper(
              Container(
                padding: widget.bodyPadding ?? EdgeInsets.zero,
                color: widget.bodyColor ?? Colors.transparent,
                child:
                    widget.child ??
                    SmartRefresher(
                      enablePullDown: widget.onRefresh != null && enableRefresh,
                      enablePullUp: widget.onLoading != null,
                      physics: widget.scrollPhysics,
                      header: WaveRefreshHeader(),
                      footer: WaveRefreshFooter(),
                      controller: refreshController,
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
                      child: CustomScrollView(
                        physics: widget.scrollPhysics,
                        controller: widget.scrollController ?? ScrollController(),
                        reverse: widget.reverse ?? false,
                        slivers: <Widget>[
                          if (widget.reverse == true) SliverToBoxAdapter(child: SizedBox(height: widget.customBottomPadding ?? scrollViewBottomPadding.bottom)),
                          SuperSliverList(
                            listController: widget.listController,
                            delegate: SliverChildListDelegate.fixed(widget.children ?? []),
                            layoutKeptAliveChildren: true,
                          ),
                          if (widget.reverse != true) SliverToBoxAdapter(child: SizedBox(height: widget.customBottomPadding ?? scrollViewBottomPadding.bottom)),
                        ],
                      ),
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sliverAppBar(MasterDetailsFlowSettings? settings, ThemeData theme, BuildContext context, bool removeDivider) {
    if (widget.title == null && widget.leadings == null && widget.actions == null) return SizedBox.shrink();

    return VisirAppBar(
      title: widget.title ?? '',
      backgroundColor: widget.appbarColor,
      leadings: [
        if (widget.hideBackButton != true) VisirAppBarButton(icon: VisirIconType.arrowLeft, onTap: settings?.goBack),
        ...(widget.leadings ?? []),
      ],
      trailings: [...(widget.actions ?? [])],
    );
  }
}
