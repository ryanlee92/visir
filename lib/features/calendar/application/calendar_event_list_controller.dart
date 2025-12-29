import 'dart:async';
import 'dart:convert';

import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/rrule/rrule.dart';
import 'package:Visir/dependency/rrule/src/utils.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/auth/domain/entities/notification_entity.dart';
import 'package:Visir/features/auth/providers.dart';
import 'package:Visir/features/calendar/application/calendar_list_controller.dart';
import 'package:Visir/features/calendar/domain/entities/calendar_entity.dart';
import 'package:Visir/features/calendar/domain/entities/calendar_reminder_entity.dart';
import 'package:Visir/features/calendar/domain/entities/event_attendee_entity.dart';
import 'package:Visir/features/calendar/domain/entities/event_entity.dart';
import 'package:Visir/features/calendar/domain/entities/outlook_event_entity.dart';
import 'package:Visir/features/calendar/infrastructure/repositories/calendar_repository.dart';
import 'package:Visir/features/calendar/providers.dart';
import 'package:Visir/features/common/domain/failures/failure.dart';
import 'package:Visir/features/common/infrastructure/entities/environment.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/color_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/date_time_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/list_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:Visir/flavors.dart';
import 'package:collection/collection.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/experimental/persist.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis/calendar/v3.dart' hide Colors;
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time/time.dart';

part 'calendar_event_list_controller.g.dart';

const Duration kLocalUpdateGracePeriod = Duration(seconds: 10);

extension DateTimeNumber on DateTime {
  int toNumber() => int.parse(DateFormat('yyyyMM').format(this));
}

enum RecurringEventEditType { single, thisEventOnly, thisAndFutureEvents, allEvents }

extension RecurringEventEditTypeX on RecurringEventEditType {
  String getTitle(BuildContext context) {
    switch (this) {
      case RecurringEventEditType.single:
        return '';
      case RecurringEventEditType.thisEventOnly:
        return context.tr.this_event_only;
      case RecurringEventEditType.thisAndFutureEvents:
        return context.tr.this_and_following_events;
      case RecurringEventEditType.allEvents:
        return context.tr.all_events;
    }
  }
}

@riverpod
class CalendarEventListController extends _$CalendarEventListController {
  static String stringKey(TabType tabType) => '${tabType.name}:calendar:events';
  late List<OAuthEntity> calendarOAuths;
  Map<String, Map<String, CalendarEventListControllerInternal>> _controllers = {};

  List<String> loadedMonth = [];

  @override
  CalendarEventResultEntity build({required TabType tabType, CalendarDisplayType displayType = CalendarDisplayType.main}) {
    final isSignedIn = ref.watch(authControllerProvider.select((v) => v.requireValue.isSignedIn));
    if (ref.watch(shouldUseMockDataProvider)) {
      getMockEvents().then((v) {
        final targetMonth = ref.read(calendarDisplayDateProvider(tabType).select((v) => v[displayType] ?? DateTime.now()));
        final targetDate = DateTime(targetMonth.year, targetMonth.month);
        final startDateTime = targetDate.subtract(Duration(days: targetDate.weekday % 7 + 1));
        final endDateTime = targetDate.add(Duration(days: 43 - targetDate.weekday % 7));
        updateState(events: v, startDateTime: startDateTime, endDateTime: endDateTime);
      });
      final targetMonth = ref.read(calendarDisplayDateProvider(tabType).select((v) => v[displayType] ?? DateTime.now()));
      final targetDate = DateTime(targetMonth.year, targetMonth.month);
      final startDateTime = targetDate.subtract(Duration(days: targetDate.weekday % 7 + 1));
      final endDateTime = targetDate.add(Duration(days: 43 - targetDate.weekday % 7));
      return CalendarEventResultEntity(events: [], startDateTime: startDateTime, endDateTime: endDateTime);
    }

    ref.watch(localPrefControllerProvider.select((v) => v.value?.calendarOAuths?.map((e) => e.uniqueId).toList()));
    ref.watch(calendarDisplayDateProvider(tabType).select((v) => DateFormat.yM().format(v[displayType] ?? DateTime.now())));
    final targetMonth = ref.read(calendarDisplayDateProvider(tabType).select((v) => v[displayType] ?? DateTime.now()));
    final prevMonth = DateTime(targetMonth.year, targetMonth.month - 1);
    final nextMonth = DateTime(targetMonth.year, targetMonth.month + 1);

    final newLoadedMonth = [DateFormat.yM().format(targetMonth), DateFormat.yM().format(prevMonth), DateFormat.yM().format(nextMonth)];
    final requireLoadMonth = newLoadedMonth.where((e) => !loadedMonth.contains(e)).toList();
    loadedMonth = newLoadedMonth;

    _controllers.clear();

    final targetDate = DateTime(targetMonth.year, targetMonth.month);
    final startDateTime = targetDate.subtract(Duration(days: targetDate.weekday % 7 + 1));
    final endDateTime = targetDate.add(Duration(days: 43 - targetDate.weekday % 7));

    // Initialize state with empty result
    state = CalendarEventResultEntity(events: [], startDateTime: startDateTime, endDateTime: endDateTime);

    void _updateFromInternalControllers() {
      final allEvents = <EventEntity>[];
      _controllers.forEach((oauthUniqueId, oauthControllers) {
        oauthControllers.forEach((monthKey, controller) {
          // Parse monthKey (format: "yyyy MMM" or similar)
          try {
            final parsedDate = DateFormat.yM().parse(monthKey);
            final controllerState = ref.read(
              calendarEventListControllerInternalProvider(isSignedIn: isSignedIn, oAuthUniqueId: oauthUniqueId, targetYear: parsedDate.year, targetMonth: parsedDate.month),
            );
            final events = controllerState.value ?? <EventEntity>[];
            allEvents.addAll(events);
          } catch (e) {
            // If parsing fails, skip this controller
          }
        });
      });

      final uniqueEvents = allEvents.unique((e) => e.uniqueId);
      updateState(events: uniqueEvents, startDateTime: startDateTime, endDateTime: endDateTime);
    }

    calendarOAuths = ref.read(localPrefControllerProvider.select((v) => v.value?.calendarOAuths ?? []));
    calendarOAuths.forEach((e) {
      _controllers[e.uniqueId] = {
        DateFormat.yM().format(targetMonth): ref.watch(
          calendarEventListControllerInternalProvider(isSignedIn: isSignedIn, oAuthUniqueId: e.uniqueId, targetYear: targetMonth.year, targetMonth: targetMonth.month).notifier,
        ),
        DateFormat.yM().format(prevMonth): ref.watch(
          calendarEventListControllerInternalProvider(isSignedIn: isSignedIn, oAuthUniqueId: e.uniqueId, targetYear: prevMonth.year, targetMonth: prevMonth.month).notifier,
        ),
        DateFormat.yM().format(nextMonth): ref.watch(
          calendarEventListControllerInternalProvider(isSignedIn: isSignedIn, oAuthUniqueId: e.uniqueId, targetYear: nextMonth.year, targetMonth: nextMonth.month).notifier,
        ),
      };

      ref.listen(calendarEventListControllerInternalProvider(isSignedIn: isSignedIn, oAuthUniqueId: e.uniqueId, targetYear: targetMonth.year, targetMonth: targetMonth.month), (
        prev,
        next,
      ) {
        _updateFromInternalControllers();
      });
      ref.listen(calendarEventListControllerInternalProvider(isSignedIn: isSignedIn, oAuthUniqueId: e.uniqueId, targetYear: prevMonth.year, targetMonth: prevMonth.month), (
        prev,
        next,
      ) {
        _updateFromInternalControllers();
      });
      ref.listen(calendarEventListControllerInternalProvider(isSignedIn: isSignedIn, oAuthUniqueId: e.uniqueId, targetYear: nextMonth.year, targetMonth: nextMonth.month), (
        prev,
        next,
      ) {
        _updateFromInternalControllers();
      });
    });

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      if (!(tabType == TabType.home && PlatformX.isDesktopView) && tabType != TabType.calendar) return;
      refresh(requireLoadMonth: requireLoadMonth);
    });

    _updateFromInternalControllers();
    return state;
  }

  Timer? timer;
  void updateState({required List<EventEntity> events, required DateTime startDateTime, required DateTime endDateTime}) {
    final previousResult = state;
    final result = CalendarEventResultEntity(
      events: events,
      startDateTime: startDateTime,
      endDateTime: endDateTime,
      previousEventsOnView: previousResult.eventsOnView,
      previousFetchedUntil: previousResult.fetchedUntil,
      previousEvents: previousResult.events,
      previousCachedRecurrenceInstances: previousResult.cachedRecurrenceInstances,
    );
    if (timer == null) state = result;
    timer?.cancel();
    timer = Timer(const Duration(milliseconds: kControllerDebouncMillisecond), () {
      state = result;
      timer = null;
    });
  }

  Future<void> refresh({bool? showLoading, bool? isChunkUpdate, List<String>? requireLoadMonth}) async {
    if (ref.read(shouldUseMockDataProvider)) return;

    Completer<void> completer = Completer();
    int resultCount = 0;
    ref.read(loadingStatusProvider.notifier).update(stringKey(tabType), LoadingState.loading);
    final controllerLength = _controllers.entries.expand((e) => e.value.entries.where((e) => requireLoadMonth?.contains(e.key) ?? true)).length;

    // OAuth가 없으면 즉시 success로 완료
    if (controllerLength == 0) {
      ref.read(loadingStatusProvider.notifier).update(stringKey(tabType), LoadingState.success);
      completer.complete();
      return completer.future;
    }

    _controllers.forEach((key, value) {
      value.entries.where((e) => requireLoadMonth?.contains(e.key) ?? true).forEach((e) {
        e.value
            .refresh()
            .then((_) {
              resultCount++;
              if (resultCount != controllerLength) return;
              ref.read(loadingStatusProvider.notifier).update(stringKey(tabType), LoadingState.success);
              completer.complete();
            })
            .catchError((error) {
              resultCount++;
              if (resultCount != controllerLength) return;
              ref.read(loadingStatusProvider.notifier).update(stringKey(tabType), LoadingState.error);
              completer.complete();
            });
      });
    });

    return completer.future;
  }

  Future<void> load({bool? showLoading, bool? isChunkUpdate}) async {
    if (ref.read(shouldUseMockDataProvider)) return;

    Completer<void> completer = Completer();
    int resultCount = 0;
    ref.read(loadingStatusProvider.notifier).update(stringKey(tabType), LoadingState.loading);
    final controllerLength = _controllers.entries.expand((e) => e.value.entries).length;

    // OAuth가 없으면 즉시 success로 완료
    if (controllerLength == 0) {
      ref.read(loadingStatusProvider.notifier).update(stringKey(tabType), LoadingState.success);
      completer.complete();
      return completer.future;
    }

    _controllers.forEach((key, value) {
      value.entries.forEach((e) {
        e.value
            .load(showLoading: showLoading, isChunkUpdate: isChunkUpdate)
            .then((_) {
              resultCount++;
              if (resultCount != controllerLength) return;
              ref.read(loadingStatusProvider.notifier).update(stringKey(tabType), LoadingState.success);
              completer.complete();
            })
            .catchError((error) {
              resultCount++;
              if (resultCount != controllerLength) return;
              ref.read(loadingStatusProvider.notifier).update(stringKey(tabType), LoadingState.error);
              completer.complete();
            });
      });
    });

    return completer.future;
  }

  Future<RecurringEventEditType?> editCalendarEvent({
    required BuildContext context,
    required EventEntity? originalEvent,
    required EventEntity? newEvent,
    required DateTime selectedEndDate,
    required DateTime selectedStartDate,
    required bool isCreate,
    required TabType? targetTab,
    RecurringEventEditType? recurringType,
  }) async {
    if (ref.read(shouldUseMockDataProvider)) {
      if (newEvent == null) return null;
      state = CalendarEventResultEntity(events: [...(state.events), newEvent], startDateTime: state.startDateTime, endDateTime: state.endDateTime);
      return RecurringEventEditType.single;
    }

    Completer<RecurringEventEditType?> completer = Completer();
    int resultCount = 0;
    final originalOAuth = calendarOAuths.firstWhereOrNull((e) => e.email == originalEvent?.calendar.email);
    final newOAuth = calendarOAuths.firstWhereOrNull((e) => e.email == newEvent?.calendar.email);

    RecurringEventEditType? result;

    if (originalEvent?.recurrence != null || originalEvent?.recurringEventId != null) {
      if (originalEvent?.recurringEventId != null) {
        recurringType = RecurringEventEditType.thisEventOnly;
      } else if (newEvent != null && newEvent.calendarId != originalEvent?.calendarId) {
        recurringType = RecurringEventEditType.allEvents;
      } else {
        if (recurringType == null) {
          await Future.delayed(Duration(milliseconds: 300), () {});
          final type = await Utils.showRecurrenceEditConfirmPopup(isTask: false);
          if (type == null) return null;
          if (Navigator.canPop(context)) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
          recurringType = type;
        }
      }
    }

    if (originalOAuth?.uniqueId != newOAuth?.uniqueId) {
      _controllers[originalOAuth?.uniqueId]?.entries.forEachIndexed((index, e) {
        e.value
            .editCalendarEvent(
              context: context,
              originalEvent: originalEvent,
              newEvent: null,
              selectedEndDate: selectedEndDate,
              selectedStartDate: selectedStartDate,
              isCreate: isCreate,
              targetTab: targetTab,
              tabType: tabType,
              recurringType: recurringType,
            )
            .then((e) {
              resultCount++;
              if (resultCount != 2) return;
              completer.complete(result);
            })
            .catchError((error) {
              resultCount++;
              if (resultCount != 2) return;
              completer.complete(result);
            });
      });

      _controllers[newOAuth?.uniqueId]?.entries.forEachIndexed((index, e) {
        e.value
            .editCalendarEvent(
              context: context,
              originalEvent: null,
              newEvent: newEvent,
              selectedEndDate: selectedEndDate,
              selectedStartDate: selectedStartDate,
              isCreate: isCreate,
              targetTab: targetTab,
              tabType: tabType,
              recurringType: recurringType,
            )
            .then((e) {
              result = e;
              resultCount++;
              if (resultCount != 2) return;
              completer.complete(result);
            })
            .catchError((error) {
              resultCount++;
              if (resultCount != 2) return;
              completer.complete(result);
            });
      });
    } else {
      _controllers[newOAuth?.uniqueId]?.entries.forEachIndexed((index, e) {
        e.value
            .editCalendarEvent(
              context: context,
              originalEvent: originalEvent,
              newEvent: newEvent,
              selectedEndDate: selectedEndDate,
              selectedStartDate: selectedStartDate,
              isCreate: isCreate,
              targetTab: targetTab,
              tabType: tabType,
              recurringType: recurringType,
            )
            .then((e) {
              result = e;
              resultCount++;
              if (resultCount != 1) return;
              completer.complete(result);
            })
            .catchError((error) {
              resultCount++;
              if (resultCount != 1) return;
              completer.complete(result);
            });
      });
    }

    return completer.future;
  }

  Future<bool> responseCalendarInvitation({
    required EventEntity event,
    required EventAttendeeResponseStatus status,
    required BuildContext context,
    required TabType? targetTab,
  }) async {
    Completer<bool> completer = Completer();
    int resultCount = 0;
    final originalOAuth = calendarOAuths.firstWhereOrNull((e) => e.email == event.calendar.email);

    bool result = false;
    _controllers[originalOAuth?.uniqueId]?.entries.forEachIndexed((index, e) {
      e.value
          .responseCalendarInvitation(event: event, status: status, context: context, targetTab: index == 0 ? targetTab : null, tabType: tabType)
          .then((e) {
            resultCount++;
            if (resultCount != 1) return;
            completer.complete(result);
          })
          .catchError((error) {
            resultCount++;
            if (resultCount != 1) return;
            completer.complete(result);
          });
    });

    return completer.future;
  }

  Future<List<EventEntity>> getMockEvents() async {
    final results = await Future.wait([
      rootBundle.loadString('assets/mock/calendar/google/calendars.json'),
      rootBundle.loadString('assets/mock/calendar/microsoft/calendars.json'),
    ]);

    final _googleCalendarList = jsonDecode(results[0]) as List<dynamic>;
    final _microsoftCalendarList = jsonDecode(results[1]) as List<dynamic>;
    final data = <String, List<CalendarEntity>>{
      fakeUserEmail: _googleCalendarList
          .map(
            (e) => CalendarEntity(
              id: e['id'],
              name: e['summary'],
              backgroundColor: e['backgroundColor'],
              foregroundColor: e['foregroundColor'],
              email: fakeUserEmail,
              owned: e['accessRole'] == 'owner',
              modifiable: true,
              shareable: true,
              removable: true,
              type: CalendarEntityType.google,
            ),
          )
          .whereType<CalendarEntity>()
          .toList(),
      companyEmail: _microsoftCalendarList
          .mapIndexed(
            (i, e) => CalendarEntity(
              id: e['id'],
              name: e['name'],
              backgroundColor: [Colors.teal, Colors.orange, Colors.red][i].toHex(),
              foregroundColor: Colors.white.toHex(),
              email: companyEmail,
              owned: e['owner']['address'] == companyEmail,
              modifiable: true,
              shareable: true,
              removable: true,
              type: CalendarEntityType.microsoft,
            ),
          )
          .whereType<CalendarEntity>()
          .toList(),
    };

    final googleCalendarIds = data[fakeUserEmail]!.map((e) => e.id).toList();
    final microsoftCalendarIds = data[companyEmail]!.map((e) => e.id).toList();

    final results2 = await Future.wait([
      Future.wait(googleCalendarIds.map((e) => rootBundle.loadString('assets/mock/calendar/google/events/$e.json'))),
      Future.wait(microsoftCalendarIds.map((e) => rootBundle.loadString('assets/mock/calendar/microsoft/events/$e.json'))),
    ]);
    final googleEvents = results2[0]
        .map((e) => jsonDecode(e))
        .mapIndexed((i, e) => e.map((e) => EventEntity.fromGoogleEvent(googleEvent: Event.fromJson(e), calendar: data[fakeUserEmail]![i])).toList())
        .expand((e) => e)
        .whereType<EventEntity>()
        .toList();

    final microsoftEvents = results2[1]
        .map((e) => jsonDecode(e))
        .mapIndexed((i, e) => e.map((e) => EventEntity.fromMsEvent(msEvent: OutlookEventEntity.fromJson(e), calendar: data[companyEmail]![i])).toList())
        .expand((e) => e)
        .whereType<EventEntity>()
        .toList();

    await Future.delayed(const Duration(seconds: 1));

    return [...googleEvents, ...microsoftEvents];
  }
}

@riverpod
class CalendarEventListControllerInternal extends _$CalendarEventListControllerInternal {
  late CalendarRepository _repository;

  String isLoadedId = '';

  Map<DateTime, bool> fetchedMonths = {};

  List<EventEntity> get events => [...state.value ?? []];

  DateTime lastLocalUpdatedTimestamp = DateTime.now();

  List<OAuthEntity> get _oauths => ref.read(localPrefControllerProvider).value?.calendarOAuths ?? [];

  List<CalendarEntity> _calendars = [];

  OAuthEntity get oauth => ref.read(localPrefControllerProvider.select((value) => value.value?.calendarOAuths?.firstWhereOrNull((e) => e.uniqueId == oAuthUniqueId)))!;

  @override
  Future<List<EventEntity>> build({required bool isSignedIn, required String oAuthUniqueId, required int targetYear, required int targetMonth}) async {
    _repository = ref.watch(calendarRepositoryProvider);

    ref.listen(
      calendarListControllerProvider.select((v) {
        final calendarIds = v.values.expand((e) => e).toList().map((e) => e.uniqueId).toList();
        calendarIds.sort((a, b) => b.compareTo(a));
        return calendarIds.join(',');
      }),
      (prev, next) {
        _calendars = ref.read(calendarListControllerProvider).values.expand((e) => e).toList();
        refresh();
      },
    );

    if (!ref.watch(shouldUseMockDataProvider)) {
      // shouldUseMockDataProvider가 false이므로 isSignedIn은 true입니다
      // 따라서 userId는 안전하게 가져올 수 있습니다
      final userId = ref.watch(authControllerProvider.select((v) => v.requireValue.id));

      await persist(
        ref.watch(storageProvider.future),
        key: '${CalendarEventListController.stringKey(TabType.calendar)}_${isSignedIn}_${oAuthUniqueId}_${targetYear}_${targetMonth}',
        encode: (List<EventEntity>? state) => state == null ? '' : jsonEncode(state.map((e) => e.toJson()).toList()),
        decode: (String encoded) {
          final trimmed = encoded.trim();
          if (trimmed.isEmpty || trimmed == 'null') {
            return [];
          }
          return (jsonDecode(trimmed) as List<dynamic>).map((e) => EventEntity.fromJson(e)).toList();
        },
        options: Utils.storageOptions,
      ).future;
    }

    return state.value ?? [];
  }

  bool _isRefreshing = false;
  bool _isRefreshPending = false;

  Future<void> refresh({bool? showLoading, bool? isChunkUpdate}) async {
    if (_isRefreshing) {
      _isRefreshPending = true;
      return;
    }
    _isRefreshing = true;
    try {
      fetchedMonths = {};
      _remoteFetchedEvents = [];
      await load(showLoading: showLoading, isChunkUpdate: isChunkUpdate);
    } finally {
      _isRefreshing = false;
      if (_isRefreshPending) {
        _isRefreshPending = false;
        refresh(showLoading: showLoading, isChunkUpdate: isChunkUpdate);
      }
    }
  }

  Future<void> load({bool? showLoading, bool? isChunkUpdate}) async {
    if (!ref.read(isSignedInProvider)) return;
    if (ref.read(shouldUseMockDataProvider)) return;
    final pref = ref.read(localPrefControllerProvider).value;
    if (pref == null) throw Failure.unauthorized(StackTrace.current);

    final targetDate = DateTime(targetYear, targetMonth);

    final updateTimestamp = DateTime.now();
    final startDateTime = targetDate.subtract(Duration(days: targetDate.weekday % 7 + 1));
    final endDateTime = targetDate.add(Duration(days: 43 - targetDate.weekday % 7));
    final result = await _repository.fetchEventLists(startDateTime: startDateTime, endDateTime: endDateTime, calendars: _calendars, oauth: oauth);

    result.fold((l) {}, (r) {
      _remoteFetchedEvents = [...r.events.values.expand((e) => e), ..._remoteFetchedEvents]..unique((e) => e.uniqueId);

      if (lastLocalUpdatedTimestamp.isAfter(updateTimestamp)) {
        return;
      }

      _updateState(list: _remoteFetchedEvents, updatedTimestamp: updatedTimestamp, isLocalUpdate: false, isChunkUpdate: isChunkUpdate);
    });
  }

  Future<bool> _responseInvitation({
    required EventEntity event,
    required EventAttendeeEntity attendee,
    required CalendarEntity? originalCalendar,
    bool? doNotUpdateState,
    List<EventEntity>? prevState,
    required BuildContext context,
    required TabType? targetTab,
    required TabType tabType,
  }) async {
    final pref = ref.read(localPrefControllerProvider).value;
    if (pref == null) throw Failure.unauthorized(StackTrace.current);

    List<EventEntity> previousState = prevState ?? events;

    if (doNotUpdateState != true) {
      final list = events
        ..removeWhere((e) => e.uniqueId == event.uniqueId)
        ..add(event.copyWith(attendees: [attendee, ...event.attendees].unique((e) => e.email)))
        ..unique((e) => e.uniqueId);

      DateTime updatedTimestamp = DateTime.now().add(kLocalUpdateGracePeriod);
      this.updatedTimestamp = updatedTimestamp;

      _updateState(list: list, updatedTimestamp: updatedTimestamp, isLocalUpdate: true);
    }

    if (tabType != targetTab) return true;

    final eventResult = await _repository.responseInvitation(event, attendee, originalCalendar, oauth);

    return eventResult.fold(
      (l) {
        if (doNotUpdateState != true) {
          _updateState(list: previousState, updatedTimestamp: updatedTimestamp, isLocalUpdate: true);
        }
        return false;
      },
      (r) async {
        if (r == null) return false;
        final remoteFetchList = events
          ..removeWhere((e) => e.eventId.isEmpty)
          ..removeWhere((e) => e.uniqueId == r.uniqueId && e.calendarId == originalCalendar?.id)
          ..add(r)
          ..unique((e) => e.uniqueId);

        if (doNotUpdateState != true) {
          _updateState(list: remoteFetchList, updatedTimestamp: updatedTimestamp, isLocalUpdate: false);
        }

        return true;
      },
    );
  }

  Future<List<EventEntity>> _upsertEvent({
    required EventEntity event,
    required EventEntity? originalEvent,
    required CalendarEntity? originalCalendar,
    List<String>? cancelledInstances,
    bool? doNotUpdateState,
    List<EventEntity>? prevState,
    required bool isCreate,
    required BuildContext context,
    required TabType? targetTab,
    required TabType tabType,
    required Completer<RecurringEventEditType?> completer,
    RecurringEventEditType? resultType,
  }) async {
    final pref = ref.read(localPrefControllerProvider).value;
    if (pref == null) throw Failure.unauthorized(StackTrace.current);

    List<EventEntity> previousState = prevState ?? events;

    final list = events
      ..removeWhere((e) => e.uniqueId == (originalEvent?.uniqueId ?? event.uniqueId) || e.recurringEventId == (originalEvent?.eventId ?? event.eventId))
      ..add(event)
      ..unique((e) => e.uniqueId);

    if (doNotUpdateState != true) {
      DateTime updatedTimestamp = DateTime.now().add(kLocalUpdateGracePeriod);
      this.updatedTimestamp = updatedTimestamp;

      _updateState(list: list, updatedTimestamp: updatedTimestamp, isLocalUpdate: true);
    }

    final targetDate = ref.read(calendarDisplayDateProvider(tabType).select((v) => v[CalendarDisplayType.main] ?? DateTime.now()));
    if (targetTab != tabType || targetMonth != targetDate.month) {
      completer.complete(resultType ?? RecurringEventEditType.single);
      return list;
    }
    if (ref.read(shouldUseMockDataProvider)) {
      completer.complete(resultType ?? RecurringEventEditType.single);
      return list;
    }

    lastLocalUpdatedTimestamp = DateTime.now().add(kLocalUpdateGracePeriod);
    final newEvent = event.copyWith(sequence: event.sequence + 1);

    final eventResult = isCreate ? await _repository.insertCalendar(newEvent, oauth) : await _repository.updateCalendar(newEvent, cancelledInstances, originalEvent, oauth);

    lastLocalUpdatedTimestamp = DateTime.now().add(kLocalUpdateGracePeriod);

    return eventResult.fold(
      (l) {
        if (doNotUpdateState != true) {
          _updateState(list: previousState, updatedTimestamp: updatedTimestamp, isLocalUpdate: true);
          completer.complete(null);
        }
        return previousState;
      },
      (r) async {
        if (r == null) {
          completer.complete(null);
          return previousState;
        }

        final remoteFetchList = events
          ..removeWhere((e) => e.eventId.isEmpty)
          ..removeWhere((e) => e.uniqueId == event.uniqueId)
          ..removeWhere((e) => e.uniqueId == r.uniqueId)
          ..add(r.isCancelled ? r.copyDeletedRecurringWith(id: r.eventId, recurringEventId: r.recurringEventId, originalStartTime: r.originalStartTime) : r)
          ..unique((e) => e.uniqueId);

        if (doNotUpdateState == true) {
          _updateState(list: remoteFetchList, updatedTimestamp: updatedTimestamp, isLocalUpdate: false);
        }

        completer.complete(resultType ?? RecurringEventEditType.single);

        return [...remoteFetchList];
      },
    );
  }

  Future<List<EventEntity>> _deleteEvent({
    required EventEntity event,
    bool? doNotUpdateState,
    List<EventEntity>? prevState,
    required BuildContext context,
    required TabType? targetTab,
    required TabType tabType,
    required Completer<RecurringEventEditType?> completer,
    RecurringEventEditType? resultType,
  }) async {
    final pref = ref.read(localPrefControllerProvider).value;
    if (pref == null) throw Failure.unauthorized(StackTrace.current);

    List<EventEntity> previousState = prevState ?? events;

    final list = events
      ..removeWhere((e) => e.uniqueId == event.uniqueId || e.recurringEventId == event.eventId)
      ..add(event.copyDeletedWith())
      ..unique((e) => e.uniqueId);

    if (doNotUpdateState != true) {
      DateTime updatedTimestamp = DateTime.now().add(kLocalUpdateGracePeriod);
      this.updatedTimestamp = updatedTimestamp;

      _updateState(list: list, updatedTimestamp: updatedTimestamp, isLocalUpdate: true);
    }

    final targetDate = ref.read(calendarDisplayDateProvider(tabType).select((v) => v[CalendarDisplayType.main] ?? DateTime.now()));
    if (targetTab != tabType || targetMonth != targetDate.month) return list;
    if (ref.read(shouldUseMockDataProvider)) return list;

    lastLocalUpdatedTimestamp = DateTime.now().add(kLocalUpdateGracePeriod);
    final eventResult = await _repository.deleteCalendar(event, oauth);
    lastLocalUpdatedTimestamp = DateTime.now().add(kLocalUpdateGracePeriod);

    return eventResult.fold(
      (l) {
        if (doNotUpdateState != true) {
          completer.complete(null);
          _updateState(list: previousState, updatedTimestamp: updatedTimestamp, isLocalUpdate: true);
        }

        return previousState;
      },
      (r) async {
        if (doNotUpdateState != true) {
          completer.complete(resultType ?? RecurringEventEditType.single);
          return previousState;
        }

        final remoteFetchList = list;
        return remoteFetchList;
      },
    );
  }

  Future<void> _updateRecurringEvent({
    required RecurringEventEditType recurringEventEditType,
    required EventEntity originalEvent,
    required EventEntity? newEvent,
    required DateTime selectedEndDate,
    required DateTime selectedStartDate,
    required BuildContext context,
    required TabType? targetTab,
    required TabType tabType,
    required Completer<RecurringEventEditType?> completer,
  }) async {
    final initialStartDate = originalEvent.recurringEventId == null
        ? originalEvent.startDateTime
        : events.firstWhereOrNull((e) => e.eventId == originalEvent.recurringEventId)?.startDateTime;
    final initialEndDate = originalEvent.recurringEventId == null
        ? originalEvent.endDateTime
        : events.firstWhereOrNull((e) => e.eventId == originalEvent.recurringEventId)?.endDateTime;
    final isDelete = newEvent == null;

    if (initialStartDate == null || initialEndDate == null) return;

    final recurringEvent = originalEvent.recurringEventId != null ? events.firstWhereOrNull((e) => e.eventId == originalEvent.recurringEventId) : originalEvent;
    RecurrenceRule? originalRrule = recurringEvent?.recurrence;
    RecurrenceRule? newEventRrule = newEvent?.recurrence;
    if (originalRrule == null) return;

    final newRrule = originalRrule != newEventRrule
        ? newEventRrule
        : newEvent == null
        ? originalRrule
        : originalRrule.copyWith(
            byMonthDays: originalRrule.byMonthDays.map((e) => e == selectedStartDate.day ? newEvent.startDate.day : e).toList(),
            byYearDays: originalRrule.byYearDays.map((e) => e == selectedStartDate.daysInYear ? newEvent.startDate.daysInYear : e).toList(),
            byWeeks: originalRrule.byWeeks.map((e) => e == selectedStartDate.weekInfo.weekOfYear ? newEvent.startDate.weekInfo.weekOfYear : e).toList(),
            byMonths: originalRrule.byMonths.map((e) => e == selectedStartDate.month ? newEvent.startDate.month : e).toList(),
            byWeekDays: originalRrule.byWeekDays
                .map((e) => e.day == selectedStartDate.weekday ? ByWeekDayEntry(newEvent.startDate.weekday, e.occurrence != null ? newEvent.startDate.weekOfMonth : null) : e)
                .toList(),
          );

    switch (recurringEventEditType) {
      case RecurringEventEditType.thisEventOnly:
        final newEventId = originalEvent.recurringEventId == null
            ? '${originalEvent.eventId}_${DateFormat('yyyyMMddTHHmmss').format((originalEvent.originalStartTime ?? selectedStartDate).toUtc())}Z'
            : originalEvent.eventId;

        List<EventEntity> prevState = events;

        List<EventEntity> list;
        if (isDelete) {
          if (originalEvent.recurringEventId == null) {
            list = [...events]..add(originalEvent.copyDeletedRecurringWith(id: newEventId, recurringEventId: originalEvent.eventId, originalStartTime: selectedStartDate));
          } else {
            list = events.map((e) {
              if (e.eventId == originalEvent.eventId) {
                return originalEvent.copyDeletedRecurringWith(id: originalEvent.eventId, recurringEventId: originalEvent.recurringEventId, originalStartTime: selectedStartDate);
              }
              return e;
            }).toList();
          }

          DateTime updatedTimestamp = DateTime.now().add(kLocalUpdateGracePeriod);
          this.updatedTimestamp = updatedTimestamp;

          _updateState(list: list, updatedTimestamp: updatedTimestamp, isLocalUpdate: true);
        } else {
          if (originalEvent.recurringEventId == null) {
            list = events
              ..add(
                newEvent.copyWith(
                  id: newEventId,
                  iCalUID: originalEvent.iCalId,
                  recurringEventId: originalEvent.eventId,
                  originalStartTime: selectedStartDate,
                  removeRecurrence: true,
                ),
              );
          } else {
            list = events.map((e) {
              if (e.eventId == originalEvent.eventId) {
                return newEvent.copyWith(
                  id: originalEvent.eventId,
                  iCalUID: originalEvent.iCalId,
                  recurringEventId: originalEvent.recurringEventId,
                  originalStartTime: originalEvent.originalStartTime,
                  removeRecurrence: true,
                );
              } else {
                return e;
              }
            }).toList();
          }

          DateTime updatedTimestamp = DateTime.now().add(kLocalUpdateGracePeriod);
          this.updatedTimestamp = updatedTimestamp;

          _updateState(list: list, updatedTimestamp: updatedTimestamp, isLocalUpdate: true);
        }

        if (ref.read(shouldUseMockDataProvider)) return;

        final targetInstance =
            (await _repository.getInstnace(startDateTime: selectedStartDate, oauth: oauth, event: recurringEvent!)).getOrElse((l) => originalEvent) ?? originalEvent;

        if (isDelete) {
          var result = await _upsertEvent(
            event: targetInstance.copyWith(status: 'cancelled'),
            cancelledInstances: originalEvent.cancelledOccurrences,
            originalEvent: originalEvent,
            originalCalendar: originalEvent.calendar,
            doNotUpdateState: true,
            prevState: prevState,
            context: context,
            isCreate: false,
            targetTab: targetTab,
            tabType: tabType,
            completer: completer,
          );

          final remoteFetchList = result.where((e) => e.eventId.isNotEmpty).toList().unique((e) => e.uniqueId);

          _updateState(list: remoteFetchList, updatedTimestamp: updatedTimestamp, isLocalUpdate: false);
        } else {
          var result = await _upsertEvent(
            event: newEvent.copyWith(
              id: targetInstance.eventId,
              iCalUID: targetInstance.iCalId,
              recurringEventId: targetInstance.recurringEventId,
              originalStartTime: targetInstance.originalStartTime,
              removeRecurrence: true,
            ),
            cancelledInstances: originalEvent.cancelledOccurrences,
            originalEvent: originalEvent,
            originalCalendar: originalEvent.calendar,
            doNotUpdateState: true,
            prevState: prevState,
            context: context,
            isCreate: false,
            targetTab: targetTab,
            tabType: tabType,
            completer: completer,
          );

          final remoteFetchList = result.where((e) => e.eventId.isNotEmpty).toList().unique((e) => e.uniqueId);
          _updateState(list: remoteFetchList, updatedTimestamp: updatedTimestamp, isLocalUpdate: false);

          completer.complete(RecurringEventEditType.thisEventOnly);
        }
        break;
      case RecurringEventEditType.thisAndFutureEvents:
        {
          final rruleSelectedStartDate = originalEvent.originalStartTime ?? selectedStartDate;
          final prevInstance = rruleSelectedStartDate.compareTo(initialStartDate) < 0
              ? null
              : originalRrule.getInstances(start: initialStartDate.toUtc(), before: rruleSelectedStartDate.toUtc(), includeBefore: false);
          final prevInstanceCount = prevInstance?.length ?? 0;
          final prevRrule = prevInstanceCount < 1
              ? null
              : originalRrule.copyWith(
                  until: originalRrule.count != null
                      ? null
                      : prevInstance?.isNotEmpty != true
                      ? rruleSelectedStartDate.toUtc()
                      : prevInstance!.last.toUtc(),
                  count: originalRrule.count == null ? null : prevInstanceCount,
                );

          final prevEvents = prevRrule == null
              ? null
              : (originalEvent.recurringEventId == null ? originalEvent : events.firstWhereOrNull((e) => e.eventId == originalEvent.recurringEventId))?.copyWith(rrule: prevRrule);

          final thisAndFutureEvents = isDelete
              ? null
              : EventEntity(
                  calendarType: newEvent.calendarType,
                  eventId: Utils.generateBase32HexStringFromTimestamp(),
                  title: newEvent.title,
                  description: newEvent.description,
                  rrule: newRrule,
                  location: newEvent.location,
                  isAllDay: newEvent.isAllDay,
                  startDate: newEvent.startDate,
                  timezone: newEvent.timezone,
                  endDate: newEvent.endDate,
                  attendees: newEvent.attendees,
                  reminders: newEvent.reminders ?? [],
                  attachments: newEvent.attachments,
                  conferenceLink: newEvent.conferenceLink,
                  modifiedEvent: newEvent,
                  calendar: newEvent.calendar,
                  sequence: newEvent.sequence,
                );

          if (isDelete) {
            List<EventEntity> prevState = events;
            final list = events
              ..removeWhere(
                (e) =>
                    (e.uniqueId == prevEvents?.uniqueId) ||
                    (e.uniqueId == originalEvent.uniqueId) ||
                    (e.recurringEventId == originalEvent.eventId && e.startDate.isAfter(selectedStartDate)),
              )
              ..unique((e) => e.uniqueId)
              ..addAll([if (prevEvents != null) prevEvents]);

            DateTime updatedTimestamp = DateTime.now().add(kLocalUpdateGracePeriod);
            this.updatedTimestamp = updatedTimestamp;

            _updateState(list: list, updatedTimestamp: updatedTimestamp, isLocalUpdate: true);

            // for this event
            List<EventEntity> result;
            if (prevEvents == null) {
              result = await _deleteEvent(
                event: originalEvent,
                doNotUpdateState: true,
                prevState: prevState,
                context: context,
                targetTab: targetTab,
                completer: completer,
                tabType: tabType,
              );
            } else {
              result = await _upsertEvent(
                event: prevEvents,
                originalEvent: originalEvent,
                originalCalendar: originalEvent.calendar,
                cancelledInstances: originalEvent.cancelledOccurrences,
                doNotUpdateState: true,
                prevState: prevState,
                context: context,
                isCreate: false,
                targetTab: targetTab,
                completer: completer,
                tabType: tabType,
              );
            }

            final remoteFetchList = result.where((e) => e.eventId.isNotEmpty).toList().unique((e) => e.uniqueId);

            _updateState(list: remoteFetchList, updatedTimestamp: updatedTimestamp, isLocalUpdate: false);
          } else {
            List<EventEntity> prevState = events;
            final list = events
              ..removeWhere(
                (e) =>
                    (e.uniqueId == prevEvents?.uniqueId) ||
                    (e.uniqueId == originalEvent.uniqueId) ||
                    (e.recurringEventId == originalEvent.eventId && e.startDate.isAfter(selectedStartDate)),
              )
              ..unique((e) => e.uniqueId)
              ..addAll([thisAndFutureEvents!, if (prevEvents != null) prevEvents]);

            DateTime updatedTimestamp = DateTime.now().add(kLocalUpdateGracePeriod);
            this.updatedTimestamp = updatedTimestamp;

            _updateState(list: list, updatedTimestamp: updatedTimestamp, isLocalUpdate: true);

            // for this event
            List<EventEntity> result;
            if (prevEvents == null) {
              result = await _deleteEvent(
                event: originalEvent,
                doNotUpdateState: true,
                prevState: prevState,
                context: context,
                targetTab: targetTab,
                completer: completer,
                tabType: tabType,
              );
            } else {
              result = await _upsertEvent(
                event: prevEvents,
                originalEvent: originalEvent,
                originalCalendar: originalEvent.calendar,
                cancelledInstances: originalEvent.cancelledOccurrences,
                doNotUpdateState: true,
                prevState: prevState,
                context: context,
                isCreate: false,
                targetTab: targetTab,
                completer: completer,
                tabType: tabType,
              );
            }

            result = await _upsertEvent(
              event: thisAndFutureEvents,
              originalEvent: originalEvent,
              originalCalendar: originalEvent.calendar,
              cancelledInstances: originalEvent.cancelledOccurrences,
              doNotUpdateState: true,
              prevState: result,
              context: context,
              isCreate: true,
              targetTab: targetTab,
              completer: completer,
              tabType: tabType,
            );

            final remoteFetchList = result.where((e) => e.eventId.isNotEmpty).toList().unique((e) => e.uniqueId);

            _updateState(list: remoteFetchList, updatedTimestamp: updatedTimestamp, isLocalUpdate: false);
          }

          completer.complete(RecurringEventEditType.thisAndFutureEvents);
          break;
        }
      case RecurringEventEditType.allEvents:
        {
          final recurringEvent = (originalEvent.recurringEventId == null ? originalEvent : events.firstWhereOrNull((e) => e.eventId == originalEvent.recurringEventId));

          if (recurringEvent == null) return;

          if (isDelete) {
            await _deleteEvent(event: recurringEvent, context: context, targetTab: targetTab, completer: completer, resultType: RecurringEventEditType.allEvents, tabType: tabType);
          } else {
            final allEvents = originalEvent.recurringEventId == null
                ? newEvent.copyWith(
                    isAllDay: newEvent.isAllDay,
                    rrule: newRrule,
                    startDate: DateUtils.dateOnly(initialStartDate.toLocal()).add(
                      Duration(
                        days: DateUtils.dateOnly(newEvent.startDate.toLocal()).difference(DateUtils.dateOnly(selectedStartDate.toLocal())).inDays,
                        hours: newEvent.startDate.hour,
                        minutes: newEvent.startDate.minute,
                      ),
                    ),
                    endDate: DateUtils.dateOnly(initialEndDate.toLocal()).add(
                      Duration(
                        days: DateUtils.dateOnly(newEvent.endDate.toLocal()).difference(DateUtils.dateOnly(selectedEndDate.toLocal())).inDays,
                        hours: newEvent.endDate.hour,
                        minutes: newEvent.endDate.minute,
                      ),
                    ),
                  )
                : recurringEvent.copyWith(
                    modifiedEvent: newEvent,
                    calendar: newEvent.calendar,
                    title: newEvent.title,
                    description: newEvent.description,
                    location: newEvent.location,
                    rrule: newRrule,
                    reminders: newEvent.reminders,
                    attendees: newEvent.attendees,
                    isAllDay: newEvent.isAllDay,
                    startDate: DateUtils.dateOnly(initialStartDate.toLocal()).add(
                      Duration(
                        days: DateUtils.dateOnly(newEvent.startDate.toLocal()).difference(DateUtils.dateOnly(selectedStartDate.toLocal())).inDays,
                        hours: newEvent.startDate.hour,
                        minutes: newEvent.startDate.minute,
                      ),
                    ),
                    endDate: DateUtils.dateOnly(initialEndDate.toLocal()).add(
                      Duration(
                        days: DateUtils.dateOnly(newEvent.endDate.toLocal()).difference(DateUtils.dateOnly(selectedEndDate.toLocal())).inDays,
                        hours: newEvent.endDate.hour,
                        minutes: newEvent.endDate.minute,
                      ),
                    ),
                  );

            await _upsertEvent(
              event: allEvents,
              originalEvent: recurringEvent,
              originalCalendar: recurringEvent.calendar,
              cancelledInstances: originalEvent.cancelledOccurrences,
              context: context,
              isCreate: false,
              targetTab: targetTab,
              completer: completer,
              resultType: RecurringEventEditType.allEvents,
              tabType: tabType,
            );
          }

          break;
        }
      case RecurringEventEditType.single:
        completer.complete(RecurringEventEditType.single);
        break;
    }
  }

  Future<RecurringEventEditType?> editCalendarEvent({
    required BuildContext context,
    required EventEntity? originalEvent,
    required EventEntity? newEvent,
    required DateTime selectedEndDate,
    required DateTime selectedStartDate,
    required bool isCreate,
    required TabType? targetTab,
    required TabType tabType,
    RecurringEventEditType? recurringType,
  }) async {
    final Completer<RecurringEventEditType?> completer = Completer();

    if (originalEvent?.recurrence != null || originalEvent?.recurringEventId != null) {
      if (recurringType == null) return null;
      await _updateRecurringEvent(
        recurringEventEditType: recurringType,
        originalEvent: originalEvent!,
        newEvent: newEvent,
        selectedEndDate: selectedEndDate,
        selectedStartDate: selectedStartDate,
        context: context,
        targetTab: targetTab,
        completer: completer,
        tabType: tabType,
      );
    } else {
      if (newEvent != null) {
        await _upsertEvent(
          event: newEvent,
          originalEvent: originalEvent,
          originalCalendar: originalEvent?.calendar,
          context: context,
          isCreate: isCreate,
          targetTab: targetTab,
          completer: completer,
          tabType: tabType,
        );
      } else if (originalEvent != null) {
        await _deleteEvent(event: originalEvent, context: context, targetTab: targetTab, completer: completer, tabType: tabType);
      } else {
        // newEvent와 originalEvent가 모두 null인 경우 (이론적으로는 발생하지 않아야 함)
        completer.complete(null);
      }
    }

    return completer.future;
  }

  Future<bool> responseCalendarInvitation({
    required EventEntity event,
    required EventAttendeeResponseStatus status,
    required BuildContext context,
    required TabType? targetTab,
    required TabType tabType,
  }) async {
    EventAttendeeEntity myAttendee = event.attendees.firstWhere((e) => e.email == event.calendar.email);
    myAttendee = myAttendee.copyWith(responseStatus: status);
    return _responseInvitation(event: event, attendee: myAttendee, originalCalendar: event.calendar, context: context, targetTab: targetTab, tabType: tabType);
  }

  DateTime updatedTimestamp = DateTime.now();
  List<EventEntity> _remoteFetchedEvents = [];

  void _updateState({required List<EventEntity> list, required DateTime updatedTimestamp, required bool isLocalUpdate, bool? isChunkUpdate}) async {
    if (!ref.mounted) return;

    list =
        list
            .where((e) {
              return e.attendees.isEmpty || (e.attendees.any((a) => a.responseStatus != EventAttendeeResponseStatus.declined));
            })
            .map((n) {
              final p = events.firstWhereOrNull((e) => e.uniqueId == n.uniqueId);
              if (p == null) return n;
              if (p.sequence < n.sequence) return n;
              if (p.sequence > n.sequence) return p;
              return n;
            })
            .where((e) => e.eventId.isNotEmpty == true && _oauths.where((o) => o.email == e.calendar.email && o.type.calendarType == e.calendarType).isNotEmpty)
            .toList()
            .unique((e) => e.uniqueId)
          ..sort((a, b) => a.uniqueId.compareTo(b.uniqueId))
          ..sort((a, b) {
            // I want to sort currentMonth-event to front and others to behind. It needs to check both startDate and endDate is in month of currentFetchedMonth
            final currentMonth = DateTime(targetYear, targetMonth);
            final aIsInMonth =
                a.startDate.isBefore(currentMonth.add(Duration(days: currentMonth.daysInMonth))) &&
                a.endDate.isAfter(currentMonth) &&
                a.endDate.isBefore(currentMonth.add(Duration(days: currentMonth.daysInMonth)));
            final bIsInMonth =
                b.startDate.isBefore(currentMonth.add(Duration(days: currentMonth.daysInMonth))) &&
                b.endDate.isAfter(currentMonth) &&
                b.endDate.isBefore(currentMonth.add(Duration(days: currentMonth.daysInMonth)));
            // now sort
            if (aIsInMonth && !bIsInMonth) return -1;
            if (!aIsInMonth && bIsInMonth) return 1;
            return 0;
          });

    if (list.isEmpty) {
      _uploadRemindersAndSyncToServer();
      _remoteFetchedEvents = [];
      state = const AsyncData([]);
      return;
    }

    if (!isLocalUpdate) {
      _remoteFetchedEvents = list;
    }

    final chunkSize = 10000000000; //isChunkUpdate == true ? 50 : 1000000;
    final chunks = <List<EventEntity>>[];
    for (int i = 0; i < list.length; i += chunkSize) {
      chunks.add(list.sublist(i, (i + chunkSize).clamp(0, list.length)));
    }

    final List<EventEntity> accumulated = [];

    void applyChunk(int index, List<List<EventEntity>> chunks) {
      if (index >= chunks.length) {
        if (ref.read(shouldUseMockDataProvider)) return;
        _uploadRemindersAndSyncToServer();
        return;
      } else {
        accumulated.addAll(chunks[index]);
        state = AsyncData([...accumulated]);
        applyChunk(index + 1, chunks);
      }
    }

    applyChunk(0, chunks);
  }

  void _uploadRemindersAndSyncToServer() async {
    if (targetMonth != DateTime.now().month || targetYear != DateTime.now().year) return;
    final list = state.value ?? [];

    /// 🔧 리마인더 추출 + 서버 전송 (렌더링과 분리된 사이드이펙트 전용 함수)
    final user = ref.read(authControllerProvider).requireValue;
    final pref = ref.read(localPrefControllerProvider).value;
    final deviceId = ref.read(deviceIdProvider).asData?.value;
    if (ref.read(shouldUseMockDataProvider)) return;
    if (pref == null || deviceId?.isEmpty != false) return;

    final configFile = await rootBundle.loadString('assets/config/${F.envFileName}');
    final env = Environment.fromJson(json.decode(configFile) as Map<String, dynamic>);

    /// 📌 EventEntity 리스트에서 CalendarReminderEntity 추출
    final notificationList = list
        .expand(
          (e) => (e.reminders ?? []).expand((r) {
            if (r.minutes == null) return [];
            if (e.attendees.any((a) => a.email == e.calendar.email && a.responseStatus == EventAttendeeResponseStatus.declined)) return [];

            final title = Utils.encryptAESCryptoJS(e.title ?? '(No title)', env.encryptAESKey);

            if (e.recurrence != null) {
              if (e.startDate.isAfter(DateTime.now().add(Duration(days: 28)))) return [];

              final dates = e.recurrence!.getInstances(
                start: e.startDate,
                after: e.startDate.isBefore(DateTime.now()) ? DateTime.now() : e.startDate,
                before: DateTime.now().add(Duration(days: 28)),
                includeBefore: true,
                includeAfter: true,
              );

              return dates.map(
                (date) => CalendarReminderEntity(
                  id: '${user.id}_${e.eventId}_${date.millisecondsSinceEpoch}_${r.minutes}',
                  email: e.calendar.email,
                  title: title,
                  minutes: r.minutes!,
                  userId: user.id,
                  calendarId: e.calendarId,
                  eventId: e.eventId,
                  deviceId: deviceId!,
                  calendarName: e.calendarName,
                  provider: e.calendarType.name,
                  targetDateTime: date.subtract(Duration(minutes: r.minutes!)).toUtc(),
                  startDate: date,
                  endDate: e.isAllDay
                      ? date.add(Duration(minutes: e.endDate.difference(e.startDate).inMinutes)).subtract(Duration(days: 1))
                      : date.add(Duration(minutes: e.endDate.difference(e.startDate).inMinutes)),
                  isAllDay: e.isAllDay,
                  locale: Intl.getCurrentLocale(),
                  isEncrypted: true,
                  iv: '',
                ),
              );
            } else {
              return [
                CalendarReminderEntity(
                  id: '${user.id}_${e.eventId}_${r.minutes}',
                  email: e.calendar.email,
                  title: title,
                  minutes: r.minutes!,
                  userId: user.id,
                  calendarId: e.calendarId,
                  eventId: e.eventId,
                  deviceId: deviceId!,
                  calendarName: e.calendarName,
                  provider: 'google',
                  targetDateTime: e.startDate.subtract(Duration(minutes: r.minutes!)).toUtc(),
                  startDate: e.startDate,
                  endDate: e.isAllDay ? e.endDate.subtract(Duration(days: 1)) : e.endDate,
                  isAllDay: e.isAllDay,
                  locale: Intl.getCurrentLocale(),
                  isEncrypted: true,
                  iv: '',
                ),
              ];
            }
          }),
        )
        .whereType<CalendarReminderEntity>()
        .where((e) => e.targetDateTime.isAfter(DateTime.now()))
        .toList();

    /// 🔄 서버에서 알림 설정 정보 가져와서 함께 저장
    final _saveReminders = (NotificationEntity r) async {
      await ref.read(calendarRepositoryProvider).saveReminders(userId: user.id, reminders: notificationList, notification: r, isCalendar: true);
    };

    final notification = await ref.read(authRepositoryProvider).getNotification(userId: user.id, deviceId: deviceId!);
    notification.fold((l) => null, (r) {
      EasyDebounce.debounce('save_reminders:calendar', const Duration(seconds: 1), () => _saveReminders(r));
    });
  }
}

class CalendarEventResultEntity {
  final List<EventEntity> events;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final List<EventEntity>? previousEventsOnView;
  final DateTime? previousFetchedUntil;
  final List<EventEntity>? previousEvents;
  final Map<String, List<DateTime>>? previousCachedRecurrenceInstances;
  late final Map<String, List<DateTime>> cachedRecurrenceInstances;
  late List<EventEntity> eventsOnView;

  DateTime get fetchedUntil => endDateTime;
  DateTime get fetchedFrom => startDateTime;

  void updateEventsOnView() {
    cachedRecurrenceInstances = {};
    List<EventEntity> nonRecurringEvents = events
        .where((e) => e.recurrence == null)
        .toList()
        .map((e) => e.copyWith(editedStartTime: e.startDate, editedEndTime: e.endDate))
        .toList();

    // Original recurring events: recurrence가 있고 recurringEventId가 null인 것들
    List<EventEntity> originalRecurringEvents = events.where((e) => e.recurrence != null && e.recurringEventId == null).toList();

    List<EventEntity> _events = [];

    originalRecurringEvents.forEach((e) {
      if (e.startDate.isAfter(fetchedUntil)) return;

      List<DateTime>? dates;

      if (e.recurrence == null) return;
      final exceptionEvents = nonRecurringEvents.where((i) => i.recurringEventId == e.eventId);
      final exceptionDates = exceptionEvents.map((i) => i.startDate.dateOnly).whereType<DateTime>().toList();
      final cancelledDates = e.exceptionDates.whereType<DateTime>().toList();
      final excludedRecurrenceDates = [...exceptionDates, ...cancelledDates].unique();

      // Optimization: Reuse previous instances if available and valid
      // Check if event itself hasn't changed AND excludedRecurrenceDates haven't changed
      if (previousEvents != null && previousCachedRecurrenceInstances != null && previousFetchedUntil == fetchedUntil) {
        final previousEvent = previousEvents!.firstWhereOrNull((ev) => ev.eventId == e.eventId);
        if (previousEvent != null && previousEvent == e) {
          // Check if excludedRecurrenceDates have changed by comparing with previousEventsOnView
          final previousExceptionEvents = previousEventsOnView?.where((i) => i.recurringEventId == e.eventId).toList() ?? [];
          final previousExceptionDates = previousExceptionEvents.map((i) => i.startDate.dateOnly).whereType<DateTime>().toList();
          final previousCancelledDates = previousEvent.exceptionDates.whereType<DateTime>().toList();
          final previousExcludedRecurrenceDates = [...previousExceptionDates, ...previousCancelledDates].unique();

          // Only reuse cache if excludedRecurrenceDates haven't changed
          if (previousExcludedRecurrenceDates.length == excludedRecurrenceDates.length &&
              previousExcludedRecurrenceDates.every((d) => excludedRecurrenceDates.any((ed) => ed.dateOnly == d.dateOnly))) {
            dates = previousCachedRecurrenceInstances![e.eventId];
          }
        }
      }

      DateTime startAt = e.startDate;
      if (e.startDate.isBefore(fetchedFrom)) {
        startAt = fetchedFrom;
      }

      if (dates == null) {
        dates = e.recurrence?.getInstances(start: e.startDate, after: startAt, before: fetchedUntil, includeAfter: true).toList();
      }

      if (dates != null) {
        cachedRecurrenceInstances[e.eventId] = dates;
      }

      // Remove original recurring event from nonRecurringEvents if its start date is in excludedRecurrenceDates
      if (excludedRecurrenceDates.any((d) => d == e.startDate.dateOnly)) {
        nonRecurringEvents.removeWhere((event) => event.eventId == e.eventId);
      }

      final eventDuration = e.endDate.difference(e.startDate);

      dates?.where((date) => !excludedRecurrenceDates.any((d) => d.dateOnly == date.dateOnly)).forEach((date) {
        EventEntity? recurringEventOnDate = nonRecurringEvents.firstWhereOrNull(
          (event) => DateUtils.dateOnly(event.startDate) == DateUtils.dateOnly(date) && event.recurringEventId == e.eventId,
        );

        // Check if date is cancelled or excluded
        bool isCancelledDate =
            e.cancelledOccurrences?.any((cancelled) {
              // Microsoft cancelledOccurrences format: "R/{id}/{date}"
              if (cancelled.contains('.')) {
                final dateStr = cancelled.split('.').lastOrNull;
                if (dateStr != null) {
                  try {
                    final cancelledDate = DateTime.parse(dateStr);
                    return DateUtils.dateOnly(cancelledDate) == DateUtils.dateOnly(date);
                  } catch (_) {
                    return false;
                  }
                }
              }
              return false;
            }) ??
            false;

        // Check exception dates
        bool isExceptionDate = e.exceptionDates.any((exceptionDate) => DateUtils.dateOnly(exceptionDate) == DateUtils.dateOnly(date));

        if (isCancelledDate || isExceptionDate) return;

        if (recurringEventOnDate == null) {
          EventEntity? existEvent = _events
              .where((event) => event.recurringEventId == e.eventId && event.editedStartTime == date && event.editedEndTime == date.add(eventDuration))
              .firstOrNull;
          if (existEvent == null) {
            _events.add(e.copyWith(editedStartTime: date, editedEndTime: date.add(eventDuration)));
          }
        } else {
          nonRecurringEvents.remove(recurringEventOnDate);
          _events.add(recurringEventOnDate.copyWith(editedStartTime: date, editedEndTime: date.add(eventDuration)));
        }
      });
    });
    eventsOnView = [...nonRecurringEvents, ..._events];
  }

  CalendarEventResultEntity({
    required this.events,
    required this.startDateTime,
    required this.endDateTime,
    this.previousEventsOnView,
    this.previousFetchedUntil,
    this.previousEvents,
    this.previousCachedRecurrenceInstances,
  }) {
    updateEventsOnView();
  }
}
