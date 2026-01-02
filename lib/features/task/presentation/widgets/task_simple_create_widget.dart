import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/contextmenu/contextmenu.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/dependency/omni_datetime_picker/omni_datetime_picker.dart';
import 'package:Visir/dependency/omni_datetime_picker/src/omni_datetime_picker.dart';
import 'package:Visir/dependency/rrule/rrule.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/calendar/domain/entities/event_entity.dart';
import 'package:Visir/features/calendar/domain/entities/event_reminder_entity.dart';
import 'package:Visir/features/calendar/presentation/widgets/calendar_desktop_time_field_simple_create.dart';
import 'package:Visir/features/calendar/presentation/widgets/calendar_reminder_edit_widget.dart';
import 'package:Visir/features/calendar/presentation/widgets/calendar_rrule_edit_widget.dart';
import 'package:Visir/features/calendar/presentation/widgets/calendar_simple_create_widget.dart';
import 'package:Visir/features/calendar/providers.dart';
import 'package:Visir/features/common/domain/entities/linked_item_entity.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/log_event.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/collapse_text_field.dart';
import 'package:Visir/features/common/presentation/widgets/desktop_scaffold.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu_container.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu_theme.dart';
import 'package:Visir/features/common/presentation/widgets/selection_widget.dart';
import 'package:Visir/features/common/presentation/widgets/showcase_wrapper.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/inbox/presentation/widgets/simple_linked_message_mail_section.dart';
import 'package:Visir/features/preference/domain/entities/local_pref_entity.dart';
import 'package:Visir/features/task/actions.dart';
import 'package:Visir/features/task/application/calendar_task_list_controller.dart';
import 'package:Visir/features/task/application/project_list_controller.dart';
import 'package:Visir/features/task/domain/entities/project_entity.dart';
import 'package:Visir/features/task/domain/entities/task_entity.dart';
import 'package:Visir/features/task/domain/entities/task_reminder_option_type.dart';
import 'package:Visir/features/time_saved/actions.dart';
import 'package:collection/collection.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time/time.dart';
import 'package:uuid/uuid.dart';

class TaskSimpleCreateWidget extends ConsumerStatefulWidget {
  final TabType tabType;
  final CalendarTaskEditSourceType calendarTaskEditSourceType;
  final TaskEntity? task;
  final bool? isAllDay;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime selectedDate;
  final String? titleHintText;
  final String? description;
  final LinkedMessageEntity? originalTaskMessage;
  final LinkedMailEntity? originalTaskMail;

  final void Function()? onRemoveCreateShadow;
  final void Function()? onSaved;
  final void Function(String? title)? onTitleChanged;
  final void Function(Color? color)? onColorChanged;
  final void Function(DateTime startTime, DateTime endTime, bool isAllDay)? onTimeChanged;
  final void Function(TaskEntity task)? onTaskChanged;
  final bool? forceCreate;
  final DateTime? savedStartDate;
  final DateTime? savedEndDate;
  final bool? isEdited;
  final bool? isCommandResult;

  final bool? forceUnscheduled;
  final TaskStatus? targetStatus;

  final ProjectEntity? initialProject;

  const TaskSimpleCreateWidget({
    super.key,
    required this.tabType,
    required this.calendarTaskEditSourceType,
    this.task,
    this.isAllDay,
    this.startDate,
    this.endDate,
    required this.selectedDate,
    this.titleHintText,
    this.description,
    this.originalTaskMessage,
    this.originalTaskMail,
    this.onRemoveCreateShadow,
    this.onTitleChanged,
    this.onColorChanged,
    this.onSaved,
    this.onTimeChanged,
    this.onTaskChanged,
    this.forceCreate,
    this.savedStartDate,
    this.savedEndDate,
    this.isEdited,
    this.isCommandResult,

    this.forceUnscheduled,
    this.initialProject,
    this.targetStatus,
  });

  @override
  ConsumerState createState() => TaskSimpleCreateWidgetState();
}

class TaskSimpleCreateWidgetState extends ConsumerState<TaskSimpleCreateWidget> {
  late TextEditingController descriptionController;

  String? titleHintText;

  RruleL10n? rruleL10n;

  RecurrenceRule? rrule;
  String? title;

  late DateTime initialStartDate;
  late DateTime initialEndDate;

  late DateTime startDate;
  late DateTime endDate;
  late bool isAllDay;
  late bool isAllDayInitial;

  late DateTime savedStartDate;
  late DateTime savedEndDate;

  late ProjectEntity project;

  List<EventReminderEntity> reminders = [];

  bool isCopy = false;
  bool doNotSave = false;

  late bool isEdited;
  late String taskId;

  late TaskStatus? taskStatus;

  final FocusNode titleFocusNode = FocusNode();
  final FocusNode descriptionFocusNode = FocusNode();

  bool get isFocused => titleFocusNode.hasFocus || descriptionFocusNode.hasFocus;

  RecurrenceOptionType get recurrenceOptionType =>
      RecurrenceOptionType.values.firstWhereOrNull((e) => e.getRecurrenceRule(startDate) == rrule) ?? RecurrenceOptionType.doesNotRepeat;

  double timeFieldPopupHeight = 240;

  bool get isDarkMode => context.isDarkMode;

  VisirButtonTooltipLocation bottomButtonTooltipLocation = VisirButtonTooltipLocation.bottom;

  bool showTimeSection = true;

  List<ProjectEntity> get projects => ref.read(
    projectListControllerProvider.select((v) {
      final defaultProject = v.firstWhere((e) => e.isDefault);
      return [
        defaultProject,
        ...(v.where((e) => !e.isDefault).toList()..sort((b, a) => (a.updatedAt ?? a.createdAt ?? DateTime(0)).compareTo(b.updatedAt ?? b.createdAt ?? DateTime(0)))),
      ];
    }),
  );

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).requireValue;

    if (widget.titleHintText != null) {
      titleHintText = widget.titleHintText;
    }

    taskId = widget.task?.id ?? Uuid().v4();
    rruleL10n = ref.read(rruleL10nEnProvider).asData?.value;

    isAllDay = widget.task?.isAllDay ?? widget.isAllDay ?? false;
    isAllDayInitial = isAllDay;

    final now = DateTime.now();
    startDate = widget.task?.startAt ?? widget.startDate ?? DateTime(now.year, now.month, now.day, now.hour, (now.minute ~/ 15 + 1) * 15);
    endDate = widget.task?.endAt ?? widget.endDate ?? startDate.add(isAllDay ? Duration(days: 1) : Duration(minutes: user.userTaskDefaultDurationInMinutes));

    final newStartDate = widget.selectedDate;
    final newEndDate = widget.selectedDate.add(Duration(minutes: endDate.difference(startDate).inMinutes));

    if (isAllDay) {
      startDate = newStartDate;
      endDate = newEndDate;
    } else {
      startDate = startDate.add(Duration(days: newStartDate.difference(DateUtils.dateOnly(startDate)).inDays));
      endDate = endDate.add(Duration(days: newEndDate.difference(DateUtils.dateOnly(endDate)).inDays));
    }

    if (isAllDay && !DateUtils.isSameDay(endDate, startDate)) {
      endDate = endDate.subtract(Duration(days: 1));
    }

    if (widget.task != null && widget.task!.startAt == null && widget.task!.endAt == null) {
      showTimeSection = false;
    }

    if (widget.targetStatus != null) {
      showTimeSection = false;
    }

    initialStartDate = startDate;
    initialEndDate = endDate;
    savedStartDate = widget.savedStartDate ?? (isAllDay ? DateTime(now.year, now.month, now.day, now.hour, (now.minute ~/ 15 + 1) * 15) : startDate);
    savedEndDate = widget.savedEndDate ?? (isAllDay ? savedStartDate.add(Duration(minutes: user.userTaskDefaultDurationInMinutes)) : endDate);

    final defaultTaskReminderType = user.userDefaultTaskReminderType;
    final defaultAllDayTaskReminderType = user.userDefaultAllDayTaskReminderType;

    reminders =
        widget.task?.reminders ??
        (isAllDay
            ? defaultAllDayTaskReminderType == TaskReminderOptionType.none
                  ? []
                  : [EventReminderEntity(method: 'push', minutes: defaultAllDayTaskReminderType.minutes())]
            : defaultTaskReminderType == TaskReminderOptionType.none
            ? []
            : [EventReminderEntity(method: 'push', minutes: defaultTaskReminderType.minutes())]);

    final lastUsedProjectId = ref.read(lastUsedProjectIdProvider).firstOrNull;
    final lastUsedProject = lastUsedProjectId == null ? null : ref.read(projectListControllerProvider).firstWhereOrNull((e) => e.isPointedProjectId(lastUsedProjectId));

    project =
        widget.initialProject ??
        projects.firstWhereOrNull((e) => widget.task != null ? e.isPointedProject(widget.task!) : false) ??
        lastUsedProject ??
        projects.firstWhere((e) => e.isDefault);

    title = widget.task?.title;
    descriptionController = TextEditingController(text: widget.description == null ? widget.task?.description : widget.description);
    rrule = widget.task?.rrule;

    taskStatus = widget.task?.status;

    isEdited = widget.isEdited ?? false;
    titleFocusNode.onKeyEvent = onKeyEventTextField;
    descriptionFocusNode.onKeyEvent = onKeyEventTextField;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onColorChanged?.call(project.color);
      widget.onTitleChanged?.call(title);
      UserActionSwtichAction.onTaskAction();
    });

    Future.delayed(Duration(milliseconds: 500), () {
      if (!mounted) return;
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      final Size size = renderBox.size;
      final Offset offset = renderBox.localToGlobal(Offset.zero);

      if ((size.height + offset.dy - Utils.mainContext.height).abs() < 100) {
        bottomButtonTooltipLocation = VisirButtonTooltipLocation.top;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    widget.onRemoveCreateShadow?.call();
    titleFocusNode.dispose();
    descriptionFocusNode.dispose();
    super.dispose();
  }

  KeyEventResult onKeyEventTextField(FocusNode node, KeyEvent event) {
    final key = event.logicalKey;
    if (event is KeyDownEvent) {
      if (ServicesBinding.instance.keyboard.logicalKeysPressed.length == 1 && key == LogicalKeyboardKey.escape) {
        onEscapePressed();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  void onTaskChanged() {
    final user = ref.read(authControllerProvider).requireValue;

    final recurrenceEndAt = rrule == null
        ? endDate
        : rrule!.until == null && rrule!.count == null
        ? DateTime(3000)
        : rrule!.until != null
        ? rrule!.until
        : rrule!.getAllInstances(start: startDate).lastOrNull ?? DateTime(3000);

    final task = TaskEntity(
      id: taskId,
      ownerId: user.id,
      title: title,
      description: descriptionController.value.text,
      startAt: startDate,
      endAt: endDate,
      isAllDay: isAllDay,
      rrule: rrule,
      excludedRecurrenceDate: [],
      recurrenceEndAt: recurrenceEndAt,
      linkedMails: widget.task?.linkedMails ?? [],
      linkedMessages: widget.task?.linkedMessages ?? [],
      reminders: reminders,
      projectId: project.uniqueId,
      createdAt: widget.task?.createdAt ?? DateTime.now(),
      doNotApplyDateOffset: true,
    );

    widget.onTaskChanged?.call(task);
  }

  void setStartDateTime(DateTime dateTime) {
    final diff = endDate.difference(startDate);
    if (isAllDay) {
      startDate = dateTime;
      endDate = dateTime;
    } else {
      startDate = dateTime;
      endDate = dateTime.add(diff);

      savedStartDate = startDate;
      savedEndDate = endDate;
    }
    isEdited = true;
    setState(() {});

    widget.onTimeChanged?.call(startDate, endDate, isAllDay);
    onTaskChanged();
  }

  void setEndDateTime(DateTime dateTime) {
    if (isAllDay) {
      endDate = dateTime;
      if (startDate.compareTo(dateTime) > 0) {
        startDate = dateTime;
      }
    } else {
      final user = ref.read(authControllerProvider).requireValue;
      endDate = dateTime;
      if (startDate.compareTo(dateTime) > 0) {
        startDate = dateTime.subtract(Duration(minutes: user.userTaskDefaultDurationInMinutes));
      }

      savedStartDate = startDate;
      savedEndDate = endDate;
    }
    isEdited = true;
    setState(() {});

    widget.onTimeChanged?.call(startDate, endDate, isAllDay);
    onTaskChanged();
  }

  Future<void> delete() async {
    if (widget.task == null) return;
    doNotSave = true;
    Navigator.maybeOf(Utils.mainContext)?.maybePop();
    await TaskAction.deleteTask(
      task: widget.task!,
      calendarTaskEditSourceType: widget.calendarTaskEditSourceType,
      tabType: widget.tabType,
      selectedStartDate: initialStartDate,
      selectedEndDate: initialEndDate.add(Duration(days: isAllDayInitial ? 1 : 0)),
    );
  }

  Future<void> copy() async {
    if (widget.task == null) return;
    taskId = Uuid().v4();
    isEdited = true;
    isCopy = true;
    Navigator.maybeOf(Utils.mainContext)?.maybePop();
  }

  Future<void> save() async {
    if (doNotSave) return;

    if (widget.titleHintText != null && (title ?? '').isEmpty) {
      title = widget.titleHintText;
      isEdited = true;
    }

    if (!isEdited) return;

    if (title?.isNotEmpty != true) return;

    final user = ref.read(authControllerProvider).requireValue;

    final recurrenceEndAt = rrule == null
        ? endDate
        : rrule!.until == null && rrule!.count == null
        ? DateTime(3000)
        : rrule!.until != null
        ? rrule!.until
        : rrule!.getAllInstances(start: startDate).lastOrNull ?? DateTime(3000);

    final task = TaskEntity(
      id: taskId,
      ownerId: user.id,
      title: title,
      description: descriptionController.value.text,
      startAt: widget.forceUnscheduled == true ? null : startDate,
      endAt: widget.forceUnscheduled == true ? null : endDate.add(Duration(days: isAllDay ? 1 : 0)),
      isAllDay: widget.forceUnscheduled == true ? null : isAllDay,
      rrule: widget.forceUnscheduled == true ? null : rrule,
      excludedRecurrenceDate: widget.forceUnscheduled == true ? null : [],
      recurrenceEndAt: widget.forceUnscheduled == true ? null : recurrenceEndAt,
      linkedMails: widget.originalTaskMail == null ? widget.task?.linkedMails ?? [] : [widget.originalTaskMail!],
      linkedMessages: widget.originalTaskMessage == null ? widget.task?.linkedMessages ?? [] : [widget.originalTaskMessage!],
      reminders: widget.forceUnscheduled == true ? null : reminders,
      projectId: project.uniqueId,
      createdAt: widget.task?.createdAt ?? DateTime.now(),
      status: widget.targetStatus ?? taskStatus ?? TaskStatus.none,
      doNotApplyDateOffset: true,
    );

    ref.read(inboxLastCreateEventTypeProvider.notifier).update(InboxLastCreateEventType.task);
    ref.read(lastUsedProjectIdProvider.notifier).set(project.uniqueId);

    await TaskAction.upsertTask(
      task: task,
      originalTask: widget.forceCreate == true ? null : (isCopy ? null : widget.task),
      calendarTaskEditSourceType: widget.calendarTaskEditSourceType,
      tabType: widget.tabType,
      selectedStartDate: initialStartDate,
      selectedEndDate: initialEndDate.add(Duration(days: isAllDayInitial ? 1 : 0)),
      showToast: widget.tabType != TabType.task,
    );

    widget.onSaved?.call();
  }

  void onTextFieldSubmitted(String text) {
    Navigator.maybeOf(Utils.mainContext)?.maybePop();
  }

  void onEscapePressed() {
    titleFocusNode.unfocus();
    descriptionFocusNode.unfocus();
    doNotSave = true;
    Navigator.maybeOf(Utils.mainContext)?.maybePop();
  }

  void updateProject(ProjectEntity project) {
    isEdited = true;
    this.project = project;
    setState(() {});
    onTaskChanged();
  }

  Widget bodyDivider({bool? forceShow}) {
    if (forceShow != true) return SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, top: 12),
      height: 1,
      decoration: BoxDecoration(color: context.context.surfaceVariant),
    );
  }

  String get doneButtonString {
    if (widget.task == null) return '';

    switch (taskStatus) {
      case TaskStatus.none:
      case TaskStatus.braindump:
        return context.tr.mark_done;
      case TaskStatus.done:
      case TaskStatus.cancelled:
        return context.tr.mark_undone;
      case null:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderRaidus = 6.0;

    bool isOverMultipleDays = startDate.date != endDate.date;
    final linkedMails = widget.task?.linkedMails ?? [];
    final linkedMessages = widget.task?.linkedMessages ?? [];

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        save();
      },
      child: Theme(
        data: context.theme.popupTheme,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Container(
                height: 28,
                padding: EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                decoration: BoxDecoration(
                  color: context.surface,
                  borderRadius: BorderRadius.circular(DesktopScaffold.cardRadius),
                  boxShadow: PopupMenu.popupShadow,
                  border: Border.all(color: context.outline, width: 0.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.task != null && PlatformX.isDesktopView && widget.forceCreate != true)
                      VisirButton(
                        type: VisirButtonAnimationType.scaleAndOpacity,
                        style: VisirButtonStyle(width: 24, height: 24, borderRadius: BorderRadius.circular(4), padding: EdgeInsets.zero, margin: EdgeInsets.only(right: 4)),
                        options: VisirButtonOptions(
                          tabType: widget.tabType,
                          shortcuts: [
                            VisirButtonKeyboardShortcut(
                              message: context.tr.task_action_duplicate,
                              keys: [LogicalKeyboardKey.keyD, if (PlatformX.isApple) LogicalKeyboardKey.meta, if (!PlatformX.isApple) LogicalKeyboardKey.control],
                            ),
                          ],
                        ),
                        onTap: copy,
                        child: VisirIcon(type: VisirIconType.copy, color: context.onInverseSurface, size: 14, isSelected: true),
                      ),
                    if (widget.task != null && PlatformX.isDesktopView && widget.forceCreate != true)
                      VisirButton(
                        type: VisirButtonAnimationType.scaleAndOpacity,
                        style: VisirButtonStyle(width: 24, height: 24, borderRadius: BorderRadius.circular(4), margin: EdgeInsets.only(right: 4), padding: EdgeInsets.zero),
                        options: VisirButtonOptions(
                          tabType: widget.tabType,
                          shortcuts: [
                            VisirButtonKeyboardShortcut(
                              message: context.tr.task_action_delete,
                              keys: [LogicalKeyboardKey.backspace, if (PlatformX.isApple) LogicalKeyboardKey.meta, if (!PlatformX.isApple) LogicalKeyboardKey.control],
                              subkeys: [
                                [LogicalKeyboardKey.delete, if (PlatformX.isApple) LogicalKeyboardKey.meta, if (!PlatformX.isApple) LogicalKeyboardKey.control],
                              ],
                              onTrigger: () {
                                if (isFocused) return false;
                                delete();
                                return true;
                              },
                            ),
                          ],
                        ),
                        onTap: delete,
                        child: VisirIcon(type: VisirIconType.trash, color: context.onInverseSurface, size: 14, isSelected: true),
                      ),
                    VisirButton(
                      type: VisirButtonAnimationType.scaleAndOpacity,
                      style: VisirButtonStyle(width: 24, height: 24, borderRadius: BorderRadius.circular(4), margin: EdgeInsets.only(right: 4)),
                      options: VisirButtonOptions(
                        tabType: widget.tabType,
                        bypassTextField: true,
                        shortcuts: [
                          VisirButtonKeyboardShortcut(message: context.tr.confirm, keys: [LogicalKeyboardKey.enter]),
                        ],
                      ),
                      onTap: () => Navigator.maybeOf(Utils.mainContext)?.maybePop(),
                      child: VisirIcon(type: VisirIconType.check, color: context.onInverseSurface, size: 14, isSelected: true),
                    ),
                    VisirButton(
                      type: VisirButtonAnimationType.scaleAndOpacity,
                      style: VisirButtonStyle(width: 24, height: 24, borderRadius: BorderRadius.circular(4)),
                      options: VisirButtonOptions(
                        tabType: widget.tabType,
                        bypassTextField: true,
                        shortcuts: [
                          VisirButtonKeyboardShortcut(message: context.tr.cancel, keys: [LogicalKeyboardKey.escape]),
                        ],
                      ),
                      onTap: onEscapePressed,
                      child: VisirIcon(type: VisirIconType.close, color: context.onInverseSurface, size: 14, isSelected: true),
                    ),
                  ],
                ),
              ),
            ),
            ShowcaseWrapper(
              showcaseKey: taskLinkedMailShowcaseKeyString,
              // closePopupOnNext: true,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(DesktopScaffold.cardRadius),
                  boxShadow: PopupMenu.popupShadow,
                  color: context.surface,
                  border: Border.all(color: context.outline, width: 0.5),
                ),
                child: PopupMenuContainer(
                  horizontalPadding: 0,
                  backgroundColor: null,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                        child: CollapsingTextFormField(
                          focusNode: titleFocusNode,
                          onFieldSubmitted: onTextFieldSubmitted,
                          initialValue: title ?? '',
                          textInputAction: TextInputAction.none,
                          autofocus: widget.task == null || widget.forceCreate == true,
                          collapsedLines: 2,
                          style: context.titleMedium?.textColor(context.outlineVariant).textBold,
                          decoration: InputDecoration(
                            constraints: BoxConstraints(minHeight: 20),
                            hintText: titleHintText ?? (widget.targetStatus == TaskStatus.braindump ? context.tr.dump_ideas_from_brain : context.tr.inbox_task_title),
                            hintStyle: context.titleMedium?.textColor(context.surfaceTint).textBold,
                            filled: false,
                            contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                            hoverColor: Colors.transparent,
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          onChanged: (text) {
                            if (text.isEmpty) {
                              titleHintText = widget.titleHintText ?? context.tr.inbox_task_title;
                            } else {
                              titleHintText = '';
                            }

                            title = text;
                            isEdited = true;
                            setState(() {});

                            widget.onTitleChanged?.call(text.isEmpty ? null : text);
                            onTaskChanged();
                          },
                        ),
                      ),
                      bodyDivider(),
                      Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 16, right: 16, top: 14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: VisirIcon(type: VisirIconType.description, size: 14, isSelected: (descriptionController.value.text).isNotEmpty),
                                ),
                                Expanded(
                                  child: CollapsingTextFormField(
                                    onFieldSubmitted: onTextFieldSubmitted,
                                    focusNode: descriptionFocusNode
                                      ..onKeyEvent = (node, event) {
                                        if (event is KeyDownEvent) {
                                          final logicalKeyPressed = ServicesBinding.instance.keyboard.logicalKeysPressed.where((e) => e != LogicalKeyboardKey.escape);

                                          if (logicalKeyPressed.length == 2) {
                                            if (HardwareKeyboard.instance.isShiftPressed && logicalKeyPressed.contains(LogicalKeyboardKey.enter)) {
                                              final currentValue = descriptionController.value.text;
                                              final selectionStart = descriptionController.selection.start;
                                              final newValue = currentValue.substring(0, selectionStart) + '\n' + currentValue.substring(selectionStart);
                                              descriptionController.text = newValue;
                                              descriptionController.selection = TextSelection.fromPosition(TextPosition(offset: selectionStart + 1));
                                              setState(() {});
                                              return KeyEventResult.handled;
                                            }
                                          }

                                          if (logicalKeyPressed.length == 1) {
                                            if (logicalKeyPressed.contains(LogicalKeyboardKey.enter)) {
                                              onTextFieldSubmitted(descriptionController.value.text);
                                              return KeyEventResult.handled;
                                            }
                                          }
                                        }
                                        return KeyEventResult.ignored;
                                      },
                                    controller: descriptionController,
                                    // initialValue: description ?? '',
                                    textInputAction: TextInputAction.none,
                                    style: context.bodyMedium?.copyWith(color: context.outlineVariant),
                                    collapsedLines: 5,
                                    decoration: InputDecoration(
                                      hintText: context.tr.description,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 3),
                                      border: InputBorder.none,
                                      fillColor: descriptionController.value.text.isNotEmpty == true ? context.surface : Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      filled: false,
                                      isDense: true,
                                      hintStyle: context.bodyLarge?.copyWith(color: context.surfaceTint),
                                    ),
                                    onChanged: (text) {
                                      isEdited = true;
                                      setState(() {});
                                      onTaskChanged();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (showTimeSection || reminders.isNotEmpty) Padding(padding: const EdgeInsets.only(left: 24), child: bodyDivider()),
                        ],
                      ),
                      SimpleLinkedMessageMailSection(
                        originalTaskMessage: widget.originalTaskMessage,
                        originalTaskMail: widget.originalTaskMail,
                        linkedMessages: linkedMessages,
                        linkedMails: linkedMails,
                        tabType: widget.tabType,
                        isEvent: false,
                      ),
                      if (showTimeSection)
                        Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                left: 16,
                                right: 16,
                                top: (linkedMessages.isNotEmpty || linkedMails.isNotEmpty || widget.originalTaskMail != null || widget.originalTaskMessage != null) ? 6 : 11,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 10, top: 5),
                                    child: VisirIcon(type: VisirIconType.clock, size: 14, isSelected: showTimeSection),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Wrap(
                                          spacing: 4,
                                          runSpacing: 4,
                                          children: [
                                            IntrinsicWidth(
                                              child: PopupMenu(
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
                                                  padding: EdgeInsets.all(5),
                                                  backgroundColor: context.surfaceVariant,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Text(EventEntity.getDateForEditSimple(startDate), style: context.bodyLarge?.textColor(context.outlineVariant)),

                                                    VisirButton(
                                                      type: VisirButtonAnimationType.scaleAndOpacity,
                                                      style: VisirButtonStyle(margin: EdgeInsets.only(left: 6)),
                                                      onTap: () {
                                                        showTimeSection = !showTimeSection;
                                                        setState(() {});
                                                      },
                                                      child: VisirIcon(type: VisirIconType.closeWithCircle, size: 12, isSelected: true),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            if (!isAllDay)
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
                                                    selectedDateTime: startDate,
                                                    onDateChanged: setStartDateTime,
                                                    isEndDateTime: false,
                                                    startDateTime: startDate,
                                                    endDateTime: endDate,
                                                    height: timeFieldPopupHeight,
                                                  ),
                                                  style: VisirButtonStyle(
                                                    padding: EdgeInsets.all(5),
                                                    backgroundColor: context.surfaceVariant,
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(EventEntity.getTimeForEdit(startDate), style: context.bodyLarge?.textColor(context.outlineVariant)),
                                                ),
                                              ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                                              child: Text(context.tr.to, style: context.bodyLarge?.textColor(context.outlineVariant)),
                                            ),
                                            if (isOverMultipleDays || isAllDay) ...[
                                              if (!isAllDay) SizedBox(width: double.infinity),
                                              IntrinsicWidth(
                                                child: PopupMenu(
                                                  width: 296,
                                                  height: 300,
                                                  forcePopup: true,
                                                  location: PopupMenuLocation.bottom,
                                                  type: ContextMenuActionType.tap,
                                                  popup: OmniDateTimePicker(
                                                    type: OmniDateTimePickerType.date,
                                                    initialDate: endDate,
                                                    backgroundColor: context.surfaceVariant,
                                                    onDateChanged: setEndDateTime,
                                                  ),
                                                  style: VisirButtonStyle(
                                                    padding: EdgeInsets.all(5),
                                                    backgroundColor: context.surfaceVariant,
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(EventEntity.getDateForEditSimple(endDate), style: context.bodyLarge?.textColor(context.outlineVariant)),
                                                ),
                                              ),
                                            ],
                                            if (!isAllDay)
                                              IntrinsicWidth(
                                                child: PopupMenu(
                                                  width: 180,
                                                  height: timeFieldPopupHeight,
                                                  forcePopup: true,
                                                  location: PopupMenuLocation.bottom,
                                                  type: ContextMenuActionType.tap,
                                                  borderRadius: 6,
                                                  popup: CalendarDesktopTimeFieldSimpleCreate(
                                                    isAllDay: isAllDay,
                                                    selectedDateTime: endDate,
                                                    onDateChanged: setEndDateTime,
                                                    isEndDateTime: true,
                                                    startDateTime: startDate,
                                                    endDateTime: endDate,
                                                    height: timeFieldPopupHeight,
                                                  ),
                                                  style: VisirButtonStyle(
                                                    padding: EdgeInsets.all(5),
                                                    backgroundColor: context.surfaceVariant,
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(EventEntity.getTimeForEdit(endDate), style: context.bodyLarge?.textColor(context.outlineVariant)),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            IntrinsicWidth(
                                              child: VisirButton(
                                                type: VisirButtonAnimationType.scaleAndOpacity,
                                                style: VisirButtonStyle(
                                                  cursor: SystemMouseCursors.click,
                                                  borderRadius: BorderRadius.circular(4),
                                                  border: isAllDay ? null : Border.all(color: context.outline, width: 1),
                                                  backgroundColor: isAllDay ? context.primary : Colors.transparent,
                                                  padding: EdgeInsets.symmetric(horizontal: 6 + (isAllDay ? 1 : 0), vertical: 4 + (isAllDay ? 1 : 0)),
                                                ),
                                                onTap: () {
                                                  isAllDay = !isAllDay;

                                                  if (isAllDay) {
                                                    final startDateTime = DateUtils.dateOnly(startDate);
                                                    final endDateTime = DateUtils.dateOnly(endDate.compareTo(startDateTime) < 0 ? startDateTime : endDate);

                                                    startDate = DateUtils.dateOnly(startDateTime);
                                                    endDate = DateUtils.dateOnly(endDateTime);
                                                  } else {
                                                    final startDateTime = DateTime(startDate.year, startDate.month, startDate.day, savedStartDate.hour, savedStartDate.minute);
                                                    final endDateTime = DateTime(endDate.year, endDate.month, endDate.day, savedEndDate.hour, savedEndDate.minute);

                                                    startDate = startDateTime;
                                                    endDate = endDateTime;
                                                    savedStartDate = startDate;
                                                    savedEndDate = endDate;
                                                  }
                                                  isEdited = true;
                                                  setState(() {});
                                                  widget.onTimeChanged?.call(startDate, endDate, isAllDay);
                                                  onTaskChanged();
                                                },
                                                child: Text(context.tr.all_day, style: context.bodyLarge?.textColor(isAllDay ? context.onPrimary : context.outlineVariant)),
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: PopupMenu(
                                                forcePopup: true,
                                                location: PopupMenuLocation.bottom,
                                                width: 284,
                                                borderRadius: 6,
                                                type: ContextMenuActionType.tap,
                                                popup: SelectionWidget<RecurrenceOptionType>(
                                                  current: recurrenceOptionType,
                                                  items: RecurrenceOptionType.values,
                                                  getTitle: (rruleOptionType) => rruleOptionType.getSelectionOptionTitle(rruleL10n, startDate, context),
                                                  getChildIsPopup: (rruleOptionType) => rruleOptionType == RecurrenceOptionType.custom,
                                                  getChildPopup: (rruleOptionType) => CalendarRruleEditWidget(
                                                    initialRrule: this.rrule,
                                                    startDate: startDate,
                                                    onRruleChanged: (rrule) {
                                                      isEdited = true;
                                                      this.rrule = rrule;
                                                      setState(() {});
                                                      onTaskChanged();

                                                      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                                                        final navigator = Navigator.maybeOf(Utils.mainContext);
                                                        if (navigator != null && navigator.canPop()) navigator.pop();
                                                      });
                                                    },
                                                  ),
                                                  onSelect: (rruleOptionType) {
                                                    switch (rruleOptionType) {
                                                      case RecurrenceOptionType.doesNotRepeat:
                                                        isEdited = true;
                                                        this.rrule = null;
                                                        setState(() {});
                                                        onTaskChanged();
                                                        break;
                                                      case RecurrenceOptionType.daily:
                                                      case RecurrenceOptionType.weeklyByWeekDay:
                                                      case RecurrenceOptionType.monthlyByWeekDay:
                                                      case RecurrenceOptionType.monthlyByMonthDay:
                                                      case RecurrenceOptionType.annualy:
                                                      case RecurrenceOptionType.weekdays:
                                                        isEdited = true;
                                                        this.rrule = rruleOptionType.getRecurrenceRule(startDate);
                                                        setState(() {});
                                                        onTaskChanged();
                                                        break;
                                                      case RecurrenceOptionType.custom:
                                                        break;
                                                    }
                                                  },
                                                ),
                                                style: VisirButtonStyle(
                                                  borderRadius: BorderRadius.circular(4),
                                                  border: rruleL10n == null || rrule == null ? Border.all(color: context.outline, width: 0.5) : null,
                                                  backgroundColor: rruleL10n == null || rrule == null ? Colors.transparent : context.primary,
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 6 + (rruleL10n == null || rrule == null ? 0 : 1),
                                                    vertical: 4 + (rruleL10n == null || rrule == null ? 0 : 1),
                                                  ),
                                                ),
                                                child: Text(
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  rruleL10n == null || rrule == null
                                                      ? context.tr.calendar_event_edit_repeat
                                                      : recurrenceOptionType == RecurrenceOptionType.annualy || recurrenceOptionType == RecurrenceOptionType.weekdays
                                                      ? recurrenceOptionType.getSelectionOptionTitle(rruleL10n, startDate, context)
                                                      : rrule!.toText(l10n: rruleL10n!),
                                                  style: context.bodyLarge?.textColor(rruleL10n == null || rrule == null ? context.outlineVariant : context.onPrimary),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (reminders.isNotEmpty) Padding(padding: const EdgeInsets.only(left: 24), child: bodyDivider()),
                          ],
                        ),
                      if (showTimeSection && reminders.isNotEmpty)
                        Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 16, right: 16, top: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 10, top: 5),
                                    child: VisirIcon(type: VisirIconType.notification, size: 14, isSelected: reminders.isNotEmpty),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: reminders.mapIndexed((index, e) {
                                        bool isFirst = index == 0;

                                        return Container(
                                          height: 24,
                                          decoration: BoxDecoration(color: context.surfaceVariant, borderRadius: BorderRadius.circular(4)),
                                          margin: EdgeInsets.only(right: 10, top: isFirst ? 0 : 8),
                                          padding: EdgeInsets.only(left: 6),
                                          child: IntrinsicWidth(
                                            child: Row(
                                              children: [
                                                Text(
                                                  getReminderString(context: context, isAllDay: isAllDay, minute: e.minutes ?? 0),
                                                  style: context.bodyLarge?.textColor(context.outlineVariant),
                                                ),
                                                VisirButton(
                                                  type: VisirButtonAnimationType.scaleAndOpacity,
                                                  style: VisirButtonStyle(cursor: SystemMouseCursors.click, padding: EdgeInsets.all(6)),
                                                  onTap: () {
                                                    isEdited = true;
                                                    reminders.remove(e);
                                                    setState(() {});
                                                    onTaskChanged();
                                                  },
                                                  child: VisirIcon(type: VisirIconType.closeWithCircle, size: 12, isSelected: true),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      bodyDivider(),
                      if (widget.targetStatus == TaskStatus.braindump || widget.task?.status == TaskStatus.braindump)
                        SizedBox(height: 16)
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  return PopupMenu(
                                    forcePopup: true,
                                    location: PopupMenuLocation.bottom,
                                    width: 180,
                                    borderRadius: 6,
                                    type: ContextMenuActionType.tap,
                                    popup: Builder(
                                      builder: (context) {
                                        final sortedProjects = projects.sortedProjectWithDepth;
                                        return SelectionWidget<ProjectEntity>(
                                          current: project,
                                          items: sortedProjects.map((e) => e.project).toList(),
                                          options: (project) => VisirButtonOptions(
                                            tooltipLocation: project.description?.isNotEmpty == true ? VisirButtonTooltipLocation.right : VisirButtonTooltipLocation.none,
                                            message: project.description,
                                          ),
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
                                            updateProject(project);
                                            widget.onColorChanged?.call(project.color);
                                          },
                                        );
                                      },
                                    ),
                                    options: project.description?.isNotEmpty == true
                                        ? VisirButtonOptions(tooltipLocation: VisirButtonTooltipLocation.bottom, message: project.description)
                                        : null,
                                    style: VisirButtonStyle(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                      borderRadius: BorderRadius.circular(borderRaidus),
                                      backgroundColor: context.surfaceVariant,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 16,
                                          height: 16,
                                          decoration: BoxDecoration(color: project.color, borderRadius: BorderRadius.circular(4)),
                                          alignment: Alignment.center,
                                          child: project.icon == null ? null : VisirIcon(type: project.icon!, size: 12, color: Colors.white, isSelected: true),
                                        ),
                                        SizedBox(width: 6),
                                        Flexible(
                                          child: Container(
                                            constraints: BoxConstraints(maxWidth: 120),
                                            child: Text(project.name, style: context.bodyMedium?.textColor(context.shadow), maxLines: 1, overflow: TextOverflow.ellipsis),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              VisirButton(
                                type: VisirButtonAnimationType.scaleAndOpacity,
                                style: VisirButtonStyle(
                                  margin: EdgeInsets.only(left: 6),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: context.outline, width: 0.5),
                                  padding: EdgeInsets.all(5),
                                ),
                                onTap: () {
                                  showTimeSection = !showTimeSection;
                                  setState(() {});
                                },
                                child: VisirIcon(type: VisirIconType.clock, size: 16, isSelected: showTimeSection),
                              ),
                              if (showTimeSection)
                                PopupMenu(
                                  forcePopup: true,
                                  location: PopupMenuLocation.bottom,
                                  width: 284,
                                  borderRadius: 6,
                                  type: ContextMenuActionType.tap,
                                  popup: SelectionWidget<TaskReminderOptionType>(
                                    current: TaskReminderOptionType.none,
                                    items:
                                        isAllDay
                                              ? [TaskReminderOptionType.nineHoursAfter, TaskReminderOptionType.fifteenHoursBefore]
                                              : List<TaskReminderOptionType>.from(TaskReminderOptionType.values)
                                          ..removeWhere(
                                            (e) => (isAllDay ? [] : [TaskReminderOptionType.none, TaskReminderOptionType.fifteenHoursBefore, TaskReminderOptionType.nineHoursAfter])
                                                .contains(e),
                                          ),
                                    getTitle: (type) => type.getSelectionOptionTitle(context, isAllDay),
                                    getChildIsPopup: (type) => type == TaskReminderOptionType.custom,
                                    getChildPopup: (type) => CalendarReminderEditWidget(
                                      initialReminder: null,
                                      isAllDay: isAllDay,
                                      onReminderChanged: (reminder) {
                                        if (!reminders.contains(reminder)) {
                                          isEdited = true;
                                          reminders.add(reminder);
                                          setState(() {});
                                        }

                                        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                                          final navigator = Navigator.maybeOf(Utils.mainContext);
                                          if (navigator != null && navigator.canPop()) navigator.pop();
                                        });
                                      },
                                    ),
                                    onSelect: (type) {
                                      if (type == TaskReminderOptionType.none) {
                                      } else if (type == TaskReminderOptionType.custom) {
                                      } else {
                                        if (!reminders.contains(EventReminderEntity(minutes: type.minutes(), method: 'push'))) {
                                          isEdited = true;
                                          reminders.add(EventReminderEntity(minutes: type.minutes(), method: 'push'));
                                          setState(() {});
                                          onTaskChanged();
                                        }
                                      }
                                    },
                                  ),
                                  style: VisirButtonStyle(
                                    margin: EdgeInsets.only(left: 6),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: context.outline, width: 0.5),
                                    padding: EdgeInsets.all(5),
                                  ),
                                  options: VisirButtonOptions(tabType: widget.tabType, message: context.tr.add_reminder, tooltipLocation: bottomButtonTooltipLocation),
                                  child: VisirIcon(type: VisirIconType.notification, size: 16, isSelected: true),
                                ),
                              Expanded(child: SizedBox.shrink()),
                              if (widget.task != null && widget.forceCreate != true && widget.task?.isBraindump != true)
                                VisirButton(
                                  type: VisirButtonAnimationType.scaleAndOpacity,
                                  style: VisirButtonStyle(
                                    margin: EdgeInsets.only(left: 6),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: context.outline, width: 0.5),
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  ),
                                  onTap: () {
                                    EasyThrottle.throttle('toggleTaskStatus${widget.task?.id}', Duration(milliseconds: 50), () {
                                      if (widget.task == null) return;

                                      final list = ref.read(calendarTaskListControllerProvider(tabType: widget.tabType)).tasksOnView;
                                      final editedRecurringTask = list.firstWhereOrNull((e) => e.recurringTaskId == widget.task!.id && e.startAt == widget.task!.editedStartTime);

                                      TaskEntity? targetTask = widget.task!.isOriginalRecurrenceTask
                                          ? taskStatus == TaskStatus.none
                                                ? editedRecurringTask ?? widget.task
                                                : editedRecurringTask
                                          : widget.task!.copyWith(status: taskStatus);

                                      if (targetTask == null) return;

                                      if (taskStatus == TaskStatus.none)
                                        logAnalyticsEvent(eventName: widget.tabType == TabType.task ? 'task_button_done' : 'home_task_button_done');

                                      TaskAction.toggleStatus(
                                        task: targetTask,
                                        startAt: targetTask.editedStartTime ?? targetTask.startAt!,
                                        endAt: targetTask.editedEndTime ?? targetTask.endAt!,
                                        changeLocalStatus: (newStatus) {
                                          taskStatus = newStatus;
                                          setState(() {});
                                        },
                                        tabType: widget.tabType,
                                      );
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 16,
                                        height: 16,
                                        decoration: ShapeDecoration(
                                          color: [TaskStatus.done, TaskStatus.cancelled].contains(taskStatus) ? project.color : Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(width: 1, color: project.color!),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                        child: [TaskStatus.done, TaskStatus.cancelled].contains(taskStatus)
                                            ? VisirIcon(type: VisirIconType.taskCheck, size: 12, color: context.onPrimary, isSelected: true)
                                            : null,
                                      ),
                                      SizedBox(width: 6),
                                      Text(doneButtonString, style: context.bodyMedium?.textColor(context.shadow), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
