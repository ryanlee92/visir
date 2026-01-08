import 'dart:math';

import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/contextmenu/src/ContextMenuArea.dart';
import 'package:Visir/dependency/modal_bottom_sheet/src/utils/modal_scroll_controller.dart';
import 'package:Visir/dependency/omni_datetime_picker/omni_datetime_picker.dart';
import 'package:Visir/dependency/omni_datetime_picker/src/omni_datetime_picker.dart';
import 'package:Visir/dependency/rrule/src/codecs/text/l10n/l10n.dart';
import 'package:Visir/dependency/rrule/src/recurrence_rule.dart';
import 'package:Visir/dependency/showcase_tutorial/src/enum.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/calendar/domain/entities/event_entity.dart';
import 'package:Visir/features/calendar/domain/entities/event_reminder_entity.dart';
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
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/presentation/widgets/selection_widget.dart';
import 'package:Visir/features/common/presentation/widgets/showcase_wrapper.dart';
import 'package:Visir/features/common/presentation/widgets/visir_app_bar.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/inbox/presentation/widgets/mobile_linked_message_mail_section.dart';
import 'package:Visir/features/inbox/presentation/widgets/agent_input_field.dart';
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
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

class MobileTaskEditWidget extends ConsumerStatefulWidget {
  final TaskEntity? task;
  final bool? isAllDay;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime selectedDate;
  final TabType tabType;
  final bool? isFromInboxDrag;
  final String? titleHintText;
  final String? initialTitle;
  final String? initialDescription;
  final LinkedMessageEntity? originalTaskMessage;
  final LinkedMailEntity? originalTaskMail;
  final CalendarTaskEditSourceType calendarTaskEditSourceType;

  final Widget? eventTaskSwitcher;
  final void Function(String title)? onTitleChanged;
  final void Function(String description)? onDescriptionChanged;
  final void Function(DateTime startDate)? onStartDateChanged;
  final void Function(DateTime endDate)? onEndDateChanged;
  final void Function(bool isAllDay)? onIsAllDayChanged;
  final void Function(ProjectEntity project)? onProjectChanged;

  final Color? backgroundColor;
  final ProjectEntity? initialProject;

  const MobileTaskEditWidget({
    this.task,
    this.isAllDay,
    this.startDate,
    this.endDate,
    this.isFromInboxDrag,
    required this.selectedDate,
    required this.calendarTaskEditSourceType,
    required this.tabType,
    this.titleHintText,
    this.initialTitle,
    this.initialDescription,
    this.originalTaskMessage,
    this.originalTaskMail,
    this.eventTaskSwitcher,
    this.onTitleChanged,
    this.onDescriptionChanged,
    this.onStartDateChanged,
    this.onEndDateChanged,
    this.onIsAllDayChanged,
    this.backgroundColor,
    this.initialProject,
    this.onProjectChanged,
  });

  @override
  _MobileTaskEditWidgetState createState() => _MobileTaskEditWidgetState();
}

class _MobileTaskEditWidgetState extends ConsumerState<MobileTaskEditWidget> {
  String? titleHintText;

  RruleL10n? rruleL10n;

  RecurrenceRule? rrule;
  String? title;
  String? description;

  late DateTime initialStartDate;
  late DateTime initialEndDate;

  late DateTime startDate;
  late DateTime endDate;
  late bool isAllDay;
  late bool isAllDayInitial;

  late DateTime savedStartDate;
  late DateTime savedEndDate;

  List<EventReminderEntity> reminders = [];

  bool doNotSave = false;
  bool isSetDifferentEndDate = false;

  late String taskId;

  late TaskStatus? taskStatus;

  RecurrenceOptionType get recurrenceOptionType =>
      RecurrenceOptionType.values.firstWhereOrNull((e) => e.getRecurrenceRule(startDate) == rrule) ?? RecurrenceOptionType.doesNotRepeat;

  bool get isFromInboxDrag => widget.isFromInboxDrag ?? false;

  ScrollController? _scrollController;

  bool isCopy = false;

  bool get isSavable => widget.titleHintText != null || title?.isNotEmpty == true;

  bool get isTaskTab => widget.tabType == TabType.task;

  bool isUnscheduled = false;

  late ProjectEntity project;
  late List<ProjectEntity> projects;

  @override
  void initState() {
    super.initState();

    if (widget.titleHintText != null) {
      titleHintText = widget.titleHintText;
    }

    final user = ref.read(authControllerProvider).requireValue;

    taskId = widget.task?.id ?? Uuid().v4();
    rruleL10n = ref.read(rruleL10nEnProvider).asData?.value;

    isAllDay = widget.task?.isAllDay ?? widget.isAllDay ?? false;
    isAllDayInitial = isAllDay;

    isUnscheduled = widget.task?.isUnscheduled ?? false;

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

    initialStartDate = startDate;
    initialEndDate = endDate;
    savedStartDate = startDate;
    savedEndDate = endDate;

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

    projects = ref.read(projectListControllerProvider);

    final lastUsedProjectIds = ref.read(lastUsedProjectIdProvider);
    final lastUsedProjectId = lastUsedProjectIds.firstOrNull;
    final lastUsedProject = lastUsedProjectId == null
        ? null
        : ref.read(projectListControllerProvider).firstWhereOrNull((e) => e.isPointedProjectId(lastUsedProjectId));

    project =
        projects.firstWhereOrNull((e) => widget.task != null ? e.isPointedProject(widget.task!) : false) ??
        lastUsedProject ??
        projects.firstWhere((e) => e.isDefault);

    final sortedOrder =
        (projects.where((e) => e.uniqueId != project.uniqueId && e.uniqueId != user.id).toList()
            ..sort((b, a) => (a.updatedAt ?? a.createdAt ?? DateTime(0)).compareTo(b.updatedAt ?? b.createdAt ?? DateTime(0))))
          ..sort((b, a) => (lastUsedProjectIds.indexOf(a.uniqueId)).compareTo(lastUsedProjectIds.indexOf(b.uniqueId)));
    final defaultProject = project.isDefault ? null : projects.firstWhere((e) => e.isDefault);
    projects = [project, if (defaultProject != null) defaultProject, ...sortedOrder];

    title = widget.initialTitle ?? widget.task?.title;
    description = widget.initialDescription ?? widget.task?.description;
    rrule = widget.task?.rrule;

    taskStatus = widget.task?.status;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      UserActionSwtichAction.onTaskAction();
    });
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
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
    if (widget.onStartDateChanged != null) {
      widget.onStartDateChanged!(startDate);
    }
    setState(() {});
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
    if (widget.onEndDateChanged != null) {
      widget.onEndDateChanged!(endDate);
    }

    setState(() {});
  }

  Future<void> delete() async {
    if (widget.task == null) return;
    doNotSave = true;
    TaskAction.deleteTask(
      task: widget.task!,
      calendarTaskEditSourceType: widget.calendarTaskEditSourceType,
      tabType: widget.tabType,
      selectedStartDate: initialStartDate,
      selectedEndDate: initialEndDate.add(Duration(days: isAllDayInitial ? 1 : 0)),
    );
    if (rrule == null) Navigator.of(Utils.mainContext).popUntil((route) => route.isFirst);
  }

  Future<void> copy() async {
    if (widget.task == null) return;
    taskId = Uuid().v4();
    isCopy = true;
    save();
  }

  Future<void> save() async {
    if (doNotSave) return;
    if (widget.titleHintText != null && (title ?? '').isEmpty) {
      title = widget.titleHintText;
    }
    if (title?.isNotEmpty != true) return;
    final user = ref.read(authControllerProvider).requireValue;

    final recurrenceEndAt = isUnscheduled
        ? DateTime(3000)
        : rrule == null
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
      description: description,
      startAt: isUnscheduled ? null : startDate,
      endAt: isUnscheduled ? null : endDate.add(Duration(days: isAllDay ? 1 : 0)),
      isAllDay: isAllDay,
      rrule: rrule,
      excludedRecurrenceDate: [],
      recurrenceEndAt: recurrenceEndAt,
      linkedMails: widget.originalTaskMail == null ? widget.task?.linkedMails ?? [] : [widget.originalTaskMail!],
      linkedMessages: widget.originalTaskMessage == null ? widget.task?.linkedMessages ?? [] : [widget.originalTaskMessage!],
      reminders: reminders,
      projectId: project.uniqueId,
      status: taskStatus ?? TaskStatus.none,
      createdAt: widget.task?.createdAt ?? DateTime.now(),
      doNotApplyDateOffset: true,
    );

    ref.read(inboxLastCreateEventTypeProvider.notifier).update(InboxLastCreateEventType.task);
    ref.read(lastUsedProjectIdProvider.notifier).set(project.uniqueId);

    await TaskAction.upsertTask(
      task: task,
      originalTask: isCopy ? null : widget.task,
      calendarTaskEditSourceType: widget.calendarTaskEditSourceType,
      tabType: widget.tabType,
      selectedStartDate: initialStartDate,
      selectedEndDate: initialEndDate.add(Duration(days: isAllDayInitial ? 1 : 0)),
      showToast: widget.originalTaskMail != null || widget.originalTaskMessage != null || isFromInboxDrag,
    );

    if (rrule == null || widget.task == null) {
      Navigator.of(Utils.mainContext).popUntil((route) => route.isFirst);
    }
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

  void updateProject(ProjectEntity project) {
    this.project = project;
    setState(() {});
    if (widget.onProjectChanged != null) {
      widget.onProjectChanged!(project);
    }
  }

  void startChat() {
    print('[startChat] MobileTaskEditWidget: startChat called');
    // Get current task - only tag if task exists
    TaskEntity? currentTask = widget.task;
    print('[startChat] MobileTaskEditWidget: widget.task = ${widget.task?.id}');
    if (currentTask == null) {
      print('[startChat] MobileTaskEditWidget: currentTask is null, returning');
      return;
    }

    print('[startChat] MobileTaskEditWidget: currentTask = ${currentTask.id}, title = ${currentTask.title}');
    print('[startChat] MobileTaskEditWidget: Navigating to home tab');

    // Navigate to home tab
    Navigator.maybeOf(Utils.mainContext)?.popUntil((route) => route.isFirst);
    tabNotifier.value = TabType.home;
    UserActionSwtichAction.onSwtichTab(targetTab: TabType.home);

    print('[startChat] MobileTaskEditWidget: Tab switched, waiting for postFrameCallback');

    // Add tag to AgentInputField after navigation - retry multiple times
    void tryAddTag({int retryCount = 0}) {
      // Find AgentInputFieldState from widget tree
      AgentInputFieldState? agentInputFieldState;
      try {
        agentInputFieldState = AgentInputField.of(Utils.mainContext);
        print('[startChat] MobileTaskEditWidget: Try $retryCount - agentInputFieldState = ${agentInputFieldState != null ? "found" : "null"}');
      } catch (e) {
        print('[startChat] MobileTaskEditWidget: Error finding via widget tree: $e');
      }
      
      // Check if state is valid and mounted
      if (agentInputFieldState != null && agentInputFieldState.mounted) {
        // Check if messageController is still valid (not disposed)
        try {
          // Try to access messageController to check if it's disposed
          final controller = agentInputFieldState.messageController;
          final _ = controller.text; // This will throw if disposed
          
          print('[startChat] MobileTaskEditWidget: Adding tag for task ${currentTask.id}');
          agentInputFieldState.addTaskTag(currentTask);
          agentInputFieldState.requestFocus();
          print('[startChat] MobileTaskEditWidget: Tag added and focus requested');
        } catch (e) {
          print('[startChat] MobileTaskEditWidget: messageController is disposed or invalid: $e');
          if (retryCount < 5) {
            print('[startChat] MobileTaskEditWidget: Retrying in ${(retryCount + 1) * 200}ms...');
            Future.delayed(Duration(milliseconds: (retryCount + 1) * 200), () {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                tryAddTag(retryCount: retryCount + 1);
              });
            });
          } else {
            print('[startChat] MobileTaskEditWidget: Failed after 5 retries - controller disposed');
          }
        }
      } else if (retryCount < 5) {
        print('[startChat] MobileTaskEditWidget: Retrying in ${(retryCount + 1) * 200}ms...');
        Future.delayed(Duration(milliseconds: (retryCount + 1) * 200), () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            tryAddTag(retryCount: retryCount + 1);
          });
        });
      } else {
        print('[startChat] MobileTaskEditWidget: Failed after 5 retries');
      }
    }

    Future.delayed(Duration(milliseconds: 300), () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        tryAddTag();
      });
    });
  }

  Widget bodyDivider() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Divider(height: 1, thickness: 1, color: context.surface),
  );

  @override
  Widget build(BuildContext context) {
    _scrollController ??= ModalScrollController.ofSyncGroup(context)?.addAndGet() ?? ScrollController();
    return VisirButton(
      type: VisirButtonAnimationType.none,
      onTap: () {
        if (FocusScope.of(context).hasFocus) FocusScope.of(context).unfocus();
      },
      style: VisirButtonStyle(),
      child: Container(
        color: widget.backgroundColor ?? context.background,
        child: FocusTraversalGroup(
          child: Column(
            children: [
              VisirAppBar(
                title: (widget.task == null || isFromInboxDrag) ? context.tr.mobile_task_edit_create_task : context.tr.mobile_task_edit_edit_task,
                leadings: [
                  VisirAppBarButton(
                    icon: VisirIconType.close,
                    onTap: Utils.mainContext.pop,
                    options: VisirButtonOptions(
                      tooltipLocation: VisirButtonTooltipLocation.right,
                      shortcuts: [
                        VisirButtonKeyboardShortcut(message: context.tr.close, keys: [LogicalKeyboardKey.escape]),
                      ],
                    ),
                  ),
                ],
                trailings: [
                  if (widget.task != null && !isFromInboxDrag)
                    VisirAppBarButton(
                      onTap: title?.isNotEmpty == true
                          ? () {
                              if (rrule == null) {
                                Utils.showMobileConfirmPopup(
                                  title: context.tr.delete_event_confirm_popup_title,
                                  description: context.tr.delete_event_confirm_popup_description,
                                  cancelString: context.tr.delete_event_confirm_popup_cancel,
                                  confirmString: context.tr.delete_event_confirm_popup_delete,
                                  isWarning: true,
                                  onPressConfirm: delete,
                                );
                              } else {
                                delete();
                              }
                            }
                          : null,
                      icon: VisirIconType.trash,
                    ),
                  if (widget.task != null && !isFromInboxDrag) VisirAppBarButton(onTap: title?.isNotEmpty == true ? copy : null, icon: VisirIconType.copy),
                  if (widget.eventTaskSwitcher != null) VisirAppBarButton(child: widget.eventTaskSwitcher!, isContainer: true),
                  VisirAppBarButton(
                    onTap: widget.task != null ? startChat : null,
                    options: VisirButtonOptions(
                      shortcuts: [
                        VisirButtonKeyboardShortcut(
                          message: 'Start chat',
                          keys: [LogicalKeyboardKey.keyL, if (PlatformX.isApple) LogicalKeyboardKey.meta, if (!PlatformX.isApple) LogicalKeyboardKey.control],
                        ),
                      ],
                    ),
                    child: VisirIcon(type: VisirIconType.at, color: context.onInverseSurface, size: 16, isSelected: true),
                  ),
                  VisirAppBarButton(onTap: isSavable ? save : null, icon: VisirIconType.check),
                ],
              ),
              (_scrollController == null)
                  ? SizedBox.shrink()
                  : Expanded(
                      child: ShowcaseWrapper(
                        showcaseKey: taskLinkedMailShowcaseKeyString,
                        tooltipPosition: TooltipPosition.top,
                        child: SingleChildScrollView(
                          physics: Utils.getScrollPhysicsForBottomSheet(context, _scrollController),
                          controller: _scrollController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: CollapsingTextFormField(
                                  initialValue: title ?? '',
                                  textInputAction: TextInputAction.go,
                                  autofocus: widget.task == null,
                                  collapsedLines: 2,
                                  style: context.titleSmall?.textColor(context.outlineVariant),
                                  decoration: InputDecoration(
                                    hintText: titleHintText ?? context.tr.inbox_task_title,
                                    hintStyle: context.titleMedium?.textColor(context.surfaceTint),
                                    fillColor: Colors.transparent,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 13),
                                    hoverColor: Colors.transparent,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                    isCollapsed: true,
                                  ),
                                  onChanged: (text) {
                                    if (text.isEmpty) {
                                      titleHintText = widget.titleHintText ?? context.tr.inbox_task_title;
                                    } else {
                                      titleHintText = '';
                                    }

                                    title = text;
                                    if (widget.onTitleChanged != null) {
                                      widget.onTitleChanged!(title ?? text);
                                    }
                                    setState(() {});
                                  },
                                ),
                              ),
                              bodyDivider(),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(top: context.textFieldPadding(16)),
                                      child: VisirIcon(type: VisirIconType.description, size: 20, isSelected: (description ?? '').isNotEmpty),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: CollapsingTextFormField(
                                        initialValue: description ?? '',
                                        textInputAction: TextInputAction.newline,
                                        style: context.titleMedium?.copyWith(color: context.outlineVariant),
                                        collapsedLines: 5,
                                        decoration: InputDecoration(
                                          constraints: BoxConstraints(minHeight: 44),
                                          hintText: context.tr.description,
                                          contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 16),
                                          border: OutlineInputBorder(borderSide: BorderSide.none),
                                          fillColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          filled: true,
                                          isDense: true,
                                          hintStyle: context.titleMedium?.copyWith(color: context.surfaceTint),
                                        ),
                                        onChanged: (text) {
                                          description = text;
                                          if (widget.onDescriptionChanged != null) {
                                            widget.onDescriptionChanged!(description ?? text);
                                          }
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              bodyDivider(),
                              MobileLinkedMessageMailSection(
                                bodyDivider: bodyDivider(),
                                originalTaskMessage: widget.originalTaskMessage,
                                originalTaskMail: widget.originalTaskMail,
                                tabType: widget.tabType,
                                linkedMessages: widget.task?.linkedMessages,
                                linkedMails: widget.task?.linkedMails,
                                isEvent: false,
                              ),
                              Column(
                                children: [
                                  const SizedBox(height: 16),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: 36,
                                          alignment: Alignment.centerLeft,
                                          child: VisirIcon(type: VisirIconType.clock, size: 20, isSelected: !isUnscheduled),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: isUnscheduled
                                              ? Row(
                                                  children: [
                                                    IntrinsicWidth(
                                                      child: VisirButton(
                                                        type: VisirButtonAnimationType.scaleAndOpacity,
                                                        style: VisirButtonStyle(
                                                          cursor: SystemMouseCursors.click,
                                                          height: 36,
                                                          backgroundColor: context.surface,
                                                          borderRadius: BorderRadius.circular(8),
                                                          padding: EdgeInsets.symmetric(horizontal: 10),
                                                        ),
                                                        onTap: () {
                                                          final user = ref.read(authControllerProvider).requireValue;
                                                          DateTime now = DateTime.now();
                                                          startDate = DateTime(now.year, now.month, now.day, now.hour, (now.minute ~/ 15 + 1) * 15);
                                                          endDate = startDate.add(
                                                            isAllDay ? Duration(days: 1) : Duration(minutes: user.userTaskDefaultDurationInMinutes),
                                                          );
                                                          isUnscheduled = false;
                                                          setState(() {});
                                                        },
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            VisirIcon(type: VisirIconType.add, size: 12),
                                                            const SizedBox(width: 6),
                                                            Text(context.tr.task_set_date, style: context.bodyLarge?.textColor(context.outlineVariant)),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : Wrap(
                                                  spacing: 8,
                                                  runSpacing: 6,
                                                  children: [
                                                    PopupMenu(
                                                      beforePopup: () => FocusScope.of(context).unfocus(),
                                                      width: 296,
                                                      height: 300,
                                                      forcePopup: true,
                                                      location: PopupMenuLocation.bottom,
                                                      type: ContextMenuActionType.tap,
                                                      popup: OmniDateTimePicker(
                                                        type: OmniDateTimePickerType.date,
                                                        initialDate: startDate,
                                                        backgroundColor: context.surface,
                                                        onDateChanged: setStartDateTime,
                                                      ),
                                                      style: VisirButtonStyle(
                                                        padding: EdgeInsets.only(left: 10, right: 2),
                                                        backgroundColor: context.surface,
                                                        borderRadius: BorderRadius.circular(8),
                                                        height: 36,
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            EventEntity.getDateForEditSimple(startDate),
                                                            style: context.titleSmall?.textColor(context.outlineVariant),
                                                          ),
                                                          VisirButton(
                                                            type: VisirButtonAnimationType.scaleAndOpacity,
                                                            style: VisirButtonStyle(padding: EdgeInsets.all(6), hoverColor: Colors.transparent),
                                                            onTap: () {
                                                              isUnscheduled = true;
                                                              setState(() {});
                                                            },
                                                            child: VisirIcon(type: VisirIconType.closeWithCircle, size: 16, isSelected: true),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    if (!isAllDay)
                                                      PopupMenu(
                                                        beforePopup: () => FocusScope.of(context).unfocus(),
                                                        width: 248,
                                                        height: 156,
                                                        forcePopup: true,
                                                        location: PopupMenuLocation.bottom,
                                                        type: ContextMenuActionType.tap,
                                                        popup: OmniDateTimePicker(
                                                          type: OmniDateTimePickerType.time,
                                                          initialDate: startDate,
                                                          onDateChanged: setStartDateTime,
                                                          minutesInterval: 5,
                                                        ),
                                                        style: VisirButtonStyle(
                                                          padding: EdgeInsets.symmetric(horizontal: 10),
                                                          backgroundColor: context.surface,
                                                          borderRadius: BorderRadius.circular(8),
                                                          height: 36,
                                                        ),
                                                        child: Text(
                                                          EventEntity.getTimeForEditWithMinutes(startDate),
                                                          style: context.titleSmall!.textColor(context.outlineVariant),
                                                        ),
                                                      ),
                                                    if (isSetDifferentEndDate || isAllDay) ...[
                                                      if (isSetDifferentEndDate) SizedBox(width: double.infinity),
                                                      PopupMenu(
                                                        beforePopup: () => FocusScope.of(context).unfocus(),
                                                        width: 296,
                                                        height: 300,
                                                        forcePopup: true,
                                                        location: PopupMenuLocation.bottom,
                                                        type: ContextMenuActionType.tap,
                                                        popup: OmniDateTimePicker(
                                                          type: OmniDateTimePickerType.date,
                                                          initialDate: endDate,
                                                          backgroundColor: context.surface,
                                                          onDateChanged: setEndDateTime,
                                                        ),
                                                        style: VisirButtonStyle(
                                                          padding: EdgeInsets.only(left: 10, right: 2),
                                                          backgroundColor: context.surface,
                                                          borderRadius: BorderRadius.circular(8),
                                                          height: 36,
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              EventEntity.getDateForEditSimple(endDate),
                                                              style: context.titleSmall?.textColor(context.outlineVariant),
                                                            ),
                                                            VisirButton(
                                                              type: VisirButtonAnimationType.scaleAndOpacity,
                                                              style: VisirButtonStyle(padding: EdgeInsets.all(6), hoverColor: Colors.transparent),
                                                              onTap: () {
                                                                isUnscheduled = true;
                                                                setState(() {});
                                                              },
                                                              child: VisirIcon(type: VisirIconType.closeWithCircle, size: 16, isSelected: true),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                    if (!isAllDay)
                                                      PopupMenu(
                                                        beforePopup: () => FocusScope.of(context).unfocus(),
                                                        width: 248,
                                                        height: 156 + 8 + 42,
                                                        forcePopup: true,
                                                        location: PopupMenuLocation.bottom,
                                                        type: ContextMenuActionType.tap,
                                                        backgroundColor: Colors.transparent,
                                                        hideShadow: true,
                                                        popup: Column(
                                                          children: [
                                                            Container(
                                                              margin: EdgeInsets.only(bottom: 8),
                                                              decoration: BoxDecoration(
                                                                color: context.surface,
                                                                borderRadius: BorderRadius.circular(12),
                                                                border: Border.all(color: context.outline, width: 0.5),
                                                              ),
                                                              child: OmniDateTimePicker(
                                                                type: OmniDateTimePickerType.time,
                                                                initialDate: endDate,
                                                                onDateChanged: setEndDateTime,
                                                                minutesInterval: 5,
                                                              ),
                                                            ),
                                                            ClipRRect(
                                                              borderRadius: BorderRadius.circular(12),
                                                              child: VisirButton(
                                                                type: VisirButtonAnimationType.scaleAndOpacity,
                                                                style: VisirButtonStyle(
                                                                  backgroundColor: context.tertiary,
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: Colors.black.withValues(alpha: 0.25),
                                                                      blurRadius: 12,
                                                                      offset: Offset(0, 4),
                                                                    ),
                                                                  ],
                                                                  height: 42,
                                                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                                                                  borderRadius: BorderRadius.circular(12),
                                                                ),
                                                                onTap: () {
                                                                  setState(() {
                                                                    isSetDifferentEndDate = true;
                                                                    context.pop();
                                                                  });
                                                                },
                                                                child: Row(
                                                                  children: [
                                                                    VisirIcon(type: VisirIconType.calendar, size: 20, color: context.onTertiary),
                                                                    const SizedBox(width: 10),
                                                                    Text(
                                                                      context.tr.set_different_end_date,
                                                                      style: context.titleMedium?.textColor(context.onTertiary),
                                                                    ),
                                                                    Expanded(child: Container()),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        style: VisirButtonStyle(
                                                          padding: EdgeInsets.symmetric(horizontal: 10),
                                                          backgroundColor: context.surface,
                                                          borderRadius: BorderRadius.circular(8),
                                                          height: 36,
                                                        ),
                                                        child: Text(
                                                          EventEntity.getTimeForEditWithMinutes(endDate),
                                                          style: context.titleSmall!.textColor(context.outlineVariant),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (!isAllDay && !isUnscheduled)
                                    Container(
                                      width: double.maxFinite,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 44, top: 12, right: 12),
                                          child: Row(
                                            children: [15, 30, 45, 60, 75, 90, 120].map((e) {
                                              final selected = e == endDate.difference(startDate).inMinutes;
                                              return VisirButton(
                                                type: VisirButtonAnimationType.scaleAndOpacity,
                                                style: VisirButtonStyle(
                                                  backgroundColor: selected ? context.primary : Colors.transparent,
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(color: selected ? Colors.transparent : context.surface, width: 1),
                                                  margin: EdgeInsets.symmetric(horizontal: 4),
                                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                                  height: 36,
                                                ),
                                                onTap: () {
                                                  endDate = startDate.add(Duration(minutes: e));
                                                  savedEndDate = endDate;
                                                  setState(() {});
                                                },
                                                child: Text(
                                                  e < 60
                                                      ? '${e}m'
                                                      : e % 60 == 0
                                                      ? '${e ~/ 60}h'
                                                      : '${e ~/ 60}h ${e % 60}m',
                                                  style: context.titleSmall?.textColor(selected ? context.onPrimary : context.outlineVariant),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (!isUnscheduled)
                                    Container(
                                      width: double.maxFinite,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 44, top: 12, right: 16),
                                          child: Row(
                                            children: [
                                              VisirButton(
                                                type: VisirButtonAnimationType.scaleAndOpacity,
                                                style: VisirButtonStyle(
                                                  margin: EdgeInsets.symmetric(horizontal: 4),
                                                  backgroundColor: isAllDay ? context.primary : Colors.transparent,
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(color: isAllDay ? Colors.transparent : context.surface, width: 1),
                                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                                  height: 36,
                                                ),
                                                onTap: () {
                                                  isAllDay = !isAllDay;

                                                  final user = ref.read(authControllerProvider).requireValue;
                                                  final defaultTaskReminderType = user.userDefaultTaskReminderType;
                                                  final defaultAllDayTaskReminderType = user.userDefaultAllDayTaskReminderType;

                                                  reminders = isAllDay
                                                      ? defaultAllDayTaskReminderType == TaskReminderOptionType.none
                                                            ? []
                                                            : [EventReminderEntity(method: 'push', minutes: defaultAllDayTaskReminderType.minutes())]
                                                      : defaultTaskReminderType == TaskReminderOptionType.none
                                                      ? []
                                                      : [EventReminderEntity(method: 'push', minutes: defaultTaskReminderType.minutes())];

                                                  if (isAllDay) {
                                                    final startDateTime = DateUtils.dateOnly(startDate);
                                                    final endDateTime = DateUtils.dateOnly(endDate.compareTo(startDateTime) < 0 ? startDateTime : endDate);

                                                    startDate = DateUtils.dateOnly(startDateTime);
                                                    endDate = DateUtils.dateOnly(endDateTime);
                                                  } else {
                                                    final startDateTime = DateTime(
                                                      startDate.year,
                                                      startDate.month,
                                                      startDate.day,
                                                      savedStartDate.hour,
                                                      savedStartDate.minute,
                                                    );
                                                    final endDateTime = DateTime(
                                                      endDate.year,
                                                      endDate.month,
                                                      endDate.day,
                                                      savedEndDate.hour,
                                                      savedEndDate.minute,
                                                    );

                                                    startDate = startDateTime;
                                                    endDate = endDateTime;
                                                    savedStartDate = startDate;
                                                    savedEndDate = endDate;
                                                  }
                                                  if (widget.onIsAllDayChanged != null) {
                                                    widget.onIsAllDayChanged!(isAllDay);
                                                  }
                                                  setState(() {});
                                                },
                                                child: Text(
                                                  context.tr.all_day,
                                                  style: context.titleSmall?.textColor(isAllDay ? context.onPrimary : context.outlineVariant),
                                                ),
                                              ),
                                              SizedBox(width: 4),
                                              PopupMenu(
                                                beforePopup: () => FocusScope.of(context).unfocus(),
                                                forcePopup: true,
                                                location: PopupMenuLocation.bottom,
                                                width: 240,
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
                                                      this.rrule = rrule;
                                                      setState(() {});

                                                      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                                                        if (Navigator.of(Utils.mainContext).canPop()) Navigator.of(Utils.mainContext).pop();
                                                      });
                                                    },
                                                  ),
                                                  onSelect: (rruleOptionType) {
                                                    switch (rruleOptionType) {
                                                      case RecurrenceOptionType.doesNotRepeat:
                                                        this.rrule = null;
                                                        setState(() {});
                                                      case RecurrenceOptionType.daily:
                                                      case RecurrenceOptionType.weeklyByWeekDay:
                                                      case RecurrenceOptionType.monthlyByWeekDay:
                                                      case RecurrenceOptionType.monthlyByMonthDay:
                                                      case RecurrenceOptionType.annualy:
                                                      case RecurrenceOptionType.weekdays:
                                                        this.rrule = rruleOptionType.getRecurrenceRule(startDate);
                                                        setState(() {});
                                                      case RecurrenceOptionType.custom:
                                                        break;
                                                    }
                                                  },
                                                ),
                                                style: VisirButtonStyle(
                                                  backgroundColor: !(rruleL10n == null || rrule == null) ? context.primary : Colors.transparent,
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: !(rruleL10n == null || rrule == null) ? Colors.transparent : context.surface,
                                                    width: 1,
                                                  ),
                                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                                  height: 36,
                                                ),
                                                child: Text(
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  rruleL10n == null || rrule == null
                                                      ? context.tr.calendar_event_edit_repeat
                                                      : recurrenceOptionType == RecurrenceOptionType.annualy ||
                                                            recurrenceOptionType == RecurrenceOptionType.weekdays
                                                      ? recurrenceOptionType.getSelectionOptionTitle(rruleL10n, startDate, context)
                                                      : rrule!.toText(l10n: rruleL10n!),
                                                  style: context.titleSmall?.textColor(
                                                    !(rruleL10n == null || rrule == null) ? context.onPrimary : context.outlineVariant,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 16),
                                  bodyDivider(),
                                ],
                              ),

                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(color: project.color, borderRadius: BorderRadius.circular(6)),
                                          alignment: Alignment.center,
                                          child: project.icon == null ? null : VisirIcon(type: project.icon!, size: 12, color: Colors.white, isSelected: true),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: LayoutBuilder(
                                            builder: (context, constraints) {
                                              return PopupMenu(
                                                beforePopup: () => FocusScope.of(context).unfocus(),
                                                forcePopup: true,
                                                location: PopupMenuLocation.bottom,
                                                width: constraints.maxWidth,
                                                borderRadius: 6,
                                                type: ContextMenuActionType.tap,
                                                popup: Builder(
                                                  builder: (context) {
                                                    final sortedProjects = projects.sortedProjectWithDepth;
                                                    return SelectionWidget<ProjectEntity>(
                                                      current: project,
                                                      options: (project) => VisirButtonOptions(
                                                        tooltipLocation: project.description?.isNotEmpty == true
                                                            ? VisirButtonTooltipLocation.bottom
                                                            : VisirButtonTooltipLocation.none,
                                                        message: project.description,
                                                      ),
                                                      items: sortedProjects.map((e) => e.project).toList(),
                                                      getChild: (project) {
                                                        final depth =
                                                            sortedProjects.firstWhereOrNull((e) => e.project.uniqueId == project.uniqueId)?.depth ?? 0;
                                                        return Row(
                                                          children: [
                                                            SizedBox(width: 10 + depth * 12),
                                                            Container(
                                                              width: 16,
                                                              height: 16,
                                                              decoration: BoxDecoration(color: project.color, borderRadius: BorderRadius.circular(6)),
                                                              alignment: Alignment.center,
                                                              child: project.icon == null
                                                                  ? null
                                                                  : VisirIcon(type: project.icon!, size: 12, color: Colors.white, isSelected: true),
                                                            ),
                                                            SizedBox(width: 6),
                                                            Expanded(
                                                              child: Text(
                                                                project.name,
                                                                style: context.bodyLarge!.textColor(context.outlineVariant),
                                                                maxLines: 1,
                                                                overflow: TextOverflow.ellipsis,
                                                              ),
                                                            ),
                                                            SizedBox(width: 12),
                                                          ],
                                                        );
                                                      },
                                                      onSelect: updateProject,
                                                    );
                                                  },
                                                ),

                                                options: project.description?.isNotEmpty == true
                                                    ? VisirButtonOptions(tooltipLocation: VisirButtonTooltipLocation.bottom, message: project.description)
                                                    : null,
                                                style: VisirButtonStyle(
                                                  height: 28,
                                                  width: double.maxFinite,
                                                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Expanded(child: Text(project.name, style: context.titleMedium?.textColor(context.outlineVariant))),
                                                    VisirIcon(type: VisirIconType.arrowDown, size: 12),
                                                    SizedBox(width: 8),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 44, right: 16),
                                        child: Row(
                                          children: projects
                                              .sublist(0, projects.length)
                                              .map(
                                                (e) => IntrinsicWidth(
                                                  child: VisirButton(
                                                    type: VisirButtonAnimationType.scaleAndOpacity,
                                                    options: e.description?.isNotEmpty == true
                                                        ? VisirButtonOptions(tooltipLocation: VisirButtonTooltipLocation.bottom, message: e.description)
                                                        : null,
                                                    style: VisirButtonStyle(
                                                      margin: EdgeInsets.symmetric(horizontal: 4),
                                                      alignment: Alignment.centerLeft,
                                                      height: 36,
                                                      backgroundColor: e.uniqueId == project.uniqueId ? e.color : Colors.transparent,
                                                      borderRadius: BorderRadius.circular(8),
                                                      border: Border.all(
                                                        color: e.uniqueId == project.uniqueId ? Colors.transparent : context.surface,
                                                        width: 1,
                                                      ),
                                                      padding: EdgeInsets.symmetric(horizontal: 8),
                                                    ),
                                                    onTap: () => updateProject(e),
                                                    child: Row(
                                                      children: [
                                                        if (e.icon != null)
                                                          VisirIcon(
                                                            type: e.icon!,
                                                            color: e.uniqueId == project.uniqueId ? Colors.white : e.color,
                                                            size: 14,
                                                            isSelected: true,
                                                          ),
                                                        if (e.icon == null)
                                                          Container(
                                                            decoration: BoxDecoration(
                                                              color: e.uniqueId == project.uniqueId ? Colors.white : e.color,
                                                              borderRadius: BorderRadius.circular(6),
                                                            ),
                                                            width: 14,
                                                            height: 14,
                                                          ),
                                                        SizedBox(width: 6),
                                                        Text(
                                                          e.name,
                                                          style: context.titleSmall?.textColor(
                                                            e.uniqueId == project.uniqueId ? Colors.white : context.outlineVariant,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  bodyDivider(),
                                ],
                              ),
                              if (reminders.isNotEmpty) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(vertical: 16),
                                        child: VisirIcon(type: VisirIconType.notification, size: 20, isSelected: reminders.isNotEmpty),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Wrap(
                                                spacing: 8,
                                                runSpacing: 8,
                                                children: reminders.map((e) {
                                                  return Container(
                                                    height: 36,
                                                    decoration: BoxDecoration(color: context.surface, borderRadius: BorderRadius.circular(8)),
                                                    padding: EdgeInsets.only(left: 10, right: 2),
                                                    child: IntrinsicWidth(
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            getReminderString(context: context, isAllDay: isAllDay, minute: e.minutes ?? 0),
                                                            style: context.titleSmall?.textColor(context.outlineVariant),
                                                          ),
                                                          VisirButton(
                                                            type: VisirButtonAnimationType.scaleAndOpacity,
                                                            style: VisirButtonStyle(padding: EdgeInsets.all(8)),
                                                            onTap: () {
                                                              reminders.remove(e);
                                                              setState(() {});
                                                            },
                                                            child: VisirIcon(type: VisirIconType.closeWithCircle, size: 16, isSelected: true),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                bodyDivider(),
                              ],
                              SizedBox(height: 12),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  return SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        SizedBox(width: 16),
                                        if (widget.task != null && !isFromInboxDrag)
                                          VisirButton(
                                            type: VisirButtonAnimationType.scaleAndOpacity,
                                            style: VisirButtonStyle(
                                              margin: EdgeInsets.only(right: 8),
                                              backgroundColor: Colors.transparent,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: context.surface, width: 1),
                                              padding: EdgeInsets.symmetric(horizontal: 10),
                                              height: 36,
                                            ),
                                            onTap: () {
                                              EasyThrottle.throttle('toggleTaskStatus${widget.task?.id}', Duration(milliseconds: 50), () {
                                                if (taskStatus == TaskStatus.none) if (widget.task == null) return;

                                                final list = ref.read(calendarTaskListControllerProvider(tabType: widget.tabType)).tasksOnView;
                                                final editedRecurringTask = list.firstWhereOrNull(
                                                  (e) => e.recurringTaskId == widget.task!.id && e.startAt == widget.task!.editedStartTime,
                                                );

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
                                                      ? VisirIcon(type: VisirIconType.check, size: 12, color: context.onPrimary)
                                                      : null,
                                                ),
                                                SizedBox(width: 10),
                                                Text(doneButtonString, style: context.titleSmall?.textColor(context.outlineVariant)),
                                              ],
                                            ),
                                          ),

                                        PopupMenu(
                                          beforePopup: () => FocusScope.of(context).unfocus(),
                                          forcePopup: true,
                                          location: PopupMenuLocation.bottom,
                                          width: min(240, constraints.maxWidth),
                                          type: ContextMenuActionType.tap,
                                          popup: SelectionWidget<TaskReminderOptionType>(
                                            current: TaskReminderOptionType.none,
                                            items:
                                                isAllDay
                                                      ? [TaskReminderOptionType.nineHoursAfter, TaskReminderOptionType.fifteenHoursBefore]
                                                      : List<TaskReminderOptionType>.from(TaskReminderOptionType.values)
                                                  ..removeWhere(
                                                    (e) =>
                                                        (isAllDay
                                                                ? []
                                                                : [
                                                                    TaskReminderOptionType.none,
                                                                    TaskReminderOptionType.fifteenHoursBefore,
                                                                    TaskReminderOptionType.nineHoursAfter,
                                                                  ])
                                                            .contains(e),
                                                  ),
                                            getTitle: (type) => type.getSelectionOptionTitle(context, isAllDay),
                                            getChildIsPopup: (type) => type == TaskReminderOptionType.custom,
                                            getChildPopup: (type) => CalendarReminderEditWidget(
                                              initialReminder: EventReminderEntity(minutes: 10, method: 'popup'),
                                              isAllDay: isAllDay,
                                              onReminderChanged: (reminder) {
                                                if (!reminders.contains(reminder)) {
                                                  reminders.add(reminder);
                                                  setState(() {});
                                                }

                                                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                                                  if (Navigator.of(Utils.mainContext).canPop()) Navigator.of(Utils.mainContext).pop();
                                                });
                                              },
                                            ),
                                            onSelect: (type) {
                                              if (type == TaskReminderOptionType.none) {
                                              } else if (type == TaskReminderOptionType.custom) {
                                              } else {
                                                if (!reminders.contains(EventReminderEntity(minutes: type.minutes(), method: 'popup'))) {
                                                  reminders.add(EventReminderEntity(minutes: type.minutes(), method: 'popup'));
                                                  setState(() {});
                                                }
                                              }
                                            },
                                          ),
                                          style: VisirButtonStyle(
                                            margin: EdgeInsets.only(right: 8),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: context.surface, width: 1),
                                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                                            height: 36,
                                          ),
                                          child: Row(
                                            children: [
                                              VisirIcon(type: VisirIconType.notification, size: 16, isSelected: true),
                                              SizedBox(width: 10),
                                              Text(context.tr.reminder, style: context.titleSmall?.textColor(context.outlineVariant)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: scrollViewBottomPadding.bottom + context.viewInset.bottom),
                            ],
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
