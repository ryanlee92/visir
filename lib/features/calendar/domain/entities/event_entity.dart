import 'package:Visir/dependency/rrule/rrule.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/calendar/domain/entities/calendar_entity.dart';
import 'package:Visir/features/calendar/domain/entities/event_attachment_entity.dart';
import 'package:Visir/features/calendar/domain/entities/event_attendee_entity.dart';
import 'package:Visir/features/calendar/domain/entities/event_reminder_entity.dart';
import 'package:Visir/features/calendar/domain/entities/outlook_event_entity.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/color_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/date_time_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:googleapis/calendar/v3.dart' as GCal;
import 'package:intl/intl.dart';
import 'package:microsoft_graph_api/models/models.dart' hide RecurrencePattern, Location;
import 'package:timezone/timezone.dart' as tz;
import 'package:uuid/uuid.dart';

class EventEntity {
  GCal.Event? _googleEvent;
  OutlookEventEntity? _msEvent;
  CalendarEntity _calendar;
  DateTime? _editedStartTime;
  DateTime? _editedEndTime;
  CalendarEntityType _calendarType;

  static String numberToWeekday(int number) {
    return ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'][number];
  }

  static String weekIndexToNumber(int weekIndex) {
    return ['first', 'second', 'third', 'fourth', 'last'][weekIndex];
  }

  bool doNotApplyDateOffset = false;

  EventEntity({
    EventEntity? modifiedEvent,
    required CalendarEntityType calendarType,
    required String? eventId,
    required String? title,
    required String? description,
    required RecurrenceRule? rrule,
    required String? location,
    required bool isAllDay,
    required DateTime startDate,
    required DateTime endDate,
    required List<EventAttendeeEntity> attendees,
    required List<EventReminderEntity> reminders,
    required List<EventAttachmentEntity> attachments,
    required String? conferenceLink,
    required String? timezone,
    required int sequence,
    required CalendarEntity calendar,
    this.doNotApplyDateOffset = false,
  }) : _calendarType = calendarType,
       _calendar = calendar,
       _googleEvent = calendarType == CalendarEntityType.google
           ? GCal.Event(
               id: eventId,
               summary: title,
               description: description,
               recurrence: rrule == null ? null : [rrule.toString(options: RecurrenceRuleToStringOptions(isTimeUtc: true))],
               location: location,
               start: GCal.EventDateTime(date: isAllDay ? startDate : null, dateTime: !isAllDay ? startDate : null, timeZone: timezone),
               end: GCal.EventDateTime(date: isAllDay ? endDate : null, dateTime: !isAllDay ? endDate : null, timeZone: timezone),
               attendees: attendees.isEmpty ? null : attendees.map((e) => e.toGoogleCalendarEventAttendee()).toList(),
               reminders: GCal.EventReminders(overrides: reminders.map((e) => e.toGoogleEntity()).toList(), useDefault: false),
               attachments: attachments.isEmpty ? null : attachments.map((e) => e.toGoogleEntity()).toList(),
               conferenceData:
                   modifiedEvent?.googleEvent?.conferenceData ??
                   (conferenceLink == 'added'
                       ? GCal.ConferenceData(
                           createRequest: GCal.CreateConferenceRequest(
                             requestId: Uuid().v4(),
                             conferenceSolutionKey: GCal.ConferenceSolutionKey(type: 'hangoutsMeet'),
                           ),
                         )
                       : null),
               sequence: sequence,
               hangoutLink: conferenceLink,
             )
           : null,
       _msEvent = calendarType == CalendarEntityType.microsoft
           ? OutlookEventEntity(
               id: eventId,
               subject: title,
               body: description?.isNotEmpty == true ? ItemBody(content: description!, contentType: 'text') : null,
               bodyPreview: description?.isNotEmpty == true ? description! : null,
               recurrence: rrule == null
                   ? null
                   : PatternedRecurrenceX.fromRecurrenceRule(rule: rrule, recurrenceTimeZone: timezone, startDate: DateFormat('yyyy-MM-dd').format(startDate.toLocal())),
               location: location?.isNotEmpty == true ? Location(displayName: location!) : null,
               locations: location?.isNotEmpty == true ? [Location(displayName: location!)] : null,
               isAllDay: isAllDay,
               start: DateTimeTimeZone(dateTime: startDate.toUtc().toIso8601String(), timeZone: timezone),
               end: DateTimeTimeZone(dateTime: endDate.toUtc().toIso8601String(), timeZone: timezone),
               attendees: attendees.isEmpty
                   ? null
                   : attendees
                         .map(
                           (e) => Attendee(
                             emailAddress: EmailAddress(address: e.email, name: e.displayName),
                           ),
                         )
                         .toList(),
               isReminderOn: reminders.isNotEmpty,
               reminderMinutesBeforeStart: reminders.map((e) => e.minutes).whereType<int>().toList().minOrNull,
               attachments: attachments.isEmpty ? null : attachments.map((e) => e.toMsEntity()).toList(),
               transactionId: sequence.toString(),
               isOnlineMeeting: conferenceLink == 'added' ? true : modifiedEvent?.msEvent?.isOnlineMeeting,
               onlineMeetingProvider: conferenceLink == 'added' ? OnlineMeetingProviderType.unknown : modifiedEvent?.msEvent?.onlineMeetingProvider,
             )
           : null;

  CalendarEntityType get calendarType => _calendarType;

  DatasourceType get datasourceType => _calendarType.datasourceType;

  GCal.Event? get googleEvent =>
      _googleEvent?.copyWith(recurrence: _googleEvent?.recurrence?.firstOrNull == null ? null : [Utils.fromGoogleRRule(_googleEvent!.recurrence!.first, startDate)]);

  OutlookEventEntity? get msEvent => _msEvent;

  List<String>? get cancelledOccurrences {
    switch (_calendarType) {
      case CalendarEntityType.google:
        return null;
      case CalendarEntityType.microsoft:
        return _msEvent?.cancelledOccurrences;
    }
  }

  Map<String, dynamic> toJson() {
    return {"calendarType": calendarType.name, "calendar": _calendar.toJson(), "googleEvent": _googleEvent?.toMap(), "msEvent": _msEvent?.toJson()};
  }

  factory EventEntity.fromJson(Map<String, dynamic> json) {
    CalendarEntityType calendarType = CalendarEntityType.values.firstWhere((e) => e.name == json['calendarType'], orElse: () => CalendarEntityType.google);
    final doNotApplyDateOffset = json['do_not_apply_date_offset'] ?? false;

    switch (calendarType) {
      case CalendarEntityType.google:
        return EventEntity.fromGoogleEvent(
          googleEvent: GCal.Event.fromJson(json['googleEvent']),
          calendar: CalendarEntity.fromJson(json['calendar']),
          doNotApplyDateOffset: doNotApplyDateOffset,
        );
      case CalendarEntityType.microsoft:
        return EventEntity.fromMsEvent(
          msEvent: OutlookEventEntity.fromJson(json['msEvent']),
          calendar: CalendarEntity.fromJson(json['calendar']),
          doNotApplyDateOffset: doNotApplyDateOffset,
        );
    }
  }

  DateTime get updatedAt {
    switch (_calendarType) {
      case CalendarEntityType.google:
        final updatedAt = (_googleEvent?.updated ?? DateTime(0)).toLocal();
        final shouldUseMockData = Utils.ref.read(shouldUseMockDataProvider);
        if (shouldUseMockData) return updatedAt.add(doNotApplyDateOffset ? Duration.zero : dateOffset);
        return updatedAt;
      case CalendarEntityType.microsoft:
        final updatedAt =
            (_msEvent?.lastModifiedDateTime == null
                    ? DateTime(0)
                    : DateTime.parse(_msEvent!.lastModifiedDateTime!.endsWith('Z') ? _msEvent!.lastModifiedDateTime! : '${_msEvent!.lastModifiedDateTime}Z'))
                .toLocal();
        final shouldUseMockData = Utils.ref.read(shouldUseMockDataProvider);
        if (shouldUseMockData) return updatedAt.add(doNotApplyDateOffset ? Duration.zero : dateOffset);
        return updatedAt;
    }
  }

  DateTime get startDate {
    switch (_calendarType) {
      case CalendarEntityType.google:
        final _start = (_googleEvent?.start?.dateTime ?? _googleEvent?.start?.date ?? DateTime(0)).toLocal();
        final startDate = getDateTimeWithTimezone(_start, _googleEvent?.start?.timeZone);
        final shouldUseMockData = Utils.ref.read(shouldUseMockDataProvider);
        if (shouldUseMockData) return startDate.add(doNotApplyDateOffset ? Duration.zero : dateOffset);

        return startDate;
      case CalendarEntityType.microsoft:
        final _start =
            (_msEvent?.start == null ? DateTime(0) : DateTime.parse(_msEvent!.start!.dateTime!.endsWith('Z') ? _msEvent!.start!.dateTime! : '${_msEvent!.start!.dateTime}Z'))
                .toLocal();
        final startDate = getDateTimeWithTimezone(_start, _msEvent?.start?.timeZone);
        final shouldUseMockData = Utils.ref.read(shouldUseMockDataProvider);
        if (shouldUseMockData) return startDate.add(doNotApplyDateOffset ? Duration.zero : dateOffset);
        return startDate;
    }
  }

  DateTime getDateTimeWithTimezone(DateTime dateTime, String? timezone) {
    if (timezone == null) return dateTime;
    final _tz = tz.getLocation(timezone);
    final tzDateTime = tz.TZDateTime.from(dateTime, _tz);
    return tzDateTime.toLocal().native.toLocal();
  }

  DateTime? getDateTimeWithTimezoneNullable(DateTime? dateTime, String? timezone) {
    if (timezone == null || dateTime == null) return dateTime;
    final _tz = tz.getLocation(timezone);
    final tzDateTime = tz.TZDateTime.from(dateTime, _tz);
    return tzDateTime.toLocal().native.toLocal();
  }

  DateTime get endDate {
    switch (_calendarType) {
      case CalendarEntityType.google:
        final _end = (_googleEvent?.end?.dateTime ?? _googleEvent?.end?.date ?? DateTime(0)).toLocal();
        final endDate = getDateTimeWithTimezone(_end, _googleEvent?.end?.timeZone);
        final shouldUseMockData = Utils.ref.read(shouldUseMockDataProvider);
        if (shouldUseMockData) return endDate.add(doNotApplyDateOffset ? Duration.zero : dateOffset);
        return endDate;
      case CalendarEntityType.microsoft:
        final _end = (_msEvent?.end == null ? DateTime(0) : DateTime.parse(_msEvent!.end!.dateTime!.endsWith('Z') ? _msEvent!.end!.dateTime! : '${_msEvent!.end!.dateTime}Z'))
            .toLocal();
        final endDate = getDateTimeWithTimezone(_end, _msEvent?.end?.timeZone);
        final shouldUseMockData = Utils.ref.read(shouldUseMockDataProvider);
        if (shouldUseMockData) return endDate.add(doNotApplyDateOffset ? Duration.zero : dateOffset);
        return endDate;
    }
  }

  DateTime? get editedStartTime => _editedStartTime;

  DateTime? get editedEndTime => _editedEndTime;

  bool get isAllDay {
    switch (_calendarType) {
      case CalendarEntityType.google:
        return _googleEvent?.start?.date != null;
      case CalendarEntityType.microsoft:
        return _msEvent?.isAllDay ?? false;
    }
  }

  bool get isOneDay {
    switch (_calendarType) {
      case CalendarEntityType.google:
        return isAllDay == true && this.endDate.difference(this.startDate).inDays <= 1;
      case CalendarEntityType.microsoft:
        return isAllDay == true && this.endDate.difference(this.startDate).inDays <= 1;
    }
  }

  bool get isInDay {
    switch (_calendarType) {
      case CalendarEntityType.google:
        return this.endDate.difference(this.startDate).inDays == 0;
      case CalendarEntityType.microsoft:
        return this.endDate.difference(this.startDate).inDays == 0;
    }
  }

  String getDateTimeString(DateTime selectedDate) {
    if (recurrence == null) {
      selectedDate = startDate;
    } else {
      final nearSelectedDateStartTime = recurrence!
          .getInstances(start: startDate.isAfter(selectedDate) ? selectedDate : startDate, before: selectedDate, includeBefore: true)
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

    return isOneDay == true
        ? DateFormat.yMMMEd().format(newStartDate)
        : isAllDay == true
        ? DateFormat.yMMMEd().format(newStartDate) + ' - ' + DateFormat.yMMMEd().format(newEndDate.subtract(Duration(days: 1)))
        : isInDay == true
        ? (DateFormat.yMMMEd().format(newStartDate) + ' • ' + newStartDate.timeString + ' - ' + newEndDate.timeString)
        : (DateFormat.yMMMEd().format(newStartDate) + ' • ' + newStartDate.timeString + ' - ' + (DateFormat.yMMMEd().format(newEndDate) + ' • ' + newEndDate.timeString));
  }

  static String getDatetime(bool isAllDay, DateTime dateTime) {
    return isAllDay == true ? DateFormat.yMMMEd().format(dateTime.toLocal()) : (DateFormat.yMMMEd().format(dateTime.toLocal()) + ' • ' + dateTime.toLocal().timeString);
  }

  static String getTimeForEdit(DateTime dateTime) {
    return dateTime.toLocal().timeString;
  }

  static String getTimeForEditWithMinutes(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime.toLocal());
  }

  static String getDateForEdit(DateTime dateTime) {
    return DateFormat('yyyy/MM/dd (E)').format(dateTime.toLocal()).toUpperCase();
  }

  static String getDateForEditSimple(DateTime dateTime) {
    return DateFormat('E, MMM d').format(dateTime.toLocal());
  }

  String getTimeString(DateTime selectedDate, BuildContext context) {
    if (recurrence == null) {
      selectedDate = startDate;
    } else {
      final nearSelectedDateStartTime = recurrence!
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

  String getStartTimeString(DateTime selectedDate, BuildContext context) {
    final actualStartDate = editedStartTime ?? startDate;
    if (recurrence == null) {
      selectedDate = actualStartDate;
    } else {
      final nearSelectedDateStartTime = recurrence!
          .getInstances(start: selectedDate.isBefore(actualStartDate) ? selectedDate : actualStartDate, before: selectedDate, includeBefore: true)
          .lastOrNull;
      final actualEndDate = editedEndTime ?? endDate;
      final nearSelectedDateEndTime = nearSelectedDateStartTime?.add(Duration(minutes: actualEndDate.difference(actualStartDate).inMinutes));
      if (nearSelectedDateStartTime != null &&
          nearSelectedDateEndTime != null &&
          nearSelectedDateStartTime.isBefore(selectedDate) &&
          nearSelectedDateEndTime.isAfter(selectedDate)) {
        selectedDate = nearSelectedDateStartTime;
      }
    }
    final newStartDate = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, actualStartDate.hour, actualStartDate.minute, actualStartDate.second);
    return newStartDate.timeString;
  }

  List<EventAttendeeEntity> get attendees {
    switch (_calendarType) {
      case CalendarEntityType.google:
        return (_googleEvent?.attendees ?? []).map((e) => EventAttendeeEntityX.fromGoogleCalendarEventAttendee(e)).toList();
      case CalendarEntityType.microsoft:
        return (_msEvent?.attendees ?? []).map((e) => EventAttendeeEntityX.fromMsCalendarEventAttendee(e)).toList();
    }
  }

  String? get organizer {
    switch (_calendarType) {
      case CalendarEntityType.google:
        return (_googleEvent?.organizer?.email);
      case CalendarEntityType.microsoft:
        return (_msEvent?.organizer?.emailAddress?.address);
    }
  }

  Color get foregroundColor {
    return ColorX.fromHex(_calendar.foregroundColor);
  }

  Color get backgroundColor {
    return ColorX.fromHex(_calendar.backgroundColor);
  }

  bool get isRequest {
    return attendees.where((e) => e.email == calendar.email).firstOrNull?.responseStatus == EventAttendeeResponseStatus.needsAction;
  }

  bool get isDeclined {
    return attendees.where((e) => e.email == calendar.email).firstOrNull?.responseStatus == EventAttendeeResponseStatus.declined;
  }

  bool get isMaybe {
    return attendees.where((e) => e.email == calendar.email).firstOrNull?.responseStatus == EventAttendeeResponseStatus.tentative;
  }

  bool get isCancelled {
    switch (_calendarType) {
      case CalendarEntityType.google:
        return _googleEvent?.status == 'cancelled';
      case CalendarEntityType.microsoft:
        return _msEvent?.isCancelled == true;
    }
  }

  String? get rrule {
    switch (_calendarType) {
      case CalendarEntityType.google:
        return _googleEvent?.recurrence?.firstOrNull;
      case CalendarEntityType.microsoft:
        return _msEvent?.recurrence?.recurrenceRule.toString(options: RecurrenceRuleToStringOptions(isTimeUtc: true));
    }
  }

  String? get title {
    switch (_calendarType) {
      case CalendarEntityType.google:
        return _googleEvent?.summary;
      case CalendarEntityType.microsoft:
        return _msEvent?.subject;
    }
  }

  String get calendarName {
    return _calendar.name;
  }

  String? get description {
    switch (_calendarType) {
      case CalendarEntityType.google:
        return _googleEvent?.description;
      case CalendarEntityType.microsoft:
        return _msEvent?.bodyPreview;
    }
  }

  String? get location {
    switch (_calendarType) {
      case CalendarEntityType.google:
        return _googleEvent?.location;
      case CalendarEntityType.microsoft:
        return _msEvent?.location?.displayName;
    }
  }

  List<EventReminderEntity>? get reminders {
    switch (_calendarType) {
      case CalendarEntityType.google:
        return _googleEvent?.reminders?.useDefault == true
            ? _calendar.defaultReminders
            : _googleEvent?.reminders?.overrides?.map((e) => EventReminderEntityX.fromGoogleEntity(e)).toList();
      case CalendarEntityType.microsoft:
        return _msEvent?.reminderMinutesBeforeStart != null ? [EventReminderEntity(minutes: _msEvent!.reminderMinutesBeforeStart!, method: 'app')] : null;
    }
  }

  String? get conferenceLink {
    switch (_calendarType) {
      case CalendarEntityType.google:
        return _googleEvent?.hangoutLink;
      case CalendarEntityType.microsoft:
        return _msEvent?.onlineMeeting?.joinUrl;
    }
  }

  bool get isModifiable {
    switch (_calendarType) {
      case CalendarEntityType.google:
        return _calendar.modifiable != false ||
            _googleEvent?.guestsCanModify == true ||
            (_googleEvent?.organizer?.email == _calendar.email && _googleEvent?.organizer?.email != null);
      case CalendarEntityType.microsoft:
        return _calendar.modifiable == true;
    }
  }

  bool get isRemovable {
    switch (_calendarType) {
      case CalendarEntityType.google:
        return _calendar.removable == true ||
            _googleEvent?.guestsCanModify == true ||
            (_googleEvent?.organizer?.email == _calendar.email && _googleEvent?.organizer?.email != null);
      case CalendarEntityType.microsoft:
        return _calendar.removable == true;
    }
  }

  bool get canSeeOtherGuests {
    switch (_calendarType) {
      case CalendarEntityType.google:
        return _googleEvent?.guestsCanSeeOtherGuests ?? true;
      case CalendarEntityType.microsoft:
        return true;
    }
  }

  bool get canInviteOthers {
    switch (_calendarType) {
      case CalendarEntityType.google:
        return _calendar.shareable == true || _googleEvent?.guestsCanInviteOthers == true;
      case CalendarEntityType.microsoft:
        return _calendar.shareable == true;
    }
  }

  String get eventId {
    switch (_calendarType) {
      case CalendarEntityType.google:
        return _googleEvent?.id ?? '';
      case CalendarEntityType.microsoft:
        return _msEvent?.id ?? '';
    }
  }

  String get iCalId {
    switch (_calendarType) {
      case CalendarEntityType.google:
        return _googleEvent!.iCalUID!;
      case CalendarEntityType.microsoft:
        return _msEvent!.iCalUId!;
    }
  }

  String get calendarId {
    return _calendar.id;
  }

  String get calendarUniqueId {
    return _calendar.uniqueId;
  }

  String get calendarAuthMail {
    return _calendar.email!;
  }

  String get uniqueId {
    switch (_calendarType) {
      case CalendarEntityType.google:
        return '${_googleEvent?.id}-${_calendar.uniqueId}';
      case CalendarEntityType.microsoft:
        return '${_msEvent?.id}-${_calendar.uniqueId}';
    }
  }

  DateTime? get startDateTime {
    switch (_calendarType) {
      case CalendarEntityType.google:
        final start = getDateTimeWithTimezoneNullable(_googleEvent?.start?.date ?? _googleEvent?.start?.dateTime, _googleEvent?.start?.timeZone);
        final shouldUseMockData = Utils.ref.read(shouldUseMockDataProvider);
        if (shouldUseMockData) return start?.add(doNotApplyDateOffset ? Duration.zero : dateOffset);
        return start;
      case CalendarEntityType.microsoft:
        final _start = _msEvent?.start == null
            ? null
            : DateTime.parse(_msEvent!.start!.dateTime!.endsWith('Z') ? _msEvent!.start!.dateTime! : '${_msEvent!.start!.dateTime}Z').toLocal();
        final start = getDateTimeWithTimezoneNullable(_start, _msEvent?.start?.timeZone);
        final shouldUseMockData = Utils.ref.read(shouldUseMockDataProvider);
        if (shouldUseMockData) return start?.add(doNotApplyDateOffset ? Duration.zero : dateOffset);
        return start;
    }
  }

  DateTime? get endDateTime {
    switch (_calendarType) {
      case CalendarEntityType.google:
        final end = getDateTimeWithTimezoneNullable(_googleEvent?.end?.date ?? _googleEvent?.end?.dateTime, _googleEvent?.end?.timeZone);
        final shouldUseMockData = Utils.ref.read(shouldUseMockDataProvider);
        if (shouldUseMockData) return end?.add(doNotApplyDateOffset ? Duration.zero : dateOffset);
        return end;
      case CalendarEntityType.microsoft:
        final _end = _msEvent?.end == null ? null : DateTime.parse(_msEvent!.end!.dateTime!.endsWith('Z') ? _msEvent!.end!.dateTime! : '${_msEvent!.end!.dateTime}Z').toLocal();
        final end = getDateTimeWithTimezoneNullable(_end, _msEvent?.end?.timeZone);
        final shouldUseMockData = Utils.ref.read(shouldUseMockDataProvider);
        if (shouldUseMockData) return end?.add(doNotApplyDateOffset ? Duration.zero : dateOffset);
        return end;
    }
  }

  String? get timezone {
    switch (_calendarType) {
      case CalendarEntityType.google:
        return _googleEvent?.start?.timeZone ?? _googleEvent?.end?.timeZone;
      case CalendarEntityType.microsoft:
        return _msEvent?.originalStartTimeZone ?? _msEvent?.originalEndTimeZone;
    }
  }

  RecurrenceRule? get recurrence {
    switch (_calendarType) {
      case CalendarEntityType.google:
        return _googleEvent?.recurrence?.firstOrNull == null ? null : RecurrenceRule.fromString(_googleEvent!.recurrence!.first);
      case CalendarEntityType.microsoft:
        return _msEvent?.recurrence?.recurrenceRule;
    }
  }

  String? get recurrenceString {
    switch (_calendarType) {
      case CalendarEntityType.google:
        return _googleEvent?.recurrence?.firstOrNull;
      case CalendarEntityType.microsoft:
        return _msEvent?.recurrence?.recurrenceRule.toString(options: RecurrenceRuleToStringOptions(isTimeUtc: true));
    }
  }

  String? get recurringEventId {
    switch (_calendarType) {
      case CalendarEntityType.google:
        return _googleEvent?.recurringEventId;
      case CalendarEntityType.microsoft:
        return _msEvent?.seriesMasterId;
    }
  }

  List<DateTime> get exceptionDates {
    switch (_calendarType) {
      case CalendarEntityType.google:
        return [];
      case CalendarEntityType.microsoft:
        final startTime = startDate.toUtc().toIso8601String().split('T').lastOrNull;
        final exceptionDates =
            _msEvent?.exceptionOccurrences?.map((e) => e.start?.dateTime == null ? null : DateTime.parse(e.start!.dateTime!).toLocal()).whereType<DateTime>().toList() ?? [];
        final cancelledDates =
            _msEvent?.cancelledOccurrences
                ?.map((e) => e.split('.').lastOrNull == null ? null : DateTime.parse('${e.split('.').last}T$startTime').toLocal())
                .whereType<DateTime>()
                .toList() ??
            [];

        return [...exceptionDates, ...cancelledDates].whereType<DateTime>().toSet().toList();
    }
  }

  List<EventAttachmentEntity> get attachments {
    switch (_calendarType) {
      case CalendarEntityType.google:
        return _googleEvent?.attachments?.map((e) => EventAttachmentEntityX.fromGoogleEntity(e)).toList() ?? [];
      case CalendarEntityType.microsoft:
        return _msEvent?.attachments?.map((e) => EventAttachmentEntityX.fromMsEntity(e)).toList() ?? [];
    }
  }

  DateTime? get originalStartTime {
    switch (_calendarType) {
      case CalendarEntityType.google:
        return getDateTimeWithTimezoneNullable(_googleEvent?.originalStartTime?.dateTime ?? _googleEvent?.originalStartTime?.date, _googleEvent?.originalStartTime?.timeZone);
      case CalendarEntityType.microsoft:
        final _originalStart = _msEvent?.originalStart == null
            ? null
            : DateTime.parse(_msEvent!.originalStart!.endsWith('Z') ? _msEvent!.originalStart! : '${_msEvent!.originalStart}Z').toLocal();
        return getDateTimeWithTimezoneNullable(_originalStart, _msEvent?.originalStartTimeZone);
    }
  }

  int get sequence {
    switch (_calendarType) {
      case CalendarEntityType.google:
        return _googleEvent?.sequence ?? 0;
      case CalendarEntityType.microsoft:
        return -1;
    }
  }

  CalendarEntity get calendar => _calendar;

  void setDates({required bool isAllDay, required DateTime startDate, required DateTime endDate, String? timezone, bool? doNotApplyDateOffset}) {
    this.doNotApplyDateOffset = true;
    switch (_calendarType) {
      case CalendarEntityType.google:
        _googleEvent = _googleEvent?.copyWith(
          start: GCal.EventDateTime(date: isAllDay != true ? null : startDate, dateTime: isAllDay == true ? null : startDate, timeZone: timezone ?? _googleEvent?.start?.timeZone),
          end: GCal.EventDateTime(date: isAllDay != true ? null : endDate, dateTime: isAllDay == true ? null : endDate, timeZone: timezone ?? _googleEvent?.end?.timeZone),
        );
        break;
      case CalendarEntityType.microsoft:
        _msEvent = _msEvent?.copyWith(
          start: DateTimeTimeZone(dateTime: startDate.toUtc().toIso8601String(), timeZone: timezone ?? _msEvent?.start?.timeZone),
          end: DateTimeTimeZone(dateTime: endDate.toUtc().toIso8601String(), timeZone: timezone ?? _msEvent?.end?.timeZone),
          isAllDay: isAllDay,
        );
        break;
    }
  }

  EventEntity.fromGoogleEvent({GCal.Event? googleEvent, required CalendarEntity calendar, DateTime? editedStartTime, DateTime? editedEndTime, bool? doNotApplyDateOffset})
    : _googleEvent = googleEvent,
      _calendar = calendar,
      _calendarType = CalendarEntityType.google,
      _editedStartTime = editedStartTime,
      _editedEndTime = editedEndTime,
      doNotApplyDateOffset = doNotApplyDateOffset ?? false;

  EventEntity.fromMsEvent({OutlookEventEntity? msEvent, required CalendarEntity calendar, DateTime? editedStartTime, DateTime? editedEndTime, bool? doNotApplyDateOffset})
    : _msEvent = msEvent,
      _calendar = calendar,
      _calendarType = CalendarEntityType.microsoft,
      _editedStartTime = editedStartTime,
      _editedEndTime = editedEndTime,
      doNotApplyDateOffset = doNotApplyDateOffset ?? false;

  EventEntity _copyWith({
    CalendarEntityType? calendarType,
    GCal.Event? googleEvent,
    OutlookEventEntity? msEvent,
    CalendarEntity? calendar,
    DateTime? editedStartTime,
    DateTime? editedEndTime,
  }) {
    switch (calendarType) {
      case CalendarEntityType.google:
        return EventEntity.fromGoogleEvent(
          googleEvent: googleEvent ?? _googleEvent?.copyWith(),
          calendar: calendar ?? _calendar.copyWith(),
          editedEndTime: editedEndTime ?? _editedEndTime,
          editedStartTime: editedStartTime ?? _editedStartTime,
          doNotApplyDateOffset: true,
        );
      case CalendarEntityType.microsoft:
        return EventEntity.fromMsEvent(
          msEvent: msEvent ?? _msEvent?.copyWith(),
          calendar: calendar ?? _calendar.copyWith(),
          editedEndTime: editedEndTime ?? _editedEndTime,
          editedStartTime: editedStartTime ?? _editedStartTime,
          doNotApplyDateOffset: true,
        );
      default:
        return this;
    }
  }

  EventEntity copyWith({
    EventEntity? modifiedEvent,
    CalendarEntity? calendar,
    bool? anyoneCanAddSelf,
    List<EventAttachmentEntity>? attachments,
    List<EventAttendeeEntity>? attendees,
    bool? attendeesOmitted,
    String? colorId,
    String? timeZone,
    bool? forceConferenceDataToNull,
    DateTime? created,
    String? description,
    bool? endTimeUnspecified,
    String? conferenceLink,
    String? etag,
    String? eventType,
    bool? guestsCanInviteOthers,
    bool? guestsCanModify,
    bool? guestsCanSeeOtherGuests,
    String? hangoutLink,
    String? htmlLink,
    String? iCalUID,
    String? id,
    String? kind,
    String? location,
    bool? locked,
    DateTime? editedStartTime,
    DateTime? editedEndTime,
    bool? privateCopy,
    RecurrenceRule? rrule,
    String? recurringEventId,
    List<EventReminderEntity>? reminders,
    int? sequence,
    String? status,
    String? title,
    String? transparency,
    DateTime? updated,
    String? visibility,
    GCal.EventWorkingLocationProperties? workingLocationProperties,
    bool? isAllDay,
    DateTime? endDate,
    DateTime? startDate,
    bool? removeRecurrence,
    bool? removeId,
    bool? removeICalUID,
    bool? removeRecurringId,
    DateTime? originalStartTime,
  }) {
    switch (calendarType) {
      case CalendarEntityType.google:
        return this._copyWith(
          calendarType: calendarType,
          calendar: calendar ?? _calendar,
          editedEndTime: editedEndTime ?? _editedEndTime,
          editedStartTime: editedStartTime ?? _editedStartTime,
          googleEvent: _googleEvent?.copyWith(
            anyoneCanAddSelf: anyoneCanAddSelf ?? _googleEvent?.anyoneCanAddSelf,
            attachments: attachments?.isNotEmpty != true ? null : attachments?.map((e) => e.toGoogleEntity()).toList() ?? _googleEvent?.attachments,
            attendees: attendees?.map((e) => e.toGoogleCalendarEventAttendee()).toList() ?? _googleEvent?.attendees,
            attendeesOmitted: attendeesOmitted ?? _googleEvent?.attendeesOmitted,
            colorId: colorId ?? _googleEvent?.colorId,
            forceConferenceDataToNull: forceConferenceDataToNull,
            conferenceData:
                modifiedEvent?.googleEvent?.conferenceData ??
                (conferenceLink == 'added'
                    ? GCal.ConferenceData(
                        createRequest: GCal.CreateConferenceRequest(
                          requestId: Uuid().v4(),
                          conferenceSolutionKey: GCal.ConferenceSolutionKey(type: 'hangoutsMeet'),
                        ),
                      )
                    : null),
            created: created ?? _googleEvent?.created,
            creator: modifiedEvent?.googleEvent?.creator ?? _googleEvent?.creator,
            description: description ?? _googleEvent?.description,
            endTimeUnspecified: endTimeUnspecified ?? _googleEvent?.endTimeUnspecified,
            etag: etag ?? _googleEvent?.etag,
            eventType: eventType ?? _googleEvent?.eventType,
            extendedProperties: modifiedEvent?.googleEvent?.extendedProperties ?? _googleEvent?.extendedProperties,
            gadget: modifiedEvent?.googleEvent?.gadget ?? _googleEvent?.gadget,
            guestsCanInviteOthers: guestsCanInviteOthers ?? _googleEvent?.guestsCanInviteOthers,
            guestsCanModify: guestsCanModify ?? _googleEvent?.guestsCanModify,
            guestsCanSeeOtherGuests: guestsCanSeeOtherGuests ?? _googleEvent?.guestsCanSeeOtherGuests,
            hangoutLink: hangoutLink ?? _googleEvent?.hangoutLink,
            htmlLink: htmlLink ?? _googleEvent?.htmlLink,
            iCalUID: removeICalUID == true ? '' : iCalUID ?? _googleEvent?.iCalUID,
            id: removeId == true ? '' : id ?? _googleEvent?.id,
            kind: kind ?? _googleEvent?.kind,
            location: location ?? _googleEvent?.location,
            locked: locked ?? _googleEvent?.locked,
            organizer: modifiedEvent?.googleEvent?.organizer ?? _googleEvent?.organizer,
            privateCopy: privateCopy ?? _googleEvent?.privateCopy,
            recurrence: removeRecurrence == true
                ? []
                : rrule != null
                ? [rrule.toString(options: RecurrenceRuleToStringOptions(isTimeUtc: true))]
                : _googleEvent?.recurrence,
            recurringEventId: removeRecurringId == true ? '' : recurringEventId ?? _googleEvent?.recurringEventId,
            reminders: reminders != null
                ? reminders.isNotEmpty != true
                      ? null
                      : GCal.EventReminders(overrides: reminders.map((e) => e.toGoogleEntity()).toList(), useDefault: false)
                : _googleEvent?.reminders,
            sequence: sequence ?? (_googleEvent?.sequence == null ? 0 : _googleEvent!.sequence! + 1),
            source: modifiedEvent?.googleEvent?.source ?? _googleEvent?.source,
            start: startDate == null
                ? GCal.EventDateTime(date: _googleEvent?.start?.date, dateTime: _googleEvent?.start?.dateTime, timeZone: timeZone ?? _googleEvent?.start?.timeZone)
                : GCal.EventDateTime(date: isAllDay != true ? null : startDate, dateTime: isAllDay == true ? null : startDate, timeZone: timeZone ?? _googleEvent?.start?.timeZone),
            end: endDate == null
                ? GCal.EventDateTime(date: _googleEvent?.end?.date, dateTime: _googleEvent?.end?.dateTime, timeZone: timeZone ?? _googleEvent?.end?.timeZone)
                : GCal.EventDateTime(date: isAllDay != true ? null : endDate, dateTime: isAllDay == true ? null : endDate, timeZone: timeZone ?? _googleEvent?.end?.timeZone),
            status: status ?? _googleEvent?.status,
            summary: title ?? _googleEvent?.summary,
            transparency: transparency ?? _googleEvent?.transparency,
            updated: updated ?? _googleEvent?.updated,
            visibility: visibility ?? _googleEvent?.visibility,
            workingLocationProperties: workingLocationProperties ?? _googleEvent?.workingLocationProperties,
            originalStartTime: originalStartTime == null
                ? _googleEvent?.originalStartTime == null
                      ? null
                      : GCal.EventDateTime(
                          date: _googleEvent?.originalStartTime?.date,
                          dateTime: _googleEvent?.originalStartTime?.dateTime,
                          timeZone: timeZone ?? _googleEvent?.originalStartTime?.timeZone,
                        )
                : GCal.EventDateTime(
                    date: isAllDay != true ? null : originalStartTime,
                    dateTime: isAllDay == true ? null : originalStartTime,
                    timeZone: timeZone ?? _googleEvent?.start?.timeZone,
                  ),
          ),
        );
      case CalendarEntityType.microsoft:
        final timezone = timeZone ?? _msEvent?.start?.timeZone ?? _msEvent?.end?.timeZone;
        return this._copyWith(
          calendarType: calendarType,
          calendar: calendar ?? _calendar,
          editedEndTime: editedEndTime ?? _editedEndTime,
          editedStartTime: editedStartTime ?? _editedStartTime,
          msEvent: _msEvent?.copyWith(
            allowNewTimeProposals: modifiedEvent?.msEvent?.allowNewTimeProposals ?? _msEvent?.allowNewTimeProposals,
            attendees: attendees?.map((e) => e.toMsCalendarEventAttendee()).toList() ?? _msEvent?.attendees,
            body: description == null ? _msEvent?.body : ItemBody(content: description, contentType: 'text'),
            bodyPreview: description ?? _msEvent?.bodyPreview,
            cancelledOccurrences: _msEvent?.cancelledOccurrences,
            categories: _msEvent?.categories,
            changeKey: _msEvent?.changeKey,
            createdDateTime: _msEvent?.createdDateTime,
            end: endDate == null ? _msEvent?.end : DateTimeTimeZone(dateTime: endDate.toUtc().toIso8601String(), timeZone: timezone),
            hasAttachments: attachments?.isNotEmpty != true ? null : _msEvent?.hasAttachments,
            hideAttendees: _msEvent?.hideAttendees,
            iCalUId: iCalUID == null ? _msEvent?.iCalUId : iCalUID,
            id: id == null ? _msEvent?.id : id,
            importance: _msEvent?.importance,
            isAllDay: isAllDay ?? _msEvent?.isAllDay,
            isCancelled: status == 'cancelled' ? true : _msEvent?.isCancelled,
            isDraft: _msEvent?.isDraft,
            isOnlineMeeting: _msEvent?.isOnlineMeeting,
            isOrganizer: _msEvent?.isOrganizer,
            isReminderOn: _msEvent?.isReminderOn,
            lastModifiedDateTime: _msEvent?.lastModifiedDateTime,
            location: location == null ? _msEvent?.location : Location(displayName: location),
            locations: location == null ? _msEvent?.locations : [Location(displayName: location)],
            onlineMeeting: _msEvent?.onlineMeeting,
            onlineMeetingProvider: _msEvent?.onlineMeetingProvider,
            onlineMeetingUrl: _msEvent?.onlineMeetingUrl,
            organizer: modifiedEvent?.msEvent?.organizer ?? _msEvent?.organizer,
            originalEndTimeZone: originalStartTime == null ? _msEvent?.originalStartTimeZone : timezone,
            originalStart: originalStartTime == null ? _msEvent?.originalStart : originalStartTime.toUtc().toIso8601String(),
            originalStartTimeZone: originalStartTime == null ? _msEvent?.originalStartTimeZone : timezone,
            recurrence: removeRecurrence == true
                ? null
                : rrule != null
                ? PatternedRecurrenceX.fromRecurrenceRule(
                    rule: rrule,
                    recurrenceTimeZone: timezone,
                    startDate: startDate != null ? DateFormat('yyyy-MM-dd').format(startDate.toLocal()) : _msEvent?.recurrence?.range?.startDate,
                  )
                : _msEvent?.recurrence,
            reminderMinutesBeforeStart: _msEvent?.reminderMinutesBeforeStart,
            responseRequested: _msEvent?.responseRequested,
            responseStatus: _msEvent?.responseStatus,
            sensitivity: _msEvent?.sensitivity,
            seriesMasterId: _msEvent?.seriesMasterId,
            showAs: _msEvent?.showAs,
            start: startDate == null ? _msEvent?.start : DateTimeTimeZone(dateTime: startDate.toUtc().toIso8601String(), timeZone: timezone),
            subject: title ?? _msEvent?.subject,
            transactionId: _msEvent?.transactionId,
            type: _msEvent?.type,
            webLink: _msEvent?.webLink,
            attachments: attachments?.map((e) => e.toMsEntity()).toList() ?? _msEvent?.attachments,
          ),
        );
    }
  }

  EventEntity copyDeletedRecurringWith({String? id, String? recurringEventId, DateTime? originalStartTime, bool? doNotApplyDateOffset}) {
    switch (this.calendarType) {
      case CalendarEntityType.google:
        return EventEntity.fromGoogleEvent(
          doNotApplyDateOffset: doNotApplyDateOffset ?? this.doNotApplyDateOffset,
          calendar: _calendar,
          editedEndTime: _editedEndTime,
          editedStartTime: _editedStartTime,
          googleEvent: GCal.Event(
            id: id,
            recurringEventId: recurringEventId,
            originalStartTime: originalStartTime == null
                ? null
                : GCal.EventDateTime(date: originalStartTime, dateTime: originalStartTime, timeZone: originalStartTime.timeZoneName),
            status: 'cancelled',
            kind: 'calendar#event',
          ),
        );
      case CalendarEntityType.microsoft:
        return EventEntity.fromMsEvent(
          doNotApplyDateOffset: doNotApplyDateOffset ?? this.doNotApplyDateOffset,
          calendar: _calendar,
          editedEndTime: _editedEndTime,
          editedStartTime: _editedStartTime,
          msEvent: OutlookEventEntity(
            id: id,
            seriesMasterId: recurringEventId,
            originalStart: originalStartTime == null ? null : originalStartTime.toUtc().toIso8601String(),
            originalStartTimeZone: originalStartTime?.timeZoneName,
            isCancelled: true,
          ),
        );
    }
  }

  EventEntity copyDeletedWith({bool? doNotApplyDateOffset}) {
    switch (this.calendarType) {
      case CalendarEntityType.google:
        return EventEntity.fromGoogleEvent(
          doNotApplyDateOffset: doNotApplyDateOffset ?? this.doNotApplyDateOffset,
          calendar: _calendar,
          editedEndTime: _editedEndTime,
          editedStartTime: _editedStartTime,
          googleEvent: GCal.Event(id: this.eventId, start: null, end: null, sequence: this.sequence + 1, status: 'cancelled', kind: 'calendar#event'),
        );
      case CalendarEntityType.microsoft:
        return EventEntity.fromMsEvent(
          doNotApplyDateOffset: doNotApplyDateOffset ?? this.doNotApplyDateOffset,
          calendar: _calendar,
          editedEndTime: _editedEndTime,
          editedStartTime: _editedStartTime,
          msEvent: OutlookEventEntity(id: this.eventId, isCancelled: true, transactionId: (this.sequence + 1).toString()),
        );
    }
  }
}

// for google
extension GcalEventX on GCal.Event {
  toMap() {
    return {
      ...this.toJson(),
      if (this.organizer != null) 'organizer': this.organizer?.toJson(),
      if (this.attachments != null) 'attachments': this.attachments?.map((e) => e.toJson()).toList(),
      if (this.attendees != null) 'attendees': this.attendees?.map((e) => e.toJson()).toList(),
      if (this.conferenceData != null) 'conferenceData': this.conferenceData?.toMap(),
      if (this.creator != null) 'creator': this.creator?.toJson(),
      if (this.end != null) 'end': this.end?.toJson(),
      if (this.extendedProperties != null) 'extendedProperties': this.extendedProperties?.toJson(),
      if (this.focusTimeProperties != null) 'focusTimeProperties': this.focusTimeProperties?.toJson(),
      if (this.gadget != null) 'gadget': this.gadget?.toJson(),
      if (this.organizer != null) 'organizer': this.organizer?.toJson(),
      if (this.originalStartTime != null) 'originalStartTime': this.originalStartTime?.toJson(),
      if (this.outOfOfficeProperties != null) 'outOfOfficeProperties': this.outOfOfficeProperties?.toJson(),
      if (this.reminders != null) 'reminders': this.reminders?.toMap(),
      if (this.source != null) 'source': this.source?.toJson(),
      if (this.start != null) 'start': this.start?.toJson(),
      if (this.workingLocationProperties != null) 'workingLocationProperties': this.workingLocationProperties?.toJson(),
    };
  }

  GCal.Event copyWith({
    bool? anyoneCanAddSelf,
    List<GCal.EventAttachment>? attachments,
    List<GCal.EventAttendee>? attendees,
    bool? attendeesOmitted,
    String? colorId,
    GCal.ConferenceData? conferenceData,
    bool? forceConferenceDataToNull,
    DateTime? created,
    GCal.EventCreator? creator,
    String? description,
    GCal.EventDateTime? end,
    bool? endTimeUnspecified,
    String? etag,
    String? eventType,
    GCal.EventExtendedProperties? extendedProperties,
    GCal.EventGadget? gadget,
    bool? guestsCanInviteOthers,
    bool? guestsCanModify,
    bool? guestsCanSeeOtherGuests,
    String? hangoutLink,
    String? htmlLink,
    String? iCalUID,
    String? id,
    String? kind,
    String? location,
    bool? locked,
    GCal.EventOrganizer? organizer,
    GCal.EventDateTime? originalStartTime,
    bool? privateCopy,
    List<String>? recurrence,
    String? recurringEventId,
    GCal.EventReminders? reminders,
    int? sequence,
    GCal.EventSource? source,
    GCal.EventDateTime? start,
    String? status,
    String? summary,
    String? transparency,
    DateTime? updated,
    String? visibility,
    GCal.EventWorkingLocationProperties? workingLocationProperties,
  }) {
    return GCal.Event(
      anyoneCanAddSelf: anyoneCanAddSelf ?? this.anyoneCanAddSelf,
      attachments: attachments ?? this.attachments,
      attendees: attendees ?? this.attendees,
      attendeesOmitted: attendeesOmitted ?? this.attendeesOmitted,
      colorId: colorId ?? this.colorId,
      conferenceData: (forceConferenceDataToNull ?? false) ? null : conferenceData ?? this.conferenceData,
      created: created ?? this.created,
      creator: creator ?? this.creator,
      description: description ?? this.description,
      end: end ?? this.end,
      endTimeUnspecified: endTimeUnspecified ?? this.endTimeUnspecified,
      etag: etag ?? this.etag,
      eventType: eventType ?? this.eventType,
      extendedProperties: extendedProperties ?? this.extendedProperties,
      gadget: gadget ?? this.gadget,
      guestsCanInviteOthers: guestsCanInviteOthers ?? this.guestsCanInviteOthers,
      guestsCanModify: guestsCanModify ?? this.guestsCanModify,
      guestsCanSeeOtherGuests: guestsCanSeeOtherGuests ?? this.guestsCanSeeOtherGuests,
      hangoutLink: hangoutLink ?? this.hangoutLink,
      htmlLink: htmlLink ?? this.htmlLink,
      iCalUID: iCalUID?.isEmpty == true ? null : iCalUID ?? this.iCalUID,
      id: id?.isEmpty == true ? null : id ?? this.id,
      kind: kind ?? this.kind,
      location: location ?? this.location,
      locked: locked ?? this.locked,
      organizer: organizer ?? this.organizer,
      originalStartTime: originalStartTime ?? this.originalStartTime,
      privateCopy: privateCopy ?? this.privateCopy,
      recurrence: recurrence?.isEmpty == true ? null : recurrence ?? this.recurrence,
      recurringEventId: recurringEventId?.isEmpty == true ? null : recurringEventId ?? this.recurringEventId,
      reminders: reminders ?? this.reminders,
      sequence: sequence ?? this.sequence,
      source: source ?? this.source,
      start: start ?? this.start,
      status: status ?? this.status,
      summary: summary ?? this.summary,
      transparency: transparency ?? this.transparency,
      updated: updated ?? this.updated,
      visibility: visibility ?? this.visibility,
      workingLocationProperties: workingLocationProperties ?? this.workingLocationProperties,
    );
  }
}

extension GcalConferenceDataX on GCal.ConferenceData {
  toMap() {
    return {
      ...this.toJson(),
      if (this.conferenceSolution != null) 'conferenceSolution': this.conferenceSolution?.toMap(),
      if (this.createRequest != null) 'createRequest': this.createRequest?.toMap(),
      if (this.entryPoints != null) 'entryPoints': this.entryPoints?.map((e) => e.toJson()).toList(),
      if (this.parameters != null) 'parameters': this.parameters?.toMap(),
    };
  }
}

extension GcalConferenceSolutionX on GCal.ConferenceSolution {
  toMap() {
    return {...this.toJson(), if (this.key != null) 'key': this.key?.toJson()};
  }
}

extension GcalCreateConferenceRequestX on GCal.CreateConferenceRequest {
  toMap() {
    return {
      ...this.toJson(),
      if (this.conferenceSolutionKey != null) 'conferenceSolutionKey': this.conferenceSolutionKey?.toJson(),
      if (this.status != null) 'status': this.status?.toJson(),
    };
  }
}

extension GcalConferenceParametersX on GCal.ConferenceParameters {
  toMap() {
    return {...this.toJson(), if (this.addOnParameters != null) 'addOnParameters': this.addOnParameters?.toJson()};
  }
}

extension GcalEventRemindersX on GCal.EventReminders {
  toMap() {
    return {...this.toJson(), if (this.overrides != null) 'overrides': this.overrides?.map((e) => e.toJson()).toList()};
  }
}
