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
import 'package:Visir/features/calendar/domain/entities/outlook_event_entity.dart';
import 'package:Visir/features/common/presentation/utils/microsoft_api_handler.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/preference/domain/entities/local_pref_entity.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:collection/collection.dart';
import 'package:googleapis/calendar/v3.dart' as GoogleCalendar;
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:http/http.dart' as http;
import 'package:microsoft_graph_api/models/calendar/calendar_model.dart';

class MicrosoftCalendarDatasource implements CalendarDatasource {
  MicrosoftCalendarDatasource();

  static List<String> scopes = ['openid', 'profile', 'offline_access', 'User.Read', 'Calendars.ReadWrite', 'Contacts.Read'];

  List<GoogleCalendar.Channel> channels = [];

  @override
  Future<OAuthEntity?> integrate() async {
    final oauth = await MicrosoftApiHandler.integrate(scopes, 'calendar');
    return oauth;
  }

  @override
  Future<Map<String, List<CalendarEntity>>> fetchCalendarLists({Map<String, http.Client>? clients, required OAuthEntity oauth}) async {
    Map<String, List<CalendarEntity>> calendars = {};
    try {
      final accessToken = await MicrosoftApiHandler.getToken(oauth: oauth, scope: scopes, isCalendar: true);

      final queryParams = {
        '\$select': 'canEdit,canShare,canViewPrivateItems,changeKey,color,hexColor,id,isDefaultCalendar,isRemovable,isTallyingResponses,name,owner',
      };

      final url = 'https://graph.microsoft.com/v1.0/me/calendars?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}';

      final calendarListRes = await http.get(Uri.parse(url), headers: {'Authorization': 'Bearer ${accessToken.data}', 'Content-Type': 'application/json'});

      final List<Calendar> calendarList = ((jsonDecode(calendarListRes.body)["value"] as List<dynamic>?) ?? [])
          .map<Calendar>((event) => Calendar.fromJson({...event, 'allowedOnlineMeetingProviders': [], 'defaultOnlineMeetingProvider': ''}))
          .toList();

      int defaultReminder = 15;

      try {
        final defaultReminderRes = await http.get(
          Uri.parse('https://graph.microsoft.com/v1.0/me/events?\$top=1&\$orderby=start/dateTime asc&\$select=reminderMinutesBeforeStart'),
          headers: {'Authorization': 'Bearer ${accessToken.data}', 'Content-Type': 'application/json'},
        );

        defaultReminder = jsonDecode(defaultReminderRes.body)['value'][0]['reminderMinutesBeforeStart'];
      } catch (e) {}

      final result = calendarList.map((e) {
        return CalendarEntity(
          id: e.id,
          name: e.name,
          backgroundColor: e.hexColor,
          foregroundColor: '',
          email: oauth.email,
          owned: e.owner.address == oauth.email,
          modifiable: e.canEdit,
          shareable: e.canShare,
          removable: e.isRemovable,
          type: CalendarEntityType.microsoft,
          defaultReminders: [EventReminderEntity(minutes: defaultReminder, method: 'app')],
        );
      }).toList();

      calendars[oauth.email] = result;
    } catch (e) {
      MicrosoftApiHandler.checkAuthNotWork(oauth, e.toString(), isCalendar: true);
      throw e;
    }

    return calendars;
  }

  Future<String?> getCalendarIdFromEventId({required OAuthEntity oauth, required String eventId}) async {
    try {
      final accessToken = await MicrosoftApiHandler.getToken(oauth: oauth, scope: scopes, isCalendar: true);
      final response = await http.get(
        Uri.parse('https://graph.microsoft.com/v1.0/me/events/${eventId}?\$expand=calendar'),
        headers: {'Authorization': 'Bearer ${accessToken.data}', 'Prefer': 'outlook.body-content-type="text"'},
      );

      final data = jsonDecode(response.body);
      return data['calendar']['id'];
    } catch (e) {}

    return null;
  }

  @override
  Future<CalendarEventResultEntity> fetchEventLists({
    required DateTime startDateTime,
    required DateTime endDateTime,
    required OAuthEntity oauth,
    required List<CalendarEntity> calendars,
    String? nextPageToken,
  }) async {
    final token = await MicrosoftApiHandler.getToken(oauth: oauth, scope: scopes, isCalendar: true);
    final events = await fetchEventsInOAuths(oauth, calendars, token, startDateTime, endDateTime, null);
    return CalendarEventResultEntity(events: groupBy(events, (e) => e.calendarId), pageTokens: {});
  }

  @override
  Future<List<EventEntity>> fetchEventsByIds({required OAuthEntity oauth, required CalendarEntity calendar, required List<String> eventIds}) async {
    if (eventIds.isEmpty) return [];
    final accessToken = await MicrosoftApiHandler.getToken(oauth: oauth, scope: scopes, isCalendar: true);
    final requests = eventIds.map((id) => {'id': id, 'method': 'GET', 'url': '/me/calendars/${calendar.id}/events/${id}'}).toList();
    final responses = await MicrosoftApiHandler.batchRequest(requests: requests, accessToken: accessToken);
    return responses
        .map((e) => e == null || e['status'] != 200 || e['body'] == null ? null : OutlookEventEntity.fromJson(e['body']))
        .whereType<OutlookEventEntity>()
        .map((ms) => EventEntity.fromMsEvent(msEvent: ms, calendar: calendar))
        .toList();
  }

  @override
  Future<CalendarEventResultEntity> searchEventLists({
    required String query,
    required OAuthEntity oauth,
    required List<CalendarEntity> calendars,
    Map<String, String?>? nextPageTokens,
  }) async {
    final token = await MicrosoftApiHandler.getToken(oauth: oauth, scope: scopes, isCalendar: true);
    final result = await searchEventsInOAuths(oauth, calendars, token, query, nextPageTokens);
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
    final token = await MicrosoftApiHandler.getToken(oauth: oauth, scope: scopes, isCalendar: true);

    try {
      final response = await http.get(
        Uri.parse(
          'https://graph.microsoft.com/v1.0/me/calendars/${calendar.id}/events/${recurringEventId}/instances?startDateTime=${startDateTime.toUtc().toIso8601String()}&endDateTime=${startDateTime.add(Duration(minutes: 1)).toUtc().toIso8601String()}',
        ),
        headers: {'Authorization': 'Bearer ${token.data}'},
      );

      final data = jsonDecode(response.body);
      final value = List.from(data['value']).firstOrNull;

      if (value == null) return null;

      return EventEntity.fromMsEvent(msEvent: OutlookEventEntity.fromJson(value), calendar: calendar);
    } catch (e) {
      MicrosoftApiHandler.checkAuthNotWork(oauth, e.toString(), isCalendar: true);
      throw e;
    }
  }

  Future<List<EventEntity>> lazyFetchEventsInCalendar({
    AccessToken? accessToken,
    required DateTime startDateTime,
    required DateTime endDateTime,
    required LocalPrefEntity pref,
    required CalendarEntity calendar,
    String? nextPageToken,
  }) async {
    final msOAuths = (pref.calendarOAuths ?? []).where((element) => element.type == OAuthType.microsoft).toList();
    if (accessToken == null) {
      Map<String, AccessToken> clients = {};
      final authResult = await Future.wait(msOAuths.map((e) => MicrosoftApiHandler.getToken(oauth: e, scope: scopes, isCalendar: true)));
      for (int i = 0; i < authResult.length; i++) {
        clients[msOAuths[i].email] = authResult[i];
      }

      accessToken = clients[calendar.email];
      final result = await fetchEventsInCalendar(
        msOAuths.where((o) => o.email == calendar.email).first,
        accessToken,
        calendar,
        startDateTime,
        endDateTime,
        nextPageToken,
        pref,
      );
      return result;
    } else {
      final result = await fetchEventsInCalendar(
        msOAuths.where((o) => o.email == calendar.email).first,
        accessToken,
        calendar,
        startDateTime,
        endDateTime,
        nextPageToken,
        pref,
      );
      return result;
    }
  }

  @override
  Future<EventEntity?> responseInvitation(EventEntity event, EventAttendeeEntity attendee, CalendarEntity? originalCalendar, OAuthEntity oauth) async {
    final token = await MicrosoftApiHandler.getToken(oauth: oauth, scope: scopes, isCalendar: true);

    try {
      final myStatus = attendee.responseStatus;

      final response = await http.post(
        Uri.parse('https://graph.microsoft.com/v1.0/me/calendars/${event.calendar.id}/events/${event.eventId}/${myStatus!.toMsApi}'),
        headers: {'Authorization': 'Bearer ${token.data}', 'Content-Type': 'application/json'},
        body: jsonEncode({'sendResponse': true}),
      );

      if (response.statusCode == 202) {
        return event;
      } else {
        throw Exception('Failed to response invitation');
      }
    } catch (e) {
      MicrosoftApiHandler.checkAuthNotWork(oauth, e.toString(), isCalendar: true);
      throw e;
    }
  }

  @override
  Future<EventEntity?> insertCalendar(EventEntity event, OAuthEntity oauth) async {
    final token = await MicrosoftApiHandler.getToken(oauth: oauth, scope: scopes, isCalendar: true);

    try {
      final response = await http.post(
        Uri.parse('https://graph.microsoft.com/v1.0/me/calendars/${event.calendar.id}/events'),
        headers: {'Authorization': 'Bearer ${token.data}', 'Content-Type': 'application/json'},
        body: jsonEncode(event.msEvent!.toCreateJson()),
      );

      return EventEntity.fromMsEvent(msEvent: OutlookEventEntity.fromJson(jsonDecode(response.body)), calendar: event.calendar);
    } catch (e) {
      MicrosoftApiHandler.checkAuthNotWork(oauth, e.toString(), isCalendar: true);
      throw e;
    }
  }

  @override
  Future<EventEntity?> updateCalendar(EventEntity event, List<String>? cancelledInstances, EventEntity? originalEvent, OAuthEntity oauth) async {
    final token = await MicrosoftApiHandler.getToken(oauth: oauth, scope: scopes, isCalendar: true);

    if (event.isCancelled) {
      await http.post(
        Uri.parse('https://graph.microsoft.com/v1.0/me/calendars/${event.calendar.id}/events/${event.eventId}/cancel'),
        headers: {'Authorization': 'Bearer ${token.data}', 'Content-Type': 'application/json'},
      );

      return event;
    }

    try {
      final response = await http.patch(
        Uri.parse('https://graph.microsoft.com/v1.0/me/calendars/${event.calendar.id}/events/${event.eventId}'),
        headers: {'Authorization': 'Bearer ${token.data}', 'Content-Type': 'application/json'},
        body: jsonEncode(event.msEvent!.toUpdateJson()),
      );

      return EventEntity.fromMsEvent(msEvent: OutlookEventEntity.fromJson(jsonDecode(response.body)), calendar: event.calendar);
    } catch (e) {
      MicrosoftApiHandler.checkAuthNotWork(oauth, e.toString(), isCalendar: true);
      throw e;
    }
  }

  @override
  Future<EventEntity?> deleteCalendar(EventEntity event, OAuthEntity oauth) async {
    final token = await MicrosoftApiHandler.getToken(oauth: oauth, scope: scopes, isCalendar: true);

    try {
      final response = await http.delete(
        Uri.parse('https://graph.microsoft.com/v1.0/me/calendars/${event.calendar.id}/events/${event.eventId}'),
        headers: {'Authorization': 'Bearer ${token.data}'},
      );

      if (response.statusCode != 204) {
        if (jsonDecode(response.body)['error']?['code'] != 'ErrorItemNotFound') {
          throw Exception('${response.statusCode} ${response.body}');
        }
      }

      return event;
    } catch (e) {
      MicrosoftApiHandler.checkAuthNotWork(oauth, e.toString(), isCalendar: true);
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

  Future<List<EventEntity>> fetchEventsInOAuths(
    OAuthEntity oauth,
    List<CalendarEntity> calendars,
    AccessToken? accessToken,
    DateTime startDateTime,
    DateTime endDateTime,
    Map<String, String?>? nextPageTokens,
  ) async {
    List<EventEntity> events = [];
    List<String> seriesMasterIds = [];
    final Map<String, CalendarEntity> seriesMasterIdToCalendar = {};
    final targetCalendarIds = calendars
        .where((e) => (nextPageTokens == null || nextPageTokens[e.id] != null) && e.type == oauth.type.calendarType && e.email == oauth.email)
        .map((e) => e.id)
        .toList();

    if (accessToken != null) {
      try {
        final queryParams = {
          '\$filter': 'start/dateTime lt \'${endDateTime.toUtc().toIso8601String()}\' and end/dateTime gt \'${startDateTime.toUtc().toIso8601String()}\'',
          '\$expand': 'calendar',
        };

        if (targetCalendarIds.isEmpty) return events;

        final eventBatchRes = await MicrosoftApiHandler.batchRequest(
          requests: targetCalendarIds
              .map(
                (e) => {
                  'id': e,
                  'method': 'GET',
                  'url': nextPageTokens?[e] ?? '/me/calendars/${e}/events?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}',
                  'headers': {'Prefer': 'outlook.body-content-type="text"'},
                },
              )
              .whereType<Map<String, dynamic>>()
              .toList(),
          accessToken: accessToken,
        );

        Map<String, String?>? newNextPageToken = {};
        eventBatchRes.forEach((e) {
          final calenarId = e['id'];
          final calendar = calendars.firstWhereOrNull((c) => c.id == calenarId);
          if (calendar == null) return;
          events.addAll(
            (e?['body']?['value'] ?? []).map((e) {
              try {
                if (e['type'] == 'seriesMaster') seriesMasterIds.add(e['id']);
                return EventEntity.fromMsEvent(msEvent: OutlookEventEntity.fromJson(e), calendar: calendar);
              } catch (e) {
                return null;
              }
            }).whereType<EventEntity>(),
          );
          newNextPageToken[calenarId] = e['body']['@odata.nextLink'];
        });

        // Discover series masters via calendarView occurrences within the range
        if (targetCalendarIds.isNotEmpty) {
          final calendarViewBatchRes = await MicrosoftApiHandler.batchRequest(
            requests: targetCalendarIds
                .map(
                  (calId) => {
                    'id': calId,
                    'method': 'GET',
                    'url':
                        '/me/calendars/${calId}/calendarView?startDateTime=${startDateTime.toUtc().toIso8601String()}&endDateTime=${endDateTime.toUtc().toIso8601String()}&\$select=id,seriesMasterId,type',
                    'headers': {'Prefer': 'outlook.body-content-type="text"'},
                  },
                )
                .toList(),
            accessToken: accessToken,
          );

          calendarViewBatchRes.forEach((resp) {
            final calenarId = resp['id'];
            final calendar = calendars.firstWhereOrNull((c) => c.id == calenarId);
            if (calendar == null) return;
            final values = (resp?['body']?['value'] ?? []) as List<dynamic>;
            for (final item in values) {
              final masterId = item['seriesMasterId'];

              if (masterId is String && masterId.isNotEmpty) {
                if (!seriesMasterIds.contains(masterId)) {
                  seriesMasterIds.add(masterId);
                }
                seriesMasterIdToCalendar[masterId] = calendar;
              }
            }
          });

          // Paginate calendarView to ensure all occurrences are considered
          final Map<String, String?> nextCalendarViewLinks = {};
          calendarViewBatchRes.forEach((resp) {
            final calenarId = resp['id'];
            final nextLink = resp?['body']?['@odata.nextLink'];
            if (nextLink != null) {
              nextCalendarViewLinks[calenarId] = (nextLink as String).replaceFirst('https://graph.microsoft.com/v1.0', '');
            }
          });

          while (nextCalendarViewLinks.values.any((e) => e != null)) {
            final moreViewRes = await MicrosoftApiHandler.batchRequest(
              requests: nextCalendarViewLinks.entries
                  .where((e) => e.value != null)
                  .map(
                    (entry) => {
                      'id': entry.key,
                      'method': 'GET',
                      'url': entry.value,
                      'headers': {'Prefer': 'outlook.body-content-type="text"'},
                    },
                  )
                  .toList(),
              accessToken: accessToken,
            );

            moreViewRes.forEach((resp) {
              final calenarId = resp['id'];
              final calendar = calendars.firstWhereOrNull((c) => c.id == calenarId);
              if (calendar == null) return;
              final values = (resp?['body']?['value'] ?? []) as List<dynamic>;
              for (final item in values) {
                final masterId = item['seriesMasterId'];
                if (masterId is String && masterId.isNotEmpty) {
                  if (!seriesMasterIds.contains(masterId)) {
                    seriesMasterIds.add(masterId);
                  }
                  seriesMasterIdToCalendar[masterId] = calendar;
                }
              }
              final nextLink = resp?['body']?['@odata.nextLink'];
              nextCalendarViewLinks[calenarId] = nextLink == null ? null : (nextLink as String).replaceFirst('https://graph.microsoft.com/v1.0', '');
            });
          }
        }

        final exceptionInstancesRes = await MicrosoftApiHandler.batchRequest(
          requests: seriesMasterIds
              .map(
                (e) => {
                  'id': e,
                  'method': 'GET',
                  'url':
                      '/me/events/${e}?\$select=allowNewTimeProposals,attendees,body,bodyPreview,cancelledOccurrences,categories,changeKey,createdDateTime,end,hasAttachments,hideAttendees,iCalUId,id,importance,isAllDay,isCancelled,isDraft,isOnlineMeeting,isOrganizer,isReminderOn,lastModifiedDateTime,location,locations,onlineMeeting,onlineMeetingProvider,onlineMeetingUrl,organizer,originalEndTimeZone,originalStart,originalStartTimeZone,recurrence,reminderMinutesBeforeStart,responseRequested,responseStatus,sensitivity,seriesMasterId,showAs,start,subject,transactionId,type,webLink,occurrenceId,exceptionOccurrences&\$expand=exceptionOccurrences&\$filter=start/dateTime lt \'${endDateTime.toUtc().toIso8601String()}\' and end/dateTime gt \'${startDateTime.toUtc().toIso8601String()}\'',
                },
              )
              .toList(),
          accessToken: accessToken,
        );

        // Ensure masters are present in events before flattening
        for (final resp in exceptionInstancesRes) {
          final masterId = resp['id'];
          final calendar = seriesMasterIdToCalendar[masterId];
          if (calendar == null) continue;
          final exists = events.any((evt) => evt.eventId == masterId);
          if (!exists) {
            try {
              final masterEntity = OutlookEventEntity.fromJson(resp['body']);
              events.add(EventEntity.fromMsEvent(msEvent: masterEntity, calendar: calendar));
            } catch (_) {}
          }
        }

        final exceptionInstances = exceptionInstancesRes.map((e) {
          return OutlookEventEntity.fromJson(e['body']);
        }).toList();

        events = events
            .map((e) {
              final exceptionOccurrence = exceptionInstances.firstWhereOrNull((element) => element.id == e.eventId);
              if (exceptionOccurrence != null) {
                return [
                  EventEntity.fromMsEvent(msEvent: exceptionOccurrence, calendar: e.calendar),
                  ...((exceptionOccurrence.exceptionOccurrences ?? []).map((o) {
                    return EventEntity.fromMsEvent(msEvent: OutlookEventEntity.fromJson(o.toJson()), calendar: e.calendar);
                  })),
                ];
              }

              return [e];
            })
            .expand((e) => e)
            .toList();

        if (newNextPageToken.values.any((e) => e != null)) {
          final lazyLoadingResult = await fetchEventsInOAuths(oauth, calendars, accessToken, startDateTime, endDateTime, newNextPageToken);
          events.addAll(lazyLoadingResult);
        }
      } catch (e) {
        Utils.reportAutoFeedback(errorMessage: 'fetchEventsInCalendar ${oauth.email}: / ${e.toString()}');
        MicrosoftApiHandler.checkAuthNotWork(oauth, e.toString(), isCalendar: true);
        throw e;
      }
    }
    return events;
  }

  Future<CalendarEventResultEntity> searchEventsInOAuths(
    OAuthEntity oauth,
    List<CalendarEntity> calendars,
    AccessToken? accessToken,
    String query,
    Map<String, String?>? nextPageTokens,
  ) async {
    List<EventEntity> events = [];
    List<String> seriesMasterIds = [];
    Map<String, String?>? newNextPageToken = {};
    final targetCalendarIds = calendars
        .where((e) => (nextPageTokens == null || nextPageTokens[e.id] != null) && e.type == oauth.type.calendarType && e.email == oauth.email)
        .map((e) => e.id)
        .toList();

    if (accessToken != null) {
      try {
        final queryParams = {'\$expand': 'calendar', '\$filter': 'contains(subject, \'${query}\')', '\$orderby': 'lastModifiedDateTime desc'};

        if (targetCalendarIds.isEmpty) return CalendarEventResultEntity(events: {}, pageTokens: {});

        final eventBatchRes = await MicrosoftApiHandler.batchRequest(
          requests: targetCalendarIds
              .map((e) {
                return {
                  'id': e,
                  'method': 'GET',
                  'url': nextPageTokens?[e] ?? '/me/calendars/${e}/events?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}',
                  'headers': {'Prefer': 'outlook.body-content-type="text"'},
                };
              })
              .whereType<Map<String, dynamic>>()
              .toList(),
          accessToken: accessToken,
        );

        eventBatchRes.forEach((e) {
          final calenarId = e['id'];
          final calendar = calendars.firstWhereOrNull((c) => c.id == calenarId);
          if (calendar == null) return;
          events.addAll(
            (e?['body']?['value'] ?? []).map((e) {
              try {
                if (e['type'] == 'seriesMaster') seriesMasterIds.add(e['id']);
                return EventEntity.fromMsEvent(msEvent: OutlookEventEntity.fromJson(e), calendar: calendar);
              } catch (e) {
                return null;
              }
            }).whereType<EventEntity>(),
          );
          newNextPageToken[calenarId] = e['body']['@odata.nextLink'];
        });

        final exceptionInstancesRes = await MicrosoftApiHandler.batchRequest(
          requests: seriesMasterIds
              .map(
                (e) => {
                  'id': e,
                  'method': 'GET',
                  'url':
                      '/me/events/${e}?\$select=allowNewTimeProposals,attendees,body,bodyPreview,cancelledOccurrences,categories,changeKey,createdDateTime,end,hasAttachments,hideAttendees,iCalUId,id,importance,isAllDay,isCancelled,isDraft,isOnlineMeeting,isOrganizer,isReminderOn,lastModifiedDateTime,location,locations,onlineMeeting,onlineMeetingProvider,onlineMeetingUrl,organizer,originalEndTimeZone,originalStart,originalStartTimeZone,recurrence,reminderMinutesBeforeStart,responseRequested,responseStatus,sensitivity,seriesMasterId,showAs,start,subject,transactionId,type,webLink,occurrenceId,exceptionOccurrences&\$expand=exceptionOccurrences',
                },
              )
              .toList(),
          accessToken: accessToken,
        );

        final exceptionInstances = exceptionInstancesRes.map((e) {
          return OutlookEventEntity.fromJson(e['body']);
        }).toList();

        events = events
            .map((e) {
              final exceptionOccurrence = exceptionInstances.firstWhereOrNull((element) => element.id == e.eventId);
              if (exceptionOccurrence != null) {
                return [
                  EventEntity.fromMsEvent(msEvent: exceptionOccurrence, calendar: e.calendar),
                  ...((exceptionOccurrence.exceptionOccurrences ?? []).map((o) {
                    return EventEntity.fromMsEvent(msEvent: OutlookEventEntity.fromJson(o.toJson()), calendar: e.calendar);
                  })),
                ];
              }

              return [e];
            })
            .expand((e) => e)
            .toList();
      } catch (e) {
        Utils.reportAutoFeedback(errorMessage: 'searchEventsInCalendar ${oauth.email}: / ${e.toString()}');
        MicrosoftApiHandler.checkAuthNotWork(oauth, e.toString(), isCalendar: true);
        throw e;
      }
    }
    return CalendarEventResultEntity(events: groupBy(events, (e) => e.calendarId), pageTokens: newNextPageToken);
  }

  Future<List<EventEntity>> fetchEventsInCalendar(
    OAuthEntity oauth,
    AccessToken? accessToken,
    CalendarEntity calendar,
    DateTime startDateTime,
    DateTime endDateTime,
    String? nextPageToken,
    LocalPrefEntity pref,
  ) async {
    List<EventEntity> events = [];
    List<String> seriesMasterIds = [];
    if (accessToken != null) {
      try {
        final queryParams = {
          '\$filter': 'start/dateTime lt \'${endDateTime.toUtc().toIso8601String()}\' and end/dateTime gt \'${startDateTime.toUtc().toIso8601String()}\'',
        };

        final url =
            nextPageToken ??
            'https://graph.microsoft.com/v1.0/me/calendars/${calendar.id}/events?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}';

        final eventRes = await http.get(Uri.parse(url), headers: {'Authorization': 'Bearer ${accessToken.data}', 'Prefer': 'outlook.body-content-type="text"'});

        final data = jsonDecode(eventRes.body);
        nextPageToken = data['@odata.nextLink'];

        events.addAll(
          (data['value'] ?? []).map((e) {
            try {
              if (e['type'] == 'seriesMaster') {
                seriesMasterIds.add(e['id']);
              }

              return EventEntity.fromMsEvent(msEvent: OutlookEventEntity.fromJson(e), calendar: calendar);
            } catch (e) {
              return null;
            }
          }).whereType<EventEntity>(),
        );

        final exceptionInstancesRes = await MicrosoftApiHandler.batchRequest(
          requests: seriesMasterIds
              .map(
                (e) => {
                  'id': e,
                  'method': 'GET',
                  'url':
                      '/me/events/${e}?\$select=allowNewTimeProposals,attendees,body,bodyPreview,cancelledOccurrences,categories,changeKey,createdDateTime,end,hasAttachments,hideAttendees,iCalUId,id,importance,isAllDay,isCancelled,isDraft,isOnlineMeeting,isOrganizer,isReminderOn,lastModifiedDateTime,location,locations,onlineMeeting,onlineMeetingProvider,onlineMeetingUrl,organizer,originalEndTimeZone,originalStart,originalStartTimeZone,recurrence,reminderMinutesBeforeStart,responseRequested,responseStatus,sensitivity,seriesMasterId,showAs,start,subject,transactionId,type,webLink,occurrenceId,exceptionOccurrences&\$expand=exceptionOccurrences&\$filter=start/dateTime lt \'${endDateTime.toUtc().toIso8601String()}\' and end/dateTime gt \'${startDateTime.toUtc().toIso8601String()}\'',
                },
              )
              .toList(),
          accessToken: accessToken,
        );

        final exceptionInstances = exceptionInstancesRes.map((e) {
          return OutlookEventEntity.fromJson(e['body']);
        }).toList();

        events = events
            .map((e) {
              final exceptionOccurrence = exceptionInstances.firstWhereOrNull((element) => element.id == e.eventId);
              if (exceptionOccurrence != null) {
                return [
                  EventEntity.fromMsEvent(msEvent: exceptionOccurrence, calendar: calendar),
                  ...((exceptionOccurrence.exceptionOccurrences ?? []).map((o) {
                    return EventEntity.fromMsEvent(msEvent: OutlookEventEntity.fromJson(o.toJson()), calendar: calendar);
                  })),
                ];
              }

              return [e];
            })
            .expand((e) => e)
            .toList();

        if (nextPageToken != null) {
          final lazyLoadingResult = await lazyFetchEventsInCalendar(
            accessToken: accessToken,
            calendar: calendar,
            startDateTime: startDateTime,
            endDateTime: endDateTime,
            pref: pref,
            nextPageToken: nextPageToken,
          );
          events.addAll(lazyLoadingResult);
        }
      } catch (e) {
        Utils.reportAutoFeedback(errorMessage: 'fetchEventsInCalendar ${oauth.email}: / ${e.toString()}');
        MicrosoftApiHandler.checkAuthNotWork(oauth, e.toString(), isCalendar: true);
        throw e;
      }
    }
    return events;
  }

  Future<void> watchEvents({required OAuthEntity oauth, required List<CalendarEntity> calendars, required UserEntity user}) async {
    final token = await MicrosoftApiHandler.getToken(oauth: oauth, scope: scopes, isCalendar: true);
    (await Future.wait(
      calendars.map((calendar) async {
        final value = await watchCalendar(oauth, token, calendar, user, '');
        return MapEntry(calendar.email, value);
      }),
    ));
  }

  Future<String?> watchCalendar(OAuthEntity oauth, AccessToken accessToken, CalendarEntity calendar, UserEntity user, String webhookUrl) async {
    try {
      final listResponse = await http.get(
        Uri.parse('https://graph.microsoft.com/v1.0/subscriptions'),
        headers: {'Authorization': 'Bearer ${accessToken.data}', 'Content-Type': 'application/json'},
      );

      final data = jsonDecode(listResponse.body);
      final subscriptions = List<Map<String, dynamic>>.from(data['value']);
      final targetResource = 'me/calendars/${calendar.id}/events';

      final filtered = subscriptions.where((s) => s['resource'] == targetResource).toList();

      List<dynamic> subscriptionIds = filtered
          .map(
            (e) => {
              'id': e['id'],
              'userId': jsonDecode(e['notificationQueryOptions'])['userId'],
              'calendarId': jsonDecode(e['notificationQueryOptions'])['calendarId'],
            },
          )
          .toList();

      final rightSubscriptionId = subscriptionIds.firstWhereOrNull((e) => e['userId'] == user.id && e['calendarId'] == calendar.id);

      if (subscriptionIds.isNotEmpty) {
        final removeSubscriptionIds = [...subscriptionIds]..removeWhere((e) => e['id'] == rightSubscriptionId?['id']);
        if (removeSubscriptionIds.isNotEmpty) {
          removeSubscriptionIds.forEach((e) async {
            await http.delete(Uri.parse('https://graph.microsoft.com/v1.0/subscriptions/${e['id']}'), headers: {'Authorization': 'Bearer ${accessToken.data}'});
          });
        }
      }

      if (rightSubscriptionId != null) {
        await http.patch(
          Uri.parse('https://graph.microsoft.com/v1.0/subscriptions/${rightSubscriptionId['id']}'),
          headers: {'Authorization': 'Bearer ${accessToken.data}'},
        );

        return rightSubscriptionId['id'];
      } else {
        final response = await http.post(
          Uri.parse('https://graph.microsoft.com/v1.0/subscriptions'),
          body: jsonEncode({
            "changeType": "created,updated,deleted",
            "notificationUrl": "https://handleoutlookcalendarnotification-37eiuas3wa-uc.a.run.app",
            "resource": targetResource,
            "expirationDateTime": DateTime.now().add(Duration(minutes: 10070)).toUtc().toIso8601String(),
            "notificationQueryOptions": jsonEncode({'userId': user.id, 'calendarId': calendar.id}),
            "clientState": user.id,
          }),
          headers: {'Authorization': 'Bearer ${accessToken.data}', 'Content-Type': 'application/json'},
        );

        final subscriptionId = json.decode(response.body)['id'];
        return subscriptionId;
      }
    } catch (e) {
      MicrosoftApiHandler.checkAuthNotWork(oauth, e.toString(), isCalendar: true);
      return null;
    }
  }

  Future<void> unwatchEvents({required OAuthEntity oauth, required List<CalendarEntity> calendars}) async {
    return;
    // final googleOAuths = (pref.calendarOAuths ?? []).where((element) => element.type == OAuthType.google).toList();
    // Map<String, http.Client> clients = {};
    // final authResult = await Future.wait(googleOAuths.map((e) => GoogleApiHandler.getClient(oauth: e, scope: scopes, isCalendar: true)));
    // for (int i = 0; i < authResult.length; i++) {
    //   clients[googleOAuths[i].email] = authResult[i];
    // }

    // calendars = calendars.unique((element) => element.uniqueId);
    // await Future.wait(calendars.map((calendar) => unwatchCalendar(clients, calendar)));
  }

  Future<void> unwatchCalendar(Map<String, http.Client> clients, CalendarEntity calendar) async {
    throw UnimplementedError();
    // final client = clients[calendar.email];
    // if (client != null) {
    //   channels.where((c) => c.token == calendar.id).forEach((element) async {
    //     try {
    //       // await GoogleCalendar.CalendarApi(client).channels.stop(element);
    //     } catch (e) {}
    //   });
    //   channels.removeWhere((c) => c.token == calendar.id);
    // }
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
