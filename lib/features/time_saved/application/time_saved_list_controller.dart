import 'dart:async';
import 'dart:convert';

import 'package:Visir/config/providers.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/common/domain/failures/failure.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/time_saved/application/user_action_switch_list_controller.dart';
import 'package:Visir/features/time_saved/domain/entities/user_action_entity.dart';
import 'package:Visir/features/time_saved/domain/entities/user_action_switch_count_entity.dart';
import 'package:Visir/features/time_saved/infrastructure/repositories/user_action_switch_repository.dart';
import 'package:Visir/features/time_saved/presentation/screens/time_saved_screen.dart';
import 'package:Visir/features/time_saved/providers.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/experimental/persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'time_saved_list_controller.g.dart';

final timeSavedListControllerProvider = Provider.autoDispose<AsyncValue<Map<DateTime, List<UserActionSwitchCountEntity>>>>((ref) {
  final viewType = ref.watch(timeSavedViewTypeProvider);
  final isSignedIn = ref.watch(authControllerProvider.select((v) => v.requireValue.isSignedIn));
  return ref.watch(timeSavedListControllerInternalProvider(viewType: viewType, isSignedIn: isSignedIn));
});

final _timeSavedListControllerNotifierProvider = Provider.autoDispose<TimeSavedListControllerInternal>((ref) {
  final viewType = ref.watch(timeSavedViewTypeProvider);
  final isSignedIn = ref.watch(authControllerProvider.select((v) => v.requireValue.isSignedIn));
  return ref.watch(timeSavedListControllerInternalProvider(viewType: viewType, isSignedIn: isSignedIn).notifier);
});

extension TimeSavedListControllerProviderX on ProviderListenable<AsyncValue<Map<DateTime, List<UserActionSwitchCountEntity>>>> {
  ProviderListenable<TimeSavedListControllerInternal> get notifier => _timeSavedListControllerNotifierProvider;
}

@riverpod
class TimeSavedListControllerInternal extends _$TimeSavedListControllerInternal {
  late UserActionSwitchRepository _repository;

  ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);

  Map<DateTime, List<UserActionSwitchCountEntity>> get userActionSwitch => {...state.value ?? {}};
  List<UserActionSwitchCountEntity> get mergedUserActionSwitchList =>
      groupBy(userActionSwitch.values.expand((e) => e).toList(), (e) => '${e.prevAction.typeWithIdentifier}-${e.nextAction.typeWithIdentifier}').values.map((e) {
        final count = e.totalCount;
        final totalLowFocusDuration = e.totalLowFocusDuration;

        return UserActionSwitchCountEntity(prevAction: e.first.prevAction, nextAction: e.first.nextAction, count: count, totalLowFocusDuration: totalLowFocusDuration * 3600);
      }).toList();

  @override
  Future<Map<DateTime, List<UserActionSwitchCountEntity>>> build({required TimeSavedViewType viewType, required bool isSignedIn}) async {
    _repository = ref.watch(userActionSwitchRepositoryProvider);

    if (ref.watch(shouldUseMockDataProvider)) {
      _loadMockDataByViewType(viewType);
      return {};
    }

    // shouldUseMockDataProvider가 false이므로 isSignedIn은 true입니다
    // 따라서 userId는 안전하게 가져올 수 있습니다
    final userId = ref.watch(authControllerProvider.select((value) => value.requireValue.id));

    await persist(
      ref.watch(storageProvider.future),
      key: 'time_saved_list_${isSignedIn}_${viewType.name}',
      encode: (Map<DateTime, List<UserActionSwitchCountEntity>> state) =>
          jsonEncode(Map.fromEntries(state.entries.map((e) => MapEntry(e.key.toIso8601String(), e.value.map((e) => e.toJson()).toList())).toList())),
      decode: (String encoded) {
        if (ref.watch(shouldUseMockDataProvider)) return {};
        final trimmed = encoded.trim();
        if (trimmed.isEmpty || trimmed == 'null') {
          return {};
        }
        return Map.fromEntries(
          (jsonDecode(trimmed) as Map<String, dynamic>).entries
              .map((e) => MapEntry(DateTime.parse(e.key), (e.value as List<dynamic>).map((item) => UserActionSwitchCountEntity.fromJson(item as Map<String, dynamic>)).toList()))
              .toList(),
        );
      },
      options: StorageOptions(destroyKey: userId),
    ).future;

    refresh();

    return state.value ?? {};
  }

  Future<void> refresh() async {
    final _pref = ref.read(localPrefControllerProvider).value;
    final user = ref.read(authControllerProvider).requireValue;
    if (ref.read(shouldUseMockDataProvider)) return;
    if (_pref == null) throw Failure.unauthorized(StackTrace.current);

    final today = DateUtils.dateOnly(DateTime.now());

    isLoadingNotifier.value = true;

    final results = await Future.wait(
      viewType.getSeparatorInDays(user.createdAt ?? today).mapIndexed((index, e) {
        final lastItemCreatedAt = index < viewType.getSeparatorInDays(user.createdAt ?? today).length - 1
            ? viewType.getSeparatorInDays(user.createdAt ?? today)[index + 1]
            : DateTime.now();
        return _repository.fetchUserActionSwitchList(pref: _pref, userId: user.id, fetchLocal: false, createdAtAfter: e, lastItemCreatedAt: lastItemCreatedAt);
      }),
    );

    isLoadingNotifier.value = false;

    final data = Map.fromEntries(
      viewType.getSeparatorInDays(user.createdAt ?? today).mapIndexed((index, key) {
        final e = results[index];
        final list = e.fold((l) => List<UserActionSwitchCountEntity>.empty(), (r) => r).where((e) => !e.prevAction.isError && !e.nextAction.isError).toList();
        return MapEntry(key, list);
      }),
    );

    _updateState(data: data);
  }

  void _updateState({required Map<DateTime, List<UserActionSwitchCountEntity>> data}) async {
    state = AsyncData(data);
  }

  Future<Map<DateTime, List<UserActionSwitchCountEntity>>> _loadMockDataByViewType(TimeSavedViewType viewType) async {
    final basePath = 'assets/mock/time_saved/by_view_type/';
    final fileName = switch (viewType) {
      TimeSavedViewType.last7days => 'last7days',
      TimeSavedViewType.last14days => 'last14days',
      TimeSavedViewType.last28days => 'last28days',
      TimeSavedViewType.last12weeks => 'last12weeks',
      TimeSavedViewType.last12months => 'last12months',
      TimeSavedViewType.thisWeek => 'thisWeek',
      TimeSavedViewType.thisMonth => 'thisMonth',
      TimeSavedViewType.thisYear => 'thisYear',
      TimeSavedViewType.total => 'total',
    };

    final jsonString = await rootBundle.loadString('$basePath$fileName.json');
    final List<dynamic> raw = jsonDecode(jsonString) as List<dynamic>;

    final Map<DateTime, List<UserActionSwitchCountEntity>> data = {};
    for (final bucket in raw) {
      final dt = DateTime.parse(bucket['date'] as String);
      final List listRaw = bucket['list'] as List;
      final list = listRaw
          .map(
            (item) => UserActionSwitchCountEntity(
              count: item['count'] as int,
              prevAction: UserActionEntity.fromJson(item['prev_action'] as Map<String, dynamic>),
              nextAction: UserActionEntity.fromJson(item['next_action'] as Map<String, dynamic>),
              totalLowFocusDuration: (item['total_low_focus_duration'] as num).toDouble(),
            ),
          )
          .where((e) => !e.prevAction.isError && !e.nextAction.isError)
          .toList();

      data[dt] = list;
    }

    _updateState(data: data);
    return data;
  }
}
