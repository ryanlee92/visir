import 'dart:async';

import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/contextmenu/src/ContextMenuArea.dart';
import 'package:Visir/dependency/master_detail_flow/src/details_item.dart';
import 'package:Visir/dependency/master_detail_flow/src/flow_settings.dart';
import 'package:Visir/dependency/omni_datetime_picker/omni_datetime_picker.dart';
import 'package:Visir/dependency/omni_datetime_picker/src/omni_datetime_picker.dart';
import 'package:Visir/dependency/rrule/src/codecs/text/l10n/l10n.dart';
import 'package:Visir/dependency/rrule/src/recurrence_rule.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/calendar/domain/entities/event_entity.dart';
import 'package:Visir/features/calendar/domain/entities/event_reminder_entity.dart';
import 'package:Visir/features/calendar/presentation/widgets/calendar_desktop_time_field_simple_create.dart';
import 'package:Visir/features/calendar/presentation/widgets/calendar_reminder_edit_widget.dart';
import 'package:Visir/features/calendar/presentation/widgets/calendar_rrule_edit_widget.dart';
import 'package:Visir/features/calendar/presentation/widgets/calendar_simple_create_widget.dart';
import 'package:Visir/features/chat/application/chat_channel_list_controller.dart';
import 'package:Visir/features/chat/domain/entities/message_entity.dart';
import 'package:Visir/features/chat/presentation/screens/chat_list_screen.dart';
import 'package:Visir/features/chat/providers.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/collapse_text_field.dart';
import 'package:Visir/features/common/presentation/widgets/keyboard_shortcut.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/presentation/widgets/selection_widget.dart';
import 'package:Visir/features/common/presentation/widgets/visir_app_bar.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/mail/domain/entities/mail_entity.dart';
import 'package:Visir/features/mail/domain/entities/mail_label_entity.dart';
import 'package:Visir/features/mail/presentation/screens/mail_detail_screen.dart';
import 'package:Visir/features/mail/providers.dart';
import 'package:Visir/features/task/actions.dart';
import 'package:Visir/features/task/application/project_list_controller.dart';
import 'package:Visir/features/task/application/task_list_controller.dart';
import 'package:Visir/features/task/domain/entities/project_entity.dart';
import 'package:Visir/features/task/domain/entities/task_entity.dart';
import 'package:Visir/features/task/domain/entities/task_reminder_option_type.dart';
import 'package:Visir/features/time_saved/actions.dart';
import 'package:collection/collection.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time/time.dart';
import 'package:uuid/uuid.dart';

class TaskListTaskDetailScreen extends ConsumerStatefulWidget {
  final TaskEntity task;
  final VoidCallback close;
  final TabType tabType;
  final bool autoFocus;
  final Color? backgroundColor;

  final void Function(Widget? details)? showDetilas;

  const TaskListTaskDetailScreen({super.key, required this.task, required this.close, required this.tabType, required this.autoFocus, this.backgroundColor, this.showDetilas});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TaskListTaskDetailScreenState();
}

class _TaskListTaskDetailScreenState extends ConsumerState<TaskListTaskDetailScreen> {
  final FocusNode titleFocusNode = FocusNode();
  final FocusNode descriptionFocusNode = FocusNode();

  late TextEditingController titleEditingController;
  late TextEditingController descriptionEditingController;

  Timer? saveTimer;

  late ProjectEntity project;

  bool isEdited = false;
  late String taskId;

  String? title;
  String? description;
  String? projectId;

  List<EventReminderEntity> reminders = [];

  late DateTime initialStartDate;
  late DateTime initialEndDate;

  late DateTime startDate;
  late DateTime endDate;
  late bool isAllDay;
  late bool isAllDayInitial;

  late DateTime savedStartDate;
  late DateTime savedEndDate;

  double timeFieldPopupHeight = 240;

  RecurrenceRule? rrule;
  RruleL10n? rruleL10n;

  RecurrenceOptionType get recurrenceOptionType =>
      RecurrenceOptionType.values.firstWhereOrNull((e) => e.getRecurrenceRule(startDate) == rrule) ?? RecurrenceOptionType.doesNotRepeat;

  bool isCopy = false;
  bool isUnscheduled = false;

  TaskEntity get originalTask => widget.task;

  bool get isSameWithOriginalTask =>
      title == originalTask.title &&
      description == originalTask.description &&
      listEquals(reminders, originalTask.reminders) &&
      project.uniqueId == originalTask.projectId &&
      startDate == initialStartDate &&
      endDate == initialEndDate &&
      rrule == originalTask.rrule &&
      projectId == originalTask.projectId &&
      isUnscheduled == originalTask.isUnscheduled;

  bool get isDarkMode => context.isDarkMode;

  late TaskStatus? taskStatus;

  List<ProjectEntity> get projects => ref.read(projectListControllerProvider);

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).requireValue;

    taskId = originalTask.id ?? Uuid().v4();

    title = originalTask.title;
    description = originalTask.description;
    projectId = originalTask.projectId;

    taskStatus = originalTask.status;

    titleEditingController = TextEditingController(text: title);
    descriptionEditingController = TextEditingController(text: description);

    project = projects.firstWhereOrNull((e) => e.isPointedProject(widget.task)) ?? projects.firstWhere((e) => e.isDefault);

    isAllDay = originalTask.isAllDay;
    isAllDayInitial = isAllDay;

    isUnscheduled = originalTask.isUnscheduled;

    rruleL10n = ref.read(rruleL10nEnProvider).asData?.value;
    rrule = originalTask.rrule;

    final now = DateTime.now();
    startDate = originalTask.editedStartTime ?? DateTime(now.year, now.month, now.day, now.hour, (now.minute ~/ 15 + 1) * 15);
    endDate = originalTask.editedEndTime ?? startDate.add(isAllDay ? Duration(days: 1) : Duration(minutes: user.userTaskDefaultDurationInMinutes));

    final newStartDate = startDate;
    final newEndDate = endDate;

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

    savedStartDate = (isAllDay ? DateTime(now.year, now.month, now.day, now.hour, (now.minute ~/ 15 + 1) * 15) : startDate);
    savedEndDate = (isAllDay ? savedStartDate.add(Duration(minutes: user.userTaskDefaultDurationInMinutes)) : endDate);

    final defaultTaskReminderType = user.userDefaultTaskReminderType;
    final defaultAllDayTaskReminderType = user.userDefaultAllDayTaskReminderType;

    reminders = List<EventReminderEntity>.from(
      originalTask.reminders ??
          (isAllDay
              ? defaultAllDayTaskReminderType == TaskReminderOptionType.none
                    ? []
                    : [EventReminderEntity(method: 'push', minutes: defaultAllDayTaskReminderType.minutes())]
              : defaultTaskReminderType == TaskReminderOptionType.none
              ? []
              : [EventReminderEntity(method: 'push', minutes: defaultTaskReminderType.minutes())]),
    );

    titleFocusNode.onKeyEvent = onKeyEventTextField;
    descriptionFocusNode.onKeyEvent = onKeyEventTextField;

    // 포커스가 변경될 때 저장
    titleFocusNode.addListener(() {
      if (!titleFocusNode.hasFocus) {
        save();
      }
    });
    descriptionFocusNode.addListener(() {
      if (!descriptionFocusNode.hasFocus) {
        save();
      }
    });
  }

  @override
  void dispose() {
    save(onEnd: true);
    saveTimer?.cancel();
    titleEditingController.dispose();
    descriptionEditingController.dispose();
    titleFocusNode.dispose();
    descriptionFocusNode.dispose();
    super.dispose();
  }

  KeyEventResult onKeyEventTextField(FocusNode node, KeyEvent event) {
    final key = event.logicalKey;
    if (event is KeyDownEvent) {
      if (ServicesBinding.instance.keyboard.logicalKeysPressed.length == 1 && key == LogicalKeyboardKey.escape) {
        if (titleFocusNode.hasFocus) {
          titleFocusNode.unfocus();
        } else if (descriptionFocusNode.hasFocus) {
          descriptionFocusNode.unfocus();
        }
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
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
  }

  bool doNotSave = false;
  Future<void> save({bool? onEnd}) async {
    if (doNotSave) return;

    Future<void> _save() async {
      if (isSameWithOriginalTask) return;
      if (!isEdited) return;
      if (title?.isNotEmpty != true) return;
      final user = Utils.ref.read(authControllerProvider).requireValue;

      final recurrenceEndAt = isUnscheduled
          ? DateTime(3000)
          : rrule == null
          ? endDate
          : rrule!.until == null && rrule!.count == null
          ? DateTime(3000)
          : rrule!.until != null
          ? rrule!.until
          : rrule!.getAllInstances(start: startDate).lastOrNull ?? DateTime(3000);

      final finalEndDate = isUnscheduled
          ? null
          : startDate.isAtSameMomentAs(endDate)
          ? isAllDay
                ? startDate.add(Duration(days: 1))
                : startDate.add(Duration(minutes: user.userTaskDefaultDurationInMinutes))
          : isAllDay
          ? endDate.add(Duration(days: 1))
          : endDate;

      final task = TaskEntity(
        id: taskId,
        ownerId: user.id,
        title: title,
        description: description,
        startAt: isUnscheduled ? null : startDate,
        endAt: finalEndDate,
        isAllDay: isAllDay,
        rrule: rrule,
        excludedRecurrenceDate: [],
        recurrenceEndAt: recurrenceEndAt,
        linkedMails: originalTask.linkedMails,
        linkedMessages: originalTask.linkedMessages,
        reminders: reminders,
        projectId: project.uniqueId,
        createdAt: originalTask.createdAt,
        status: originalTask.status,
      );

      await TaskAction.upsertTask(
        task: task,
        originalTask: isCopy ? null : originalTask,
        calendarTaskEditSourceType: CalendarTaskEditSourceType.drag,
        tabType: TabType.task,
        selectedStartDate: initialStartDate,
        selectedEndDate: initialEndDate.add(Duration(days: isAllDayInitial ? 1 : 0)),
      );

      UserActionSwtichAction.onTaskAction();
    }

    if (onEnd == true) {
      await _save();
      return;
    }

    EasyDebounce.debounce('saveTaskOnTaskList', const Duration(milliseconds: 500), () async {
      _save();
      isEdited = false;
      setState(() {});
    });
  }

  Future<void> delete() async {
    await TaskAction.deleteTask(
      task: originalTask,
      calendarTaskEditSourceType: CalendarTaskEditSourceType.addTaskTop,
      tabType: TabType.task,
      selectedStartDate: initialStartDate,
      selectedEndDate: initialEndDate.add(Duration(days: isAllDayInitial ? 1 : 0)),
    );
    UserActionSwtichAction.onTaskAction();
  }

  Future<void> copy() async {
    taskId = Uuid().v4();
    isEdited = true;
    isCopy = true;
    save();
  }

  Widget appbarDivider() {
    return Container(width: 2, height: 16, decoration: BoxDecoration(color: context.surfaceVariant));
  }

  Widget bodyDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 1,
      decoration: BoxDecoration(color: context.surface),
    );
  }

  bool _onKeyDown(KeyEvent event, {bool? justReturnResult}) {
    if (ServicesBinding.instance.keyboard.logicalKeysPressed.length == 1 && ServicesBinding.instance.keyboard.logicalKeysPressed.contains(LogicalKeyboardKey.tab)) {
      if (justReturnResult == true) return true;
      if (titleFocusNode.hasFocus) {
        descriptionFocusNode.requestFocus();
      } else if (descriptionFocusNode.hasFocus) {
        titleFocusNode.requestFocus();
      }
      return true;
    }

    return false;
  }

  String get doneButtonString {
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
    final MasterDetailsFlowSettings? settings = MasterDetailsFlowSettings.of(context);

    final linkedMails = originalTask.linkedMails;
    final linkedMessages = originalTask.linkedMessages;

    bool isOverMultipleDays = startDate.date != endDate.date;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        save();
      },
      child: KeyboardShortcut(
        targetTab: widget.tabType,
        onKeyDown: _onKeyDown,
        bypassTextField: true,
        child: ValueListenableBuilder(
          valueListenable: tabNotifier,
          builder: (context, tabType, child) {
            if (tabType != TabType.task) {
              save();
            }

            return SafeArea(
              bottom: false,
              child: DetailsItem(
                hideBackButton: true,
                bodyColor: widget.backgroundColor,
                appbarColor: widget.backgroundColor,
                actions: [
                  VisirAppBarButton(
                    icon: VisirIconType.check,
                    enabled: isEdited,
                    options: VisirButtonOptions(
                      bypassTextField: true,
                      tabType: widget.tabType,
                      shortcuts: [
                        VisirButtonKeyboardShortcut(
                          message: context.tr.save,
                          keys: [LogicalKeyboardKey.enter, if (PlatformX.isApple) LogicalKeyboardKey.meta, if (!PlatformX.isApple) LogicalKeyboardKey.control],
                        ),
                      ],
                    ),
                    onTap: () {
                      save();
                    },
                  ),
                ],
                leadings: [
                  VisirAppBarButton(
                    icon: settings?.large != true ? VisirIconType.arrowLeft : VisirIconType.close,
                    options: VisirButtonOptions(
                      tabType: widget.tabType,
                      shortcuts: [
                        VisirButtonKeyboardShortcut(message: settings?.large != true ? context.tr.go_back : context.tr.close, keys: [LogicalKeyboardKey.escape]),
                      ],
                    ),
                    onTap: () {
                      if (ref.read(resizableClosableWidgetProvider(widget.tabType)) != null) return;
                      doNotSave = true;
                      widget.close();
                    },
                  ),
                  VisirAppBarButton(isDivider: true),
                  VisirAppBarButton(
                    icon: VisirIconType.copy,
                    options: VisirButtonOptions(
                      tabType: widget.tabType,
                      shortcuts: [
                        VisirButtonKeyboardShortcut(
                          message: context.tr.duplicate,
                          keys: [LogicalKeyboardKey.keyD, if (PlatformX.isApple) LogicalKeyboardKey.meta, if (!PlatformX.isApple) LogicalKeyboardKey.control],
                        ),
                      ],
                    ),
                    onTap: copy,
                  ),
                  VisirAppBarButton(
                    icon: VisirIconType.trash,
                    options: VisirButtonOptions(
                      tabType: widget.tabType,
                      shortcuts: [
                        VisirButtonKeyboardShortcut(
                          message: context.tr.delete,
                          keys: [LogicalKeyboardKey.backspace, if (PlatformX.isApple) LogicalKeyboardKey.meta, if (!PlatformX.isApple) LogicalKeyboardKey.control],
                          subkeys: [
                            [LogicalKeyboardKey.delete, if (PlatformX.isApple) LogicalKeyboardKey.meta, if (!PlatformX.isApple) LogicalKeyboardKey.control],
                          ],
                        ),
                      ],
                    ),
                    onTap: delete,
                  ),
                ],
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: CollapsingTextFormField(
                      focusNode: titleFocusNode,
                      controller: titleEditingController,
                      textInputAction: TextInputAction.go,
                      autofocus: widget.autoFocus,
                      collapsedLines: 2,
                      style: context.titleMedium?.textColor(context.outlineVariant).textBold,
                      decoration: InputDecoration(
                        hintText: context.tr.inbox_task_title,
                        hintStyle: context.titleMedium?.textColor(context.surfaceTint).textBold,
                        fillColor: Colors.transparent,
                        contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                        hoverColor: Colors.transparent,
                        border: InputBorder.none,
                        isCollapsed: true,
                      ),
                      onChanged: (text) {
                        title = text.isEmpty ? '(${context.tr.task_no_title})' : text;
                        isEdited = true;
                        setState(() {});
                      },
                    ),
                  ),
                  bodyDivider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        VisirIcon(type: VisirIconType.description, size: 14, isSelected: description?.isNotEmpty == true),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CollapsingTextFormField(
                            focusNode: descriptionFocusNode,
                            controller: descriptionEditingController,
                            textInputAction: TextInputAction.newline,
                            style: context.bodyLarge?.copyWith(color: context.outlineVariant),
                            collapsedLines: 5,
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
                              isEdited = true;
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(padding: const EdgeInsets.only(left: 24), child: bodyDivider()),
                  ...linkedMails.map((m) {
                    return Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(padding: const EdgeInsets.only(right: 10), child: Image.asset(m.type.icon, width: 14, height: 14)),
                              Expanded(
                                child: Text(m.fromName, style: context.bodyLarge?.copyWith(color: context.outlineVariant), maxLines: 1),
                              ),
                              SizedBox(width: 8),
                              if (PlatformX.isMobileView || true)
                                PopupMenu(
                                  type: ContextMenuActionType.tap,
                                  location: PopupMenuLocation.right,
                                  width: Utils.linkedPopupSize.width,
                                  height: Utils.linkedPopupSize.height,
                                  scrollPhysics: NeverScrollableScrollPhysics(),
                                  beforePopup: () {
                                    ref
                                        .read(mailConditionProvider(widget.tabType).notifier)
                                        .openThread(label: CommonMailLabels.inbox.id, email: null, threadId: m.threadId, threadEmail: m.hostMail, type: m.type);
                                    mailViewportSyncVisibleNotifier[widget.tabType]!.value = false;
                                  },
                                  onPopup: () {
                                    mailViewportSyncVisibleNotifier[widget.tabType]!.value = true;
                                  },
                                  afterPopup: () {
                                    mailViewportSyncVisibleNotifier[widget.tabType]!.value = false;
                                  },
                                  popup: Container(
                                    width: Utils.linkedPopupSize.width,
                                    height: Utils.linkedPopupSize.height,
                                    child: MailDetailScreen(tabType: widget.tabType, taskMail: m, anchorMailId: m.messageId, close: Navigator.of(context).pop),
                                  ),
                                  onTap: PlatformX.isMobileView
                                      ? null
                                      : () => widget.showDetilas?.call(
                                          Container(
                                            width: Utils.linkedPopupSize.width,
                                            height: Utils.linkedPopupSize.height,
                                            child: MailDetailScreen(tabType: widget.tabType, taskMail: m, anchorMailId: m.messageId, close: Navigator.of(context).pop),
                                          ),
                                        ),
                                  style: VisirButtonStyle(
                                    padding: EdgeInsets.all(5),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: context.outline, width: 0.5),
                                  ),
                                  options: VisirButtonOptions(tabType: widget.tabType, message: context.tr.quick_view),
                                  child: VisirIcon(type: VisirIconType.show, size: 14, isSelected: true),
                                )
                              else
                                VisirButton(
                                  type: VisirButtonAnimationType.scaleAndOpacity,
                                  style: VisirButtonStyle(
                                    padding: EdgeInsets.all(5),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: context.outline, width: 0.5),
                                  ),
                                  options: VisirButtonOptions(tabType: widget.tabType, message: context.tr.quick_view),
                                  onTap: () async {
                                    ref
                                        .read(mailConditionProvider(widget.tabType).notifier)
                                        .openThread(label: CommonMailLabels.inbox.id, email: null, threadId: m.threadId, threadEmail: m.hostMail, type: m.type);
                                    mailViewportSyncVisibleNotifier[widget.tabType]!.value = true;
                                    ref
                                        .read(resizableClosableWidgetProvider(widget.tabType).notifier)
                                        .setWidget(
                                          ResizableWidget(
                                            widget: MailDetailScreen(
                                              tabType: widget.tabType,
                                              taskMail: m,
                                              anchorMailId: m.messageId,
                                              close: () {
                                                mailViewportSyncVisibleNotifier[widget.tabType]!.value = false;
                                                Utils.ref.read(resizableClosableWidgetProvider(widget.tabType).notifier).setWidget(null);
                                              },
                                            ),
                                            minWidth: 320,
                                          ),
                                        );
                                  },
                                  child: VisirIcon(type: VisirIconType.show, size: 14, isSelected: true),
                                ),
                              SizedBox(width: 4),
                              VisirButton(
                                type: VisirButtonAnimationType.scaleAndOpacity,
                                style: VisirButtonStyle(
                                  cursor: SystemMouseCursors.click,
                                  padding: EdgeInsets.all(5),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: context.outline, width: 0.5),
                                ),
                                options: VisirButtonOptions(tabType: widget.tabType, doNotConvertCase: true, message: context.tr.open_in(m.type.title)),
                                onTap: () {
                                  Utils.launchUrlExternal(url: m.link);
                                  UserActionSwtichAction.onOpenMail(mailHost: m.hostMail);
                                },
                                child: Image.asset(m.type.icon, width: 14, height: 14),
                              ),
                            ],
                          ),
                        ),
                        Padding(padding: const EdgeInsets.only(left: 24), child: bodyDivider()),
                      ],
                    );
                  }),
                  ...linkedMessages.map((m) {
                    final channels = ref.read(chatChannelListControllerProvider.select((v) => v.values.expand((e) => e.channels).toList()));
                    final channel = channels.firstWhereOrNull((e) => e.id == m.channelId);

                    return Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(padding: const EdgeInsets.only(right: 10), child: Image.asset(m.type.icon, width: 14, height: 14)),
                              Expanded(
                                child: Text('${m.userName} - ${m.channelName}', style: context.bodyLarge?.copyWith(color: context.outlineVariant), maxLines: 1),
                              ),
                              SizedBox(width: 4),
                              if (PlatformX.isMobileView || true)
                                PopupMenu(
                                  type: ContextMenuActionType.tap,
                                  location: PopupMenuLocation.right,
                                  width: Utils.linkedPopupSize.width,
                                  height: Utils.linkedPopupSize.height,
                                  scrollPhysics: NeverScrollableScrollPhysics(),
                                  beforePopup: () {
                                    if (channel == null) return;
                                    ref.read(chatConditionProvider(widget.tabType).notifier).setThreadAndChannel(m.threadId, channel, targetMessageId: m.messageId);
                                  },
                                  popup: Container(
                                    width: Utils.linkedPopupSize.width,
                                    height: Utils.linkedPopupSize.height,
                                    child: ChatListScreen(tabType: widget.tabType, taskMessage: m, close: Navigator.of(context).pop),
                                  ),
                                  style: VisirButtonStyle(
                                    padding: EdgeInsets.all(5),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: context.outline, width: 0.5),
                                  ),
                                  options: VisirButtonOptions(tabType: widget.tabType, message: context.tr.quick_view),
                                  child: VisirIcon(type: VisirIconType.show, size: 14, isSelected: true),
                                )
                              else
                                VisirButton(
                                  type: VisirButtonAnimationType.scaleAndOpacity,
                                  style: VisirButtonStyle(
                                    padding: EdgeInsets.all(5),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: context.outline, width: 0.5),
                                  ),
                                  options: VisirButtonOptions(tabType: widget.tabType, doNotConvertCase: true, message: context.tr.open_in(m.type.title)),
                                  onTap: () async {
                                    ref
                                        .read(resizableClosableWidgetProvider(widget.tabType).notifier)
                                        .setWidget(
                                          ResizableWidget(
                                            widget: ChatListScreen(
                                              tabType: widget.tabType,
                                              taskMessage: m,
                                              close: () {
                                                Utils.ref.read(resizableClosableWidgetProvider(widget.tabType).notifier).setWidget(null);
                                              },
                                            ),
                                            minWidth: 320,
                                          ),
                                        );
                                  },
                                  child: Image.asset(m.type.icon, width: 14, height: 14),
                                ),
                              SizedBox(width: 4),
                              VisirButton(
                                type: VisirButtonAnimationType.scaleAndOpacity,
                                style: VisirButtonStyle(
                                  cursor: SystemMouseCursors.click,
                                  padding: EdgeInsets.all(5),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: context.outline, width: 0.5),
                                ),
                                options: VisirButtonOptions(tabType: widget.tabType, doNotConvertCase: true, message: context.tr.open_in(m.type.title)),
                                onTap: () {
                                  Utils.launchUrlExternal(url: m.link);
                                  UserActionSwtichAction.onOpenExternalMessageLink(teamId: m.teamId);
                                },
                                child: Image.asset(m.type.icon, width: 14, height: 14),
                              ),
                            ],
                          ),
                        ),
                        Padding(padding: const EdgeInsets.only(left: 24), child: bodyDivider()),
                      ],
                    );
                  }),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 10, top: 5),
                          child: VisirIcon(type: VisirIconType.clock, size: 14, color: isDarkMode ? context.outlineVariant : context.shadow),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: isUnscheduled
                                ? [
                                    IntrinsicWidth(
                                      child: VisirButton(
                                        type: VisirButtonAnimationType.scaleAndOpacity,
                                        style: VisirButtonStyle(
                                          cursor: SystemMouseCursors.click,
                                          height: 24,
                                          backgroundColor: context.surface,
                                          borderRadius: BorderRadius.circular(4),
                                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                                        ),
                                        onTap: () {
                                          isEdited = true;
                                          final user = ref.read(authControllerProvider).requireValue;
                                          DateTime now = DateTime.now();
                                          startDate = DateTime(now.year, now.month, now.day, now.hour, (now.minute ~/ 15 + 1) * 15);
                                          endDate = startDate.add(isAllDay ? Duration(days: 1) : Duration(minutes: user.userTaskDefaultDurationInMinutes));
                                          isUnscheduled = false;
                                          setState(() {});
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            VisirIcon(type: VisirIconType.add, size: 12, color: context.outlineVariant),
                                            const SizedBox(width: 6),
                                            Text(context.tr.task_set_date, style: context.bodyLarge?.textColor(context.outlineVariant)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ]
                                : [
                                    Wrap(
                                      spacing: 4,
                                      runSpacing: isOverMultipleDays && !isAllDay ? 4 : 8,
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
                                              cursor: SystemMouseCursors.click,
                                              padding: EdgeInsets.only(left: 5),
                                              backgroundColor: context.surface,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Row(
                                              children: [
                                                Text(EventEntity.getDateForEditSimple(startDate), style: context.bodyLarge?.textColor(context.outlineVariant)),
                                                VisirButton(
                                                  type: VisirButtonAnimationType.scaleAndOpacity,
                                                  style: VisirButtonStyle(padding: EdgeInsets.all(6), hoverColor: Colors.transparent),
                                                  onTap: () {
                                                    isEdited = true;
                                                    isUnscheduled = true;
                                                    setState(() {});
                                                  },
                                                  child: VisirIcon(type: VisirIconType.closeWithCircle, size: 12, color: context.outlineVariant, isSelected: true),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        if (!isAllDay)
                                          PopupMenu(
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
                                            style: VisirButtonStyle(padding: EdgeInsets.all(5), backgroundColor: context.surface, borderRadius: BorderRadius.circular(4)),
                                            child: Text(EventEntity.getTimeForEdit(startDate), style: context.bodyLarge?.textColor(context.outlineVariant)),
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
                                              style: VisirButtonStyle(padding: EdgeInsets.only(left: 5), backgroundColor: context.surface, borderRadius: BorderRadius.circular(4)),
                                              child: Row(
                                                children: [
                                                  Text(EventEntity.getDateForEditSimple(endDate), style: context.bodyLarge?.textColor(context.outlineVariant)),
                                                  VisirButton(
                                                    type: VisirButtonAnimationType.scaleAndOpacity,
                                                    style: VisirButtonStyle(hoverColor: Colors.transparent, padding: EdgeInsets.all(6)),
                                                    onTap: () {
                                                      isEdited = true;
                                                      isUnscheduled = true;
                                                      setState(() {});
                                                    },
                                                    child: VisirIcon(type: VisirIconType.closeWithCircle, size: 12, color: context.outlineVariant, isSelected: true),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                        if (!isAllDay)
                                          PopupMenu(
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
                                            style: VisirButtonStyle(padding: EdgeInsets.all(5), backgroundColor: context.surface, borderRadius: BorderRadius.circular(4)),
                                            child: Text(EventEntity.getTimeForEdit(endDate), style: context.bodyLarge?.textColor(context.outlineVariant)),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        VisirButton(
                                          type: VisirButtonAnimationType.scaleAndOpacity,
                                          style: VisirButtonStyle(
                                            cursor: SystemMouseCursors.click,
                                            borderRadius: BorderRadius.circular(4),
                                            border: isAllDay ? null : Border.all(color: context.surface, width: 1),
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
                                          },
                                          child: Text(context.tr.all_day, style: context.bodyLarge?.textColor(isAllDay ? context.onPrimary : context.outlineVariant)),
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
                                                },
                                              ),
                                              onSelect: (rruleOptionType) {
                                                switch (rruleOptionType) {
                                                  case RecurrenceOptionType.doesNotRepeat:
                                                    isEdited = true;
                                                    this.rrule = null;
                                                    setState(() {});
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
                                                    break;
                                                  case RecurrenceOptionType.custom:
                                                    break;
                                                }
                                              },
                                            ),
                                            style: VisirButtonStyle(
                                              borderRadius: BorderRadius.circular(4),
                                              border: rruleL10n == null || rrule == null
                                                  ? Border.all(color: rruleL10n == null || rrule == null ? context.surface : context.primary, width: 1)
                                                  : null,
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
                  Padding(padding: const EdgeInsets.only(left: 24), child: bodyDivider()),
                  if (reminders.isNotEmpty)
                    Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 10, top: 5),
                                child: VisirIcon(type: VisirIconType.notification, size: 14, color: isDarkMode ? context.outlineVariant : context.shadow),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: reminders.mapIndexed((index, e) {
                                    // final minute = e.minutes ?? 0;
                                    bool isFirst = index == 0;
                                    bool isOnlyReminder = reminders.length == 1;

                                    return Container(
                                      height: 24,
                                      decoration: BoxDecoration(color: context.surface, borderRadius: BorderRadius.circular(4)),
                                      margin: isOnlyReminder ? EdgeInsets.zero : EdgeInsets.only(right: 10, top: isFirst ? 0 : 8),
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
                                              style: VisirButtonStyle(hoverColor: Colors.transparent, padding: EdgeInsets.all(6)),
                                              onTap: () {
                                                isEdited = true;
                                                reminders.remove(e);
                                                setState(() {});
                                              },
                                              child: VisirIcon(type: VisirIconType.closeWithCircle, size: 12, color: context.outlineVariant, isSelected: true),
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
                        Padding(padding: const EdgeInsets.only(left: 24), child: bodyDivider()),
                      ],
                    ),

                  SizedBox(height: 8),

                  SingleChildScrollView(
                    reverse: true,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        IntrinsicWidth(
                          child: PopupMenu(
                            beforePopup: () => FocusScope.of(context).unfocus(),
                            enabled: true,
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
                                  onSelect: (p) {
                                    project = p;
                                    isEdited = true;
                                    setState(() {});
                                  },
                                );
                              },
                            ),
                            style: VisirButtonStyle(
                              margin: EdgeInsets.only(right: 8),
                              borderRadius: BorderRadius.circular(8),
                              backgroundColor: context.surface,
                              padding: EdgeInsets.symmetric(horizontal: 6),
                              height: 28,
                            ),
                            options: project.description?.isNotEmpty == true
                                ? VisirButtonOptions(tooltipLocation: VisirButtonTooltipLocation.bottom, message: project.description)
                                : null,
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(color: project.color!, borderRadius: BorderRadius.circular(6)),
                                  child: project.icon == null ? null : VisirIcon(type: project.icon!, size: 12, color: Colors.white, isSelected: true),
                                ),
                                SizedBox(width: 6),
                                Text(project.name, style: context.bodyLarge?.textColor(context.outlineVariant)),
                                SizedBox(width: 6),
                                VisirIcon(type: VisirIconType.arrowDown, size: 12),
                              ],
                            ),
                          ),
                        ),
                        IntrinsicWidth(
                          child: PopupMenu(
                            beforePopup: () => FocusScope.of(context).unfocus(),
                            forcePopup: true,
                            location: PopupMenuLocation.bottom,
                            width: 180,
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
                                initialReminder: EventReminderEntity(minutes: 10, method: 'popup'),
                                isAllDay: isAllDay,
                                onReminderChanged: (reminder) {
                                  if (!reminders.contains(reminder)) {
                                    reminders.add(reminder);
                                    isEdited = true;
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
                                    isEdited = true;
                                    setState(() {});
                                  }
                                }
                              },
                            ),
                            style: VisirButtonStyle(
                              margin: EdgeInsets.only(right: 8),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: context.surface, width: 1),
                              padding: EdgeInsets.symmetric(horizontal: 6),
                              height: 28,
                            ),
                            child: Row(
                              children: [
                                VisirIcon(type: VisirIconType.notification, size: 14, isSelected: true),
                                SizedBox(width: 6),
                                Text(context.tr.reminder, style: context.bodyLarge?.textColor(context.outlineVariant)),
                                SizedBox(width: 2),
                              ],
                            ),
                          ),
                        ),

                        if (widget.task.status != TaskStatus.braindump)
                          IntrinsicWidth(
                            child: VisirButton(
                              type: VisirButtonAnimationType.scaleAndOpacity,
                              style: VisirButtonStyle(
                                margin: EdgeInsets.only(right: 8),
                                backgroundColor: Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: context.surface, width: 1),
                                padding: EdgeInsets.symmetric(horizontal: 6),
                                height: 28,
                              ),
                              onTap: () {
                                EasyThrottle.throttle('toggleTaskStatus${widget.task.id}', Duration(milliseconds: 50), () {
                                  final list = ref.read(taskListControllerProvider);
                                  final editedRecurringTask = list.tasks.firstWhereOrNull((e) => e.recurringTaskId == widget.task.id && e.startAt == widget.task.editedStartTime);

                                  TaskEntity? targetTask = widget.task.isOriginalRecurrenceTask
                                      ? taskStatus == TaskStatus.none
                                            ? editedRecurringTask ?? widget.task
                                            : editedRecurringTask
                                      : widget.task.copyWith(status: taskStatus);

                                  if (targetTask == null) return;

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
                                  SizedBox(width: 6),
                                  Text(doneButtonString, style: context.bodyLarge?.textColor(context.outlineVariant)),
                                  SizedBox(width: 2),
                                ],
                              ),
                            ),
                          ),

                        SizedBox(width: 8),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
