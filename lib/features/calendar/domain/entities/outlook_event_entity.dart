import 'package:Visir/dependency/rrule/src/by_week_day_entry.dart';
import 'package:Visir/dependency/rrule/src/frequency.dart';
import 'package:Visir/dependency/rrule/src/recurrence_rule.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';
import 'package:microsoft_graph_api/models/models.dart' hide Location, Recipient;

part 'outlook_event_entity.freezed.dart';
part 'outlook_event_entity.g.dart';

@freezed
abstract class OutlookEventEntity with _$OutlookEventEntity {
  const factory OutlookEventEntity({
    bool? allowNewTimeProposals,
    List<Attendee>? attendees,
    ItemBody? body,
    String? bodyPreview,
    List<String>? cancelledOccurrences,
    List<OutlookEventEntity>? exceptionOccurrences,
    String? occurrenceId,
    List<String>? categories,
    String? changeKey,
    String? createdDateTime,
    DateTimeTimeZone? end,
    bool? hasAttachments,
    bool? hideAttendees,
    String? iCalUId,
    String? id,
    String? importance,
    bool? isAllDay,
    bool? isCancelled,
    bool? isDraft,
    bool? isOnlineMeeting,
    bool? isOrganizer,
    bool? isReminderOn,
    String? lastModifiedDateTime,
    Location? location,
    List<Location>? locations,
    OnlineMeetingInfo? onlineMeeting,
    OnlineMeetingProviderType? onlineMeetingProvider,
    String? onlineMeetingUrl,
    Recipient? organizer,
    String? originalEndTimeZone,
    String? originalStart,
    String? originalStartTimeZone,
    PatternedRecurrence? recurrence,
    int? reminderMinutesBeforeStart,
    bool? responseRequested,
    ResponseStatus? responseStatus,
    String? sensitivity,
    String? seriesMasterId,
    String? showAs,
    DateTimeTimeZone? start,
    String? subject,
    String? transactionId,
    String? type,
    String? webLink,
    List<Attachment>? attachments,
  }) = _OutlookEventEntity;

  /// Serialization
  factory OutlookEventEntity.fromJson(Map<String, dynamic> json) => _$OutlookEventEntityFromJson(json);
}

extension OutlookEventEntityX on OutlookEventEntity {
  Map<String, dynamic> toCreateJson() {
    return {
      if (allowNewTimeProposals != null) 'allowNewTimeProposals': allowNewTimeProposals,
      if (attendees != null) 'attendees': attendees?.map((e) => e.toJson()).toList(),
      if (body != null) 'body': body?.toJson(),
      if (bodyPreview != null) 'bodyPreview': bodyPreview,
      if (cancelledOccurrences != null) 'cancelledOccurrences': cancelledOccurrences,
      if (categories != null) 'categories': categories,
      if (changeKey != null) 'changeKey': changeKey,
      if (createdDateTime != null) 'createdDateTime': createdDateTime,
      if (end != null) 'end': isAllDay == true ? end?.toAlldayJson() : end?.toJson(),
      if (hasAttachments != null) 'hasAttachments': hasAttachments,
      if (hideAttendees != null) 'hideAttendees': hideAttendees,
      if (importance != null) 'importance': importance,
      if (isAllDay != null) 'isAllDay': isAllDay,
      if (isCancelled != null) 'isCancelled': isCancelled,
      if (isDraft != null) 'isDraft': isDraft,
      if (isOnlineMeeting != null) 'isOnlineMeeting': isOnlineMeeting,
      if (isOrganizer != null) 'isOrganizer': isOrganizer,
      if (isReminderOn != null) 'isReminderOn': isReminderOn,
      if (lastModifiedDateTime != null) 'lastModifiedDateTime': lastModifiedDateTime,
      if (location != null) 'location': location?.toJson(),
      if (locations != null) 'locations': locations?.map((e) => e.toJson()).toList(),
      if (onlineMeetingProvider != null) 'onlineMeetingProvider': onlineMeetingProvider?.name,
      if (organizer != null) 'organizer': organizer?.toJson(),
      if (originalEndTimeZone != null) 'originalEndTimeZone': originalEndTimeZone,
      if (originalStart != null) 'originalStart': originalStart,
      if (originalStartTimeZone != null) 'originalStartTimeZone': originalStartTimeZone,
      if (recurrence != null) 'recurrence': recurrence?.toJson(),
      if (reminderMinutesBeforeStart != null) 'reminderMinutesBeforeStart': reminderMinutesBeforeStart,
      if (responseRequested != null) 'responseRequested': responseRequested,
      if (responseStatus != null) 'responseStatus': responseStatus?.toJson(),
      if (sensitivity != null) 'sensitivity': sensitivity,
      if (seriesMasterId != null) 'seriesMasterId': seriesMasterId,
      if (showAs != null) 'showAs': showAs,
      if (start != null) 'start': isAllDay == true ? start?.toAlldayJson() : start?.toJson(),
      if (subject != null) 'subject': subject,
      // if (transactionId != null) 'transactionId': Uuid().v4(),
      if (attachments != null) 'attachments': attachments?.map((e) => e.toJson()).toList(),
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      if (attendees != null) 'attendees': attendees?.map((e) => e.toJson()).toList(),
      if (body != null) 'body': body?.toJson(),
      if (categories != null) 'categories': categories,
      if (end != null) 'end': isAllDay == true ? end?.toAlldayJson() : end?.toJson(),
      if (hideAttendees != null) 'hideAttendees': hideAttendees,
      if (importance != null) 'importance': importance,
      if (isAllDay != null) 'isAllDay': isAllDay,
      if (isCancelled != null) 'isCancelled': isCancelled,
      if (isOnlineMeeting != null) 'isOnlineMeeting': isOnlineMeeting,
      if (isReminderOn != null) 'isReminderOn': isReminderOn,
      if (location != null) 'location': location?.toJson(),
      if (locations != null) 'locations': locations?.map((e) => e.toJson()).toList(),
      if (onlineMeetingProvider != null) 'onlineMeetingProvider': onlineMeetingProvider?.name,
      if (recurrence != null) 'recurrence': recurrence?.toJson(),
      if (reminderMinutesBeforeStart != null) 'reminderMinutesBeforeStart': reminderMinutesBeforeStart,
      if (responseRequested != null) 'responseRequested': responseRequested,
      if (sensitivity != null) 'sensitivity': sensitivity,
      if (showAs != null) 'showAs': showAs,
      if (start != null) 'start': isAllDay == true ? start?.toAlldayJson() : start?.toJson(),
      if (subject != null) 'subject': subject,
      if (attachments != null) 'attachments': attachments?.map((e) => e.toJson()).toList(),
    };
  }
}

@freezed
abstract class Location with _$Location {
  const factory Location({String? displayName, String? locationEmailAddress, Address? address, GeoCoordinates? coordinates}) = _Location;

  /// Serialization
  factory Location.fromJson(Map<String, dynamic> json) => _$LocationFromJson(json);
}

@freezed
abstract class RecurrencePattern with _$RecurrencePattern {
  const factory RecurrencePattern({String? type, int? interval, int? month, int? dayOfMonth, List<String>? daysOfWeek, String? firstDayOfWeek, String? index}) =
      _RecurrencePattern;

  /// Serialization
  factory RecurrencePattern.fromJson(Map<String, dynamic> json) => _$RecurrencePatternFromJson(json);
}

@freezed
abstract class ResponseStatus with _$ResponseStatus {
  const factory ResponseStatus({String? response, String? time}) = _ResponseStatus;

  /// Serialization
  factory ResponseStatus.fromJson(Map<String, dynamic> json) => _$ResponseStatusFromJson(json);
}

@freezed
abstract class PatternedRecurrence with _$PatternedRecurrence {
  const factory PatternedRecurrence({RecurrencePattern? pattern, RecurrenceRange? range}) = _PatternedRecurrence;

  /// Serialization
  factory PatternedRecurrence.fromJson(Map<String, dynamic> json) => _$PatternedRecurrenceFromJson(json);
}

@freezed
abstract class DateTimeTimeZone with _$DateTimeTimeZone {
  const factory DateTimeTimeZone({String? dateTime, String? timeZone}) = _DateTimeTimeZone;

  /// Serialization
  factory DateTimeTimeZone.fromJson(Map<String, dynamic> json) => _$DateTimeTimeZoneFromJson(json);
}

extension DateTimeTimeZoneX on DateTimeTimeZone {
  Map<String, String?> toAlldayJson() {
    final dateString = dateTime?.endsWith('Z') == true ? dateTime! : '${dateTime!}Z';
    return {'dateTime': '${DateUtils.dateOnly(DateTime.parse(dateString).toLocal()).toIso8601String().replaceAll('Z', '')}', 'timeZone': timeZone};
  }
}

@freezed
abstract class Recipient with _$Recipient {
  const factory Recipient({EmailAddress? emailAddress}) = _Recipient;

  /// Serialization
  factory Recipient.fromJson(Map<String, dynamic> json) => _$RecipientFromJson(json);
}

extension PatternedRecurrenceX on PatternedRecurrence {
  RecurrenceRule get recurrenceRule {
    final days = {'monday': 1, 'tuesday': 2, 'wednesday': 3, 'thursday': 4, 'friday': 5, 'saturday': 6, 'sunday': 7};
    final occurence = {'first': 1, 'second': 2, 'third': 3, 'fourth': 4, 'last': -1};
    final weekStart = pattern?.firstDayOfWeek != null ? days[pattern!.firstDayOfWeek!]! : null;

    final frequency = switch (pattern?.type) {
      'daily' => Frequency.daily,
      'weekly' => Frequency.weekly,
      'absoluteMonthly' => Frequency.monthly,
      'relativeMonthly' => Frequency.monthly,
      'absoluteYearly' => Frequency.yearly,
      'relativeYearly' => Frequency.yearly,
      _ => Frequency.daily,
    };

    final byMonthDays = pattern?.dayOfMonth != null && pattern?.dayOfMonth != 0 ? [pattern!.dayOfMonth!] : List<int>.from([]);
    final byWeeks = frequency == Frequency.yearly && pattern?.index != null ? [occurence[pattern!.index!]!] : List<int>.from([]);
    final byWeekDays =
        pattern?.daysOfWeek
            ?.map(
              (e) => ByWeekDayEntry(
                days[e.toLowerCase()]!,
                pattern?.index == null
                    ? null
                    : ![Frequency.monthly, Frequency.yearly].contains(frequency)
                    ? null
                    : frequency != Frequency.yearly || byWeeks.isEmpty
                    ? occurence[pattern!.index!]!
                    : null,
              ),
            )
            .toList() ??
        [];
    final byYearDays = frequency == Frequency.yearly && pattern?.dayOfMonth != null && pattern?.dayOfMonth != 0 && pattern?.month != null
        ? [getDayOfYear(day: pattern!.dayOfMonth!, month: pattern!.month!)]
        : List<int>.from([]);
    final byMonths = pattern?.month != null && pattern?.month != 0 ? [pattern!.month!] : List<int>.from([]);
    final bySetPositions = byWeekDays.isNotEmpty || byMonthDays.isNotEmpty || byYearDays.isNotEmpty || byWeeks.isNotEmpty || byMonths.isNotEmpty
        ? [convertGraphIndexToBySetPos(pattern?.index)].whereType<int>().toList()
        : List<int>.from([]);

    return RecurrenceRule(
      frequency: frequency,
      until: range?.type != 'endDate'
          ? null
          : range?.endDate != null
          ? DateTime.parse(range!.endDate!).toUtc().add(Duration(days: 1))
          : null,
      count: range?.type != 'numbered' ? null : range?.numberOfOccurrences,
      interval: pattern?.interval,
      byWeekDays: byWeekDays,
      byMonthDays: byMonthDays,
      byYearDays: byYearDays,
      byWeeks: byMonths.isEmpty && bySetPositions.isEmpty ? byWeeks : [],
      byMonths: byMonths,
      bySetPositions: bySetPositions,
      weekStart: weekStart == DateTime.monday ? weekStart : null,
    );
  }

  static PatternedRecurrence fromRecurrenceRule({required RecurrenceRule rule, String? recurrenceTimeZone, String? startDate}) {
    final days = {1: 'monday', 2: 'tuesday', 3: 'wednesday', 4: 'thursday', 5: 'friday', 6: 'saturday', 7: 'sunday'};
    final occurence = {1: 'first', 2: 'second', 3: 'third', 4: 'fourth', -1: 'last'};
    final daysOfWeek = rule.byWeekDays.map((e) => days[e.day]!).toList();

    Map<String, int> convertByYearDayToMonthDay(int yearDay, {int year = 2025}) {
      final isLeapYear = DateTime(year, 12, 31).difference(DateTime(year, 1, 1)).inDays + 1 == 366;
      final totalDays = isLeapYear ? 366 : 365;

      // 음수는 뒤에서 세는 것 (-1은 마지막 날)
      int actualDay = yearDay > 0 ? yearDay : (totalDays + yearDay + 1);

      final date = DateTime(year).add(Duration(days: actualDay - 1));
      return {'month': date.month, 'day': date.day};
    }

    return PatternedRecurrence(
      pattern: RecurrencePattern(
        type: switch (rule.frequency) {
          Frequency.daily => 'daily',
          Frequency.weekly => 'weekly',
          Frequency.monthly => rule.hasByMonthDays ? 'absoluteMonthly' : 'relativeMonthly',
          Frequency.yearly => rule.hasByYearDays ? 'absoluteYearly' : 'relativeYearly',
          _ => 'daily',
        },
        interval: rule.interval ?? 1,
        month: rule.byMonths.firstOrNull ?? (rule.byYearDays.isNotEmpty ? convertByYearDayToMonthDay(rule.byYearDays.firstOrNull!)['month'] : null),
        dayOfMonth: daysOfWeek.isNotEmpty
            ? null
            : rule.byMonthDays.firstOrNull ?? (rule.byYearDays.isNotEmpty ? convertByYearDayToMonthDay(rule.byYearDays.firstOrNull!)['day'] : null),
        daysOfWeek: daysOfWeek.isNotEmpty ? daysOfWeek : null,
        firstDayOfWeek: rule.weekStart != null ? days[rule.weekStart!] : null,
        index: (rule.frequency == Frequency.monthly || rule.frequency == Frequency.yearly) && daysOfWeek.isNotEmpty
            ? occurence[rule.byWeekDays.firstOrNull?.occurrence ?? 1]
            : rule.bySetPositions.firstOrNull != null
            ? occurence[rule.bySetPositions.firstOrNull!]
            : null,
      ),
      range: RecurrenceRange(
        startDate: startDate,
        endDate: rule.until != null ? DateFormat('yyyy-MM-dd').format(rule.until!.toLocal()) : null,
        numberOfOccurrences: rule.count,
        recurrenceTimeZone: recurrenceTimeZone,
        type: rule.until == null && rule.count == null
            ? 'noEnd'
            : rule.until != null
            ? 'endDate'
            : rule.count != null
            ? 'numbered'
            : null,
      ),
    );
  }

  int? convertGraphIndexToBySetPos(String? index) {
    const map = {'first': 1, 'second': 2, 'third': 3, 'fourth': 4, 'last': -1};
    return map[index?.toLowerCase()];
  }

  int getDayOfYear({required int month, required int day, int year = 2025}) {
    final date = DateTime(year, month, day);
    final startOfYear = DateTime(year, 1, 1);
    return date.difference(startOfYear).inDays + 1;
  }
}

@freezed
abstract class RecurrenceRange with _$RecurrenceRange {
  const factory RecurrenceRange({String? endDate, int? numberOfOccurrences, String? recurrenceTimeZone, String? startDate, String? type}) = _RecurrenceRange;

  /// Serialization
  factory RecurrenceRange.fromJson(Map<String, dynamic> json) => _$RecurrenceRangeFromJson(json);
}

enum OnlineMeetingProviderType {
  @JsonValue("unknown")
  unknown,
  @JsonValue("teamsForBusiness")
  teamsForBusiness,
  @JsonValue("skypeForBusiness")
  skypeForBusiness,
  @JsonValue("skypeForConsumer")
  skypeForConsumer,
}

@freezed
abstract class OnlineMeetingInfo with _$OnlineMeetingInfo {
  const factory OnlineMeetingInfo({
    String? conferenceId,
    String? joinUrl,
    List<Phone>? phones,
    String? quickDial,
    List<String>? tollFreeNumbers,
    String? tollNumber,
  }) = _OnlineMeetingInfo;

  /// Serialization
  factory OnlineMeetingInfo.fromJson(Map<String, dynamic> json) => _$OnlineMeetingInfoFromJson(json);
}

@freezed
abstract class Phone with _$Phone {
  const factory Phone({String? number, String? type}) = _Phone;

  /// Serialization
  factory Phone.fromJson(Map<String, dynamic> json) => _$PhoneFromJson(json);
}
