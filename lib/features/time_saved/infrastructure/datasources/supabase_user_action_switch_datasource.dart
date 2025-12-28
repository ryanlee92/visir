import 'package:Visir/features/time_saved/domain/datasources/user_action_switch_datasource.dart';
import 'package:Visir/features/time_saved/domain/entities/user_action_entity.dart';
import 'package:Visir/features/time_saved/domain/entities/user_action_switch_count_entity.dart';
import 'package:Visir/features/time_saved/domain/entities/user_action_switch_entity.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseUserActionSwitchDatasource extends UserActionSwitchDatasource {
  SupabaseClient get client => Supabase.instance.client;
  final userActionSwitchesDatabaseTable = 'user_action_switches';

  @override
  Future<List<UserActionSwitchCountEntity>> fetchUserActionSwitchList({
    required String userId,
    required DateTime createdAtAfter,
    DateTime? lastItemCreatedAt,
  }) async {
    final result = await client.rpc('getactioncountfordaterange', params: {
      'uid': userId,
      'start_date': createdAtAfter.toIso8601String(),
      'end_date': (lastItemCreatedAt ?? DateTime.now()).toIso8601String(),
    });

    return result
        .map((e) {
          return UserActionSwitchCountEntity(
            count: e['cnt'],
            prevAction: UserActionEntity.fromJson(e['prev_action_id']),
            nextAction: UserActionEntity.fromJson(e['next_action_id']),
            totalLowFocusDuration: e['total_low_focus_duration_seconds'].toDouble(),
          );
        })
        .whereType<UserActionSwitchCountEntity>()
        .toList();
  }

  @override
  Future<Map<DateTime, List<UserActionSwitchCountEntity>>> fetchUserActionSwitchListByDate({required String userId, required DateTime createdAtAfter}) async {
    final result = await client.rpc('get_user_action_switch_by_date', params: {
      'uid': userId,
      'start_date': createdAtAfter.toIso8601String(),
      'end_date': DateTime.now().toIso8601String(),
    });

    return Map<DateTime, List<UserActionSwitchCountEntity>>.fromEntries(
      result.entries.map((entry) {
        final key = entry.key as String;
        final value = entry.value as List;
        return MapEntry<DateTime, List<UserActionSwitchCountEntity>>(
          DateUtils.dateOnly(DateTime.parse(key)), // 시간 정보를 제거하여 일관성 유지
          value
              .map((e) => UserActionSwitchCountEntity(
                    count: e['cnt'],
                    prevAction: UserActionEntity.fromJson(e['prev']),
                    nextAction: UserActionEntity.fromJson(e['next']),
                    totalLowFocusDuration: e['total_low_focus_duration_seconds'].toDouble(),
                  ))
              .whereType<UserActionSwitchCountEntity>()
              .toList(),
        );
      }).cast<MapEntry<DateTime, List<UserActionSwitchCountEntity>>>(),
    );
  }

  @override
  Future<void> saveUserActionSwitch({required UserActionSwitchEntity userActionSwitch}) async {
    await client.from(userActionSwitchesDatabaseTable).upsert(userActionSwitch.toJson());
  }

  @override
  Future<void> cacheUserActionSwtichList({required List<UserActionSwitchCountEntity> list}) {
    throw UnimplementedError();
  }

  @override
  Future<void> cacheUserActionSwitchListByDate({required Map<DateTime, List<UserActionSwitchCountEntity>> list}) {
    throw UnimplementedError();
  }
}
