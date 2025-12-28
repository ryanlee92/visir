import 'package:Visir/config/providers.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/chat/domain/entities/message_channel_entity.dart';
import 'package:Visir/features/chat/infrastructure/datasources/remote/slack_message_datasource.dart';
import 'package:Visir/features/chat/infrastructure/repositories/message_repository.dart';
import 'package:Visir/features/common/presentation/utils/extensions/list_extension.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@riverpod
SlackMessageDatasource slackMessageDatasource(Ref ref) {
  return SlackMessageDatasource();
}

@riverpod
ChatRepository chatRepository(Ref ref) {
  return ChatRepository(datasources: {DatasourceType.slack: ref.watch(slackMessageDatasourceProvider)});
}

class ChatListCondition {
  MessageChannelEntity? channel;
  String? threadId;
  String? targetMessageId;

  ChatListCondition({required this.channel, required this.threadId, required this.targetMessageId});

  ChatListCondition setThreadAndChannel(String? threadId, MessageChannelEntity channel, {String? targetMessageId}) {
    this.channel = channel;
    this.threadId = threadId;
    this.targetMessageId = targetMessageId;
    return this.copyWith();
  }

  ChatListCondition setChannel(MessageChannelEntity channel, {String? targetMessageId}) {
    this.channel = channel;
    this.targetMessageId = targetMessageId;
    return this.copyWith();
  }

  ChatListCondition setThread(String? threadId, {String? targetMessageId}) {
    this.channel = channel;
    this.threadId = threadId;
    this.targetMessageId = targetMessageId;
    return this.copyWith();
  }

  ChatListCondition copyWith() {
    return ChatListCondition(channel: channel, threadId: threadId, targetMessageId: targetMessageId);
  }
}

@Riverpod(keepAlive: true)
class ChatCondition extends _$ChatCondition {
  @override
  ChatListCondition build(TabType tabType) {
    return ChatListCondition(channel: null, threadId: null, targetMessageId: null);
  }

  void setThreadAndChannel(String? threadId, MessageChannelEntity channel, {String? targetMessageId}) {
    state = state.setThreadAndChannel(threadId, channel, targetMessageId: targetMessageId);
  }

  void setChannel(MessageChannelEntity channel, {String? targetMessageId}) {
    state = state.setChannel(channel, targetMessageId: targetMessageId);
  }

  void setThread(String? threadId, {String? targetMessageId}) {
    state = state.setThread(threadId, targetMessageId: targetMessageId);
  }

  void clear() {
    state = ChatListCondition(channel: null, threadId: null, targetMessageId: null);
  }

  void clearThread() {
    state = state.setThread(null);
  }
}

enum ChatChannelSection { basic, pinned, muted }

@riverpod
class ChatChannelStateList extends _$ChatChannelStateList {
  @override
  Map<String, ChatChannelSection> build(TabType tabType) {
    if (ref.watch(shouldUseMockDataProvider)) return {};

    final localPref = ref.watch(localPrefControllerProvider).value;
    final stateMap = localPref?.prefChatChannelStateList ?? {};
    return Map.fromEntries(stateMap.entries.map((e) => MapEntry(e.key, ChatChannelSection.values.firstWhere((v) => v.name == e.value, orElse: () => ChatChannelSection.basic))));
  }

  void updateChannelState({required String channelId, required ChatChannelSection section}) {
    state = {...state, channelId: section};
    final localPref = ref.read(localPrefControllerProvider).value;
    final currentState = localPref?.prefChatChannelStateList ?? {};
    ref.read(localPrefControllerProvider.notifier).set(chatChannelStateList: {...currentState, channelId: section.name});
    if (section == ChatChannelSection.muted) {
      final user = ref.read(authControllerProvider).requireValue;
      final excludedChannelIds = user.userExcludedChannelIds;
      final newExcludedChannelIds = [...excludedChannelIds, channelId];
      ref.read(authControllerProvider.notifier).updateUser(user: user.copyWith(excludedChannelIds: newExcludedChannelIds));
    } else {
      final user = ref.read(authControllerProvider).requireValue;
      final excludedChannelIds = user.userExcludedChannelIds;
      final newExcludedChannelIds = excludedChannelIds.where((e) => e != channelId).toList();
      ref.read(authControllerProvider.notifier).updateUser(user: user.copyWith(excludedChannelIds: newExcludedChannelIds));
    }
  }
}

@Riverpod(keepAlive: true)
class ChatLastChannel extends _$ChatLastChannel {
  @override
  List<String> build(TabType tabType) {
    if (ref.watch(shouldUseMockDataProvider)) return [];

    final localPref = ref.watch(localPrefControllerProvider).value;
    return localPref?.prefChatLastChannel[tabType.name] ?? [];
  }

  void setChannel(String channelId) {
    final newList = [channelId, ...state].unique((e) => e).take(5).toList();
    state = newList;
    final localPref = ref.read(localPrefControllerProvider).value;
    final currentChannels = localPref?.prefChatLastChannel ?? {};
    ref.read(localPrefControllerProvider.notifier).set(chatLastChannel: {...currentChannels, tabType.name: newList});
  }
}
