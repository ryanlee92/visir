import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/toasty_box/model/toast_model.dart';
import 'package:Visir/features/calendar/application/calendar_event_list_controller.dart';
import 'package:Visir/features/calendar/domain/entities/event_attendee_entity.dart';
import 'package:Visir/features/calendar/domain/entities/event_entity.dart';
import 'package:Visir/features/calendar/presentation/widgets/calendar_simple_create_widget.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/log_event.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/inbox/application/inbox_linked_task_controller.dart';
import 'package:flutter/cupertino.dart';

class CalendarAction {
  static void upsertLinkedTaskForInboxIfLinked(EventEntity event) {
    Utils.ref.read(inboxLinkedTaskControllerProvider.notifier).upsertLinkedEventForInbox(event);
  }

  static void deleteLinkedTaskForInboxIfLinked(EventEntity event) {
    Utils.ref.read(inboxLinkedTaskControllerProvider.notifier).deleteLinkedEventForInbox(event);
  }

  static Future<void> responseCalendarInvitation({
    required EventEntity event,
    required EventAttendeeResponseStatus status,
    required BuildContext context,
    required TabType tabType,
  }) async {
    await Utils.ref
        .read(calendarEventListControllerProvider(tabType: tabType).notifier)
        .responseCalendarInvitation(status: status, event: event, context: context, targetTab: tabType);
  }

  static Future<void> editCalendarEvent({
    required EventEntity? originalEvent,
    required EventEntity? newEvent,
    required DateTime selectedEndDate,
    required DateTime selectedStartDate,
    CalendarTaskEditSourceType? calendarTaskEditSourceType,
    required bool isCreate,
    required TabType tabType,
    bool showToast = true,
    bool? isLinkedWithMessages,
    bool? isLinkedWithMails,
    bool? isChannel,
    bool? isRepeat,
    DateTime? startDate,
  }) async {
    final recurringType = await Utils.ref
        .read(calendarEventListControllerProvider(tabType: tabType).notifier)
        .editCalendarEvent(
          context: Utils.mainContext,
          originalEvent: originalEvent,
          newEvent: newEvent,
          selectedEndDate: selectedEndDate,
          selectedStartDate: selectedStartDate,
          isCreate: isCreate,
          targetTab: tabType,
        );

    if (recurringType == null) return;
    if (newEvent == null) {
      deleteLinkedTaskForInboxIfLinked(originalEvent!);
    } else {
      upsertLinkedTaskForInboxIfLinked(newEvent);
    }

    if (calendarTaskEditSourceType != null) {
      logCalendarTaskCreateEvent(
        calendarTaskEditSourceType: calendarTaskEditSourceType,
        isEvent: true,
        tabType: tabType,
        isLinkedWithMessages: isLinkedWithMessages ?? false,
        isLinkedWithMails: isLinkedWithMails ?? false,
        isChannel: isChannel ?? false,
        isRepeat: isRepeat ?? false,
        startDate: startDate ?? DateTime.now(),
      );
    }

    if (!showToast) return;

    final isCreated = originalEvent == null && newEvent != null;
    final isDeleted = originalEvent != null && newEvent == null;
    final isEdited = !isCreated && !isDeleted;

    Utils.showToast(
      ToastModel(
        message: TextSpan(
          text: isCreated
              ? Utils.mainContext.tr.event_created
              : isEdited
              ? Utils.mainContext.tr.event_edited
              : Utils.mainContext.tr.event_deleted,
        ),
        buttons: [
          ToastButton(
            color: Utils.mainContext.primary,
            textColor: Utils.mainContext.onPrimary,
            text: Utils.mainContext.tr.undo,
            onTap: (item) {
              if (isCreated) {
                CalendarAction.editCalendarEvent(
                  originalEvent: newEvent,
                  calendarTaskEditSourceType: calendarTaskEditSourceType,
                  newEvent: null,
                  selectedEndDate: newEvent.endDate,
                  selectedStartDate: newEvent.startDate,
                  tabType: tabType,
                  showToast: false,
                  isCreate: false,
                );
              } else if (isDeleted) {
                CalendarAction.editCalendarEvent(
                  originalEvent: null,
                  calendarTaskEditSourceType: calendarTaskEditSourceType,
                  newEvent: originalEvent,
                  selectedEndDate: originalEvent.endDate,
                  selectedStartDate: originalEvent.startDate,
                  tabType: tabType,
                  showToast: false,
                  isCreate: true,
                );
              } else {
                CalendarAction.editCalendarEvent(
                  originalEvent: newEvent,
                  calendarTaskEditSourceType: calendarTaskEditSourceType,
                  newEvent: originalEvent,
                  selectedEndDate: originalEvent!.endDate,
                  selectedStartDate: originalEvent.startDate,
                  tabType: tabType,
                  showToast: false,
                  isCreate: false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
