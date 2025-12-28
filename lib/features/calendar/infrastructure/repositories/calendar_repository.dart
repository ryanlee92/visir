import 'dart:async';

import 'package:Visir/config/providers.dart';
import 'package:Visir/features/auth/domain/entities/notification_entity.dart';
import 'package:Visir/features/auth/domain/entities/user_entity.dart';
import 'package:Visir/features/calendar/domain/datasources/calendar_datasource.dart';
import 'package:Visir/features/calendar/domain/entities/calendar_entity.dart';
import 'package:Visir/features/calendar/domain/entities/calendar_event_result_entity.dart';
import 'package:Visir/features/calendar/domain/entities/calendar_reminder_entity.dart';
import 'package:Visir/features/calendar/domain/entities/event_attendee_entity.dart';
import 'package:Visir/features/calendar/domain/entities/event_entity.dart';
import 'package:Visir/features/common/domain/failures/failure.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:fpdart/src/either.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CalendarRepository {
  final Map<DatasourceType, CalendarDatasource> datasources;

  CalendarRepository({required this.datasources});

  Future<void> sendTaskOrEventChangeFcm({required EventEntity event, required String action}) async {
    await proxyCall(
      oauth: null,
      headers: {},
      files: null,
      method: 'POST',
      url: sendTaskOrEventChangeFcmFunctionUrl,
      body: {'userId': Supabase.instance.client.auth.currentUser?.id, 'data': event.toJson(), 'type': 'event', 'action': action},
    );
  }

  Future<Either<Failure, OAuthEntity>> integrate({required OAuthType type}) async {
    try {
      final oauth = await datasources[type.datasourceType]?.integrate();
      return right(oauth!);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, Map<String, List<CalendarEntity>>>> fetchCalendarLists({required OAuthEntity oauth}) async {
    try {
      final result = await datasources[oauth.type.datasourceType]?.fetchCalendarLists(oauth: oauth);
      return right(result!);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, CalendarEventResultEntity>> fetchEventLists({
    required DateTime startDateTime,
    required DateTime endDateTime,
    required OAuthEntity oauth,
    required List<CalendarEntity> calendars,
  }) async {
    try {
      final result = await datasources[oauth.type.datasourceType]?.fetchEventLists(
        startDateTime: startDateTime,
        endDateTime: endDateTime,
        oauth: oauth,
        calendars: calendars.where((e) => oauth.email == e.email && e.type?.datasourceType == oauth.type.datasourceType).toList(),
      );
      return right(result!);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, List<EventEntity>>> fetchEventsByIds({
    required OAuthEntity oauth,
    required CalendarEntity calendar,
    required List<String> eventIds,
  }) async {
    try {
      final ds = datasources[oauth.type.datasourceType];
      final list = await ds?.fetchEventsByIds(oauth: oauth, calendar: calendar, eventIds: eventIds) ?? [];
      return right(list);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, CalendarEventResultEntity>> searchEventLists({
    required String query,
    required OAuthEntity oauth,
    required List<CalendarEntity> calendars,
    Map<String, String?>? nextPageTokens,
  }) async {
    try {
      final result = await datasources[oauth.type.datasourceType]?.searchEventLists(
        query: query,
        oauth: oauth,
        calendars: calendars,
        nextPageTokens: nextPageTokens,
      );
      return right(result!);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, EventEntity?>> responseInvitation(
    EventEntity event,
    EventAttendeeEntity attendee,
    CalendarEntity? originalCalendar,
    OAuthEntity oauth,
  ) async {
    try {
      final result = await datasources[event.datasourceType]?.responseInvitation(event, attendee, originalCalendar, oauth);
      return right(result);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, EventEntity?>> insertCalendar(EventEntity event, OAuthEntity oauth) async {
    try {
      final result = await datasources[event.datasourceType]?.insertCalendar(event, oauth);
      sendTaskOrEventChangeFcm(event: event, action: 'insert');
      return right(result);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, EventEntity?>> updateCalendar(
    EventEntity event,
    List<String>? cancelledInstances,
    EventEntity? originalEvent,
    OAuthEntity oauth,
  ) async {
    try {
      if (originalEvent != null && originalEvent.calendar.id != event.calendar.id) {
        await datasources[originalEvent.datasourceType]?.deleteCalendar(originalEvent, oauth);
        final result = await datasources[event.datasourceType]?.insertCalendar(event.copyWith(id: Utils.generateBase32HexStringFromTimestamp()), oauth);
        sendTaskOrEventChangeFcm(event: event, action: 'update');
        return right(result);
      }

      final result = await datasources[event.datasourceType]?.updateCalendar(event, cancelledInstances, originalEvent, oauth);
      sendTaskOrEventChangeFcm(event: event, action: 'update');
      return right(result);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, EventEntity?>> deleteCalendar(EventEntity event, OAuthEntity oauth) async {
    try {
      final result = await datasources[event.datasourceType]?.deleteCalendar(event, oauth);
      sendTaskOrEventChangeFcm(event: event, action: 'delete');
      return right(result);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, EventEntity?>> getInstnace({required DateTime startDateTime, required OAuthEntity oauth, required EventEntity event}) async {
    try {
      final result = await datasources[event.datasourceType]?.getInstnace(
        startDateTime: startDateTime,
        oauth: oauth,
        calendar: event.calendar,
        recurringEventId: event.recurringEventId ?? event.eventId,
      );
      return right(result);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, bool>> saveReminders({
    required String userId,
    required List<CalendarReminderEntity> reminders,
    required NotificationEntity notification,
    required bool isCalendar,
  }) async {
    try {
      await datasources[DatasourceType.supabase]?.saveReminders(userId: userId, reminders: reminders, notification: notification, isCalendar: isCalendar);
      return right(true);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  void attachCalendarChangeListener({required UserEntity user, required OAuthEntity oauth, required List<CalendarEntity> calendars}) {
    datasources[oauth.type.datasourceType]?.attachCalendarChangeListener(user: user, oauth: oauth, calendars: calendars);
  }

  Future<void> detachCalendarChangeListener({required OAuthEntity oauth, required List<CalendarEntity> calendars}) async {
    await datasources[oauth.type.datasourceType]?.detachCalendarChangeListener(oauth: oauth, calendars: calendars);
  }
}
