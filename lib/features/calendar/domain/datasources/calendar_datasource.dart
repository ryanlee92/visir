import 'dart:async';

import 'package:Visir/features/auth/domain/entities/notification_entity.dart';
import 'package:Visir/features/auth/domain/entities/user_entity.dart';
import 'package:Visir/features/calendar/domain/entities/calendar_entity.dart';
import 'package:Visir/features/calendar/domain/entities/calendar_event_result_entity.dart';
import 'package:Visir/features/calendar/domain/entities/calendar_reminder_entity.dart';
import 'package:Visir/features/calendar/domain/entities/event_attendee_entity.dart';
import 'package:Visir/features/calendar/domain/entities/event_entity.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:http/http.dart' as http;

abstract class CalendarDatasource {
  Future<OAuthEntity?> integrate();

  Future<void> cacheCalendarLists({required Map<String, List<CalendarEntity>> calendars});

  Future<void> cacheEventLists({required DateTime startDateTime, required DateTime endDateTime, required List<EventEntity> events});

  Future<Map<String, List<CalendarEntity>>> fetchCalendarLists({Map<String, http.Client>? clients, required OAuthEntity oauth});

  Future<CalendarEventResultEntity> fetchEventLists({
    required DateTime startDateTime,
    required DateTime endDateTime,
    required OAuthEntity oauth,
    required List<CalendarEntity> calendars,
    String? nextPageToken,
  });

  Future<CalendarEventResultEntity> searchEventLists({
    required String query,
    required OAuthEntity oauth,
    required List<CalendarEntity> calendars,
    Map<String, String?>? nextPageTokens,
  });

  Future<EventEntity?> responseInvitation(EventEntity event, EventAttendeeEntity attendee, CalendarEntity? originalCalendar, OAuthEntity oauth);

  Future<EventEntity?> insertCalendar(EventEntity event, OAuthEntity oauth);

  Future<EventEntity?> updateCalendar(EventEntity event, List<String>? cancelledInstances, EventEntity? originalEvent, OAuthEntity oauth);

  Future<EventEntity?> deleteCalendar(EventEntity event, OAuthEntity oauth);

  Future<EventEntity?> getInstnace({
    http.Client? client,
    required DateTime startDateTime,
    required OAuthEntity oauth,
    required String recurringEventId,
    required CalendarEntity calendar,
  });

  Future<void> saveReminders({
    required String userId,
    required List<CalendarReminderEntity> reminders,
    required NotificationEntity notification,
    required bool isCalendar,
  });

  void attachCalendarChangeListener({required OAuthEntity oauth, required UserEntity user, required List<CalendarEntity> calendars});

  Future<void> detachCalendarChangeListener({required OAuthEntity oauth, required List<CalendarEntity> calendars});

  Future<List<EventEntity>> fetchEventsByIds({required OAuthEntity oauth, required CalendarEntity calendar, required List<String> eventIds});
}
