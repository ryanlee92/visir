import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:Visir/config/providers.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/calendar/domain/entities/calendar_entity.dart';
import 'package:Visir/features/calendar/infrastructure/repositories/calendar_repository.dart';
import 'package:Visir/features/calendar/providers.dart';
import 'package:Visir/features/common/domain/failures/failure.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/color_extension.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/domain/entities/local_pref_entity.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/experimental/persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'calendar_list_controller.g.dart';

@riverpod
class CalendarListController extends _$CalendarListController {
  static String get stringKey => 'global:calendar_list';
  late List<OAuthEntity> calendarOAuths;
  Map<String, CalendarListControllerInternal> _controllers = {};

  @override
  Map<String, List<CalendarEntity>> build() {
    final isSignedIn = ref.watch(authControllerProvider.select((v) => v.requireValue.isSignedIn));
    Map<String, List<CalendarEntity>> data = {};
    ref.watch(
      localPrefControllerProvider.select((v) {
        final uniqueIds = v.value?.calendarOAuths?.map((e) => e.uniqueId).toList() ?? [];
        uniqueIds.sort();
        return uniqueIds.join(',');
      }),
    );

    _controllers.clear();

    calendarOAuths = ref.read(localPrefControllerProvider.select((v) => v.value?.calendarOAuths ?? []));
    calendarOAuths.forEach((e) {
      _controllers[e.uniqueId] = ref.watch(calendarListControllerInternalProvider(isSignedIn: isSignedIn, oAuthUniqueId: e.uniqueId).notifier);
      ref.listen(calendarListControllerInternalProvider(isSignedIn: isSignedIn, oAuthUniqueId: e.uniqueId).select((v) => v.value ?? {}), (previous, next) {
        data = {...data, ...next};
        updateState(data);
      });
    });

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      load();
    });
    return data;
  }

  Timer? timer;
  void updateState(Map<String, List<CalendarEntity>> data) {
    if (timer == null) state = data;
    timer?.cancel();
    timer = Timer(const Duration(milliseconds: kControllerDebouncMillisecond), () {
      state = data;
      timer = null;
    });
  }

  Future<List<String>?> load() async {
    Completer<List<String>?> completer = Completer();
    List<String> result = [];
    int resultCount = 0;
    ref.read(loadingStatusProvider.notifier).update(stringKey, LoadingState.loading);
    _controllers.forEach((key, value) {
      value
          .load()
          .then((value) {
            result = [...result, ...(value ?? [])];
            resultCount++;
            if (resultCount != _controllers.length) return;
            ref.read(loadingStatusProvider.notifier).update(stringKey, LoadingState.success);
            completer.complete(result);
          })
          .catchError((error) {
            resultCount++;
            if (resultCount != _controllers.length) return;
            ref.read(loadingStatusProvider.notifier).update(stringKey, LoadingState.error);
            completer.complete(result);
          });
    });
    return completer.future;
  }

  Future<void> attachCalendarChangeListener() async {
    if (ref.read(shouldUseMockDataProvider)) return;
    _controllers.forEach((key, value) {
      value.attachCalendarChangeListener();
    });
  }
}

@riverpod
class CalendarListControllerInternal extends _$CalendarListControllerInternal {
  late CalendarRepository _repository;

  Map<String, List<CalendarEntity>> get calendars => {...(state.value ?? {})};

  OAuthEntity get oauth => ref.read(localPrefControllerProvider.select((value) => value.value?.calendarOAuths?.firstWhereOrNull((e) => e.uniqueId == oAuthUniqueId)))!;

  @override
  Future<Map<String, List<CalendarEntity>>> build({required bool isSignedIn, required String oAuthUniqueId}) async {
    _repository = ref.watch(calendarRepositoryProvider);

    if (ref.watch(shouldUseMockDataProvider)) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        getMockCalendars();
      });
      return state.value ?? {};
    }

    // shouldUseMockDataProvider가 false이므로 isSignedIn은 true입니다
    // 따라서 userId는 안전하게 가져올 수 있습니다
    final userId = ref.watch(authControllerProvider.select((value) => value.requireValue.id));

    await persist(
      ref.watch(storageProvider.future),
      key: '${CalendarListController.stringKey}:${isSignedIn}:${oAuthUniqueId}',
      encode: (Map<String, List<CalendarEntity>> state) => jsonEncode(Map.fromEntries(state.entries.map((e) => MapEntry(e.key, e.value.map((e) => e.toJson()).toList())))),
      decode: (String encoded) {
        final trimmed = encoded.trim();
        if (trimmed.isEmpty || trimmed == 'null') {
          return {};
        }
        return Map.fromEntries(
          (jsonDecode(trimmed) as Map<String, dynamic>).entries.map(
            (e) => MapEntry(e.key, (e.value as List<dynamic>).map((item) => CalendarEntity.fromJson(item as Map<String, dynamic>)).toList()),
          ),
        );
      },
      options: StorageOptions(destroyKey: userId),
    ).future;

    return state.value ?? {};
  }

  void _updateState(Map<String, List<CalendarEntity>> data) {
    final prevState = {...(state.value ?? {})};
    final currentCalendarBackgroundColors = [...prevState.values.expand((e) => e).map((e) => e.backgroundColor).toList()];

    Map<String, String> userCalendarColors = ref.read(authControllerProvider).requireValue.userCalendarColors;
    Map<String, String> newCalendarColors = {};

    data = data.map((key, value) {
      final newValue = value.map((e) {
        final prevItem = prevState[key]?.where((k) => k.uniqueId == e.uniqueId).firstOrNull;
        if (e.backgroundColor.isEmpty) {
          if (userCalendarColors[e.id] != null) {
            return e.copyWith(backgroundColor: userCalendarColors[e.id]!, foregroundColor: Colors.white.toHex());
          }

          final selectableAccountColors = accountColors.where((e) => !currentCalendarBackgroundColors.contains(e.toHex())).toList();
          Color? selectableAccountColor = selectableAccountColors.isEmpty ? null : selectableAccountColors[Random().nextInt(selectableAccountColors.length)];
          selectableAccountColor ??= accountColors[Random().nextInt(accountColors.length)];
          currentCalendarBackgroundColors.add(selectableAccountColor.toHex());
          final newBackgroundColor = e.backgroundColor.isEmpty ? prevItem?.backgroundColor ?? selectableAccountColor.toHex() : e.backgroundColor;
          final newForegroundColor = e.foregroundColor.isEmpty ? prevItem?.foregroundColor ?? Colors.white.toHex() : e.foregroundColor;
          newCalendarColors[e.id] = newBackgroundColor;
          return e.copyWith(backgroundColor: newBackgroundColor, foregroundColor: newForegroundColor);
        }

        return e;
      }).toList();

      return MapEntry(key, newValue);
    });

    final finalState = {...prevState, ...data};
    final calendarOAuths = ref.read(localPrefControllerProvider).requireValue.calendarOAuths;
    finalState.removeWhere((key, value) => !(calendarOAuths?.any((e) => e.email == key) ?? false));
    state = AsyncData(finalState);

    ref
        .read(authControllerProvider.notifier)
        .updateUser(user: ref.read(authControllerProvider).requireValue.copyWith(calendarColors: {...userCalendarColors, ...newCalendarColors}));
  }

  Future<void> getMockCalendars() async {
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
    _updateState(data);
  }

  Future<List<String>?> load() async {
    if (ref.watch(shouldUseMockDataProvider)) {
      await getMockCalendars();
      return state.value?.keys.toList();
    }

    LocalPrefEntity? _pref = ref.read(localPrefControllerProvider).value;
    if (_pref == null) throw Failure.unauthorized(StackTrace.current);

    final result = await _repository.fetchCalendarLists(oauth: oauth);

    return result.fold(
      (l) {
        return null;
      },
      (r) async {
        _updateState(r);
        return r.keys.toList();
      },
    );
  }

  Future<void> attachCalendarChangeListener() async {
    if (ref.read(shouldUseMockDataProvider)) return;
    final user = ref.read(authControllerProvider).requireValue;
    final pref = ref.read(localPrefControllerProvider).value;
    if (pref == null) throw Failure.unauthorized(StackTrace.current);
    _repository.attachCalendarChangeListener(user: user, oauth: oauth, calendars: state.value?.values.expand((e) => e).toList() ?? []);
  }
}
