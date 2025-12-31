import 'dart:async';
import 'dart:convert';

import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/rrule/src/by_week_day_entry.dart';
import 'package:Visir/dependency/rrule/src/codecs/string/encoder.dart';
import 'package:Visir/dependency/rrule/src/recurrence_rule.dart';
import 'package:Visir/dependency/rrule/src/utils.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/auth/domain/entities/user_entity.dart';
import 'package:Visir/features/common/presentation/utils/extensions/list_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/recurrence_edit_confirm_popup.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/domain/entities/local_pref_entity.dart';
import 'package:Visir/features/task/domain/entities/task_entity.dart';
import 'package:Visir/features/task/domain/entities/task_label_entity.dart';
import 'package:Visir/features/task/infrastructure/repositories/task_repository.dart';
import 'package:Visir/features/task/providers.dart';
import 'package:Visir/features/task/application/calendar_task_list_controller.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/experimental/persist.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'task_list_controller.g.dart';

@riverpod
class TaskListController extends _$TaskListController {
  static String stringKey = '${TabType.task.name}:tasks';

  TaskListControllerInternal? _controller;
  TaskListDateControllerInternal? _dateController;

  List<TaskLabelEntity> get taskLabelList => [
    TaskLabelEntity(type: TaskLabelType.all),
    TaskLabelEntity(type: TaskLabelType.scheduled),
    TaskLabelEntity(type: TaskLabelType.overdue),
    TaskLabelEntity(type: TaskLabelType.unscheduled),
    TaskLabelEntity(type: TaskLabelType.completed),
  ];

  @override
  TaskListResultEntity build() {
    final isSignedIn = ref.watch(authControllerProvider.select((v) => v.requireValue.isSignedIn));
    final taskLabel = ref.watch(taskLabelProvider);
    final labelId = taskLabel.id;

    // labelId에서 TaskLabelType 파싱
    TaskLabelType taskLabelType = TaskLabelType.all;
    if (labelId.startsWith('all')) {
      taskLabelType = TaskLabelType.all;
    } else if (labelId.startsWith('completed')) {
      taskLabelType = TaskLabelType.completed;
    } else if (labelId.startsWith('scheduled')) {
      taskLabelType = TaskLabelType.scheduled;
    } else if (labelId.startsWith('overdue')) {
      taskLabelType = TaskLabelType.overdue;
    } else if (labelId.startsWith('unscheduled')) {
      taskLabelType = TaskLabelType.unscheduled;
    } else if (labelId.startsWith('today') || labelId.startsWith('upcoming')) {
      // 기존 today/upcoming을 scheduled로 마이그레이션
      taskLabelType = TaskLabelType.scheduled;
    }

    // Initialize state with empty result
    state = TaskListResultEntity(tasks: [], taskDates: []);

    _updateFromInternalControllers(isSignedIn: isSignedIn, labelId: labelId);

    // labelId에 따라 다른 provider들을 listen
    if (taskLabelType == TaskLabelType.all ||
        taskLabelType == TaskLabelType.completed ||
        taskLabelType == TaskLabelType.overdue ||
        taskLabelType == TaskLabelType.unscheduled ||
        taskLabelType == TaskLabelType.scheduled) {
      // all, completed, overdue, unscheduled, scheduled: TaskListControllerInternal listen
      _controller = ref.watch(taskListControllerInternalProvider(isSignedIn: isSignedIn, labelId: labelId).notifier);
      ref.listen(taskListControllerInternalProvider(isSignedIn: isSignedIn, labelId: labelId), (prev, next) {
        _updateFromInternalControllers(isSignedIn: isSignedIn, labelId: labelId);
      });
    }

    if (taskLabelType == TaskLabelType.all || taskLabelType == TaskLabelType.scheduled) {
      // all, scheduled: TaskListDateControllerInternal 사용
      _dateController = ref.watch(taskListDateControllerInternalProvider(isSignedIn: isSignedIn).notifier);
      ref.listen(taskListDateControllerInternalProvider(isSignedIn: isSignedIn), (prev, next) {
        _updateFromInternalControllers(isSignedIn: isSignedIn, labelId: labelId);
      });
    }

    SchedulerBinding.instance.addPostFrameCallback((_) {
      refresh();
    });

    return state;
  }

  void _updateFromInternalControllers({required bool isSignedIn, required String labelId}) {
    TaskListResultEntity? taskListResult;
    List<TaskEntity> calendarTasks = [];

    if (_controller != null) {
      final controllerState = ref.read(taskListControllerInternalProvider(isSignedIn: isSignedIn, labelId: labelId));
      taskListResult = controllerState.value;
    }

    if (_dateController != null) {
      final dateControllerState = ref.read(taskListDateControllerInternalProvider(isSignedIn: isSignedIn));
      calendarTasks.addAll(dateControllerState);
    }

    // 데이터 합치기
    final taskListResultFinal = taskListResult ?? TaskListResultEntity(tasks: [], taskDates: []);
    // Optimization: Use List.from and addAll instead of spread operator to reduce allocations
    final allTasks = List<TaskEntity>.from(taskListResultFinal.tasks);
    allTasks.addAll(calendarTasks);
    allTasks.unique((e) => e.id);

    // loadedMonths에 속한 모든 날짜를 taskDates에 추가 (오늘 이후 날짜만)
    // Optimization: Reuse existing list when possible
    final mergedTaskDates = List<DateTime?>.from(taskListResultFinal.taskDates);
    final today = DateUtils.dateOnly(DateTime.now());

    // overdue 태스크가 있으면 DateTime(1000) 추가
    final overdueTasks = allTasks.where((t) => t.isOverdue && t.status == TaskStatus.none && !t.isUnscheduled).toList();
    if (overdueTasks.isNotEmpty && !mergedTaskDates.contains(DateTime(1000))) {
      mergedTaskDates.add(DateTime(1000));
    }

    // unscheduled 태스크가 있으면 null 추가
    final hasUnscheduledTasks = allTasks.any((t) => t.isUnscheduled);
    if (hasUnscheduledTasks && !mergedTaskDates.contains(null)) {
      mergedTaskDates.add(null);
    }

    if (_dateController != null) {
      final loadedMonths = ref.read(taskListCurrentLoadedMonthsProvider);
      final dateSet = <DateTime>{};

      // 기존 taskDates의 날짜들을 set에 추가 (오늘 이후만)
      for (final date in mergedTaskDates) {
        if (date != null && date != DateTime(1000)) {
          final dateOnly = DateUtils.dateOnly(date);
          if (!dateOnly.isBefore(today)) {
            dateSet.add(dateOnly);
          }
        }
      }

      // loadedMonths의 각 달에 속한 모든 날짜 추가 (오늘 이후만)
      for (final month in loadedMonths) {
        final firstDay = DateTime(month.year, month.month, 1);
        final lastDay = DateTime(month.year, month.month + 1, 0); // 다음 달의 0일 = 이번 달의 마지막 날
        // 오늘 이후부터 시작
        final startDate = firstDay.isBefore(today) ? today : firstDay;

        for (var date = startDate; !date.isAfter(lastDay); date = date.add(Duration(days: 1))) {
          final dateOnly = DateUtils.dateOnly(date);
          if (!dateSet.contains(dateOnly) && !dateOnly.isBefore(today)) {
            dateSet.add(dateOnly);
            mergedTaskDates.add(dateOnly);
          }
        }
      }

      // 날짜 정렬: null (unscheduled) -> DateTime(1000) (overdue) -> 날짜 순서
      mergedTaskDates.sort((a, b) {
        if (a == null) return -1; // null이 가장 앞
        if (b == null) return 1;
        if (a == DateTime(1000)) return -1; // DateTime(1000)이 두 번째
        if (b == DateTime(1000)) return 1;
        return a.compareTo(b);
      });
    }

    final mergedState = TaskListResultEntity(
      tasks: allTasks,
      taskDates: mergedTaskDates,
      previousTasksOnView: taskListResultFinal.previousTasksOnView,
      previousTaskFetchedUntil: taskListResultFinal.previousTaskFetchedUntil,
      previousTasks: taskListResultFinal.previousTasks,
      previousCachedRecurrenceInstances: taskListResultFinal.previousCachedRecurrenceInstances,
    );

    updateState(mergedState);
  }

  Timer? timer;
  void updateState(TaskListResultEntity tasks) {
    if (timer == null) state = tasks;
    timer?.cancel();
    timer = Timer(const Duration(milliseconds: kControllerDebouncMillisecond), () {
      state = tasks;
      timer = null;
    });
  }

  Future<void> refresh({LocalPrefEntity? pref, UserEntity? user}) async {
    Completer<void> completer = Completer<void>();
    ref.read(loadingStatusProvider.notifier).update(TaskListController.stringKey, LoadingState.loading);

    int resultCount = 0;
    int totalCount = 0;

    if (_controller != null) {
      totalCount++;
      _controller!
          .refresh(pref: pref, user: user)
          .then((e) {
            resultCount++;
            if (resultCount == totalCount) {
              ref.read(loadingStatusProvider.notifier).update(TaskListController.stringKey, LoadingState.success);
              completer.complete();
            }
          })
          .catchError((e) {
            resultCount++;
            if (resultCount == totalCount) {
              ref.read(loadingStatusProvider.notifier).update(TaskListController.stringKey, LoadingState.error);
              completer.complete();
            }
          });
    }

    if (_dateController != null) {
      totalCount++;
      _dateController!
          .refresh()
          .then((e) {
            resultCount++;
            if (resultCount == totalCount) {
              ref.read(loadingStatusProvider.notifier).update(TaskListController.stringKey, LoadingState.success);
              completer.complete();
            }
          })
          .catchError((e) {
            resultCount++;
            if (resultCount == totalCount) {
              ref.read(loadingStatusProvider.notifier).update(TaskListController.stringKey, LoadingState.error);
              completer.complete();
            }
          });
    }

    if (totalCount == 0) {
      ref.read(loadingStatusProvider.notifier).update(TaskListController.stringKey, LoadingState.success);
      completer.complete();
    }

    return completer.future;
  }

  Future<bool> getMoreTasks() async {
    final taskLabel = ref.read(taskLabelProvider);
    final labelId = taskLabel.id;

    // labelId에서 TaskLabelType 파싱
    TaskLabelType taskLabelType = TaskLabelType.all;
    if (labelId.startsWith('all')) {
      taskLabelType = TaskLabelType.all;
    } else if (labelId.startsWith('completed')) {
      taskLabelType = TaskLabelType.completed;
    } else if (labelId.startsWith('scheduled')) {
      taskLabelType = TaskLabelType.scheduled;
    } else if (labelId.startsWith('overdue')) {
      taskLabelType = TaskLabelType.overdue;
    } else if (labelId.startsWith('unscheduled')) {
      taskLabelType = TaskLabelType.unscheduled;
    } else if (labelId.startsWith('today') || labelId.startsWith('upcoming')) {
      // 기존 today/upcoming을 scheduled로 마이그레이션
      taskLabelType = TaskLabelType.scheduled;
    }

    Completer<bool> completer = Completer<bool>();
    ref.read(loadingStatusProvider.notifier).update(TaskListController.stringKey, LoadingState.loading);

    int resultCount = 0;
    int totalCount = 0;
    bool hasMoreData = false;

    // all 탭이 아닐 때만 TaskListControllerInternal의 getMoreTasks 호출
    if (taskLabelType != TaskLabelType.all && _controller != null) {
      totalCount++;
      final controllerHasMoreData = await _controller!.getMoreTasks();
      hasMoreData = hasMoreData || controllerHasMoreData;
      resultCount++;
      if (resultCount == totalCount) {
        ref.read(loadingStatusProvider.notifier).update(TaskListController.stringKey, LoadingState.success);
        completer.complete(hasMoreData);
      }
    }

    // all일 때는 _dateController에서만 컨트롤러를 추가 (build에서 자동으로 로드됨)
    if (taskLabelType == TaskLabelType.all && _dateController != null) {
      final loadedMonths = ref.read(taskListCurrentLoadedMonthsProvider);
      if (loadedMonths.isNotEmpty) {
        // 이미 로드된 달 중 가장 마지막 달 찾기
        final sortedMonths = loadedMonths.toList()
          ..sort((a, b) {
            final yearCompare = a.year.compareTo(b.year);
            if (yearCompare != 0) return yearCompare;
            return a.month.compareTo(b.month);
          });
        final lastLoadedMonth = sortedMonths.last;
        // 다음 달 계산
        final nextMonth = DateTime(lastLoadedMonth.year, lastLoadedMonth.month + 1);

        // 이미 로드된 달인지 확인
        final alreadyLoaded = loadedMonths.any((m) => m.year == nextMonth.year && m.month == nextMonth.month);
        if (!alreadyLoaded) {
          // 달만 추가하면 build에서 자동으로 로드됨
          ref.read(taskListCurrentLoadedMonthsProvider.notifier).addMonth(nextMonth);
          hasMoreData = true; // 날짜 컨트롤러는 항상 더 많은 데이터가 있을 수 있음
        } else {
          // 이미 모든 달이 로드되었으면 더 이상 데이터 없음
        }
      }

      // all 탭의 경우 completer 완료 처리
      ref.read(loadingStatusProvider.notifier).update(TaskListController.stringKey, LoadingState.success);
      if (!completer.isCompleted) {
        completer.complete(hasMoreData);
      }
    }

    if (totalCount == 0) {
      ref.read(loadingStatusProvider.notifier).update(TaskListController.stringKey, LoadingState.success);
      completer.complete(false);
    }

    return completer.future;
  }

  Future<void> load({required DateTime startAtBefore, required DateTime? startAtAfter, required bool isRefresh, LocalPrefEntity? pref, UserEntity? user}) async {
    final taskLabel = ref.read(taskLabelProvider);
    final labelId = taskLabel.id;

    // labelId에서 TaskLabelType 파싱
    TaskLabelType taskLabelType = TaskLabelType.all;
    if (labelId.startsWith('all')) {
      taskLabelType = TaskLabelType.all;
    } else if (labelId.startsWith('completed')) {
      taskLabelType = TaskLabelType.completed;
    } else if (labelId.startsWith('scheduled')) {
      taskLabelType = TaskLabelType.scheduled;
    } else if (labelId.startsWith('overdue')) {
      taskLabelType = TaskLabelType.overdue;
    } else if (labelId.startsWith('unscheduled')) {
      taskLabelType = TaskLabelType.unscheduled;
    } else if (labelId.startsWith('today') || labelId.startsWith('upcoming')) {
      // 기존 today/upcoming을 scheduled로 마이그레이션
      taskLabelType = TaskLabelType.scheduled;
    }

    Completer<void> completer = Completer<void>();
    ref.read(loadingStatusProvider.notifier).update(TaskListController.stringKey, LoadingState.loading);

    int resultCount = 0;
    int totalCount = 0;

    if (_controller != null) {
      totalCount++;
      _controller!
          .load(startAtBefore: startAtBefore, startAtAfter: startAtAfter, isRefresh: isRefresh, pref: pref, user: user)
          .then((e) {
            resultCount++;
            if (resultCount == totalCount) {
              ref.read(loadingStatusProvider.notifier).update(TaskListController.stringKey, LoadingState.success);
              completer.complete();
            }
          })
          .catchError((e) {
            resultCount++;
            if (resultCount == totalCount) {
              ref.read(loadingStatusProvider.notifier).update(TaskListController.stringKey, LoadingState.error);
              completer.complete(e);
            }
          });
    }

    // all, scheduled일 때 dateController도 load
    if ((taskLabelType == TaskLabelType.all || taskLabelType == TaskLabelType.scheduled) && _dateController != null) {
      totalCount++;
      _dateController!
          .loadAll(isRefresh: isRefresh)
          .then((e) {
            resultCount++;
            if (resultCount == totalCount) {
              ref.read(loadingStatusProvider.notifier).update(TaskListController.stringKey, LoadingState.success);
              completer.complete();
            }
          })
          .catchError((e) {
            resultCount++;
            if (resultCount == totalCount) {
              ref.read(loadingStatusProvider.notifier).update(TaskListController.stringKey, LoadingState.error);
              completer.complete(e);
            }
          });
    }

    if (totalCount == 0) {
      ref.read(loadingStatusProvider.notifier).update(TaskListController.stringKey, LoadingState.success);
      completer.complete();
    }

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
    Completer<void> completer = Completer<void>();
    int resultCount = 0;
    int totalCount = 0;

    String recurrence =
        originalTask?.rrule?.toString(options: RecurrenceRuleToStringOptions(isTimeUtc: true)) ??
        state.tasks.firstWhereOrNull((e) => e.id == originalTask?.recurringTaskId)?.rrule?.toString(options: RecurrenceRuleToStringOptions(isTimeUtc: true)) ??
        '';

    RecurringTaskEditType? editType;
    if (recurrence.isNotEmpty) {
      if (updateTaskStatus == true || (originalTask?.recurringTaskId != null && originalTask?.rrule == null) || TabType.task != targetTab) {
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

    if (_controller != null) {
      totalCount++;
      _controller!
          .saveTask(
            originalTask: originalTask,
            newTask: newTask,
            selectedEndDate: selectedEndDate,
            selectedStartDate: selectedStartDate,
            updateTaskStatus: updateTaskStatus,
            targetTab: targetTab,
          )
          .then((e) {
            resultCount++;
            if (resultCount == totalCount) {
              completer.complete();
            }
          })
          .catchError((error) {
            resultCount++;
            if (resultCount == totalCount) {
              completer.complete();
            }
          });
    }

    if (_dateController != null) {
      totalCount++;
      _dateController!
          .saveTask(
            recurringTaskEditType: editType,
            originalTask: originalTask,
            newTask: newTask,
            selectedEndDate: selectedEndDate,
            selectedStartDate: selectedStartDate,
            updateTaskStatus: updateTaskStatus,
            targetTab: targetTab,
            tabType: TabType.task,
          )
          .then((e) {
            resultCount++;
            if (resultCount == totalCount) {
              completer.complete();
            }
          })
          .catchError((error) {
            resultCount++;
            if (resultCount == totalCount) {
              completer.complete();
            }
          });
    }

    if (totalCount == 0) {
      completer.complete();
    }

    return completer.future;
  }

  void onUpdateTask(TaskEntity task) {
    _controller?.onUpdateTask(task);
    _dateController?.onUpdateTask(task);
  }

  void onDeleteTask(String taskId) {
    _controller?.onDeleteTask(taskId);
    _dateController?.onDeleteTask(taskId);
  }

  Future<void> toggleTaskStatusOnBackground({required String taskId, required String recurringTaskId, required int startAtMs, required int endAtMs}) async {
    _controller?.toggleTaskStatusOnBackground(taskId: taskId, recurringTaskId: recurringTaskId, startAtMs: startAtMs, endAtMs: endAtMs);
    _dateController?.toggleTaskStatusOnBackground(taskId: taskId, recurringTaskId: recurringTaskId, startAtMs: startAtMs, endAtMs: endAtMs);
  }
}

@riverpod
class TaskListDateControllerInternal extends _$TaskListDateControllerInternal {
  Set<DateTime> _previousLoadedMonths = {};

  @override
  List<TaskEntity> build({required bool isSignedIn}) {
    final loadedMonths = ref.watch(taskListCurrentLoadedMonthsProvider);
    final allTasks = <TaskEntity>[];

    // 새로운 달이 추가되었는지 확인
    final newMonths = loadedMonths.where((month) {
      final normalizedMonth = DateTime(month.year, month.month);
      return !_previousLoadedMonths.any((prev) => prev.year == normalizedMonth.year && prev.month == normalizedMonth.month);
    }).toList();

    // 각 달의 태스크를 읽어서 합치기
    loadedMonths.forEach((month) {
      try {
        final controllerState = ref.read(calendarTaskListControllerInternalProvider(isSignedIn: isSignedIn, targetYear: month.year, targetMonth: month.month));
        allTasks.addAll(controllerState.value ?? []);
      } catch (e) {
        // If reading fails, skip
      }
    });

    // 각 달에 대해 listen 설정
    loadedMonths.forEach((month) {
      ref.listen(calendarTaskListControllerInternalProvider(isSignedIn: isSignedIn, targetYear: month.year, targetMonth: month.month), (prev, next) {
        _updateFromMonths(isSignedIn);
      });
    });

    // 새로운 달이 있으면 자동으로 로드
    if (newMonths.isNotEmpty) {
      _previousLoadedMonths = loadedMonths.map((m) => DateTime(m.year, m.month)).toSet();
      SchedulerBinding.instance.addPostFrameCallback((_) {
        for (final month in newMonths) {
          final controller = ref.read(calendarTaskListControllerInternalProvider(isSignedIn: isSignedIn, targetYear: month.year, targetMonth: month.month).notifier);
          controller.load(isRefresh: false);
        }
      });
    } else {
      _previousLoadedMonths = loadedMonths.map((m) => DateTime(m.year, m.month)).toSet();
    }

    return allTasks;
  }

  void _updateFromMonths(bool isSignedIn) {
    final loadedMonths = ref.read(taskListCurrentLoadedMonthsProvider);
    final allTasks = <TaskEntity>[];

    loadedMonths.forEach((month) {
      try {
        final controllerState = ref.read(calendarTaskListControllerInternalProvider(isSignedIn: isSignedIn, targetYear: month.year, targetMonth: month.month));
        allTasks.addAll(controllerState.value ?? []);
      } catch (e) {
        // If reading fails, skip
      }
    });

    state = allTasks;
  }

  Future<void> refresh() async {
    final isSignedIn = ref.read(authControllerProvider).requireValue.isSignedIn;
    final loadedMonths = ref.read(taskListCurrentLoadedMonthsProvider);
    final completer = Completer<void>();
    int resultCount = 0;
    int totalCount = loadedMonths.length;

    if (totalCount == 0) {
      completer.complete();
      return completer.future;
    }

    loadedMonths.forEach((month) {
      final controller = ref.read(calendarTaskListControllerInternalProvider(isSignedIn: isSignedIn, targetYear: month.year, targetMonth: month.month).notifier);
      controller
          .refresh()
          .then((e) {
            resultCount++;
            if (resultCount == totalCount) {
              completer.complete();
            }
          })
          .catchError((e) {
            resultCount++;
            if (resultCount == totalCount) {
              completer.complete();
            }
          });
    });

    return completer.future;
  }

  Future<void> loadAll({required bool isRefresh}) async {
    final isSignedIn = ref.read(authControllerProvider).requireValue.isSignedIn;
    final loadedMonths = ref.read(taskListCurrentLoadedMonthsProvider);
    final completer = Completer<void>();
    int resultCount = 0;
    int totalCount = loadedMonths.length;

    if (totalCount == 0) {
      completer.complete();
      return completer.future;
    }

    loadedMonths.forEach((month) {
      final controller = ref.read(calendarTaskListControllerInternalProvider(isSignedIn: isSignedIn, targetYear: month.year, targetMonth: month.month).notifier);
      controller
          .load(isRefresh: isRefresh)
          .then((e) {
            resultCount++;
            if (resultCount == totalCount) {
              completer.complete();
            }
          })
          .catchError((e) {
            resultCount++;
            if (resultCount == totalCount) {
              completer.complete();
            }
          });
    });

    return completer.future;
  }

  Future<void> loadMonth({required int year, required int month, required bool isRefresh}) async {
    final isSignedIn = ref.read(authControllerProvider).requireValue.isSignedIn;
    final controller = ref.read(calendarTaskListControllerInternalProvider(isSignedIn: isSignedIn, targetYear: year, targetMonth: month).notifier);
    return controller.load(isRefresh: isRefresh);
  }

  Future<void> saveTask({
    TaskEntity? originalTask,
    TaskEntity? newTask,
    required DateTime? selectedEndDate,
    required DateTime? selectedStartDate,
    bool? updateTaskStatus,
    required TabType targetTab,
    required TabType tabType,
    required RecurringTaskEditType? recurringTaskEditType,
  }) async {
    final isSignedIn = ref.read(authControllerProvider).requireValue.isSignedIn;
    final loadedMonths = ref.read(taskListCurrentLoadedMonthsProvider);
    final completer = Completer<void>();
    int resultCount = 0;
    int totalCount = loadedMonths.length;

    if (totalCount == 0) {
      completer.complete();
      return completer.future;
    }

    loadedMonths.forEach((month) {
      final controller = ref.read(calendarTaskListControllerInternalProvider(isSignedIn: isSignedIn, targetYear: month.year, targetMonth: month.month).notifier);
      controller
          .saveTask(
            recurringTaskEditType: recurringTaskEditType,
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
            if (resultCount == totalCount) {
              completer.complete();
            }
          })
          .catchError((error) {
            resultCount++;
            if (resultCount == totalCount) {
              completer.complete();
            }
          });
    });

    return completer.future;
  }

  void onUpdateTask(TaskEntity task) {
    final isSignedIn = ref.read(authControllerProvider).requireValue.isSignedIn;
    final loadedMonths = ref.read(taskListCurrentLoadedMonthsProvider);
    loadedMonths.forEach((month) {
      final controller = ref.read(calendarTaskListControllerInternalProvider(isSignedIn: isSignedIn, targetYear: month.year, targetMonth: month.month).notifier);
      controller.onUpdateTask(task);
    });
  }

  void onDeleteTask(String taskId) {
    final isSignedIn = ref.read(authControllerProvider).requireValue.isSignedIn;
    final loadedMonths = ref.read(taskListCurrentLoadedMonthsProvider);
    loadedMonths.forEach((month) {
      final controller = ref.read(calendarTaskListControllerInternalProvider(isSignedIn: isSignedIn, targetYear: month.year, targetMonth: month.month).notifier);
      controller.onDeleteTask(taskId);
    });
  }

  Future<void> toggleTaskStatusOnBackground({required String taskId, required String recurringTaskId, required int startAtMs, required int endAtMs}) async {
    final isSignedIn = ref.read(authControllerProvider).requireValue.isSignedIn;
    final loadedMonths = ref.read(taskListCurrentLoadedMonthsProvider);
    loadedMonths.forEach((month) {
      final controller = ref.read(calendarTaskListControllerInternalProvider(isSignedIn: isSignedIn, targetYear: month.year, targetMonth: month.month).notifier);
      controller.toggleTaskStatusOnBackground(taskId: taskId, recurringTaskId: recurringTaskId, startAtMs: startAtMs, endAtMs: endAtMs);
    });
  }
}

@riverpod
class TaskListControllerInternal extends _$TaskListControllerInternal {
  late TaskRepository _taskRepository;

  TabType get tabType => TabType.task;

  DateTime updatedTimestamp = DateTime.now();

  List<TaskEntity> get tasks => [...state.value?.tasks ?? []];
  List<TaskEntity> _remoteFetchedTasks = [];

  String isLoadedId = '';

  final Duration taskLoadingDuration = Duration(days: 30); // Optimized: reduced from 60 to 30 days for better memory usage

  DateTime? get taskFetchedUntil => ref.read(taskDatesProvider).where((e) => e != null && e != DateTime(1000)).lastOrNull;
  DateTime? get taskFetchedFrom => ref.read(taskDatesProvider).where((e) => e != null && e != DateTime(1000)).firstOrNull;

  List<DateTime?> taskDates = [];

  @override
  Future<TaskListResultEntity> build({required bool isSignedIn, required String labelId}) async {
    _taskRepository = ref.watch(taskRepositoryProvider);

    ref.listen(taskDatesProvider, (prev, next) {
      taskDates = next;
    });

    if (ref.watch(shouldUseMockDataProvider)) {
      _loadMockTasks(startAtBefore: DateUtils.dateOnly(DateTime.now()));
      return TaskListResultEntity(tasks: [], taskDates: taskDates);
    }

    await persist(
      ref.watch(storageProvider.future),
      key: '${TaskListController.stringKey}:${isSignedIn}:${labelId}',
      encode: (TaskListResultEntity? state) => state == null ? '' : jsonEncode(state.toJson()),
      decode: (String encoded) {
        if (ref.watch(shouldUseMockDataProvider)) return TaskListResultEntity(tasks: [], taskDates: taskDates);
        final trimmed = encoded.trim();
        if (trimmed.isEmpty || trimmed == 'null') {
          return TaskListResultEntity(tasks: [], taskDates: taskDates);
        }
        return TaskListResultEntity.fromJson(jsonDecode(trimmed) as Map<String, dynamic>);
      },
      options: Utils.storageOptions,
    ).future;

    return state.value ?? TaskListResultEntity(tasks: [], taskDates: taskDates);
  }

  Future<void> _loadMockTasks({required DateTime startAtBefore}) async {
    final result = await rootBundle.loadString('assets/mock/tasks.json');
    final data = jsonDecode(result);
    final userId = ref.read(authControllerProvider.select((e) => e.requireValue.id));
    List<TaskEntity> tasks = data
        .map((e) {
          if (e['linked_event'] == null) {
            // project_id가 'userId'인 경우 실제 userId로 변환
            if (e['project_id'] == 'userId') {
              e['project_id'] = userId;
            }
            return TaskEntity.fromJson(e, local: true);
          }

          return null;
        })
        .whereType<TaskEntity>()
        .toList();
    _updateState(list: tasks, isLocalUpdate: true, updatedTimestamp: DateTime.now());

    DateTime startDateTime = DateUtils.dateOnly(DateTime.now());
    List<DateTime> dateList = [];
    for (DateTime date = startDateTime; !date.isAfter(startAtBefore); date = date.add(Duration(days: 1))) {
      dateList.add(DateUtils.dateOnly(date));
    }
    ref.read(taskDatesProvider.notifier).updateDates([null, DateTime(1000), ...dateList]);
    return;
  }

  Future<void> refresh({LocalPrefEntity? pref, UserEntity? user}) async {
    _remoteFetchedTasks = [];
    await load(startAtBefore: DateUtils.dateOnly(DateTime.now()).add(taskLoadingDuration), startAtAfter: null, isRefresh: true, pref: pref, user: user);
  }

  Future<bool> getMoreTasks() async {
    // labelId에서 TaskLabelType 파싱
    TaskLabelType taskLabelType = TaskLabelType.all;
    if (labelId.startsWith('all')) {
      taskLabelType = TaskLabelType.all;
    } else if (labelId.startsWith('completed')) {
      taskLabelType = TaskLabelType.completed;
    } else if (labelId.startsWith('scheduled')) {
      taskLabelType = TaskLabelType.scheduled;
    } else if (labelId.startsWith('overdue')) {
      taskLabelType = TaskLabelType.overdue;
    } else if (labelId.startsWith('unscheduled')) {
      taskLabelType = TaskLabelType.unscheduled;
    } else if (labelId.startsWith('today') || labelId.startsWith('upcoming')) {
      // 기존 today/upcoming을 scheduled로 마이그레이션
      taskLabelType = TaskLabelType.scheduled;
    }

    // all 탭의 경우: overdue만 가져오므로 레이지로딩 불필요 (TaskListDateControllerInternal에서 처리)
    if (taskLabelType == TaskLabelType.all) {
      return false;
    }

    if (taskFetchedUntil == null) {
      // 더 이상 로드할 데이터가 없으면 false 반환
      return false;
    }
    final beforeLoadCount = _remoteFetchedTasks.length;
    await load(startAtBefore: taskFetchedUntil!.add(taskLoadingDuration), startAtAfter: taskFetchedUntil, isRefresh: false);
    final afterLoadCount = _remoteFetchedTasks.length;
    final hasMoreData = afterLoadCount > beforeLoadCount;
    // 새로운 데이터가 로드되었는지 확인
    return hasMoreData;
  }

  Future<void> load({required DateTime startAtBefore, required DateTime? startAtAfter, required bool isRefresh, LocalPrefEntity? pref, UserEntity? user}) async {
    if (ref.watch(shouldUseMockDataProvider)) {
      await _loadMockTasks(startAtBefore: startAtBefore);
      return;
    }

    final _pref = pref ?? ref.read(localPrefControllerProvider).value;
    final _user = user ?? ref.read(authControllerProvider).requireValue;
    if (ref.read(shouldUseMockDataProvider)) return;
    if (_pref == null) return;
    isLoadedId = Uuid().v4();

    final overdueAndCompletedTasks = <TaskEntity>[];
    final now = DateUtils.dateOnly(DateTime.now());

    // labelId에서 TaskLabelType 파싱
    TaskLabelType taskLabelType = TaskLabelType.all;
    if (labelId.startsWith('all')) {
      taskLabelType = TaskLabelType.all;
    } else if (labelId.startsWith('completed')) {
      taskLabelType = TaskLabelType.completed;
    } else if (labelId.startsWith('scheduled')) {
      taskLabelType = TaskLabelType.scheduled;
    } else if (labelId.startsWith('overdue')) {
      taskLabelType = TaskLabelType.overdue;
    } else if (labelId.startsWith('unscheduled')) {
      taskLabelType = TaskLabelType.unscheduled;
    } else if (labelId.startsWith('today') || labelId.startsWith('upcoming')) {
      // 기존 today/upcoming을 scheduled로 마이그레이션
      taskLabelType = TaskLabelType.scheduled;
    }

    // taskLabel에 따라 필요한 데이터만 가져오기
    switch (taskLabelType) {
      case TaskLabelType.all:
        // all: overdue와 unscheduled 필요 (completed는 calendarTaskListControllerInternal에서 가져옴)
        final overdueStartDate = now.subtract(Duration(days: 365)); // 1년 전부터
        final overdueEndDate = now.subtract(Duration(days: 1)); // 어제까지

        final overdueResult = await _taskRepository.fetchTasksBetweenDates(startDateTime: overdueStartDate, endDateTime: overdueEndDate, pref: _pref, userId: _user.id);
        overdueResult.fold((l) {}, (r) {
          // overdue: status가 none이고 isOverdue이고 linkedEvent == null이고 isCancelled가 아닌 태스크
          final overdueTasks = r.where((t) => t.status == TaskStatus.none && t.isOverdue && !t.isUnscheduled && t.linkedEvent == null && !t.isCancelled).toList();
          overdueAndCompletedTasks.addAll(overdueTasks);
        });

        // unscheduled tasks 가져오기
        final unscheduledResult = await _taskRepository.fetchUnscheduledTasks(pref: _pref, userId: _user.id);
        unscheduledResult.fold((l) {}, (r) {
          final unscheduledTasks = r.where((t) => (t.status == TaskStatus.none || t.status == TaskStatus.braindump) && t.linkedEvent == null && !t.isCancelled).toList();
          overdueAndCompletedTasks.addAll(unscheduledTasks);
        });
        break;
      case TaskLabelType.completed:
        // completed: status가 done인 태스크만 가져오기
        // 레이지 로딩: 데이터베이스에서 가져온 후 뷰에서 정렬한 길이를 offset으로 사용
        final limit = taskLoadingDuration.inDays; // 30일치를 한 번에 가져오는 것처럼 보이도록
        int offset = 0;
        if (!isRefresh && _remoteFetchedTasks.isNotEmpty) {
          // 기존 데이터를 뷰에서 정렬한 후의 길이를 offset으로 사용
          // 하지만 데이터베이스 정렬과 뷰 정렬이 다를 수 있으므로,
          // 대신 데이터베이스에서 가져온 후 클라이언트에서 정렬하고 중복 제거
          offset = _remoteFetchedTasks.length;
        }
        final completedResult = await _taskRepository.fetchTasksByStatus(status: TaskStatus.done, pref: _pref, userId: _user.id, limit: limit, offset: offset);
        completedResult.fold((l) {}, (r) {
          // linkedEvent == null이고 isCancelled가 아닌 것만 필터링 (데이터베이스에서 이미 필터링했지만 추가 확인)
          final filtered = r.where((t) => t.linkedEvent == null && !t.isCancelled).toList();
          overdueAndCompletedTasks.addAll(filtered);
        });
        break;
      case TaskLabelType.scheduled:
        // scheduled: overdue만 필요 (오늘 및 미래 날짜는 calendarTaskListControllerInternal에서 가져옴)
        final overdueStartDate = now.subtract(Duration(days: 365)); // 1년 전부터
        final overdueEndDate = now.subtract(Duration(days: 1)); // 어제까지

        final overdueResult = await _taskRepository.fetchTasksBetweenDates(startDateTime: overdueStartDate, endDateTime: overdueEndDate, pref: _pref, userId: _user.id);
        overdueResult.fold((l) {}, (r) {
          // overdue: status가 none이고 isOverdue이고 linkedEvent == null이고 isCancelled가 아닌 태스크
          final overdueTasks = r.where((t) => t.status == TaskStatus.none && t.isOverdue && !t.isUnscheduled && t.linkedEvent == null && !t.isCancelled).toList();
          overdueAndCompletedTasks.addAll(overdueTasks);
        });
        break;
      case TaskLabelType.overdue:
        // overdue: status가 none이고 isOverdue인 태스크만 가져오기
        final overdueStartDate = now.subtract(Duration(days: 365)); // 1년 전부터
        final overdueEndDate = now.subtract(Duration(days: 1)); // 어제까지

        final overdueResult = await _taskRepository.fetchTasksBetweenDates(startDateTime: overdueStartDate, endDateTime: overdueEndDate, pref: _pref, userId: _user.id);
        overdueResult.fold((l) {}, (r) {
          final overdueTasks = r.where((t) => t.status == TaskStatus.none && t.isOverdue && !t.isUnscheduled && t.linkedEvent == null && !t.isCancelled).toList();
          overdueAndCompletedTasks.addAll(overdueTasks);
        });
        break;
      case TaskLabelType.unscheduled:
        // unscheduled: 날짜가 없는 태스크만 가져오기
        final unscheduledResult = await _taskRepository.fetchUnscheduledTasks(pref: _pref, userId: _user.id);
        unscheduledResult.fold((l) {}, (r) {
          final unscheduledTasks = r.where((t) => (t.status == TaskStatus.none || t.status == TaskStatus.braindump) && t.linkedEvent == null && !t.isCancelled).toList();
          overdueAndCompletedTasks.addAll(unscheduledTasks);
        });
        break;
    }

    // completed 탭의 경우: 데이터베이스에서 updated_at 정렬로 가져온 순서 그대로 사용 (정렬 없음)
    if (taskLabelType == TaskLabelType.completed) {
      if (isRefresh) {
        _remoteFetchedTasks = overdueAndCompletedTasks..unique((e) => e.id);
      } else {
        // 레이지 로딩: 기존 데이터 뒤에 새 데이터 추가 (정렬 없음)
        _remoteFetchedTasks = [..._remoteFetchedTasks, ...overdueAndCompletedTasks]..unique((e) => e.id);
      }
    } else {
      // 다른 탭의 경우: 기존 로직 유지
      if (isRefresh) {
        _remoteFetchedTasks = overdueAndCompletedTasks..unique((e) => e.id);
      } else {
        _remoteFetchedTasks = [...overdueAndCompletedTasks, ..._remoteFetchedTasks]..unique((e) => e.id);
      }
    }

    // completed, overdue, unscheduled 탭이 아닐 때만 taskDates 업데이트
    if (taskLabelType != TaskLabelType.completed && taskLabelType != TaskLabelType.overdue && taskLabelType != TaskLabelType.unscheduled) {
      if (isRefresh && startAtAfter == null) {
        DateTime startDateTime = DateUtils.dateOnly(DateTime.now());
        List<DateTime> dateList = [];
        for (DateTime date = startDateTime; !date.isAfter(startAtBefore); date = date.add(Duration(days: 1))) {
          dateList.add(DateUtils.dateOnly(date));
        }
        ref.read(taskDatesProvider.notifier).updateDates([null, DateTime(1000), ...dateList]);
      } else if (!isRefresh && startAtAfter != null) {
        DateTime startDateTime = DateUtils.dateOnly(startAtAfter);
        List<DateTime> dateList = [];
        for (DateTime date = startDateTime.add(Duration(days: 1)); !date.isAfter(startAtBefore); date = date.add(Duration(days: 1))) {
          dateList.add(DateUtils.dateOnly(date));
        }
        ref.read(taskDatesProvider.notifier).updateDates([...ref.read(taskDatesProvider), ...dateList]);
      }
    }

    _updateState(list: _remoteFetchedTasks, updatedTimestamp: updatedTimestamp, isLocalUpdate: false);
  }

  Future<void> saveTask({
    TaskEntity? originalTask,
    TaskEntity? newTask,
    required DateTime? selectedEndDate,
    required DateTime? selectedStartDate,
    bool? updateTaskStatus,
    required TabType targetTab,
  }) async {
    BuildContext context = Utils.mainContext;
    String recurrence =
        originalTask?.rrule?.toString(options: RecurrenceRuleToStringOptions(isTimeUtc: true)) ??
        tasks.firstWhereOrNull((e) => e.id == originalTask?.recurringTaskId)?.rrule?.toString(options: RecurrenceRuleToStringOptions(isTimeUtc: true)) ??
        '';
    if (recurrence.isNotEmpty) {
      if (updateTaskStatus == true || (originalTask?.recurringTaskId != null && originalTask?.rrule == null) || tabType != targetTab) {
        if (selectedStartDate == null || selectedEndDate == null) return;
        await _updateRecurringEvent(
          recurringTaskEditType: RecurringTaskEditType.thisTaskOnly,
          originalTask: originalTask!,
          newTask: newTask,
          selectedEndDate: selectedEndDate,
          selectedStartDate: selectedStartDate,
          targetTab: targetTab,
        );
      } else {
        if (selectedStartDate == null || selectedEndDate == null) return;
        final type = await Utils.showRecurrenceEditConfirmPopup(isTask: true);
        if (type == null) return;
        if (Navigator.canPop(context)) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
        await _updateRecurringEvent(
          recurringTaskEditType: type,
          originalTask: originalTask!,
          newTask: newTask,
          selectedEndDate: selectedEndDate,
          selectedStartDate: selectedStartDate,
          targetTab: targetTab,
        );
      }
    } else {
      if (newTask != null) {
        await _upsertTask(task: newTask, originalTask: originalTask, targetTab: targetTab);
      } else if (originalTask != null) {
        await _deleteTask(task: originalTask, targetTab: targetTab);
      }
    }
  }

  Future<void> _updateRecurringEvent({
    required RecurringTaskEditType recurringTaskEditType,
    required TaskEntity originalTask,
    required TaskEntity? newTask,
    required DateTime selectedEndDate,
    required DateTime selectedStartDate,
    required TabType targetTab,
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
            list = [...tasks]
              ..removeWhere((e) => e.eventId == originalTask.eventId)
              ..add(savingTask);
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
            if (list.firstWhereOrNull((e) => e.eventId == savingTask.eventId) == null) {
              list.add(savingTask);
            }
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
              targetTab: targetTab,
            );
          }
        }

        var result = await _upsertTask(
          task: savingTask.copyWith(excludedRecurrenceDate: [], editedRecurrenceTaskIds: []),
          originalTask: originalTask,
          doNotUpdateState: true,
          prevState: prevState,
          targetTab: targetTab,
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
              result = await _deleteTask(task: originalTask, doNotUpdateState: true, prevState: prevState, targetTab: targetTab);
            } else {
              result = await _upsertTask(task: prevTasks, originalTask: originalTask, doNotUpdateState: true, prevState: prevState, targetTab: targetTab);
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
              result = await _deleteTask(task: originalTask, doNotUpdateState: true, prevState: prevState, targetTab: targetTab);
            } else {
              result = await _upsertTask(task: prevTasks, originalTask: originalTask, doNotUpdateState: true, prevState: prevState, targetTab: targetTab);
            }

            result = await _upsertTask(task: thisAndFutureEvents, originalTask: originalTask, doNotUpdateState: true, prevState: result, targetTab: targetTab);

            final remoteFetchList = result.where((e) => e.id != null).toList().unique((e) => e.id);
            _updateState(list: remoteFetchList, updatedTimestamp: updatedTimestamp, isLocalUpdate: false);
          }
          break;
        }
      case RecurringTaskEditType.allTasks:
        {
          final recurringTask = originalTask.recurringTaskId == null ? originalTask : tasks.firstWhereOrNull((e) => e.id == originalTask.recurringTaskId);

          if (recurringTask == null) return;

          if (isDelete) {
            await _deleteTask(task: recurringTask, forceDelete: true, targetTab: targetTab);
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

            await _upsertTask(task: allTasks, originalTask: originalTask, targetTab: targetTab);
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
    required TabType targetTab,
  }) async {
    final pref = ref.read(localPrefControllerProvider).value;
    if (pref == null) return [];

    List<TaskEntity> previousState = prevState ?? tasks;

    if (doNotUpdateState != true) {
      final list = tasks
        ..removeWhere((e) => e.id == (originalTask?.id ?? task.id))
        ..add(task)
        ..unique((e) => e.id);

      DateTime updatedTimestamp = DateTime.now();
      this.updatedTimestamp = updatedTimestamp;

      _updateState(list: list, updatedTimestamp: updatedTimestamp, isLocalUpdate: true);
    }

    if (targetTab != tabType) return state.value?.tasks ?? [];

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

        if (doNotUpdateState != true) {
          _updateState(list: remoteFetchList, updatedTimestamp: updatedTimestamp, isLocalUpdate: false);
        }

        return [...remoteFetchList];
      },
    );
  }

  Future<List<TaskEntity>> _deleteTask({required TaskEntity task, bool? forceDelete, bool? doNotUpdateState, List<TaskEntity>? prevState, required TabType targetTab}) async {
    final pref = ref.read(localPrefControllerProvider).value;
    if (pref == null) {
      return [];
    }

    List<TaskEntity> previousState = prevState ?? tasks;

    if (doNotUpdateState != true) {
      final list = tasks
        ..removeWhere((e) => e.id == task.id!)
        ..add(task.copyWith(status: TaskStatus.cancelled, startAt: task.startAt, endAt: task.startAt))
        ..unique((e) => e.id);

      DateTime updatedTimestamp = DateTime.now();
      this.updatedTimestamp = updatedTimestamp;
      _updateState(list: list, updatedTimestamp: updatedTimestamp, isLocalUpdate: true);
    }

    if (targetTab != tabType) {
      return state.value?.tasks ?? [];
    }

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

        if (doNotUpdateState != true) {
          _updateState(list: remoteFetchList, updatedTimestamp: updatedTimestamp, isLocalUpdate: false);
        }

        return remoteFetchList;
      },
    );
  }

  void _updateState({required List<TaskEntity> list, required DateTime updatedTimestamp, required bool isLocalUpdate}) async {
    list = list.where((e) => e.id?.isNotEmpty == true).toList().unique((e) => e.id)..sort((a, b) => a.id!.compareTo(b.id!));

    if (!isLocalUpdate) _remoteFetchedTasks = list;

    state = AsyncData(
      TaskListResultEntity(
        tasks: list,
        taskDates: taskDates,
        previousTasksOnView: state.value?.tasksOnView,
        previousTaskFetchedUntil: state.value?.taskFetchedUntil,
        previousTasks: state.value?.tasks,
        previousCachedRecurrenceInstances: state.value?.cachedRecurrenceInstances,
      ),
    );
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
      final task = state.value?.tasksOnView.firstWhereOrNull((t) => t.id == taskId);
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
      final task = state.value?.tasksOnView.firstWhereOrNull(
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

class TaskListResultEntity {
  final List<TaskEntity> tasks;
  final List<DateTime?> taskDates;
  final List<TaskEntity>? previousTasksOnView;
  final DateTime? previousTaskFetchedUntil;
  final List<TaskEntity>? previousTasks;
  final Map<String, List<DateTime>>? previousCachedRecurrenceInstances;
  late final Map<String, List<DateTime>> cachedRecurrenceInstances;

  DateTime? get taskFetchedUntil => taskDates.where((e) => e != null && e != DateTime(1000)).lastOrNull;
  DateTime? get taskFetchedFrom => taskDates.where((e) => e != null && e != DateTime(1000)).firstOrNull;
  late List<TaskEntity> tasksOnView;
  late List<TaskLabelEntity> taskLabelList;

  List<TaskEntity> get todayTasksOnView {
    return tasksOnView
        .where((t) => t.status == TaskStatus.none && !t.isOverdue && t.editedStartTime != null && t.editedStartDateOnly == DateUtils.dateOnly(DateTime.now()))
        .toList()
      ..sort((a, b) => taskSorter(a: a, b: b));
  }

  int taskSorter({required TaskEntity a, required TaskEntity b}) {
    if (a.createdAt == null || b.createdAt == null) return 0;
    if (a.editedStartTime == null || b.editedStartTime == null) return a.createdAt!.compareTo(b.createdAt!);
    return a.editedStartTime!.compareTo(b.editedStartTime!) == 0 ? a.createdAt!.compareTo(b.createdAt!) : a.editedStartTime!.compareTo(b.editedStartTime!);
  }

  Map<String, dynamic> toJson() {
    return {'tasks': tasks.map((e) => e.toJson(local: true)).toList(), 'taskDates': taskDates.map((e) => e?.toIso8601String()).toList()};
  }

  factory TaskListResultEntity.fromJson(Map<String, dynamic> json) {
    return TaskListResultEntity(
      tasks: (json['tasks'] as List<dynamic>).map((e) => TaskEntity.fromJson(e as Map<String, dynamic>, local: true)).toList(),
      taskDates: (json['taskDates'] as List<dynamic>).map((e) => e == null ? null : DateTime.parse(e)).toList(),
    );
  }

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
    // Index by date and recurringTaskId for faster lookup
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
    // Optimization: Use Map for O(1) lookup instead of O(n) where().firstOrNull
    final _tasksByRecurringIdAndDate = <String, TaskEntity>{};

    originalRecurringTasks.forEach((t) {
      if (taskFetchedUntil == null) return;
      if (t.startAt == null) return;
      if (t.startAt!.isAfter(taskFetchedUntil!)) return;

      List<DateTime>? dates;

      // Optimization: Reuse previous instances if rrule-related fields haven't changed
      // This allows cache reuse even when status or updatedAt changes
      if (previousTasks != null && previousCachedRecurrenceInstances != null && previousTaskFetchedUntil == taskFetchedUntil) {
        final previousTask = previousTasks!.firstWhereOrNull((e) => e.id == t.id);
        if (previousTask != null && _isRruleEqual(previousTask, t)) {
          dates = previousCachedRecurrenceInstances![t.id];
        }
      }

      DateTime startAt = t.startAt!;
      if (t.startAt!.isBefore(taskFetchedFrom!)) {
        startAt = taskFetchedFrom!;
      }

      if (dates == null) {
        dates = t.rrule?.getInstances(start: t.startAt!, after: startAt, before: taskFetchedUntil, includeAfter: true).toList();
      }

      if (dates != null) {
        cachedRecurrenceInstances[t.id!] = dates;
      }

      final taskDuration = t.startAt != null && t.endAt != null ? t.endAt!.difference(t.startAt!) : Duration(days: 1);

      dates?.forEach((date) {
        final dateOnly = DateUtils.dateOnly(date);
        final lookupKey = '${t.id}_${dateOnly.millisecondsSinceEpoch}';
        TaskEntity? recurringTaskOnDate = nonRecurringTasksByDateAndRecurringId[lookupKey];

        // Check excluded recurrence dates - compare dates only, not time
        bool isExcludedDate = t.excludedRecurrenceDate?.any((excludedDate) => DateUtils.dateOnly(excludedDate) == dateOnly) ?? false;

        if (isExcludedDate) return;

        if (recurringTaskOnDate == null) {
          final existTaskKey = '${t.id}_${date.millisecondsSinceEpoch}';
          TaskEntity? existTask = _tasksByRecurringIdAndDate[existTaskKey];
          final newTask = t.copyWith(
            id: existTask?.id ?? Uuid().v4(),
            recurringTaskId: t.id,
            editedStartTime: date,
            editedEndTime: date.add(taskDuration),
            excludedRecurrenceDate: [],
            editedRecurrenceTaskIds: [],
          );
          _tasks.add(newTask);
          if (newTask.id != null) {
            _tasksByRecurringIdAndDate[existTaskKey] = newTask;
          }
        } else {
          // Remove from map and list
          nonRecurringTasksByDateAndRecurringId.remove(lookupKey);
          nonRecurringTasks.remove(recurringTaskOnDate);

          final updatedTask = recurringTaskOnDate.isCancelled || recurringTaskOnDate.isDone
              ? recurringTaskOnDate.copyWith(editedStartTime: date, editedEndTime: date.add(taskDuration))
              : recurringTaskOnDate.copyWith(
                  id: recurringTaskOnDate.id,
                  recurringTaskId: recurringTaskOnDate.recurringTaskId,
                  editedStartTime: date,
                  editedEndTime: date.add(taskDuration),
                );
          _tasks.add(updatedTask);
        }
      });
    });

    // Optimization: Use List.from with capacity hint and addAll instead of spread operator
    // This reduces memory allocations compared to [...nonRecurringTasks, ..._tasks]
    tasksOnView = List.from(nonRecurringTasks, growable: true);
    tasksOnView.addAll(_tasks);

    taskLabelList = [
      TaskLabelEntity(type: TaskLabelType.all),
      TaskLabelEntity(type: TaskLabelType.scheduled),
      TaskLabelEntity(type: TaskLabelType.overdue),
      TaskLabelEntity(type: TaskLabelType.unscheduled),
      TaskLabelEntity(type: TaskLabelType.completed),
    ];
  }

  TaskListResultEntity({
    required this.tasks,
    required this.taskDates,
    this.previousTasksOnView,
    this.previousTaskFetchedUntil,
    this.previousTasks,
    this.previousCachedRecurrenceInstances,
  }) {
    updateTasksOnView();
  }
}
