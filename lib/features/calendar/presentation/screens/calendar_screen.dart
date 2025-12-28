import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/admin_scaffold/admin_scaffold.dart';
import 'package:Visir/features/calendar/presentation/screens/main_calendar_widget.dart';
import 'package:Visir/features/calendar/presentation/screens/side_calendar_widget.dart';
import 'package:Visir/features/calendar/presentation/widgets/calendar_sidebar.dart';
import 'package:Visir/features/calendar/providers.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/widgets/desktop_scaffold.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_resizable_container/flutter_resizable_container.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final double kSidebarBreakpoint = 728;
final double kMobileUIBreakpoint = 448;

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> with AutomaticKeepAliveClientMixin {
  TabType get tabType => TabType.calendar;

  GlobalKey<AdminScaffoldState> adminScaffoldKey = GlobalKey<AdminScaffoldState>();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isMonth = ref.watch(calendarTypeChangerProvider(TabType.calendar).select((v) => v == CalendarType.month));
    final resizableClosableDrawer = ref.watch(resizableClosableDrawerProvider(tabType));

    return AdminScaffold(
      tabType: tabType,
      key: adminScaffoldKey,
      sideBar: CalendarSideBar(tabType: tabType),
      body: PlatformX.isMobileView
          ? isMonth
                ? SideCalendarWidget(
                    tabType: tabType,
                    onSidebarButtonPressed: () {
                      adminScaffoldKey.currentState?.toggleSidebar();
                    },
                  )
                : MainCalendarWidget(
                    tabType: tabType,
                    isPopup: false,
                    onSidebarButtonPressed: () {
                      adminScaffoldKey.currentState?.toggleSidebar();
                    },
                  )
          : ResizableContainer(
              direction: Axis.horizontal,
              children: [
                if (resizableClosableDrawer != null)
                  ResizableChild(
                    size: ResizableSize.expand(min: 120, max: 220),
                    child: DesktopCard(child: resizableClosableDrawer),
                    divider: ResizableDivider(thickness: DesktopScaffold.cardPadding, color: Colors.transparent),
                  ),

                if (PlatformX.isDesktopView || !isMonth)
                  ResizableChild(
                    size: ResizableSize.expand(min: calendarViewMinWidth),
                    child: DesktopCard(
                      child: MainCalendarWidget(
                        tabType: tabType,
                        isPopup: false,
                        onSidebarButtonPressed: () {
                          adminScaffoldKey.currentState?.toggleSidebar();
                        },
                      ),
                    ),
                    divider: ResizableDivider(thickness: PlatformX.isDesktopView ? DesktopScaffold.cardPadding : 0, color: Colors.transparent),
                  ),

                if (PlatformX.isDesktopView || isMonth)
                  ResizableChild(
                    size: ResizableSize.expand(min: 240, max: PlatformX.isMobileView ? null : 320),
                    child: Builder(
                      builder: (context) {
                        return DesktopCard(
                          child: SideCalendarWidget(
                            tabType: tabType,
                            onSidebarButtonPressed: () {
                              adminScaffoldKey.currentState?.toggleSidebar();
                            },
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
    );
  }
}
