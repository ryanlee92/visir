import 'dart:async';
import 'dart:convert';

import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/rrule/rrule.dart';
import 'package:Visir/dependency/rrule/src/utils.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/auth/domain/entities/notification_entity.dart';
import 'package:Visir/features/auth/providers.dart';
import 'package:Visir/features/calendar/domain/entities/calendar_reminder_entity.dart';
import 'package:Visir/features/calendar/providers.dart';
import 'package:Visir/features/common/infrastructure/entities/environment.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/date_time_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/list_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/recurrence_edit_confirm_popup.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/task/domain/entities/task_entity.dart';
import 'package:Visir/features/task/infrastructure/repositories/task_repository.dart';
import 'package:Visir/features/task/providers.dart';
import 'package:Visir/flavors.dart';
import 'package:collection/collection.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/experimental/persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'calendar_task_list_controller.g.dart';

@riverpod
class CalendarTaskListController extends _$CalendarTaskListController {
  static String stringKey(TabType tabType) => '${tabType.name}:calendar:events';
  Map<String, Map<String, CalendarTaskListControllerInternal>> _controllers = {};
  static String defaultOAuthUniqueKey = 'default';
  List<String> loadedMonth = [];

  @override
  CalendarTaskResultEntity build({required TabType tabType, CalendarDisplayType displayType = CalendarDisplayType.main}) {
    final isSignedIn = ref.watch(authControllerProvider.select((v) => v.requireValue.isSignedIn));
    final shouldUseMockData = ref.watch(shouldUseMockDataProvider);
    if (shouldUseMockData) {
      final targetMonth = ref.read(calendarDisplayDateProvider(tabType).select((v) => v[displayType] ?? DateTime.now()));
      final targetDate = DateTime(targetMonth.year, targetMonth.month);
      final startDateTime = targetDate.subtract(Duration(days: targetDate.weekday % 7 + 1));
      final endDateTime = targetDate.add(Duration(days: 43 - targetDate.weekday % 7));

      getMockTasks()
          .then((v) {
            updateState(tasks: v, startDateTime: startDateTime, endDateTime: endDateTime);
          })
          .catchError((e) {
            // Error loading mock tasks
          });

      return CalendarTaskResultEntity(tasks: [], startDateTime: startDateTime, endDateTime: endDateTime);
    }
    ref.watch(calendarDisplayDateProvider(tabType).select((v) => DateFormat.yM().format(v[displayType] ?? DateTime.now())));
    final targetMonth = ref.read(calendarDisplayDateProvider(tabType).select((v) => v[displayType] ?? DateTime.now()));
    final prevMonth = DateTime(targetMonth.year, targetMonth.month - 1);
    final nextMonth = DateTime(targetMonth.year, targetMonth.month + 1);

    final newLoadedMonth = [DateFormat.yM().format(targetMonth), DateFormat.yM().format(prevMonth), DateFormat.yM().format(nextMonth)];
    final requireLoadMonth = newLoadedMonth.where((e) => !loadedMonth.contains(e)).toList();
    loadedMonth = newLoadedMonth;

    _controllers.clear();

    final targetMonthKey = DateFormat.yM().format(targetMonth);
    final prevMonthKey = DateFormat.yM().format(prevMonth);
    final nextMonthKey = DateFormat.yM().format(nextMonth);

    _controllers[defaultOAuthUniqueKey] = {
      targetMonthKey: ref.watch(calendarTaskListControllerInternalProvider(isSignedIn: isSignedIn, targetYear: targetMonth.year, targetMonth: targetMonth.month).notifier),
      prevMonthKey: ref.watch(calendarTaskListControllerInternalProvider(isSignedIn: isSignedIn, targetYear: prevMonth.year, targetMonth: prevMonth.month).notifier),
      nextMonthKey: ref.watch(calendarTaskListControllerInternalProvider(isSignedIn: isSignedIn, targetYear: nextMonth.year, targetMonth: nextMonth.month).notifier),
    };

    final targetDate = DateTime(targetMonth.year, targetMonth.month);
    final startDateTime = targetDate.subtract(Duration(days: targetDate.weekday % 7 + 1));
    final endDateTime = targetDate.add(Duration(days: 43 - targetDate.weekday % 7));

    // Initialize state with empty result
    state = CalendarTaskResultEntity(tasks: [], startDateTime: startDateTime, endDateTime: endDateTime);

    void _updateFromInternalControllers() {
      final allTasks = <TaskEntity>[];
      _controllers[defaultOAuthUniqueKey]?.forEach((monthKey, controller) {
        // Parse monthKey (format: "yyyy MMM" or similar)
        try {
          final parsedDate = DateFormat.yM().parse(monthKey);
          final controllerState = ref.read(calendarTaskListControllerInternalProvider(isSignedIn: isSignedIn, targetYear: parsedDate.year, targetMonth: parsedDate.month));
          final tasks = controllerState.value ?? <TaskEntity>[];
          allTasks.addAll(tasks);
        } catch (e) {
          // If parsing fails, skip this controller
        }
      });

      final uniqueTasks = allTasks.unique((e) => e.recurringTaskId == null ? e.id : '${e.recurringTaskId}-${e.startAt?.year}-${e.startAt?.month}-${e.startAt?.day}');

      updateState(tasks: uniqueTasks, startDateTime: startDateTime, endDateTime: endDateTime);
    }

    ref.listen(calendarTaskListControllerInternalProvider(isSignedIn: isSignedIn, targetYear: targetMonth.year, targetMonth: targetMonth.month), (prev, next) {
      _updateFromInternalControllers();
    });
    ref.listen(calendarTaskListControllerInternalProvider(isSignedIn: isSignedIn, targetYear: prevMonth.year, targetMonth: prevMonth.month), (prev, next) {
      _updateFromInternalControllers();
    });
    ref.listen(calendarTaskListControllerInternalProvider(isSignedIn: isSignedIn, targetYear: nextMonth.year, targetMonth: nextMonth.month), (prev, next) {
      _updateFromInternalControllers();
    });

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!(tabType == TabType.home && PlatformX.isDesktopView) && tabType != TabType.calendar) return;
      refresh(requireLoadMonth: requireLoadMonth);
    });

    _updateFromInternalControllers();
    return state;
  }

  Timer? timer;
  void updateState({required List<TaskEntity> tasks, required DateTime startDateTime, required DateTime endDateTime}) {
    final previousResult = state;
    final result = CalendarTaskResultEntity(
      tasks: tasks,
      startDateTime: startDateTime,
      endDateTime: endDateTime,
      previousTasksOnView: previousResult.tasksOnView,
      previousFetchedUntil: previousResult.fetchedUntil,
      previousTasks: previousResult.tasks,
      previousCachedRecurrenceInstances: previousResult.cachedRecurrenceInstances,
    );
    if (timer == null) state = result;
    timer?.cancel();
    timer = Timer(const Duration(milliseconds: kControllerDebouncMillisecond), () {
      state = result;
      timer = null;
    });
  }

  Future<void> refresh({bool? showLoading, bool? isChunkUpdate, List<String>? requireLoadMonth}) async {
    if (ref.read(shouldUseMockDataProvider)) return;

    Completer<void> completer = Completer();
    int resultCount = 0;
    ref.read(loadingStatusProvider.notifier).update(stringKey(tabType), LoadingState.loading);
    final controllerLength = _controllers.entries.expand((e) => e.value.entries.where((e) => requireLoadMonth?.contains(e.key) ?? true)).length;

    // OAuth가 없으면 즉시 success로 완료
    if (controllerLength == 0) {
      ref.read(loadingStatusProvider.notifier).update(stringKey(tabType), LoadingState.success);
      completer.complete();
      return completer.future;
    }

    _controllers.forEach((key, value) {
      value.entries.where((e) => requireLoadMonth?.contains(e.key) ?? true).forEach((e) {
        e.value
            .refresh()
            .then((_) {
              resultCount++;
              if (resultCount != controllerLength) return;
              ref.read(loadingStatusProvider.notifier).update(stringKey(tabType), LoadingState.success);
              completer.complete();
            })
            .catchError((error) {
              resultCount++;
              if (resultCount != controllerLength) return;
              ref.read(loadingStatusProvider.notifier).update(stringKey(tabType), LoadingState.error);
              completer.complete();
            });
      });
    });

    return completer.future;
  }

  Future<void> load({bool? showLoading, bool? isRefresh, bool? isChunkUpdate}) async {
    Completer<void> completer = Completer();
    int resultCount = 0;
    ref.read(loadingStatusProvider.notifier).update(stringKey(tabType), LoadingState.loading);
    final controllerLength = _controllers.entries.expand((e) => e.value.entries).length;

    // OAuth가 없으면 즉시 success로 완료
    if (controllerLength == 0) {
      ref.read(loadingStatusProvider.notifier).update(stringKey(tabType), LoadingState.success);
      completer.complete();
      return completer.future;
    }

    _controllers.forEach((key, value) {
      value.entries.forEach((e) {
        e.value
            .load(showLoading: showLoading, isRefresh: isRefresh, isChunkUpdate: isChunkUpdate)
            .then((_) {
              resultCount++;
              if (resultCount != controllerLength) return;
              ref.read(loadingStatusProvider.notifier).update(stringKey(tabType), LoadingState.success);
              completer.complete();
            })
            .catchError((error) {
              resultCount++;
              if (resultCount != controllerLength) return;
              ref.read(loadingStatusProvider.notifier).update(stringKey(tabType), LoadingState.error);
              completer.complete();
            });
      });
    });

    return completer.future;
  }

  Future<void> saveTask({
    TaskEntity? originalTask,
    TaskEntity? newTask,
    required DateTime? selectedEndDate,
    required DateTime? selectedStartDate,
    bool? updateTaskStatus,
    required TabType targetTab,
  }) async {
    if (ref.read(shouldUseMockDataProvider)) {
      if (newTask == null) return;
      state = CalendarTaskResultEntity(tasks: [...(state.tasks), newTask], startDateTime: state.startDateTime, endDateTime: state.endDateTime);
      return;
    }

    Completer<void> completer = Completer();
    int resultCount = 0;

    String recurrence =
        originalTask?.rrule?.toString(options: RecurrenceRuleToStringOptions(isTimeUtc: true)) ??
        state.tasks.firstWhereOrNull((e) => e.id == originalTask?.recurringTaskId)?.rrule?.toString(options: RecurrenceRuleToStringOptions(isTimeUtc: true)) ??
        '';

    RecurringTaskEditType? editType;
    if (recurrence.isNotEmpty) {
      if (updateTaskStatus == true || (originalTask?.recurringTaskId != null && originalTask?.rrule == null) || tabType != targetTab) {
        if (selectedStartDate == null || selectedEndDate == null) return;
        editType = RecurringTaskEditType.thisTaskOnly;
      } else {
        if (selectedStartDate == null || selectedEndDate == null) return;
        await Future.delayed(Duration(milliseconds: 300), () {});
        final type = await Utils.showRecurrenceEditConfirmPopup(isTask: true);
        if (type == null) return;
        if (Navigator.canPop(Utils.mainContext)) {
          Navigator.of(Utils.mainContext).popUntil((route) => route.isFirst);
        }

        editType = type;
      }
    }

    _controllers[defaultOAuthUniqueKey]?.entries.forEach((e) {
      e.value
          .saveTask(
            recurringTaskEditType: editType,
            originalTask: originalTask,
            newTask: newTask,
            selectedEndDate: selectedEndDate,
            selectedStartDate: selectedStartDate,
            updateTaskStatus: updateTaskStatus,
            targetTab: targetTab,
            tabType: tabType,
          )
          .then((e) {
            resultCount++;
            if (resultCount != 1) return;
            completer.complete();
          })
          .catchError((error) {
            resultCount++;
            if (resultCount != 1) return;
            completer.complete();
          });
    });

    return completer.future;
  }

  void onUpdateTask(TaskEntity task) {
    _controllers[defaultOAuthUniqueKey]?.entries.forEach((e) {
      e.value.onUpdateTask(task);
    });
  }

  void onDeleteTask(String taskId) {
    _controllers[defaultOAuthUniqueKey]?.entries.forEach((e) {
      e.value.onDeleteTask(taskId);
    });
  }

  Future<List<TaskEntity>> getMockTasks() async {
    final result = await rootBundle.loadString('assets/mock/tasks.json');
    final data = jsonDecode(result) as List<dynamic>;
    final userId = ref.read(authControllerProvider.select((e) => e.requireValue.id));
    List<TaskEntity> tasks = data
        .map((e) {
          // project_id가 'userId'인 경우 실제 userId로 변환
          final originalData = Map<String, dynamic>.from(e as Map);
          final taskData = originalData['linked_event']?['googleEvent']?['id'] == linkedChatEventId ? originalData : {...originalData, 'linked_event': null};
          final finalTaskData = Map<String, dynamic>.from(taskData);
          if (finalTaskData['project_id'] == 'userId') {
            finalTaskData['project_id'] = userId;
          }

          // 특정 이벤트를 오늘 오후 2시로 설정
          final eventId = finalTaskData['linked_event']?['googleEvent']?['id'] as String?;
          if (eventId == '82ec12262eeb4566b0dab11a') {
            final now = DateTime.now();
            final todayStart = DateTime(now.year, now.month, now.day, 14, 0); // 오후 2시
            final todayEnd = DateTime(now.year, now.month, now.day, 15, 0); // 오후 3시 (1시간 이벤트)

            // task의 start_at과 end_at도 설정 (이벤트가 있을 때도 사용됨)
            finalTaskData['start_at'] = todayStart.toIso8601String();
            finalTaskData['end_at'] = todayEnd.toIso8601String();

            // linked_event의 googleEvent 날짜도 설정
            final linkedEvent = finalTaskData['linked_event'] as Map<String, dynamic>;
            final googleEvent = linkedEvent['googleEvent'] as Map<String, dynamic>;
            googleEvent['start'] = {'dateTime': todayStart.toIso8601String(), 'timeZone': 'Asia/Seoul'};
            googleEvent['end'] = {'dateTime': todayEnd.toIso8601String(), 'timeZone': 'Asia/Seoul'};
            linkedEvent['googleEvent'] = googleEvent;
            linkedEvent['do_not_apply_date_offset'] = true; // 이벤트에도 설정
            finalTaskData['linked_event'] = linkedEvent;
            finalTaskData['do_not_apply_date_offset'] = true;
          }

          // 특정 task를 오늘 오후 5시로 설정
          final taskId = finalTaskData['id'] as String?;
          if (taskId == '04ddee1f-9505-4cb1-8f9b-2461e5a95a75') {
            final now = DateTime.now();
            final todayStart = DateTime(now.year, now.month, now.day, 17, 0); // 오후 5시
            final todayEnd = DateTime(now.year, now.month, now.day, 18, 0); // 오후 6시 (1시간 task)
            finalTaskData['start_at'] = todayStart.toIso8601String();
            finalTaskData['end_at'] = todayEnd.toIso8601String();
            finalTaskData['do_not_apply_date_offset'] = true;
          }

          final task = TaskEntity.fromJson(finalTaskData, local: true);

          // 이벤트의 doNotApplyDateOffset과 editedStartTime/editedEndTime 설정
          if (eventId == '82ec12262eeb4566b0dab11a' && task.linkedEvent != null) {
            final now = DateTime.now();
            final todayStart = DateTime(now.year, now.month, now.day, 14, 0); // 오후 2시
            final todayEnd = DateTime(now.year, now.month, now.day, 15, 0); // 오후 3시
            // editedStartTime과 editedEndTime을 설정하여 시간 표시가 올바르게 되도록 함
            task.linkedEvent = task.linkedEvent!.copyWith(editedStartTime: todayStart, editedEndTime: todayEnd);
            task.linkedEvent!.doNotApplyDateOffset = true;
          }

          return task;
        })
        .whereType<TaskEntity>()
        .toList();

    final list = tasks.where((e) => e.id?.isNotEmpty == true).toList().unique((e) => e.id)..sort((a, b) => a.id!.compareTo(b.id!));
    final mockTasksList = mockTasks(now: DateTime.now(), context: Utils.mainContext, userId: userId);
    final allTasks = [...list, ...mockTasksList].unique((e) => e.id);
    return allTasks;
  }
}

@riverpod
class CalendarTaskListControllerInternal extends _$CalendarTaskListControllerInternal {
  late TaskRepository _taskRepository;

  List<TaskEntity> get tasks => [...state.value ?? []];

  DateTime updatedTimestamp = DateTime.now();

  List<TaskEntity> _beforeLoginTasks = [];

  @override
  Future<List<TaskEntity>> build({required bool isSignedIn, required int targetYear, required int targetMonth}) async {
    _taskRepository = ref.watch(taskRepositoryProvider);
    isSignedIn = ref.watch(authControllerProvider.select((v) => v.requireValue.isSignedIn));

    if (ref.watch(shouldUseMockDataProvider)) {
      load(showLoading: true, isRefresh: true, isChunkUpdate: true);
      return state.value ?? [];
    }

    // shouldUseMockDataProvider가 false이므로 isSignedIn은 true입니다
    // 따라서 userId는 안전하게 가져올 수 있습니다

    await persist(
      ref.watch(storageProvider.future),
      key: '${CalendarTaskListController.stringKey(TabType.calendar)}:${isSignedIn}:${targetYear}:${targetMonth}',
      encode: (List<TaskEntity>? state) => state == null ? '' : jsonEncode(state.map((e) => e.toJson(local: true)).toList()),
      decode: (String encoded) {
        final trimmed = encoded.trim();
        if (trimmed.isEmpty || trimmed == 'null') {
          return [];
        }
        return (jsonDecode(trimmed) as List<dynamic>).map((e) => TaskEntity.fromJson(e, local: true)).toList();
      },
      options: Utils.storageOptions,
    ).future;

    return state.value ?? [];
  }

  bool _isRefreshing = false;
  bool _isRefreshPending = false;

  Future<void> refresh({bool? showLoading, bool? isChunkUpdate}) async {
    if (_isRefreshing) {
      _isRefreshPending = true;
      return;
    }
    _isRefreshing = true;
    try {
      await load(showLoading: showLoading, isRefresh: true, isChunkUpdate: isChunkUpdate);
    } finally {
      _isRefreshing = false;
      if (_isRefreshPending) {
        _isRefreshPending = false;
        refresh(showLoading: showLoading, isChunkUpdate: isChunkUpdate);
      }
    }
  }

  Future<void> load({bool? showLoading, bool? isRefresh, bool? isChunkUpdate}) async {
    if (ref.read(shouldUseMockDataProvider)) {
      return;
    }

    final pref = ref.read(localPrefControllerProvider).value;
    final user = ref.read(authControllerProvider).requireValue;
    if (pref == null) return;

    final updateTimestamp = DateTime.now();

    final targetDate = DateTime(targetYear, targetMonth);

    final startDateTime = targetDate.subtract(Duration(days: targetDate.weekday % 7 + 1));
    final endDateTime = targetDate.add(Duration(days: 43 - targetDate.weekday % 7));
    final result = await _taskRepository.fetchTasksBetweenDates(startDateTime: startDateTime, endDateTime: endDateTime, pref: pref, userId: user.id);

    result.fold((l) {}, (r) {
      _updateState(list: [...r]..unique((e) => e.id), targetMonth: targetDate, updatedTimestamp: updateTimestamp, isLocalUpdate: false, isChunkUpdate: isChunkUpdate);
    });
  }

  Future<void> saveTask({
    TaskEntity? originalTask,
    TaskEntity? newTask,
    required DateTime? selectedEndDate,
    required DateTime? selectedStartDate,
    bool? updateTaskStatus,
    required TabType? targetTab,
    required TabType tabType,
    required RecurringTaskEditType? recurringTaskEditType,
  }) async {
    BuildContext context = Utils.mainContext;
    String recurrence =
        originalTask?.rrule?.toString(options: RecurrenceRuleToStringOptions(isTimeUtc: true)) ??
        tasks.firstWhereOrNull((e) => e.id == originalTask?.recurringTaskId)?.rrule?.toString(options: RecurrenceRuleToStringOptions(isTimeUtc: true)) ??
        '';

    if (recurrence.isNotEmpty) {
      if (selectedStartDate == null || selectedEndDate == null || recurringTaskEditType == null) return;
      await _updateRecurringEvent(
        recurringTaskEditType: recurringTaskEditType,
        originalTask: originalTask!,
        newTask: newTask,
        selectedEndDate: selectedEndDate,
        selectedStartDate: selectedStartDate,
        context: context,
        targetTab: targetTab,
        tabType: tabType,
      );
    } else {
      if (newTask != null) {
        await _upsertTask(task: newTask, originalTask: originalTask, context: context, targetTab: targetTab, tabType: tabType);
      } else if (originalTask != null) {
        await _deleteTask(task: originalTask, context: context, targetTab: targetTab, tabType: tabType);
      }
    }
  }

  Future<void> _updateRecurringEvent({
    required RecurringTaskEditType recurringTaskEditType,
    required TaskEntity originalTask,
    required TaskEntity? newTask,
    required DateTime selectedEndDate,
    required DateTime selectedStartDate,
    required BuildContext context,
    required TabType? targetTab,
    required TabType tabType,
  }) async {
    final initialStartDate = originalTask.recurringTaskId != originalTask.id ? originalTask.startAt : tasks.firstWhereOrNull((e) => e.id == originalTask.recurringTaskId)?.startAt;
    final initialEndDate = originalTask.recurringTaskId != originalTask.id ? originalTask.endAt : tasks.firstWhereOrNull((e) => e.id == originalTask.recurringTaskId)?.endAt;
    final isDelete = newTask == null;

    if (initialStartDate == null || initialEndDate == null) return;

    RecurrenceRule? originalRrule = originalTask.rrule ?? tasks.firstWhereOrNull((e) => e.id == originalTask.recurringTaskId)?.rrule;
    RecurrenceRule? newEventRrule = newTask?.rrule;
    if (originalRrule == null) return;
    final newRrule = originalRrule != newEventRrule
        ? newEventRrule
        : newTask == null
        ? originalRrule
        : originalRrule.copyWith(
            byMonthDays: originalRrule.byMonthDays.map((e) => e == selectedStartDate.day ? newTask.startDate.day : e).toList(),
            byYearDays: originalRrule.byYearDays.map((e) => e == selectedStartDate.daysInYear ? newTask.startDate.daysInYear : e).toList(),
            byWeeks: originalRrule.byWeeks.map((e) => e == selectedStartDate.weekInfo.weekOfYear ? newTask.startDate.weekInfo.weekOfYear : e).toList(),
            byMonths: originalRrule.byMonths.map((e) => e == selectedStartDate.month ? newTask.startDate.month : e).toList(),
            byWeekDays: originalRrule.byWeekDays.map((e) => e.day == selectedStartDate.weekday ? ByWeekDayEntry(newTask.startDate.weekday, e.occurrence) : e).toList(),
          );

    switch (recurringTaskEditType) {
      case RecurringTaskEditType.thisTaskOnly:
        final newEventId = Uuid().v4();

        List<TaskEntity> prevState = tasks;

        TaskEntity savingTask;

        List<TaskEntity> list;
        if (isDelete) {
          if (originalTask.recurringTaskId == null) {
            savingTask = originalTask.copyWith(
              id: newEventId,
              recurringTaskId: originalTask.id,
              startAt: selectedStartDate,
              endAt: selectedStartDate,
              status: TaskStatus.cancelled,
              removeRrule: true,
            );
            list = [...tasks]..add(savingTask);
          } else {
            savingTask = originalTask.copyWith(
              id: originalTask.id,
              recurringTaskId: originalTask.recurringTaskId,
              startAt: selectedStartDate,
              endAt: selectedStartDate,
              status: TaskStatus.cancelled,
              removeRrule: true,
            );
            list = tasks.map((e) {
              if (e.eventId == originalTask.eventId) {
                return savingTask;
              } else {
                return e;
              }
            }).toList();
          }

          DateTime updatedTimestamp = DateTime.now();
          this.updatedTimestamp = updatedTimestamp;

          _updateState(list: list, updatedTimestamp: updatedTimestamp, isLocalUpdate: true);
        } else {
          if (originalTask.recurringTaskId == null) {
            savingTask = newTask.copyWith(id: newEventId, recurringTaskId: originalTask.id, removeRrule: true);
            list = tasks..add(savingTask);
          } else {
            savingTask = newTask.copyWith(id: originalTask.id, recurringTaskId: originalTask.recurringTaskId, removeRrule: true);
            list = tasks.map((e) {
              if (e.eventId == originalTask.eventId) {
                return savingTask;
              } else {
                return e;
              }
            }).toList();
          }

          DateTime updatedTimestamp = DateTime.now();
          this.updatedTimestamp = updatedTimestamp;

          _updateState(list: list, updatedTimestamp: updatedTimestamp, isLocalUpdate: true);
        }

        final recurringTask = originalTask.recurringTaskId == null ? originalTask : tasks.firstWhereOrNull((e) => e.id == originalTask.recurringTaskId);
        if (originalTask.startAt != null && recurringTask != null) {
          final bool isEditedRecurringTask = recurringTask.editedRecurrenceTaskIds?.contains(originalTask.id) ?? false;

          if (!isEditedRecurringTask) {
            final excludedRecurrenceDate = recurringTask.excludedRecurrenceDate ?? [];
            final editedRecurrenceTaskIds = recurringTask.editedRecurrenceTaskIds ?? [];
            await _upsertTask(
              task: recurringTask.copyWith(
                excludedRecurrenceDate: [...excludedRecurrenceDate, selectedStartDate.toUtc()].unique(),
                editedRecurrenceTaskIds: [...editedRecurrenceTaskIds, savingTask.id!].unique(),
              ),
              originalTask: null,
              context: context,
              targetTab: targetTab,
              tabType: tabType,
            );
          }
        }

        var result = await _upsertTask(
          task: savingTask.copyWith(excludedRecurrenceDate: [], editedRecurrenceTaskIds: []),
          originalTask: null,
          doNotUpdateState: true,
          prevState: prevState,
          context: context,
          targetTab: targetTab,
          tabType: tabType,
        );

        final remoteFetchList = result.where((e) => e.id != null).toList().unique((e) => e.id);
        _updateState(list: remoteFetchList, updatedTimestamp: updatedTimestamp, isLocalUpdate: false);
        break;
      case RecurringTaskEditType.thisAndFollowingTasks:
        {
          final rruleSelectedStartDate = selectedStartDate;
          final prevInstance = rruleSelectedStartDate.compareTo(initialStartDate) < 0
              ? null
              : originalRrule.getInstances(start: initialStartDate.toUtc(), before: rruleSelectedStartDate.toUtc(), includeBefore: false);
          final prevInstanceCount = prevInstance?.length ?? 0;
          final prevRrule = prevInstanceCount < 1
              ? null
              : originalRrule.copyWith(
                  until: originalRrule.count != null
                      ? null
                      : prevInstance?.isNotEmpty != true
                      ? rruleSelectedStartDate.toUtc()
                      : prevInstance!.last.toUtc(),
                  count: originalRrule.count == null ? null : prevInstanceCount,
                );

          final prevTasks = prevRrule == null
              ? null
              : (originalTask.recurringTaskId == null ? originalTask : tasks.firstWhereOrNull((e) => e.id == originalTask.recurringTaskId))?.copyWith(rrule: prevRrule);

          final thisAndFutureEvents = isDelete ? null : newTask.copyWith(id: Uuid().v4(), rrule: newRrule);

          if (isDelete) {
            List<TaskEntity> prevState = tasks;
            final list = tasks
              ..removeWhere((e) => (e.id == prevTasks?.id) || (e.id == originalTask.id) || (e.recurringTaskId == originalTask.id && e.startAt!.isAfter(selectedStartDate)))
              ..unique((e) => e.id)
              ..addAll([if (prevTasks != null) prevTasks]);

            DateTime updatedTimestamp = DateTime.now();
            this.updatedTimestamp = updatedTimestamp;

            _updateState(list: list, updatedTimestamp: updatedTimestamp, isLocalUpdate: true);

            // for this event
            List<TaskEntity> result;
            if (prevTasks == null) {
              result = await _deleteTask(task: originalTask, doNotUpdateState: true, prevState: prevState, context: context, targetTab: targetTab, tabType: tabType);
            } else {
              result = await _upsertTask(
                task: prevTasks,
                originalTask: originalTask,
                doNotUpdateState: true,
                prevState: prevState,
                context: context,
                targetTab: targetTab,
                tabType: tabType,
              );
            }

            final remoteFetchList = result.where((e) => e.id != null).toList().unique((e) => e.id);

            _updateState(list: remoteFetchList, updatedTimestamp: updatedTimestamp, isLocalUpdate: false);
          } else {
            List<TaskEntity> prevState = tasks;
            final list = tasks
              ..removeWhere((e) => (e.id == prevTasks?.id) || (e.id == originalTask.id) || (e.recurringTaskId == originalTask.id && e.startAt!.isAfter(selectedStartDate)))
              ..unique((e) => e.id)
              ..addAll([thisAndFutureEvents!, if (prevTasks != null) prevTasks]);

            DateTime updatedTimestamp = DateTime.now();
            this.updatedTimestamp = updatedTimestamp;

            _updateState(list: list, updatedTimestamp: updatedTimestamp, isLocalUpdate: true);

            // for this event
            List<TaskEntity> result;
            if (prevTasks == null) {
              result = await _deleteTask(task: originalTask, doNotUpdateState: true, prevState: prevState, context: context, targetTab: targetTab, tabType: tabType);
            } else {
              result = await _upsertTask(
                task: prevTasks,
                originalTask: originalTask,
                doNotUpdateState: true,
                prevState: prevState,
                context: context,
                targetTab: targetTab,
                tabType: tabType,
              );
            }

            result = await _upsertTask(
              task: thisAndFutureEvents,
              originalTask: originalTask,
              doNotUpdateState: true,
              prevState: result,
              context: context,
              targetTab: targetTab,
              tabType: tabType,
            );

            final remoteFetchList = result.where((e) => e.id != null).toList().unique((e) => e.id);
            _updateState(list: remoteFetchList, updatedTimestamp: updatedTimestamp, isLocalUpdate: false);
          }
          break;
        }
      case RecurringTaskEditType.allTasks:
        {
          final recurringTask = (originalTask.recurringTaskId == null ? originalTask : tasks.firstWhereOrNull((e) => e.id == originalTask.recurringTaskId));

          if (recurringTask == null) return;

          if (isDelete) {
            await _deleteTask(task: recurringTask, context: context, forceDelete: true, targetTab: targetTab, tabType: tabType);
          } else {
            final allTasks = originalTask.recurringTaskId == null
                ? newTask.copyWith(
                    isAllDay: newTask.isAllDay,
                    rrule: newRrule,
                    startAt: DateUtils.dateOnly(initialStartDate.toLocal()).add(
                      Duration(
                        days: DateUtils.dateOnly(newTask.startAt!.toLocal()).difference(DateUtils.dateOnly(selectedStartDate.toLocal())).inDays,
                        hours: newTask.startAt!.hour,
                        minutes: newTask.startAt!.minute,
                      ),
                    ),
                    endAt: DateUtils.dateOnly(initialEndDate.toLocal()).add(
                      Duration(
                        days: DateUtils.dateOnly(newTask.endAt!.toLocal()).difference(DateUtils.dateOnly(selectedEndDate.toLocal())).inDays,
                        hours: newTask.endAt!.hour,
                        minutes: newTask.endAt!.minute,
                      ),
                    ),
                  )
                : recurringTask.copyWith(
                    title: newTask.title,
                    description: newTask.description,
                    rrule: newRrule,
                    reminders: newTask.reminders,
                    isAllDay: newTask.isAllDay,
                    startAt: DateUtils.dateOnly(initialStartDate.toLocal()).add(
                      Duration(
                        days: DateUtils.dateOnly(newTask.startDate.toLocal()).difference(DateUtils.dateOnly(selectedStartDate.toLocal())).inDays,
                        hours: newTask.startDate.hour,
                        minutes: newTask.startDate.minute,
                      ),
                    ),
                    endAt: DateUtils.dateOnly(initialEndDate.toLocal()).add(
                      Duration(
                        days: DateUtils.dateOnly(newTask.endDate.toLocal()).difference(DateUtils.dateOnly(selectedEndDate.toLocal())).inDays,
                        hours: newTask.endDate.hour,
                        minutes: newTask.endDate.minute,
                      ),
                    ),
                  );

            await _upsertTask(task: allTasks, originalTask: originalTask, context: context, targetTab: targetTab, tabType: tabType);
          }
          break;
        }
    }
  }

  Future<List<TaskEntity>> _upsertTask({
    required TaskEntity task,
    required TaskEntity? originalTask,
    bool? doNotUpdateState,
    List<TaskEntity>? prevState,
    required BuildContext context,
    required TabType? targetTab,
    required TabType tabType,
  }) async {
    final pref = ref.read(localPrefControllerProvider).value;
    if (pref == null) return [];

    List<TaskEntity> previousState = prevState ?? tasks;

    final list = tasks
      ..removeWhere((e) => e.id == (originalTask?.id ?? task.id))
      ..add(task)
      ..unique((e) => e.id);

    if (doNotUpdateState != true) {
      DateTime updatedTimestamp = DateTime.now();

      _updateState(list: list, updatedTimestamp: updatedTimestamp, isLocalUpdate: true);
    }

    final targetDate = ref.read(calendarDisplayDateProvider(tabType).select((v) => v[CalendarDisplayType.main] ?? DateTime.now()));
    if (targetTab != tabType || targetMonth != targetDate.month) return list;
    if (ref.read(shouldUseMockDataProvider)) return list;

    final eventResult = await _taskRepository.saveTask(task: task);

    return eventResult.fold(
      (l) {
        if (doNotUpdateState != true) {
          _updateState(list: previousState, updatedTimestamp: updatedTimestamp, isLocalUpdate: true);
        }
        return previousState;
      },
      (r) async {
        final remoteFetchList = tasks
          ..removeWhere((e) => e.id == r.id)
          ..add(r)
          ..unique((e) => e.id);

        if (doNotUpdateState == true) {
          _updateState(list: remoteFetchList, updatedTimestamp: updatedTimestamp, isLocalUpdate: false);
        }

        return [...remoteFetchList];
      },
    );
  }

  Future<List<TaskEntity>> _deleteTask({
    required TaskEntity task,
    bool? forceDelete,
    bool? doNotUpdateState,
    List<TaskEntity>? prevState,
    required BuildContext context,
    required TabType? targetTab,
    required TabType tabType,
  }) async {
    final pref = ref.read(localPrefControllerProvider).value;
    if (pref == null) return [];

    List<TaskEntity> previousState = prevState ?? tasks;

    final list = tasks
      ..removeWhere((e) => e.id == task.id!)
      ..add(task.copyWith(status: TaskStatus.cancelled, startAt: task.startAt, endAt: task.startAt))
      ..unique((e) => e.id);

    if (doNotUpdateState != true) {
      DateTime updatedTimestamp = DateTime.now();
      this.updatedTimestamp = updatedTimestamp;

      _updateState(list: list, updatedTimestamp: updatedTimestamp, isLocalUpdate: true);
    }

    final targetDate = ref.read(calendarDisplayDateProvider(tabType).select((v) => v[CalendarDisplayType.main] ?? DateTime.now()));

    if (targetTab != tabType || targetMonth != targetDate.month) return list;
    if (!isSignedIn) return list;
    if (ref.read(shouldUseMockDataProvider)) return list;

    final eventResult = task.rrule == null || forceDelete == true
        ? await _taskRepository.deleteTask(task: task)
        : await _taskRepository.saveTask(
            task: task.copyWith(status: TaskStatus.cancelled, startAt: task.startAt, endAt: task.startAt),
          );

    return eventResult.fold(
      (l) {
        if (doNotUpdateState != true) {
          _updateState(list: previousState, updatedTimestamp: updatedTimestamp, isLocalUpdate: true);
        }

        return previousState;
      },
      (r) async {
        final remoteFetchList = tasks
          ..removeWhere((e) => e.id! == task.id)
          ..unique((e) => e.id);

        if (doNotUpdateState == true) {
          _updateState(list: remoteFetchList, updatedTimestamp: updatedTimestamp, isLocalUpdate: false);
        }

        return remoteFetchList;
      },
    );
  }

  bool isAbleToUpdate({required List<TaskEntity> next, required List<TaskEntity> prev, required bool isLocalUpdate}) {
    if (next.length < prev.length) return true;
    if (isLocalUpdate) return true;
    for (var n in next) {
      final p = prev.firstWhereOrNull((e) => e.id == n.id);
      if (p == null) return true;
      if (p != n) return true;
    }
    return false;
  }

  void _updateState({required List<TaskEntity> list, DateTime? targetMonth, required DateTime updatedTimestamp, required bool isLocalUpdate, bool? isChunkUpdate}) async {
    if (!ref.mounted) return;
    // if (!isAbleToUpdate(next: list, prev: tasks, isLocalUpdate: isLocalUpdate)) return;

    list = list.where((e) => e.id?.isNotEmpty == true).toList().unique((e) => e.id)..sort((a, b) => a.id!.compareTo(b.id!));
    _beforeLoginTasks = _beforeLoginTasks.map((e) => list.firstWhereOrNull((e) => e.id == e.id) ?? e).toList();

    if (list.isEmpty) {
      _uploadRemindersAndSyncToServer();
      state = const AsyncData([]);
      return;
    }

    // 재귀적 PostFrameCallback 제거 - 한 번에 업데이트하여 성능 개선
    state = AsyncData([...list]);

    if (!ref.read(shouldUseMockDataProvider)) {
      _uploadRemindersAndSyncToServer();
    }
  }

  void _uploadRemindersAndSyncToServer() async {
    if (targetMonth != DateTime.now().month || targetYear != DateTime.now().year) return;
    final list = state.value ?? [];

    /// 🔧 리마인더 추출 + 서버 전송 (렌더링과 분리된 사이드이펙트 전용 함수)
    final user = ref.read(authControllerProvider).requireValue;
    final pref = ref.read(localPrefControllerProvider).value;
    final deviceId = ref.read(deviceIdProvider).asData?.value;
    if (ref.read(shouldUseMockDataProvider)) return;
    if (pref == null || deviceId?.isEmpty != false) return;

    final configFile = await rootBundle.loadString('assets/config/${F.envFileName}');
    final env = Environment.fromJson(json.decode(configFile) as Map<String, dynamic>);

    /// 📌 EventEntity 리스트에서 CalendarReminderEntity 추출
    final doneTasks = list.where((e) => e.isDone).toList();
    final cancelledTasks = list.where((e) => e.isCancelled).toList();

    final notificationList = list
        .expand(
          (e) => (e.reminders ?? []).expand((r) {
            if (r.minutes == null) return [];
            if (e.isDone || e.isCancelled) return [];

            final title = Utils.encryptAESCryptoJS(e.title ?? '(No title)', env.encryptAESKey);

            if (e.rrule != null) {
              if (e.startDate.isAfter(DateTime.now().add(Duration(days: 28)))) return [];

              final list = e.rrule!
                  .getInstances(
                    start: e.startDate,
                    after: e.startDate.isAfter(DateTime.now()) ? e.startDate : DateTime.now(),
                    before: DateTime.now().add(Duration(days: 28)),
                    includeBefore: true,
                    includeAfter: true,
                  )
                  .toList();

              final excludedDates = [...doneTasks, ...cancelledTasks].where((t) => t.recurringTaskId == e.id).toList().map((t) => t.startDateOnly).toList();
              list.removeWhere((date) => excludedDates.contains(DateUtils.dateOnly(date)));
              list.removeWhere((date) => e.excludedRecurrenceDate?.contains(date) ?? false);
              list.removeWhere((date) => date.isBefore(DateTime.now()));

              return list.map((date) {
                final endDate = date.add(Duration(minutes: e.endDate.difference(e.startDate).inMinutes));
                final startDate = date;
                return CalendarReminderEntity(
                  id: user.id + e.id! + date.millisecondsSinceEpoch.toString() + r.minutes!.toString(),
                  email: e.calendarMail,
                  title: title,
                  minutes: r.minutes!,
                  userId: user.id,
                  calendarId: e.calendarId,
                  eventId: e.id!,
                  deviceId: deviceId!,
                  calendarName: e.calendarName,
                  provider: e.calendarType,
                  targetDateTime: (date.subtract(Duration(minutes: r.minutes!))).toUtc(),
                  startDate: date,
                  isAllDay: e.isAllDay,
                  endDate: e.isAllDay
                      ? endDate.isBefore(startDate.add(Duration(days: 1)))
                            ? startDate
                            : endDate.subtract(Duration(days: 1))
                      : endDate,
                  locale: Intl.getCurrentLocale(),
                  isEncrypted: true,
                  iv: '',
                );
              }).toList();
            } else {
              if (e.startDate.isBefore(DateTime.now())) return [];

              return [
                CalendarReminderEntity(
                  id: user.id + e.id! + r.minutes!.toString(),
                  email: e.calendarMail,
                  title: title,
                  minutes: r.minutes!,
                  userId: user.id,
                  calendarId: e.calendarId,
                  eventId: e.id!,
                  deviceId: deviceId!,
                  calendarName: e.calendarName,
                  provider: e.calendarType,
                  targetDateTime: (e.startDate.subtract(Duration(minutes: r.minutes!))).toUtc(),
                  startDate: e.startDate,
                  endDate: e.isAllDay
                      ? e.endDate.isBefore(e.startDate.add(Duration(days: 1)))
                            ? e.startDate
                            : e.endDate.subtract(Duration(days: 1))
                      : e.endDate,
                  isAllDay: e.isAllDay,
                  locale: Intl.getCurrentLocale(),
                  isEncrypted: true,
                  iv: '',
                ),
              ];
            }
          }),
        )
        .whereType<CalendarReminderEntity>()
        .where((e) => e.targetDateTime.isAfter(DateTime.now()))
        .toList();

    final _saveReminders = (NotificationEntity r) async {
      ref.read(calendarRepositoryProvider).saveReminders(userId: user.id, reminders: notificationList, notification: r, isCalendar: false);
    };

    /// 🔄 서버에서 알림 설정 정보 가져와서 함께 저장
    final notification = await ref.read(authRepositoryProvider).getNotification(userId: user.id, deviceId: deviceId!);
    notification.fold((l) => null, (r) {
      EasyDebounce.debounce('save_reminders:task', const Duration(seconds: 1), () => _saveReminders(r));
    });
  }

  void onUpdateTask(TaskEntity task) {
    updatedTimestamp = DateTime.now();
    final remoteFetchList = tasks
      ..removeWhere((e) => e.id! == task.id)
      ..add(task)
      ..unique((e) => e.id);
    _updateState(list: remoteFetchList, updatedTimestamp: updatedTimestamp, isLocalUpdate: true);
  }

  void onDeleteTask(String taskId) {
    updatedTimestamp = DateTime.now();
    final remoteFetchList = tasks
      ..removeWhere((e) => e.id! == taskId)
      ..unique((e) => e.id);
    _updateState(list: remoteFetchList, updatedTimestamp: updatedTimestamp, isLocalUpdate: true);
  }

  Future<void> toggleTaskStatusOnBackground({required String taskId, required String recurringTaskId, required int startAtMs, required int endAtMs}) async {
    if (recurringTaskId.isEmpty) {
      final task = tasks.firstWhereOrNull((t) => t.id == taskId);
      if (task == null) return;

      final eventResult = await _taskRepository.saveTask(task: task.copyWith(status: TaskStatus.done));
      eventResult.fold((l) {}, (r) async {
        final list = tasks
          ..removeWhere((e) => e.id == r.id)
          ..add(r)
          ..unique((e) => e.id);

        DateTime updatedTimestamp = DateTime.now();
        this.updatedTimestamp = updatedTimestamp;

        _updateState(list: list, updatedTimestamp: updatedTimestamp, isLocalUpdate: false);
      });
    } else {
      final task = tasks.firstWhereOrNull(
        (t) =>
            t.recurringTaskId == recurringTaskId &&
            t.editedStartTime == DateTime.fromMillisecondsSinceEpoch(startAtMs) &&
            t.editedEndTime == DateTime.fromMillisecondsSinceEpoch(endAtMs),
      );
      if (task == null) return;

      List<TaskEntity> list;
      TaskEntity savingTask = task.copyWith(
        id: task.id,
        recurringTaskId: task.recurringTaskId,
        removeRrule: true,
        status: TaskStatus.done,
        startAt: task.editedStartTime ?? DateTime.now(),
        endAt: task.editedEndTime ?? DateTime.now(),
        createdAt: DateTime.now(),
      );

      list = tasks.map((e) {
        if (e.eventId == task.eventId) {
          return savingTask;
        } else {
          return e;
        }
      }).toList();
      if (list.firstWhereOrNull((e) => e.eventId == savingTask.eventId) == null) {
        list.add(savingTask);
      }

      final recurringTask = task.recurringTaskId == null ? task : tasks.firstWhereOrNull((e) => e.id == task.recurringTaskId);
      if (task.startAt != null && recurringTask != null) {
        final bool isEditedRecurringTask = recurringTask.editedRecurrenceTaskIds?.contains(task.id) ?? false;
        if (!isEditedRecurringTask) {
          final excludedRecurrenceDate = recurringTask.excludedRecurrenceDate ?? [];
          final editedRecurrenceTaskIds = recurringTask.editedRecurrenceTaskIds ?? [];
          await _taskRepository.saveTask(
            task: recurringTask.copyWith(
              excludedRecurrenceDate: [...excludedRecurrenceDate, savingTask.startDate.toUtc()].unique(),
              editedRecurrenceTaskIds: [...editedRecurrenceTaskIds, savingTask.id!].unique(),
            ),
          );
        }
      }

      final eventResult = await _taskRepository.saveTask(task: savingTask);
      eventResult.fold((l) {}, (r) async {
        final list = tasks
          ..removeWhere((e) => e.id == r.id)
          ..add(r)
          ..unique((e) => e.id);

        DateTime updatedTimestamp = DateTime.now();
        this.updatedTimestamp = updatedTimestamp;

        _updateState(list: list, updatedTimestamp: updatedTimestamp, isLocalUpdate: false);
      });
    }
  }
}

class CalendarTaskResultEntity {
  final List<TaskEntity> tasks;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final List<TaskEntity>? previousTasksOnView;
  final DateTime? previousFetchedUntil;
  final List<TaskEntity>? previousTasks;
  final Map<String, List<DateTime>>? previousCachedRecurrenceInstances;
  late final Map<String, List<DateTime>> cachedRecurrenceInstances;
  late List<TaskEntity> tasksOnView;

  DateTime get fetchedUntil => endDateTime;
  DateTime get fetchedFrom => startDateTime;

  /// Check if rrule-related fields are equal (excluding status, updatedAt, etc.)
  bool _isRruleEqual(TaskEntity a, TaskEntity b) {
    return a.id == b.id &&
        a.rrule == b.rrule &&
        a.startAt == b.startAt &&
        a.endAt == b.endAt &&
        a.recurrenceEndAt == b.recurrenceEndAt &&
        a.excludedRecurrenceDate == b.excludedRecurrenceDate &&
        a.editedRecurrenceTaskIds == b.editedRecurrenceTaskIds;
  }

  void updateTasksOnView() {
    cachedRecurrenceInstances = {};

    // Optimization: Single pass to filter and map non-recurring tasks
    // Avoids creating intermediate lists (where().toList().map().toList())
    final nonRecurringTasks = <TaskEntity>[];
    for (final e in tasks) {
      if (e.rrule == null) {
        nonRecurringTasks.add(e.copyWith(editedStartTime: e.startAt, editedEndTime: e.endAt));
      }
    }

    // Optimization: Convert to Map for O(1) lookup instead of O(n) firstWhereOrNull
    final nonRecurringTasksByDateAndRecurringId = <String, TaskEntity>{};
    for (final task in nonRecurringTasks) {
      if (task.recurringTaskId != null) {
        final key = '${task.recurringTaskId}_${DateUtils.dateOnly(task.startDate).millisecondsSinceEpoch}';
        nonRecurringTasksByDateAndRecurringId[key] = task;
      }
    }

    // Optimization: Single pass to filter original recurring tasks
    // Avoids creating intermediate list with where().toList()
    final originalRecurringTasks = <TaskEntity>[];
    for (final e in tasks) {
      if (e.isOriginalRecurrenceTask) {
        originalRecurringTasks.add(e);
      }
    }

    final _tasks = <TaskEntity>[];

    originalRecurringTasks.forEach((t) {
      if (t.startAt == null) return;
      if (t.startAt!.isAfter(fetchedUntil)) return;

      List<DateTime>? dates;

      final taskDuration = t.startAt != null && t.endAt != null ? t.endAt!.difference(t.startAt!) : Duration(days: 1);

      final exceptionTasks = nonRecurringTasks.where((i) => i.recurringTaskId == t.id);

      final excludedRecurrenceDates = [...exceptionTasks.map((e) => e.startAt?.dateOnly).whereType<DateTime>().toList(), ...(t.excludedRecurrenceDate ?? [])].unique();

      // Optimization: Reuse previous instances if rrule-related fields haven't changed
      // This allows cache reuse even when status or updatedAt changes
      if (previousTasks != null && previousCachedRecurrenceInstances != null && previousFetchedUntil == fetchedUntil) {
        final previousTask = previousTasks!.firstWhereOrNull((e) => e.id == t.id);
        if (previousTask != null && _isRruleEqual(previousTask, t)) {
          // Check if excludedRecurrenceDates have changed by comparing with previousTasksOnView
          final previousExceptionTasks = previousTasksOnView?.where((i) => i.recurringTaskId == t.id).toList() ?? [];
          final previousExcludedRecurrenceDates = [
            ...previousExceptionTasks.map((e) => e.startAt?.dateOnly).whereType<DateTime>().toList(),
            ...(previousTask.excludedRecurrenceDate ?? []),
          ].unique();

          // Only reuse cache if excludedRecurrenceDates haven't changed
          if (previousExcludedRecurrenceDates.length == excludedRecurrenceDates.length &&
              previousExcludedRecurrenceDates.every((d) => excludedRecurrenceDates.any((ed) => ed == d))) {
            dates = previousCachedRecurrenceInstances![t.id];
          }
        }
      }

      DateTime startAt = t.startAt!;
      if (t.startAt!.isBefore(fetchedFrom)) {
        startAt = fetchedFrom;
      }

      if (dates == null) {
        dates = t.rrule?.getInstances(start: t.startAt!, after: startAt, before: fetchedUntil, includeAfter: true).toList();
      }

      if (dates != null) {
        cachedRecurrenceInstances[t.id!] = dates;
      }

      dates?.where((date) => !excludedRecurrenceDates.any((d) => d == date.dateOnly)).forEach((date) {
        final dateOnly = DateUtils.dateOnly(date);
        final lookupKey = '${t.id}_${dateOnly.millisecondsSinceEpoch}';
        TaskEntity? recurringTaskOnDate = nonRecurringTasksByDateAndRecurringId[lookupKey];

        if (recurringTaskOnDate == null) {
          _tasks.add(t.copyWith(editedStartTime: date, editedEndTime: date.add(taskDuration)));
        } else {
          // Remove from map and list
          nonRecurringTasksByDateAndRecurringId.remove(lookupKey);
          nonRecurringTasks.remove(recurringTaskOnDate);

          if (recurringTaskOnDate.isDone) {
            _tasks.add(recurringTaskOnDate.copyWith(editedStartTime: date, editedEndTime: date.add(taskDuration)));
          } else if (recurringTaskOnDate.isCancelled) {
            // Cancelled tasks are excluded from tasksOnView
          } else {
            _tasks.add(
              recurringTaskOnDate.copyWith(
                id: recurringTaskOnDate.id,
                recurringTaskId: recurringTaskOnDate.recurringTaskId,
                editedStartTime: date,
                editedEndTime: date.add(taskDuration),
              ),
            );
          }
        }
      });
    });

    // Optimization: Use List.from and addAll instead of spread operator
    // Filter out cancelled tasks in a single pass
    tasksOnView = <TaskEntity>[];
    for (final task in nonRecurringTasks) {
      if (!task.isCancelled) {
        tasksOnView.add(task);
      }
    }
    for (final task in _tasks) {
      if (!task.isCancelled) {
        tasksOnView.add(task);
      }
    }
  }

  CalendarTaskResultEntity({
    required this.tasks,
    required this.startDateTime,
    required this.endDateTime,
    this.previousTasksOnView,
    this.previousFetchedUntil,
    this.previousTasks,
    this.previousCachedRecurrenceInstances,
  }) {
    updateTasksOnView();
  }
}
