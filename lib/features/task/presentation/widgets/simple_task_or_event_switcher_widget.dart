import 'package:Visir/config/providers.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/calendar/application/calendar_list_controller.dart';
import 'package:Visir/features/calendar/domain/entities/calendar_entity.dart';
import 'package:Visir/features/calendar/domain/entities/event_entity.dart';
import 'package:Visir/features/calendar/domain/entities/event_reminder_entity.dart';
import 'package:Visir/features/calendar/presentation/widgets/calendar_simple_create_widget.dart';
import 'package:Visir/features/calendar/providers.dart';
import 'package:Visir/features/common/domain/entities/linked_item_entity.dart';
import 'package:Visir/features/common/presentation/utils/extensions/list_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/desktop_scaffold.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/task/application/project_list_controller.dart';
import 'package:Visir/features/task/domain/entities/task_entity.dart';
import 'package:Visir/features/task/domain/entities/task_reminder_option_type.dart';
import 'package:Visir/features/task/presentation/widgets/task_simple_create_widget.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class SimpleTaskOrEventSwithcerWidget extends ConsumerStatefulWidget {
  final bool isEvent;
  final bool isAllDay;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime selectedDate;
  final TabType tabType;
  final CalendarTaskEditSourceType calendarTaskEditSourceType;

  final void Function()? onRemoveCreateShadow;
  final void Function()? onSaved;
  final void Function(String? title)? onTitleChanged;
  final void Function(Color? color)? onColorChanged;
  final void Function(DateTime startTime, DateTime endTime, bool isAllDay)? onTimeChanged;
  final void Function(bool isTask)? updateIsTask;

  final String? titleHintText;
  final String? description;
  final LinkedMessageEntity? originalTaskMessage;
  final LinkedMailEntity? originalTaskMail;
  final String? suggestedProjectId;
  final bool? isUnscheduledTask;
  final TaskStatus? targetStatus;

  const SimpleTaskOrEventSwithcerWidget({
    super.key,
    required this.isEvent,
    required this.isAllDay,
    required this.startDate,
    required this.endDate,
    required this.selectedDate,
    required this.tabType,
    required this.calendarTaskEditSourceType,
    this.onRemoveCreateShadow,
    this.onTitleChanged,
    this.onColorChanged,
    this.onSaved,
    this.onTimeChanged,
    this.updateIsTask,
    this.titleHintText,
    this.description,
    this.originalTaskMessage,
    this.originalTaskMail,
    this.suggestedProjectId,
    this.isUnscheduledTask,
    this.targetStatus,
  });

  @override
  ConsumerState createState() => _SimpleTaskOrEventSwithcerWidgetState();
}

class _SimpleTaskOrEventSwithcerWidgetState extends ConsumerState<SimpleTaskOrEventSwithcerWidget> {
  bool isEvent = true;

  TaskEntity? editedTask;
  EventEntity? editedEvent;

  late DateTime startDate;
  late DateTime endDate;
  late bool isAllDay;

  late DateTime savedStartDate;
  late DateTime savedEndDate;

  bool isEdited = false;

  late final GlobalKey<CalenderSimpleCreateWidgetState> calendarSimpleCreateKey;
  late final GlobalKey<TaskSimpleCreateWidgetState> taskSimpleCreateKey;

  @override
  initState() {
    super.initState();
    calendarSimpleCreateKey = GlobalKey();
    taskSimpleCreateKey = GlobalKey();

    isEvent = widget.isEvent;
    startDate = widget.startDate;
    endDate = widget.endDate;
    isAllDay = widget.isAllDay;
    widget.updateIsTask?.call(!isEvent);

    final user = ref.read(authControllerProvider).requireValue;
    final calendarMap = ref.read(calendarListControllerProvider);
    final calendarHide = ref.read(calendarHideProvider(widget.tabType));
    List<CalendarEntity> calendars = calendarMap.values.expand((e) => e).toList()
      ..removeWhere((c) => c.modifiable != true || calendarHide.contains(c.uniqueId) == true)
      ..unique((element) => element.uniqueId);

    final lastUsedCalendarIds = ref.read(lastUsedCalendarIdProvider);
    CalendarEntity? calendar =
        (calendars.where((e) => e.uniqueId == (user.userDefaultCalendarId ?? lastUsedCalendarIds.firstOrNull)).toList().firstOrNull ?? calendars.firstOrNull);

    final lastUsedProjectId = ref.read(lastUsedProjectIdProvider).firstOrNull;
    final lastUsedProject = lastUsedProjectId == null
        ? null
        : ref.read(projectListControllerProvider).firstWhereOrNull((e) => e.isPointedProjectId(lastUsedProjectId));
    final defaultProject = ref.read(projectListControllerProvider).firstWhereOrNull((e) => e.isDefault);
    final suggestedProject = widget.suggestedProjectId == null
        ? null
        : ref.read(projectListControllerProvider).firstWhereOrNull((e) => e.isPointedProjectId(widget.suggestedProjectId));

    editedEvent = calendar == null
        ? null
        : EventEntity(
            calendarType: calendar.type ?? CalendarEntityType.google,
            eventId: Utils.generateBase32HexStringFromTimestamp(),
            title: null,
            description: null,
            rrule: null,
            location: null,
            isAllDay: isAllDay,
            startDate: startDate,
            timezone: ref.read(timezoneProvider).value,
            endDate: endDate,
            attendees: [],
            reminders: (isAllDay ? [] : [...(calendar.defaultReminders ?? [])]),
            attachments: [],
            conferenceLink: null,
            modifiedEvent: null,
            calendar: calendar,
            sequence: 1,
            doNotApplyDateOffset: true,
          );

    final recurrenceEndAt = endDate;

    final defaultTaskReminderType = user.userDefaultTaskReminderType;
    final defaultAllDayTaskReminderType = user.userDefaultAllDayTaskReminderType;

    editedTask = TaskEntity(
      id: Uuid().v4(),
      ownerId: user.id,
      title: null,
      description: null,
      startAt: startDate,
      endAt: endDate,
      isAllDay: isAllDay,
      rrule: null,
      excludedRecurrenceDate: [],
      recurrenceEndAt: recurrenceEndAt,
      linkedMails: [],
      linkedMessages: [],
      reminders: (isAllDay
          ? defaultAllDayTaskReminderType == TaskReminderOptionType.none
                ? []
                : [EventReminderEntity(method: 'push', minutes: defaultAllDayTaskReminderType.minutes())]
          : defaultTaskReminderType == TaskReminderOptionType.none
          ? []
          : [EventReminderEntity(method: 'push', minutes: defaultTaskReminderType.minutes())]),
      createdAt: DateTime.now(),
      doNotApplyDateOffset: true,
      projectId: suggestedProject?.uniqueId ?? lastUsedProject?.uniqueId ?? defaultProject?.uniqueId,
    );

    final now = DateTime.now();
    savedStartDate = (isAllDay ? DateTime(now.year, now.month, now.day, now.hour, (now.minute ~/ 15 + 1) * 15) : startDate);
    savedEndDate = (isAllDay
        ? DateTime(now.year, now.month, now.day, now.hour, (now.minute ~/ 15 + 1) * 15).add(Duration(minutes: user.userTaskDefaultDurationInMinutes))
        : endDate);
  }

  @override
  void dispose() {
    widget.onRemoveCreateShadow?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(top: 0),

          child: isEvent
              ? CalenderSimpleCreateWidget(
                  key: calendarSimpleCreateKey,
                  tabType: widget.tabType,
                  event: editedEvent,
                  startDate: startDate,
                  endDate: endDate,
                  isAllDay: isAllDay,
                  selectedDate: DateUtils.dateOnly(startDate),
                  onRemoveCreateShadow: () {},
                  onTitleChanged: widget.onTitleChanged,
                  onColorChanged: widget.onColorChanged,
                  onSaved: widget.onSaved,
                  onTimeChanged: widget.onTimeChanged,
                  forceCreate: true,
                  isEdited: isEdited,
                  savedStartDate: savedStartDate,
                  savedEndDate: savedEndDate,
                  onEventChanged: (event) {
                    isEdited = true;
                    editedEvent = event;
                    if (!event.isAllDay) {
                      savedStartDate = event.startDate;
                      savedEndDate = event.endDate;
                    }
                  },
                  titleHintText: widget.titleHintText,
                  description: Utils.textTrimmer(widget.description),
                  originalTaskMessage: widget.originalTaskMessage,
                  originalTaskMail: widget.originalTaskMail,
                  calendarTaskEditSourceType: widget.calendarTaskEditSourceType,
                )
              : TaskSimpleCreateWidget(
                  key: taskSimpleCreateKey,
                  tabType: widget.tabType,
                  task: editedTask,
                  startDate: startDate,
                  endDate: endDate,
                  isAllDay: isAllDay,
                  selectedDate: DateUtils.dateOnly(startDate),
                  onRemoveCreateShadow: () {},
                  forceUnscheduled: widget.isUnscheduledTask,
                  targetStatus: widget.targetStatus,
                  onTitleChanged: widget.onTitleChanged,
                  onColorChanged: widget.onColorChanged,
                  onSaved: widget.onSaved,
                  onTimeChanged: widget.onTimeChanged,
                  forceCreate: true,
                  isEdited: isEdited,
                  savedStartDate: savedStartDate,
                  savedEndDate: savedEndDate,
                  onTaskChanged: (task) {
                    isEdited = true;
                    editedTask = task;
                    if (!task.isAllDay) {
                      savedStartDate = task.startDate;
                      savedEndDate = task.endDate;
                    }
                  },
                  titleHintText: widget.titleHintText,
                  description: Utils.textTrimmer(widget.description),
                  originalTaskMessage: widget.originalTaskMessage,
                  originalTaskMail: widget.originalTaskMail,
                  calendarTaskEditSourceType: widget.calendarTaskEditSourceType,
                ),
        ),
        if (editedEvent != null && widget.isUnscheduledTask != true)
          Row(
            children: [
              VisirButton(
                type: VisirButtonAnimationType.scaleAndOpacity,
                options: VisirButtonOptions(
                  tabType: widget.tabType,
                  bypassTextField: true,
                  shortcuts: [
                    VisirButtonKeyboardShortcut(
                      message: context.tr.inbox_drag_event,
                      keys: [LogicalKeyboardKey.keyE, if (PlatformX.isApple) LogicalKeyboardKey.meta, if (!PlatformX.isApple) LogicalKeyboardKey.control],
                    ),
                  ],
                ),
                style: VisirButtonStyle(
                  cursor: SystemMouseCursors.click,
                  height: 28,
                  padding: EdgeInsets.only(left: 8, right: 10),
                  backgroundColor: isEvent ? context.primary : context.surface,

                  borderRadius: BorderRadius.circular(DesktopScaffold.cardRadius),
                  boxShadow: PopupMenu.popupShadow,
                  border: Border.all(color: context.outline, width: 0.5),
                ),
                onTap: () {
                  isEvent = true;
                  editedEvent = editedEvent?.copyWith(
                    title: editedTask?.title,
                    description: editedTask?.description,
                    startDate: editedTask?.startAt,
                    endDate: editedTask?.endAt,
                    isAllDay: editedTask?.isAllDay,
                    rrule: editedTask?.rrule,
                  );
                  setState(() {});
                  widget.updateIsTask?.call(!isEvent);
                },
                child: Row(
                  children: [
                    VisirIcon(type: VisirIconType.calendar, color: isEvent ? context.onPrimary : context.inverseSurface, size: 14, isSelected: isEvent),
                    SizedBox(width: 6),
                    Text(context.tr.inbox_drag_event, style: context.bodyMedium?.textColor(isEvent ? context.onPrimary : context.inverseSurface)),
                  ],
                ),
              ),
              SizedBox(width: 8),
              VisirButton(
                type: VisirButtonAnimationType.scaleAndOpacity,
                options: VisirButtonOptions(
                  tabType: widget.tabType,
                  bypassTextField: true,
                  shortcuts: [
                    VisirButtonKeyboardShortcut(
                      message: context.tr.inbox_drag_task,
                      keys: [LogicalKeyboardKey.keyT, if (PlatformX.isApple) LogicalKeyboardKey.meta, if (!PlatformX.isApple) LogicalKeyboardKey.control],
                    ),
                  ],
                ),
                style: VisirButtonStyle(
                  cursor: SystemMouseCursors.click,
                  height: 28,
                  padding: EdgeInsets.only(left: 8, right: 10),
                  backgroundColor: !isEvent ? context.primary : context.surface,
                  borderRadius: BorderRadius.circular(DesktopScaffold.cardRadius),
                  boxShadow: PopupMenu.popupShadow,
                  border: Border.all(color: context.outline, width: 0.5),
                ),
                onTap: () {
                  isEvent = false;
                  editedTask = editedTask?.copyWith(
                    title: editedEvent?.title,
                    description: editedEvent?.description,
                    startAt: editedEvent?.startDateTime,
                    endAt: editedEvent?.endDateTime,
                    isAllDay: editedEvent?.isAllDay,
                    rrule: editedEvent?.recurrence,
                  );
                  setState(() {});
                  widget.updateIsTask?.call(!isEvent);
                },
                child: Row(
                  children: [
                    VisirIcon(type: VisirIconType.task, color: !isEvent ? context.onPrimary : context.inverseSurface, size: 14, isSelected: !isEvent),
                    SizedBox(width: 6),
                    Text(context.tr.inbox_drag_task, style: context.bodyMedium?.textColor(!isEvent ? context.onPrimary : context.inverseSurface)),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }
}
