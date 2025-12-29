import 'dart:convert';

import 'package:Visir/config/providers.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/common/domain/entities/connection_entity.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/experimental/persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connection_list_controller.g.dart';

@riverpod
class ConnectionListController extends _$ConnectionListController {
  @override
  Future<Map<String, List<ConnectionEntity>>> build() async {
    if (ref.watch(shouldUseMockDataProvider)) return {};

    if (!ref.watch(shouldUseMockDataProvider)) {
      await persist(
        ref.watch(storageProvider.future),
        key: 'connection_list',
        encode: (Map<String, List<ConnectionEntity>> state) =>
            jsonEncode(Map.fromEntries(state.entries.map((e) => MapEntry(e.key, e.value.map((e) => e.toJson()).toList())).toList())),
        decode: (String encoded) => Map.fromEntries(
          (jsonDecode(encoded) as Map<String, dynamic>).entries.map(
            (e) => MapEntry(e.key, (e.value as List).map((item) => ConnectionEntity.fromJson(item as Map<String, dynamic>)).toList()),
          ),
        ),
        options: Utils.storageOptions,
      ).future;
    }

    return state.value ?? {};
  }

  Future<void> set({required String provider, required List<ConnectionEntity> connectionList}) async {
    final newState = {...(state.value ?? {})};
    newState[provider] = connectionList;
    state = AsyncData(newState);
  }

  Future<List<ConnectionEntity>> search({required String provider, required String query}) async {
    final newState = {...(state.value ?? {})};
    return newState[provider]?.where((e) => e.name?.contains(query) == true || e.email?.contains(query) == true).toList() ?? [];
  }
}
