import 'dart:async';
import 'dart:convert';

import 'package:Visir/config/providers.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/chat/domain/entities/message_channel_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_group_entity.dart';
import 'package:Visir/features/chat/domain/entities/state/chat_fetch_groups_result_entity.dart';
import 'package:Visir/features/chat/infrastructure/repositories/message_repository.dart';
import 'package:Visir/features/chat/providers.dart';
import 'package:Visir/features/common/presentation/utils/extensions/list_extension.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:emoji_extension/emoji_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/experimental/persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_group_list_controller.g.dart';

@riverpod
class ChatGroupListController extends _$ChatGroupListController {
  static final String stringKey = 'global:chat_group_list';

  @override
  ChatFetchGroupsResultEntity build({required TabType tabType}) {
    final isSignedIn = ref.watch(isSignedInProvider);
    final teamId = ref.watch(chatConditionProvider(tabType).select((v) => v.channel!.teamId));
    final channelType = ref.watch(chatConditionProvider(tabType).select((v) => v.channel!.type));
    final oauthUniqueId = ref.watch(
      localPrefControllerProvider.select((v) => v.value?.messengerOAuths?.firstWhereOrNull((e) => e.teamId == teamId && e.type == channelType.oAuthType)?.uniqueId),
    );

    if (oauthUniqueId == null) return ChatFetchGroupsResultEntity(groups: [], sequence: 0);

    ref.listen(
      chatGroupListControllerInternalProvider(
        isSignedIn: isSignedIn,
        type: channelType,
        oauthUniqueId: oauthUniqueId,
      ).select((v) => v.value ?? ChatFetchGroupsResultEntity(groups: [], sequence: 0)),
      (prev, next) {
        updateState(next);
      },
    );
    return ChatFetchGroupsResultEntity(groups: [], sequence: 0);
  }

  Timer? timer;
  void updateState(ChatFetchGroupsResultEntity data) {
    if (timer == null) state = data;
    timer?.cancel();
    timer = Timer(const Duration(milliseconds: kControllerDebouncMillisecond), () {
      state = data;
      timer = null;
    });
  }
}

@riverpod
class ChatGroupListControllerInternal extends _$ChatGroupListControllerInternal {
  late ChatRepository _repository;
  OAuthEntity get _oauth => ref.read(localPrefControllerProvider.select((v) => v.value?.messengerOAuths?.firstWhereOrNull((e) => e.uniqueId == oauthUniqueId)))!;

  @override
  Future<ChatFetchGroupsResultEntity> build({required bool isSignedIn, required MessageChannelEntityType type, required String oauthUniqueId}) async {
    _repository = ref.watch(chatRepositoryProvider);

    if (ref.watch(shouldUseMockDataProvider)) return ChatFetchGroupsResultEntity(groups: [], sequence: 0);

    await persist(
      ref.watch(storageProvider.future),
      key: '${ChatGroupListController.stringKey}:${isSignedIn}:${_oauth.teamId}:${type.name}:${oauthUniqueId}',
      encode: (ChatFetchGroupsResultEntity state) => jsonEncode(state.toJson()),
      decode: (String encoded) {
        if (ref.watch(shouldUseMockDataProvider)) return ChatFetchGroupsResultEntity(groups: [], sequence: 0);
        final trimmed = encoded.trim();
        if (trimmed.isEmpty || trimmed == 'null') {
          return ChatFetchGroupsResultEntity(groups: [], sequence: 0);
        }
        return ChatFetchGroupsResultEntity.fromJson(jsonDecode(trimmed) as Map<String, dynamic>);
      },
      options: StorageOptions(destroyKey: ref.watch(authControllerProvider.select((value) => value.requireValue.id))),
    ).future;

    fetchGroups(groupIds: [], sequence: 0);
    return state.value ?? ChatFetchGroupsResultEntity(groups: [], sequence: 0);
  }

  Future<void> fetchGroups({required List<String> groupIds, required int sequence}) async {
    if (ref.read(shouldUseMockDataProvider)) return;
    if (!ref.mounted) return;

    ref.read(loadingStatusProvider.notifier).update(ChatGroupListController.stringKey, LoadingState.loading);
    final result = await _repository.fetchGroups(type: type, oauth: _oauth, groupIds: groupIds);
    return result.fold(
      (l) {
        ref.read(loadingStatusProvider.notifier).update(ChatGroupListController.stringKey, LoadingState.error);
      },
      (r) {
        ref.read(loadingStatusProvider.notifier).update(ChatGroupListController.stringKey, LoadingState.success);
        if (r == null) return;
        if (!ref.mounted) return;
        final newState = state.value;
        final newGroups = [...(newState?.groups ?? <MessageGroupEntity>[]), ...r].unique((e) => e.id);
        state = AsyncData(ChatFetchGroupsResultEntity(groups: newGroups, sequence: sequence));
      },
    );
  }
}
