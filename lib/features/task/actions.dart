import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/toasty_box/model/toast_model.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/auth/domain/entities/user_entity.dart';
import 'package:Visir/features/calendar/presentation/widgets/calendar_simple_create_widget.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/log_event.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/inbox/application/inbox_linked_task_controller.dart';
import 'package:Visir/features/task/application/calendar_task_list_controller.dart';
import 'package:Visir/features/task/application/task_list_controller.dart';
import 'package:Visir/features/task/domain/entities/task_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TaskAction {
  static void upsertLinkedTaskForInboxIfLinked(TaskEntity task) {
    if (task.linkedMails.isEmpty && task.linkedMessages.isEmpty) return;
    Utils.ref.read(inboxLinkedTaskControllerProvider.notifier).upsertLinkedTaskForInbox(task);
  }

  static void deleteLinkedTaskForInboxIfLinked(TaskEntity task) {
    if (task.linkedMails.isEmpty && task.linkedMessages.isEmpty) return;
    Utils.ref.read(inboxLinkedTaskControllerProvider.notifier).deleteLinkedTaskForInbox(task);
  }

  static Future<void> toggleStatus({
    required TaskEntity task,
    required DateTime? startAt,
    required DateTime? endAt,
    required TabType tabType,
    void Function(TaskStatus newStatus)? changeLocalStatus,
    bool showToast = true,
  }) async {
    final user = Utils.ref.read(authControllerProvider).requireValue;
    CompletedTaskOptionType completedTaskOptionType = user.userCompletedTaskOptionType;

    final newState = task.status == TaskStatus.done
        ? TaskStatus.none
        : completedTaskOptionType == CompletedTaskOptionType.delete
        ? TaskStatus.cancelled
        : TaskStatus.done;

    changeLocalStatus?.call(newState);

    if (PlatformX.isMobileView) HapticFeedback.lightImpact();

    if (newState != TaskStatus.none && user.userTaskCompletionSound) {
      Utils.playTaskDoneSound();
    }

    if (tabType == TabType.task) {
      await Utils.ref
          .read(taskListControllerProvider.notifier)
          .saveTask(
            originalTask: task,
            newTask: task.copyWith(
              status: newState,
              startAt: startAt,
              endAt: endAt,
              createdAt: (newState != TaskStatus.none && task.rrule != null) ? DateTime.now() : task.createdAt,
              updatedAt: DateTime.now(),
            ),
            selectedEndDate: endAt,
            selectedStartDate: startAt,
            updateTaskStatus: true,
            targetTab: tabType,
          );
    } else {
      await Utils.ref
          .read(calendarTaskListControllerProvider(tabType: tabType).notifier)
          .saveTask(
            originalTask: task,
            newTask: task.copyWith(
              status: newState,
              startAt: startAt,
              endAt: endAt,
              createdAt: (newState != TaskStatus.none && task.rrule != null) ? DateTime.now() : task.createdAt,
              updatedAt: DateTime.now(),
            ),
            selectedEndDate: endAt,
            selectedStartDate: startAt,
            updateTaskStatus: true,
            targetTab: tabType,
          );
    }

    if (!showToast) return;

    Utils.showToast(
      ToastModel(
        message: TextSpan(text: task.status == TaskStatus.done ? Utils.mainContext.tr.task_undone : Utils.mainContext.tr.task_done),
        buttons: [
          ToastButton(
            color: Utils.mainContext.primary,
            textColor: Utils.mainContext.onPrimary,
            text: Utils.mainContext.tr.undo,
            onTap: (item) {
              TaskAction.toggleStatus(
                task: task.copyWith(status: newState),
                startAt: task.editedStartTime ?? DateTime.now(),
                endAt: task.editedEndTime ?? DateTime.now(),
                tabType: tabType,
                showToast: false,
              );
            },
          ),
        ],
      ),
    );
  }

  static Future<void> deleteTask({
    required TaskEntity task,
    required CalendarTaskEditSourceType calendarTaskEditSourceType,
    required TabType tabType,
    required DateTime? selectedStartDate,
    required DateTime? selectedEndDate,
    bool showToast = true,
  }) async {
    if (tabType == TabType.task) {
      await Utils.ref
          .read(taskListControllerProvider.notifier)
          .saveTask(originalTask: task, newTask: null, selectedEndDate: selectedEndDate, selectedStartDate: selectedStartDate, targetTab: tabType);
    } else {
      await Utils.ref
          .read(calendarTaskListControllerProvider(tabType: tabType).notifier)
          .saveTask(originalTask: task, newTask: null, selectedEndDate: selectedEndDate, selectedStartDate: selectedStartDate, targetTab: tabType);
    }

    deleteLinkedTaskForInboxIfLinked(task);

    if (!showToast) return;

    Utils.showToast(
      ToastModel(
        message: TextSpan(text: Utils.mainContext.tr.task_deleted),
        buttons: [
          ToastButton(
            color: Utils.mainContext.primary,
            textColor: Utils.mainContext.onPrimary,
            text: Utils.mainContext.tr.undo,
            onTap: (item) {
              upsertTask(
                task: task,
                originalTask: null,
                calendarTaskEditSourceType: calendarTaskEditSourceType,
                tabType: tabType,
                isLinkedWithMessages: task.linkedMessages.isNotEmpty,
                isLinkedWithMails: task.linkedMails.isNotEmpty,
                isChannel: false,
                isRepeat: task.rrule != null,
                startDate: task.startAt,
                showToast: false,
              );
            },
          ),
        ],
      ),
    );
  }

  static Future<void> upsertTask({
    required TaskEntity task,
    required CalendarTaskEditSourceType calendarTaskEditSourceType,
    required TabType tabType,
    TaskEntity? originalTask,
    DateTime? selectedStartDate,
    DateTime? selectedEndDate,
    bool? isLinkedWithMessages,
    bool? isLinkedWithMails,
    bool? isChannel,
    bool? isRepeat,
    DateTime? startDate,
    bool showToast = true,
  }) async {
    debugPrint('[TaskAction] upsertTask 시작: task.id=${task.id}, task.title=${task.title}, tabType=$tabType, originalTask=${originalTask?.id}');
    if (task.isUnscheduled) tabType = TabType.task;

    try {
      if (tabType == TabType.task) {
        debugPrint('[TaskAction] upsertTask: taskListController.saveTask 호출');
        await Utils.ref
            .read(taskListControllerProvider.notifier)
            .saveTask(
              originalTask: originalTask,
              newTask: task,
              targetTab: tabType,
              selectedStartDate: selectedStartDate ?? originalTask?.startAt,
              selectedEndDate: selectedEndDate ?? originalTask?.endAt?.add(Duration(days: originalTask.isAllDay == true ? 1 : 0)),
            );
        debugPrint('[TaskAction] upsertTask: taskListController.saveTask 완료');
      } else {
        debugPrint('[TaskAction] upsertTask: calendarTaskListController.saveTask 호출, tabType=$tabType');
        await Utils.ref
            .read(calendarTaskListControllerProvider(tabType: tabType).notifier)
            .saveTask(
              originalTask: originalTask,
              newTask: task,
              selectedStartDate: selectedStartDate ?? originalTask?.startAt,
              selectedEndDate: selectedEndDate ?? originalTask?.endAt?.add(Duration(days: originalTask.isAllDay == true ? 1 : 0)),
              targetTab: tabType,
            );
        debugPrint('[TaskAction] upsertTask: calendarTaskListController.saveTask 완료');
      }
    } catch (e, stackTrace) {
      debugPrint('[TaskAction] upsertTask 에러 발생: $e');
      debugPrint('[TaskAction] upsertTask StackTrace: $stackTrace');
      rethrow;
    }

    upsertLinkedTaskForInboxIfLinked(task);

    logCalendarTaskCreateEvent(
      calendarTaskEditSourceType: calendarTaskEditSourceType,
      isEvent: false,
      tabType: tabType,
      isLinkedWithMessages: isLinkedWithMessages ?? false,
      isLinkedWithMails: isLinkedWithMails ?? false,
      isChannel: isChannel ?? false,
      isRepeat: isRepeat ?? false,
      startDate: startDate ?? DateTime.now(),
    );

    if (!showToast) return;

    Utils.showToast(
      ToastModel(
        message: TextSpan(text: originalTask == null ? Utils.mainContext.tr.task_created : Utils.mainContext.tr.task_edited),
        buttons: [
          ToastButton(
            color: Utils.mainContext.primary,
            textColor: Utils.mainContext.onPrimary,
            text: Utils.mainContext.tr.task_created_undo,
            onTap: (item) {
              deleteTask(
                task: task,
                tabType: tabType,
                calendarTaskEditSourceType: calendarTaskEditSourceType,
                showToast: false,
                selectedStartDate: selectedStartDate,
                selectedEndDate: selectedEndDate,
              );
            },
          ),
        ],
      ),
    );
  }
}
