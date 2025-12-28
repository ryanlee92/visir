import 'package:Visir/features/auth/domain/entities/notification_entity.dart';
import 'package:Visir/features/auth/domain/entities/user_entity.dart';
import 'package:Visir/features/calendar/domain/datasources/calendar_datasource.dart';
import 'package:Visir/features/calendar/domain/entities/calendar_entity.dart';
import 'package:Visir/features/calendar/domain/entities/calendar_event_result_entity.dart';
import 'package:Visir/features/calendar/domain/entities/calendar_reminder_entity.dart';
import 'package:Visir/features/calendar/domain/entities/event_attendee_entity.dart';
import 'package:Visir/features/calendar/domain/entities/event_entity.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:http/src/client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseCalendarDatasource implements CalendarDatasource {
  SupabaseCalendarDatasource();

  SupabaseClient get client => Supabase.instance.client;

  String get calendarReminderDatabaseKey => 'calendar_reminder';

  @override
  Future<void> saveReminders({
    required String userId,
    required List<CalendarReminderEntity> reminders,
    required NotificationEntity notification,
    required bool isCalendar,
  }) async {
    if ((notification.linkedGoogleCalendars ?? []).isEmpty) return;

    final _saveReminders = () async {
      await client
          .from(calendarReminderDatabaseKey)
          .delete()
          .eq('user_id', userId)
          .inFilter(
            'calendar_id',
            isCalendar ? [...(notification.linkedGoogleCalendars ?? []), ...(notification.linkedOutlookMails ?? [])] : ['taskCalendarId'],
          );
      if (reminders.isEmpty) return;
      await client.from(calendarReminderDatabaseKey).upsert(reminders.map((e) => e.toJson()).toList());
    };

    EasyThrottle.throttle('save_reminders', const Duration(seconds: 1), _saveReminders, onAfter: _saveReminders);
  }

  @override
  void attachCalendarChangeListener({required OAuthEntity oauth, required UserEntity user, required List<CalendarEntity> calendars}) {}

  @override
  Future<EventEntity?> deleteCalendar(EventEntity event, OAuthEntity oauth) async {
    return null;
  }

  @override
  Future<void> detachCalendarChangeListener({required OAuthEntity oauth, required List<CalendarEntity> calendars}) async {}

  @override
  Future<Map<String, List<CalendarEntity>>> fetchCalendarLists({Map<String, Client>? clients, required OAuthEntity oauth}) async {
    return {};
  }

  @override
  Future<EventEntity?> getInstnace({
    Client? client,
    required DateTime startDateTime,
    required OAuthEntity oauth,
    required String recurringEventId,
    required CalendarEntity calendar,
  }) async {
    return null;
  }

  @override
  Future<EventEntity?> insertCalendar(EventEntity event, OAuthEntity oauth) async {
    return null;
  }

  @override
  Future<OAuthEntity?> integrate() async {
    return null;
  }

  @override
  Future<EventEntity?> responseInvitation(EventEntity event, EventAttendeeEntity attendee, CalendarEntity? originalCalendar, OAuthEntity oauth) async {
    return null;
  }

  @override
  Future<EventEntity?> updateCalendar(EventEntity event, List<String>? cancelledInstances, EventEntity? originalEvent, OAuthEntity oauth) async {
    return null;
  }

  @override
  Future<void> cacheCalendarLists({required Map<String, List<CalendarEntity>> calendars}) {
    throw UnimplementedError();
  }

  @override
  Future<void> cacheEventLists({required DateTime startDateTime, required DateTime endDateTime, required List<EventEntity> events}) {
    throw UnimplementedError();
  }

  @override
  Future<CalendarEventResultEntity> searchEventLists({
    required String query,
    required OAuthEntity oauth,
    required List<CalendarEntity> calendars,
    Map<String, String?>? nextPageTokens,
  }) async {
    return CalendarEventResultEntity(events: {}, pageTokens: {});
  }

  @override
  Future<CalendarEventResultEntity> fetchEventLists({
    required DateTime startDateTime,
    required DateTime endDateTime,
    required OAuthEntity oauth,
    required List<CalendarEntity> calendars,
    String? nextPageToken,
  }) async {
    return CalendarEventResultEntity(events: {}, pageTokens: {});
  }

  @override
  Future<List<EventEntity>> fetchEventsByIds({required OAuthEntity oauth, required CalendarEntity calendar, required List<String> eventIds}) {
    // TODO: implement fetchEventsByIds
    throw UnimplementedError();
  }
}
