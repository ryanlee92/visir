import 'dart:async';
import 'dart:math' as math;
import 'dart:math';

import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/calendar/calendar.dart';
import 'package:Visir/dependency/calendar/src/calendar/appointment_engine/appointment_helper.dart';
import 'package:Visir/dependency/calendar/src/calendar/appointment_layout/appointment_layout.dart';
import 'package:Visir/dependency/contextmenu/contextmenu.dart';
import 'package:Visir/dependency/rrule/src/codecs/string/encoder.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/auth/domain/entities/user_entity.dart';
import 'package:Visir/features/calendar/application/calendar_event_list_controller.dart';
import 'package:Visir/features/calendar/application/calendar_list_controller.dart';
import 'package:Visir/features/calendar/presentation/screens/main_calendar_appbar.dart';
import 'package:Visir/features/calendar/presentation/screens/main_calendar_widget.dart';
import 'package:Visir/features/calendar/presentation/widgets/calendar_simple_create_widget.dart';
import 'package:Visir/features/calendar/presentation/widgets/mobile_calendar_edit_widget.dart';
import 'package:Visir/features/calendar/providers.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/date_time_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/list_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/log_event.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/desktop_scaffold.dart';
import 'package:Visir/features/common/presentation/widgets/diagonal_stripes_paint.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:Visir/features/task/actions.dart';
import 'package:Visir/features/task/application/calendar_task_list_controller.dart';
import 'package:Visir/features/task/application/project_list_controller.dart';
import 'package:Visir/features/task/domain/entities/task_entity.dart';
import 'package:Visir/features/task/presentation/widgets/mobile_task_edit_widget.dart';
import 'package:Visir/features/task/presentation/widgets/task_simple_create_widget.dart';
import 'package:collection/collection.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_resizable_container/flutter_resizable_container.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class SideCalendarWidget extends ConsumerStatefulWidget {
  final TabType tabType;
  final void Function()? onSidebarButtonPressed;

  const SideCalendarWidget({super.key, required this.tabType, this.onSidebarButtonPressed});

  @override
  ConsumerState createState() => SideCalendarWidgetState();
}

class SideCalendarWidgetState extends ConsumerState<SideCalendarWidget> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool get isMobileView => PlatformX.isMobileView;

  CalendarController controller = CalendarController();
  CalendarController agendaController = CalendarController();
  _CalendarDataSource datasource = _CalendarDataSource([]);
  _CalendarDataSource agendaDatasource = _CalendarDataSource([]);

  String? get timezone => ref.read(defaultTimezoneProvider) ?? ref.read(timezoneProvider).value;

  DateTime? modifyStartDateTime;
  DateTime? modifyEndDateTime;
  bool? modifyIsAllDay;
  Duration modifyStartTimeDurationDifference = Duration.zero;

  DateTime initialCalendarDateTime = DateTime.now();
  DateTime intiialCalendarDisplayTime = DateTime.now();

  OverlayEntry? simpleCreateOverlayEntry;
  bool initialLoaded = false;

  GlobalKey calendarKey = GlobalKey();

  GlobalKey editAreaGlobalKey = GlobalKey();
  GlobalKey cancelAreaGlobalKey = GlobalKey();

  bool onDragEdit = false;
  bool onDragCancel = false;

  double get timeLabelWidth => showMobileUi ? 52 : 60;

  bool get isSignedIn => ref.read(isSignedInProvider);

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    final now15 = DateTime(now.year, now.month, now.day, now.hour, (now.minute ~/ 15 + 1) * 15);

    initialCalendarDateTime = now15;
    intiialCalendarDisplayTime = now15;

    controller.setProperties(displayDate: intiialCalendarDisplayTime, view: CalendarView.month);
    agendaController.setProperties(displayDate: intiialCalendarDisplayTime, view: CalendarView.schedule);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      updateCalendarDatasource();
    });

    if (!isSignedIn) {
      initialCalendarDateTime = onboardingTargetTime;
      intiialCalendarDisplayTime = onboardingTargetTime;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    agendaController.dispose();
    _datasourceUpdateTimer?.cancel(); // GC optimization: clean up timer
    super.dispose();
  }

  DateTime get onboardingTargetTime => DateTime(2025, 9, 13, 20, 30).add(dateOffset);

  String? prevIsShowcaseOn = null;
  Widget? showcaseTargetTask;
  Widget? showcaseTargetEvent;

  Widget buildAppointment(BuildContext context, CalendarAppointmentDetails details, bool isAgenda) {
    return ExtendGestureAreaDetector(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: details.appointments.map((d) {
              final e = d as TaskEntity;

              final project = ref.read(projectListControllerProvider.select((p) => p.firstWhereOrNull((p) => p.isPointedProject(e)) ?? p.firstWhere((p) => p.isDefault)));
              Color? backgroundColor = e.isEvent ? e.linkedEvent?.backgroundColor : project.color;
              if (backgroundColor == null) return SizedBox.shrink();

              HSVColor hsvColor = HSVColor.fromColor(backgroundColor);
              if (context.brightness == Brightness.light) {
                if (hsvColor.value > 0.7 && hsvColor.saturation >= 0.2 && hsvColor.saturation < 0.5) {
                  hsvColor = hsvColor.withValue(0.7);
                  backgroundColor = hsvColor.toColor();
                } else if (hsvColor.value > 0.5 && hsvColor.saturation < 0.2) {
                  hsvColor = hsvColor.withValue(0.5);
                  backgroundColor = hsvColor.toColor();
                } else if (hsvColor.value > 0.9 && hsvColor.saturation >= 0.5) {
                  hsvColor = hsvColor.withValue(0.9);
                }
              }

              Color nonAgendaBackgroundColor = backgroundColor.withValues(alpha: hsvColor.value <= 0.6 && context.brightness == Brightness.dark ? 0.3 : 0.15);
              Color nonAgendaForegroundColor = backgroundColor;
              Color nonAgendaTextColor = backgroundColor;

              if (context.brightness == Brightness.dark) {
                if (hsvColor.value <= 0.6) {
                  hsvColor = hsvColor.withValue(0.9);
                  nonAgendaForegroundColor = hsvColor.toColor();
                  nonAgendaTextColor = hsvColor.toColor();
                }

                nonAgendaTextColor = hsvColor.withSaturation(0.2).withValue(1).toColor();
              } else {
                if (hsvColor.hue > 0.4 && hsvColor.hue < 0.95 && hsvColor.value > 0.7 && hsvColor.saturation >= 0.5) {
                  hsvColor = hsvColor.withValue(0.7);
                  nonAgendaTextColor = hsvColor.toColor();
                }

                nonAgendaTextColor = hsvColor.withSaturation(0.95).withValue(0.3).toColor();
              }

              final showTimeRatherThanLine = !e.isAllDay;

              final actualStartTime = e.startAt ?? e.linkedEvent?.editedStartTime ?? e.linkedEvent?.startDate;
              final actualEndTime = e.endAt ?? e.linkedEvent?.editedEndTime ?? e.linkedEvent?.endDate;

              if (actualStartTime == null || actualEndTime == null) return SizedBox.shrink();

              final isSpanned =
                  !(actualEndTime.day == actualStartTime.day && actualEndTime.month == actualStartTime.month && actualEndTime.year == actualStartTime.year) &&
                  AppointmentHelper.getDifference(actualStartTime, actualEndTime).inDays > 0;

              double checkboxSize = 12;

              double leftPadding = 4;
              double rightPadding = 4;
              double topPadding = 2;

              final isRequest = e.isRequest;
              final isDeclined = e.linkedEvent?.isDeclined == true;
              final isMaybe = e.linkedEvent?.isMaybe == true;

              double startTimeBottomPadding = 2;

              Color base = isAgenda
                  ? context.surfaceVariant
                  : showTimeRatherThanLine
                  ? Colors.transparent
                  : nonAgendaBackgroundColor;

              Widget child = RepaintBoundary(
                child: Padding(
                  padding: EdgeInsets.only(right: 2),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(isAgenda ? 6 : 2),
                    child: Container(
                      height: constraints.maxHeight,
                      constraints: BoxConstraints(minHeight: 16),
                      decoration: BoxDecoration(
                        color: isAgenda
                            ? Colors.transparent
                            : isDeclined
                            ? Colors.transparent
                            : base,
                        border: isAgenda
                            ? null
                            : !e.isEvent
                            ? null
                            : isRequest || isDeclined
                            ? Border.all(color: backgroundColor, width: 1, strokeAlign: BorderSide.strokeAlignInside)
                            : null,
                      ),
                      alignment: controller.view == CalendarView.month ? Alignment.centerLeft : null,
                      child: Stack(
                        children: [
                          if (isMaybe && !isAgenda)
                            CustomPaint(
                              painter: DiagonalStripesPainter(
                                angleRadians: math.pi / 6, // 45° (구글 캘린더 느낌)
                                stripeWidth: 4, // 줄 폭
                                gapWidth: 4, // 줄 간격
                                stripeColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
                                backgroundColor: base,
                              ),
                              size: Size.infinite,
                            ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!isAgenda)
                                Container(
                                  width: isRequest || isDeclined ? 1 : 2,
                                  decoration: BoxDecoration(
                                    color: !e.isEvent
                                        ? Colors.transparent
                                        : isRequest || isDeclined || showTimeRatherThanLine
                                        ? Colors.transparent
                                        : nonAgendaForegroundColor.withValues(alpha: e.isMaybe ? 0.8 : 0.8),
                                    borderRadius: BorderRadius.horizontal(left: Radius.circular(2)),
                                  ),
                                ),
                              Expanded(
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    double maxHeight = constraints.maxHeight - (isRequest || isDeclined || e.isAllDay ? 0 : topPadding);
                                    // double maxWidth = constraints.maxWidth - (leftPadding + rightPadding);

                                    bool isHideCell = maxHeight < (context.bodyMedium!.height! * context.textScaler.scale(context.bodyMedium!.fontSize!));
                                    bool isShowStartTime =
                                        maxHeight >
                                        (context.bodyMedium!.height! * context.textScaler.scale(context.bodyMedium!.fontSize!)) +
                                            (context.labelSmall!.height! * context.textScaler.scale(context.labelSmall!.fontSize!)) +
                                            2;

                                    final baseStyle = e.isAllDay ? context.bodyLarge : context.bodyLarge;

                                    return Stack(
                                      children: [
                                        Padding(
                                          padding: isAgenda
                                              ? EdgeInsets.zero
                                              : EdgeInsets.only(left: leftPadding, right: rightPadding, top: isRequest || isDeclined || e.isAllDay ? 0 : topPadding),
                                          child: isAgenda
                                              ? Builder(
                                                  builder: (context) {
                                                    final child = PopupMenu(
                                                      location: PopupMenuLocation.right,
                                                      forceShiftOffset: Offset(
                                                        0,
                                                        e.linkedEvent == null || (PlatformX.isDesktopView && e.linkedEvent!.isModifiable && !isRequest)
                                                            ? forceShiftOffsetForMenu.dy
                                                            : 0,
                                                      ),
                                                      type: ContextMenuActionType.tap,
                                                      backgroundColor: Colors.transparent,
                                                      hideShadow: true,
                                                      popup: PlatformX.isDesktopView
                                                          ? e.isEvent
                                                                ? CalenderSimpleCreateWidget(
                                                                    tabType: TabType.home,
                                                                    selectedDate: e.linkedEvent?.editedStartTime ?? e.linkedEvent?.startDate ?? DateTime.now(),
                                                                    event: e.linkedEvent,
                                                                    linkedMails: e.linkedMails,
                                                                    linkedMessages: e.linkedMessages,
                                                                    calendarTaskEditSourceType: CalendarTaskEditSourceType.editOriginal,
                                                                  )
                                                                : TaskSimpleCreateWidget(
                                                                    tabType: widget.tabType,
                                                                    task: e,
                                                                    selectedDate: e.editedStartTime ?? e.startDate,
                                                                    calendarTaskEditSourceType: CalendarTaskEditSourceType.editOriginal,
                                                                  )
                                                          : e.isEvent
                                                          ? MobileCalendarEditWidget(
                                                              tabType: widget.tabType,
                                                              event: e.linkedEvent,
                                                              selectedDate: details.date.add(
                                                                Duration(hours: e.linkedEvent!.startDate.hour, minutes: e.linkedEvent!.startDate.minute),
                                                              ),
                                                              linkedMessages: e.linkedMessages,
                                                              linkedMails: e.linkedMails,
                                                              calendarTaskEditSourceType: CalendarTaskEditSourceType.editOriginal,
                                                            )
                                                          : MobileTaskEditWidget(
                                                              task: e,
                                                              selectedDate: details.date.add(Duration(hours: e.startAt!.hour, minutes: e.startAt!.minute)),
                                                              tabType: widget.tabType,
                                                              calendarTaskEditSourceType: CalendarTaskEditSourceType.editOriginal,
                                                            ),
                                                      style: VisirButtonStyle(
                                                        hoverColor: Colors.transparent,
                                                        clickMargin: EdgeInsets.zero,
                                                        backgroundColor: e.isAllDay
                                                            ? context.isDarkMode
                                                                  ? context.background
                                                                  : context.surfaceTint
                                                            : null,
                                                        borderRadius: BorderRadius.circular(6),
                                                      ),
                                                      child: Transform.translate(
                                                        offset: Offset(0, e.isAllDay ? 0 : -1.5),
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            color: e.isAllDay ? backgroundColor?.withValues(alpha: e.isAllDay ? 0.5 : 0.75) : Colors.transparent,
                                                            borderRadius: BorderRadius.circular(6),
                                                          ),
                                                          padding: EdgeInsets.only(left: e.isAllDay ? 6 : 0, right: e.isAllDay ? 6 : 6, top: e.isAllDay ? 0 : 0),
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              if (!e.isAllDay)
                                                                Text(
                                                                  e.getTimeString(details.date, context),
                                                                  maxLines: 1,
                                                                  overflow: TextOverflow.ellipsis,
                                                                  style: context.bodySmall
                                                                      ?.textColor(isRequest || isDeclined ? context.inverseSurface : context.inverseSurface)
                                                                      .appFont(context)
                                                                      .copyWith(decoration: isDeclined ? TextDecoration.lineThrough : null),
                                                                ),
                                                              if (!e.isAllDay) SizedBox(height: 3),
                                                              Row(
                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                children: [
                                                                  VisirButton(
                                                                    type: e.isEvent ? VisirButtonAnimationType.none : VisirButtonAnimationType.scaleAndOpacity,
                                                                    style: VisirButtonStyle(
                                                                      clickMargin: EdgeInsets.all(4),
                                                                      width: e.isEvent ? 4 : 12,
                                                                      height: 12,
                                                                      margin: EdgeInsets.only(right: 6),
                                                                      backgroundColor: e.isEvent
                                                                          ? backgroundColor
                                                                          : e.status == TaskStatus.done
                                                                          ? e.isAllDay
                                                                                ? Colors.white
                                                                                : backgroundColor
                                                                          : Colors.transparent,
                                                                      borderRadius: BorderRadius.circular(4),
                                                                      border: e.isEvent ? null : Border.all(color: e.isAllDay ? Colors.white : nonAgendaForegroundColor, width: 1),
                                                                      hoverColor: e.isEvent
                                                                          ? null
                                                                          : e.status == TaskStatus.done
                                                                          ? null
                                                                          : e.isAllDay
                                                                          ? Colors.white.withValues(alpha: 0.5)
                                                                          : nonAgendaForegroundColor.withValues(alpha: 0.5),
                                                                    ),
                                                                    onTap: e.isEvent
                                                                        ? null
                                                                        : () {
                                                                            EasyThrottle.throttle('toggleTaskStatus${e.id}', Duration(milliseconds: 50), () {
                                                                              if (e.status == TaskStatus.none) logAnalyticsEvent(eventName: 'home_task_check_done');
                                                                              TaskAction.toggleStatus(
                                                                                task: e,
                                                                                startAt: e.editedStartTime ?? e.startAt,
                                                                                endAt: e.editedEndTime ?? e.endAt,
                                                                                tabType: widget.tabType,
                                                                              );
                                                                            });
                                                                          },
                                                                    child: e.isEvent
                                                                        ? null
                                                                        : e.status == TaskStatus.done
                                                                        ? VisirIcon(type: VisirIconType.taskCheck, size: 12, color: e.isAllDay ? backgroundColor : Colors.white)
                                                                        : null,
                                                                  ),

                                                                  Expanded(
                                                                    child: Text(
                                                                      '${e.title ?? 'New Event'}',
                                                                      maxLines: 1,
                                                                      overflow: TextOverflow.ellipsis,
                                                                      style: baseStyle!
                                                                          .textColor(
                                                                            e.isAllDay
                                                                                ? Colors.white
                                                                                : isRequest || isDeclined
                                                                                ? context.outlineVariant
                                                                                : context.outlineVariant,
                                                                          )
                                                                          .copyWith(
                                                                            decoration: isDeclined ? TextDecoration.lineThrough : null,
                                                                            textBaseline: TextBaseline.ideographic,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    );

                                                    if (e.isAllDay) {
                                                      return IntrinsicWidth(child: child);
                                                    }

                                                    return Container(width: double.infinity, child: child);
                                                  },
                                                )
                                              : LayoutBuilder(
                                                  builder: (context, constraints) {
                                                    if (isHideCell) return SizedBox.shrink();

                                                    if (e.isAllDay || isSpanned && !e.isAllDay) {
                                                      return Align(
                                                        alignment: Alignment.centerLeft,
                                                        child: Row(
                                                          children: [
                                                            if (!e.isEvent)
                                                              VisirButton(
                                                                type: VisirButtonAnimationType.scaleAndOpacity,
                                                                style: VisirButtonStyle(
                                                                  cursor: WidgetStateMouseCursor.clickable,
                                                                  margin: EdgeInsets.only(right: 4),
                                                                  width: checkboxSize,
                                                                  height: checkboxSize,
                                                                  clickMargin: EdgeInsets.all(4),
                                                                  hoverColor: e.status == TaskStatus.done ? null : nonAgendaForegroundColor.withValues(alpha: 0.5),
                                                                  backgroundColor: e.status == TaskStatus.done ? nonAgendaForegroundColor : null,
                                                                  borderRadius: BorderRadius.circular(4),
                                                                  border: e.status == TaskStatus.done ? null : Border.all(color: nonAgendaForegroundColor, width: 1),
                                                                ),
                                                                child: e.status == TaskStatus.done
                                                                    ? VisirIcon(type: VisirIconType.taskCheck, size: 8, color: Colors.white)
                                                                    : null,
                                                                onTap: () {
                                                                  EasyThrottle.throttle('toggleTaskStatus${e.id}', Duration(milliseconds: 50), () {
                                                                    if (e.status == TaskStatus.none) logAnalyticsEvent(eventName: 'home_task_check_done');
                                                                    TaskAction.toggleStatus(
                                                                      task: e,
                                                                      startAt: e.editedStartTime ?? e.startAt,
                                                                      endAt: e.editedEndTime ?? e.endAt,
                                                                      tabType: widget.tabType,
                                                                    );
                                                                  });
                                                                },
                                                              ),
                                                            Expanded(
                                                              child: Text(
                                                                isSpanned && !e.isAllDay
                                                                    ? '${e.title ?? 'New Event'} · ${e.getStartTimeString(details.date, context)} '
                                                                    : '${e.title ?? 'New Event'}',
                                                                overflow: constraints.maxWidth < 50 ? TextOverflow.clip : TextOverflow.ellipsis,
                                                                style: context.bodyMedium?.textColor(nonAgendaTextColor.withValues(alpha: 0.8)),
                                                                maxLines: 1,
                                                                strutStyle: StrutStyle(
                                                                  forceStrutHeight: true,
                                                                  height: context.bodyMedium?.height,
                                                                  fontSize: context.bodyMedium?.fontSize,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    }

                                                    return Align(
                                                      alignment: Alignment.topLeft,
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        mainAxisSize: MainAxisSize.max,
                                                        mainAxisAlignment: e.isAllDay ? MainAxisAlignment.center : MainAxisAlignment.start,
                                                        children: [
                                                          if (isShowStartTime)
                                                            Padding(
                                                              padding: EdgeInsets.only(bottom: startTimeBottomPadding),
                                                              child: Text(
                                                                e.getStartTimeString(details.date, context),
                                                                maxLines: 1,
                                                                overflow: constraints.maxWidth < 50 ? TextOverflow.clip : TextOverflow.ellipsis,
                                                                style: context.labelSmall
                                                                    ?.textColor(nonAgendaTextColor.withValues(alpha: 0.9))
                                                                    .appFont(context)
                                                                    .copyWith(decoration: isDeclined ? TextDecoration.lineThrough : null),
                                                              ),
                                                            ),
                                                          Text.rich(
                                                            TextSpan(
                                                              children: [
                                                                if (!e.isEvent)
                                                                  WidgetSpan(
                                                                    child: VisirButton(
                                                                      type: VisirButtonAnimationType.scaleAndOpacity,
                                                                      style: VisirButtonStyle(
                                                                        cursor: WidgetStateMouseCursor.clickable,
                                                                        margin: EdgeInsets.only(right: 4),
                                                                        width: checkboxSize,
                                                                        height: checkboxSize,
                                                                        clickMargin: EdgeInsets.all(4),
                                                                        hoverColor: e.status == TaskStatus.done ? null : nonAgendaForegroundColor.withValues(alpha: 0.5),
                                                                        backgroundColor: e.status == TaskStatus.done ? nonAgendaForegroundColor : null,
                                                                        borderRadius: BorderRadius.circular(4),
                                                                        border: e.status == TaskStatus.done ? null : Border.all(color: nonAgendaForegroundColor, width: 1),
                                                                      ),
                                                                      child: e.status == TaskStatus.done
                                                                          ? VisirIcon(type: VisirIconType.taskCheck, size: 8, color: Colors.white)
                                                                          : null,
                                                                      onTap: () {
                                                                        EasyThrottle.throttle('toggleTaskStatus${e.id}', Duration(milliseconds: 50), () {
                                                                          if (e.status == TaskStatus.none) logAnalyticsEvent(eventName: 'home_task_check_done');
                                                                          TaskAction.toggleStatus(
                                                                            task: e,
                                                                            startAt: e.editedStartTime ?? e.startAt,
                                                                            endAt: e.editedEndTime ?? e.endAt,
                                                                            tabType: widget.tabType,
                                                                          );
                                                                        });
                                                                      },
                                                                    ),
                                                                  ),
                                                                TextSpan(text: '${e.title ?? 'New Event'}'),
                                                                TextSpan(text: '\n'),
                                                                TextSpan(
                                                                  text: e.linkedEvent?.location ?? '',
                                                                  style: context.bodySmall?.textColor(nonAgendaTextColor.withValues(alpha: 0.9)),
                                                                ),
                                                              ],
                                                            ),
                                                            maxLines: max(
                                                              1,
                                                              min(
                                                                ((constraints.maxHeight -
                                                                            2 -
                                                                            (context.bodyMedium!.height! * context.textScaler.scale(context.bodyMedium!.fontSize!))) /
                                                                        (context.bodyMedium!.height! * context.textScaler.scale(context.bodyMedium!.fontSize!)))
                                                                    .floor(),
                                                                ((details.availableHeight -
                                                                        (context.labelSmall!.height! * context.textScaler.scale(context.bodyMedium!.fontSize! + 2))) ~/
                                                                    (context.bodyMedium!.height! * context.textScaler.scale(context.bodyMedium!.fontSize!))),
                                                              ),
                                                            ),
                                                            overflow: constraints.maxWidth < 50 ? TextOverflow.clip : TextOverflow.ellipsis,
                                                            style: context.bodyMedium
                                                                ?.textColor(nonAgendaTextColor.withValues(alpha: 0.8))
                                                                .copyWith(decoration: isDeclined ? TextDecoration.lineThrough : null),
                                                            strutStyle: StrutStyle(
                                                              forceStrutHeight: true,
                                                              height: context.bodyMedium?.height,
                                                              fontSize: context.bodyMedium?.fontSize,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),

                              if (e.conferenceLink != null && !isAgenda && constraints.maxWidth > 100 && constraints.maxHeight > 32)
                                Align(
                                  alignment: Alignment.topRight,
                                  child: VisirButton(
                                    type: VisirButtonAnimationType.scaleAndOpacity,
                                    style: VisirButtonStyle(width: 32, height: 32, padding: EdgeInsets.all(6), hoverColor: Colors.transparent, clickMargin: EdgeInsets.zero),
                                    onTap: () {
                                      Utils.launchUrlExternal(url: e.conferenceLink);
                                    },
                                    child: CircleAvatar(
                                      radius: 10,
                                      backgroundColor: backgroundColor,
                                      child: VisirIcon(type: VisirIconType.videoCall, size: 10, color: Colors.white, isSelected: true),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );

              return Expanded(
                child: isMobileView
                    ? VisirButton(
                        type: VisirButtonAnimationType.scaleAndOpacity,
                        style: VisirButtonStyle(hoverColor: Colors.transparent, clickMargin: EdgeInsets.zero),
                        onTap: () {
                          Utils.showPopupDialog(
                            child: e.isEvent
                                ? MobileCalendarEditWidget(
                                    tabType: widget.tabType,
                                    event: e.linkedEvent,
                                    selectedDate: details.date.add(Duration(hours: e.linkedEvent!.startDate.hour, minutes: e.linkedEvent!.startDate.minute)),
                                    linkedMessages: e.linkedMessages,
                                    linkedMails: e.linkedMails,
                                    calendarTaskEditSourceType: CalendarTaskEditSourceType.editOriginal,
                                  )
                                : MobileTaskEditWidget(
                                    task: e,
                                    selectedDate: details.date.add(Duration(hours: e.startAt!.hour, minutes: e.startAt!.minute)),
                                    tabType: widget.tabType,
                                    calendarTaskEditSourceType: CalendarTaskEditSourceType.editOriginal,
                                  ),
                          );
                        },
                        child: child,
                      )
                    : PopupMenu(
                        backgroundColor: Colors.transparent,
                        hideShadow: true,
                        forceShiftOffset: forceShiftOffsetForMenu,
                        popup: e.isEvent
                            ? CalenderSimpleCreateWidget(
                                tabType: widget.tabType,
                                event: e.linkedEvent,
                                linkedMessages: e.linkedMessages,
                                linkedMails: e.linkedMails,
                                selectedDate: details.date.add(Duration(hours: e.linkedEvent!.startDate.hour, minutes: e.linkedEvent!.startDate.minute)),
                                calendarTaskEditSourceType: CalendarTaskEditSourceType.editOriginal,
                              )
                            : TaskSimpleCreateWidget(
                                tabType: widget.tabType,
                                task: e,
                                selectedDate: details.date.add(Duration(hours: e.startAt!.hour, minutes: e.startAt!.minute)),
                                calendarTaskEditSourceType: CalendarTaskEditSourceType.editOriginal,
                              ),
                        type: ContextMenuActionType.tap,
                        location: PopupMenuLocation.right,
                        style: VisirButtonStyle(hoverColor: Colors.transparent, clickMargin: EdgeInsets.zero),
                        child: child,
                      ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget buildScheduleViewMonthHeader(BuildContext context, ScheduleViewMonthHeaderDetails details) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        child: Padding(
          padding: const EdgeInsets.only(top: 36, left: 54.0, right: 12, bottom: 12),
          child: Text(DateFormat.yMMM().format(details.date), style: context.titleLarge?.textColor(context.onBackground)),
        ),
      ),
    );
  }

  Widget buildMonthCell(BuildContext context, MonthCellDetails details) {
    return Container(
      child: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        decoration: BoxDecoration(
          border: Border.all(color: context.surface, width: 0.5, strokeAlign: BorderSide.strokeAlignOutside),
        ),
        child: Opacity(
          opacity: details.visibleDates[details.visibleDates.length ~/ 2].month == details.date.month ? 1 : 0.2,
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: DateUtils.isSameDay(details.date, DateTime.now()) ? EdgeInsets.symmetric(horizontal: 4, vertical: 3) : EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Container(
                    padding: DateUtils.isSameDay(details.date, DateTime.now()) ? EdgeInsets.symmetric(horizontal: 4, vertical: 1) : EdgeInsets.zero,
                    decoration: BoxDecoration(
                      color: (DateUtils.isSameDay(details.date, DateTime.now()) ? context.tertiary : Colors.transparent),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      details.date.day.toString(),
                      style: context.labelMedium?.textColor((DateUtils.isSameDay(details.date, DateTime.now()) ? context.onTertiary : context.outlineVariant)).appFont(context),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3.0),
                    child: Column(
                      children: [
                        Container(
                          height: 13,
                          child: ClipRect(
                            child: Wrap(
                              spacing: 3,
                              runSpacing: 3,
                              alignment: WrapAlignment.center,
                              children: details.appointments.map((e) {
                                if (e is TaskEntity) {
                                  final project = ref.read(
                                    projectListControllerProvider.select((p) => p.firstWhereOrNull((p) => p.isPointedProject(e)) ?? p.firstWhere((p) => p.isDefault)),
                                  );
                                  Color? backgroundColor = e.isEvent ? e.linkedEvent?.backgroundColor : project?.color;
                                  HSVColor hsvColor = HSVColor.fromColor(backgroundColor ?? context.primary);
                                  if (context.brightness == Brightness.light) {
                                    if (hsvColor.value > 0.7 && hsvColor.saturation >= 0.2 && hsvColor.saturation < 0.5) {
                                      hsvColor = hsvColor.withValue(0.7);
                                      backgroundColor = hsvColor.toColor();
                                    } else if (hsvColor.value > 0.5 && hsvColor.saturation < 0.2) {
                                      hsvColor = hsvColor.withValue(0.5);
                                      backgroundColor = hsvColor.toColor();
                                    }
                                  }
                                  return CircleAvatar(radius: 2.5, backgroundColor: backgroundColor);
                                }
                                return SizedBox.shrink();
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration get selectedDecoration => BoxDecoration(color: context.tertiary.withValues(alpha: 0.1));

  ScheduleViewSettings get scheduleViewSetting => ScheduleViewSettings(
    hideEmptyScheduleWeek: false,
    monthHeaderSettings: MonthHeaderSettings(height: 0),
    weekHeaderSettings: WeekHeaderSettings(
      weekTextStyle: context.titleLarge?.textColor(context.outlineVariant).appFont(context),
      height: 48 + context.titleLarge!.height! * context.textScaler.scale(context.titleLarge!.fontSize!),
    ),
    dayHeaderSettings: DayHeaderSettings(
      dayFormat: 'E',
      dayTextStyle: context.labelMedium?.textColor(context.inverseSurface).appFont(context),
      dateTextStyle: context.titleSmall?.textColor(context.outlineVariant).appFont(context),
    ),
  );

  DragAndDropSettings get dragAndDropSettings => DragAndDropSettings(indicatorTimeFormat: '', allowNavigation: false);

  TimeSlotViewSettings getTimeslotViewSettings(double value, bool showMobileUi) => TimeSlotViewSettings(
    timeInterval: Duration(hours: 1),
    timeIntervalHeight: value,
    timeTextStyle: context.bodySmall?.textColor(context.onSurface),
    timeIntervalWidth: 60,
    timeRulerSize: timeLabelWidth,
    timeFormat: 'h a',
    startHour: 0,
    endHour: 24,
    dayFormat: 'E',
  );

  MonthViewSettings getMonthViewSetting(int displayCount) => MonthViewSettings(
    showAgenda: false,
    dayFormat: 'E',
    appointmentDisplayCount: displayCount > 0 ? displayCount : 3,
    appointmentDisplayMode: MonthAppointmentDisplayMode.none,
    agendaViewHeight: ValueNotifier<double>(320),
    numberOfWeeksInView: kNumberOfWeeksInView,
  );

  void moveCalendar({required DateTime targetDate, DateTime? displayDate}) {
    ref.read(calendarDisplayDateProvider(widget.tabType).notifier).updateDate(CalendarDisplayType.sideMonth, targetDate);
    controller.setProperties(selectedDate: targetDate, tappedDate: targetDate, displayDate: displayDate ?? targetDate, changeKey: 'move');
    agendaController.setProperties(selectedDate: targetDate, tappedDate: targetDate, displayDate: displayDate ?? targetDate, changeKey: 'move');
  }

  bool isScrollAgenda = false;

  void doneScrollAgenda() {
    isScrollAgenda = false;
  }

  void onTap(CalendarTapDetails details, CalendarDisplayType type) {
    switch (details.targetElement) {
      case CalendarElement.appointment:
        break;
      case CalendarElement.calendarCell:
        ref.read(calendarDisplayDateProvider(widget.tabType).notifier).updateDate(type, details.date!);
        break;
      case CalendarElement.header:
      case CalendarElement.viewHeader:
      case CalendarElement.agenda:
      case CalendarElement.allDayPanel:
      case CalendarElement.moreAppointmentRegion:
      case CalendarElement.resourceHeader:
        break;
    }
  }

  void openDetailWidget(Offset offset, DateTime date, Offset? localOffset, TaskEntity task, Rect? appointmentRect, double timeLabelWidth) {
    if (task.isEvent) {
      final event = task.linkedEvent!;
      if (isMobileView) {
        Utils.showPopupDialog(
          child: MobileCalendarEditWidget(
            tabType: TabType.home,
            selectedDate: event.editedStartTime ?? event.startDate,
            event: event,
            linkedMails: task.linkedMails,
            linkedMessages: task.linkedMessages,
            calendarTaskEditSourceType: CalendarTaskEditSourceType.editOriginal,
          ),
        );
      } else {
        Size size = MediaQueryData.fromView(View.of(context)).size;
        double screenWidth = size.width;
        double screenHeight = size.height;
        double right = offset.dx + 8;
        double top = offset.dy + 8;
        double width = 300;
        double height = 0;

        if (right + width > screenWidth) {
          right = screenWidth - 16 - width;
        }
        if (top + height > screenHeight) {
          top = screenHeight - 16 - height;
        }

        if (appointmentRect != null) {
          if (appointmentRect.right + width + 10 + 16 > screenWidth) {
            right = appointmentRect.left - width - 10 - timeLabelWidth;
          } else {
            right = appointmentRect.right + 10 - timeLabelWidth;
          }

          top = appointmentRect.top;
        }

        if (appointmentRect != null && localOffset != null) {
          final ratio = Utils.ref.read(zoomRatioProvider);

          final anchorDiff = Rect.fromLTRB(
            appointmentRect.left - localOffset.dx,
            appointmentRect.top - localOffset.dy,
            appointmentRect.right - localOffset.dx,
            appointmentRect.bottom - localOffset.dy,
          );

          if (offset.dx + (anchorDiff.right + width + 10 + 16) * ratio > context.width) {
            right = offset.dx + (anchorDiff.left - width - 10 + timeLabelWidth) * ratio;
          } else {
            right = offset.dx + (anchorDiff.right + 10 + timeLabelWidth) * ratio;
          }

          top = offset.dy + (anchorDiff.top - ((event.isAllDay ? 2 : 0) + (event.isModifiable ? 38 : 2))) * ratio;
        }

        showContextMenu(
          topLeft: Offset(right - (appointmentRect?.width ?? 0), top),
          bottomRight: Offset(right, top + (appointmentRect?.height ?? 0)),
          context: context,
          child: CalenderSimpleCreateWidget(
            tabType: TabType.home,
            selectedDate: event.editedStartTime ?? event.startDate,
            event: event,
            linkedMails: task.linkedMails,
            linkedMessages: task.linkedMessages,
            calendarTaskEditSourceType: CalendarTaskEditSourceType.editOriginal,
          ),
          verticalPadding: 16.0,
          borderRadius: 6.0,
          width: width,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          clipBehavior: Clip.none,
          isPopupMenu: false,
          hideShadow: true,
        );
      }
    } else {
      if (isMobileView) {
        Utils.showPopupDialog(
          child: MobileTaskEditWidget(
            tabType: widget.tabType,
            task: task,
            selectedDate: task.editedStartTime ?? task.startDate,
            calendarTaskEditSourceType: CalendarTaskEditSourceType.editOriginal,
          ),
        );
      } else {
        Size size = MediaQueryData.fromView(View.of(context)).size;
        double screenWidth = size.width;
        double screenHeight = size.height;
        double right = offset.dx + 8;
        double top = offset.dy + 8;
        double width = 300;
        double height = 0;

        if (right + width > screenWidth) {
          right = screenWidth - 16 - width;
        }
        if (top + height > screenHeight) {
          top = screenHeight - 16 - height;
        }

        if (appointmentRect != null) {
          if (appointmentRect.right + width + 10 + 16 > screenWidth) {
            right = appointmentRect.left - width - 10 - timeLabelWidth;
          } else {
            right = appointmentRect.right + 10 - timeLabelWidth;
          }

          top = appointmentRect.top;
        }

        if (appointmentRect != null && localOffset != null) {
          final ratio = Utils.ref.read(zoomRatioProvider);

          final anchorDiff = Rect.fromLTRB(
            appointmentRect.left - localOffset.dx,
            appointmentRect.top - localOffset.dy,
            appointmentRect.right - localOffset.dx,
            appointmentRect.bottom - localOffset.dy,
          );

          if (offset.dx + (anchorDiff.right + width + 10 + 16) * ratio > context.width) {
            right = offset.dx + (anchorDiff.left - width - 10 + timeLabelWidth) * ratio;
          } else {
            right = offset.dx + (anchorDiff.right + 10 + timeLabelWidth) * ratio;
          }

          top = offset.dy + (anchorDiff.top - ((task.isAllDay ? 2 : 0) + 38)) * ratio;
        }

        showContextMenu(
          topLeft: Offset(right - (appointmentRect?.width ?? 0), top),
          bottomRight: Offset(right, top + (appointmentRect?.height ?? 0)),
          context: context,
          child: TaskSimpleCreateWidget(
            tabType: widget.tabType,
            task: task,
            selectedDate: task.editedStartTime ?? task.startDate,
            calendarTaskEditSourceType: CalendarTaskEditSourceType.editOriginal,
          ),
          verticalPadding: 16.0,
          borderRadius: 6.0,
          width: width,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          clipBehavior: Clip.none,
          isPopupMenu: false,
          hideShadow: true,
        );
      }
    }
  }

  void updateCalendarDatasource() {
    final user = ref.read(authControllerProvider).requireValue;
    final pref = ref.read(localPrefControllerProvider).value;
    if (pref == null) return;

    final tasks = ref.read(calendarTaskListControllerProvider(tabType: widget.tabType, displayType: CalendarDisplayType.sideMonth)).tasksOnView;
    final events = ref.read(calendarEventListControllerProvider(tabType: widget.tabType, displayType: CalendarDisplayType.sideMonth)).eventsOnView;
    final calendarHide = ref.read(calendarHideProvider(widget.tabType));

    final newEvents = events.where((e) {
      return !calendarHide.contains(e.calendarUniqueId) && pref.calendarOAuths?.any((o) => o.email == e.calendar.email && o.type.calendarType == e.calendar.type) == true;
    }).toList();

    CompletedTaskOptionType completedTaskOptionType = user.userCompletedTaskOptionType;
    final projectHide = ref.read(projectHideProvider(widget.tabType));

    List<TaskEntity> visibleTasks = tasks
        .where((t) => !projectHide.contains(t.projectId))
        .map((t) => completedTaskOptionType == CompletedTaskOptionType.show || t.status != TaskStatus.done ? t : t.copyWith(status: TaskStatus.cancelled))
        .toList();
    visibleTasks.removeWhere((t) => t.isEventDummyTask);
    final result = [
      ...newEvents.map(
        (e) => TaskEntity(
          startAt: e.startDate,
          endAt: e.endDate,
          linkedEvent: e,
          linkedMails: tasks.firstWhereOrNull((t) => t.linkedEvent?.eventId == e.eventId)?.linkedMails ?? [],
          linkedMessages: tasks.firstWhereOrNull((t) => t.linkedEvent?.eventId == e.eventId)?.linkedMessages ?? [],
        ),
      ),
      ...visibleTasks,
    ];

    // GC optimization: debounce datasource updates to reduce rebuilds
    _datasourceUpdateTimer?.cancel();
    _datasourceUpdateTimer = Timer(const Duration(milliseconds: 100), () {
      datasource.setTimeZone(timezone);
      agendaDatasource.setTimeZone(timezone);
      datasource.appointments = result;
      agendaDatasource.appointments = result;
      agendaDatasource.notifyListeners(CalendarDataSourceAction.reset, result);
      datasource.notifyListeners(CalendarDataSourceAction.reset, result);
      _datasourceUpdateTimer = null;
    });
  }

  ViewHeaderStyle getViewHeaderStyle(CalendarType type) => ViewHeaderStyle(
    dayTextStyle: type == CalendarType.month
        ? context.labelSmall?.textColor(context.inverseSurface).appFont(context).textBold
        : context.labelMedium?.textColor(context.inverseSurface).appFont(context).textBold,
    dateTextStyle: context.titleLarge?.textColor(context.outlineVariant).textBold.appFont(context),
  );

  bool showMobileUi = false;
  double minScale = 0;
  double lastScrollOffset = 0;

  // GC optimization: debounce timer for updateCalendarDatasource
  Timer? _datasourceUpdateTimer;

  double get maxScale => 300;

  void onViewChanged(ViewChangedDetails details) {
    ref.read(calendarDisplayDateProvider(widget.tabType).notifier).updateDate(CalendarDisplayType.sideMonth, details.visibleDates[details.visibleDates.length ~/ 2]);
  }

  void selectDateOnScrollMonthView(DateTime targetDate) {
    ref.read(calendarDisplayDateProvider(widget.tabType).notifier).updateDate(CalendarDisplayType.sideAgenda, targetDate);
  }

  void today() {
    setState(() {
      onDragCancel = false;
      onDragEdit = false;
    });

    final now = DateTime.now();
    final now15 = DateTime(now.year, now.month, now.day, now.hour, (now.minute ~/ 15) * 15);
    final user = ref.read(authControllerProvider).requireValue;

    if (controller.view == CalendarView.week && !(user.userWeekViewStartWeekday == 0)) {
      moveCalendar(
        targetDate: now15,
        displayDate: (now15).subtract(
          (DateTime.now()).weekday == 7
              ? Duration(days: (7 - (user.userWeekViewStartWeekday)).floor())
              : Duration(days: (now15.weekday - (user.userWeekViewStartWeekday) % 7).floor()),
        ),
      );
    } else {
      moveCalendar(targetDate: now15);
    }
  }

  Future<void> refresh() async {
    await ref.read(calendarListControllerProvider.notifier).load();
    await Future.wait(
      [
        ref.read(calendarTaskListControllerProvider(tabType: widget.tabType, displayType: CalendarDisplayType.sideMonth).notifier).refresh(showLoading: true, isChunkUpdate: true),
      ].whereType<Future>(),
    );
    initialLoaded = true;
  }

  void moveNext() {
    final targetMonth = ref.read(calendarDisplayDateProvider(widget.tabType).select((v) => v[CalendarDisplayType.sideMonth] ?? DateTime.now()));
    final targetDate = DateTime(targetMonth.year, targetMonth.month + 1, controller.selectedDate?.day ?? 1);
    final finalDate = targetDate.month == DateTime(targetMonth.year, targetMonth.month + 2).month
        ? DateTime(targetMonth.year, targetMonth.month + 2).subtract(Duration(days: 1))
        : targetDate;
    moveCalendar(targetDate: finalDate);
  }

  void movePrev() {
    final targetMonth = ref.read(calendarDisplayDateProvider(widget.tabType).select((v) => v[CalendarDisplayType.sideMonth] ?? DateTime.now()));
    final targetDate = DateTime(targetMonth.year, targetMonth.month - 1, controller.selectedDate?.day ?? 1);
    final finalDate = targetDate.month == targetMonth.month ? DateTime(targetMonth.year, targetMonth.month).subtract(Duration(days: 1)) : targetDate;
    moveCalendar(targetDate: finalDate);
  }

  bool movePrevDay() {
    final time = controller.getCurrentTargetedDisplayDate?.call();
    if (time != null && controller.displayDate != null) {
      moveCalendar(targetDate: DateUtils.dateOnly(controller.displayDate!).add(Duration(minutes: time.hour * 60 + time.minute)).subtract(Duration(days: 1)));
      return true;
    }
    return false;
  }

  bool moveNextDay() {
    final time = controller.getCurrentTargetedDisplayDate?.call();
    if (time != null && controller.displayDate != null) {
      moveCalendar(targetDate: DateUtils.dateOnly(controller.displayDate!).add(Duration(minutes: time.hour * 60 + time.minute)).add(Duration(days: 1)));
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final firstDayOfWeek = ref.watch(authControllerProvider.select((e) => e.requireValue.userFirstDayOfWeek));
    ref.listen(localPrefControllerProvider, (previous, next) {
      if (previous?.value?.notificationPayload != next.value?.notificationPayload) {
        return;
      }

      agendaController.setProperties(displayDate: null, view: CalendarView.schedule);
    });

    ref.listen(calendarHideProvider(widget.tabType), (prev, next) {
      updateCalendarDatasource();
    });

    ref.listen(projectHideProvider(widget.tabType), (prev, next) {
      updateCalendarDatasource();
    });

    ref.listen(calendarListControllerProvider, (prev, next) {
      if (prev?.keys.isNotEmpty != true && next.keys.isNotEmpty == true) {
        updateCalendarDatasource();
      }
    });

    ref.listen(calendarEventListControllerProvider(tabType: widget.tabType, displayType: CalendarDisplayType.sideMonth), (prev, next) {
      updateCalendarDatasource();
    });

    ref.listen(calendarTaskListControllerProvider(tabType: widget.tabType, displayType: CalendarDisplayType.sideMonth), (prev, next) {
      updateCalendarDatasource();
    });

    ref.listen(authControllerProvider, (prev, next) {
      updateCalendarDatasource();
    });

    ref.listen(calendarDisplayDateProvider(widget.tabType).select((e) => e[CalendarDisplayType.sideMonth]), (prev, next) {
      agendaController.setProperties(displayDate: next, selectedDate: next, tappedDate: next, changeKey: 'update');
    });

    ref.listen(calendarDisplayDateProvider(widget.tabType).select((e) => e[CalendarDisplayType.sideAgenda]), (prev, next) {
      controller.setProperties(displayDate: next, selectedDate: next, changeKey: 'update');
    });

    return Stack(
      children: [
        Positioned.fill(
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    color: context.background,
                    child: MainCalendarAppbar(
                      key: ValueKey(showMobileUi.toString()),
                      tabType: widget.tabType,
                      onSidebarButtonPressed: widget.onSidebarButtonPressed ?? () {},
                      onDateButtonPressed: (date) => moveCalendar(targetDate: date),
                      onAddButtonPressed: () {},
                      onTodayButtonPressed: today,
                      onRefreshButtonPressed: refresh,
                      onNextButtonPressed: moveNext,
                      onPrevButtonPressed: movePrev,
                      movePrevDay: movePrevDay,
                      moveNextDay: moveNextDay,
                      appbarType: CalendarAppBarType.side,
                      hideSearchButton: PlatformX.isDesktopView,
                      onCalendarTypeChanged: (type) {},
                    ),
                  ),
                ],
              ),

              Expanded(
                child: ResizableContainer(
                  direction: Axis.vertical,
                  children: [
                    ResizableChild(
                      size: ResizableSize.expand(min: PlatformX.isMobileView ? 140 : 260, max: PlatformX.isMobileView ? 300 : 320),
                      child: DesktopCard(
                        forceCard: true,
                        backgroundColor: context.background,
                        removeTopBorderRadius: true,
                        child: Padding(
                          padding: EdgeInsets.all(DesktopScaffold.cardPadding),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(DesktopScaffold.cardRadius),
                            child: SfCalendar(
                              key: ValueKey('sideCalendar' + firstDayOfWeek.toString() + DateTime.now().day.toString() + (timezone ?? '')),
                              timeZone: timezone,
                              firstDayOfWeek: firstDayOfWeek,
                              todayHighlightColor: context.tertiary,
                              todayTextStyle: context.bodyLarge?.textColor(context.onTertiary).appFont(context),
                              controller: controller,
                              dataSource: datasource,
                              headerHeight: 0,
                              view: CalendarView.month,
                              initialDisplayDate: intiialCalendarDisplayTime,
                              initialSelectedDate: initialCalendarDateTime,
                              selectionDecoration: selectedDecoration,
                              showWeekNumber: false,
                              allowDragAndDrop: false,
                              allowAppointmentResize: false,
                              viewHeaderStyle: getViewHeaderStyle(CalendarType.month),
                              appointmentBuilder: (context, details) => buildAppointment(context, details, false),
                              monthViewSettings: getMonthViewSetting(0),
                              scheduleViewSettings: scheduleViewSetting,
                              scheduleViewMonthHeaderBuilder: buildScheduleViewMonthHeader,
                              monthCellBuilder: (context, details) => buildMonthCell(context, details),
                              onTap: (details) => onTap(details, CalendarDisplayType.sideMonth),
                              onViewChanged: (details) => onViewChanged(details),
                            ),
                          ),
                        ),
                      ),
                      divider: ResizableDivider(thickness: DesktopScaffold.cardPadding, color: Colors.transparent),
                    ),

                    ResizableChild(
                      size: ResizableSize.expand(),
                      child: DesktopCard(
                        forceCard: true,
                        backgroundColor: context.background,
                        removeBottomBorderRadius: true,
                        child: SfCalendar(
                          key: ValueKey('sideAgenda' + firstDayOfWeek.toString() + DateTime.now().day.toString() + (timezone ?? '')),
                          timeZone: timezone,
                          firstDayOfWeek: firstDayOfWeek,
                          todayHighlightColor: context.tertiary,
                          todayTextStyle: context.bodyLarge?.textColor(context.onTertiary).appFont(context),
                          controller: agendaController,
                          dataSource: agendaDatasource,
                          headerHeight: 0,
                          view: CalendarView.schedule,
                          initialDisplayDate: intiialCalendarDisplayTime,
                          initialSelectedDate: initialCalendarDateTime,
                          selectionDecoration: selectedDecoration,
                          showWeekNumber: false,
                          allowDragAndDrop: false,
                          allowAppointmentResize: false,
                          viewHeaderStyle: getViewHeaderStyle(CalendarType.month),
                          appointmentBuilder: (context, details) => buildAppointment(context, details, true),
                          scheduleViewSettings: scheduleViewSetting,
                          selectDateOnScrollAgendaView: (date) => selectDateOnScrollMonthView(date),
                        ),
                      ),
                      divider: const ResizableDivider(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CalendarDataSource extends CalendarDataSource<TaskEntity?> {
  String? _timeZone;

  _CalendarDataSource(List<TaskEntity> source, {String? timeZone}) {
    appointments = source;
    _timeZone = timeZone;
  }

  void setTimeZone(String? timeZone) {
    _timeZone = timeZone;
  }

  @override
  Object? getId(int index) {
    final task = (appointments![index] as TaskEntity);
    if (task.isEvent) return '${task.linkedEvent!.uniqueId}';
    return '${task.id}-${task.editedStartTime?.year}-${task.editedStartTime?.month}-${task.editedStartTime?.day}';
  }

  @override
  DateTime getStartTime(int index) {
    final task = (appointments![index] as TaskEntity);
    if (task.isEvent) return task.linkedEvent!.editedStartTime ?? task.linkedEvent!.startDate;
    if (task.isCancelled) return DateTime(0);
    return task.editedStartTime ?? task.startAt ?? DateTime(0);
  }

  @override
  DateTime getEndTime(int index) {
    final task = (appointments![index] as TaskEntity);
    DateTime endDate;
    if (task.isEvent) {
      final event = task.linkedEvent!;
      endDate = event.editedEndTime ?? event.endDate;

      if (event.isAllDay) {
        if (DateUtils.isSameDay(event.endDate, event.startDate)) {
          endDate = endDate.add(Duration(days: 1));
        }

        endDate = DateUtils.dateOnly(endDate).subtract(Duration(hours: 1));
      }

      if (!endDate.isAfter(getStartTime(index))) {
        if (event.isAllDay) {
          endDate = getStartTime(index).add(Duration(days: 1)).subtract(Duration(hours: 1));
        } else {
          endDate = getStartTime(index).add(Duration(hours: 1));
        }
      }
    } else {
      if (task.isCancelled) return DateTime(0);
      endDate = task.editedEndTime ?? task.endDate;
      if (task.isAllDay) {
        if (DateUtils.isSameDay(task.endDate, task.startDate)) {
          endDate = endDate.add(Duration(days: 1));
        }

        endDate = DateUtils.dateOnly(endDate).subtract(Duration(hours: 1));
      }

      if (!endDate.isAfter(getStartTime(index))) {
        if (task.isAllDay) {
          endDate = getStartTime(index).add(Duration(days: 1)).subtract(Duration(hours: 1));
        } else {
          endDate = getStartTime(index).add(Duration(hours: 1));
        }
      }
    }

    if (endDate.isBefore(getStartTime(index).add(Duration(minutes: 30)))) {
      endDate = getStartTime(index).add(Duration(minutes: 30));
    }

    return endDate;
  }

  @override
  String getSubject(int index) {
    final task = (appointments![index] as TaskEntity);
    if (task.isEvent) return task.linkedEvent!.title ?? 'New Event';
    return task.title ?? 'New Task';
  }

  @override
  Color getColor(int index) {
    final task = (appointments![index] as TaskEntity);
    if (task.isEvent) return task.linkedEvent?.backgroundColor ?? Colors.transparent;
    return task.color ?? Colors.transparent;
  }

  @override
  String? getRecurrenceRule(int index) {
    return null;
  }

  @override
  List<DateTime>? getRecurrenceExceptionDates(int index) {
    return null;
  }

  @override
  Object? getRecurrenceId(int index) {
    final task = (appointments![index] as TaskEntity);
    if (task.isEvent) return task.linkedEvent!.recurringEventId;
    return task.recurringTaskId;
  }

  @override
  bool isAllDay(int index) {
    final task = (appointments![index] as TaskEntity);
    if (task.isEvent) return task.linkedEvent!.isAllDay;
    return task.isAllDay;
  }

  @override
  String? getStartTimeZone(int index) {
    // Return calendar timezone to prevent unnecessary conversion - dates are already in local time
    // If timezone matches, convertTimeToAppointmentTimeZone will return date as-is
    return _timeZone;
  }

  @override
  String? getEndTimeZone(int index) {
    // Return calendar timezone to prevent unnecessary conversion - dates are already in local time
    // If timezone matches, convertTimeToAppointmentTimeZone will return date as-is
    return _timeZone;
  }

  @override
  Future<void> handleLoadMore(DateTime startDate, DateTime endDate) {
    return super.handleLoadMore(startDate, endDate);
  }

  @override
  TaskEntity? convertAppointmentToObject(Object? customData, Appointment appointment) {
    if (customData == null) return null;
    TaskEntity task = customData as TaskEntity;
    if (task.isEvent) {
      return task.copyWith(
        editedStartTime: appointment.startTime,
        editedEndTime: appointment.endTime,
        linkedEvent: task.linkedEvent?.copyWith(editedStartTime: appointment.startTime, editedEndTime: appointment.endTime),
      );
    } else {
      return task.copyWith(editedStartTime: appointment.startTime, editedEndTime: appointment.endTime);
    }
  }
}
