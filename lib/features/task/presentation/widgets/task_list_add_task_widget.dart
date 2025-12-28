import 'dart:async';

import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/contextmenu/src/ContextMenuArea.dart';
import 'package:Visir/dependency/omni_datetime_picker/omni_datetime_picker.dart';
import 'package:Visir/dependency/omni_datetime_picker/src/omni_datetime_picker.dart';
import 'package:Visir/dependency/rrule/src/codecs/text/l10n/l10n.dart';
import 'package:Visir/dependency/rrule/src/recurrence_rule.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/calendar/domain/entities/event_entity.dart';
import 'package:Visir/features/calendar/domain/entities/event_reminder_entity.dart';
import 'package:Visir/features/calendar/presentation/widgets/calendar_desktop_time_field_simple_create.dart';
import 'package:Visir/features/calendar/presentation/widgets/calendar_rrule_edit_widget.dart';
import 'package:Visir/features/calendar/presentation/widgets/calendar_simple_create_widget.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/widgets/keyboard_shortcut.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/presentation/widgets/selection_widget.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/task/actions.dart';
import 'package:Visir/features/task/application/project_list_controller.dart';
import 'package:Visir/features/task/domain/entities/project_entity.dart';
import 'package:Visir/features/task/domain/entities/task_entity.dart';
import 'package:Visir/features/task/domain/entities/task_reminder_option_type.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class TaskListAddTaskWidget extends ConsumerStatefulWidget {
  final DateTime? dateOnAddTask;
  final ProjectEntity? initialProject;
  final void Function() closeAddTaskWidget;

  const TaskListAddTaskWidget({super.key, required this.dateOnAddTask, required this.closeAddTaskWidget, this.initialProject});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => TaskListAddTaskWidgetState();
}

class TaskListAddTaskWidgetState extends ConsumerState<TaskListAddTaskWidget> {
  Timer? saveTimer;

  final FocusNode titleFocusNode = FocusNode();
  final FocusNode descriptionFocusNode = FocusNode();

  late TextEditingController titleEditingController;
  late TextEditingController descriptionEditingController;

  String title = '';
  String description = '';

  late ProjectEntity project;

  DateTime? startDate;
  DateTime? endDate;

  bool isAllDay = true;

  final double timeFieldPopupHeight = 240;

  RruleL10n? rruleL10n;
  RecurrenceRule? rrule;

  RecurrenceOptionType? get recurrenceOptionType => startDate == null
      ? null
      : RecurrenceOptionType.values.firstWhereOrNull((e) => e.getRecurrenceRule(startDate!) == rrule) ?? RecurrenceOptionType.doesNotRepeat;

  List<EventReminderEntity> reminders = [];

  bool get isTopAddTaskWidget => widget.dateOnAddTask != null && widget.dateOnAddTask == DateTime(1000);

  bool get isDarkMode => context.isDarkMode;

  List<ProjectEntity> get projects => ref.read(
    projectListControllerProvider.select((v) {
      final defaultProject = v.firstWhere((e) => e.isDefault);
      return [
        defaultProject,
        ...(v.where((e) => !e.isDefault).toList()
          ..sort((b, a) => (a.updatedAt ?? a.createdAt ?? DateTime(0)).compareTo(b.updatedAt ?? b.createdAt ?? DateTime(0)))),
      ];
    }),
  );

  @override
  void initState() {
    super.initState();
    titleEditingController = TextEditingController(text: title);
    descriptionEditingController = TextEditingController(text: description);
    initiate((widget.dateOnAddTask == null || isTopAddTaskWidget) ? null : widget.dateOnAddTask!);
  }

  @override
  void dispose() {
    saveTimer?.cancel();
    titleEditingController.dispose();
    descriptionEditingController.dispose();
    titleFocusNode.dispose();
    descriptionFocusNode.dispose();
    super.dispose();
  }

  void initiate(DateTime? date) {
    final user = ref.read(authControllerProvider).requireValue;

    project = widget.initialProject ?? projects.firstWhere((e) => e.isDefault);

    rruleL10n = ref.read(rruleL10nEnProvider).asData?.value;
    rrule = null;

    startDate = date == null ? null : DateUtils.dateOnly(date);
    endDate = null;
    isAllDay = true;

    final defaultTaskReminderType = user.userDefaultTaskReminderType;
    final defaultAllDayTaskReminderType = user.userDefaultAllDayTaskReminderType;

    reminders = isAllDay
        ? defaultAllDayTaskReminderType == TaskReminderOptionType.none
              ? []
              : [EventReminderEntity(method: 'push', minutes: defaultAllDayTaskReminderType.minutes())]
        : defaultTaskReminderType == TaskReminderOptionType.none
        ? []
        : [EventReminderEntity(method: 'push', minutes: defaultTaskReminderType.minutes())];

    title = '';
    description = '';

    titleEditingController.clear();
    descriptionEditingController.clear();

    setState(() {});

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      titleFocusNode.requestFocus();
    });
  }

  String getEndTimeDescription() {
    if (endDate == null || startDate == null) return '';
    final duration = endDate!.difference(startDate!);
    final days = duration.inDays;
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);
    String result = '';
    if (days != 0) result += '${days}d';
    if (hours != 0) result += '${(days != 0) ? ' ' : ''}${hours}h';
    if (minutes != 0) result += '${(days != 0) || (hours != 0) ? ' ' : ''}${minutes}m';
    return result;
  }

  void setStartDateTime(DateTime dateTime) {
    if (isAllDay) {
      startDate = DateUtils.dateOnly(dateTime);
      endDate = null;
    } else {
      startDate = dateTime;
      final diff = endDate!.difference(startDate!);
      endDate = dateTime.add(diff);
    }
    setState(() {});
  }

  void setEndDateTime(DateTime dateTime) {
    final user = ref.read(authControllerProvider).requireValue;
    endDate = dateTime;
    if (startDate!.compareTo(dateTime) > 0) {
      startDate = dateTime.subtract(Duration(minutes: user.userTaskDefaultDurationInMinutes));
    }
    setState(() {});
  }

  Future<void> saveTask() async {
    if (title.isEmpty) return;

    saveTimer?.cancel();
    saveTimer = Timer(const Duration(milliseconds: 50), () async {
      final user = ref.read(authControllerProvider).requireValue;

      final recurrenceEndAt = rrule == null || startDate == null
          ? endDate ?? DateTime(3000)
          : rrule!.until == null && rrule!.count == null
          ? DateTime(3000)
          : rrule!.until != null
          ? rrule!.until
          : rrule!.getAllInstances(start: startDate!).lastOrNull ?? DateTime(3000);

      final task = TaskEntity(
        id: Uuid().v4(),
        ownerId: user.id,
        title: title,
        description: description,
        startAt: startDate,
        endAt: (isAllDay || endDate == null) ? startDate?.add(Duration(days: 1)) : endDate,
        isAllDay: isAllDay,
        rrule: rrule,
        excludedRecurrenceDate: [],
        recurrenceEndAt: recurrenceEndAt,
        linkedMails: [],
        linkedMessages: [],
        reminders: reminders,
        projectId: project.uniqueId,
        createdAt: DateTime.now(),
        status: TaskStatus.none,
      );

      await TaskAction.upsertTask(
        task: task,
        originalTask: null,
        calendarTaskEditSourceType: isTopAddTaskWidget ? CalendarTaskEditSourceType.addTaskTop : CalendarTaskEditSourceType.addTaskOnDate,
        tabType: TabType.task,
        selectedStartDate: task.startDate,
        selectedEndDate: task.endDate,
      );

      widget.closeAddTaskWidget();
    });
  }

  bool _onKeyDown(KeyEvent event, {bool? justReturnResult}) {
    final logicalKeyPressed = ServicesBinding.instance.keyboard.logicalKeysPressed.where((e) => e != LogicalKeyboardKey.escape);

    if (ServicesBinding.instance.keyboard.logicalKeysPressed.length == 1) {
      if (ServicesBinding.instance.keyboard.logicalKeysPressed.contains(LogicalKeyboardKey.escape)) {
        if (justReturnResult == true) return true;
        widget.closeAddTaskWidget();
        return true;
      }
    }

    if (logicalKeyPressed.length == 1) {
      if (logicalKeyPressed.contains(LogicalKeyboardKey.enter) || logicalKeyPressed.contains(LogicalKeyboardKey.numpadEnter)) {
        if (justReturnResult == true) return true;
        saveTask();
        return true;
      }
      if (logicalKeyPressed.contains(LogicalKeyboardKey.tab)) {
        if (justReturnResult == true) return true;
        if (titleFocusNode.hasFocus) {
          descriptionFocusNode.requestFocus();
        } else if (descriptionFocusNode.hasFocus) {
          titleFocusNode.requestFocus();
        }
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardShortcut(
      bypassTextField: true,
      onKeyDown: _onKeyDown,
      child: Container(
        margin: EdgeInsets.only(top: isTopAddTaskWidget ? 0 : 12),
        padding: EdgeInsets.all(12),
        decoration: ShapeDecoration(
          color: context.background,
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1, color: isDarkMode ? context.inverseSurface : context.surface),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              focusNode: titleFocusNode,
              controller: titleEditingController,
              textInputAction: TextInputAction.go,
              autofocus: true,
              maxLines: null,
              style: context.titleSmall?.textColor(context.outlineVariant).textBold,
              decoration: InputDecoration(
                hintText: context.tr.inbox_task_title,
                hintStyle: context.titleSmall?.textColor(context.surfaceTint).textBold,
                fillColor: Colors.transparent,
                contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                hoverColor: Colors.transparent,
                border: InputBorder.none,
                isCollapsed: true,
              ),
              onChanged: (text) {
                title = text;
                setState(() {});
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              focusNode: descriptionFocusNode,
              controller: descriptionEditingController,
              textInputAction: TextInputAction.newline,
              style: context.bodyLarge?.textColor(context.shadow),
              maxLines: null,
              decoration: InputDecoration(
                constraints: BoxConstraints(minHeight: 14),
                hintText: context.tr.description,
                contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                border: InputBorder.none,
                fillColor: Colors.transparent,
                hoverColor: Colors.transparent,
                filled: true,
                isDense: true,
                hintStyle: context.bodyLarge?.copyWith(color: context.surfaceTint),
              ),
              onChanged: (text) {
                description = text;
                setState(() {});
              },
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 10,
              children: [
                PopupMenu(
                  forcePopup: true,
                  location: PopupMenuLocation.bottom,
                  width: 180,
                  type: ContextMenuActionType.tap,
                  borderRadius: 6,
                  popup: Builder(
                    builder: (context) {
                      final sortedProjects = projects.sortedProjectWithDepth;
                      return SelectionWidget<ProjectEntity>(
                        current: project,
                        options: (project) => VisirButtonOptions(
                          tooltipLocation: project.description?.isNotEmpty == true ? VisirButtonTooltipLocation.right : VisirButtonTooltipLocation.none,
                          message: project.description,
                        ),
                        items: sortedProjects.map((e) => e.project).toList(),
                        getChild: (project) {
                          final depth = sortedProjects.firstWhereOrNull((e) => e.project.uniqueId == project.uniqueId)?.depth ?? 0;
                          return Row(
                            children: [
                              SizedBox(width: 10 + depth * 12),
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(color: project.color, borderRadius: BorderRadius.circular(6)),
                                alignment: Alignment.center,
                                child: project.icon == null ? null : VisirIcon(type: project.icon!, size: 12, color: Colors.white, isSelected: true),
                              ),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(project.name, style: context.bodyMedium!.textColor(context.shadow), maxLines: 1, overflow: TextOverflow.ellipsis),
                              ),
                              SizedBox(width: 12),
                            ],
                          );
                        },

                        onSelect: (project) {
                          this.project = project;
                          setState(() {});
                        },
                      );
                    },
                  ),
                  style: VisirButtonStyle(
                    height: 24,
                    backgroundColor: context.surface,
                    borderRadius: BorderRadius.circular(4),
                    alignment: Alignment.center,
                    cursor: SystemMouseCursors.click,
                  ),
                  options: project.description?.isNotEmpty == true ? VisirButtonOptions(message: project.description) : null,
                  child: Row(
                    children: [
                      SizedBox(width: 6),
                      Container(
                        width: 14,
                        height: 14,
                        decoration: ShapeDecoration(
                          color: project.color,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        alignment: Alignment.center,
                        child: project.icon == null ? null : VisirIcon(type: project.icon!, size: 10, color: Colors.white, isSelected: true),
                      ),
                      SizedBox(width: 6),
                      Text(project.name, style: context.bodyLarge!.textColor(context.shadow)),
                      SizedBox(width: 8),
                    ],
                  ),
                ),
                ...startDate == null
                    ? [
                        PopupMenu(
                          width: 296,
                          height: 300,
                          forcePopup: true,
                          location: PopupMenuLocation.bottom,
                          type: ContextMenuActionType.tap,
                          popup: OmniDateTimePicker(
                            type: OmniDateTimePickerType.date,
                            initialDate: startDate,
                            backgroundColor: context.surfaceVariant,
                            onDateChanged: setStartDateTime,
                          ),
                          style: VisirButtonStyle(
                            width: 24,
                            height: 24,
                            backgroundColor: context.surface,
                            borderRadius: BorderRadius.circular(4),
                            alignment: Alignment.center,
                            cursor: SystemMouseCursors.click,
                          ),
                          options: VisirButtonOptions(message: context.tr.task_set_date),
                          child: VisirIcon(type: VisirIconType.calendar, size: 14),
                        ),
                      ]
                    : [
                        PopupMenu(
                          width: 296,
                          height: 300,
                          forcePopup: true,
                          location: PopupMenuLocation.bottom,
                          type: ContextMenuActionType.tap,
                          popup: OmniDateTimePicker(
                            type: OmniDateTimePickerType.date,
                            initialDate: startDate,
                            backgroundColor: context.surfaceVariant,
                            onDateChanged: setStartDateTime,
                          ),
                          style: VisirButtonStyle(
                            cursor: SystemMouseCursors.click,
                            padding: EdgeInsets.only(left: 5),
                            backgroundColor: context.surface,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: IntrinsicWidth(
                            child: Row(
                              children: [
                                Text(EventEntity.getDateForEditSimple(startDate!), style: context.bodyLarge?.textColor(context.outlineVariant)),
                                VisirButton(
                                  type: VisirButtonAnimationType.scaleAndOpacity,
                                  style: VisirButtonStyle(padding: EdgeInsets.all(6), hoverColor: Colors.transparent),
                                  onTap: () {
                                    startDate = null;
                                    endDate = null;
                                    isAllDay = true;
                                    setState(() {});
                                  },
                                  child: VisirIcon(type: VisirIconType.closeWithCircle, size: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                        ...(isAllDay && endDate == null)
                            ? [
                                VisirButton(
                                  type: VisirButtonAnimationType.scaleAndOpacity,
                                  style: VisirButtonStyle(
                                    cursor: SystemMouseCursors.click,
                                    width: 24,
                                    height: 24,
                                    backgroundColor: context.surface,
                                    borderRadius: BorderRadius.circular(4),
                                    alignment: Alignment.center,
                                  ),
                                  options: VisirButtonOptions(message: context.tr.task_set_time),
                                  onTap: () {
                                    final user = ref.read(authControllerProvider).requireValue;
                                    final now = DateTime.now();
                                    final date = DateUtils.dateOnly(startDate ?? now);
                                    startDate = DateTime(date.year, date.month, date.day, now.hour, (now.minute ~/ 15 + 1) * 15);
                                    endDate = startDate!.add(Duration(minutes: user.userTaskDefaultDurationInMinutes));
                                    isAllDay = false;
                                    setState(() {});
                                  },
                                  child: VisirIcon(type: VisirIconType.clock, size: 14, isSelected: true),
                                ),
                              ]
                            : [
                                IntrinsicWidth(
                                  child: PopupMenu(
                                    width: 160,
                                    height: timeFieldPopupHeight,
                                    forcePopup: true,
                                    location: PopupMenuLocation.bottom,
                                    type: ContextMenuActionType.tap,
                                    borderRadius: 6,
                                    popup: CalendarDesktopTimeFieldSimpleCreate(
                                      isAllDay: isAllDay,
                                      selectedDateTime: startDate!,
                                      onDateChanged: setStartDateTime,
                                      isEndDateTime: false,
                                      startDateTime: startDate!,
                                      endDateTime: endDate!,
                                      height: timeFieldPopupHeight,
                                    ),
                                    style: VisirButtonStyle(
                                      cursor: SystemMouseCursors.click,
                                      padding: EdgeInsets.only(left: 5),
                                      backgroundColor: context.surface,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(EventEntity.getTimeForEdit(startDate!), style: context.bodyLarge?.textColor(context.outlineVariant)),
                                        VisirButton(
                                          type: VisirButtonAnimationType.scaleAndOpacity,
                                          style: VisirButtonStyle(padding: EdgeInsets.all(6), hoverColor: Colors.transparent),
                                          onTap: () {
                                            endDate = null;
                                            isAllDay = true;
                                            setState(() {});
                                          },
                                          child: VisirIcon(type: VisirIconType.closeWithCircle, size: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                PopupMenu(
                                  width: 180,
                                  height: timeFieldPopupHeight,
                                  forcePopup: true,
                                  location: PopupMenuLocation.bottom,
                                  type: ContextMenuActionType.tap,
                                  borderRadius: 6,
                                  popup: CalendarDesktopTimeFieldSimpleCreate(
                                    isAllDay: isAllDay,
                                    selectedDateTime: endDate!,
                                    onDateChanged: setEndDateTime,
                                    isEndDateTime: true,
                                    startDateTime: startDate!,
                                    endDateTime: endDate!,
                                    height: timeFieldPopupHeight,
                                  ),
                                  style: VisirButtonStyle(
                                    padding: EdgeInsets.all(5),
                                    backgroundColor: context.surface,
                                    borderRadius: BorderRadius.circular(4),
                                    cursor: SystemMouseCursors.click,
                                  ),
                                  child: Text(getEndTimeDescription(), style: context.bodyLarge?.textColor(context.outlineVariant)),
                                ),
                              ],
                        if (recurrenceOptionType != null)
                          PopupMenu(
                            forcePopup: true,
                            location: PopupMenuLocation.bottom,
                            width: 284,
                            borderRadius: 6,
                            type: ContextMenuActionType.tap,
                            popup: SelectionWidget<RecurrenceOptionType>(
                              current: recurrenceOptionType,
                              items: RecurrenceOptionType.values,
                              getTitle: (rruleOptionType) => rruleOptionType.getSelectionOptionTitle(rruleL10n, startDate!, context),
                              getChildIsPopup: (rruleOptionType) => rruleOptionType == RecurrenceOptionType.custom,
                              getChildPopup: (rruleOptionType) => CalendarRruleEditWidget(
                                initialRrule: this.rrule,
                                startDate: startDate!,
                                onRruleChanged: (rrule) {
                                  this.rrule = rrule;
                                  setState(() {});
                                },
                              ),
                              onSelect: (rruleOptionType) {
                                switch (rruleOptionType) {
                                  case RecurrenceOptionType.doesNotRepeat:
                                    this.rrule = null;
                                    setState(() {});
                                    break;
                                  case RecurrenceOptionType.daily:
                                  case RecurrenceOptionType.weeklyByWeekDay:
                                  case RecurrenceOptionType.monthlyByWeekDay:
                                  case RecurrenceOptionType.monthlyByMonthDay:
                                  case RecurrenceOptionType.annualy:
                                  case RecurrenceOptionType.weekdays:
                                    this.rrule = rruleOptionType.getRecurrenceRule(startDate!);
                                    setState(() {});
                                    break;
                                  case RecurrenceOptionType.custom:
                                    break;
                                }
                              },
                            ),
                            style: rruleL10n == null || rrule == null
                                ? VisirButtonStyle(
                                    width: 24,
                                    height: 24,
                                    padding: const EdgeInsets.all(5),
                                    clipBehavior: Clip.antiAlias,
                                    backgroundColor: context.surface,
                                    borderRadius: BorderRadius.circular(4),
                                    cursor: SystemMouseCursors.click,
                                  )
                                : VisirButtonStyle(
                                    backgroundColor: context.surface,
                                    borderRadius: BorderRadius.circular(4),
                                    padding: EdgeInsets.only(left: 6),
                                    cursor: SystemMouseCursors.click,
                                  ),
                            options: rruleL10n == null || rrule == null ? VisirButtonOptions(message: context.tr.calendar_event_edit_repeat) : null,
                            child: rruleL10n == null || rrule == null
                                ? VisirIcon(type: VisirIconType.repeat, size: 14, isSelected: true)
                                : IntrinsicWidth(
                                    child: Row(
                                      children: [
                                        Text(
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          rruleL10n == null || rrule == null
                                              ? context.tr.calendar_event_edit_repeat
                                              : recurrenceOptionType == RecurrenceOptionType.annualy || recurrenceOptionType == RecurrenceOptionType.weekdays
                                              ? recurrenceOptionType!.getSelectionOptionTitle(rruleL10n, startDate!, context)
                                              : rrule!.toText(l10n: rruleL10n!),
                                          style: context.bodyLarge?.textColor(context.outlineVariant),
                                        ),
                                        VisirButton(
                                          type: VisirButtonAnimationType.scaleAndOpacity,
                                          style: VisirButtonStyle(padding: EdgeInsets.all(6), hoverColor: Colors.transparent),
                                          onTap: () {
                                            this.rrule = null;
                                            setState(() {});
                                          },
                                          child: VisirIcon(type: VisirIconType.closeWithCircle, size: 12, isSelected: true),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                      ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
