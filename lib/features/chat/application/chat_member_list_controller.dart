import 'dart:async';
import 'dart:convert';

import 'package:Visir/config/providers.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/chat/application/chat_list_controller.dart';
import 'package:Visir/features/chat/application/chat_thread_list_controller.dart';
import 'package:Visir/features/chat/domain/entities/message_channel_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_member_entity.dart';
import 'package:Visir/features/chat/domain/entities/slack/slack_message_member_entity.dart';
import 'package:Visir/features/chat/domain/entities/state/chat_fetch_members_result_entity.dart';
import 'package:Visir/features/chat/infrastructure/repositories/message_repository.dart';
import 'package:Visir/features/chat/providers.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:emoji_extension/emoji_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/experimental/persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_member_list_controller.g.dart';

@riverpod
class ChatMemberListController extends _$ChatMemberListController {
  static final String stringKey = 'global:chat_member_list';

  late OAuthEntity _oauth;
  late ChatRepository _repository;
  late bool _isSignedIn;

  @override
  ChatFetchMembersResultEntity build({required TabType tabType}) {
    _isSignedIn = ref.watch(isSignedInProvider);
    if (ref.watch(shouldUseMockDataProvider)) {
      getMockMembers().then((value) {
        state = value;
        // Update internal providers for each mock member
        final oauths = ref.read(localPrefControllerProvider.select((v) => v.value?.messengerOAuths ?? []));
        final _membersMap = Map.fromEntries(
          fakeMembersJson.entries.map((e) => MapEntry(e.key, e.value.map((e) => MessageMemberEntity.fromSlack(member: SlackMessageMemberEntity.fromJson(e))).toList())),
        );
        _membersMap.forEach((teamId, members) {
          final oauth = oauths.firstWhereOrNull((o) => o.teamId == teamId);
          if (oauth != null) {
            members.forEach((member) {
              ref.read(chatMemberListControllerInternalProvider(isSignedIn: _isSignedIn, userId: member.id, oauthUniqueId: oauth.uniqueId).notifier).updateState(member);
            });
          }
        });
      });

      return ChatFetchMembersResultEntity(members: [], sequence: 0, loadedMembers: []);
    }

    _repository = ref.watch(chatRepositoryProvider);

    final teamId = ref.watch(chatConditionProvider(tabType).select((v) => v.channel!.teamId));
    final channelType = ref.watch(chatConditionProvider(tabType).select((v) => v.channel!.type));
    final oauth = ref.watch(localPrefControllerProvider.select((v) => v.value?.messengerOAuths?.firstWhereOrNull((e) => e.teamId == teamId && e.type == channelType.oAuthType)));

    if (oauth == null) return ChatFetchMembersResultEntity(members: [], sequence: 0, loadedMembers: []);
    _oauth = oauth;

    TabType.values.forEach((tabType) {
      final teamId = ref.watch(chatConditionProvider(tabType).select((e) => e.channel?.teamId));

      if (teamId == _oauth.teamId) {
        final channelId = ref.watch(chatConditionProvider(tabType).select((e) => e.channel?.id));
        final threadId = ref.watch(chatConditionProvider(tabType).select((e) => e.threadId));
        if (channelId != null) {
          if (threadId != null) {
            ref.listen(chatThreadListControllerProvider(tabType: tabType), (previous, next) {
              handleChatChange();
            });
          }

          ref.listen(chatListControllerProvider(tabType: tabType), (previous, next) {
            handleChatChange();
          });
        }
      }
    });

    return ChatFetchMembersResultEntity(members: [], sequence: 0, loadedMembers: []);
  }

  void handleChatChange() {
    final prevMemberIds = state.members.map((e) => e.id).toSet().toList();
    List<String> userIds = [];

    final messages = ref.read(chatListControllerProvider(tabType: tabType).select((v) => v?.messages ?? []));
    final threadMessages = ref.read(chatThreadListControllerProvider(tabType: tabType).select((v) => v?.messages ?? []));

    [...messages, ...threadMessages].forEach((e) {
      final data = e.getUserGroupEmojiIds;
      final userId = data['userIds'] ?? [];
      userId.forEach((e) {
        if (!prevMemberIds.contains(e)) userIds.add(e);
      });
    });

    [...userIds, ...prevMemberIds].toSet().toList().forEach((userId) {
      ref.listen(chatMemberListControllerInternalProvider(isSignedIn: _isSignedIn, userId: userId, oauthUniqueId: _oauth.uniqueId), (prev, next) {
        if (next == null) return;
        updateState(state.copyWith(members: [...(state.members.where((e) => e.id != next.id)), next], loadedMembers: [next.id, ...state.loadedMembers].toSet().toList()));
      });
    });

    userIds = userIds.toSet().toList();
    fetchMembers(userIds: userIds);
  }

  Timer? timer;
  void updateState(ChatFetchMembersResultEntity data) {
    if (timer == null) state = data;
    timer?.cancel();
    timer = Timer(const Duration(milliseconds: kControllerDebouncMillisecond), () {
      state = data;
      timer = null;
    });
  }

  Future<ChatFetchMembersResultEntity> getMockMembers() async {
    final _members = Map.fromEntries(
      fakeMembersJson.entries.map((e) => MapEntry(e.key, e.value.map((e) => MessageMemberEntity.fromSlack(member: SlackMessageMemberEntity.fromJson(e))).toList())),
    );

    return ChatFetchMembersResultEntity(members: _members.values.expand((e) => e).toList(), sequence: 0, loadedMembers: _members.values.expand((e) => e).map((e) => e.id).toList());
  }

  Future<void> fetchMembers({required List<String> userIds}) async {
    if (ref.read(shouldUseMockDataProvider)) return;
    if (!ref.mounted) return;
    if (_oauth.type.chatChannelType == null) return;

    ref.read(loadingStatusProvider.notifier).update(ChatMemberListController.stringKey, LoadingState.loading);
    final result = await _repository.fetchMembers(type: _oauth.type.chatChannelType!, oauth: _oauth, userIds: userIds);
    return result.fold(
      (l) {
        ref.read(loadingStatusProvider.notifier).update(ChatMemberListController.stringKey, LoadingState.error);
      },
      (r) {
        ref.read(loadingStatusProvider.notifier).update(ChatMemberListController.stringKey, LoadingState.success);
        if (r == null) return;
        if (!ref.mounted) return;
        r.forEach((e) {
          ref.read(chatMemberListControllerInternalProvider(isSignedIn: _isSignedIn, userId: e.id, oauthUniqueId: _oauth.uniqueId).notifier).updateState(e);
        });

        updateState(state.copyWith(members: [...r, ...state.members], loadedMembers: [...userIds, ...state.loadedMembers].toSet().toList()));
      },
    );
  }
}

@riverpod
class ChatMemberListControllerInternal extends _$ChatMemberListControllerInternal {
  @override
  MessageMemberEntity? build({required bool isSignedIn, required String userId, required String oauthUniqueId}) {
    if (ref.watch(shouldUseMockDataProvider)) {
      // Find member from ChatMemberListController state
      for (final tabType in TabType.values) {
        final members = ref.watch(chatMemberListControllerProvider(tabType: tabType).select((v) => v.members));
        final member = members.firstWhereOrNull((m) => m.id == userId);
        if (member != null) {
          return member;
        }
      }
      return null;
    }

    // shouldUseMockDataProvider가 false이므로 isSignedIn은 true입니다
    // 따라서 userId는 안전하게 가져올 수 있습니다

    persist(
      ref.watch(storageProvider.future),
      key: '${ChatMemberListController.stringKey}:${isSignedIn}:${userId}:${oauthUniqueId}',
      encode: (MessageMemberEntity? state) => state == null ? 'null' : jsonEncode(state.toJson()),
      decode: (String encoded) {
        final trimmed = encoded.trim();
        if (trimmed.isEmpty || trimmed == 'null') {
          return null;
        }
        return MessageMemberEntity.fromJson(jsonDecode(trimmed) as Map<String, dynamic>);
      },
      options: Utils.storageOptions,
    );

    return null;
  }

  void updateState(MessageMemberEntity data) {
    state = data;
  }
}
