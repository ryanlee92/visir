import 'dart:async';
import 'dart:convert';

import 'package:Visir/config/providers.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/common/presentation/utils/extensions/list_extension.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/inbox/application/inbox_list_controller.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_config_entity.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_entity.dart';
import 'package:Visir/features/inbox/infrastructure/repositories/inbox_repository.dart';
import 'package:Visir/features/inbox/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/experimental/persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'inbox_config_controller.g.dart';

@riverpod
class InboxConfigListController extends _$InboxConfigListController {
  late InboxConfigControllerInternal _controller;
  static String stringKey = '${TabType.home.name}:inboxConfigs';

  @override
  InboxConfigFetchListEntity? build() {
    final isSearch = ref.watch(inboxListIsSearchProvider);
    final date = ref.watch(inboxListDateProvider);
    final isSignedIn = ref.watch(authControllerProvider.select((v) => v.requireValue.isSignedIn));

    _controller = ref.watch(inboxConfigControllerInternalProvider(isSearch: isSearch, year: date.year, month: date.month, day: date.day, isSignedIn: isSignedIn).notifier);

    ref.listen(inboxConfigControllerInternalProvider(isSearch: isSearch, year: date.year, month: date.month, day: date.day, isSignedIn: isSignedIn), (prev, next) {
      updateState(next.value);
    });

    return null;
  }

  Future<void> updateInboxConfig({required List<InboxConfigEntity> configs, bool? onlyLocal}) async {
    return _controller.updateInboxConfig(configs: configs, onlyLocal: onlyLocal ?? false);
  }

  Timer? timer;
  void updateState(InboxConfigFetchListEntity? data) {
    if (timer == null) state = data;
    timer?.cancel();
    timer = Timer(const Duration(milliseconds: kControllerDebouncMillisecond), () {
      state = data;
      timer = null;
    });
  }
}

@riverpod
class InboxConfigControllerInternal extends _$InboxConfigControllerInternal {
  late InboxRepository _inboxRepository;

  List<InboxEntity> _prevInboxes = [];

  @override
  Future<InboxConfigFetchListEntity?> build({required bool isSearch, required int year, required int month, required int day, required bool isSignedIn}) async {
    _inboxRepository = ref.watch(inboxRepositoryProvider);

    if (ref.watch(shouldUseMockDataProvider)) return null;
    if (isSearch) return null;

    // shouldUseMockDataProvider가 false이므로 isSignedIn은 true입니다
    // 따라서 userId는 안전하게 가져올 수 있습니다
    final userId = ref.watch(authControllerProvider.select((v) => v.requireValue.id));

    final provider = inboxListControllerInternalProvider(isSearch: isSearch, year: year, month: month, day: day, isSignedIn: isSignedIn);

    await persist(
      ref.watch(storageProvider.future),
      key: '${InboxConfigListController.stringKey}:${isSignedIn}:${isSearch ? 'search' : '${year}_${month}_${day}'}',
      encode: (InboxConfigFetchListEntity? state) => state == null ? '' : jsonEncode(state.toJson()),
      decode: (String encoded) {
        if (isSearch) return null;
        final trimmed = encoded.trim();
        if (trimmed.isEmpty || trimmed == 'null') {
          return InboxConfigFetchListEntity(configs: [], sequence: 0);
        }
        return InboxConfigFetchListEntity.fromJson(jsonDecode(trimmed) as Map<String, dynamic>);
      },
      options: StorageOptions(destroyKey: userId + '1'),
    ).future;

    ref.listen(provider.select((e) => e.value?.sequence ?? 0), (previous, next) {
      final sequence = next;
      if (sequence <= (state.value?.sequence ?? -1)) return;
      final inboxes = ref.read(provider).value?.inboxes ?? [];
      _prevInboxes = [..._prevInboxes, ...inboxes].unique((e) => e.id).toList();
      setInboxConfig(_prevInboxes, sequence, DateTime(year, month, day));
    });

    return state.value;
  }

  Future<void> _processing = Future.value();

  Future<void> setInboxConfig(List<InboxEntity> inboxes, int sequence, DateTime? date) async {
    final previous = _processing;
    final completer = Completer<void>();
    _processing = completer.future;

    try {
      await previous;
    } catch (_) {}

    try {
      if (!ref.mounted) return;
      final r = state.value;
      final _configs = r?.configs ?? <InboxConfigEntity>[];
      final restInboxes = inboxes.where((e) => !_configs.any((s) => s.id == e.id)).toList();

      if (ref.read(shouldUseMockDataProvider)) return;

      final userId = ref.read(authControllerProvider.select((v) => v.requireValue.id));
      ref.read(loadingStatusProvider.notifier).update(InboxConfigListController.stringKey, LoadingState.loading);
      await _inboxRepository
          .fetchInboxConfig(configIds: restInboxes.map((e) => e.id).toList(), userId: userId)
          .then((restConfigs) {
            if (!ref.mounted) return;
            ref.read(loadingStatusProvider.notifier).update(InboxConfigListController.stringKey, LoadingState.success);

            return restConfigs.fold((l) {}, (r2) {
              final finalConfigs = [..._configs, ...r2];
              state = AsyncData(InboxConfigFetchListEntity(configs: finalConfigs, sequence: sequence));
            });
          })
          .catchError((e) {
            ref.read(loadingStatusProvider.notifier).update(InboxConfigListController.stringKey, LoadingState.error);
          });
    } finally {
      if (!completer.isCompleted) {
        completer.complete();
      }
    }
  }

  Future<void> updateInboxConfig({required List<InboxConfigEntity> configs, required bool onlyLocal}) async {
    final prevState = state;
    state = AsyncData(
      InboxConfigFetchListEntity(configs: [...configs, ...(state.value?.configs ?? <InboxConfigEntity>[])].unique((e) => e.id).toList(), sequence: state.value?.sequence ?? 0),
    );

    if (onlyLocal) return;
    if (ref.read(shouldUseMockDataProvider)) return;

    final result = await _inboxRepository.saveInboxConfig(configs: configs);
    result.fold((l) {
      state = prevState;
    }, (r) {});
  }
}
