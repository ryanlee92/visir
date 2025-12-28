import 'dart:math';

import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/rrule/rrule.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/calendar/domain/entities/event_entity.dart';
import 'package:Visir/features/calendar/domain/entities/event_reminder_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_entity.dart';
import 'package:Visir/features/common/domain/entities/linked_item_entity.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/date_time_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/mail/domain/entities/mail_entity.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum TaskStatus { none, done, cancelled, braindump }

extension TaskStatusX on TaskStatus {
  int get sortValue {
    switch (this) {
      case TaskStatus.braindump:
        return 3;
      case TaskStatus.none:
        return 0;
      case TaskStatus.done:
        return 1;
      case TaskStatus.cancelled:
        return 2;
    }
  }
}

class TaskEntity {
  bool get isSignedIn => Utils.ref.read(isSignedInProvider);

  EventEntity? linkedEvent;
  List<LinkedMailEntity> linkedMails;
  List<LinkedMessageEntity> linkedMessages;

  String? id;
  String? ownerId;
  String? _title;
  String? description;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? _startAt;
  DateTime? _endAt;
  bool? _isAllDay;
  RecurrenceRule? rrule;
  TaskStatus status;
  DateTime? recurrenceEndAt;
  String? recurringTaskId;
  List<DateTime>? excludedRecurrenceDate;
  List<String>? editedRecurrenceTaskIds;
  List<EventReminderEntity>? reminders;
  String? projectId;

  DateTime? editedStartTime;
  DateTime? editedEndTime;

  Color? color;

  bool doNotApplyDateOffset = false;

  DateTime get comparingStartTime => isAllDay == true
      ? DateTime(editedStartTime?.year ?? startDate.year, editedStartTime?.month ?? startDate.month, editedStartTime?.day ?? startDate.day)
      : editedStartTime ?? startDate;

  void setColor(Color color) {
    this.color = color;
  }

  TaskEntity({
    this.id,
    this.ownerId,
    String? title,
    this.description,
    this.createdAt,
    this.updatedAt,
    DateTime? startAt,
    DateTime? endAt,
    bool? isAllDay,
    this.rrule,
    this.linkedEvent,
    this.linkedMails = const [],
    this.linkedMessages = const [],
    this.status = TaskStatus.none,
    this.recurrenceEndAt,
    this.recurringTaskId,
    this.excludedRecurrenceDate,
    this.editedRecurrenceTaskIds,
    this.reminders,
    this.projectId,
    this.editedEndTime,
    this.editedStartTime,
    this.doNotApplyDateOffset = false,
  }) {
    _title = title;
    _startAt = startAt;
    _endAt = endAt;
    _isAllDay = isAllDay;
  }

  TaskEntity copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? startAt,
    DateTime? endAt,
    bool? isAllDay,
    RecurrenceRule? rrule,
    EventEntity? linkedEvent,
    List<LinkedMailEntity>? linkedMails,
    List<LinkedMessageEntity>? linkedMessages,
    TaskStatus? status,
    DateTime? recurrenceEndAt,
    String? recurringTaskId,
    List<DateTime>? excludedRecurrenceDate,
    List<String>? editedRecurrenceTaskIds,
    List<EventReminderEntity>? reminders,
    String? projectId,
    DateTime? editedStartTime,
    DateTime? editedEndTime,
    bool? removeRrule,
    bool? removeRecurringTaskId,
    bool? removeLinkedEvent,
    bool? removeTime,
  }) {
    final task = TaskEntity(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this._title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      startAt: removeTime == true ? null : startAt ?? this._startAt,
      endAt: removeTime == true ? null : endAt ?? this._endAt,
      isAllDay: removeTime == true ? null : isAllDay ?? this._isAllDay,
      rrule: removeTime == true
          ? null
          : removeRrule == true
          ? null
          : rrule ?? this.rrule,
      linkedEvent: removeLinkedEvent == true ? null : linkedEvent ?? this.linkedEvent,
      linkedMails: linkedMails ?? this.linkedMails,
      linkedMessages: linkedMessages ?? this.linkedMessages,
      status: status ?? this.status,
      recurrenceEndAt: recurrenceEndAt ?? this.recurrenceEndAt,
      recurringTaskId: removeRecurringTaskId == true ? null : recurringTaskId ?? this.recurringTaskId,
      excludedRecurrenceDate: excludedRecurrenceDate ?? this.excludedRecurrenceDate,
      editedRecurrenceTaskIds: editedRecurrenceTaskIds ?? this.editedRecurrenceTaskIds,
      reminders: removeTime == true ? null : reminders ?? this.reminders,
      projectId: projectId ?? this.projectId,
      editedStartTime: removeTime == true ? null : editedStartTime ?? this.editedStartTime,
      editedEndTime: removeTime == true ? null : editedEndTime ?? this.editedEndTime,
      doNotApplyDateOffset: true,
    );

    if (this.color != null) task.setColor(this.color!);
    return task;
  }

  Map<String, dynamic> toJson({bool? local}) {
    return {
      'id': id,
      'owner_id': ownerId,
      'title': _title?.isNotEmpty == true
          ? local == true
                ? _title
                : Utils.encryptAESCryptoJS(_title!, aesKey)
          : null,
      'description': description?.isNotEmpty == true
          ? local == true
                ? description
                : Utils.encryptAESCryptoJS(description!, aesKey)
          : null,
      'created_at': createdAt?.toUtc().toIso8601String(),
      'updated_at': updatedAt?.toUtc().toIso8601String(),
      'start_at': _startAt?.toUtc().toIso8601String(),
      'end_at': _endAt?.toUtc().toIso8601String(),
      'is_all_day': _isAllDay,
      'rrule': rrule?.toString(options: RecurrenceRuleToStringOptions(isTimeUtc: true)),
      'recurring_task_id': recurringTaskId,
      'linked_event': linkedEvent?.toJson(),
      'linked_mails': linkedMails.map((e) => e.toJson(local: local)).toList(),
      'linked_messages': linkedMessages.map((e) => e.toJson(local: local)).toList(),
      'status': status.name,
      'recurrence_end_at': recurrenceEndAt?.toUtc().toIso8601String(),
      'excluded_recurrence_date': excludedRecurrenceDate?.map((e) => e.toUtc().toIso8601String()).toList(),
      'edited_recurrence_task_ids': editedRecurrenceTaskIds?.map((e) => e).toList(),
      'reminders': reminders?.map((e) => e.toJson()).toList(),
      'project_id': projectId,
    };
  }

  factory TaskEntity.fromJson(Map<String, dynamic> json, {bool? local}) {
    return TaskEntity(
      id: json['id'],
      ownerId: json['owner_id'],
      title: json['title'] == null
          ? null
          : local == true
          ? json['title']
          : Utils.decryptAESCryptoJS(json['title'], aesKey),
      description: json['description'] == null
          ? null
          : local == true
          ? json['description']
          : Utils.decryptAESCryptoJS(json['description'], aesKey),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']).toLocal() : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']).toLocal() : null,
      startAt: json['start_at'] != null ? DateTime.parse(json['start_at']).toLocal() : null,
      endAt: json['end_at'] != null ? DateTime.parse(json['end_at']).toLocal() : null,
      isAllDay: json['is_all_day'],
      rrule: json['rrule'] != null ? RecurrenceRule.fromString(json['rrule']) : null,
      recurringTaskId: json['recurring_task_id'],
      linkedEvent: json['linked_event'] != null ? EventEntity.fromJson(json['linked_event']) : null,
      linkedMails: (json['linked_mails'] as List?)?.map((e) => LinkedMailEntity.fromJson(e, local: local)).toList() ?? [],
      linkedMessages: (json['linked_messages'] as List?)?.map((e) => LinkedMessageEntity.fromJson(e, local: local)).toList() ?? [],
      status: TaskStatus.values.firstWhere((e) => e.name == json['status'], orElse: () => TaskStatus.none),
      recurrenceEndAt: json['recurrence_end_at'] != null ? DateTime.parse(json['recurrence_end_at']).toLocal() : null,
      excludedRecurrenceDate: (json['excluded_recurrence_date'] as List?)?.map((e) => DateTime.parse(e).toLocal()).toList() ?? [],
      editedRecurrenceTaskIds: (json['edited_recurrence_task_ids'] as List?)?.map((e) => e.toString()).toList() ?? [],
      reminders: (json['reminders'] as List?)?.map((e) => EventReminderEntity.fromJson(e)).toList() ?? [],
      projectId: json['project_id'] ?? json['background_color'] ?? null,
      doNotApplyDateOffset: json['do_not_apply_date_offset'] ?? false,
    );
  }

  List<TaskProvider> get providers {
    List<TaskProvider> providers = [];
    if (linkedEvent != null) {
      providers.add(TaskProvider(icon: 'assets/logos/logo_gcal.png', name: linkedEvent!.title ?? '', datetime: linkedEvent!.startDate));
    }
    if (linkedMails.isNotEmpty) {
      providers.addAll(linkedMails.map((e) => TaskProvider(icon: e.type.icon, name: e.fromName, datetime: e.date)));
    }
    if (linkedMessages.isNotEmpty) {
      providers.addAll(linkedMessages.map((e) => TaskProvider(icon: e.type.icon, name: '${!(e.isDm ?? false) ? '#' : ''}${e.channelName}', datetime: e.date)));
    }
    return providers;
  }

  operator ==(Object other) {
    return other is TaskEntity &&
        other.id == id &&
        other.ownerId == ownerId &&
        other._title == _title &&
        other.description == description &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other._startAt == _startAt &&
        other._endAt == _endAt &&
        other._isAllDay == _isAllDay &&
        other.rrule == rrule &&
        other.recurringTaskId == recurringTaskId &&
        other.linkedEvent == linkedEvent &&
        other.linkedMails == linkedMails &&
        other.linkedMessages == linkedMessages &&
        other.status == status &&
        other.recurrenceEndAt == recurrenceEndAt &&
        other.excludedRecurrenceDate == excludedRecurrenceDate &&
        other.editedRecurrenceTaskIds == editedRecurrenceTaskIds &&
        other.reminders == reminders &&
        other.projectId == projectId &&
        other.editedStartTime == editedStartTime &&
        other.editedEndTime == editedEndTime;
  }

  String? get title => isEvent ? linkedEvent?.title : _title;

  bool get isEvent => linkedEvent != null;

  bool get isThread => linkedMessages.firstOrNull?.threadId.isNotEmpty == true && linkedMessages.firstOrNull?.threadId != linkedMessages.firstOrNull?.messageId;

  String get calendarId => linkedEvent?.calendarId ?? 'taskCalendarId';

  String get eventId => linkedEvent?.eventId ?? id ?? '';

  String get uniqueId => recurringTaskId ?? linkedEvent?.uniqueId ?? id ?? '';

  DateTime? get startAt {
    final shouldUseMockData = Utils.ref.read(shouldUseMockDataProvider);
    if (!shouldUseMockData) return _startAt?.toLocal();
    return _startAt?.add(doNotApplyDateOffset ? Duration.zero : dateOffset);
  }

  DateTime? get endAt {
    final shouldUseMockData = Utils.ref.read(shouldUseMockDataProvider);
    if (!shouldUseMockData) return _endAt?.toLocal();
    return _endAt?.add(doNotApplyDateOffset ? Duration.zero : dateOffset);
  }

  DateTime get startDate => startAt ?? linkedEvent?.startDate ?? DateTime(1000);
  DateTime get endDate => endAt ?? linkedEvent?.endDate ?? DateTime(1000);

  bool get isAllDay => isEvent ? linkedEvent!.isAllDay : _isAllDay ?? false;

  String get calendarMail => !isEvent ? 'task' : linkedEvent!.calendar.email!;

  String get calendarName => !isEvent ? 'task' : linkedEvent!.calendarName;

  String get calendarType => !isEvent ? 'task' : linkedEvent!.calendarType.name;

  bool get isRequest => linkedEvent?.isRequest ?? false;

  bool get isMaybe => linkedEvent?.isMaybe ?? false;

  bool get isInDay => this.endDate.difference(this.startDate).inDays == 0;

  bool get isOverdue => (isAllDay ? editedStartDateOnly : editedEndDateOnly).isBefore(DateUtils.dateOnly((DateTime.now())));

  bool get isUnscheduled => startAt == null && endAt == null;

  bool get isBraindump => status == TaskStatus.braindump;

  DateTime get startDateOnly => DateUtils.dateOnly(startDate);

  DateTime get endDateOnly => DateUtils.dateOnly(endDate);

  DateTime get editedStartDateOnly => isEvent ? DateUtils.dateOnly(linkedEvent!.editedStartTime ?? linkedEvent!.startDate) : DateUtils.dateOnly(editedStartTime ?? startDate);

  DateTime get editedEndDateOnly => isEvent ? DateUtils.dateOnly(linkedEvent!.editedEndTime ?? linkedEvent!.endDate) : DateUtils.dateOnly(editedEndTime ?? endDate);

  List<DateTime> get editedDateOnlyList {
    final List<DateTime> dates = [];
    var currentDate = editedStartDateOnly;
    while (!currentDate.isAfter(editedEndDateOnly)) {
      dates.add(currentDate);
      currentDate = currentDate.add(const Duration(days: 1));
    }
    return dates;
  }

  // String get editeUniqueId => rrule != null ? '${uniqueId}@${editedStartTime}' : uniqueId;

  String getEditedUniqueId(DateTime? date) {
    if (isLongDurationTask && date != null) {
      String dateKey = '${DateUtils.dateOnly(date).year}@${DateUtils.dateOnly(date).month}@${DateUtils.dateOnly(date).day}';
      return rrule != null ? '${uniqueId}@${editedStartTime}@${dateKey}' : '${uniqueId}@${dateKey}';
    } else {
      return rrule != null ? '${uniqueId}@${editedStartTime}' : uniqueId;
    }
  }

  String? get conferenceLink => linkedEvent?.conferenceLink;

  String get shortTitle => '${title?.substring(0, min(title?.length ?? 0, 120))}${(title?.length ?? 0) > 120 ? '...' : ''}';

  String get messageTeamId => linkedMessages.firstOrNull?.teamId ?? '';

  String get messageChannelId => linkedMessages.firstOrNull?.channelId ?? '';

  bool get isEventDummyTask => id != null && linkedEvent != null;

  bool get isCancelled => status == TaskStatus.cancelled || linkedEvent?.isCancelled == true;

  bool get isDone => status == TaskStatus.done;

  bool get isOriginalRecurrenceTask => rrule != null && recurringTaskId == null;

  Duration get duration => endDate.difference(startDate);

  bool get isLongDurationTask => (duration.inHours >= 24) && (isAllDay == false) && (editedDateOnlyList.length > 1);

  String getStartTimeString(DateTime selectedDate, BuildContext context) {
    if (isEvent) {
      return linkedEvent!.getStartTimeString(selectedDate, context);
    }

    final startDate = startAt ?? DateTime(1970);
    final endDate = endAt ?? DateTime(1970);
    if (rrule == null) {
      selectedDate = startDate;
    } else {
      final nearSelectedDateStartTime = rrule!
          .getInstances(start: selectedDate.isBefore(startDate) ? selectedDate : startDate, before: selectedDate, includeBefore: true)
          .lastOrNull;
      final nearSelectedDateEndTime = nearSelectedDateStartTime?.add(Duration(minutes: endDate.difference(startDate).inMinutes));
      if (nearSelectedDateStartTime != null &&
          nearSelectedDateEndTime != null &&
          nearSelectedDateStartTime.isBefore(selectedDate) &&
          nearSelectedDateEndTime.isAfter(selectedDate)) {
        selectedDate = nearSelectedDateStartTime;
      }
    }
    final newStartDate = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, startDate.hour, startDate.minute, startDate.second);
    return newStartDate.timeString;
  }

  String getTimeString(DateTime selectedDate, BuildContext context) {
    if (isEvent) {
      return linkedEvent!.getStartTimeString(selectedDate, context);
    }

    if (rrule == null) {
      selectedDate = startDate;
    } else {
      final nearSelectedDateStartTime = rrule!
          .getInstances(start: selectedDate.isBefore(startDate) ? selectedDate : startDate, before: selectedDate, includeBefore: true)
          .lastOrNull;
      final nearSelectedDateEndTime = nearSelectedDateStartTime?.add(Duration(minutes: endDate.difference(startDate).inMinutes));
      if (nearSelectedDateStartTime != null &&
          nearSelectedDateEndTime != null &&
          nearSelectedDateStartTime.isBefore(selectedDate) &&
          nearSelectedDateEndTime.isAfter(selectedDate)) {
        selectedDate = nearSelectedDateStartTime;
      }
    }
    final newStartDate = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, startDate.hour, startDate.minute, startDate.second);
    var newEndDate = selectedDate.add(Duration(minutes: endDate.difference(startDate).inMinutes));
    newEndDate = DateTime(newEndDate.year, newEndDate.month, newEndDate.day, endDate.hour, endDate.minute, endDate.second);

    return isAllDay == true
        ? context.tr.all_day
        : isInDay == true
        ? newStartDate.timeString + ' - ' + newEndDate.timeString
        : (DateFormat.yMMMEd().format(newStartDate) + ' • ' + newStartDate.timeString + ' - ' + (DateFormat.yMMMEd().format(newEndDate) + ' • ' + newEndDate.timeString));
  }
}

class TaskProvider {
  String icon;
  String name;
  DateTime datetime;

  TaskProvider({required this.icon, required this.name, required this.datetime});

  operator ==(Object other) {
    return other is TaskProvider && other.icon == icon && other.name == name && other.datetime == datetime;
  }
}
