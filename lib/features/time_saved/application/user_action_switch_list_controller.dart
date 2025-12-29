import 'dart:async';
import 'dart:convert';

import 'package:Visir/config/providers.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/time_saved/domain/entities/user_action_entity.dart';
import 'package:Visir/features/time_saved/domain/entities/user_action_switch_count_entity.dart';
import 'package:Visir/features/time_saved/domain/entities/user_action_switch_entity.dart';
import 'package:Visir/features/time_saved/infrastructure/repositories/user_action_switch_repository.dart';
import 'package:Visir/features/time_saved/presentation/screens/time_saved_screen.dart';
import 'package:Visir/features/time_saved/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/experimental/persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'user_action_switch_list_controller.g.dart';

final userActionSwitchListControllerProvider = Provider.autoDispose.family<AsyncValue<List<UserActionSwitchCountEntity>>, TimeSavedViewType>((ref, viewType) {
  final isSignedIn = ref.watch(authControllerProvider.select((v) => v.requireValue.isSignedIn));
  return ref.watch(userActionSwitchListControllerInternalProvider(viewType: viewType, isSignedIn: isSignedIn));
});

final _userActionSwitchListControllerNotifierProvider = Provider.autoDispose.family<UserActionSwitchListControllerInternal, TimeSavedViewType>((ref, viewType) {
  final isSignedIn = ref.watch(authControllerProvider.select((v) => v.requireValue.isSignedIn));
  return ref.watch(userActionSwitchListControllerInternalProvider(viewType: viewType, isSignedIn: isSignedIn).notifier);
});

extension UserActionSwitchListControllerProviderX on ProviderListenable<AsyncValue<List<UserActionSwitchCountEntity>>> {
  static ValueNotifier<double> savedTimeInHoursNotifier = ValueNotifier(0);

  ProviderListenable<UserActionSwitchListControllerInternal> get notifier {
    final provider = this;
    Object? argument;

    try {
      argument = (provider as dynamic).argument as Object?;
    } catch (_) {
      throw StateError('UserActionSwitchListControllerProviderX can only be used on family providers.');
    }

    if (argument == null) {
      return _defaultUserActionSwitchListControllerNotifierProvider;
    }

    if (argument is! TimeSavedViewType) {
      throw StateError('Invalid provider argument for UserActionSwitchListControllerProviderX');
    }
    return _userActionSwitchListControllerNotifierProvider(argument);
  }
}

final defaultUserActionSwitchListControllerProvider = Provider.autoDispose<AsyncValue<List<UserActionSwitchCountEntity>>>((ref) {
  final viewType = ref.watch(timeSavedViewTypeProvider);
  return ref.watch(userActionSwitchListControllerProvider(viewType));
});

final _defaultUserActionSwitchListControllerNotifierProvider = Provider.autoDispose<UserActionSwitchListControllerInternal>((ref) {
  final viewType = ref.watch(timeSavedViewTypeProvider);
  return ref.watch(userActionSwitchListControllerProvider(viewType).notifier);
});

@riverpod
class TimeSavedViewTypeNotifier extends _$TimeSavedViewTypeNotifier {
  @override
  TimeSavedViewType build() {
    return ref.watch(lastTimeSavedViewTypeProvider);
  }

  void set(TimeSavedViewType value) {
    state = value;
  }
}

@riverpod
class UserActionSwitchListControllerInternal extends _$UserActionSwitchListControllerInternal {
  late UserActionSwitchRepository _repository;

  ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);

  UserActionEntity? lastAction;

  DateTime updatedTimestamp = DateTime.now();
  DateTime lastLocalUpdatedTimestamp = DateTime.now();

  List<UserActionSwitchCountEntity> get userActionSwitchList => [...state.value ?? []];

  int get appSwitchingCount {
    final count = userActionSwitchList.totalCount;
    return count;
  }

  @override
  Future<List<UserActionSwitchCountEntity>> build({required TimeSavedViewType viewType, required bool isSignedIn}) async {
    _repository = ref.watch(userActionSwitchRepositoryProvider);

    if (ref.watch(shouldUseMockDataProvider)) {
      getMockList();
      return [];
    }

    await persist(
      ref.watch(storageProvider.future),
      key: 'user_action_switch_list_${isSignedIn}_${viewType.name}',
      encode: (List<UserActionSwitchCountEntity> state) => jsonEncode(state.map((e) => e.toJson()).toList()),
      decode: (String encoded) {
        final trimmed = encoded.trim();
        if (trimmed.isEmpty || trimmed == 'null') {
          return [];
        }
        return (jsonDecode(trimmed) as List<dynamic>).map((e) => UserActionSwitchCountEntity.fromJson(e)).toList();
      },
      options: Utils.storageOptions,
    ).future;

    load();

    return state.value ?? [];
  }

  Future<List<UserActionSwitchCountEntity>> getMockList() async {
    final list = await _loadLocalListForViewType(viewType);
    _updateState(list: list, updatedTimestamp: DateTime.now());
    return list;
  }

  Future<void> load() async {
    if (!ref.mounted) return;
    final _pref = ref.read(localPrefControllerProvider).value;
    if (!ref.mounted) return;
    final user = ref.read(authControllerProvider).requireValue;
    if (ref.read(shouldUseMockDataProvider)) return;
    if (_pref == null) return;

    final today = DateUtils.dateOnly(DateTime.now());
    DateTime? createdAtAfter = viewType.getSeparatorInDays(user.createdAt ?? today).firstOrNull;
    if (createdAtAfter == null) return;

    isLoadingNotifier.value = true;

    final eventResult = await _repository.fetchUserActionSwitchList(pref: _pref, userId: user.id, fetchLocal: false, createdAtAfter: createdAtAfter);

    isLoadingNotifier.value = false;

    return eventResult.fold((l) {}, (r) {
      _updateState(list: r, updatedTimestamp: DateTime.now());
    });
  }

  Future<UserActionSwitchEntity?> saveUserActionSwtich({required UserActionEntity nextAction, required UserActionEntity? prevAction}) async {
    if (prevAction?.isError ?? false || nextAction.isError) return null;

    if (prevAction != null && prevAction.createdAt != null && nextAction.createdAt != null && prevAction.createdAt!.isBefore(nextAction.createdAt!)) {
      final user = ref.read(authControllerProvider).requireValue;
      if (ref.read(shouldUseMockDataProvider)) return null;

      final switchAction = UserActionSwitchEntity(createdAt: DateTime.now(), prevAction: prevAction, nextAction: nextAction, id: Uuid().v4(), userId: user.id);
      Duration standard = const Duration(minutes: 9, seconds: 30);
      final lowFocusDuration = nextAction.createdAt!.difference(prevAction.createdAt!).inMilliseconds <= standard.inMilliseconds
          ? nextAction.createdAt!.difference(prevAction.createdAt!)
          : const Duration(minutes: 5);

      final newList = userActionSwitchList.map((e) {
        if (e.prevAction.typeWithIdentifier == prevAction.typeWithIdentifier && e.nextAction.typeWithIdentifier == nextAction.typeWithIdentifier) {
          return e.copyWith(count: e.count + 1, totalLowFocusDuration: e.totalLowFocusDuration + lowFocusDuration.inSeconds);
        }
        return e;
      }).toList();

      final result = await _repository.saveUserActionSwitch(userActionSwitch: switchAction);

      result.fold((l) {}, (r) {
        lastAction = nextAction;
        _updateState(list: newList, updatedTimestamp: DateTime.now());
      });
      return switchAction;
    }
    return null;
  }

  void _updateState({required List<UserActionSwitchCountEntity> list, required DateTime updatedTimestamp}) async {
    if (updatedTimestamp.isBefore(this.updatedTimestamp)) return;

    list = list
      ..sort((a, b) => b.count.compareTo(a.count))
      ..removeWhere((e) => e.prevAction.isError || e.nextAction.isError);

    state = AsyncData(list);

    UserActionSwitchListControllerProviderX.savedTimeInHoursNotifier.value = list.totalWastedTime;
  }

  Future<List<UserActionSwitchCountEntity>> _loadLocalListForViewType(TimeSavedViewType viewType) async {
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
    final List<dynamic> buckets = jsonDecode(jsonString) as List<dynamic>;

    // Flatten and aggregate by prev-next pair
    final Map<String, UserActionSwitchCountEntity> agg = {};

    for (final bucket in buckets) {
      final List listRaw = bucket['list'] as List;
      for (final item in listRaw) {
        final entity = UserActionSwitchCountEntity(
          count: item['count'] as int,
          prevAction: UserActionEntity.fromJson(item['prev_action'] as Map<String, dynamic>),
          nextAction: UserActionEntity.fromJson(item['next_action'] as Map<String, dynamic>),
          totalLowFocusDuration: (item['total_low_focus_duration'] as num).toDouble(),
        );
        if (entity.prevAction.isError || entity.nextAction.isError) continue;
        final key = entity.id;
        final existing = agg[key];
        if (existing == null) {
          agg[key] = entity;
        } else {
          agg[key] = existing.copyWith(count: existing.count + entity.count, totalLowFocusDuration: existing.totalLowFocusDuration + entity.totalLowFocusDuration);
        }
      }
    }

    return agg.values.toList()..sort((a, b) => b.count.compareTo(a.count));
  }
}
