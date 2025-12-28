import 'dart:convert';

import 'package:Visir/config/providers.dart';
import 'package:Visir/features/calendar/infrastructure/datasources/remote/google_calendar_datasource.dart';
import 'package:Visir/features/calendar/infrastructure/datasources/remote/microsoft_calendar_datasource.dart';
import 'package:Visir/features/calendar/infrastructure/datasources/remote/supabase_calendar_datasource.dart';
import 'package:Visir/features/calendar/infrastructure/repositories/calendar_repository.dart';
import 'package:Visir/features/calendar/presentation/screens/main_calendar_widget.dart';
import 'package:Visir/features/common/presentation/utils/extensions/list_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:Visir/features/task/domain/entities/project_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@riverpod
SupabaseCalendarDatasource supabaseCalendarDatasource(Ref ref) {
  return SupabaseCalendarDatasource();
}

@riverpod
GoogleCalendarDatasource googleCalendarDatasource(Ref ref) {
  return GoogleCalendarDatasource();
}

@riverpod
MicrosoftCalendarDatasource microsoftCalendarDatasource(Ref ref) {
  return MicrosoftCalendarDatasource();
}

@riverpod
CalendarRepository calendarRepository(Ref ref) {
  return CalendarRepository(
    datasources: {
      DatasourceType.google: ref.watch(googleCalendarDatasourceProvider),
      DatasourceType.microsoft: ref.watch(microsoftCalendarDatasourceProvider),
      DatasourceType.supabase: ref.watch(supabaseCalendarDatasourceProvider),
    },
  );
}

@riverpod
class CalendarDisplayDate extends _$CalendarDisplayDate {
  @override
  Map<CalendarDisplayType, DateTime> build(TabType tabType) {
    return {CalendarDisplayType.main: DateTime.now(), CalendarDisplayType.sideMonth: DateTime.now(), CalendarDisplayType.sideAgenda: DateTime.now()};
  }

  void updateDate(CalendarDisplayType type, DateTime date) {
    if (state[type]?.year == date.year && state[type]?.month == date.month && state[type]?.day == date.day) return;
    state = {...state, type: date};
  }
}

@riverpod
class CalendarTargetMonth extends _$CalendarTargetMonth {
  @override
  Map<CalendarAppBarType, DateTime> build(TabType tabType) {
    ref.listen(calendarDisplayDateProvider(tabType).select((v) => v[CalendarDisplayType.main]), (prev, next) {
      _updateMonth(CalendarAppBarType.main, next ?? DateTime.now());
    });
    ref.listen(calendarDisplayDateProvider(tabType).select((v) => v[CalendarDisplayType.sideMonth]), (prev, next) {
      _updateMonth(CalendarAppBarType.side, next ?? DateTime.now());
    });
    ref.listen(calendarDisplayDateProvider(tabType).select((v) => v[CalendarDisplayType.sideAgenda]), (prev, next) {
      _updateMonth(CalendarAppBarType.side, next ?? DateTime.now());
    });

    return {CalendarAppBarType.main: DateTime.now(), CalendarAppBarType.side: DateTime.now()};
  }

  void _updateMonth(CalendarAppBarType type, DateTime date) {
    if (state[type]?.year == date.year && state[type]?.month == date.month) return;
    state = {...state, type: date};
  }
}

enum CalendarAppBarType { main, side }

enum CalendarDisplayType { main, sideMonth, sideAgenda }

@riverpod
class CalendarTypeChanger extends _$CalendarTypeChanger {
  @override
  CalendarType build(TabType tabType) {
    if (tabType != TabType.calendar && tabType != TabType.home) return CalendarType.threeDays;
    if (tabType == TabType.home && PlatformX.isMobileView) return CalendarType.threeDays;

    final defaultValue = tabType == TabType.home ? CalendarType.threeDays : CalendarType.values[(PlatformX.isDesktopView ? 4 : 2)];
    if (ref.watch(shouldUseMockDataProvider)) return defaultValue;

    final localPref = ref.watch(localPrefControllerProvider).value;
    final savedType = localPref?.prefCalendarType[tabType.name];
    if (savedType != null) {
      try {
        return CalendarType.values.firstWhere((e) => e.name == savedType);
      } catch (e) {
        return defaultValue;
      }
    }

    return defaultValue;
  }

  void updateType(CalendarType type) {
    if (tabType != TabType.calendar && tabType != TabType.home) return;
    if (tabType == TabType.home && PlatformX.isMobileView) return;
    if (state == type) return;
    state = type;
    final localPref = ref.read(localPrefControllerProvider).value;
    final currentTypes = localPref?.prefCalendarType ?? {};
    ref.read(localPrefControllerProvider.notifier).set(calendarType: {...currentTypes, tabType.name: type.name});
  }
}

@riverpod
class CalendarHide extends _$CalendarHide {
  @override
  List<String> build(TabType tabType) {
    if (ref.watch(shouldUseMockDataProvider)) return [];

    // sharedPref에서 읽기
    final sharedPrefAsync = ref.read(sharedPreferencesProvider);
    final sharedPref = sharedPrefAsync.asData?.value;
    if (sharedPref == null) return [];
    final jsonString = sharedPref.getString('calendar_hide_${tabType.name}');
    if (jsonString == null || jsonString.isEmpty) return [];
    try {
      final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded.cast<String>();
    } catch (e) {
      return [];
    }
  }

  void add(String calendarId) {
    final currentList = state;
    final newList = [...currentList, calendarId].unique();
    _updateSharedPref(newList);
  }

  void remove(String calendarId) {
    final newList = state.where((e) => e != calendarId).toList();
    _updateSharedPref(newList);
  }

  void toggle(String calendarId) {
    if (state.contains(calendarId)) {
      remove(calendarId);
    } else {
      add(calendarId);
    }
  }

  void _updateSharedPref(List<String> newList) async {
    state = newList;
    final sharedPref = await ref.read(sharedPreferencesProvider.future);
    await sharedPref.setString('calendar_hide_${tabType.name}', jsonEncode(newList));
  }
}

@riverpod
class CalendarIntervalScale extends _$CalendarIntervalScale {
  @override
  double build(TabType tabType) {
    if (ref.watch(shouldUseMockDataProvider)) return 60;

    final localPref = ref.watch(localPrefControllerProvider).value;
    return localPref?.prefCalendarIntervalScale[tabType.name] ?? 60;
  }

  void updateScale(double scale) {
    state = scale;
    final localPref = ref.read(localPrefControllerProvider).value;
    final currentScales = localPref?.prefCalendarIntervalScale ?? {};
    ref.read(localPrefControllerProvider.notifier).set(calendarIntervalScale: {...currentScales, tabType.name: scale});
  }
}

@riverpod
class ProjectHide extends _$ProjectHide {
  @override
  List<String> build(TabType tabType) {
    if (ref.watch(shouldUseMockDataProvider)) return [];

    // sharedPref에서 읽기
    final sharedPrefAsync = ref.read(sharedPreferencesProvider);
    final sharedPref = sharedPrefAsync.asData?.value;
    if (sharedPref == null) return [];
    final jsonString = sharedPref.getString('project_hide_${tabType.name}');
    if (jsonString == null || jsonString.isEmpty) return [];
    try {
      final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded.cast<String>();
    } catch (e) {
      return [];
    }
  }

  void add(String projectId) {
    final currentList = state;
    final newList = [...currentList, projectId].unique();
    _updateSharedPref(newList);
  }

  void remove(String projectId) {
    final newList = state.where((e) => e != projectId).toList();
    _updateSharedPref(newList);
  }

  void toggle(ProjectEntity project) {
    if (state.contains(project.uniqueId)) {
      remove(project.uniqueId);
    } else {
      add(project.uniqueId);
    }
  }

  void _updateSharedPref(List<String> newList) async {
    state = newList;
    final sharedPref = await ref.read(sharedPreferencesProvider.future);
    await sharedPref.setString('project_hide_${tabType.name}', jsonEncode(newList));
  }
}

@riverpod
class LastUsedCalendarId extends _$LastUsedCalendarId {
  @override
  List<String> build() {
    if (ref.watch(shouldUseMockDataProvider)) return [];

    final localPref = ref.watch(localPrefControllerProvider).value;
    return localPref?.prefLastUsedCalendarId ?? [];
  }

  void set(String calendarId) {
    final newList = [calendarId, ...state].unique().take(5).toList();
    state = newList;
    ref.read(localPrefControllerProvider.notifier).set(lastUsedCalendarId: newList);
  }
}

@riverpod
class LastUsedProjectId extends _$LastUsedProjectId {
  @override
  List<String> build() {
    if (ref.watch(shouldUseMockDataProvider)) return [];

    final localPref = ref.watch(localPrefControllerProvider).value;
    return localPref?.prefLastUsedProjectId ?? [];
  }

  void set(String projectId) {
    final newList = [projectId, ...state].unique().take(5).toList();
    state = newList;
    ref.read(localPrefControllerProvider.notifier).set(lastUsedProjectId: newList);
  }
}
