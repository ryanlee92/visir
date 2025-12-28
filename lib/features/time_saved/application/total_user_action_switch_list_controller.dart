import 'dart:async';
import 'dart:convert';

import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/common/domain/failures/failure.dart';
import 'package:Visir/features/common/presentation/utils/log_event.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/time_saved/domain/entities/total_user_action_entity.dart';
import 'package:Visir/features/time_saved/domain/entities/user_action_entity.dart';
import 'package:Visir/features/time_saved/domain/entities/user_action_switch_count_entity.dart';
import 'package:Visir/features/time_saved/domain/entities/user_action_switch_entity.dart';
import 'package:Visir/features/time_saved/infrastructure/repositories/user_action_switch_repository.dart';
import 'package:Visir/features/time_saved/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'total_user_action_switch_list_controller.g.dart';

final totalUserActionSwitchListControllerProvider = Provider.autoDispose<AsyncValue<TotalUserActionEntity>>((ref) {
  final isSignedIn = ref.watch(authControllerProvider.select((v) => v.requireValue.isSignedIn));
  return ref.watch(totalUserActionSwitchListControllerInternalProvider(isSignedIn: isSignedIn));
});

final _totalUserActionSwitchListControllerNotifierProvider = Provider.autoDispose<TotalUserActionSwitchListControllerInternal>((ref) {
  final isSignedIn = ref.watch(authControllerProvider.select((v) => v.requireValue.isSignedIn));
  return ref.watch(totalUserActionSwitchListControllerInternalProvider(isSignedIn: isSignedIn).notifier);
});

extension TotalUserActionSwitchListControllerProviderX on ProviderListenable<AsyncValue<TotalUserActionEntity>> {
  ProviderListenable<TotalUserActionSwitchListControllerInternal> get notifier => _totalUserActionSwitchListControllerNotifierProvider;
}

@riverpod
class TotalUserActionSwitchListControllerInternal extends _$TotalUserActionSwitchListControllerInternal {
  late UserActionSwitchRepository _repository;

  DateTime updatedTimestamp = DateTime.now();
  DateTime lastLocalUpdatedTimestamp = DateTime.now();

  List<UserActionSwitchCountEntity> get userActionSwitchList => [...state.value?.userActions ?? []];

  @override
  Future<TotalUserActionEntity> build({required bool isSignedIn}) async {
    _repository = ref.watch(userActionSwitchRepositoryProvider);

    if (ref.watch(shouldUseMockDataProvider)) {
      unawaited(getMockList());
      return TotalUserActionEntity(userActions: []);
    }

    unawaited(refresh());
    return state.value ?? TotalUserActionEntity(userActions: []);
  }

  Future<void> getMockList() async {
    final value = await rootBundle.loadString('assets/mock/time_saved/user_action_switch_count.json');
    final list = (jsonDecode(value) as List<dynamic>).map((e) => UserActionSwitchCountEntity.fromJson(e)).toList();
    _updateState(list: list, updatedTimestamp: DateTime.now());
  }

  Future<void> refresh() async {
    if (!isSignedIn) return;
    final _pref = ref.read(localPrefControllerProvider).value;
    if (_pref == null) throw Failure.unauthorized(StackTrace.current);
    final user = ref.read(authControllerProvider.select((value) => value.requireValue));
    final eventResult = await _repository.fetchUserActionSwitchList(
      pref: _pref,
      userId: user.id,
      fetchLocal: false,
      createdAtAfter: DateUtils.dateOnly(DateTime.now()).subtract(Duration(days: user.userTotalDays)),
    );

    return eventResult.fold((l) {}, (r) {
      _updateState(list: r, updatedTimestamp: DateTime.now());
      final hourlyWage = ref.read(hourlyWageProvider);
      setAnalyticsUserProfile(user: user, moneySaved: (r.totalWastedTime * hourlyWage).round());
    });
  }

  Future<void> updateUserActionSwitch({required UserActionSwitchEntity switchAction}) async {
    if (switchAction.isTypeSwitched || switchAction.isTypeWithIdentifierSwitched) {
      Duration standard = const Duration(minutes: 9, seconds: 30);
      final lowFocusDuration = switchAction.nextAction.createdAt!.difference(switchAction.prevAction.createdAt!).inMilliseconds <= standard.inMilliseconds
          ? switchAction.nextAction.createdAt!.difference(switchAction.prevAction.createdAt!)
          : const Duration(minutes: 5);

      final newList = userActionSwitchList.map((e) {
        if (e.prevAction.typeWithIdentifier == switchAction.prevAction.typeWithIdentifier && e.nextAction.typeWithIdentifier == switchAction.nextAction.typeWithIdentifier) {
          return e.copyWith(count: e.count + 1, totalLowFocusDuration: e.totalLowFocusDuration + lowFocusDuration.inSeconds);
        }
        return e;
      }).toList();

      _updateState(list: newList, updatedTimestamp: DateTime.now());
    }
  }

  void _updateState({required List<UserActionSwitchCountEntity> list, required DateTime updatedTimestamp}) async {
    if (updatedTimestamp.isBefore(this.updatedTimestamp)) return;

    list = list
      ..sort((a, b) => b.count.compareTo(a.count))
      ..removeWhere((e) => e.prevAction.isError || e.nextAction.isError);

    state = AsyncData(TotalUserActionEntity(userActions: list));
  }
}
