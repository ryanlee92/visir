import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/admin_scaffold/admin_scaffold.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/calendar/presentation/screens/main_calendar_widget.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/log_event.dart';
import 'package:Visir/features/common/presentation/widgets/desktop_scaffold.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/inbox/presentation/screens/inbox_agent_screen.dart';
import 'package:Visir/features/inbox/presentation/screens/inbox_list_screen.dart';
import 'package:Visir/features/inbox/presentation/widgets/inbox_sidebar.dart';
import 'package:Visir/features/inbox/providers.dart';
import 'package:Visir/features/task/presentation/widgets/timeblock_drop_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_resizable_container/flutter_resizable_container.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InboxScreen extends ConsumerStatefulWidget {
  final TabType tabType;
  final GlobalKey<InboxListScreenState>? inboxListScreenKey;
  final void Function(bool showCalendarOnMobile)? onUpdateVisibilitiyCalendarOnMobile;

  const InboxScreen({super.key, required this.tabType, this.inboxListScreenKey, this.onUpdateVisibilitiyCalendarOnMobile});

  @override
  ConsumerState createState() => _InboxScreenState();
}

class _InboxScreenState extends ConsumerState<InboxScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late GlobalKey<MainCalendarWidgetState> calendarKey;
  GlobalKey<AdminScaffoldState> adminScaffoldKey = GlobalKey<AdminScaffoldState>();
  GlobalKey<TimeblockDropWidgetState> timeblockDropWidgetKey = GlobalKey<TimeblockDropWidgetState>();

  double inboxListMinWidth = 320;

  bool isAgenticHome = false;

  bool showTimeblockDropWidget = false;
  Offset dragOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final resizableClosableDrawer = ref.watch(resizableClosableDrawerProvider(widget.tabType));
    final resizableClosableWidget = ref.watch(resizableClosableWidgetProvider(widget.tabType));
    final homeCalendarRatio = ref.watch(homeCalendarRatioProvider);
    final ratio = ref.watch(zoomRatioProvider);

    final currentInboxScreenType = ref.watch(currentInboxScreenTypeProvider);

    final isAgenticUi = currentInboxScreenType == InboxScreenType.agent;

    return AdminScaffold(
      key: adminScaffoldKey,
      tabType: widget.tabType,
      sideBar: InboxSideBar(tabType: widget.tabType),
      body: PlatformX.isMobileView
          ? Stack(
              children: [
                Positioned.fill(
                  child: isAgenticUi
                      ? InboxAgentScreen(
                          onDragStart: (inbox) {
                            showTimeblockDropWidget = true;
                            setState(() {});
                          },
                          onDragUpdate: (inbox, offset) {
                            timeblockDropWidgetKey.currentState?.onInboxDragUpdate(inbox, offset);
                          },
                          onDragEnd: (inbox, offset) {
                            timeblockDropWidgetKey.currentState
                                ?.onInboxDragEnd(inbox, offset)
                                .then((_) {
                                  showTimeblockDropWidget = false;
                                  setState(() {});
                                })
                                .catchError((e) {
                                  showTimeblockDropWidget = false;
                                  setState(() {});
                                });
                          },
                        )
                      : InboxListScreen(
                          tabType: widget.tabType,
                          onSidebarButtonPressed: () {
                            adminScaffoldKey.currentState?.toggleSidebar();
                          },
                          onDragStart: (inbox) {
                            showTimeblockDropWidget = true;
                            setState(() {});
                          },
                          onDragEnd: (inbox, offset) {
                            timeblockDropWidgetKey.currentState
                                ?.onInboxDragEnd(inbox, offset)
                                .then((_) {
                                  showTimeblockDropWidget = false;
                                  setState(() {});
                                })
                                .catchError((e) {
                                  showTimeblockDropWidget = false;
                                  setState(() {});
                                });
                          },
                          onDragUpdate: (inbox, offset) {
                            timeblockDropWidgetKey.currentState?.onInboxDragUpdate(inbox, offset);
                          },
                        ),
                ),

                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  width: context.width / ratio,
                  top: PlatformX.isMobileView
                      ? showTimeblockDropWidget
                            ? 0
                            : context.mobileCardHeight / ratio
                      : 0,
                  right: PlatformX.isMobileView
                      ? 0
                      : showTimeblockDropWidget
                      ? 380
                      : 0,
                  bottom: PlatformX.isMobileView ? null : 0,
                  height: PlatformX.isMobileView ? context.mobileCardHeight / ratio : null,
                  child: Transform.translate(
                    offset: Offset(PlatformX.isDesktopView ? 380 : 0, PlatformX.isMobileView ? 0 : 0),
                    child: Container(
                      height: PlatformX.isMobileView ? context.mobileCardHeight / ratio : null,
                      margin: PlatformX.isMobileView ? null : EdgeInsets.all(6),
                      padding: EdgeInsets.all(PlatformX.isMobileView ? 0 : 6),
                      decoration: BoxDecoration(
                        color: context.surface,
                        boxShadow: PopupMenu.popupShadow,
                        border: PlatformX.isMobileView ? null : Border.all(color: context.outline),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(PlatformX.isMobileView ? 20 : DesktopScaffold.cardRadius),
                          topRight: Radius.circular(PlatformX.isMobileView ? 20 : DesktopScaffold.cardRadius),
                          bottomLeft: Radius.circular(PlatformX.isMobileView ? 0 : DesktopScaffold.cardRadius),
                          bottomRight: Radius.circular(PlatformX.isMobileView ? 0 : DesktopScaffold.cardRadius),
                        ),
                      ),
                      child: TimeblockDropWidget(key: timeblockDropWidgetKey, tabType: widget.tabType),
                    ),
                  ),
                ),
              ],
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: RepaintBoundary(
                        child: ResizableContainer(
                          direction: Axis.horizontal,
                          children: [
                            if (resizableClosableDrawer != null)
                              ResizableChild(
                                size: ResizableSize.expand(min: 120, max: 220),
                                child: DesktopCard(child: resizableClosableDrawer),
                                divider: ResizableDivider(thickness: DesktopScaffold.cardPadding, color: Colors.transparent),
                              ),

                            if (isAgenticUi)
                              ResizableChild(
                                size: ResizableSize.expand(min: inboxListMinWidth, flex: homeCalendarRatio.first),
                                child: DesktopCard(child: InboxAgentScreen(), backgroundColor: context.background),
                              ),

                            if (!isAgenticUi)
                              ResizableChild(
                                size: ResizableSize.expand(min: inboxListMinWidth, flex: homeCalendarRatio.first),
                                child: Builder(
                                  builder: (context) {
                                    return DesktopCard(
                                      child: InboxListScreen(
                                        key: widget.inboxListScreenKey,
                                        onSidebarButtonPressed: () {
                                          adminScaffoldKey.currentState?.toggleSidebar();
                                        },
                                        tabType: widget.tabType,
                                        onDragUpdate: (inbox, offset) {
                                          timeblockDropWidgetKey.currentState?.onInboxDragUpdate(inbox, offset);
                                        },
                                        onDragEnd: (inbox, offset) {
                                          final user = ref.read(authControllerProvider).value;
                                          if (user != null && !user.isSignedIn) {
                                            logAnalyticsEvent(eventName: 'onboarding_drag_drop');
                                          }

                                          timeblockDropWidgetKey.currentState?.onInboxDragEnd(inbox, offset);
                                        },
                                        onShowCreateShadow: (startTime, endTime, isAllDay) {
                                          timeblockDropWidgetKey.currentState?.onShowCreateShadow(startTime, endTime, isAllDay);
                                        },
                                        onRemoveCreateShadow: () {
                                          timeblockDropWidgetKey.currentState?.onRemoveCreateShadow();
                                        },
                                        onSaved: () {
                                          timeblockDropWidgetKey.currentState?.onSaved();
                                        },
                                        onTitleChanged: (title) {
                                          timeblockDropWidgetKey.currentState?.onTitleChanged(title);
                                        },
                                        onColorChanged: (color) {
                                          timeblockDropWidgetKey.currentState?.onColorChanged(color);
                                        },
                                        onTimeChanged: (startDate, endDate, isAllDay) {
                                          timeblockDropWidgetKey.currentState?.onTimeChanged(startDate, endDate, isAllDay);
                                        },
                                        updateIsTask: (isTask) {
                                          timeblockDropWidgetKey.currentState?.updateIsTask(isTask);
                                        },
                                      ),
                                    );
                                  },
                                ),
                                divider: ResizableDivider(thickness: DesktopScaffold.cardPadding, color: Colors.transparent),
                              ),

                            if (!isAgenticUi)
                              ResizableChild(
                                size: ResizableSize.expand(min: calendarViewMinWidth, flex: homeCalendarRatio.last),
                                child: DesktopCard(
                                  child: TimeblockDropWidget(tabType: widget.tabType, key: timeblockDropWidgetKey),
                                ),
                                divider: resizableClosableWidget != null
                                    ? ResizableDivider(thickness: DesktopScaffold.cardPadding, color: Colors.transparent)
                                    : const ResizableDivider(),
                              ),

                            if (resizableClosableWidget != null && !isAgenticUi)
                              ResizableChild(
                                size: ResizableSize.expand(min: resizableClosableWidget.minWidth ?? 120),
                                child: DesktopCard(child: resizableClosableWidget.widget!),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
