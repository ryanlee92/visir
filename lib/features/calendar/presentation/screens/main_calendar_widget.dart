import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:math';

import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/calendar/calendar.dart';
import 'package:Visir/dependency/calendar/src/calendar/appointment_engine/appointment_helper.dart';
import 'package:Visir/dependency/calendar/src/calendar/appointment_layout/appointment_layout.dart';
import 'package:Visir/dependency/contextmenu/contextmenu.dart';
import 'package:Visir/dependency/pinch_scale/pinch_scale.dart';
import 'package:Visir/dependency/showcase_tutorial/src/enum.dart';
import 'package:Visir/dependency/toasty_box/model/toast_model.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/auth/domain/entities/user_entity.dart';
import 'package:Visir/features/calendar/actions.dart';
import 'package:Visir/features/calendar/application/calendar_event_list_controller.dart';
import 'package:Visir/features/calendar/application/calendar_list_controller.dart';
import 'package:Visir/features/calendar/domain/entities/calendar_entity.dart';
import 'package:Visir/features/calendar/presentation/screens/main_calendar_appbar.dart';
import 'package:Visir/features/calendar/presentation/widgets/calendar_allday_more_widget.dart';
import 'package:Visir/features/calendar/presentation/widgets/calendar_simple_create_widget.dart';
import 'package:Visir/features/calendar/presentation/widgets/mobile_calendar_edit_widget.dart';
import 'package:Visir/features/calendar/providers.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/color_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/date_time_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/list_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/log_event.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/desktop_scaffold.dart';
import 'package:Visir/features/common/presentation/widgets/diagonal_stripes_paint.dart';
import 'package:Visir/features/common/presentation/widgets/fgbg_detector.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/presentation/widgets/showcase_wrapper.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/common/presentation/widgets/tourlist_widget.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/inbox/application/inbox_conversation_summary_controller.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_entity.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_suggestion_entity.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/domain/entities/local_pref_entity.dart' show InboxLastCreateEventType;
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:Visir/features/preference/presentation/screens/preference_screen.dart';
import 'package:Visir/features/task/actions.dart';
import 'package:Visir/features/task/application/calendar_task_list_controller.dart';
import 'package:Visir/features/task/application/project_list_controller.dart';
import 'package:Visir/features/task/domain/entities/task_entity.dart';
import 'package:Visir/features/task/presentation/widgets/mobile_task_edit_widget.dart';
import 'package:Visir/features/task/presentation/widgets/mobile_task_or_event_switcher_widget.dart';
import 'package:Visir/features/task/presentation/widgets/simple_task_or_event_switcher_widget.dart';
import 'package:Visir/features/task/presentation/widgets/task_simple_create_widget.dart';
import 'package:Visir/features/time_saved/actions.dart';
import 'package:collection/collection.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

enum CalendarType { day, twoDays, threeDays, fourDays, fiveDays, sixDays, week, month }

extension TaskCalendarTypeX on CalendarType {
  String getTitle(BuildContext context) {
    switch (this) {
      case CalendarType.day:
        return context.tr.calendar_configuration_day;
      case CalendarType.twoDays:
        return context.tr.calendar_configuration_2_days;
      case CalendarType.threeDays:
        return context.tr.calendar_configuration_3_days;
      case CalendarType.fourDays:
        return context.tr.calendar_configuration_4_days;
      case CalendarType.fiveDays:
        return context.tr.calendar_configuration_5_days;
      case CalendarType.sixDays:
        return context.tr.calendar_configuration_6_days;
      case CalendarType.week:
        return context.tr.calendar_configuration_week;
      case CalendarType.month:
        return context.tr.calendar_configuration_month;
    }
  }

  CalendarView get calendarView {
    switch (this) {
      case CalendarType.day:
        return CalendarView.day;
      case CalendarType.twoDays:
        return CalendarView.twoDays;
      case CalendarType.threeDays:
        return CalendarView.threeDays;
      case CalendarType.fourDays:
        return CalendarView.fourDays;
      case CalendarType.fiveDays:
        return CalendarView.fiveDays;
      case CalendarType.sixDays:
        return CalendarView.sixDays;
      case CalendarType.week:
        return CalendarView.week;
      case CalendarType.month:
        return CalendarView.month;
    }
  }

  VisirIconType get taskeyIconType {
    switch (this) {
      case CalendarType.day:
        return VisirIconType.one;
      case CalendarType.twoDays:
        return VisirIconType.two;
      case CalendarType.threeDays:
        return VisirIconType.three;
      case CalendarType.fourDays:
        return VisirIconType.four;
      case CalendarType.fiveDays:
        return VisirIconType.five;
      case CalendarType.sixDays:
        return VisirIconType.six;
      case CalendarType.week:
        return VisirIconType.seven;
      case CalendarType.month:
        return VisirIconType.month;
    }
  }

  VisirIcon getVisirIcon({required double size}) {
    switch (this) {
      case CalendarType.day:
        return VisirIcon(type: VisirIconType.one, size: size);
      case CalendarType.twoDays:
        return VisirIcon(type: VisirIconType.two, size: size);
      case CalendarType.threeDays:
        return VisirIcon(type: VisirIconType.three, size: size);
      case CalendarType.fourDays:
        return VisirIcon(type: VisirIconType.four, size: size);
      case CalendarType.fiveDays:
        return VisirIcon(type: VisirIconType.five, size: size);
      case CalendarType.sixDays:
        return VisirIcon(type: VisirIconType.six, size: size);
      case CalendarType.week:
        return VisirIcon(type: VisirIconType.seven, size: size);
      case CalendarType.month:
        return VisirIcon(type: VisirIconType.month, size: size);
    }
  }

  String get count {
    switch (this) {
      case CalendarType.day:
        return '1';
      case CalendarType.twoDays:
        return '2';
      case CalendarType.threeDays:
        return '3';
      case CalendarType.fourDays:
        return '4';
      case CalendarType.fiveDays:
        return '5';
      case CalendarType.sixDays:
        return '6';
      case CalendarType.week:
        return '7';
      case CalendarType.month:
        return 'Month';
    }
  }

  LogicalKeyboardKey get shortcut {
    switch (this) {
      case CalendarType.day:
        return LogicalKeyboardKey.digit1;
      case CalendarType.twoDays:
        return LogicalKeyboardKey.digit2;
      case CalendarType.threeDays:
        return LogicalKeyboardKey.digit3;
      case CalendarType.fourDays:
        return LogicalKeyboardKey.digit4;
      case CalendarType.fiveDays:
        return LogicalKeyboardKey.digit5;
      case CalendarType.sixDays:
        return LogicalKeyboardKey.digit6;
      case CalendarType.week:
        return LogicalKeyboardKey.digit7;
      case CalendarType.month:
        return LogicalKeyboardKey.keyM;
    }
  }

  LogicalKeyboardKey? get subshortcut {
    switch (this) {
      case CalendarType.day:
        return null;
      case CalendarType.twoDays:
        return null;
      case CalendarType.threeDays:
        return null;
      case CalendarType.fourDays:
        return null;
      case CalendarType.fiveDays:
        return null;
      case CalendarType.sixDays:
        return null;
      case CalendarType.week:
        return LogicalKeyboardKey.keyW;
      case CalendarType.month:
        return null;
    }
  }
}

final double kMobileUIBreakpoint = 448;

class MainCalendarWidget extends ConsumerStatefulWidget {
  final TabType tabType;
  final bool isPopup;
  final void Function()? onSidebarButtonPressed;
  final void Function({required Offset globalPosition, required TaskEntity task})? onDragUpdate;
  final void Function()? onDragEnd;
  final Color? backgroundColor;

  const MainCalendarWidget({super.key, required this.tabType, required this.isPopup, this.onSidebarButtonPressed, this.onDragUpdate, this.onDragEnd, this.backgroundColor});

  @override
  ConsumerState createState() => MainCalendarWidgetState();
}

class MainCalendarWidgetState extends ConsumerState<MainCalendarWidget> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  CalendarController controller = CalendarController();
  _CalendarDataSource datasource = _CalendarDataSource([]);

  String? get timezone => ref.read(defaultTimezoneProvider) ?? ref.read(timezoneProvider).value;

  DateTime? modifyStartDateTime;
  DateTime? modifyEndDateTime;
  bool? modifyIsAllDay;
  Duration modifyStartTimeDurationDifference = Duration.zero;

  DateTime initialCalendarDateTime = DateTime.now();
  DateTime intiialCalendarDisplayTime = DateTime.now();

  late Timer refreshTimer;

  OverlayEntry? simpleCreateOverlayEntry;
  bool initialLoaded = false;

  GlobalKey calendarKey = GlobalKey();
  GlobalKey sfCalendarKey = GlobalKey();

  GlobalKey editAreaGlobalKey = GlobalKey();
  GlobalKey cancelAreaGlobalKey = GlobalKey();

  bool onDragEdit = false;
  bool onDragCancel = false;

  String? _nextScheduleTaskId;
  String? _nextScheduleEventId;

  double timeLabelWidth = 60;
  double? prevTimeIntervalHeight;

  bool get isSignedIn => ref.read(isSignedInProvider);

  @override
  void initState() {
    super.initState();

    if (PlatformX.isMobile) {
      _checkForWidgetLaunch();
      HomeWidget.widgetClicked.listen((Uri? uri) => Utils.handleHomeWidgetClick(uri));
    }

    final user = ref.read(authControllerProvider).requireValue;

    final now = DateTime.now();
    final now15 = DateTime(now.year, now.month, now.day, now.hour, (now.minute ~/ 15 + 1) * 15);

    final initialCalendarType = ref.read(calendarTypeChangerProvider(widget.tabType));
    if (initialCalendarType == CalendarType.week && !(user.weekViewStartWeekday == 0 || user.weekViewStartWeekday == null)) {
      intiialCalendarDisplayTime = (now15).subtract(
        (DateTime.now()).weekday == 7
            ? Duration(days: (7 - (user.weekViewStartWeekday!)).floor())
            : Duration(days: (intiialCalendarDisplayTime.weekday - (user.weekViewStartWeekday!) % 7).floor()),
      );
    } else {
      initialCalendarDateTime = now15;
      intiialCalendarDisplayTime = now15;
    }

    controller.onRefresh = () async {
      await refresh();
    };

    controller.onControlScrollWheel = (offset) {
      final ratio = controller.getCurrentScrollPositionRatio?.call();
      final prevScale = ref.read(calendarIntervalScaleProvider(widget.tabType));
      ref.read(calendarIntervalScaleProvider(widget.tabType).notifier).updateScale(min(max(minScale, prevScale + ((offset ?? 0) < 0 ? 3 : -3)), maxScale));
      if (ratio == null) return;
      controller.setCurrentScrollPositionRatio?.call(ratio);
    };

    refreshTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      updateDefaultCreationData();
      onShowcaseOnListener();
      updateCalendarDatasource();
    });

    isShowcaseOn.addListener(onShowcaseOnListener);

    if (!isSignedIn) {
      initialCalendarDateTime = onboardingTargetTime;
      intiialCalendarDisplayTime = onboardingTargetTime;
    }
  }

  @override
  void dispose() {
    refreshTimer.cancel();
    isShowcaseOn.removeListener(onShowcaseOnListener);
    super.dispose();
  }

  DateTime get onboardingTargetTime => DateTime(2025, 9, 13, 20, 30).add(dateOffset);

  String? prevIsShowcaseOn = null;

  void onShowcaseOnListener() {
    if ((PlatformX.isMobileView && widget.tabType != TabType.calendar) || (PlatformX.isDesktopView && widget.tabType != TabType.home)) return;
    if (prevIsShowcaseOn == isShowcaseOn.value) return;

    final targetTime = onboardingTargetTime;
    if (isShowcaseOn.value == taskOnCalendarShowcaseKeyString) {
      moveCalendar(targetDate: targetTime, displayDate: targetTime);
      prevIsShowcaseOn = isShowcaseOn.value;
      return;
    }

    if (isShowcaseOn.value == taskLinkedMailShowcaseKeyString || (isShowcaseOn.value == taskLinkedMailDetailShowcaseKeyString && TourListWidget.isOpened)) {
      // ref.read(resizableClosableWidgetProvider(widget.tabType).notifier).setWidget(null);
      moveCalendar(targetDate: targetTime, displayDate: targetTime);

      Navigator.of(Utils.mainContext).popUntil((route) => route.isFirst);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (PlatformX.isDesktopView) {
          Timer.periodic(Duration(milliseconds: 500), (timer) {
            final popupState = (taskOnCalendarShowcaseKey2.currentState as PopupMenuState?);
            if (popupState != null) {
              timer.cancel();
              popupState.showPopup();
            }
          });
        }

        if (PlatformX.isMobileView) {
          Timer.periodic(Duration(milliseconds: 500), (timer) {
            final buttonState = (taskOnCalendarShowcaseKey2.currentState as VisirButtonState?);
            if (buttonState != null) {
              timer.cancel();
              buttonState.onTap();
            }
          });
        }
      });

      prevIsShowcaseOn = isShowcaseOn.value;
      return;
    }

    if (isShowcaseOn.value == taskLinkedChatShowcaseKeyString || (isShowcaseOn.value == taskLinkedChatDetailShowcaseKeyString && TourListWidget.isOpened)) {
      moveCalendar(targetDate: targetTime, displayDate: targetTime);

      Navigator.of(Utils.mainContext).popUntil((route) => route.isFirst);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (PlatformX.isDesktopView) {
          Timer.periodic(Duration(milliseconds: 500), (timer) {
            final popupState = (eventOnCalendarShowcaseKey.currentState as PopupMenuState?);
            if (popupState != null) {
              timer.cancel();
              popupState.showPopup();
            }
          });
        }

        if (PlatformX.isMobileView) {
          Timer.periodic(Duration(milliseconds: 500), (timer) {
            final buttonState = (eventOnCalendarShowcaseKey.currentState as VisirButtonState?);
            if (buttonState != null) {
              timer.cancel();
              buttonState.onTap();
            }
          });
        }
        prevIsShowcaseOn = isShowcaseOn.value;
      });

      prevIsShowcaseOn = isShowcaseOn.value;
      return;
    }
  }

  /// Checks if the App was initially launched via the Widget
  void _checkForWidgetLaunch() {
    if (!PlatformX.isMobile) return;
    HomeWidget.initiallyLaunchedFromHomeWidget().then((uri) => Utils.handleHomeWidgetClick(uri));
  }

  void logHomeViewChangeEvent(CalendarType type) {
    logAnalyticsEvent(eventName: 'home_view_change', properties: {'view': type.getTitle(context)});
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

  void onTaskDragStart(TaskEntity task) {}

  void onTaskDragUpdate(TaskEntity task, Offset offset) {
    final user = ref.read(authControllerProvider).requireValue;

    int taskDefaultDurationInMinutes = user.userTaskDefaultDurationInMinutes;

    RenderBox? box = calendarKey.currentContext?.findRenderObject() as RenderBox?;
    Offset position = box?.localToGlobal(Offset.zero) ?? Offset.zero;
    final ratio = Utils.ref.read(zoomRatioProvider);

    final finalPosition = offset - position / ratio;
    if (finalPosition.dy < 0) {
      controller.endDragInboxShadow?.call();
      return;
    }

    final lastUsedProjectId = ref.read(lastUsedProjectIdProvider).firstOrNull;
    final lastUsedProject = lastUsedProjectId == null ? null : ref.read(projectListControllerProvider).firstWhereOrNull((e) => e.isPointedProjectId(lastUsedProjectId));
    final defaultProject = ref.read(projectListControllerProvider).firstWhereOrNull((e) => e.isDefault);
    final suggestedProject = task.projectId == null ? null : ref.read(projectListControllerProvider).firstWhereOrNull((e) => e.isPointedProjectId(task.projectId));
    final color = suggestedProject?.color ?? lastUsedProject?.color ?? defaultProject?.color;

    controller.showDragInboxShadow?.call(offset - position / ratio, Duration(minutes: taskDefaultDurationInMinutes), color ?? context.primary, (anchorOffset) {}, task.title);
  }

  void onTaskDragEnd(TaskEntity task) {
    bool isLinkedWithMail = task.linkedMails.isNotEmpty;
    bool isLinkedWithMessage = task.linkedMessages.isNotEmpty;
    DateTime? date = controller.getInboxDragDatetime?.call();
    bool? isAllDay = controller.getInboxDragIsAllDay?.call();

    if (date != null && isAllDay != null) {
      final user = ref.read(authControllerProvider).requireValue;
      final endAt = isAllDay == true ? date : date.add(Duration(minutes: user.userTaskDefaultDurationInMinutes));
      // final ratio = Utils.ref.read(zoomRatioProvider);

      final newTask = task.copyWith(startAt: date, endAt: endAt, isAllDay: isAllDay, status: task.status == TaskStatus.braindump ? TaskStatus.none : null);

      TaskAction.upsertTask(
        task: newTask,
        originalTask: task,
        calendarTaskEditSourceType: CalendarTaskEditSourceType.drag,
        tabType: widget.tabType,
        isLinkedWithMails: isLinkedWithMail,
        isLinkedWithMessages: isLinkedWithMessage,
      );

      controller.endDragInboxShadow?.call();
    } else {
      controller.endDragInboxShadow?.call();
    }
  }

  void setInboxInitialCalendarScale(double value) {
    ref.read(calendarIntervalScaleProvider(widget.tabType).notifier).updateScale(value);
  }

  Widget? showcaseTargetTask;
  Widget? showcaseTargetEvent;

  Widget buildTaskView(TaskEntity e, {required bool isMonth, required double height, required double width, required DateTime date, double? availableHeight, Rect? bounds}) {
    final userId = ref.read(authControllerProvider.select((v) => v.requireValue.id));
    final project = ref.read(projectListControllerProvider.select((p) => p.firstWhereOrNull((p) => p.isPointedProject(e)) ?? p.firstWhereOrNull((p) => p.uniqueId == userId)));
    if (project == null) return SizedBox.shrink();
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

      if (isMonth) {
        nonAgendaTextColor = hsvColor.withSaturation(0.1).withValue(1).toColor();
      } else {
        nonAgendaTextColor = hsvColor.withSaturation(0.2).withValue(1).toColor();
      }
    } else {
      if (hsvColor.hue > 0.4 && hsvColor.hue < 0.95 && hsvColor.value > 0.7 && hsvColor.saturation >= 0.5) {
        hsvColor = hsvColor.withValue(0.7);
        nonAgendaTextColor = hsvColor.toColor();
      }

      if (isMonth) {
        nonAgendaTextColor = hsvColor.withSaturation(0.95).withValue(0.3).toColor();
      } else {
        nonAgendaTextColor = hsvColor.withSaturation(0.95).withValue(0.3).toColor();
      }
    }

    final showTimeRatherThanLine = isMonth && !e.isAllDay;

    final actualStartTime = e.startAt ?? e.linkedEvent?.editedStartTime ?? e.linkedEvent?.startDate;
    final actualEndTime = e.endAt ?? e.linkedEvent?.editedEndTime ?? e.linkedEvent?.endDate;

    if (actualStartTime == null || actualEndTime == null) return SizedBox.shrink();

    final isSpanned =
        !(actualEndTime.day == actualStartTime.day && actualEndTime.month == actualStartTime.month && actualEndTime.year == actualStartTime.year) &&
        AppointmentHelper.getDifference(actualStartTime, actualEndTime).inDays > 0;

    double checkboxSize = context.bodyLarge!.height! * context.bodyLarge!.fontSize! - 2;

    double leftPadding = 4;
    double topPadding = !isMonth ? 2 : 0;

    final isRequest = e.isRequest && !isMonth;
    final isDeclined = e.linkedEvent?.isDeclined == true;
    final isMaybe = e.linkedEvent?.isMaybe == true;

    double startTimeBottomPadding = 0;

    Color base = showTimeRatherThanLine ? Colors.transparent : nonAgendaBackgroundColor;

    Widget child = RepaintBoundary(
      child: Container(
        height: height,
        constraints: BoxConstraints(minHeight: 18),
        alignment: isMonth ? Alignment.centerLeft : null,
        child: Stack(
          children: [
            if (isMaybe)
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
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double maxHeight = constraints.maxHeight - (isRequest || isDeclined || e.isAllDay ? 0 : topPadding);
                      // double maxWidth = constraints.maxWidth - (leftPadding + rightPadding);

                      bool isHideCell = maxHeight < (context.bodyLarge!.height! * context.textScaler.scale(context.bodyLarge!.fontSize!));
                      bool isShowStartTime =
                          maxHeight >
                          (context.bodyLarge!.height! * context.textScaler.scale(context.bodyLarge!.fontSize!)) +
                              (context.labelSmall!.height! * context.textScaler.scale(context.labelSmall!.fontSize!)) +
                              2;

                      return Stack(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: leftPadding, right: 2, top: isRequest || isDeclined || e.isAllDay ? 0 : topPadding),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                if (isHideCell) return SizedBox.shrink();

                                if (e.isAllDay || isSpanned) {
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
                                            child: e.status == TaskStatus.done ? VisirIcon(type: VisirIconType.taskCheck, size: checkboxSize * 2 / 3, color: Colors.white) : null,
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
                                          )
                                        else if (e.editedStartDateOnly.isBefore(date))
                                          Container(
                                            width: 4,
                                            margin: EdgeInsets.only(right: 4),
                                            height: checkboxSize,
                                            child: CustomPaint(
                                              painter: ArrowPainter(color: nonAgendaForegroundColor, strokeWidth: 3, direction: ArrowDirction.left),
                                            ),
                                          )
                                        else
                                          Container(
                                            width: 4,
                                            margin: EdgeInsets.only(right: 4),
                                            height: checkboxSize,
                                            decoration: BoxDecoration(color: nonAgendaForegroundColor, borderRadius: BorderRadius.circular(2)),
                                          ),
                                        Expanded(
                                          child: Text(
                                            isSpanned && !e.isAllDay ? '${e.title ?? 'New Event'} · ${e.getStartTimeString(date, context)} ' : '${e.title ?? 'New Event'}',
                                            softWrap: false,
                                            overflow: TextOverflow.ellipsis,
                                            style: context.bodyLarge?.textColor(nonAgendaTextColor.withValues(alpha: 0.8)),
                                            maxLines: 1,
                                            strutStyle: StrutStyle(forceStrutHeight: true, height: context.bodyLarge?.height, fontSize: context.bodyLarge?.fontSize),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                return Align(
                                  alignment: isMonth ? Alignment.centerLeft : Alignment.topLeft,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: isMonth || e.isAllDay ? MainAxisAlignment.center : MainAxisAlignment.start,
                                    children: [
                                      if (isShowStartTime)
                                        Padding(
                                          padding: EdgeInsets.only(bottom: startTimeBottomPadding),
                                          child: Text(
                                            e.getStartTimeString(date, context),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: false,
                                            style: context.bodySmall
                                                ?.textColor(nonAgendaTextColor.withValues(alpha: 0.9))
                                                .appFont(context)
                                                .copyWith(decoration: isDeclined ? TextDecoration.lineThrough : null),
                                          ),
                                        ),
                                      Text.rich(
                                        TextSpan(
                                          children: [
                                            if (showTimeRatherThanLine)
                                              TextSpan(
                                                text: e.startDate.timeString + '  ',
                                                style: TextStyle(color: nonAgendaForegroundColor).appFont(context),
                                              ),
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
                                                      ? VisirIcon(type: VisirIconType.taskCheck, size: checkboxSize * 2 / 3, color: Colors.white)
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
                                              )
                                            else
                                              WidgetSpan(
                                                child: Container(
                                                  width: 4,
                                                  margin: EdgeInsets.only(right: 4),
                                                  height: checkboxSize,
                                                  decoration: BoxDecoration(color: nonAgendaForegroundColor, borderRadius: BorderRadius.circular(2)),
                                                ),
                                              ),

                                            TextSpan(
                                              text: isSpanned && !e.isAllDay ? '${e.title ?? 'New Event'} · ${e.getStartTimeString(date, context)} ' : '${e.title ?? 'New Event'}',
                                            ),
                                            TextSpan(text: '\n'),
                                            TextSpan(text: e.linkedEvent?.location ?? '', style: context.bodySmall?.textColor(nonAgendaTextColor.withValues(alpha: 0.9))),
                                          ],
                                        ),
                                        maxLines: max(
                                          1,
                                          min(
                                            ((constraints.maxHeight - 2 - (context.bodyLarge!.height! * context.textScaler.scale(context.bodyLarge!.fontSize!))) /
                                                    (context.bodyLarge!.height! * context.textScaler.scale(context.bodyLarge!.fontSize!)))
                                                .floor(),
                                            (((availableHeight ?? 1000000) - (context.labelSmall!.height! * context.textScaler.scale(context.bodyLarge!.fontSize! + 2))) ~/
                                                (context.bodyLarge!.height! * context.textScaler.scale(context.bodyLarge!.fontSize!))),
                                          ),
                                        ),
                                        softWrap: false,
                                        overflow: TextOverflow.ellipsis,
                                        style: context.bodyLarge
                                            ?.textColor(nonAgendaTextColor.withValues(alpha: 0.8))
                                            .copyWith(decoration: isDeclined ? TextDecoration.lineThrough : null),
                                        strutStyle: StrutStyle(forceStrutHeight: true, height: context.bodyLarge?.height, fontSize: context.bodyLarge?.fontSize),
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
                if (e.conferenceLink != null && !isMonth && width > 100 && height > 32)
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
    );

    return ValueListenableBuilder(
      key: ValueKey(e.id),
      valueListenable: isShowcaseOn,
      builder: (context, value, _) {
        final eventShowcaseTargetTab = PlatformX.isMobileView ? TabType.calendar : TabType.home;
        GlobalKey? key;
        if (eventShowcaseTargetTab == widget.tabType) {
          if (e.eventId == linkedMailTaskId && context.mounted && !widget.isPopup && value != null) {
            if (bounds?.left != bounds?.right) {
              if (showcaseTargetTask == null) {
                showcaseTargetTask = RepaintBoundary(
                  child: ShowcaseWrapper(showcaseKey: taskOnCalendarShowcaseKeyString, targetBorderRadius: BorderRadius.circular(4), child: child),
                );
              }
              child = showcaseTargetTask!;
              key = taskOnCalendarShowcaseKey2;
            }
          } else if (e.eventId == linkedChatEventId && context.mounted && !widget.isPopup && value != null) {
            if (bounds?.left != bounds?.right) {
              if (showcaseTargetEvent == null) {
                showcaseTargetEvent = RepaintBoundary(child: child);
              }
              child = showcaseTargetEvent!;
              key = eventOnCalendarShowcaseKey;
            }
          }
        }

        final style = VisirButtonStyle(
          hoverBorder: Border.all(color: backgroundColor ?? Colors.transparent, width: 1, strokeAlign: BorderSide.strokeAlignInside),
          clickMargin: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(6),
          margin: EdgeInsets.only(right: 2),
          backgroundColor: isDeclined ? Colors.transparent : base,
          border: !e.isEvent || !(isRequest || isDeclined)
              ? Border.all(color: Colors.transparent, width: 1, strokeAlign: BorderSide.strokeAlignInside)
              : Border.all(color: backgroundColor ?? Colors.transparent, width: 1, strokeAlign: BorderSide.strokeAlignInside),
        );

        final result = Expanded(
          child: PlatformX.isMobileView
              ? VisirButton(
                  key: key,
                  type: VisirButtonAnimationType.scaleAndOpacity,
                  style: style,
                  onTap: () {
                    Utils.showPopupDialog(
                      child: e.isEvent
                          ? MobileCalendarEditWidget(
                              tabType: widget.tabType,
                              event: e.linkedEvent,
                              selectedDate: date.add(Duration(hours: e.linkedEvent!.startDate.hour, minutes: e.linkedEvent!.startDate.minute)),
                              linkedMessages: e.linkedMessages,
                              linkedMails: e.linkedMails,
                              calendarTaskEditSourceType: CalendarTaskEditSourceType.editOriginal,
                            )
                          : MobileTaskEditWidget(
                              task: e,
                              selectedDate: date.add(Duration(hours: e.startAt!.hour, minutes: e.startAt!.minute)),
                              tabType: widget.tabType,
                              calendarTaskEditSourceType: CalendarTaskEditSourceType.editOriginal,
                            ),
                    );
                  },
                  child: child,
                )
              : PopupMenu(
                  key: key,
                  backgroundColor: Colors.transparent,
                  hideShadow: true,
                  forceShiftOffset: forceShiftOffsetForMenu,
                  popup: e.isEvent
                      ? CalenderSimpleCreateWidget(
                          tabType: widget.tabType,
                          event: e.linkedEvent,
                          linkedMessages: e.linkedMessages,
                          linkedMails: e.linkedMails,
                          selectedDate: date.add(Duration(hours: e.linkedEvent!.startDate.hour, minutes: e.linkedEvent!.startDate.minute)),
                          calendarTaskEditSourceType: CalendarTaskEditSourceType.editOriginal,
                        )
                      : TaskSimpleCreateWidget(
                          tabType: widget.tabType,
                          task: e,
                          selectedDate: date.add(Duration(hours: e.startAt!.hour, minutes: e.startAt!.minute)),
                          calendarTaskEditSourceType: CalendarTaskEditSourceType.editOriginal,
                        ),
                  type: ContextMenuActionType.tap,
                  location: PopupMenuLocation.right,
                  style: style,
                  child: child,
                ),
        );

        return result;
      },
    );
  }

  Widget buildAppointment(BuildContext context, CalendarAppointmentDetails details) {
    bool isMonth = controller.view == CalendarView.month;
    return Padding(
      padding: EdgeInsets.only(left: 1),
      child: ExtendGestureAreaDetector(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              children: details.appointments.map((d) {
                final e = d as TaskEntity;
                return buildTaskView(
                  e,
                  isMonth: isMonth,
                  height: constraints.maxHeight,
                  width: constraints.maxWidth,
                  date: details.date,
                  bounds: details.bounds,
                  availableHeight: details.availableHeight,
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  Widget buildAppointmentMonthMoreWidget(BuildContext context, List<CalendarAppointmentDetails> details, int count, DateTime date) {
    return PopupMenu(
      popup: CalendarAllDayMoreWidget(
        tabType: TabType.calendar,
        details: details,
        selectedDate: date,
        buildTaskView: buildTaskView,
        moveToDateOnDayView: (date) {
          moveCalendar(targetDate: date);
        },
      ),
      type: ContextMenuActionType.tap,
      location: PopupMenuLocation.right,
      style: VisirButtonStyle(
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.symmetric(horizontal: 1),
        padding: EdgeInsets.symmetric(horizontal: 6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text('+${count}', style: context.bodySmall?.textColor(context.inverseSurface)),
    );
  }

  Widget buildScheduleViewMonthHeader(BuildContext context, ScheduleViewMonthHeaderDetails details) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        child: Padding(
          padding: const EdgeInsets.only(left: 54.0, right: 12, bottom: 12),
          child: Text(DateFormat.yMMM().format(details.date), style: context.titleMedium?.textColor(context.onBackground)),
        ),
      ),
    );
  }

  Widget buildMonthCell(BuildContext context, MonthCellDetails details) {
    return Container(
      decoration: DateUtils.isSameDay(DateTime.now(), details.date) && PlatformX.isDesktopView
          ? BoxDecoration(
              border: Border(
                top: BorderSide(color: context.tertiary, width: 3, style: BorderStyle.solid),
              ),
            )
          : null,
      child: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        decoration: BoxDecoration(
          border: Border.all(color: context.surface, width: 1, strokeAlign: BorderSide.strokeAlignCenter),
          color: !PlatformX.isDesktopView
              ? Colors.transparent
              : DateUtils.isSameDay(DateTime.now(), details.date)
              ? context.tertiary.withValues(alpha: 0.1)
              : (details.date.weekday == 6 || details.date.weekday == 7)
              ? context.tertiary.withValues(alpha: 0.07)
              : Colors.transparent,
        ),
        child: Opacity(
          opacity: details.visibleDates[details.visibleDates.length ~/ 2].month == details.date.month ? 1 : 0.2,
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: DateUtils.isSameDay(DateTime.now(), details.date) ? 1 : 4, left: 8),
                  child: Container(
                    padding: EdgeInsets.zero,
                    decoration: BoxDecoration(color: null, borderRadius: BorderRadius.circular(4)),
                    child: Text(details.date.day.toString(), style: context.titleMedium?.textColor(context.outlineVariant).appFont(context)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration get selectedDecoration => BoxDecoration(color: context.secondary.withValues(alpha: 0.2));

  ScheduleViewSettings get scheduleViewSetting => ScheduleViewSettings(
    hideEmptyScheduleWeek: false,
    appointmentItemHeight: 46,
    monthHeaderSettings: MonthHeaderSettings(height: 0),
    weekHeaderSettings: WeekHeaderSettings(weekTextStyle: context.titleSmall?.textColor(context.outlineVariant).appFont(context), height: 20),
    dayHeaderSettings: DayHeaderSettings(
      dayFormat: 'E',
      dayTextStyle: context.labelMedium?.textColor(context.outlineVariant).appFont(context),
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

  ViewHeaderStyle getViewHeaderStyle(CalendarType type) => ViewHeaderStyle(
    dayTextStyle: type == CalendarType.month
        ? context.labelSmall?.textColor(context.inverseSurface).appFont(context)
        : context.labelMedium?.textColor(context.inverseSurface).appFont(context),
    dateTextStyle: context.titleLarge?.textColor(context.outlineVariant).textBold.appFont(context),
  );

  double getViewHeaderHeight(CalendarType type) {
    switch (type) {
      case CalendarType.day:
      case CalendarType.twoDays:
      case CalendarType.threeDays:
      case CalendarType.fourDays:
      case CalendarType.fiveDays:
      case CalendarType.sixDays:
        return 38;
      case CalendarType.week:
        return 38;
      case CalendarType.month:
        return 24;
    }
  }

  MonthViewSettings getMonthViewSetting(int displayCount) => MonthViewSettings(
    showAgenda: false,
    dayFormat: 'E',
    appointmentDisplayCount: displayCount > 0 ? displayCount : 3,
    appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
    numberOfWeeksInView: kNumberOfWeeksInView,
  );

  void onViewChanged(ViewChangedDetails details) {
    // final targetMonth = ref.read(calendarDisplayDateProvider(widget.tabType).select((v) => v[CalendarDisplayType.main] ?? DateTime.now()));
    final newTargetDate = controller.view == CalendarView.month ? details.visibleDates[details.visibleDates.length ~/ 2] : details.visibleDates.firstOrNull;

    ref.read(calendarDisplayDateProvider(widget.tabType).notifier).updateDate(CalendarDisplayType.main, newTargetDate ?? DateTime.now());
  }

  void moveCalendar({required DateTime targetDate, DateTime? displayDate}) {
    controller.setProperties(selectedDate: targetDate, tappedDate: targetDate, displayDate: displayDate ?? targetDate, changeKey: 'move');
    ref.read(calendarDisplayDateProvider(widget.tabType).notifier).updateDate(CalendarDisplayType.main, displayDate ?? targetDate);
  }

  void selectDateOnScrollAgendaView(DateTime targetDate) {
    controller.setProperties(selectedDate: targetDate, displayDate: targetDate);
    isScrollAgenda = true;
    EasyDebounce.debounce('agenda_scroll', Duration(milliseconds: 300), doneScrollAgenda);
  }

  bool isScrollAgenda = false;

  void doneScrollAgenda() {
    isScrollAgenda = false;
  }

  DateTime _lastTapTime = DateTime(1970);

  void onTap(CalendarTapDetails details, bool showMobileUi) {
    final ratio = ref.read(zoomRatioProvider);

    final globalOffset = details.globalOffset - Offset(timeLabelWidth * ratio, 0) + Offset(timeLabelWidth, 0);
    switch (details.targetElement) {
      case CalendarElement.calendarCell:
        if (details.date == null) return;

        if (((_lastTapTime.difference(DateTime.now()).inMilliseconds) > -300)) {
          openEditWidget(globalOffset, details.date!, controller.view == CalendarView.month, details.localOffset);
        } else {
          if (details.date == null) return;
          controller.setProperties(selectedDate: details.date, tappedDate: details.date, displayDate: null);
        }

        _lastTapTime = DateTime.now();
        break;
      case CalendarElement.appointment:
        // openDetailWidget(globalOffset, details.date!, details.localOffset, details.appointments!.first, details.appointmentRect, timeLabelWidth);
        break;
      case CalendarElement.header:
        break;
      case CalendarElement.viewHeader:
        if (details.date == null) return;
        if (controller.view == CalendarView.month) return;

        if (((_lastTapTime.difference(DateTime.now()).inMilliseconds) > -300)) {
          openEditWidget(globalOffset, details.date!, true, details.localOffset);
        }
        _lastTapTime = DateTime.now();
        break;
      case CalendarElement.agenda:
        break;
      case CalendarElement.allDayPanel:
        if (details.date == null) return;

        if (((_lastTapTime.difference(DateTime.now()).inMilliseconds) > -300)) {
          openEditWidget(globalOffset, details.date!, true, details.localOffset);
        }
        _lastTapTime = DateTime.now();
        break;
      case CalendarElement.moreAppointmentRegion:
        break;
      case CalendarElement.resourceHeader:
        break;
    }
  }

  void openEditWidget(Offset offset, DateTime date, bool isAllDay, Offset? localOffset) {
    final user = ref.read(authControllerProvider).requireValue;
    final Map<String, List<CalendarEntity>> calendarMap = ref.read(calendarListControllerProvider);
    final calendarList = calendarMap.values.expand((e) => e).toList();

    final inboxCalendarDoubleClickActionType = user.userInboxCalendarDoubleClickActionType;

    bool isEvent = true;
    inboxCalendarDoubleClickActionType == InboxCalendarActionType.calendar;

    switch (inboxCalendarDoubleClickActionType) {
      case InboxCalendarActionType.calendar:
        break;
      case InboxCalendarActionType.task:
        isEvent = false;
        break;
      case InboxCalendarActionType.lastCreated:
        final inboxLastCreateEventType = ref.read(inboxLastCreateEventTypeProvider);
        isEvent = inboxLastCreateEventType == InboxLastCreateEventType.calendar;
        break;
    }

    final lastUsedCalendarId = ref.read(lastUsedCalendarIdProvider).firstOrNull;
    final lastUsedProjectId = ref.read(lastUsedProjectIdProvider).firstOrNull;
    final lastUsedProject = lastUsedProjectId == null ? null : ref.read(projectListControllerProvider).firstWhereOrNull((e) => e.isPointedProjectId(lastUsedProjectId));

    final defaultProject = ref.read(projectListControllerProvider).firstWhereOrNull((e) => e.isDefault);

    CalendarEntity? calendar = (calendarList.where((e) => e.uniqueId == (user.defaultCalendarId ?? lastUsedCalendarId)).toList().firstOrNull ?? calendarList.firstOrNull);

    controller.updateColor?.call(
      isEvent
          ? calendar?.backgroundColor == null
                ? context.error
                : ColorX.fromHex(calendar!.backgroundColor)
          : (lastUsedProject?.color ?? defaultProject?.color ?? context.error),
    );
    controller.updateIsTask?.call(!isEvent);

    if (PlatformX.isMobileView) {
      if (isEvent) {
        final pref = ref.read(localPrefControllerProvider).value;
        final calendarOAuths = pref?.calendarOAuths ?? [];
        if (calendarOAuths.isEmpty) {
          showIntegrateCalendarToast();
          return;
        }
      }

      Utils.showPopupDialog(
        child: MobileTaskOrEventSwitcherWidget(
          isEvent: isEvent,
          startDate: date,
          endDate: isAllDay ? date : date.add(Duration(minutes: isEvent ? user.userDefaultDurationInMinutes : user.userTaskDefaultDurationInMinutes)),
          isAllDay: isAllDay,
          selectedDate: DateUtils.dateOnly(date),
          tabType: widget.tabType,
          calendarTaskEditSourceType: CalendarTaskEditSourceType.doubleClick,
        ),
      );

      updateDefaultCreationData();
    } else {
      final endDate = isAllDay ? date : date.add(Duration(minutes: (isEvent ? user.userDefaultDurationInMinutes : user.userTaskDefaultDurationInMinutes)));
      if (localOffset != null)
        controller.showCreateShadow?.call(date, endDate, isAllDay, localOffset, (anchorDiff) {
          showSimpleCreateDialog(offset, date, endDate, isAllDay, isEvent, localOffset, anchorDiff, null, 0, 0, CalendarTaskEditSourceType.doubleClick);
        });
    }
  }

  void openDetailWidget(Offset offset, DateTime date, Offset? localOffset, TaskEntity task, Rect? appointmentRect, double timeLabelWidth) {
    if (task.isEvent) {
      final event = task.linkedEvent!;
      if (PlatformX.isMobileView) {
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
      if (PlatformX.isMobileView) {
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

  void onDoubleTap(CalendarTapDetails details, bool isSide) {}

  Rect? anchorOffset;

  void onInboxDragUpdate(InboxEntity inbox, Offset offset) {
    final user = ref.read(authControllerProvider).requireValue;

    int taskDefaultDurationInMinutes = user.userTaskDefaultDurationInMinutes;
    int eventDefaultDurationInMinutes = user.userDefaultDurationInMinutes;

    RenderBox? box = calendarKey.currentContext?.findRenderObject() as RenderBox?;
    Offset position = box?.localToGlobal(Offset.zero) ?? Offset.zero;
    final ratio = Utils.ref.read(zoomRatioProvider);

    // bool isEdit = isEditAreaPosition(offset: offset);
    // bool isCancel = isCancelAreaPosition(offset: offset);

    // if (PlatformX.isMobileView) {
    //   onDragEdit = isEdit;
    //   onDragCancel = isCancel;
    //   setState(() {});
    // }

    // if (!isEdit && !isCancel) {

    final isEvent = inbox.suggestion?.date_type == InboxSuggestionDateType.event;

    final calendarMap = ref.read(calendarListControllerProvider);
    final calendarHide = ref.read(calendarHideProvider(widget.tabType));
    List<CalendarEntity> calendars = calendarMap.values.expand((e) => e).toList()
      ..removeWhere((c) => c.modifiable != true || calendarHide.contains(c.uniqueId) == true)
      ..unique((element) => element.uniqueId);

    final lastUsedCalendarIds = ref.read(lastUsedCalendarIdProvider);
    CalendarEntity? calendar =
        (calendars.where((e) => e.uniqueId == (user.userDefaultCalendarId ?? lastUsedCalendarIds.firstOrNull)).toList().firstOrNull ?? calendars.firstOrNull);

    final lastUsedProjectId = ref.read(lastUsedProjectIdProvider).firstOrNull;
    final lastUsedProject = lastUsedProjectId == null ? null : ref.read(projectListControllerProvider).firstWhereOrNull((e) => e.isPointedProjectId(lastUsedProjectId));
    final defaultProject = ref.read(projectListControllerProvider).firstWhereOrNull((e) => e.isDefault);
    final suggestedProject = inbox.suggestion?.project_id == null
        ? null
        : ref.read(projectListControllerProvider).firstWhereOrNull((e) => e.isPointedProjectId(inbox.suggestion?.project_id));
    final color = isEvent
        ? calendar == null
              ? null
              : ColorX.fromHex(calendar.backgroundColor)
        : suggestedProject?.color ?? lastUsedProject?.color ?? defaultProject?.color;

    controller.showDragInboxShadow?.call(
      offset - position / ratio,
      Duration(minutes: isEvent ? eventDefaultDurationInMinutes : taskDefaultDurationInMinutes),
      color ?? context.primary,
      (anchorOffset) {
        this.anchorOffset = anchorOffset;
      },
      null,
    );
  }

  Future<void> onInboxDragEnd(InboxEntity inbox, Offset offset) async {
    Completer<void> completer = Completer<void>();
    // final user = ref.read(authControllerProvider).requireValue;

    // bool isEdit = isEditAreaPosition(offset: offset);
    // bool isCancel = isCancelAreaPosition(offset: offset);

    bool isLinkedWithMail = inbox.linkedMail != null;
    bool isLinkedWithMessage = inbox.linkedMessage != null;

    // if (isCancel) {
    //   HapticFeedback.lightImpact();
    //   return;
    // } else if (isEdit) {
    //   final isAllDay = false;
    //   final date = DateTime.now().roundUp(delta: Duration(minutes: 15));

    //   HapticFeedback.lightImpact();
    //   Utils.showPopupDialog(
    //     child: MobileTaskOrEventSwitcherWidget(
    //       isEvent: false,
    //       isAllDay: isAllDay,
    //       selectedDate: DateUtils.dateOnly(date),
    //       startDate: date,
    //       endDate: date.add(Duration(minutes: user.userTaskDefaultDurationInMinutes)),
    //       tabType: widget.tabType,
    //       isFromInboxDrag: true,
    //       titleHintText: inbox.suggestion?.summary ?? inbox.title,
    //       description: inbox.description,
    //       originalTaskMail: inbox.linkedMail,
    //       originalTaskMessage: inbox.linkedMessage,
    //       calendarTaskEditSourceType: CalendarTaskEditSourceType.inboxDrag,
    //     ),
    //   );

    //   return;
    // } else {
    DateTime? date = controller.getInboxDragDatetime?.call();
    bool? isAllDay = controller.getInboxDragIsAllDay?.call();

    if (date != null && isAllDay != null) {
      final user = ref.read(authControllerProvider).requireValue;
      final endAt = isAllDay == true ? date : date.add(Duration(minutes: user.userTaskDefaultDurationInMinutes));

      final ratio = Utils.ref.read(zoomRatioProvider);

      controller.endDragInboxShadow?.call();
      controller.showCreateShadow?.call(date, endAt, isAllDay, offset, (anchorDiff) {});
      if (PlatformX.isMobileView) {
        controller.hideCreateShadow?.call();
        Utils.showPopupDialog(
              child: MobileTaskOrEventSwitcherWidget(
                isEvent: inbox.suggestion?.date_type == InboxSuggestionDateType.event,
                isAllDay: isAllDay,
                startDate: date,
                endDate: isAllDay ? date : date.add(Duration(minutes: user.userTaskDefaultDurationInMinutes)),
                selectedDate: DateUtils.dateOnly(date),
                tabType: widget.tabType,
                titleHintText: inbox.suggestion?.summary ?? inbox.title,
                description: inbox.description,
                originalTaskMail: inbox.linkedMail,
                originalTaskMessage: inbox.linkedMessage,
                calendarTaskEditSourceType: CalendarTaskEditSourceType.inboxDrag,
              ),
            )
            .then((_) {
              completer.complete();
            })
            .catchError((e) {
              completer.completeError(e);
            });
      } else {
        showSimpleCreateDialog(
              Offset(offset.dx * ratio + timeLabelWidth * ratio, offset.dy * ratio),
              date,
              endAt,
              isAllDay,
              inbox.suggestion?.date_type == InboxSuggestionDateType.event,
              offset,
              this.anchorOffset,
              inbox,
              0,
              0,
              CalendarTaskEditSourceType.inboxDrag,
            )
            .then((_) {
              completer.complete();
            })
            .catchError((e) {
              completer.completeError(e);
            });
      }
    } else {
      controller.endDragInboxShadow?.call();
      completer.complete();
    }
    // }

    // if (!isCancel) {
    if (isLinkedWithMail) {
      UserActionSwtichAction.onOpenMail(mailHost: inbox.linkedMail?.hostMail ?? '');
    }
    if (isLinkedWithMessage) {
      UserActionSwtichAction.onOpenExternalMessageLink(teamId: inbox.linkedMessage?.teamId ?? '');
    }
    // }
    return completer.future;
  }

  bool isDargging = false;

  void onDragStart(AppointmentDragStartDetails details) {
    final task = details.appointment as TaskEntity;
    final user = ref.read(authControllerProvider).requireValue;
    isDargging = true;

    if (task.isEvent) {
      final event = task.linkedEvent!;
      final startDateTime = details.dragStartTime;

      modifyStartDateTime = event.editedStartTime;
      modifyEndDateTime = event.editedEndTime;
      modifyIsAllDay = event.isAllDay;
      if (event.isAllDay) {
        if (!modifyEndDateTime!.isAtSameMomentAs(DateUtils.dateOnly(modifyEndDateTime!))) {
          modifyEndDateTime = DateUtils.dateOnly(modifyEndDateTime!).add(Duration(days: 1));
        }
        modifyStartTimeDurationDifference = event.editedStartTime!.difference(DateUtils.dateOnly(startDateTime!));
      } else {
        modifyStartTimeDurationDifference = Duration.zero;
      }
    } else {
      final startDateTime = details.dragStartTime;

      modifyStartDateTime = task.editedStartTime ?? task.startAt;
      modifyEndDateTime = task.editedEndTime ?? task.endAt;
      modifyIsAllDay = task.isAllDay;
      if (task.isAllDay) {
        if (!modifyEndDateTime!.isAtSameMomentAs(DateUtils.dateOnly(modifyEndDateTime!))) {
          modifyEndDateTime = DateUtils.dateOnly(modifyEndDateTime!).add(Duration(days: 1));
        }
        modifyStartTimeDurationDifference = modifyStartDateTime!.difference(DateUtils.dateOnly(startDateTime!));
      } else {
        modifyStartTimeDurationDifference = Duration.zero;
      }
    }

    final selectionDuration = task.isEvent ? user.userDefaultDurationInMinutes : user.userTaskDefaultDurationInMinutes;
    controller.updateDuration?.call(selectionDuration);
  }

  void onDragUpdate(AppointmentDragUpdateDetails details) {
    if (details.globalOffset == null || !(details.appointment is TaskEntity)) return;
    widget.onDragUpdate?.call(globalPosition: details.globalOffset!, task: details.appointment as TaskEntity);
  }

  void onDragEnd(AppointmentDragEndDetails details) async {
    widget.onDragEnd?.call();

    isDargging = false;
    if (details.droppingTime == null) return;
    final user = ref.read(authControllerProvider).requireValue;

    final task = details.appointment as TaskEntity;

    bool isCopy = HardwareKeyboard.instance.logicalKeysPressed.length == 1 && HardwareKeyboard.instance.isAltPressed;

    if (!isCopy && details.droppingTime?.isAtSameMomentAs(modifyStartDateTime!) == true && details.isAllDay == modifyIsAllDay) {
      // 원본은 그대로 두고, 새로 추가된 복제본만 제거
      final originalTask = details.appointment as TaskEntity;
      final currentAppointments = List<TaskEntity>.from(datasource.appointments ?? []);

      // 같은 ID를 가진 appointment가 2개 이상 있으면 복제본이 있는 것
      final duplicates = currentAppointments.where((appointment) => appointment.eventId == originalTask.eventId).toList();

      if (duplicates.length > 1) {
        // 가장 최근에 추가된 것(복제본)을 제거
        final duplicateToRemove = duplicates.last;
        datasource.appointments?.remove(duplicateToRemove);
        datasource.notifyListeners(CalendarDataSourceAction.remove, [duplicateToRemove]);
      }

      return;
    }

    // 드래그가 실제로 발생한 경우에만 처리
    if (task.isEvent) {
      UserActionSwtichAction.onCalendarAction();

      final originalEvent = task.linkedEvent!;

      final list = ref.read(calendarEventListControllerProvider(tabType: widget.tabType)).eventsOnView;
      final recurringEvnet = list.firstWhereOrNull((e) => e.eventId == originalEvent.recurringEventId);
      final event = isCopy
          ? originalEvent.copyWith(id: Utils.generateBase32HexStringFromTimestamp(), removeRecurrence: true, removeICalUID: true, removeRecurringId: true)
          : originalEvent.recurringEventId == null
          ? originalEvent.copyWith()
          : originalEvent.copyWith(rrule: recurringEvnet!.recurrence!);

      final isAllDay = details.isAllDay ?? event.isAllDay;
      final isAllDayChanged = isAllDay != event.isAllDay;

      final minCount = details.droppingTime!.difference(DateUtils.dateOnly(details.droppingTime!)).inMinutes;
      final newStartTime = DateTime(
        details.droppingTime!.year,
        details.droppingTime!.month,
        details.droppingTime!.day,
      ).add(Duration(minutes: (minCount / 15).round() * 15)).add(modifyStartTimeDurationDifference);

      DateTime newEndTime = isAllDayChanged
          ? isAllDay
                ? newStartTime.add(Duration(days: 1))
                : newStartTime.add(Duration(minutes: user.userDefaultDurationInMinutes))
          : isAllDay
          ? newStartTime.add(Duration(days: event.endDate.difference(event.startDate).inDays))
          : newStartTime.add(Duration(minutes: event.endDate.difference(event.startDate).inMinutes));

      if (isAllDay && newStartTime.isAtSameMomentAs(newEndTime)) {
        newEndTime = newEndTime.add(Duration(days: 1));
      }

      if (event.isAllDay != details.isAllDay) {
        if (details.isAllDay == true) {
          newEndTime = newStartTime.add(Duration(days: 1));
        } else {
          newEndTime = newStartTime.add(Duration(minutes: user.userDefaultDurationInMinutes));
        }
      }

      final timezone = ref.read(timezoneProvider).value;
      event.setDates(isAllDay: isAllDay, startDate: newStartTime, endDate: newEndTime, timezone: timezone);
      if (modifyEndDateTime != null && modifyStartDateTime != null) {
        if (isCopy) {
          if (task.linkedMails.isNotEmpty == true || task.linkedMessages.isNotEmpty == true) {
            final newTask = task.copyWith(
              id: Uuid().v4(),
              title: event.title,
              description: event.description,
              removeRrule: true,
              removeRecurringTaskId: true,
              createdAt: DateTime.now(),
              ownerId: user.id,
              linkedEvent: event,
              status: TaskStatus.none,
            );
            TaskAction.upsertTask(
              task: newTask,
              calendarTaskEditSourceType: CalendarTaskEditSourceType.drag,
              tabType: widget.tabType,
              selectedStartDate: modifyStartDateTime!,
              selectedEndDate: modifyEndDateTime!,
            );
          }

          CalendarAction.editCalendarEvent(
            tabType: widget.tabType,
            originalEvent: null,
            newEvent: event,
            selectedEndDate: modifyEndDateTime!,
            selectedStartDate: modifyStartDateTime!,
            isCreate: true,
          );
        } else {
          CalendarAction.editCalendarEvent(
            tabType: widget.tabType,
            originalEvent: originalEvent,
            newEvent: event,
            selectedEndDate: modifyEndDateTime!,
            selectedStartDate: modifyStartDateTime!,
            isCreate: false,
          );
        }
      }
    } else {
      UserActionSwtichAction.onTaskAction();

      final list = ref.read(calendarTaskListControllerProvider(tabType: widget.tabType)).tasksOnView;
      final recurringEvent = list.firstWhereOrNull((e) => e.id == task.recurringTaskId);
      final newTask = isCopy
          ? task.copyWith(id: Uuid().v4(), removeRrule: true, removeRecurringTaskId: true, createdAt: DateTime.now(), ownerId: user.id, status: TaskStatus.none)
          : task.recurringTaskId == null
          ? task.copyWith()
          : task.copyWith(rrule: recurringEvent!.rrule!);
      final isAllDay = details.isAllDay ?? task.isAllDay;

      final minCount = details.droppingTime!.difference(DateUtils.dateOnly(details.droppingTime!)).inMinutes;
      final newStartTime = DateTime(
        details.droppingTime!.year,
        details.droppingTime!.month,
        details.droppingTime!.day,
      ).add(Duration(minutes: (minCount / 15).round() * 15)).add(modifyStartTimeDurationDifference);

      DateTime newEndTime = isAllDay
          ? newStartTime.add(Duration(days: newTask.endAt!.difference(newTask.startAt!).inDays))
          : newStartTime.add(Duration(minutes: newTask.endAt!.difference(newTask.startAt!).inMinutes));

      if (isAllDay && newStartTime.isAtSameMomentAs(newEndTime)) {
        newEndTime = newEndTime.add(Duration(days: 1));
      }

      if (task.isAllDay != details.isAllDay) {
        if (details.isAllDay == true) {
          newEndTime = newStartTime.add(Duration(days: 1));
        } else {
          newEndTime = newStartTime.add(Duration(minutes: user.userTaskDefaultDurationInMinutes));
        }
      }

      if (modifyEndDateTime != null && modifyStartDateTime != null) {
        final finalTask = newTask.copyWith(isAllDay: isAllDay, startAt: newStartTime, endAt: newEndTime);
        if (isCopy) {
          TaskAction.upsertTask(
            originalTask: finalTask,
            task: finalTask,
            calendarTaskEditSourceType: CalendarTaskEditSourceType.drag,
            tabType: widget.tabType,
            selectedStartDate: modifyStartDateTime!,
            selectedEndDate: modifyEndDateTime!,
          );
        } else {
          TaskAction.upsertTask(
            originalTask: task,
            task: finalTask,
            calendarTaskEditSourceType: CalendarTaskEditSourceType.drag,
            tabType: widget.tabType,
            selectedStartDate: modifyStartDateTime!,
            selectedEndDate: modifyEndDateTime!,
          );
        }
        ref.read(inboxLastCreateEventTypeProvider.notifier).update(InboxLastCreateEventType.task);
      }
    }
  }

  void onAppointmentResizeStart(AppointmentResizeStartDetails details) {
    final task = details.appointment as TaskEntity;
    if (task.isEvent) {
      final event = task.linkedEvent!;
      modifyStartDateTime = event.editedStartTime;
      modifyEndDateTime = event.editedEndTime;

      if (event.isAllDay && !modifyEndDateTime!.isAtSameMomentAs(DateUtils.dateOnly(modifyEndDateTime!))) {
        modifyEndDateTime = DateUtils.dateOnly(modifyEndDateTime!).add(Duration(days: 1));
      }
    } else {
      modifyStartDateTime = task.editedStartTime ?? task.startAt;
      modifyEndDateTime = task.editedEndTime ?? task.endAt;

      if (task.isAllDay && !modifyEndDateTime!.isAtSameMomentAs(DateUtils.dateOnly(modifyEndDateTime!))) {
        modifyEndDateTime = DateUtils.dateOnly(modifyEndDateTime!).add(Duration(days: 1));
      }
    }
  }

  void onAppointmentResizeEnd(AppointmentResizeEndDetails details) {
    final task = details.appointment as TaskEntity;
    if (task.isEvent) {
      final originalEvent = task.linkedEvent!;

      final list = ref.read(calendarEventListControllerProvider(tabType: widget.tabType)).eventsOnView;
      final recurringEvnet = list.firstWhereOrNull((e) => e.eventId == originalEvent.recurringEventId);
      final event = originalEvent.recurringEventId == null ? originalEvent.copyWith() : originalEvent.copyWith(rrule: recurringEvnet!.recurrence!);

      if (details.startTime == null || details.endTime == null) return;

      final startMinCount = details.startTime!.difference(DateUtils.dateOnly(details.startTime!)).inMinutes;
      final newStartTime = event.isAllDay
          ? DateTime(details.startTime!.year, details.startTime!.month, details.startTime!.day)
          : DateTime(details.startTime!.year, details.startTime!.month, details.startTime!.day).add(Duration(minutes: (startMinCount / 15).round() * 15));

      final endMinCount = details.endTime!.difference(DateUtils.dateOnly(details.endTime!)).inMinutes;
      final newEndTime = event.isAllDay
          ? DateTime(details.endTime!.year, details.endTime!.month, details.endTime!.day).add(Duration(days: details.endTime!.hour == 0 ? 0 : 1))
          : DateTime(details.endTime!.year, details.endTime!.month, details.endTime!.day).add(Duration(minutes: (endMinCount / 15).round() * 15));

      final timezone = ref.read(timezoneProvider).value;
      event.setDates(isAllDay: event.isAllDay, endDate: newEndTime, startDate: newStartTime, timezone: timezone);

      if (modifyEndDateTime != null && modifyStartDateTime != null) {
        CalendarAction.editCalendarEvent(
          tabType: widget.tabType,
          originalEvent: originalEvent,
          newEvent: event,
          selectedEndDate: modifyEndDateTime!,
          selectedStartDate: modifyStartDateTime!,
          isCreate: false,
        );
      }
    } else {
      final list = ref.read(calendarTaskListControllerProvider(tabType: widget.tabType)).tasksOnView;
      final recurringEvnet = list.firstWhereOrNull((e) => e.id == task.recurringTaskId);
      final newTask = task.recurringTaskId == null ? task.copyWith() : task.copyWith(rrule: recurringEvnet!.rrule!);

      if (details.startTime == null || details.endTime == null) return;

      final startMinCount = details.startTime!.difference(DateUtils.dateOnly(details.startTime!)).inMinutes;
      final newStartTime = newTask.isAllDay
          ? DateTime(details.startTime!.year, details.startTime!.month, details.startTime!.day)
          : DateTime(details.startTime!.year, details.startTime!.month, details.startTime!.day).add(Duration(minutes: (startMinCount / 15).round() * 15));

      final endMinCount = details.endTime!.difference(DateUtils.dateOnly(details.endTime!)).inMinutes;
      final newEndTime = newTask.isAllDay
          ? DateTime(details.endTime!.year, details.endTime!.month, details.endTime!.day).add(Duration(days: details.endTime!.hour == 0 ? 0 : 1))
          : DateTime(details.endTime!.year, details.endTime!.month, details.endTime!.day).add(Duration(minutes: (endMinCount / 15).round() * 15));

      if (modifyEndDateTime != null && modifyStartDateTime != null) {
        TaskAction.upsertTask(
          task: newTask.copyWith(isAllDay: newTask.isAllDay, startAt: newStartTime, endAt: newEndTime),
          originalTask: task,
          calendarTaskEditSourceType: CalendarTaskEditSourceType.drag,
          tabType: widget.tabType,
          selectedStartDate: modifyStartDateTime!,
          selectedEndDate: modifyEndDateTime!,
        );
      }
    }
  }

  void onAppointmentCreate(AppointmentCreateEndDetails details) {
    if (details.startTime == null || details.endTime == null) return;

    final user = ref.read(authControllerProvider).requireValue;

    final inboxCalendarDragActionType = user.userInboxCalendarDragActionType;
    bool isEvent = true;

    switch (inboxCalendarDragActionType) {
      case InboxCalendarActionType.calendar:
        break;
      case InboxCalendarActionType.task:
        isEvent = false;
        break;
      case InboxCalendarActionType.lastCreated:
        final inboxLastCreateEventType = ref.read(inboxLastCreateEventTypeProvider);
        isEvent = inboxLastCreateEventType == InboxLastCreateEventType.calendar;
        break;
    }

    if (PlatformX.isMobileView) {
      if (isEvent) {
        final pref = ref.read(localPrefControllerProvider).value;
        final calendarOAuths = pref?.calendarOAuths ?? [];
        if (calendarOAuths.isEmpty) {
          showIntegrateCalendarToast();
          return;
        }
      }

      controller.hideCreateShadow?.call();

      Utils.showPopupDialog(
        child: MobileTaskOrEventSwitcherWidget(
          isEvent: isEvent,
          startDate: details.startTime!,
          endDate: details.endTime!,
          isAllDay: details.isAllDay ?? false,
          selectedDate: DateUtils.dateOnly(details.startTime!),
          tabType: widget.tabType,
          calendarTaskEditSourceType: CalendarTaskEditSourceType.drag,
        ),
      );
    } else {
      showSimpleCreateDialog(
        details.position,
        details.startTime!,
        details.endTime!,
        details.isAllDay ?? false,
        isEvent,
        details.localPosition,
        details.anchorDiff,
        null,
        0,
        0,
        CalendarTaskEditSourceType.drag,
      );
    }
  }

  void onShowCreateShadow(DateTime startTime, DateTime endTime, bool isAllDay) {
    moveCalendar(targetDate: startTime);
    Future.delayed(Duration(milliseconds: 500), () {
      controller.showCreateShadow?.call(startTime, endTime, isAllDay, Offset.zero, (anchorDiff) {});
    });
  }

  void onRemoveCreateShadow() {
    controller.hideCreateShadow?.call();
    controller.endDragInboxShadow?.call();
    updateDefaultCreationData();
  }

  void onTitleChanged(String? title) {
    controller.updateTitle?.call(title);
  }

  void onColorChanged(Color? color) {
    controller.updateColor?.call(color);
  }

  void onSaved() {
    controller.hideCreateShadow?.call();
    controller.endDragInboxShadow?.call();
    updateDefaultCreationData();
  }

  void onTimeChanged(DateTime startDate, DateTime endDate, bool isAllDay) {
    controller.updateDate?.call(startDate, endDate, isAllDay);
  }

  void updateIsTask(bool isTask) {
    controller.updateIsTask?.call(isTask);
  }

  Future<void> showSimpleCreateDialog(
    Offset position,
    DateTime startTime,
    DateTime endTime,
    bool isAllDay,
    bool isEvent,
    Offset? localPosition,
    Rect? anchorDiff,
    InboxEntity? inbox,
    double itemWidth,
    double itemHeight,
    CalendarTaskEditSourceType calendarTaskEditSourceType,
  ) async {
    Completer<void> completer = Completer<void>();
    double left = position.dx + 8;
    double top = position.dy + 8;
    double width = Constants.desktopCreateTaskPopupWidth;

    if (anchorDiff != null) {
      final ratio = Utils.ref.read(zoomRatioProvider);

      if (position.dx + (anchorDiff.right + width + 10 + 16) * ratio > context.width) {
        left = position.dx + (anchorDiff.left - width - 13) * ratio;
      } else {
        left = position.dx + (anchorDiff.right + 13) * ratio;
      }

      top = position.dy + (anchorDiff.top - 38) * ratio;
    }

    if (isEvent) {
      final pref = ref.read(localPrefControllerProvider).value;
      final calendarOAuths = pref?.calendarOAuths ?? [];
      if (calendarOAuths.isEmpty) {
        showIntegrateCalendarToast();
        return;
      }
    }

    showContextMenu(
      topLeft: Offset(left, top),
      bottomRight: Offset(left + itemWidth, top + itemHeight),
      context: context,
      child: SimpleTaskOrEventSwithcerWidget(
        tabType: widget.tabType,
        isEvent: isEvent,
        startDate: startTime,
        endDate: endTime,
        isAllDay: isAllDay,
        suggestedProjectId: inbox?.suggestion?.project_id,
        selectedDate: DateUtils.dateOnly(startTime),
        onRemoveCreateShadow: onRemoveCreateShadow,
        onTitleChanged: onTitleChanged,
        onColorChanged: onColorChanged,
        onSaved: onSaved,
        onTimeChanged: onTimeChanged,
        updateIsTask: updateIsTask,
        titleHintText: inbox?.suggestion?.summary ?? inbox?.title,
        description: inbox?.description,
        originalTaskMail: inbox?.linkedMail,
        originalTaskMessage: inbox?.linkedMessage,
        calendarTaskEditSourceType: calendarTaskEditSourceType,
      ),
      afterPopup: () {
        completer.complete();
      },
      verticalPadding: 16.0,
      borderRadius: 6.0,
      width: width,
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      clipBehavior: Clip.none,
      isPopupMenu: false,
      hideShadow: true,
    );
    return completer.future;
  }

  void onAddeventButtonPressed() {
    final isAllDay = controller.view == CalendarView.month;
    final date = DateTime.now().roundUp(delta: Duration(minutes: 15));
    final user = ref.read(authControllerProvider).requireValue;

    final pref = ref.read(localPrefControllerProvider).value;
    final calendarOAuths = pref?.calendarOAuths ?? [];
    if (calendarOAuths.isEmpty) {
      showIntegrateCalendarToast();
      return;
    }

    Utils.showPopupDialog(
      child: MobileCalendarEditWidget(
        tabType: widget.tabType,
        event: null,
        startDate: date,
        endDate: isAllDay ? date : date.add(Duration(minutes: user.userDefaultDurationInMinutes)),
        isAllDay: isAllDay,
        selectedDate: DateUtils.dateOnly(date),
        calendarTaskEditSourceType: CalendarTaskEditSourceType.fab,
      ),
    );
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
    if (widget.isPopup) return;
    await ref.read(calendarListControllerProvider.notifier).load();
    await Future.wait([ref.read(calendarTaskListControllerProvider(tabType: widget.tabType).notifier).refresh(showLoading: true, isChunkUpdate: true)].whereType<Future>());
    initialLoaded = true;
  }

  void moveNext() {
    final type = ref.read(calendarTypeChangerProvider(widget.tabType));
    switch (type) {
      case CalendarType.day:
        moveCalendar(targetDate: controller.displayDate!.add(Duration(days: 1)));
        break;
      case CalendarType.twoDays:
        moveCalendar(targetDate: controller.displayDate!.add(Duration(days: 2)));
        break;
      case CalendarType.threeDays:
        moveCalendar(targetDate: controller.displayDate!.add(Duration(days: 3)));
        break;
      case CalendarType.fourDays:
        moveCalendar(targetDate: controller.displayDate!.add(Duration(days: 4)));
        break;
      case CalendarType.fiveDays:
        moveCalendar(targetDate: controller.displayDate!.add(Duration(days: 5)));
        break;
      case CalendarType.sixDays:
        moveCalendar(targetDate: controller.displayDate!.add(Duration(days: 6)));
        break;
      case CalendarType.week:
        moveCalendar(targetDate: controller.displayDate!.add(Duration(days: 7)));
        break;
      case CalendarType.month:
        final targetMonth = ref.read(calendarDisplayDateProvider(widget.tabType).select((v) => v[CalendarDisplayType.main] ?? DateTime.now()));
        moveCalendar(targetDate: DateTime(targetMonth.year, targetMonth.month + 1));
        break;
    }
  }

  void movePrev() {
    final type = ref.read(calendarTypeChangerProvider(widget.tabType));
    switch (type) {
      case CalendarType.day:
        moveCalendar(targetDate: controller.displayDate!.subtract(Duration(days: 1)));
        break;
      case CalendarType.twoDays:
        moveCalendar(targetDate: controller.displayDate!.subtract(Duration(days: 2)));
        break;
      case CalendarType.threeDays:
        moveCalendar(targetDate: controller.displayDate!.subtract(Duration(days: 3)));
        break;
      case CalendarType.fourDays:
        moveCalendar(targetDate: controller.displayDate!.subtract(Duration(days: 4)));
        break;
      case CalendarType.fiveDays:
        moveCalendar(targetDate: controller.displayDate!.subtract(Duration(days: 5)));
        break;
      case CalendarType.sixDays:
        moveCalendar(targetDate: controller.displayDate!.subtract(Duration(days: 6)));
        break;
      case CalendarType.week:
        moveCalendar(targetDate: controller.displayDate!.subtract(Duration(days: 7)));
        break;
      case CalendarType.month:
        final targetMonth = ref.read(calendarDisplayDateProvider(widget.tabType).select((v) => v[CalendarDisplayType.main] ?? DateTime.now()));
        moveCalendar(targetDate: DateTime(targetMonth.year, targetMonth.month - 1));
        break;
    }
  }

  void updateCalendarDatasource() {
    if (!mounted) return;
    final user = ref.read(authControllerProvider).requireValue;
    final pref = ref.read(localPrefControllerProvider).value;
    if (pref == null) return;

    final tasks = ref.read(calendarTaskListControllerProvider(tabType: widget.tabType)).tasksOnView;
    final events = ref.read(calendarEventListControllerProvider(tabType: widget.tabType)).eventsOnView;
    final calendarHide = ref.read(calendarHideProvider(widget.tabType));
    final projectHide = ref.read(projectHideProvider(widget.tabType));

    final newEvents = events.where((e) {
      return !calendarHide.contains(e.calendarUniqueId) && pref.calendarOAuths?.any((o) => o.email == e.calendar.email && o.type.calendarType == e.calendar.type) == true;
    }).toList();

    CompletedTaskOptionType completedTaskOptionType = user.userCompletedTaskOptionType;

    List<TaskEntity> visibleTasks = tasks.where((t) => !projectHide.contains(t.projectId)).map((t) {
      final project = ref.read(projectListControllerProvider).firstWhereOrNull((e) => e.isPointedProject(t));
      if (project?.color != null) t.setColor(project!.color!);
      if (completedTaskOptionType == CompletedTaskOptionType.show || t.status != TaskStatus.done) {
        return t;
      }
      return t.copyWith(status: TaskStatus.cancelled);
    }).toList();

    visibleTasks.removeWhere((t) => t.isEventDummyTask);
    final result = <TaskEntity>[
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

    final homeDefaultTimezone = ref.read(defaultTimezoneProvider) ?? ref.read(timezoneProvider).value;

    datasource.setTimeZone(homeDefaultTimezone);
    datasource.appointments = result;
    datasource.notifyListeners(CalendarDataSourceAction.reset, result);

    checkPayloadThenAction();

    if (result.isNotEmpty && PlatformX.isMobile) {
      EasyThrottle.throttle('updateWidgetData', Duration(milliseconds: 500), () async {
        // Home widget에는 calendar 탭의 projectHide, calendarHide 설정을 사용
        final calendarTabCalendarHide = ref.read(calendarHideProvider(TabType.calendar));
        final calendarTabProjectHide = ref.read(projectHideProvider(TabType.calendar));

        DateTime today = DateUtils.dateOnly(DateTime.now().subtract(Duration(days: 1)));
        // 월 단위 달력 위젯을 위해 최소 6주(42일) 데이터 필요
        // 이전 달의 마지막 주 일부부터 다음 달의 일부까지 포함하도록 계산
        final currentMonthStart = DateTime(today.year, today.month, 1);
        final calendarStartDate = currentMonthStart.subtract(Duration(days: 7)); // 이전 달의 마지막 주 일부 포함
        final nextMonthStart = DateTime(today.year, today.month + 1, 1);
        final calendarEndDate = nextMonthStart.add(Duration(days: 14)); // 다음 달의 일부까지 포함
        List<Appointment> visibleAppointments = datasource.getVisibleAppointments(calendarStartDate, timezone ?? '', calendarEndDate);

        List<Map<String, dynamic>> data = visibleAppointments
            .map((e) {
              // getId 로직에 맞춰서 result에서 TaskEntity 찾기
              // 이벤트인 경우: task.linkedEvent!.uniqueId
              // 태스크인 경우: '${task.id}-${task.editedStartTime?.year}-${task.editedStartTime?.month}-${task.editedStartTime?.day}'
              final originalTask = result.firstWhereOrNull((t) {
                if (t.isEvent) {
                  return '${t.linkedEvent!.uniqueId}' == e.id.toString();
                } else {
                  final taskId = '${t.id}-${t.editedStartTime?.year}-${t.editedStartTime?.month}-${t.editedStartTime?.day}';
                  return taskId == e.id.toString();
                }
              });

              if (originalTask == null) {
                return null;
              }

              if (originalTask.status != TaskStatus.none) {
                return null;
              }

              // calendar 탭의 projectHide 설정으로 필터링 (태스크인 경우)
              if (originalTask.linkedEvent == null && calendarTabProjectHide.contains(originalTask.projectId)) {
                return null;
              }

              // calendar 탭의 calendarHide 설정으로 필터링 (이벤트인 경우)
              if (originalTask.linkedEvent != null) {
                if (calendarTabCalendarHide.contains(originalTask.linkedEvent!.calendarUniqueId)) {
                  return null;
                }
              }

              return {
                'id': originalTask.rrule == null ? e.id : Uuid().v4(),
                'title': e.subject,
                'colorInt': e.color.toARGB32(),
                'startAtMs': e.startTime.millisecondsSinceEpoch,
                'endAtMs': e.endTime.millisecondsSinceEpoch,
                'isAllDay': e.isAllDay,
                'isDone': originalTask.isDone,
                'recurringTaskId': originalTask.rrule == null ? null : originalTask.id,
                'isEvent': originalTask.linkedEvent != null,
                'createdAt': originalTask.createdAt?.millisecondsSinceEpoch,
                'projectId': originalTask.projectId,
                'calendarUniqueId': originalTask.linkedEvent?.calendarUniqueId,
              };
            })
            .where((e) => e != null)
            .cast<Map<String, dynamic>>()
            .toList();

        // 위젯에 projectHide와 calendarHide 리스트도 함께 저장
        await HomeWidget.saveWidgetData<String>('projectHide', jsonEncode(calendarTabProjectHide));
        await HomeWidget.saveWidgetData<String>('calendarHide', jsonEncode(calendarTabCalendarHide));

        Utils.updateWidgetData(userEmail: user.email ?? '', appointments: Utils.sortWidgetAppointmentsData(data), themeMode: ref.read(themeSwitchProvider));

        // Next Schedule 위젯 데이터 업데이트
        final nextScheduleIds = await Utils.updateNextScheduleWidgetData(ref: ref, result: result, events: newEvents, projects: ref.read(projectListControllerProvider));
        if (nextScheduleIds != null) {
          final oldTaskId = _nextScheduleTaskId;
          final oldEventId = _nextScheduleEventId;
          _nextScheduleTaskId = nextScheduleIds.taskId;
          _nextScheduleEventId = nextScheduleIds.eventId;
          print('NextScheduleWidget: Updated IDs - taskId: $_nextScheduleTaskId, eventId: $_nextScheduleEventId (old: taskId=$oldTaskId, eventId=$oldEventId)');
        } else {
          _nextScheduleTaskId = null;
          _nextScheduleEventId = null;
          print('NextScheduleWidget: Cleared IDs (no next schedule)');
        }
      });
    }
  }

  void updateDefaultCreationData() {
    if (!mounted) return;
    if (controller.isAppointmentCreateViewVisible?.call() == true) return;

    final user = ref.read(authControllerProvider).requireValue;

    final Map<String, List<CalendarEntity>> calendarMap = ref.read(calendarListControllerProvider);
    final calendarList = calendarMap.values.expand((e) => e).toList();

    bool isEvent = true;
    final type = user.userInboxCalendarDragActionType;
    switch (type) {
      case InboxCalendarActionType.calendar:
        break;
      case InboxCalendarActionType.task:
        isEvent = false;
        break;
      case InboxCalendarActionType.lastCreated:
        final inboxLastCreateEventType = ref.read(inboxLastCreateEventTypeProvider);
        isEvent = inboxLastCreateEventType == InboxLastCreateEventType.calendar;
        break;
    }

    final lastUsedCalendarId = ref.read(lastUsedCalendarIdProvider).firstOrNull;
    final lastUsedProjectId = ref.read(lastUsedProjectIdProvider).firstOrNull;
    final lastUsedProject = lastUsedProjectId == null ? null : ref.read(projectListControllerProvider).firstWhereOrNull((e) => e.isPointedProjectId(lastUsedProjectId));

    final defaultProject = ref.read(projectListControllerProvider).firstWhereOrNull((e) => e.isDefault);

    CalendarEntity? calendar = (calendarList.where((e) => e.uniqueId == (user.defaultCalendarId ?? lastUsedCalendarId)).toList().firstOrNull ?? calendarList.firstOrNull);

    controller.updateColor?.call(
      isEvent
          ? calendar?.backgroundColor == null
                ? context.error
                : ColorX.fromHex(calendar!.backgroundColor)
          : (lastUsedProject?.color ?? defaultProject?.color ?? context.error),
    );
    final selectionDuration = isEvent ? user.userDefaultDurationInMinutes : user.userTaskDefaultDurationInMinutes;
    if (!isDargging) controller.updateDuration?.call(selectionDuration);
    controller.updateIsTask?.call(!isEvent);
  }

  void checkPayloadThenAction() {
    // final localPref = ref.read(localPrefControllerProvider).value;
    // final devicePixelRatio = localPref?.devicePixelRatio ?? View.of(context).devicePixelRatio;
    // final multiplier = devicePixelRatio / context.devicePixelRatio;

    final payload = notificationPayload;
    if (payload == null) return;
    if (payload['isHome'] != null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      switch (payload['type']) {
        case 'gcal':
          // final eventId = notificationPayload!['eventId'];
          final timestampString = notificationPayload!['date'];
          final date = int.tryParse(timestampString ?? '') != null ? DateTime.fromMillisecondsSinceEpoch(int.tryParse(timestampString!)!) : null;
          if (date == null) return;

          // final open = () {
          //   final event = (ref.read(calendarEventListControllerProvider(widget.tabType)).value ?? []).where((e) => e.eventId == eventId).firstOrNull;
          //   if (event == null) return;
          //   final result = controller.getCalendarDetailsForId?.call(event.eventId, date);
          //   if (result == null) return;
          //   final _globalOffset = result.globalOffset - Offset(timeLabelWidth * multiplier, 0) + Offset(timeLabelWidth, 0);
          //   openDetailWidget(_globalOffset, date, result.localOffset, TaskEntity(linkedEvent: event), result.appointmentRect, timeLabelWidth);
          //   notificationPayload = null;
          // };

          if (controller.getCurrentVisibleDates?.call().contains(DateUtils.dateOnly(date)) != true) {
            final now = date;
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
            // Future.delayed(Duration(milliseconds: 250), () {
            //   open();
            // });
          } else {
            // open();
          }
          break;
        case 'task':
          // final eventId = notificationPayload!['eventId'];
          final timestampString = notificationPayload!['date'];
          final date = int.tryParse(timestampString ?? '') != null ? DateTime.fromMillisecondsSinceEpoch(int.tryParse(timestampString!)!) : null;
          if (date == null) return;

          // final open = () {
          //   final task = (ref.read(inboxTaskListControllerProvider).value ?? []).where((e) => e.id == eventId).firstOrNull;
          //   if (task == null) return;
          //   final result = controller.getCalendarDetailsForId?.call(task.id!, date);
          //   if (result == null) return;
          //   final _globalOffset = result.globalOffset - Offset(timeLabelWidth * multiplier, 0) + Offset(timeLabelWidth, 0);
          //   openDetailWidget(_globalOffset, date, result.localOffset, task, result.appointmentRect, timeLabelWidth);
          //   notificationPayload = null;
          // };

          if (controller.getCurrentVisibleDates?.call().contains(DateUtils.dateOnly(date)) != true) {
            final now = date;
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
            // Future.delayed(Duration(milliseconds: 250), () {
            //   open();
            // });
          } else {
            // open();
          }

          break;
      }
    });
  }

  bool isEditAreaPosition({required Offset offset}) {
    if (PlatformX.isMobileView) {
      RenderBox box = editAreaGlobalKey.currentContext?.findRenderObject() as RenderBox;
      Offset position = box.localToGlobal(Offset.zero);
      final Size size = box.size;

      bool isX = offset.dx >= position.dx && offset.dx <= position.dx + size.width;
      bool isY = offset.dy >= position.dy && offset.dy <= position.dy + size.height;

      return isX && isY;
    } else {
      return false;
    }
  }

  bool isCancelAreaPosition({required Offset offset}) {
    if (PlatformX.isMobileView) {
      RenderBox box = cancelAreaGlobalKey.currentContext?.findRenderObject() as RenderBox;
      Offset position = box.localToGlobal(Offset.zero);
      final Size size = box.size;

      bool isX = offset.dx >= position.dx && offset.dx <= position.dx + size.width;
      bool isY = offset.dy >= position.dy && offset.dy <= position.dy + size.height;

      return isX && isY;
    } else {
      return false;
    }
  }

  Widget editArea({required GlobalKey? key}) {
    return Padding(
      key: key,
      padding: EdgeInsets.all(8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: ShapeDecoration(
          color: context.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            VisirIcon(type: VisirIconType.edit, size: 20, color: context.onPrimary),
            SizedBox(width: 12),
            Text(context.tr.edit, style: context.titleMedium?.textColor(context.onPrimary).appFont(context)),
          ],
        ),
      ),
    );
  }

  Widget cancelArea({required GlobalKey? key}) {
    return Padding(
      key: key,
      padding: EdgeInsets.all(8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: ShapeDecoration(
          color: context.error,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            VisirIcon(type: VisirIconType.close, size: 20, color: context.onPrimary),
            SizedBox(width: 12),
            Text(context.tr.cancel, style: context.titleMedium?.textColor(context.onPrimary).appFont(context)),
          ],
        ),
      ),
    );
  }

  void showIntegrateCalendarToast() {
    Utils.showToast(
      ToastModel(
        message: TextSpan(text: Utils.mainContext.tr.calendar_connect_to_create),
        buttons: [
          ToastButton(
            color: Utils.mainContext.primary,
            textColor: Utils.mainContext.onPrimary,
            text: Utils.mainContext.tr.integrate,
            onTap: (item) {
              if (PlatformX.isMobileView) {
                Utils.showPopupDialog(
                  child: PreferenceScreen(key: Utils.preferenceScreenKey, initialPreferenceScreenType: PreferenceScreenType.integration),
                );
              } else {
                Utils.showPopupDialog(
                  child: PreferenceScreen(key: Utils.preferenceScreenKey, initialPreferenceScreenType: PreferenceScreenType.integration),
                  size: Size(640, 560),
                );
              }
            },
          ),
        ],
      ),
    );

    controller.hideCreateShadow?.call();
    controller.endDragInboxShadow?.call();
  }

  bool showMobileUi = false;
  double minScale = 0;
  double get maxScale => 300;

  String? prevCalendarKey;
  Widget? calendar;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final firstDayOfWeek = ref.watch(authControllerProvider.select((e) => e.requireValue.userFirstDayOfWeek));
    final calendarType = ref.watch(calendarTypeChangerProvider(widget.tabType));

    ref.listen(lastUsedCalendarIdProvider, (previous, next) {});
    ref.listen(lastUsedProjectIdProvider, (previous, next) {});

    ref.listen(localPrefControllerProvider, (previous, next) {
      if (previous?.value?.notificationPayload != next.value?.notificationPayload) {
        checkPayloadThenAction();
        return;
      }

      updateDefaultCreationData();
    });

    ref.listen(hiddenTaskColorsOnHomeTabProvider, (previous, next) {
      if (previous != next) {
        updateCalendarDatasource();
      }
    });

    ref.listen(calendarTypeChangerProvider(widget.tabType), (prev, next) {
      if (prev != next) {
        final now = controller.displayDate ?? DateTime.now();
        final now15 = DateTime(now.year, now.month, now.day, now.hour, (now.minute ~/ 15 + 1) * 15);
        final user = ref.read(authControllerProvider).requireValue;

        final displayDate = next == CalendarType.week && !(user.userWeekViewStartWeekday == 0)
            ? (now15).subtract(
                (DateTime.now()).weekday == 7
                    ? Duration(days: (7 - (user.userWeekViewStartWeekday)).floor())
                    : Duration(days: (controller.displayDate!.weekday - (user.userWeekViewStartWeekday) % 7).floor()),
              )
            : now15;

        updateDefaultCreationData();
        controller.setProperties(displayDate: displayDate, view: next.calendarView);
      }
    });

    ref.listen(calendarListControllerProvider, (prev, next) {
      if (prev?.keys.isNotEmpty != true && next.keys.isNotEmpty == true) {
        updateDefaultCreationData();
      }
    });

    ref.listen(calendarEventListControllerProvider(tabType: widget.tabType), (prev, next) {
      updateCalendarDatasource();
      updateDefaultCreationData();
      checkPayloadThenAction();
    });

    ref.listen(calendarTaskListControllerProvider(tabType: widget.tabType), (prev, next) {
      updateCalendarDatasource();
      updateDefaultCreationData();
    });

    ref.listen(authControllerProvider, (prev, next) {
      if (prev?.value?.userCompletedTaskOptionType != next.value?.userCompletedTaskOptionType) {
        updateCalendarDatasource();
        updateDefaultCreationData();
      }
    });

    ref.listen(calendarHideProvider(widget.tabType), (prev, next) {
      updateCalendarDatasource();
      updateDefaultCreationData();
    });

    ref.listen(projectHideProvider(widget.tabType), (prev, next) {
      updateCalendarDatasource();
      updateDefaultCreationData();
    });

    if (PlatformX.isMobileView && (_nextScheduleTaskId != null || _nextScheduleEventId != null)) {
      ref.listen(inboxConversationSummaryProvider(_nextScheduleTaskId, _nextScheduleEventId), (previous, next) {
        if (next.hasValue && next.value != null && next.value!.isNotEmpty) {
          final taskResult = ref.read(calendarTaskListControllerProvider(tabType: widget.tabType));
          final eventResult = ref.read(calendarEventListControllerProvider(tabType: widget.tabType));
          final projects = ref.read(projectListControllerProvider);
          Utils.updateNextScheduleWidgetData(ref: ref, result: taskResult.tasksOnView, events: eventResult.eventsOnView, projects: projects);
        }
      });
    }

    final scale = ref.watch(calendarIntervalScaleProvider(widget.tabType));
    final homeSecondaryTimezone = ref.watch(secondaryTimezoneProvider);
    final homeDefaultTimezone = ref.watch(defaultTimezoneProvider) ?? ref.read(timezoneProvider).value;
    final timeIntervalHeight = min(max(minScale, scale), maxScale);

    // timeIntervalHeight가 변경될 때만 calendar를 업데이트
    if (prevTimeIntervalHeight != null && prevTimeIntervalHeight != timeIntervalHeight) {
      // timeIntervalHeight만 변경된 경우, calendar만 업데이트
      calendar = null;
    }
    prevTimeIntervalHeight = timeIntervalHeight;

    // calendar 위젯을 build 메서드 밖에서 관리하여 불필요한 재생성 방지
    // timeIntervalHeight는 key에서 제외 (별도로 처리)
    final dateKey = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
    final currentCalendarKey =
        'calendar_${widget.tabType.name}_${firstDayOfWeek.toString()}_${homeDefaultTimezone}_${homeSecondaryTimezone}_${context.isDarkMode}_${dateKey}_${timeIntervalHeight}';
    if (prevCalendarKey != currentCalendarKey) {
      prevCalendarKey = currentCalendarKey;
      // sfCalendarKey = GlobalKey();
      // calendar = null; // 키가 변경되면 calendar 초기화
    }

    return FGBGDetector(
      onChanged: (isForeground, isFirst) {
        if (!isForeground) return;
        checkPayloadThenAction();
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          timeLabelWidth = constraints.maxWidth < 400 ? 48 : 60;
          return Container(
            color: widget.backgroundColor ?? context.background,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Column(
                    children: [
                      if (!widget.isPopup)
                        MainCalendarAppbar(
                          key: ValueKey(showMobileUi.toString()),
                          tabType: widget.tabType,
                          onSidebarButtonPressed: widget.onSidebarButtonPressed ?? () {},
                          onDateButtonPressed: (date) => moveCalendar(targetDate: date),
                          onAddButtonPressed: onAddeventButtonPressed,
                          onTodayButtonPressed: today,
                          onRefreshButtonPressed: refresh,
                          onNextButtonPressed: moveNext,
                          onPrevButtonPressed: movePrev,
                          movePrevDay: movePrevDay,
                          moveNextDay: moveNextDay,
                          appbarType: CalendarAppBarType.main,
                          onCalendarTypeChanged: (type) {},
                        ),

                      Expanded(
                        key: calendarKey,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            minScale = max((constraints.maxHeight - 60) / 24, (context.textScaler.scale(context.bodyLarge!.fontSize!) * context.bodyLarge!.height! + 6) * 2);

                            // timeIntervalHeight를 LayoutBuilder 내부에서도 다시 계산 (minScale이 변경될 수 있음)
                            final currentTimeIntervalHeight = min(max(minScale, scale), maxScale);

                            // calendar가 null이거나 키가 변경되었을 때만 재생성
                            // timeIntervalHeight가 변경된 경우에도 재생성
                            if (calendar == null || prevCalendarKey != currentCalendarKey || prevTimeIntervalHeight != currentTimeIntervalHeight) {
                              calendar = SfCalendar(
                                key: sfCalendarKey,
                                timeZone: homeDefaultTimezone,
                                firstDayOfWeek: firstDayOfWeek,
                                secondaryTimezone: homeSecondaryTimezone,
                                selectionDuration: 60,
                                parentSize: null,
                                todayHighlightColor: context.tertiary,
                                todayTextStyle: context.bodyLarge?.textColor(context.onTertiary),
                                controller: controller,
                                dataSource: datasource,
                                cellBorderColor: context.surface,
                                headerHeight: 0,
                                view: calendarType.calendarView,
                                initialDisplayDate: intiialCalendarDisplayTime,
                                initialSelectedDate: initialCalendarDateTime,
                                selectionDecoration: BoxDecoration(color: Colors.transparent),
                                viewHeaderHeight: getViewHeaderHeight(calendarType),
                                showWeekNumber: false,
                                allowDragAndDrop: true,
                                allowAppointmentResize: calendarType == CalendarType.month ? false : true,
                                dragAndDropSettings: dragAndDropSettings,
                                timeSlotViewSettings: getTimeslotViewSettings(currentTimeIntervalHeight, showMobileUi),
                                viewHeaderStyle: getViewHeaderStyle(calendarType),
                                appointmentBuilder: (context, details) => buildAppointment(context, details),
                                appointmentMonthMoreBuilder: (context, details, count, date) => buildAppointmentMonthMoreWidget(context, details, count, date),
                                monthViewSettings: getMonthViewSetting(
                                  (((constraints.maxHeight - getViewHeaderHeight(calendarType)) / kNumberOfWeeksInView - kMonthDateHeight - todayCircleRadius) /
                                          kMinimumMonthAppointmentHeight)
                                      .floor(),
                                ),
                                onViewChanged: (details) => onViewChanged(details),
                                scheduleViewSettings: scheduleViewSetting,
                                scheduleViewMonthHeaderBuilder: buildScheduleViewMonthHeader,
                                monthCellBuilder: (context, details) => buildMonthCell(context, details),
                                onTap: (details) => onTap(details, showMobileUi),
                                onDragStart: onDragStart,
                                onDragUpdate: onDragUpdate,
                                onDragEnd: onDragEnd,
                                onAppointmentResizeStart: onAppointmentResizeStart,
                                onAppointmentResizeEnd: onAppointmentResizeEnd,
                                onCreate: onAppointmentCreate,
                                selectDateOnScrollAgendaView: (date) => selectDateOnScrollAgendaView(date),
                              );
                              prevCalendarKey = currentCalendarKey;
                            }

                            return RepaintBoundary(
                              child: PinchScale(
                                baseValue: scale,
                                currentValue: () => scale,
                                minValue: minScale,
                                maxValue: maxScale,
                                onValueChanged: (newValue) {
                                  if (controller.view == CalendarView.month) return;
                                  ref.read(calendarIntervalScaleProvider(widget.tabType).notifier).updateScale(newValue);
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(DesktopScaffold.cardRadius),
                                  child: ShowcaseWrapper(
                                    tooltipPosition: TooltipPosition.top,
                                    showcaseKey: ((PlatformX.isMobileView && widget.tabType == TabType.calendar) || (PlatformX.isDesktopView && widget.tabType == TabType.home))
                                        ? taskCalendarShowcaseKeyString
                                        : null,
                                    child: RepaintBoundary(child: calendar!),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
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

enum ArrowDirction { left, right }

class ArrowPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final ArrowDirction direction;

  ArrowPainter({required this.color, required this.strokeWidth, required this.direction});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    var path = Path();
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = strokeWidth;
    paint.strokeCap = StrokeCap.round;
    paint.color = color;
    if (direction == ArrowDirction.left) {
      path.moveTo(size.width - 1, 2);
      path.lineTo(0, size.height * 0.5);
      path.lineTo(size.width - 1, size.height - 2);
    } else {
      path.moveTo(0, 2);
      path.lineTo(size.width - 1, size.height * 0.5);
      path.lineTo(0, size.height - 2);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
