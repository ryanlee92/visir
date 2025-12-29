import 'dart:async';
import 'dart:convert';

import 'package:Visir/config/providers.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/chat/application/chat_channel_list_controller.dart';
import 'package:Visir/features/chat/application/chat_emoji_list_controller.dart';
import 'package:Visir/features/chat/application/chat_group_list_controller.dart';
import 'package:Visir/features/chat/application/chat_member_list_controller.dart';
import 'package:Visir/features/chat/domain/entities/message_channel_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_emoji_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_file_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_group_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_member_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_reaction_entity.dart';
import 'package:Visir/features/chat/domain/entities/slack/slack_message_entity.dart';
import 'package:Visir/features/chat/domain/entities/state/message_thread_fetch_result_entity.dart';
import 'package:Visir/features/chat/infrastructure/repositories/message_repository.dart';
import 'package:Visir/features/chat/providers.dart';
import 'package:Visir/features/common/domain/failures/failure.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/list_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:emoji_extension/emoji_extension.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/experimental/persist.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_thread_list_controller.g.dart';

@riverpod
class ChatThreadListController extends _$ChatThreadListController {
  static final String Function(TabType tabType) stringKey = (tabType) => '${tabType.name}:chat_thread_list';

  late ChatThreadListControllerInternal _controller;
  late String? _threadId;
  late String? _channelId;
  late String? _teamId;

  @override
  MessageThreadFetchResultEntity? build({required TabType tabType}) {
    final isSignedIn = ref.watch(authControllerProvider.select((v) => v.requireValue.isSignedIn));
    _channelId = ref.watch(chatConditionProvider(tabType).select((v) => v.channel?.id));
    _threadId = ref.watch(chatConditionProvider(tabType).select((v) => v.threadId ?? ''));
    _teamId = ref.watch(chatConditionProvider(tabType).select((v) => v.channel?.teamId));

    if (_channelId == null) return null;
    if (_teamId == null) return null;
    if (_threadId == null) return null;

    final channelType = ref.watch(chatConditionProvider(tabType).select((v) => v.channel?.type));
    if (channelType == null) return null;

    final oauthUniqueId = ref.watch(
      localPrefControllerProvider.select((v) => v.value?.messengerOAuths?.firstWhereOrNull((e) => e.teamId == _teamId && e.type == channelType.oAuthType)?.uniqueId),
    );

    if (oauthUniqueId == null) return null;

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      load();
    });

    _controller = ref.watch(chatThreadListControllerInternalProvider(isSignedIn: isSignedIn, channelId: _channelId!, threadId: _threadId!, oauthUniqueId: oauthUniqueId).notifier);
    ref.listen(
      chatThreadListControllerInternalProvider(isSignedIn: isSignedIn, channelId: _channelId!, threadId: _threadId!, oauthUniqueId: oauthUniqueId).select((v) => v.value),
      (previous, next) {
        updateState(next);
      },
    );

    return null;
  }

  Timer? timer;
  void updateState(MessageThreadFetchResultEntity? data) {
    if (timer == null) state = data;
    timer?.cancel();
    timer = Timer(const Duration(milliseconds: kControllerDebouncMillisecond), () {
      state = data;
      timer = null;
    });
  }

  Future<MessageThreadFetchResultEntity?> load({bool? isRefresh}) async {
    ref.read(loadingStatusProvider.notifier).update(stringKey(tabType), LoadingState.loading);
    final result = await _controller.load(isRefresh: isRefresh);
    ref.read(loadingStatusProvider.notifier).update(stringKey(tabType), LoadingState.success);
    return result;
  }

  Future<MessageThreadFetchResultEntity?> getReply() async {
    ref.read(loadingStatusProvider.notifier).update(stringKey(tabType), LoadingState.loading);
    final result = await _controller.getReply();
    ref.read(loadingStatusProvider.notifier).update(stringKey(tabType), LoadingState.success);
    return result;
  }

  Future<MessageEntity?> postReply({String? id, required List<MessageFileEntity> files, required String html, required TabType? targetTab}) async {
    final members = ref.read(chatMemberListControllerProvider(tabType: tabType).select((v) => v.members));
    final groups = ref.read(chatGroupListControllerProvider(tabType: tabType).select((v) => v.groups));
    final emojis = ref.read(chatEmojiListControllerProvider(tabType: tabType).select((v) => v.emojis));
    return _controller.postReply(id: id, html: html, threadId: _threadId!, files: files, targetTab: targetTab, tabType: tabType, members: members, groups: groups, emojis: emojis);
  }

  Future<void> postReplyLocally({required String html, required List<MessageFileEntity> files, required TabType? targetTab}) async {
    final members = ref.read(chatMemberListControllerProvider(tabType: tabType).select((v) => v.members));
    final groups = ref.read(chatGroupListControllerProvider(tabType: tabType).select((v) => v.groups));
    final emojis = ref.read(chatEmojiListControllerProvider(tabType: tabType).select((v) => v.emojis));
    return _controller.postReplyLocally(html: html, files: files, targetTab: targetTab, tabType: tabType, members: members, groups: groups, emojis: emojis);
  }

  Future<bool> deleteReply({required MessageEntity message, required TabType? targetTab}) async {
    return _controller.deleteReply(message: message, targetTab: targetTab, tabType: tabType);
  }

  Future<bool> addReaction({required MessageEntity message, required String emoji, required String userId, required TabType? targetTab}) async {
    return _controller.addReaction(message: message, emoji: emoji, userId: userId, targetTab: targetTab, tabType: tabType);
  }

  Future<bool> removeReaction({required MessageEntity message, required String emoji, required String userId, required TabType? targetTab}) async {
    return _controller.removeReaction(message: message, emoji: emoji, userId: userId, targetTab: targetTab, tabType: tabType);
  }

  Future<void> getReactions({required String messageId}) async {
    return _controller.getReactions(messageId: messageId);
  }

  Future<void> addReactionLocally({required String messageId, required MessageReactionEntityType reactionType, required String reactionName, required String userId}) async {
    return _controller.addReactionLocally(messageId: messageId, reactionType: reactionType, reactionName: reactionName, userId: userId);
  }

  Future<void> removeReactionLocally({required String messageId, required MessageReactionEntityType reactionType, required String reactionName, required String userId}) async {
    return _controller.removeReactionLocally(messageId: messageId, reactionType: reactionType, reactionName: reactionName, userId: userId);
  }

  bool updateReplyLocally({required MessageEntity message, bool? doNotSort, String? messageId}) {
    return _controller.updateReplyLocally(message: message, doNotSort: doNotSort, messageId: messageId);
  }

  void deleteReplyLocally({required String id}) {
    return _controller.deleteReplyLocally(id: id);
  }

  Future<String?> getMessagePermalink({required MessageEntity message}) async {
    return _controller.getMessagePermalink(message: message);
  }
}

@riverpod
class ChatThreadListControllerInternal extends _$ChatThreadListControllerInternal {
  late ChatRepository _repository;

  int messageCount = 40;
  OAuthEntity get _oauth => ref.read(localPrefControllerProvider.select((v) => v.value?.messengerOAuths?.firstWhereOrNull((e) => e.uniqueId == oauthUniqueId)))!;
  MessageChannelEntity get _channel =>
      ref.read(chatChannelListControllerProvider.select((v) => v.entries.expand((e) => e.value.channels).firstWhereOrNull((e) => e.id == channelId)))!;
  List<MessageChannelEntity> get channels => ref.read(chatChannelListControllerProvider).entries.expand((e) => e.value.channels).toList();

  @override
  Future<MessageThreadFetchResultEntity?> build({required bool isSignedIn, required String channelId, required String threadId, required String oauthUniqueId}) async {
    _repository = ref.watch(chatRepositoryProvider);

    if (ref.watch(shouldUseMockDataProvider)) return loadMock();
    if (threadId.isEmpty) return null;

    await persist(
      ref.watch(storageProvider.future),
      key: '${ChatThreadListController.stringKey(TabType.chat)}:${isSignedIn}:${_channel.teamId}:${_channel.id}:${threadId}:${oauthUniqueId}',
      encode: (MessageThreadFetchResultEntity? state) => state == null ? '' : jsonEncode(state.toJson()),
      decode: (String encoded) {
        if (ref.watch(shouldUseMockDataProvider)) return null;
        final trimmed = encoded.trim();
        if (trimmed.isEmpty || trimmed == 'null') {
          return null;
        }
        return MessageThreadFetchResultEntity.fromJson(jsonDecode(trimmed) as Map<String, dynamic>);
      },
      options: Utils.storageOptions,
    ).future;

    return state.value;
  }

  Future<MessageThreadFetchResultEntity> loadMock() async {
    final value = await rootBundle.loadString('assets/mock/chat/${_channel.teamId}/threads/${_channel.id}/${threadId}.json');
    final messages = (jsonDecode(value)['messages'] as List<dynamic>).map((e) => MessageEntity.fromSlack(message: SlackMessageEntity.fromJson(e))).toList();
    return MessageThreadFetchResultEntity(messages: messages, nextCursor: null, hasMore: false);
  }

  Future<void> _updateState({required MessageThreadFetchResultEntity newState, bool? doNotSort}) async {
    if (threadId.isEmpty) return null;
    final data = doNotSort == true
        ? newState
        : newState.copyWith(
            messages: [...newState.messages]
              ..sort((a, b) {
                if (a.createdAt == null) return 0;
                if (b.createdAt == null) return 0;
                return a.createdAt!.compareTo(b.createdAt!);
              }),
          );

    state = AsyncData(data);
  }

  Future<MessageThreadFetchResultEntity?> load({bool? isRefresh}) async {
    if (threadId.isEmpty) return null;
    if (ref.read(shouldUseMockDataProvider)) return null;
    final _pref = ref.read(localPrefControllerProvider).value;
    if (_pref == null) throw Failure.unauthorized(StackTrace.current);

    final result = await _repository.fetchReplies(oauth: _oauth, channel: _channel, parentMessageId: threadId);

    if (_channel.id != _channel.id || threadId != threadId) {
      return null;
    }

    return result.fold(
      (l) {
        return null;
      },
      (r) async {
        if (r.nextCursor != null) {
          return _getMoreReplies(prevResult: r);
        } else {
          await _updateState(newState: r);
        }

        return r;
      },
    );
  }

  Future<MessageThreadFetchResultEntity?> _getMoreReplies({required MessageThreadFetchResultEntity prevResult}) async {
    if (threadId.isEmpty) return null;
    if (ref.read(shouldUseMockDataProvider)) return null;
    if (!(prevResult.hasMore)) return null;
    if (prevResult.nextCursor == null) return null;

    final result = await _repository.fetchReplies(oauth: _oauth, channel: _channel, parentMessageId: threadId, nextCursor: prevResult.nextCursor);

    if (_channel.id != _channel.id || threadId != threadId) return null;

    return result.fold((l) => null, (r) async {
      final newState = r.copyWith(messages: [...r.messages, ...prevResult.messages].unique((e) => e.id).whereType<MessageEntity>().toList());

      if (r.nextCursor != null) {
        return _getMoreReplies(prevResult: newState);
      } else {
        await _updateState(newState: newState);
      }

      return r;
    });
  }

  Future<MessageThreadFetchResultEntity?> getReply() async {
    if (threadId.isEmpty) return null;
    if (ref.read(shouldUseMockDataProvider)) return null;
    final List<MessageEntity> replies = List<MessageEntity>.from(state.value?.messages ?? []);

    final result = await _repository.fetchReplies(oauth: _oauth, channel: _channel, parentMessageId: threadId, oldestMessageId: replies.lastOrNull?.id);

    if (_channel.id != _channel.id || threadId != threadId) return null;

    return result.fold((l) => null, (r) async {
      List<MessageEntity> filteredNewMessages = [];
      r.messages.forEach((n) {
        int index = replies.indexWhere((o) => n.userId == o.userId && n.text == o.text && o.isLocalTempMessage);
        if (index > -1) {
          replies[index] = n;
        } else {
          filteredNewMessages.add(n);
        }
      });

      final newState = r.copyWith(messages: [...replies, ...filteredNewMessages].unique((e) => e.id).whereType<MessageEntity>().toList());
      _updateState(newState: newState);
      return newState;
    });
  }

  Future<MessageEntity?> postReply({
    String? id,
    required String html,
    required List<MessageFileEntity> files,
    required String threadId,
    required List<MessageMemberEntity> members,
    required List<MessageGroupEntity> groups,
    required List<MessageEmojiEntity> emojis,
    required TabType? targetTab,
    required TabType tabType,
  }) async {
    if (threadId.isEmpty) return null;
    if (threadId != threadId) return null;

    if (html.isEmpty) return null;

    final _pref = ref.read(localPrefControllerProvider).value;
    if (_pref == null) return null;

    MessageEntity newMessage = MessageEntity.fromHtml(
      id: id,
      type: _channel.messageType,
      html: html,
      files: files,
      currentChannel: _channel,
      channels: channels,
      meId: _channel.meId,
      members: members,
      groups: groups,
      emojis: emojis,
    );

    List<MessageEntity> messages = List<MessageEntity>.from(state.value?.messages ?? []);
    if (id != null) messages.removeWhere((e) => e.id == id);
    final newState = (state.value ?? MessageThreadFetchResultEntity(messages: [], hasMore: false, nextPageTokens: {})).copyWith(messages: [...messages, newMessage]);

    _updateState(newState: newState, doNotSort: true);
    if (ref.read(shouldUseMockDataProvider)) return newMessage;

    if (tabType != targetTab) return null;

    final result = await _repository.postMessage(type: _channel.type, oauth: _oauth, channel: _channel, message: newMessage, threadId: threadId, isEdit: id != null);

    return result.fold(
      (l) {
        deleteReplyLocally(id: newMessage.id!);
        return null;
      },
      (r) {
        r = id == null ? r : newMessage;
        if (r != null) updateReplyLocally(message: r, doNotSort: true, messageId: newMessage.id);
        return r;
      },
    );
  }

  Future<void> postReplyLocally({
    required String html,
    required List<MessageFileEntity> files,
    required List<MessageMemberEntity> members,
    required List<MessageGroupEntity> groups,
    required List<MessageEmojiEntity> emojis,
    required TabType? targetTab,
    required TabType tabType,
  }) async {
    if (threadId.isEmpty) return null;

    MessageEntity newMessage = MessageEntity.fromHtml(
      type: _channel.messageType,
      html: html,
      files: files,
      currentChannel: _channel,
      channels: channels,
      meId: _channel.meId,
      members: members,
      groups: groups,
      emojis: emojis,
    );

    final newState = state.value!.copyWith(messages: [...state.value!.messages, newMessage]);
    _updateState(newState: newState);
  }

  Future<bool> deleteReply({required MessageEntity message, required TabType? targetTab, required TabType tabType}) async {
    if (threadId.isEmpty) return false;
    if (message.id == null) return false;

    final _pref = ref.read(localPrefControllerProvider).value;
    if (_pref == null) return false;

    final prevState = state.value;

    List<MessageEntity> messages = List<MessageEntity>.from(state.value?.messages ?? []);
    messages.removeWhere((e) => e.id == message.id);
    final newState = state.value!.copyWith(messages: messages);
    _updateState(newState: newState);

    if (tabType != targetTab) return true;

    final result = await _repository.deleteMessage(type: _channel.type, oauth: _oauth, channelId: _channel.id, messageId: message.id!);

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

  Future<bool> addReaction({required MessageEntity message, required String emoji, required String userId, required TabType? targetTab, required TabType tabType}) async {
    if (threadId.isEmpty) return false;
    final _pref = ref.read(localPrefControllerProvider).value;
    if (_pref == null) return false;

    final reactions = [...message.reactions];
    final matchReaction = reactions.firstWhereOrNull((e) => e.name == emoji);
    if (matchReaction == null) {
      reactions.add(MessageReactionEntity(type: _channel.reactionType, name: emoji, count: 1, users: [userId]));
    } else {
      int index = reactions.indexOf(matchReaction);
      reactions[index] = MessageReactionEntity(type: _channel.reactionType, name: emoji, count: (matchReaction.count ?? 0) + 1, users: [...matchReaction.users, userId]);
    }

    _replaceReactionsLocally(id: message.id, reactions: reactions);

    if (tabType != targetTab) return true;
    final result = await _repository.addReaction(type: _channel.type, oauth: _oauth, channelId: _channel.id, emoji: emoji, messageId: message.id!);

    return result.fold(
      (l) {
        _replaceReactionsLocally(id: message.id, reactions: message.reactions);
        return false;
      },
      (r) async {
        ref.read(frequentlyUsedEmojiIdsProvider.notifier).addEmoji(emoji);
        return true;
      },
    );
  }

  Future<bool> removeReaction({required MessageEntity message, required String emoji, required String userId, required TabType? targetTab, required TabType tabType}) async {
    if (threadId.isEmpty) return false;
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
          type: _channel.reactionType,
          name: emoji,
          count: (matchReaction.count ?? 1) - 1,
          users: [...matchReaction.users]..removeWhere((e) => e == userId),
        );
      }
    }

    _replaceReactionsLocally(id: message.id, reactions: reactions);

    if (tabType != targetTab) return true;

    final result = await _repository.removeReaction(type: _channel.type, oauth: _oauth, channelId: _channel.id, emoji: emoji, messageId: message.id!);

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

  Future<void> getReactions({required String messageId}) async {
    if (threadId.isEmpty) return;
    if (!_checkMessageExistByTs(id: messageId)) return;

    final result = await _repository.fetchReactions(type: _channel.type, oauth: _oauth, channelId: _channel.id, messageId: messageId);

    result.fold((l) => null, (r) {
      _replaceReactionsLocally(id: messageId, reactions: r);
    });
  }

  Future<void> addReactionLocally({required String messageId, required MessageReactionEntityType reactionType, required String reactionName, required String userId}) async {
    if (threadId.isEmpty) return;
    if (!_checkMessageExistByTs(id: messageId)) return;

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
    if (threadId.isEmpty) return;
    if (!_checkMessageExistByTs(id: messageId)) return;

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

  bool updateReplyLocally({required MessageEntity message, bool? doNotSort, String? messageId}) {
    if (threadId.isEmpty) return false;
    List<MessageEntity> messages = List<MessageEntity>.from(state.value?.messages ?? []);
    int index = messages.indexWhere((e) {
      if (e.id == (messageId ?? message.id) && e.userId == message.userId) return true;
      if (e.files.isNotEmpty && ListEquality().equals(e.files.map((f) => f.id).toList(), message.files.map((f) => f.id).toList())) return true;
      return false;
    });

    if (index < 0) {
      final newState = state.value!.copyWith(messages: [...messages, message]);
      _updateState(newState: newState, doNotSort: doNotSort);
      return true;
    } else {
      messages[index] = message;
      final newState = state.value!.copyWith(messages: messages);
      _updateState(newState: newState, doNotSort: doNotSort);
      return false;
    }
  }

  void deleteReplyLocally({required String id}) {
    if (threadId.isEmpty) return;
    final newMessages = List<MessageEntity>.from(state.value?.messages ?? []);
    newMessages.removeWhere((e) => e.id == id);
    final newState = state.value!.copyWith(messages: newMessages);
    _updateState(newState: newState);
  }

  void _replaceReactionsLocally({required String? id, required List<MessageReactionEntity> reactions}) {
    if (threadId.isEmpty) return;
    if (id == null) return;
    List<MessageEntity>? messages = List<MessageEntity>.from(state.value?.messages ?? []);
    if (messages.isEmpty) return;
    int index = messages.indexWhere((e) => e.id == id);
    if (index < 0) return;
    MessageEntity oldMessage = messages[index];
    messages[index] = oldMessage.copyWith(reactions: reactions);
    final newState = state.value!.copyWith(messages: messages);
    _updateState(newState: newState);
  }

  bool _checkMessageExistByTs({required String id}) {
    MessageEntity? m = state.value?.messages.where((e) => e.id == id).firstOrNull;
    return m != null;
  }

  Future<String?> getMessagePermalink({required MessageEntity message}) async {
    if (threadId.isEmpty) return null;

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
