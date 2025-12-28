import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:googleapis/calendar/v3.dart' as GoogleCalendar;

part 'event_reminder_entity.freezed.dart';
part 'event_reminder_entity.g.dart';

@freezed
abstract class EventReminderEntity with _$EventReminderEntity {
  // ignore: invalid_annotation_target
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory EventReminderEntity({
    String? method,
    int? minutes,
  }) = _EventReminderEntity;

  /// Serialization
  factory EventReminderEntity.fromJson(Map<String, dynamic> json) => _$EventReminderEntityFromJson(json);
}

extension EventReminderEntityX on EventReminderEntity {
  GoogleCalendar.EventReminder toGoogleEntity() {
    return GoogleCalendar.EventReminder(
      method: method,
      minutes: minutes,
    );
  }

  static EventReminderEntity fromGoogleEntity(GoogleCalendar.EventReminder eventAttendee) {
    return EventReminderEntity(
      method: eventAttendee.method,
      minutes: eventAttendee.minutes,
    );
  }
}

String getReminderString({required BuildContext context, required int minute, required bool isAllDay}) {
  final interval = minute;

  int days = interval ~/ (60 * 24);
  if (days != interval / 60 / 24) days += 1;

  final minutesInDay = interval % (60 * 24);
  final isWeek = days % 7 == 0;
  final count = isWeek ? days ~/ 7 : days;
  final minutes = minutesInDay == 0 ? 0 : 60 * 24 - minutesInDay;
  final hour = minutes ~/ 60;
  final min = minutes % 60;

  final hourDiff = interval ~/ 60;
  final minDiff = interval % 60;

  return minute == -2
      ? context.tr.none
      : minute == -1
          ? context.tr.custom_reminder
          : minute == 0
              ? context.tr.at_start_event
              : isAllDay
                  ? isWeek
                      ? context.tr
                          .week_before_at(count, hour == 24 && min == 0 ? 'midnight' : TimeOfDay(hour: hour, minute: min).format(context))
                      : minute > 0
                          ? context.tr
                              .day_before_at(count, hour == 0 && min == 0 ? 'midnight' : TimeOfDay(hour: hour, minute: min).format(context))
                          : context.tr
                              .on_day_of_event_at(hour == 0 && min == 0 ? 'midnight' : TimeOfDay(hour: hour, minute: min).format(context))
                  : '${hourDiff == 0 ? '' : hourDiff == 1 ? context.tr.reminder_hour : context.tr.reminder_hours(hourDiff)} ${minDiff == 0 ? '' : minDiff == 1 ? context.tr.reminder_minute : context.tr.reminder_minutes(minDiff)} ${context.tr.before}'
                      .trim();
}
