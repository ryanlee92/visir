import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:flutter/material.dart';

enum TaskReminderOptionType {
  custom,
  none,
  atTheStart,
  fiveMinutesBefore,
  tenMinutesBefore,
  thirtyMinutesBefore,
  hourBefore,
  fifteenHoursBefore,
  nineHoursAfter,
  dayBefore,
}

extension TaskReminderOptionTypeX on TaskReminderOptionType {
  int minutes() {
    switch (this) {
      case TaskReminderOptionType.none:
      case TaskReminderOptionType.custom:
        return -1;
      case TaskReminderOptionType.atTheStart:
        return 0;
      case TaskReminderOptionType.fiveMinutesBefore:
        return 5;
      case TaskReminderOptionType.tenMinutesBefore:
        return 10;
      case TaskReminderOptionType.thirtyMinutesBefore:
        return 30;
      case TaskReminderOptionType.hourBefore:
        return 60;
      case TaskReminderOptionType.fifteenHoursBefore:
        return 60 * 15;
      case TaskReminderOptionType.nineHoursAfter:
        return -60 * 9;
      case TaskReminderOptionType.dayBefore:
        return 60 * 24;
    }
  }

  String getSelectionOptionTitle(BuildContext context, bool isAllDay) {
    if (isAllDay) {
      final interval = this.minutes();

      int days = interval ~/ (60 * 24);
      if (days != interval / 60 / 24) days += 1;

      final minutesInDay = interval % (60 * 24);
      final isWeek = days % 7 == 0;
      final count = isWeek ? days ~/ 7 : days;
      final minutes = minutesInDay == 0 ? 0 : 60 * 24 - minutesInDay;
      final hour = minutes ~/ 60;
      final min = minutes % 60;

      switch (this) {
        case TaskReminderOptionType.none:
          return context.tr.none;
        case TaskReminderOptionType.custom:
          return context.tr.custom_reminder;
        case TaskReminderOptionType.atTheStart:
          return context.tr.at_start_event;
        case TaskReminderOptionType.fiveMinutesBefore:
        case TaskReminderOptionType.tenMinutesBefore:
        case TaskReminderOptionType.thirtyMinutesBefore:
        case TaskReminderOptionType.hourBefore:
        case TaskReminderOptionType.fifteenHoursBefore:
        case TaskReminderOptionType.dayBefore:
          return isWeek
              ? context.tr.week_before_at(count, hour == 24 && min == 0 ? 'midnight' : TimeOfDay(hour: hour, minute: min).format(context))
              : context.tr.day_before_at(count, hour == 0 && min == 0 ? 'midnight' : TimeOfDay(hour: hour, minute: min).format(context));
        case TaskReminderOptionType.nineHoursAfter:
          return context.tr.on_day_of_event_at(hour == 0 && min == 0 ? 'midnight' : TimeOfDay(hour: hour, minute: min).format(context));
      }
    } else {
      final interval = this.minutes();
      final hourDiff = interval ~/ 60;
      final minDiff = interval % 60;

      switch (this) {
        case TaskReminderOptionType.none:
          return context.tr.none;
        case TaskReminderOptionType.custom:
          return context.tr.custom_reminder;
        case TaskReminderOptionType.atTheStart:
          return context.tr.at_start_event;
        case TaskReminderOptionType.fiveMinutesBefore:
        case TaskReminderOptionType.tenMinutesBefore:
        case TaskReminderOptionType.thirtyMinutesBefore:
        case TaskReminderOptionType.hourBefore:
        case TaskReminderOptionType.fifteenHoursBefore:
        case TaskReminderOptionType.nineHoursAfter:
        case TaskReminderOptionType.dayBefore:
          return '${hourDiff == 0
                  ? ''
                  : hourDiff == 1
                  ? context.tr.reminder_hour
                  : context.tr.reminder_hours(hourDiff)} ${minDiff == 0
                  ? ''
                  : minDiff == 1
                  ? context.tr.reminder_minute
                  : context.tr.reminder_minutes(minDiff)} ${context.tr.before}'
              .trim();
      }
    }
  }
}
