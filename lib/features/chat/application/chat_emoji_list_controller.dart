import 'dart:async';
import 'dart:convert';

import 'package:Visir/config/providers.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/chat/application/chat_channel_list_controller.dart';
import 'package:Visir/features/chat/application/chat_list_controller.dart';
import 'package:Visir/features/chat/application/chat_thread_list_controller.dart';
import 'package:Visir/features/chat/domain/entities/message_channel_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_emoji_entity.dart';
import 'package:Visir/features/chat/domain/entities/state/chat_fetch_emojis_result_entity.dart';
import 'package:Visir/features/chat/infrastructure/repositories/message_repository.dart';
import 'package:Visir/features/chat/providers.dart';
import 'package:Visir/features/common/presentation/utils/extensions/list_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/experimental/persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_emoji_list_controller.g.dart';

@riverpod
class ChatEmojiListController extends _$ChatEmojiListController {
  static final String stringKey = 'global:chat_emoji_list';

  @override
  ChatFetchEmojisResultEntity build({required TabType tabType}) {
    final isSignedIn = ref.watch(isSignedInProvider);
    final teamId = ref.watch(chatConditionProvider(tabType).select((v) => v.channel!.teamId));
    final channelType = ref.watch(chatConditionProvider(tabType).select((v) => v.channel!.type));
    final oauthUniqueId = ref.watch(
      localPrefControllerProvider.select((v) => v.value?.messengerOAuths?.firstWhereOrNull((e) => e.teamId == teamId && e.type == channelType.oAuthType)?.uniqueId),
    );

    if (oauthUniqueId == null) return ChatFetchEmojisResultEntity(emojis: [], sequence: 0);

    ref.listen(
      chatEmojiListControllerInternalProvider(
        isSignedIn: isSignedIn,
        type: channelType,
        oauthUniqueId: oauthUniqueId,
      ).select((v) => v.value ?? ChatFetchEmojisResultEntity(emojis: [], sequence: 0)),
      (prev, next) {
        updateState(next);
      },
    );
    return ChatFetchEmojisResultEntity(emojis: [], sequence: 0);
  }

  Timer? timer;
  void updateState(ChatFetchEmojisResultEntity data) {
    if (timer == null) state = data;
    timer?.cancel();
    timer = Timer(const Duration(milliseconds: kControllerDebouncMillisecond), () {
      state = data;
      timer = null;
    });
  }
}

@riverpod
class ChatEmojiListControllerInternal extends _$ChatEmojiListControllerInternal {
  late ChatRepository _repository;
  OAuthEntity get _oauth => ref.read(localPrefControllerProvider.select((v) => v.value?.messengerOAuths?.firstWhereOrNull((e) => e.uniqueId == oauthUniqueId)))!;

  @override
  Future<ChatFetchEmojisResultEntity> build({required bool isSignedIn, required MessageChannelEntityType type, required String oauthUniqueId}) async {
    _repository = ref.watch(chatRepositoryProvider);

    if (ref.watch(shouldUseMockDataProvider)) return ChatFetchEmojisResultEntity(emojis: [], sequence: 0);

    await persist(
      ref.watch(storageProvider.future),
      key: '${ChatEmojiListController.stringKey}:${isSignedIn}:${_oauth.teamId}:${oauthUniqueId}',
      encode: (ChatFetchEmojisResultEntity state) => jsonEncode(state.toJson()),
      decode: (String encoded) {
        if (ref.watch(shouldUseMockDataProvider)) return ChatFetchEmojisResultEntity(emojis: [], sequence: 0);
        final trimmed = encoded.trim();
        if (trimmed.isEmpty || trimmed == 'null') {
          return ChatFetchEmojisResultEntity(emojis: [], sequence: 0);
        }
        return ChatFetchEmojisResultEntity.fromJson(jsonDecode(trimmed) as Map<String, dynamic>);
      },
      options: Utils.storageOptions,
    ).future;

    final channelEmojis = ref.watch(
      chatChannelListControllerInternalProvider(isSignedIn: isSignedIn, oauthUniqueId: oauthUniqueId).select((v) => v.value?.values.firstOrNull?.emojis ?? []),
    );

    TabType.values.forEach((tabType) {
      final teamId = ref.watch(chatConditionProvider(tabType).select((e) => e.channel?.teamId));
      if (teamId == _oauth.teamId) {
        final channelId = ref.watch(chatConditionProvider(tabType).select((e) => e.channel?.id));
        final threadId = ref.watch(chatConditionProvider(tabType).select((e) => e.threadId));
        if (channelId != null) {
          if (threadId != null) {
            ref.listen(chatThreadListControllerProvider(tabType: tabType), (previous, next) {
              final prevEmojiIds = [...channelEmojis, ...(state.value?.emojis ?? <MessageEmojiEntity>[])].map((e) => e.id).toSet().toList();
              List<String> emojiIds = [];

              final messages = ref.read(chatListControllerProvider(tabType: tabType).select((v) => v?.messages ?? []));
              final threadMessages = ref.read(chatThreadListControllerProvider(tabType: tabType).select((v) => v?.messages ?? []));

              [...messages, ...threadMessages].forEach((e) {
                final data = e.getUserGroupEmojiIds;
                final emojiId = data['emojiIds'] ?? [];
                emojiId.forEach((e) {
                  if (!prevEmojiIds.contains(e)) emojiIds.add(e);
                });
              });

              emojiIds = emojiIds.toSet().toList();
              fetchEmojis(emojiIds: emojiIds, sequence: 0);
            });
          }

          ref.listen(chatListControllerProvider(tabType: tabType), (previous, next) {
            final prevEmojiIds = [...channelEmojis, ...(state.value?.emojis ?? <MessageEmojiEntity>[])].map((e) => e.id).toSet().toList();
            List<String> emojiIds = [];

            final messages = ref.read(chatListControllerProvider(tabType: tabType).select((v) => v?.messages ?? []));
            final threadMessages = ref.read(chatThreadListControllerProvider(tabType: tabType).select((v) => v?.messages ?? []));

            [...messages, ...threadMessages].forEach((e) {
              final data = e.getUserGroupEmojiIds;
              final emojiId = data['emojiIds'] ?? [];
              emojiId.forEach((e) {
                if (!prevEmojiIds.contains(e)) emojiIds.add(e);
              });
            });

            emojiIds = emojiIds.toSet().toList();
            fetchEmojis(emojiIds: emojiIds, sequence: 0);
          });
        }
      }
    });

    final emojis = state.value?.emojis.where((e) => !channelEmojis.any((c) => c.id == e.id)).toList() ?? [];
    return ChatFetchEmojisResultEntity(emojis: [...emojis, ...channelEmojis], sequence: state.value?.sequence ?? 0);
  }

  Future<void> fetchEmojis({required List<String> emojiIds, required int sequence}) async {
    if (ref.read(shouldUseMockDataProvider)) return;
    if (!ref.mounted) return;

    final _pref = ref.read(localPrefControllerProvider).value;
    if (_pref == null) return;

    ref.read(loadingStatusProvider.notifier).update(ChatEmojiListController.stringKey, LoadingState.loading);
    final result = await _repository.fetchEmojis(type: type, oauth: _oauth, emojiIds: emojiIds);
    return result.fold(
      (l) {
        ref.read(loadingStatusProvider.notifier).update(ChatEmojiListController.stringKey, LoadingState.error);
      },
      (r) {
        ref.read(loadingStatusProvider.notifier).update(ChatEmojiListController.stringKey, LoadingState.success);
        if (r == null) return;
        if (!ref.mounted) return;
        final newState = state.value;
        final newEmojis = [...(newState?.emojis ?? <MessageEmojiEntity>[]), ...r].unique((e) => e.id);
        state = AsyncData(ChatFetchEmojisResultEntity(emojis: newEmojis, sequence: sequence));
      },
    );
  }
}
