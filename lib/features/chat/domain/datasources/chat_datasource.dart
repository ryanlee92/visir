import 'dart:async';

import 'package:Visir/features/auth/domain/entities/user_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_channel_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_channel_fetch_result_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_emoji_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_file_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_group_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_member_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_reaction_entity.dart';
import 'package:Visir/features/chat/domain/entities/state/chat_fetch_result_entity.dart';
import 'package:Visir/features/chat/domain/entities/state/message_thread_fetch_result_entity.dart';
import 'package:Visir/features/chat/domain/entities/state/message_uploading_temp_file_entity.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:file_picker/file_picker.dart';

abstract class MessageDatasource {
  Future<OAuthEntity?> integrate();

  Future<Map<String, MessageChannelFetchResultEntity>> fetchChannels({
    required OAuthEntity oAuth,
    required String userId,
    List<MessageChannelEntity>? channels,
  });

  Future<ChatFetchResultEntity?> fetchMessageForInbox({
    required OAuthEntity oauth,
    required UserEntity user,
    required List<MessageChannelEntity> channels,
    required String q,
    Map<String, String?>? pageToken,
    String? oldestId,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<ChatFetchResultEntity?> searchMessage({
    required OAuthEntity oauth,
    required UserEntity user,
    Map<String, String?>? pageToken,
    List<MessageChannelEntity>? channels,
    required String q,
    SearchSortType sortType = SearchSortType.relevant,
  });

  Future<ChatFetchResultEntity?> fetchMessages({
    required OAuthEntity oauth,
    required MessageChannelEntity channel,
    String? nextCursor,
    String? oldestId,
    String? targetId,
  });

  Future<MessageEntity?> postMessage({
    required OAuthEntity oauth,
    required MessageChannelEntity channel,
    required MessageEntity message,
    String? threadId,
    bool? isEdit,
  });

  Future<bool> deleteMessage({required OAuthEntity oauth, required String channelId, required String messageId});

  Future<MessageThreadFetchResultEntity?> fetchReplies({
    required OAuthEntity oauth,
    required MessageChannelEntity channel,
    required String parentMessageId,
    String? oldestId,
    String? nextCursor,
  });

  Future<bool> addReaction({required OAuthEntity oauth, required String channelId, required String messageId, required String emoji});

  Future<bool> removeReaction({required OAuthEntity oauth, required String channelId, required String messageId, required String emoji});

  Future<List<MessageReactionEntity>> fetchReactions({required OAuthEntity oauth, required String channelId, required String messageId});

  Future<MessageUploadingTempFileEntity?> uploadFileToServer({required OAuthEntity oauth, required PlatformFile file});

  Future<List<MessageFileEntity>> postFilesToChannel({
    required OAuthEntity oauth,
    required String channelId,
    required List<MessageUploadingTempFileEntity> fileDataList,
    required MessageEntity message,
    String? threadId,
  });

  Future<void> setReadCursor({
    required OAuthEntity oauth,
    required String userId,
    required String channelId,
    required DateTime lastReadAt,
    required DateTime? lastUpdatedAt,
  });

  Future<List<MessageMemberEntity>> fetchMembers({required OAuthEntity oauth, required List<String> userIds});

  Future<List<MessageGroupEntity>> fetchGroups({required OAuthEntity oauth, required List<String> groupIds});

  Future<List<MessageEmojiEntity>> fetchEmojis({required OAuthEntity oauth, required List<String> emojiIds});

  Future<MessageMemberEntity?> fetchBotInfo({required OAuthEntity oauth, required String botId});

  Future<String?> getMessagePermalink({required OAuthEntity oauth, required String channelId, required MessageEntity message});

  Future<void> attachMessageChangeListener({required OAuthEntity oauth, required UserEntity user});

  Future<void> detachMessageChangeListener({required OAuthEntity oauth});

  Future<Map<String, List<String>>> fetchPresence({required OAuthEntity oauth});

  Future<List<MessageGroupEntity>?> searchGroups({required OAuthEntity oauth, required String query});

  Future<List<MessageMemberEntity>?> searchMembers({required OAuthEntity oauth, required String query});

  Future<List<MessageEmojiEntity>> fetchAllEmojisFromTeam({required OAuthEntity oauth});
}
