import 'dart:async';

import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/master_detail_flow/src/master_item.dart';
import 'package:Visir/dependency/master_detail_flow/src/widget.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/auth/domain/entities/user_entity.dart';
import 'package:Visir/features/calendar/presentation/widgets/calendar_simple_create_widget.dart';
import 'package:Visir/features/calendar/providers.dart';
import 'package:Visir/features/common/presentation/utils/extensions/date_time_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/list_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/log_event.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/fgbg_detector.dart';
import 'package:Visir/features/common/presentation/widgets/keyboard_shortcut.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/presentation/widgets/visir_app_bar.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_empty_widget.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:Visir/features/task/actions.dart';
import 'package:Visir/features/task/application/project_list_controller.dart';
import 'package:Visir/features/task/application/task_list_controller.dart';
import 'package:Visir/features/task/domain/entities/project_entity.dart';
import 'package:Visir/features/task/domain/entities/task_entity.dart';
import 'package:Visir/features/task/domain/entities/task_label_entity.dart';
import 'package:Visir/features/task/presentation/screens/task_list_task_detail_screen.dart';
import 'package:Visir/features/task/presentation/widgets/mobile_task_or_event_switcher_widget.dart';
import 'package:Visir/features/task/presentation/widgets/task_list_add_task_widget.dart';
import 'package:Visir/features/task/presentation/widgets/task_list_element_widget.dart';
import 'package:Visir/features/task/providers.dart';
import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:time/time.dart';

class TaskListScreen extends ConsumerStatefulWidget {
  final GlobalKey<TaskListAddTaskWidgetState> addTaskWidgetKey;
  final DateTime? dateOnAddTask;
  final void Function(DateTime? date) setDateOnAddTask;
  final GlobalKey<MasterDetailsFlowState> masterDetailsKey;
  final void Function({required String? id}) openDetails;
  final void Function() closeDetails;
  final VoidCallback toggleSidebar;
  final ScrollController scrollController;

  const TaskListScreen({
    super.key,
    required this.addTaskWidgetKey,
    required this.dateOnAddTask,
    required this.setDateOnAddTask,
    required this.masterDetailsKey,
    required this.openDetails,
    required this.closeDetails,
    required this.toggleSidebar,
    required this.scrollController,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen> {
  Timer? hourlyRefreshTimer;

  ListController listController = ListController();

  final double minCustomWidth = 280;

  bool focusTextFieldOnDetails = false;

  bool get isMobileView => PlatformX.isMobileView;
  bool get isDarkMode => context.isDarkMode;

  ValueNotifier<DateTime?> dragTargetDate = ValueNotifier(null);
  DateTime? dragStartDate;

  Widget? selectedDetails;

  @override
  void initState() {
    super.initState();
    scheduleHourlyRefresh();
  }

  @override
  dispose() {
    listController.dispose();
    hourlyRefreshTimer?.cancel();
    super.dispose();
  }

  void scheduleHourlyRefresh() {
    final now = DateTime.now();
    final nextHour = DateTime(now.year, now.month, now.day, now.hour + 1);
    final initialDelay = nextHour.difference(now);
    Future.delayed(initialDelay, () {
      ref.read(taskListControllerProvider.notifier).refresh();
      hourlyRefreshTimer = Timer.periodic(const Duration(hours: 1), (_) => ref.read(taskListControllerProvider.notifier).refresh());
    });
  }

  int taskSorter({required TaskEntity a, required TaskEntity b}) {
    if (a.isDone && !b.isDone) return 1;
    if (!a.isDone && b.isDone) return -1;
    final aProject = ref.read(projectListControllerProvider).where((element) => element.isPointedProjectId(a.projectId)).firstOrNull;
    final bProject = ref.read(projectListControllerProvider).where((element) => element.isPointedProjectId(b.projectId)).firstOrNull;
    final sortedProject = ref.read(projectListControllerProvider).sortedProjectWithDepth;
    final aProjectIndex = sortedProject.indexWhere((element) => element.project.uniqueId == aProject?.uniqueId);
    final bProjectIndex = sortedProject.indexWhere((element) => element.project.uniqueId == bProject?.uniqueId);
    final projectSorter = aProjectIndex < 0 || bProjectIndex < 0 ? (a.projectId ?? '').compareTo(b.projectId ?? '') : aProjectIndex.compareTo(bProjectIndex);
    final dateSorter = (a.comparingStartTime).compareTo(b.comparingStartTime);
    if (projectSorter != 0) return projectSorter;
    if (dateSorter != 0) return dateSorter;
    return (a.updatedAt ?? a.createdAt!).compareTo(b.updatedAt ?? b.createdAt!);
  }

  int completedTaskSorter({required TaskEntity a, required TaskEntity b}) {
    // completed 탭: date > project 순서로 정렬
    final dateSorter = (a.comparingStartTime).compareTo(b.comparingStartTime);
    if (dateSorter != 0) return dateSorter;

    final aProject = ref.read(projectListControllerProvider).where((element) => element.isPointedProjectId(a.projectId)).firstOrNull;
    final bProject = ref.read(projectListControllerProvider).where((element) => element.isPointedProjectId(b.projectId)).firstOrNull;
    final sortedProject = ref.read(projectListControllerProvider).sortedProjectWithDepth;
    final aProjectIndex = sortedProject.indexWhere((element) => element.project.uniqueId == aProject?.uniqueId);
    final bProjectIndex = sortedProject.indexWhere((element) => element.project.uniqueId == bProject?.uniqueId);
    final projectSorter = aProjectIndex < 0 || bProjectIndex < 0 ? (a.projectId ?? '').compareTo(b.projectId ?? '') : aProjectIndex.compareTo(bProjectIndex);
    if (projectSorter != 0) return projectSorter;

    return (a.updatedAt ?? a.createdAt!).compareTo(b.updatedAt ?? b.createdAt!);
  }

  void closeAddTaskWidget() async {
    widget.setDateOnAddTask(null);
  }

  void showAddTaskBottomSheet(DateTime? date, CalendarTaskEditSourceType calendarTaskEditSourceType) {
    final _date = date ?? DateTime.now().roundUp(delta: Duration(minutes: 15));

    Utils.showPopupDialog(
      child: MobileTaskOrEventSwitcherWidget(
        isEvent: false,
        isAllDay: true,
        startDate: _date,
        endDate: _date,
        selectedDate: DateUtils.dateOnly(_date),
        tabType: TabType.task,
        hideEventTaskSwitcher: true,
        calendarTaskEditSourceType: calendarTaskEditSourceType,
      ),
    );
  }

  Widget topAddTaskWidget(ProjectEntity? project) {
    DateTime date = DateTime(1000);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Container(
            color: context.background,
            padding: EdgeInsets.only(left: 8, right: 8),
            child: Transform.translate(
              offset: Offset(0, -8),
              child: widget.dateOnAddTask == date
                  ? TaskListAddTaskWidget(key: widget.addTaskWidgetKey, dateOnAddTask: date, closeAddTaskWidget: closeAddTaskWidget)
                  : VisirButton(
                      type: VisirButtonAnimationType.scale,
                      style: VisirButtonStyle(
                        cursor: SystemMouseCursors.click,
                        padding: EdgeInsets.all(12),
                        border: Border.all(width: 1, color: context.surface),
                        borderRadius: BorderRadius.circular(8),
                        backgroundColor: context.background,
                      ),
                      options: VisirButtonOptions(
                        tabType: TabType.task,
                        tooltipLocation: VisirButtonTooltipLocation.none,
                        shortcuts: [
                          VisirButtonKeyboardShortcut(
                            message: context.tr.task_add_task,
                            keys: [LogicalKeyboardKey.keyN, if (PlatformX.isApple) LogicalKeyboardKey.meta, if (!PlatformX.isApple) LogicalKeyboardKey.control],
                          ),
                        ],
                      ),
                      onTap: () {
                        widget.setDateOnAddTask(date);
                      },
                      child: Row(
                        children: [
                          VisirIcon(type: VisirIconType.add, size: 16, color: context.outline),
                          const SizedBox(width: 8),
                          Text(context.tr.task_add_task, style: context.titleSmall?.textColor(context.outline)),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildAppBarButton(VisirIconType icon, VoidCallback onTap) {
    return VisirAppBarButton(icon: icon, onTap: onTap).getButton(context: context);
  }

  MasterItemBase placeholder({required TaskLabelEntity currentTaskLabel, required double height}) {
    final isLoading = ref.read(loadingStatusProvider.select((v) => v[TaskListController.stringKey] == LoadingState.loading));

    return MasterItem(
      'placeholder',
      'placeholder',
      customWidget: (selected) {
        return Container(
          height: height,
          child: isLoading
              ? Center(
                  child: AnimatedTextKit(
                    animatedTexts: [TypewriterAnimatedText('loading...', textStyle: context.titleMedium?.textColor(context.surfaceTint), speed: const Duration(milliseconds: 100))],
                    repeatForever: true,
                    pause: const Duration(milliseconds: 500),
                    displayFullTextOnTap: true,
                  ),
                )
              : VisirEmptyWidget(
                  height: height,
                  message: currentTaskLabel.type == TaskLabelType.scheduled
                      ? context.tr.task_no_scheduled_tasks
                      : currentTaskLabel.type == TaskLabelType.completed
                      ? context.tr.task_no_completed_tasks
                      : currentTaskLabel.type == TaskLabelType.overdue
                      ? context.tr.task_no_overdue_tasks
                      : currentTaskLabel.type == TaskLabelType.unscheduled
                      ? context.tr.task_no_unscheduled_tasks
                      : null,
                ),
        );
      },
      onTap: () {},
    );
  }

  void openDetails(TaskEntity task, DateTime? date) {
    if (widget.masterDetailsKey.currentState?.selectedItem?.id == task.getEditedUniqueId(date)) {
      focusTextFieldOnDetails = true;
      setState(() {});
    } else {
      focusTextFieldOnDetails = false;
      setState(() {});
    }
    widget.openDetails(id: task.getEditedUniqueId(date));
  }

  Future<void> moveTaskDate({required DateTime? date, required TaskEntity originalTask}) async {
    final user = ref.read(authControllerProvider).requireValue;
    bool isUnscheduled = date == null;
    final diff = date == null ? Duration.zero : (dragStartDate ?? date).difference(date);
    final newTask = TaskEntity(
      id: originalTask.id,
      ownerId: user.id,
      title: originalTask.title,
      description: originalTask.description,
      startAt: isUnscheduled
          ? null
          : originalTask.startAt == null
          ? date
          : (originalTask.editedStartTime ?? originalTask.startDate).subtract(diff),
      endAt: isUnscheduled
          ? null
          : originalTask.startAt == null
          ? date.add(Duration(days: 1))
          : originalTask.isAllDay == true
          ? (originalTask.editedStartTime ?? originalTask.startDate).add(Duration(days: 1)).subtract(diff)
          : (originalTask.editedEndTime ?? originalTask.endDate).subtract(diff),
      isAllDay: originalTask.startAt == null ? true : originalTask.isAllDay,
      rrule: originalTask.rrule,
      excludedRecurrenceDate: [],
      recurrenceEndAt: originalTask.recurrenceEndAt,
      linkedMails: originalTask.linkedMails,
      linkedMessages: originalTask.linkedMessages,
      reminders: originalTask.reminders,
      createdAt: originalTask.createdAt,
      status: originalTask.status,
      projectId: originalTask.projectId,
    );

    await TaskAction.upsertTask(
      originalTask: originalTask,
      task: newTask,
      calendarTaskEditSourceType: CalendarTaskEditSourceType.drag,
      tabType: TabType.task,
      selectedStartDate: originalTask.editedStartTime ?? originalTask.startDate,
      selectedEndDate: originalTask.editedEndTime ?? originalTask.endDate.add(Duration(days: originalTask.isAllDay ? 1 : 0)),
    );
  }

  final unscheduledPlaceholderDateTime = DateTime(5000);
  TabType get tabType => TabType.task;

  @override
  Widget build(BuildContext context) {
    ref.watch(taskListControllerProvider);
    final projectHide = ref.watch(projectHideProvider(tabType));
    final projects = ref.watch(projectListControllerProvider);
    final completedTaskOptionType = ref.watch(authControllerProvider.select((e) => e.requireValue.userCompletedTaskOptionType));
    final currentTaskLabel = ref.watch(taskLabelProvider);
    final taskDates = ref.watch(taskListControllerProvider.select((v) => v.taskDates));

    // Optimization: Combine filtering and selection in a single select to avoid multiple rebuilds
    // This reduces the number of times tasksOnView is filtered
    final tasksOnViewRaw = ref.watch(taskListControllerProvider.select((v) => v.tasksOnView));

    // Optimization: Pre-filter tasksOnView once with common filters
    // Use Set for O(1) lookup instead of List.contains() which is O(n)
    final projectHideSet = Set<String>.from(projectHide);
    final tasksOnView = <TaskEntity>[];
    for (final t in tasksOnViewRaw) {
      if (!t.isCancelled && !t.isOriginalRecurrenceTask && !projectHideSet.contains(t.projectId) && !t.isEventDummyTask) {
        tasksOnView.add(t);
      }
    }

    List<TaskEntity> filteredTasks;

    switch (currentTaskLabel.type) {
      case TaskLabelType.all:
        // Optimization: Single pass filtering instead of where().toList()
        filteredTasks = <TaskEntity>[];
        for (final t in tasksOnView) {
          if (completedTaskOptionType == CompletedTaskOptionType.show ? true : t.status == TaskStatus.none) {
            if (completedTaskOptionType == CompletedTaskOptionType.show && t.isOverdue && t.status == TaskStatus.done) {
              continue;
            }
            filteredTasks.add(t);
          }
        }
        filteredTasks.sort((a, b) => taskSorter(a: a, b: b));
        break;
      case TaskLabelType.scheduled:
        // all tasks에서 unscheduled와 overdue를 제외한 뷰
        filteredTasks = <TaskEntity>[];
        for (final t in tasksOnView) {
          if (completedTaskOptionType == CompletedTaskOptionType.show ? true : t.status == TaskStatus.none) {
            if (completedTaskOptionType == CompletedTaskOptionType.show && t.isOverdue && t.status == TaskStatus.done) {
              continue;
            }
            // unscheduled와 overdue 제외
            if (t.isUnscheduled || t.isOverdue) {
              continue;
            }
            filteredTasks.add(t);
          }
        }
        filteredTasks.sort((a, b) => taskSorter(a: a, b: b));
        break;
      case TaskLabelType.completed:
        // updated_at descending으로 정렬 (최신부터)
        filteredTasks = <TaskEntity>[];
        for (final t in tasksOnView) {
          if (t.status == TaskStatus.done) {
            filteredTasks.add(t);
          }
        }
        filteredTasks.sort((a, b) => (b.updatedAt ?? b.createdAt ?? DateTime(1000)).compareTo(a.updatedAt ?? a.createdAt ?? DateTime(1000)));
        break;
      case TaskLabelType.overdue:
        filteredTasks = <TaskEntity>[];
        for (final t in tasksOnView) {
          if (t.status == TaskStatus.none && t.isOverdue && !t.isUnscheduled) {
            filteredTasks.add(t);
          }
        }
        filteredTasks.sort((a, b) => taskSorter(a: a, b: b));
        break;
      case TaskLabelType.unscheduled:
        filteredTasks = <TaskEntity>[];
        for (final t in tasksOnView) {
          if (t.status == TaskStatus.none && t.isUnscheduled) {
            filteredTasks.add(t);
          }
        }
        filteredTasks.sort((a, b) => taskSorter(a: a, b: b));
        break;
    }

    final dateTaskMapList =
        taskDates.map((date) {
            List<TaskEntity> tasksOnDate = date == null
                ? (filteredTasks.where((t) => t.isUnscheduled).toList()).toList()
                : date == DateTime(1000)
                ? filteredTasks.where((t) => !t.isUnscheduled && t.isOverdue).toList()
                : filteredTasks.where((t) => t.editedStartTime != null && (t.isLongDurationTask ? t.editedDateOnlyList.contains(date) : t.editedStartDateOnly == date)).toList();
            return {date: tasksOnDate.unique((e) => e.getEditedUniqueId(date)).toList()..sort((a, b) => taskSorter(a: a, b: b))};
          }).toList()
          ..removeWhere((e) => e.keys.first == null && e.values.first.isEmpty)
          ..removeWhere((e) => e.keys.first == DateTime(1000) && e.values.first.isEmpty)
          // scheduled 뷰에서는 overdue(DateTime(1000)) 제외
          ..removeWhere((e) => currentTaskLabel.type == TaskLabelType.scheduled && e.keys.first == DateTime(1000));

    final closableDrawer = ref.watch(resizableClosableDrawerProvider(tabType));

    return FGBGDetector(
      onChanged: (isForeground, isFirst) {
        if (!isForeground) return;
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          ref.read(taskListControllerProvider.notifier).refresh();
        });
      },
      child: KeyboardShortcut(
        targetTab: TabType.task,
        child: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                double appbarSize = 0;

                final leadingBeforeText = [
                  if (closableDrawer == null) buildAppBarButton(VisirIconType.control, widget.toggleSidebar),
                  // VisirAppBarButton(
                  //   icon: VisirIconType.search,
                  //   onTap: () {},
                  //   options: VisirButtonOptions(
                  //     tabType: tabType,
                  //     shortcuts: [
                  //       VisirButtonKeyboardShortcut(
                  //         message: context.tr.search_tasks,
                  //         keys: [LogicalKeyboardKey.keyF, if (PlatformX.isApple) LogicalKeyboardKey.meta, if (!PlatformX.isApple) LogicalKeyboardKey.control],
                  //       ),
                  //     ],
                  //   ),
                  // ).getButton(context: context),
                ];

                return Row(
                  children: [
                    Expanded(
                      child: MasterDetailsFlow(
                        tabType: TabType.task,
                        key: widget.masterDetailsKey,
                        scrollController: widget.scrollController,
                        listController: listController,
                        masterBackgroundColor: context.background,
                        appbarSize: appbarSize,
                        showAppBarDivider: false,
                        minMasterResizableWidth: 280,
                        minDetailResizableWidth: 280,
                        dividerColor: context.surface,

                        leadings: [
                          SizedBox(width: 6),
                          ...leadingBeforeText,
                          if (leadingBeforeText.isNotEmpty) VisirAppBarButton(isDivider: true).getButton(context: context) else SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.only(left: 6),
                            constraints: BoxConstraints(maxWidth: 200),
                            child: Text(
                              currentTaskLabel.type.getTitle(context, currentTaskLabel.colorString),
                              style: context.titleLarge?.textColor(context.outlineVariant).textBold.appFont(context),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                        actions: PlatformX.isMobileView
                            ? [
                                VisirAppBarButton(icon: VisirIconType.add, onTap: () => showAddTaskBottomSheet(null, CalendarTaskEditSourceType.fab)).getButton(context: context),
                                SizedBox(width: 6),
                              ]
                            : [],

                        onTargetResized: (width) {},
                        breakpoint: (minCustomWidth).floor(),
                        isDetailExpanded: true,
                        nothingSelectedWidget: filteredTasks.isEmpty
                            ? Center(child: Text(context.tr.task_no_task_selected, style: context.titleMedium?.textColor(context.surfaceTint)))
                            : null,
                        detailBackgroundColor: context.background,
                        onLoading:
                            (currentTaskLabel.type == TaskLabelType.scheduled ||
                                currentTaskLabel.type == TaskLabelType.overdue ||
                                currentTaskLabel.type == TaskLabelType.unscheduled)
                            ? null
                            : () async {
                                final hasMoreData = await ref.read(taskListControllerProvider.notifier).getMoreTasks();
                                return hasMoreData;
                              },
                        onRefresh: isMobileView
                            ? () async {
                                await ref.read(taskListControllerProvider.notifier).refresh();
                                logAnalyticsEvent(eventName: 'refresh', properties: {'tab': TabType.task.name});
                              }
                            : null,
                        bottom: isMobileView ? null : topAddTaskWidget(null),
                        items:
                            (currentTaskLabel.type == TaskLabelType.completed ||
                                currentTaskLabel.type == TaskLabelType.overdue ||
                                currentTaskLabel.type == TaskLabelType.unscheduled)
                            ? filteredTasks.isEmpty
                                  ? [placeholder(currentTaskLabel: currentTaskLabel, height: constraints.maxHeight - appbarSize)]
                                  : filteredTasks.toList().mapIndexed((taskIndex, task) {
                                      final date = DateUtils.dateOnly(DateTime.now());
                                      return MasterItem(
                                        task.getEditedUniqueId(date),
                                        task.getEditedUniqueId(date),
                                        customWidget: (selected) {
                                          return TaskListElementWidget(
                                            task: task,
                                            prevItem: taskIndex > 0 ? filteredTasks[taskIndex - 1] : null,
                                            isSelected: selected,
                                            openDetails: () => openDetails(task, date),
                                            tabType: TabType.task,
                                            date: date,
                                            onAddTask: widget.dateOnAddTask == null ? false : DateUtils.dateOnly(widget.dateOnAddTask!) == DateUtils.dateOnly(date),
                                            setDateOnAddTask: widget.setDateOnAddTask,
                                            addTaskWidget: TaskListAddTaskWidget(
                                              key: widget.addTaskWidgetKey,
                                              dateOnAddTask: widget.dateOnAddTask,
                                              closeAddTaskWidget: closeAddTaskWidget,
                                            ),
                                            tasksOnSameDate: filteredTasks,
                                            isUnscheduled: currentTaskLabel.type == TaskLabelType.unscheduled,
                                            isOverdue: currentTaskLabel.type == TaskLabelType.overdue,
                                            hideFooter: true,
                                            isCompletedTab: currentTaskLabel.type == TaskLabelType.completed,
                                            isFirst: taskIndex == 0,
                                            showAddTaskBottomSheet: showAddTaskBottomSheet,
                                            currentTaskLabelType: currentTaskLabel.type,
                                          );
                                        },
                                        detailsBuilder: (context, isSmall, onClose) {
                                          return TaskListTaskDetailScreen(
                                            key: ValueKey('task_list_task_details_screen_${task.getEditedUniqueId(date)}_${focusTextFieldOnDetails}'),
                                            task: task,
                                            close: widget.closeDetails,
                                            tabType: TabType.task,
                                            autoFocus: focusTextFieldOnDetails,
                                            showDetilas: (details) {
                                              selectedDetails = details;
                                              setState(() {});
                                            },
                                          );
                                        },
                                        onTap: () {},
                                      );
                                    }).toList()
                            : [
                                ...dateTaskMapList
                                    .mapIndexed((dateIndex, e) {
                                      final date = e.keys.first;
                                      final tasks = e.values.first;
                                      bool isUnscheduled = date == null;
                                      bool isOverdue = date == DateTime(1000);
                                      if (isUnscheduled) tasks.removeWhere((a) => a.status == TaskStatus.braindump);

                                      return tasks.isEmpty
                                          ? [
                                              MasterItem(
                                                '${date == null ? 'unscheduled' : date.toString()}',
                                                '${date == null ? 'unscheduled' : date.toString()}',
                                                customWidget: (selected) {
                                                  return DragTarget(
                                                    onAcceptWithDetails: (details) async {
                                                      if (isOverdue) return;
                                                      final originalTask = details.data as TaskEntity;
                                                      moveTaskDate(date: date, originalTask: originalTask);
                                                    },
                                                    onMove: (details) {
                                                      dragTargetDate.value = date ?? unscheduledPlaceholderDateTime;
                                                    },
                                                    builder: (context, candidateDate, rejectData) {
                                                      return ValueListenableBuilder(
                                                        valueListenable: dragTargetDate,
                                                        builder: (context, data, child) {
                                                          final isInDragTarget = data == null
                                                              ? null
                                                              : isOverdue
                                                              ? false
                                                              : dragStartDate?.isAtSameDayAs(data) == true
                                                              ? false
                                                              : DateUtils.isSameDay(date ?? unscheduledPlaceholderDateTime, data);
                                                          return TaskListElementWidget(
                                                            task: null,
                                                            isSelected: selected,
                                                            openDetails: () {},
                                                            tabType: TabType.task,
                                                            date: date,
                                                            onAddTask: (widget.dateOnAddTask == null || date == null)
                                                                ? false
                                                                : DateUtils.dateOnly(widget.dateOnAddTask!) == DateUtils.dateOnly(date),
                                                            setDateOnAddTask: widget.setDateOnAddTask,
                                                            addTaskWidget: TaskListAddTaskWidget(
                                                              key: widget.addTaskWidgetKey,
                                                              dateOnAddTask: widget.dateOnAddTask,
                                                              closeAddTaskWidget: closeAddTaskWidget,
                                                            ),
                                                            tasksOnSameDate: tasks,
                                                            isUnscheduled: isUnscheduled,
                                                            isOverdue: isOverdue,
                                                            hideFooter: false,
                                                            isCompletedTab: false,
                                                            isFirst: dateIndex == 0,
                                                            showAddTaskBottomSheet: showAddTaskBottomSheet,
                                                            currentTaskLabelType: currentTaskLabel.type,
                                                            isInDragTarget: isInDragTarget,
                                                          );
                                                        },
                                                      );
                                                    },
                                                  );
                                                },
                                                detailsBuilder: (context, isSmall, onClose) {
                                                  return const SizedBox.shrink();
                                                },
                                                onTap: () {},
                                              ),
                                            ]
                                          : tasks.mapIndexed((taskIndex, task) {
                                              return MasterItem(
                                                task.getEditedUniqueId(date),
                                                task.getEditedUniqueId(date),
                                                customWidget: (selected) {
                                                  final project = projects.firstWhereOrNull((e) => e.uniqueId == task.projectId);
                                                  return DragTarget(
                                                    onAcceptWithDetails: (details) async {
                                                      if (isOverdue) return;
                                                      final originalTask = details.data as TaskEntity;
                                                      moveTaskDate(date: date, originalTask: originalTask);
                                                    },
                                                    onMove: (details) {
                                                      dragTargetDate.value = date ?? unscheduledPlaceholderDateTime;
                                                    },
                                                    builder: (context, candidateDate, rejectData) {
                                                      final feedback = Material(
                                                        color: Colors.transparent,
                                                        shadowColor: Colors.transparent,
                                                        child: IntrinsicWidth(
                                                          child: Container(
                                                            constraints: BoxConstraints(maxWidth: 240, minHeight: 40),
                                                            decoration: BoxDecoration(
                                                              color: context.surface,
                                                              borderRadius: BorderRadius.circular(6),
                                                              boxShadow: PopupMenu.popupShadow,
                                                            ),
                                                            padding: EdgeInsets.only(right: 12),
                                                            alignment: Alignment.centerLeft,
                                                            child: Text.rich(
                                                              TextSpan(
                                                                children: [
                                                                  WidgetSpan(
                                                                    child: Container(
                                                                      margin: EdgeInsets.symmetric(horizontal: 12),
                                                                      decoration: BoxDecoration(
                                                                        color: task.status == TaskStatus.done ? project?.color : Colors.transparent,
                                                                        borderRadius: BorderRadius.circular(5),
                                                                        border: task.status == TaskStatus.done
                                                                            ? null
                                                                            : Border.all(color: project?.color ?? Colors.transparent, width: 1.5),
                                                                      ),
                                                                      width: 16,
                                                                      height: 16,
                                                                      child: task.status == TaskStatus.done
                                                                          ? VisirIcon(type: VisirIconType.check, size: 12, color: Colors.white)
                                                                          : null,
                                                                    ),
                                                                  ),
                                                                  TextSpan(text: task.title),
                                                                ],
                                                              ),
                                                              style: context.titleSmall?.textColor(context.outlineVariant),
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                        ),
                                                      );

                                                      final child = ValueListenableBuilder(
                                                        valueListenable: dragTargetDate,
                                                        builder: (context, data, child) {
                                                          final isInDragTarget = data == null
                                                              ? null
                                                              : isOverdue
                                                              ? false
                                                              : dragStartDate?.isAtSameDayAs(data) == true
                                                              ? false
                                                              : DateUtils.isSameDay(date ?? unscheduledPlaceholderDateTime, data);
                                                          return TaskListElementWidget(
                                                            task: task,
                                                            prevItem: taskIndex > 0 ? tasks[taskIndex - 1] : null,
                                                            isSelected: selected,
                                                            openDetails: () => openDetails(task, date),
                                                            tabType: TabType.task,
                                                            date: date,
                                                            onAddTask: (widget.dateOnAddTask == null || date == null)
                                                                ? false
                                                                : DateUtils.dateOnly(widget.dateOnAddTask!) == DateUtils.dateOnly(date),
                                                            setDateOnAddTask: widget.setDateOnAddTask,
                                                            addTaskWidget: TaskListAddTaskWidget(
                                                              key: widget.addTaskWidgetKey,
                                                              dateOnAddTask: widget.dateOnAddTask,
                                                              closeAddTaskWidget: closeAddTaskWidget,
                                                            ),
                                                            tasksOnSameDate: tasks,
                                                            isUnscheduled: isUnscheduled,
                                                            isOverdue: isOverdue,
                                                            hideFooter: false,
                                                            isCompletedTab: false,
                                                            isFirst: dateIndex == 0,
                                                            showAddTaskBottomSheet: showAddTaskBottomSheet,
                                                            currentTaskLabelType: currentTaskLabel.type,
                                                            isInDragTarget: isInDragTarget,
                                                            hasNextItem: taskIndex < tasks.length - 1,
                                                          );
                                                        },
                                                      );

                                                      if (PlatformX.isDesktopView) {
                                                        return Draggable(
                                                          data: task,
                                                          dragAnchorStrategy: pointerDragAnchorStrategy,
                                                          onDragCompleted: () {
                                                            dragTargetDate.value = null;
                                                          },
                                                          onDragStarted: () {
                                                            if (date != null && date.isBefore(DateUtils.dateOnly(DateTime.now()))) {
                                                              dragStartDate = task.startDateOnly;
                                                            } else {
                                                              dragStartDate = date;
                                                            }
                                                          },
                                                          feedback: feedback,
                                                          child: child,
                                                        );
                                                      }

                                                      return LongPressDraggable(
                                                        data: task,
                                                        delay: kLongPressTimeout,
                                                        dragAnchorStrategy: pointerDragAnchorStrategy,
                                                        onDragCompleted: () {
                                                          dragTargetDate.value = null;
                                                        },
                                                        onDragStarted: () {
                                                          if (date != null && date.isBefore(DateUtils.dateOnly(DateTime.now()))) {
                                                            dragStartDate = task.startDateOnly;
                                                          } else {
                                                            dragStartDate = date;
                                                          }
                                                        },
                                                        feedback: feedback,
                                                        child: child,
                                                      );
                                                    },
                                                  );
                                                },
                                                detailsBuilder: (context, isSmall, onClose) {
                                                  return TaskListTaskDetailScreen(
                                                    key: ValueKey('task_list_task_details_screen_${task.getEditedUniqueId(date)}_${focusTextFieldOnDetails}'),
                                                    task: task,
                                                    close: widget.closeDetails,
                                                    tabType: TabType.task,
                                                    autoFocus: focusTextFieldOnDetails,
                                                    showDetilas: (details) {
                                                      selectedDetails = details;
                                                      setState(() {});
                                                    },
                                                  );
                                                },
                                                onTap: () {},
                                              );
                                            }).toList();
                                    })
                                    .expand((x) => x)
                                    .toList(),
                              ],
                      ),
                    ),

                    if (selectedDetails != null) selectedDetails!,
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
