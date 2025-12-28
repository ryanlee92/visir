import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:Visir/config/providers.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/chat/application/chat_channel_list_controller.dart';
import 'package:Visir/features/chat/domain/entities/message_channel_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_emoji_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_file_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_group_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_member_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_reaction_entity.dart';
import 'package:Visir/features/chat/domain/entities/slack/slack_message_entity.dart';
import 'package:Visir/features/chat/domain/entities/state/chat_fetch_result_entity.dart';
import 'package:Visir/features/chat/infrastructure/repositories/message_repository.dart';
import 'package:Visir/features/chat/providers.dart';
import 'package:Visir/features/common/domain/failures/failure.dart';
import 'package:Visir/features/common/presentation/utils/extensions/list_extension.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:collection/collection.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/experimental/persist.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_list_controller.g.dart';

@riverpod
class ChatListController extends _$ChatListController {
  late ChatListControllerInternal _controller;

  static final String Function(TabType tabType) stringKey = (tabType) => '${tabType.name}:chat_list';

  @override
  ChatFetchResultEntity? build({required TabType tabType}) {
    final isSignedIn = ref.watch(authControllerProvider.select((v) => v.requireValue.isSignedIn));
    final channelId = ref.watch(chatConditionProvider(tabType).select((v) => v.channel?.id));
    final teamId = ref.watch(chatConditionProvider(tabType).select((v) => v.channel?.teamId));
    final targetMessageId = ref.watch(chatConditionProvider(tabType).select((v) => v.targetMessageId));
    final channelType = ref.watch(chatConditionProvider(tabType).select((v) => v.channel?.type));
    final oauthUniqueId = ref.watch(
      localPrefControllerProvider.select((v) => v.value?.messengerOAuths?.firstWhereOrNull((e) => e.teamId == teamId && e.type == channelType?.oAuthType)?.uniqueId),
    );

    if (oauthUniqueId == null) return null;
    if (channelId == null) return null;
    if (channelType == null) return null;
    if (teamId == null) return null;

    _controller = ref.watch(
      chatListControllerInternalProvider(isSignedIn: isSignedIn, oauthUniqueId: oauthUniqueId, channelId: channelId, targetMessageId: targetMessageId).notifier,
    );

    ref.listen(
      chatListControllerInternalProvider(isSignedIn: isSignedIn, oauthUniqueId: oauthUniqueId, channelId: channelId, targetMessageId: targetMessageId).select((v) => v.value),
      (previous, next) {
        if (!ref.mounted) return;
        updateState(next);
      },
    );

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(chatLastChannelProvider(tabType).notifier).setChannel(channelId);
      load();
    });

    return null;
  }

  Timer? timer;
  void updateState(ChatFetchResultEntity? data) {
    if (timer == null) state = data;
    timer?.cancel();
    timer = Timer(const Duration(milliseconds: kControllerDebouncMillisecond), () {
      state = data;
      timer = null;
    });
  }

  Future<ChatFetchResultEntity?> loadRecent() async {
    ref.read(loadingStatusProvider.notifier).update(stringKey(tabType), LoadingState.loading);
    final result = await _controller.loadRecent();
    ref.read(loadingStatusProvider.notifier).update(stringKey(tabType), LoadingState.success);
    return result;
  }

  Future<ChatFetchResultEntity?> load() async {
    ref.read(loadingStatusProvider.notifier).update(stringKey(tabType), LoadingState.loading);
    final result = await _controller.load();
    ref.read(loadingStatusProvider.notifier).update(stringKey(tabType), LoadingState.success);
    return result;
  }

  Future<ChatFetchResultEntity?> getMoreMessages({required MessageChannelEntity channel}) async {
    ref.read(loadingStatusProvider.notifier).update(stringKey(tabType), LoadingState.loading);
    final result = await _controller.getMoreMessages(channel: channel);
    ref.read(loadingStatusProvider.notifier).update(stringKey(tabType), LoadingState.success);
    return result;
  }

  Future<ChatFetchResultEntity?> getRecentMessages({required MessageChannelEntity channel}) async {
    ref.read(loadingStatusProvider.notifier).update(stringKey(tabType), LoadingState.loading);
    final result = await _controller.getRecentMessages(channel: channel);
    ref.read(loadingStatusProvider.notifier).update(stringKey(tabType), LoadingState.success);
    return result;
  }

  Future<bool> postMessage({
    String? id,
    required String html,
    required MessageChannelEntity channel,
    required List<MessageChannelEntity> channels,
    required List<MessageMemberEntity> members,
    required List<MessageGroupEntity> groups,
    required List<MessageEmojiEntity> emojis,
    required List<MessageFileEntity> files,
    required TabType? targetTab,
    bool? forceSend,
  }) async {
    return _controller.postMessage(
      id: id,
      html: html,
      channel: channel,
      channels: channels,
      members: members,
      groups: groups,
      emojis: emojis,
      files: files,
      targetTab: targetTab,
      tabType: tabType,
      forceSend: forceSend,
    );
  }

  Future<bool> postMessageLocally({
    String? id,
    required String html,
    required MessageChannelEntity channel,
    required List<MessageChannelEntity> channels,
    required List<MessageFileEntity> files,
    required List<MessageMemberEntity> members,
    required List<MessageGroupEntity> groups,
    required List<MessageEmojiEntity> emojis,
  }) async {
    return _controller.postMessageLocally(id: id, html: html, channel: channel, channels: channels, files: files, members: members, groups: groups, emojis: emojis);
  }

  Future<bool> addMessageLocally({required MessageEntity message, required MessageChannelEntity channel}) async {
    return _controller.addMessageLocally(message: message, channel: channel);
  }

  Future<bool> deleteMessage({required MessageEntity message, required MessageChannelEntity channel, required TabType? targetTab}) async {
    return _controller.deleteMessage(message: message, channel: channel, targetTab: targetTab, tabType: tabType);
  }

  Future<bool> addReaction({
    required MessageEntity message,
    required MessageChannelEntity channel,
    required String emoji,
    required String userId,
    required TabType? targetTab,
  }) async {
    return _controller.addReaction(message: message, channel: channel, emoji: emoji, userId: userId, targetTab: targetTab, tabType: tabType);
  }

  Future<bool> removeReaction({
    required MessageEntity message,
    required MessageChannelEntity channel,
    required String emoji,
    required String userId,
    required TabType? targetTab,
  }) async {
    return _controller.removeReaction(message: message, channel: channel, emoji: emoji, userId: userId, targetTab: targetTab, tabType: tabType);
  }

  Future<void> getReactions({required String messageId, required MessageChannelEntity channel}) async {
    return _controller.getReactions(messageId: messageId, channel: channel);
  }

  Future<void> addReactionLocally({required String messageId, required MessageReactionEntityType reactionType, required String reactionName, required String userId}) async {
    return _controller.addReactionLocally(messageId: messageId, reactionType: reactionType, reactionName: reactionName, userId: userId);
  }

  Future<void> removeReactionLocally({required String messageId, required MessageReactionEntityType reactionType, required String reactionName, required String userId}) async {
    return _controller.removeReactionLocally(messageId: messageId, reactionType: reactionType, reactionName: reactionName, userId: userId);
  }

  void addReplyLocally({required String messageId, required MessageEntity reply, required bool selfSent, required bool threadOpened}) {
    return _controller.addReplyLocally(messageId: messageId, reply: reply, selfSent: selfSent, threadOpened: threadOpened);
  }

  void removeReplyLocally({required String messageId, required String replyUserId, required String replyId}) {
    return _controller.removeReplyLocally(messageId: messageId, replyUserId: replyUserId, replyId: replyId);
  }

  void updateMessageLocally({required MessageEntity message, bool? doNotSort, String? messageId}) {
    return _controller.updateMessageLocally(message: message, doNotSort: doNotSort, messageId: messageId);
  }

  void deleteMessageLocally({required String id}) {
    return _controller.deleteMessageLocally(id: id);
  }

  Future<String?> getMessagePermalink({required MessageEntity message}) async {
    return _controller.getMessagePermalink(message: message);
  }
}

@riverpod
class ChatListControllerInternal extends _$ChatListControllerInternal {
  late ChatRepository _repository;

  OAuthEntity get _oauth => ref.read(localPrefControllerProvider.select((v) => v.value?.messengerOAuths?.firstWhereOrNull((e) => e.uniqueId == oauthUniqueId)))!;
  MessageChannelEntity get _channel =>
      ref.read(chatChannelListControllerProvider.select((v) => v.entries.expand((e) => e.value.channels).firstWhereOrNull((e) => e.id == channelId)))!;

  @override
  Future<ChatFetchResultEntity?> build({required bool isSignedIn, required String channelId, required String? targetMessageId, required String oauthUniqueId}) async {
    _repository = ref.watch(chatRepositoryProvider);

    if (ref.watch(shouldUseMockDataProvider)) {
      return getMockMessages();
    }

    await persist(
      ref.watch(storageProvider.future),
      key: '${ChatListController.stringKey(TabType.chat)}:${isSignedIn}:${_oauth.teamId}:${channelId}:${targetMessageId}:${oauthUniqueId}',
      encode: (ChatFetchResultEntity? state) => state == null ? '' : jsonEncode(state.toJson()),
      decode: (String encoded) {
        if (!isSignedIn) return null;
        final trimmed = encoded.trim();
        if (trimmed.isEmpty || trimmed == 'null') {
          return null;
        }
        return ChatFetchResultEntity.fromJson(jsonDecode(trimmed) as Map<String, dynamic>);
      },
      options: StorageOptions(destroyKey: ref.watch(authControllerProvider.select((value) => value.requireValue.id))),
    ).future;

    return state.value;
  }

  Future<ChatFetchResultEntity> getMockMessages() async {
    final value = await rootBundle.loadString('assets/mock/chat/${_oauth.teamId}/${channelId}.json');
    final messages = (jsonDecode(value)['messages'] as List<dynamic>)
        .map((e) => MessageEntity.fromSlack(message: SlackMessageEntity.fromJson(e)))
        .toList()
        .where((e) => e.threadId == null)
        .toList();
    return ChatFetchResultEntity(messages: messages.reversed.toList(), channel: _channel, nextCursor: null, hasMore: false);
  }

  void _updateState({required ChatFetchResultEntity newState, bool? doNotSort}) {
    final data = doNotSort == true
        ? newState
        : newState.copyWith(
            messages: [...newState.messages]
              ..sort((a, b) {
                if (a.createdAt == null) return 0;
                if (b.createdAt == null) return 0;
                return b.createdAt!.compareTo(a.createdAt!);
              }),
          );

    state = AsyncData(data);
  }

  Future<ChatFetchResultEntity?> loadRecent() async {
    if (ref.read(shouldUseMockDataProvider)) return null;
    final result = await _repository.fetchMessages(oauth: _oauth, channel: _channel);

    return result.fold(
      (l) {
        return null;
      },
      (r) async {
        final prevState = state.value;
        final prevMessages = (prevState?.messages ?? []).where((e) => !r.messages.any((n) => n.id == e.id) && !e.isLocalTempMessage).toList();
        _updateState(newState: prevState == null ? r : r.copyWith(messages: [...prevMessages, ...r.messages].unique((e) => e.id).toList()));
        return r;
      },
    );
  }

  Future<ChatFetchResultEntity?> load() async {
    if (ref.read(shouldUseMockDataProvider)) return null;
    final result = await _repository.fetchMessages(oauth: _oauth, channel: _channel, targetMessageId: targetMessageId);
    if (!ref.mounted) return null;
    return result.fold((l) => null, (r) {
      _updateState(newState: r);
      return r;
    });
  }

  Future<ChatFetchResultEntity?> getMoreMessages({required MessageChannelEntity channel}) async {
    if (ref.read(shouldUseMockDataProvider)) return null;
    if (!(state.value?.hasMore ?? false)) return null;
    if (state.value?.nextCursor == null) return null;
    final channelId = channel.id;

    final result = await _repository.fetchMessages(oauth: _oauth, channel: channel, nextCursor: state.value?.nextCursor);

    if (channel.id != channelId) return null;
    if (!ref.mounted) return null;

    return result.fold((l) => null, (r) async {
      final newState = r.copyWith(messages: [...(state.value?.messages ?? []), ...r.messages].unique((e) => e.id).whereType<MessageEntity>().toList());
      _updateState(newState: newState);
      return r;
    });
  }

  Future<ChatFetchResultEntity?> getRecentMessages({required MessageChannelEntity channel}) async {
    if (ref.read(shouldUseMockDataProvider)) return null;
    final channelId = channel.id;

    List<MessageEntity> messages = List<MessageEntity>.from(state.value?.messages ?? []);
    if (messages.isEmpty || messages.first.id == null) return null;

    final result = await _repository.fetchMessages(oauth: _oauth, channel: channel, oldestMessageId: messages.first.id!);

    if (channel.id != channelId) return null;

    return result.fold(
      (l) {
        return null;
      },
      (r) async {
        List<MessageEntity> filteredNewMessages = [];

        r.messages.forEach((n) {
          int index = messages.indexWhere((o) => n.userId == o.userId && n.text == o.text && o.isLocalTempMessage);
          if (index > -1) {
            messages[index] = n;
          } else {
            filteredNewMessages.add(n);
          }
        });

        final newState = r.copyWith(messages: [...filteredNewMessages, ...messages].unique().whereType<MessageEntity>().toList());
        _updateState(newState: newState);
        return r.copyWith(messages: filteredNewMessages);
      },
    );
  }

  Future<bool> postMessage({
    String? id,
    required String html,
    required MessageChannelEntity channel,
    required List<MessageChannelEntity> channels,
    required List<MessageMemberEntity> members,
    required List<MessageGroupEntity> groups,
    required List<MessageEmojiEntity> emojis,
    required List<MessageFileEntity> files,
    required TabType? targetTab,
    required TabType tabType,
    bool? forceSend,
  }) async {
    if (html.isEmpty) return false;
    if (forceSend != true) {
      if (channel.id != channel.id) return false;
    }

    final channelId = channel.id;

    final _pref = ref.read(localPrefControllerProvider).value;
    if (_pref == null) return false;

    MessageEntity newMessage = MessageEntity.fromHtml(
      id: id,
      type: channel.messageType,
      html: html,
      currentChannel: channel,
      channels: channels,
      files: files,
      meId: channel.meId,
      members: members,
      groups: groups,
      emojis: emojis,
    );

    List<MessageEntity> messages = List<MessageEntity>.from(state.value?.messages ?? []);

    final newMessages = id == null ? [newMessage, ...messages] : messages.map((e) => e.id == id ? newMessage : e).toList();
    if (forceSend != true) {
      final newState = state.value!.copyWith(messages: newMessages);
      _updateState(newState: newState, doNotSort: true);
    }

    if (tabType != targetTab) return true;
    if (ref.read(shouldUseMockDataProvider)) return true;

    final result = await _repository.postMessage(type: channel.type, oauth: _oauth, channel: channel, message: newMessage, isEdit: id != null);

    if (channel.id != channelId) return false;

    return result.fold(
      (l) {
        deleteMessageLocally(id: newMessage.id!);
        return false;
      },
      (r) {
        r = id == null ? r : newMessage;
        if (r != null) updateMessageLocally(message: r, doNotSort: true, messageId: newMessage.id);
        return true;
      },
    );
  }

  Future<bool> postMessageLocally({
    String? id,
    required String html,
    required MessageChannelEntity channel,
    required List<MessageChannelEntity> channels,
    required List<MessageFileEntity> files,
    required List<MessageMemberEntity> members,
    required List<MessageGroupEntity> groups,
    required List<MessageEmojiEntity> emojis,
  }) async {
    final _pref = ref.read(localPrefControllerProvider).value;
    if (_pref == null) return false;

    MessageEntity newMessage = MessageEntity.fromHtml(
      id: id,
      type: channel.messageType,
      html: html,
      currentChannel: channel,
      channels: channels,
      files: files,
      meId: channel.meId,
      members: members,
      groups: groups,
      emojis: emojis,
    );

    List<MessageEntity> messages = List<MessageEntity>.from(state.value?.messages ?? []);
    final newMessages = id == null ? [newMessage, ...messages] : messages.map((e) => e.id == id ? newMessage : e).toList();

    final newState = state.value!.copyWith(messages: newMessages);
    _updateState(newState: newState);
    return true;
  }

  Future<bool> addMessageLocally({required MessageEntity message, required MessageChannelEntity channel}) async {
    final _pref = ref.read(localPrefControllerProvider).value;
    if (_pref == null) return false;

    List<MessageEntity> messages = List<MessageEntity>.from(state.value?.messages ?? []);
    final newState = state.value!.copyWith(
      messages: [message, ...messages].unique((e) => e.id)..sort((a, b) => (a.createdAt ?? DateTime.now()).compareTo((b.createdAt ?? DateTime.now()))),
    );
    _updateState(newState: newState);
    return true;
  }

  Future<bool> deleteMessage({required MessageEntity message, required MessageChannelEntity channel, required TabType? targetTab, required TabType tabType}) async {
    if (message.id == null) return false;
    final channelId = channel.id;

    final prevState = state.value;

    List<MessageEntity> messages = List<MessageEntity>.from(state.value?.messages ?? []);
    messages.removeWhere((e) => e.id == message.id);
    final newState = state.value!.copyWith(messages: messages);
    _updateState(newState: newState);

    if (tabType != targetTab) return true;

    final result = await _repository.deleteMessage(type: channel.type, oauth: _oauth, channelId: channel.id, messageId: message.id!);

    if (channel.id != channelId) return false;

    return result.fold(
      (l) {
        if (prevState != null) _updateState(newState: prevState);

        return false;
      },
      (r) {
        return true;
      },
    );
  }

  Future<bool> addReaction({
    required MessageEntity message,
    required MessageChannelEntity channel,
    required String emoji,
    required String userId,
    required TabType? targetTab,
    required TabType tabType,
  }) async {
    final channelId = channel.id;

    final _pref = ref.read(localPrefControllerProvider).value;
    if (_pref == null) return false;

    final reactions = [...message.reactions];
    final matchReaction = reactions.firstWhereOrNull((e) => e.name == emoji);
    if (matchReaction == null) {
      reactions.add(MessageReactionEntity(type: channel.reactionType, name: emoji, count: 1, users: [userId]));
    } else {
      int index = reactions.indexOf(matchReaction);
      reactions[index] = MessageReactionEntity(type: channel.reactionType, name: emoji, count: (matchReaction.count ?? 0) + 1, users: [...matchReaction.users, userId]);
    }

    _replaceReactionsLocally(id: message.id!, reactions: reactions);
    if (tabType != targetTab) return true;

    final result = await _repository.addReaction(type: channel.type, oauth: _oauth, channelId: channel.id, messageId: message.id!, emoji: emoji);

    if (channel.id != channelId) return false;

    return result.fold(
      (l) {
        _replaceReactionsLocally(id: message.id!, reactions: message.reactions);
        return false;
      },
      (r) async {
        ref.read(frequentlyUsedEmojiIdsProvider.notifier).addEmoji(emoji);
        return true;
      },
    );
  }

  Future<bool> removeReaction({
    required MessageEntity message,
    required MessageChannelEntity channel,
    required String emoji,
    required String userId,
    required TabType? targetTab,
    required TabType tabType,
  }) async {
    final channelId = channel.id;

    final _pref = ref.read(localPrefControllerProvider).value;
    if (_pref == null) return false;

    List<MessageReactionEntity> reactions = [...message.reactions];
    final matchReaction = reactions.firstWhereOrNull((e) => e.name == emoji);
    if (matchReaction != null && matchReaction.count != null) {
      if (matchReaction.count == 1) {
        reactions.removeWhere((e) => e.name == matchReaction.name);
      } else {
        int index = reactions.indexOf(matchReaction);
        reactions[index] = MessageReactionEntity(
          type: channel.reactionType,
          name: emoji,
          count: (matchReaction.count ?? 1) - 1,
          users: [...matchReaction.users]..removeWhere((e) => e == userId),
        );
      }
    }

    _replaceReactionsLocally(id: message.id, reactions: reactions);
    if (tabType != targetTab) return true;

    final result = await _repository.removeReaction(type: channel.type, oauth: _oauth, channelId: channel.id, messageId: message.id!, emoji: emoji);

    if (channel.id != channelId) return false;

    return result.fold(
      (l) {
        _replaceReactionsLocally(id: message.id, reactions: message.reactions);
        return false;
      },
      (r) {
        return true;
      },
    );
  }

  Future<void> getReactions({required String messageId, required MessageChannelEntity channel}) async {
    final channelId = channel.id;
    if (!_checkMessageExistById(id: messageId)) return;

    final result = await _repository.fetchReactions(type: channel.type, oauth: _oauth, channelId: channel.id, messageId: messageId);

    if (channel.id != channelId) return;

    result.fold((l) {}, (r) {
      _replaceReactionsLocally(id: messageId, reactions: r);
    });
  }

  Future<void> addReactionLocally({required String messageId, required MessageReactionEntityType reactionType, required String reactionName, required String userId}) async {
    if (!_checkMessageExistById(id: messageId)) return;

    List<MessageEntity>? messages = List<MessageEntity>.from(state.value?.messages ?? []);
    final prevMessage = messages.where((e) => e.id == messageId).firstOrNull;
    List<MessageReactionEntity> reactions = [...(prevMessage?.reactions ?? [])];
    final prevReactionIndex = reactions.indexWhere((e) => e.name == reactionName && e.type == reactionType);
    final prevReaction = prevReactionIndex < 0 ? null : reactions[prevReactionIndex];
    if (prevReaction?.users.contains(userId) == true) return;

    final reaction = MessageReactionEntity(
      type: reactionType,
      name: reactionName,
      count: (prevReaction?.count ?? 0) + 1,
      users: [...(prevReaction?.users ?? [])]
        ..add(userId)
        ..unique((e) => e),
    );

    if (prevReactionIndex < 0) {
      reactions.add(reaction);
    } else {
      reactions[prevReactionIndex] = reaction;
    }

    _replaceReactionsLocally(id: messageId, reactions: reactions);
  }

  Future<void> removeReactionLocally({required String messageId, required MessageReactionEntityType reactionType, required String reactionName, required String userId}) async {
    if (!_checkMessageExistById(id: messageId)) return;

    List<MessageEntity>? messages = List<MessageEntity>.from(state.value?.messages ?? []);
    final prevMessage = messages.where((e) => e.id == messageId).firstOrNull;
    List<MessageReactionEntity> reactions = [...(prevMessage?.reactions ?? [])];
    final prevReactionIndex = reactions.indexWhere((e) => e.name == reactionName && e.type == reactionType);
    final prevReaction = prevReactionIndex < 0 ? null : reactions[prevReactionIndex];
    List<String> newUsers = [...(prevReaction?.users ?? [])]..removeWhere((e) => e == userId);
    if (prevReaction?.users.contains(userId) != true) return;

    if (newUsers.isNotEmpty == true) {
      final reaction = MessageReactionEntity(type: reactionType, name: reactionName, count: (prevReaction?.count ?? 1) - 1, users: newUsers);
      reactions[prevReactionIndex] = reaction;
    } else {
      reactions.removeWhere((e) => e.name == reactionName && e.type == reactionType);
    }

    _replaceReactionsLocally(id: messageId, reactions: reactions);
  }

  void addReplyLocally({required String messageId, required MessageEntity reply, required bool selfSent, required bool threadOpened}) {
    final _pref = ref.read(localPrefControllerProvider).value;
    if (_pref == null) throw Failure.unauthorized(StackTrace.current);

    final messages = List<MessageEntity>.from(state.value?.messages ?? []);
    final index = messages.indexWhere((e) => e.id == messageId);
    if (index < 0) return;
    MessageEntity message = messages[index];

    List<String> replyUsers = [...message.replyUsers]
      ..add(reply.userId!)
      ..unique((e) => e);
    if (reply.id == message.latestReply) return;
    if (message.replyIds.contains(reply.id)) return;
    messages[index] = message.copyWith(
      replyCount: message.replyCount + 1,
      latestReply: (reply.createdAt!.microsecondsSinceEpoch / 1000000).toString(),
      replyUsersCount: replyUsers.length,
      replyUsers: replyUsers,
      replyReadAt: threadOpened
          ? reply.createdAt
          : selfSent
          ? reply.createdAt
          : message.replyReadAt,
      replyIds: [...message.replyIds, reply.id ?? ''],
    );
    final newState = state.value!.copyWith(messages: messages);
    _updateState(newState: newState);
  }

  void removeReplyLocally({required String messageId, required String replyUserId, required String replyId}) {
    final _pref = ref.read(localPrefControllerProvider).value;
    if (_pref == null) throw Failure.unauthorized(StackTrace.current);

    final messages = List<MessageEntity>.from(state.value?.messages ?? []);
    final index = messages.indexWhere((e) => e.id == messageId);
    if (index < 0) return;
    MessageEntity message = messages[index];

    List<String> replyUsers = [...message.replyUsers]
      ..remove(replyUserId)
      ..unique((e) => e);
    messages[index] = message.copyWith(replyCount: max(0, message.replyCount - 1), latestReply: replyId, replyUsersCount: replyUsers.length, replyUsers: replyUsers);

    final newState = state.value!.copyWith(messages: messages);
    _updateState(newState: newState);
  }

  void updateMessageLocally({required MessageEntity message, bool? doNotSort, String? messageId}) {
    List<MessageEntity> messages = List<MessageEntity>.from(state.value?.messages ?? []);
    int index = messages.indexWhere((e) {
      if (e.id == (messageId ?? message.id) && e.userId == message.userId) return true;
      if (e.files.isNotEmpty && ListEquality().equals(e.files.map((f) => f.id).toList(), message.files.map((f) => f.id).toList())) return true;
      return false;
    });

    if (state.value == null) return;

    if (index < 0) {
      final newState = state.value!.copyWith(messages: [message, ...messages]);
      _updateState(newState: newState, doNotSort: doNotSort);
    } else {
      messages[index] = message;
      final newState = state.value!.copyWith(messages: messages);
      _updateState(newState: newState, doNotSort: doNotSort);
    }
  }

  void deleteMessageLocally({required String id}) {
    List<MessageEntity> messages = List<MessageEntity>.from(state.value?.messages ?? []);
    if (messages.isEmpty) return;
    messages.removeWhere((e) => e.id == id);
    if (state.value == null) return;
    final newState = state.value!.copyWith(messages: messages);
    _updateState(newState: newState);
  }

  void _replaceReactionsLocally({required String? id, required List<MessageReactionEntity> reactions}) {
    if (id == null) return;
    List<MessageEntity>? messages = List<MessageEntity>.from(state.value?.messages ?? []);
    int index = messages.indexWhere((e) => e.id == id);
    if (index < 0) return;
    MessageEntity message = messages[index];
    messages[index] = message.copyWith(reactions: reactions);
    final newState = state.value!.copyWith(messages: messages);
    _updateState(newState: newState);
  }

  bool _checkMessageExistById({required String id}) {
    MessageEntity? m = state.value?.messages.where((e) => e.id == id).firstOrNull;
    return m != null;
  }

  Future<String?> getMessagePermalink({required MessageEntity message}) async {
    final result = await _repository.getMessagePermalink(type: _channel.type, oauth: _oauth, channelId: channelId, message: message);

    return result.fold(
      (l) {
        return null;
      },
      (r) {
        return r;
      },
    );
  }
}
