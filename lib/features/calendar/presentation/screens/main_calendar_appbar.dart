import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/contextmenu/contextmenu.dart';
import 'package:Visir/dependency/omni_datetime_picker/omni_datetime_picker.dart';
import 'package:Visir/dependency/omni_datetime_picker/src/omni_datetime_picker.dart';
import 'package:Visir/features/calendar/presentation/screens/main_calendar_widget.dart';
import 'package:Visir/features/calendar/providers.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/presentation/widgets/visir_app_bar.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class MainCalendarAppbar extends ConsumerStatefulWidget {
  final void Function(DateTime dateTime) onDateButtonPressed;
  final void Function() onAddButtonPressed;
  final void Function() onTodayButtonPressed;

  final void Function() onPrevButtonPressed;
  final void Function() onNextButtonPressed;

  final bool Function() movePrevDay;
  final bool Function() moveNextDay;

  final void Function() onRefreshButtonPressed;
  final void Function(CalendarType type) onCalendarTypeChanged;
  final void Function() onSidebarButtonPressed;

  final TabType tabType;
  final bool hideSearchButton;
  final CalendarAppBarType appbarType;

  const MainCalendarAppbar({
    super.key,
    required this.tabType,
    required this.onAddButtonPressed,
    required this.onTodayButtonPressed,
    required this.onPrevButtonPressed,
    required this.onNextButtonPressed,
    required this.onRefreshButtonPressed,
    required this.onCalendarTypeChanged,
    required this.onDateButtonPressed,
    required this.movePrevDay,
    required this.moveNextDay,
    required this.onSidebarButtonPressed,
    this.hideSearchButton = false,
    required this.appbarType,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => MainCalendarAppbarState();
}

class MainCalendarAppbarState extends ConsumerState<MainCalendarAppbar> {
  bool get isDarkMode => context.isDarkMode;
  double get appBarHeight => 48;

  @override
  Widget build(BuildContext context) {
    final calendarType = widget.appbarType == CalendarAppBarType.side ? CalendarType.month : ref.watch(calendarTypeChangerProvider(widget.tabType));
    final targetMonth = ref.watch(calendarTargetMonthProvider(widget.tabType).select((v) => v[widget.appbarType] ?? DateTime.now()));
    final resizableClosableDrawer = ref.watch(resizableClosableDrawerProvider(widget.tabType));

    final leadingBeforeText = [
      if (widget.tabType == TabType.calendar && (resizableClosableDrawer == null))
        VisirAppBarButton(icon: VisirIconType.control, onTap: widget.onSidebarButtonPressed).getButton(context: context),
      // if (!widget.hideSearchButton)
      //   VisirAppBarButton(
      //     icon: VisirIconType.search,
      //     onTap: () {},
      //     options: VisirButtonOptions(
      //       tabType: widget.tabType,
      //       shortcuts: [
      //         VisirButtonKeyboardShortcut(
      //           message: context.tr.search_events,
      //           keys: [LogicalKeyboardKey.keyF, if (PlatformX.isApple) LogicalKeyboardKey.meta, if (!PlatformX.isApple) LogicalKeyboardKey.control],
      //         ),
      //       ],
      //     ),
      //   ).getButton(context: context),
    ];

    bool isInteractableAppbar = widget.tabType == TabType.calendar || (widget.tabType == TabType.home && PlatformX.isDesktopView);

    return PreferredSize(
      preferredSize: Size.fromHeight(context.appBarTheme.toolbarHeight ?? kToolbarHeight),
      child: Container(
        height: context.appBarHeight,
        child: Row(
          children: [
            SizedBox(width: 6),
            if (isInteractableAppbar) ...leadingBeforeText,
            if (leadingBeforeText.isNotEmpty && isInteractableAppbar) VisirAppBarButton(isDivider: true).getButton(context: context) else SizedBox(width: 4),
            PlatformX.isMobileView
                ? PopupMenu(
                    width: 296,
                    height: 300,
                    forcePopup: true,
                    location: PopupMenuLocation.bottom,
                    type: ContextMenuActionType.tap,
                    popup: OmniDateTimePicker(
                      type: OmniDateTimePickerType.date,
                      initialDate: targetMonth,
                      onDateChanged: (dateTime) {
                        widget.onDateButtonPressed(dateTime);
                      },
                    ),
                    style: VisirButtonStyle(borderRadius: BorderRadius.circular(6), height: 32, padding: EdgeInsets.symmetric(horizontal: 4)),
                    child: Row(
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: DateFormat.MMM().format(targetMonth),
                                style: context.titleLarge?.textColor(context.outlineVariant).textBold.appFont(context),
                              ),
                              // WidgetSpan(child: SizedBox(width: 6)),
                              TextSpan(
                                text: ' ${DateFormat.y().format(targetMonth).substring(2)}',
                                style: context.titleLarge?.textColor(context.tertiary).textBold.appFont(context),
                              ),
                            ],
                          ),
                        ),
                        if (isInteractableAppbar) SizedBox(width: 6),
                        if (isInteractableAppbar) VisirIcon(type: VisirIconType.arrowDown, size: 16, color: context.inverseSurface),
                      ],
                    ),
                  )
                : PopupMenu(
                    width: 296,
                    height: 300,
                    forcePopup: true,
                    location: PopupMenuLocation.bottom,
                    type: ContextMenuActionType.tap,
                    popup: OmniDateTimePicker(
                      type: OmniDateTimePickerType.date,
                      initialDate: targetMonth,
                      onDateChanged: (dateTime) {
                        widget.onDateButtonPressed(dateTime);
                      },
                    ),
                    style: VisirButtonStyle(borderRadius: BorderRadius.circular(6), height: 32, padding: EdgeInsets.symmetric(horizontal: 6)),
                    child: Row(
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: DateFormat.MMM().format(targetMonth),
                                style: context.titleLarge?.textColor(context.onBackground).textBold.appFont(context),
                              ),
                              // WidgetSpan(child: SizedBox(width: 6)),
                              TextSpan(
                                text: ' ${DateFormat.y().format(targetMonth)}',
                                style: context.titleLarge?.textColor(context.tertiary).textBold.appFont(context),
                              ),
                            ],
                          ),
                        ),
                        if (isInteractableAppbar) SizedBox(width: 8),
                        if (isInteractableAppbar) VisirIcon(type: VisirIconType.arrowDown, size: 16, color: context.inverseSurface),
                      ],
                    ),
                  ),
            if (isInteractableAppbar) ...[
              VisirAppBarButton(isDivider: true).getButton(context: context),
              Row(
                children: [
                  VisirAppBarButton(
                    icon: VisirIconType.calendarBefore,
                    onTap: widget.onPrevButtonPressed,
                    options: VisirButtonOptions(
                      tabType: widget.tabType,
                      shortcuts: [
                        VisirButtonKeyboardShortcut(message: context.tr.tooltip_prev_day, onTrigger: widget.movePrevDay, keys: [LogicalKeyboardKey.arrowLeft]),
                        if (calendarType != CalendarType.day)
                          VisirButtonKeyboardShortcut(
                            message: calendarType == CalendarType.week
                                ? context.tr.tooltip_prev_week
                                : calendarType == CalendarType.month
                                ? context.tr.tooltip_prev_month
                                : context.tr.tooltip_prev_n_day(calendarType.count),
                            keys: [
                              LogicalKeyboardKey.arrowLeft,
                              if (PlatformX.isApple) LogicalKeyboardKey.meta,
                              if (!PlatformX.isApple) LogicalKeyboardKey.control,
                            ],
                          ),
                      ],
                    ),
                  ).getButton(context: context),

                  VisirAppBarButton(
                    icon: VisirIconType.today,
                    onTap: widget.onTodayButtonPressed,
                    options: VisirButtonOptions(
                      tabType: widget.tabType,
                      shortcuts: [
                        VisirButtonKeyboardShortcut(
                          message: context.tr.today,
                          keys: [LogicalKeyboardKey.keyT, if (PlatformX.isApple) LogicalKeyboardKey.meta, if (!PlatformX.isApple) LogicalKeyboardKey.control],
                        ),
                      ],
                    ),
                  ).getButton(context: context),
                  VisirAppBarButton(
                    icon: VisirIconType.calendarAfter,
                    options: VisirButtonOptions(
                      tabType: widget.tabType,
                      shortcuts: [
                        VisirButtonKeyboardShortcut(
                          message: context.tr.tooltip_next_day,
                          onTrigger: widget.moveNextDay,
                          keys: [LogicalKeyboardKey.arrowRight],
                        ),
                        if (calendarType != CalendarType.day)
                          VisirButtonKeyboardShortcut(
                            message: calendarType == CalendarType.week
                                ? context.tr.tooltip_next_week
                                : calendarType == CalendarType.month
                                ? context.tr.tooltip_next_month
                                : context.tr.tooltip_next_n_day(calendarType.count),
                            keys: [
                              LogicalKeyboardKey.arrowRight,
                              if (PlatformX.isApple) LogicalKeyboardKey.meta,
                              if (!PlatformX.isApple) LogicalKeyboardKey.control,
                            ],
                          ),
                      ],
                    ),
                    onTap: widget.onNextButtonPressed,
                  ).getButton(context: context),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
