import 'dart:convert';

import 'package:Visir/features/auth/domain/entities/notification_entity.dart';
import 'package:Visir/features/auth/domain/entities/user_entity.dart';
import 'package:Visir/features/calendar/domain/datasources/calendar_datasource.dart';
import 'package:Visir/features/calendar/domain/entities/calendar_entity.dart';
import 'package:Visir/features/calendar/domain/entities/calendar_event_result_entity.dart';
import 'package:Visir/features/calendar/domain/entities/calendar_reminder_entity.dart';
import 'package:Visir/features/calendar/domain/entities/event_attendee_entity.dart';
import 'package:Visir/features/calendar/domain/entities/event_entity.dart';
import 'package:Visir/features/calendar/domain/entities/event_reminder_entity.dart';
import 'package:Visir/features/common/infrastructure/entities/environment.dart';
import 'package:Visir/features/common/presentation/utils/extensions/list_extension.dart';
import 'package:Visir/features/common/presentation/utils/google_api_handler.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:Visir/flavors.dart';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/calendar/v3.dart' as GoogleCalendar;
import 'package:googleapis/people/v1.dart' as GooglePeople;
import 'package:http/http.dart' as http;

class GoogleCalendarDatasource implements CalendarDatasource {
  GoogleCalendarDatasource();

  static List<String> scopes = [
    GoogleCalendar.CalendarApi.calendarScope,
    GooglePeople.PeopleServiceApi.contactsOtherReadonlyScope,
    GooglePeople.PeopleServiceApi.userinfoProfileScope,
    GooglePeople.PeopleServiceApi.userinfoEmailScope,
  ];

  List<GoogleCalendar.Channel> channels = [];

  @override
  Future<OAuthEntity?> integrate() async {
    final oauth = await GoogleApiHandler.integrate(scopes, 'calendar');
    return oauth;
  }

  @override
  Future<Map<String, List<CalendarEntity>>> fetchCalendarLists({Map<String, http.Client>? clients, required OAuthEntity oauth}) async {
    Map<String, List<CalendarEntity>> calendars = {};

    final client = clients != null ? clients[oauth.email] : await GoogleApiHandler.getClient(oauth: oauth, scope: scopes, isCalendar: true);
    if (client != null) {
      try {
        final value = await GoogleCalendar.CalendarApi(client).calendarList.list();
        final result =
            value.items
                ?.map((e) {
                  if (e.id != null && e.backgroundColor != null && e.foregroundColor != null && e.summary != null) {
                    try {
                      return CalendarEntity(
                        id: e.id!,
                        name: e.summary!,
                        backgroundColor: e.backgroundColor!,
                        foregroundColor: e.foregroundColor!,
                        email: oauth.email,
                        owned: e.accessRole == "owner",
                        modifiable: e.accessRole == "owner" || e.accessRole == "writer",
                        shareable: e.accessRole == "owner" || e.accessRole == "writer",
                        removable: e.accessRole == "owner" || e.accessRole == "writer",
                        type: CalendarEntityType.google,
                        defaultReminders: e.defaultReminders?.map((e) => EventReminderEntityX.fromGoogleEntity(e)).toList(),
                      );
                    } catch (e) {
                      return null;
                    }
                  } else {
                    return null;
                  }
                })
                .whereType<CalendarEntity>()
                .toList() ??
            [];

        calendars[oauth.email] = result;
      } catch (e) {
        GoogleApiHandler.checkAuthNotWork(oauth, e.toString(), isCalendar: true);
        throw e;
      }
    }

    return calendars;
  }

  @override
  Future<CalendarEventResultEntity> fetchEventLists({
    required DateTime startDateTime,
    required DateTime endDateTime,
    required OAuthEntity oauth,
    required List<CalendarEntity> calendars,
    String? nextPageToken,
  }) async {
    final authResult = await GoogleApiHandler.getClient(oauth: oauth, scope: scopes, isCalendar: true);
    final events = await fetchEventsInOAuth(oauth, authResult, calendars, startDateTime, endDateTime, null);
    return CalendarEventResultEntity(events: groupBy(events, (e) => e.calendarId), pageTokens: {});
  }

  @override
  Future<List<EventEntity>> fetchEventsByIds({required OAuthEntity oauth, required CalendarEntity calendar, required List<String> eventIds}) async {
    if (eventIds.isEmpty) return [];
    final client = await GoogleApiHandler.getClient(oauth: oauth, scope: scopes, isCalendar: true);

    final batch = eventIds
        .map(
          (id) => BatchRequest(
            method: 'GET',
            path: '/calendar/v3/calendars/${Uri.encodeComponent(calendar.id)}/events/${Uri.encodeComponent(id)}',
            contentType: 'application/http',
            contentId: id,
          ),
        )
        .toList();

    final responses = await GoogleApiHandler.batchRequest('calendar/v3', batch, client);
    return responses
        .map((e) {
          try {
            return GoogleCalendar.Event.fromJson(e);
          } catch (_) {
            return null;
          }
        })
        .whereType<GoogleCalendar.Event>()
        .map((evt) => EventEntity.fromGoogleEvent(calendar: calendar, googleEvent: evt))
        .toList();
  }

  @override
  Future<CalendarEventResultEntity> searchEventLists({
    required String query,
    required OAuthEntity oauth,
    required List<CalendarEntity> calendars,
    Map<String, String?>? nextPageTokens,
  }) async {
    final client = await GoogleApiHandler.getClient(oauth: oauth, scope: scopes, isCalendar: true);
    final result = await searchEventsInOAuth(oauth, client, calendars, query, nextPageTokens);
    return result;
  }

  @override
  Future<EventEntity?> getInstnace({
    http.Client? client,
    required DateTime startDateTime,
    required OAuthEntity oauth,
    required String recurringEventId,
    required CalendarEntity calendar,
  }) async {
    final googleOAuths = [oauth];
    if (client == null) {
      client = await GoogleApiHandler.getClient(oauth: oauth, scope: scopes, isCalendar: true);

      try {
        GoogleCalendar.Events value = await GoogleCalendar.CalendarApi(
          client,
        ).events.instances(calendar.id, recurringEventId, timeMin: startDateTime, timeMax: startDateTime.add(Duration(minutes: 1)));

        return value.items?.isNotEmpty == true ? EventEntity.fromGoogleEvent(calendar: calendar, googleEvent: value.items!.first) : null;
      } catch (e) {
        GoogleApiHandler.checkAuthNotWork(googleOAuths.where((o) => o.email == calendar.email).first, e.toString(), isCalendar: true);
        throw e;
      }
    } else {
      try {
        GoogleCalendar.Events value = await GoogleCalendar.CalendarApi(
          client,
        ).events.instances(calendar.id, recurringEventId, timeMin: startDateTime, timeMax: startDateTime.add(Duration(minutes: 1)));

        return value.items?.isNotEmpty == true ? EventEntity.fromGoogleEvent(calendar: calendar, googleEvent: value.items!.first) : null;
      } catch (e) {
        GoogleApiHandler.checkAuthNotWork(googleOAuths.where((o) => o.email == calendar.email).first, e.toString(), isCalendar: true);
        throw e;
      }
    }
  }

  @override
  Future<EventEntity?> responseInvitation(EventEntity event, EventAttendeeEntity attendee, CalendarEntity? originalCalendar, OAuthEntity oauth) async {
    final client = await GoogleApiHandler.getClient(oauth: oauth, scope: scopes, isCalendar: true);

    try {
      GoogleCalendar.Event value = await GoogleCalendar.CalendarApi(client).events.patch(
        GoogleCalendar.Event(attendees: [attendee.toGoogleCalendarEventAttendee()]),
        originalCalendar?.id ?? event.calendarId,
        event.eventId,
        alwaysIncludeEmail: true,
        sendUpdates: "all",
        conferenceDataVersion: event.googleEvent?.conferenceData != null ? 1 : null,
      );

      if (event.calendarId != originalCalendar?.id && originalCalendar?.id != null) {
        value = await GoogleCalendar.CalendarApi(client).events.move(originalCalendar!.id, value.id!, event.calendarId);
      }

      return EventEntity.fromGoogleEvent(
        calendar: event.calendar,
        googleEvent: value.copyWith(start: event.googleEvent!.start, end: event.googleEvent!.end),
      );
    } catch (e) {
      GoogleApiHandler.checkAuthNotWork(oauth, e.toString(), isCalendar: true);
      throw e;
    }
  }

  @override
  Future<EventEntity?> insertCalendar(EventEntity event, OAuthEntity oauth) async {
    final client = await GoogleApiHandler.getClient(oauth: oauth, scope: scopes, isCalendar: true);

    try {
      GoogleCalendar.Event value = await GoogleCalendar.CalendarApi(
        client,
      ).events.insert(event.googleEvent!, event.calendarId, sendUpdates: "all", conferenceDataVersion: event.googleEvent?.conferenceData != null ? 1 : null);

      return EventEntity.fromGoogleEvent(
        calendar: event.calendar,
        googleEvent: value.copyWith(start: event.googleEvent!.start, end: event.googleEvent!.end),
      );
    } catch (e) {
      GoogleApiHandler.checkAuthNotWork(oauth, e.toString(), isCalendar: true);
      throw e;
    }
  }

  @override
  Future<EventEntity?> updateCalendar(EventEntity event, List<String>? cancelledInstances, EventEntity? originalEvent, OAuthEntity oauth) async {
    final client = await GoogleApiHandler.getClient(oauth: oauth, scope: scopes, isCalendar: true);

    final originalCalendar = originalEvent?.calendar;
    try {
      GoogleCalendar.Event value = await GoogleCalendar.CalendarApi(client).events.update(
        event.googleEvent!,
        originalCalendar?.id ?? event.calendarId,
        event.eventId,
        alwaysIncludeEmail: true,
        sendUpdates: "all",
        conferenceDataVersion: 1,
      );

      if (event.calendarId != originalCalendar?.id && originalCalendar?.id != null) {
        value = await GoogleCalendar.CalendarApi(client).events.move(originalCalendar!.id, value.id!, event.calendarId);
      }

      return EventEntity.fromGoogleEvent(
        calendar: event.calendar,
        googleEvent: value.copyWith(start: event.googleEvent!.start, end: event.googleEvent!.end),
      );
    } catch (e) {
      GoogleApiHandler.checkAuthNotWork(oauth, e.toString(), isCalendar: true);
      throw e;
    }
  }

  @override
  Future<EventEntity?> deleteCalendar(EventEntity event, OAuthEntity oauth) async {
    final client = await GoogleApiHandler.getClient(oauth: oauth, scope: scopes, isCalendar: true);
    try {
      await GoogleCalendar.CalendarApi(client).events.delete(event.calendarId, event.eventId, sendNotifications: true, sendUpdates: "all");

      return event;
    } catch (e) {
      GoogleApiHandler.checkAuthNotWork(oauth, e.toString(), isCalendar: true);
      throw e;
    }
  }

  void attachCalendarChangeListener({required OAuthEntity oauth, required UserEntity user, required List<CalendarEntity> calendars}) async {
    await detachCalendarChangeListener(oauth: oauth, calendars: calendars);
    watchEvents(oauth: oauth, user: user, calendars: calendars);
  }

  Future<void> detachCalendarChangeListener({required OAuthEntity oauth, required List<CalendarEntity> calendars}) async {
    await unwatchEvents(oauth: oauth, calendars: calendars);
  }

  Future<List<EventEntity>> fetchEventsInOAuth(
    OAuthEntity oauth,
    http.Client? client,
    List<CalendarEntity> calendars,
    DateTime startDateTime,
    DateTime endDateTime,
    Map<String, String?>? nextPageTokens,
  ) async {
    List<EventEntity> events = [];
    final targetCalendarIds = calendars
        .where((e) => (nextPageTokens == null || nextPageTokens[e.id] != null) && e.type == oauth.type.calendarType && e.email == oauth.email)
        .map((e) => e.id)
        .toList();

    if (targetCalendarIds.isEmpty) return events;

    if (client != null) {
      try {
        final maxResultCount = 250;
        final batchResult = await GoogleApiHandler.batchRequest(
          'calendar/v3',
          targetCalendarIds
              .map(
                (e) => BatchRequest(
                  method: 'GET',
                  path:
                      '/calendar/v3/calendars/$e/events?timeMin=${startDateTime.toUtc().toIso8601String()}&timeMax=${endDateTime.toUtc().toIso8601String()}&showHiddenInvitations=false&maxResults=${maxResultCount}${nextPageTokens?[e] != null ? '&pageToken=${nextPageTokens?[e]}' : ''}',
                  contentType: 'application/http',
                  contentId: e,
                  contentTransferEncoding: 'binary',
                ),
              )
              .toList(),
          client,
        );

        Map<String, String?> newNextPageTokens = {};
        batchResult.forEach((e) {
          final calendar = calendars.firstWhereOrNull(
            (c) => e['contentId']?.contains(c.id) == true && c.type == oauth.type.calendarType && c.email == oauth.email,
          );
          if (calendar != null) {
            final items = e['items'] ?? [];
            if (e['nextPageToken'] != null) newNextPageTokens[calendar.id] = e['nextPageToken'];
            events.addAll(
              items.map((e) {
                final googleEvent = GoogleCalendar.Event.fromJson(e);

                String? recurrence = googleEvent.recurrence?.where((e) => e.startsWith('RRULE:')).firstOrNull;
                try {
                  return EventEntity.fromGoogleEvent(
                    googleEvent: googleEvent.copyWith(
                      recurrence: recurrence == null
                          ? null
                          : [Utils.fromGoogleRRule(recurrence, googleEvent.start?.date?.toLocal() ?? googleEvent.start?.dateTime?.toLocal() ?? DateTime.now())],
                    ),
                    calendar: calendar,
                  );
                } catch (e) {
                  return null;
                }
              }).whereType<EventEntity>(),
            );
          }
        });

        if (newNextPageTokens.values.where((e) => e != null).isNotEmpty) {
          final lazyLoadingResult = await fetchEventsInOAuth(oauth, client, calendars, startDateTime, endDateTime, newNextPageTokens);

          events.addAll(lazyLoadingResult);
        }
      } catch (e) {
        Utils.reportAutoFeedback(errorMessage: 'fetchEventsInCalendar ${oauth.email}: / ${e.toString()}');
        GoogleApiHandler.checkAuthNotWork(oauth, e.toString(), isCalendar: true);
        throw e;
      }
    }

    return events;
  }

  Future<CalendarEventResultEntity> searchEventsInOAuth(
    OAuthEntity oauth,
    http.Client? client,
    List<CalendarEntity> calendars,
    String query,
    Map<String, String?>? nextPageTokens,
  ) async {
    List<EventEntity> events = [];
    Map<String, String?> newNextPageTokens = {};

    final targetCalendarIds = calendars
        .where((e) => (nextPageTokens == null || nextPageTokens[e.id] != null) && e.type == oauth.type.calendarType && e.email == oauth.email)
        .map((e) => e.id)
        .toList();

    if (targetCalendarIds.isEmpty) return CalendarEventResultEntity(events: {}, pageTokens: {});

    if (client != null) {
      try {
        final maxResultCount = 250;
        final batchResult = await GoogleApiHandler.batchRequest(
          'calendar/v3',
          targetCalendarIds
              .map(
                (e) => BatchRequest(
                  method: 'GET',
                  path:
                      '/calendar/v3/calendars/$e/events?orderBy=updated&q=${query}&showHiddenInvitations=false&maxResults=${maxResultCount}${nextPageTokens?[e] != null ? '&pageToken=${nextPageTokens?[e]}' : ''}',
                  contentType: 'application/http',
                  contentId: e,
                  contentTransferEncoding: 'binary',
                ),
              )
              .toList(),
          client,
        );

        batchResult.forEach((e) {
          final calendar = calendars.firstWhereOrNull(
            (c) => e['contentId']?.contains(c.id) == true && c.type == oauth.type.calendarType && c.email == oauth.email,
          );
          if (calendar != null) {
            final items = e['items'] ?? [];
            if (e['nextPageToken'] != null) newNextPageTokens[calendar.id] = e['nextPageToken'];
            events.addAll(
              items.map((e) {
                final googleEvent = GoogleCalendar.Event.fromJson(e);
                String? recurrence = googleEvent.recurrence?.where((e) => e.startsWith('RRULE:')).firstOrNull;
                try {
                  return EventEntity.fromGoogleEvent(
                    googleEvent: googleEvent.copyWith(
                      recurrence: recurrence == null
                          ? null
                          : [Utils.fromGoogleRRule(recurrence, googleEvent.start?.date?.toLocal() ?? googleEvent.start?.dateTime?.toLocal() ?? DateTime.now())],
                    ),
                    calendar: calendar,
                  );
                } catch (e) {
                  return null;
                }
              }).whereType<EventEntity>(),
            );
          }
        });
      } catch (e) {
        Utils.reportAutoFeedback(errorMessage: 'fetchEventsInCalendar ${oauth.email}: / ${e.toString()}');
        GoogleApiHandler.checkAuthNotWork(oauth, e.toString(), isCalendar: true);
        throw e;
      }
    }

    return CalendarEventResultEntity(events: groupBy(events, (e) => e.calendarId), pageTokens: newNextPageTokens);
  }

  Future<void> watchEvents({required OAuthEntity oauth, required List<CalendarEntity> calendars, required UserEntity user}) async {
    final client = await GoogleApiHandler.getClient(oauth: oauth, scope: scopes, isCalendar: true);

    final configFile = await rootBundle.loadString('assets/config/${F.envFileName}');
    final env = Environment.fromJson(json.decode(configFile) as Map<String, dynamic>);
    channels = (await Future.wait(
      calendars.map((calendar) {
        return watchCalendar(oauth, client, calendar, user, env.googleCalendarWebhookUrl);
      }),
    )).whereType<GoogleCalendar.Channel>().toList();
  }

  Future<GoogleCalendar.Channel?> watchCalendar(OAuthEntity oauth, http.Client client, CalendarEntity calendar, UserEntity user, String webhookUrl) async {
    try {
      RegExp regExp = new RegExp(r"[A-Za-z0-9\-_\+/=]+");
      final regCalendarId = regExp.allMatches(calendar.id).map((e) => e.group(0)).join('');
      GoogleCalendar.Channel value = await GoogleCalendar.CalendarApi(client).events.watch(
        GoogleCalendar.Channel(
          id: '${user.id.replaceAll('-', '_')}_$regCalendarId',
          type: "web_hook",
          address: webhookUrl,
          token: calendar.id,
          expiration: DateTime.now().add(Duration(days: 30)).millisecondsSinceEpoch.toString(),
        ),
        calendar.id,
      );
      return value;
    } catch (e) {
      GoogleApiHandler.checkAuthNotWork(oauth, e.toString(), isCalendar: true);
    }
    return null;
  }

  Future<void> unwatchEvents({required OAuthEntity oauth, required List<CalendarEntity> calendars}) async {
    final client = await GoogleApiHandler.getClient(oauth: oauth, scope: scopes, isCalendar: true);
    calendars = calendars.unique((element) => element.uniqueId);
    await Future.wait(calendars.map((calendar) => unwatchCalendar(client, calendar)));
  }

  Future<void> unwatchCalendar(http.Client client, CalendarEntity calendar) async {
    channels.where((c) => c.token == calendar.id).forEach((element) async {
      try {
        // await GoogleCalendar.CalendarApi(client).channels.stop(element);
      } catch (e) {}
    });
    channels.removeWhere((c) => c.token == calendar.id);
  }

  @override
  Future<void> saveReminders({
    required String userId,
    required List<CalendarReminderEntity> reminders,
    required NotificationEntity notification,
    required bool isCalendar,
  }) async {
    // only for supabase
  }

  @override
  Future<void> cacheCalendarLists({required Map<String, List<CalendarEntity>> calendars}) {
    throw UnimplementedError();
  }

  @override
  Future<void> cacheEventLists({required DateTime startDateTime, required DateTime endDateTime, required List<EventEntity> events}) {
    throw UnimplementedError();
  }
}
