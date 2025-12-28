import 'dart:async';

import 'package:Visir/features/auth/domain/entities/user_entity.dart';
import 'package:Visir/features/chat/domain/datasources/chat_datasource.dart';
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
import 'package:Visir/features/common/domain/failures/failure.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:file_picker/src/platform_file.dart';
import 'package:fpdart/src/either.dart';

class ChatRepository {
  final Map<DatasourceType, MessageDatasource> datasources;

  ChatRepository({required this.datasources});

  Future<Either<Failure, OAuthEntity>> integrate({required OAuthType type}) async {
    try {
      final oauth = await datasources[type.datasourceType]?.integrate();
      return right(oauth!);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, Map<String, MessageChannelFetchResultEntity>>> fetchChannels({
    required OAuthEntity oAuth,
    required String userId,
    List<MessageChannelEntity>? channels,
  }) async {
    try {
      final result = await datasources[oAuth.type.datasourceType]?.fetchChannels(oAuth: oAuth, channels: channels, userId: userId);
      return right(result!);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, ChatFetchResultEntity>> fetchMessages({
    required OAuthEntity oauth,
    required MessageChannelEntity channel,
    String? targetMessageId,
    String? oldestMessageId,
    String? nextCursor,
  }) async {
    try {
      final result = await datasources[channel.type.datasourceType]?.fetchMessages(
        oauth: oauth,
        channel: channel,
        nextCursor: nextCursor,
        oldestId: oldestMessageId,
        targetId: targetMessageId,
      );
      return right(result!);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, ChatFetchResultEntity>> fetchMessageForInbox({
    required OAuthEntity oauth,
    required UserEntity user,
    required List<MessageChannelEntity> channels,
    required String q,
    DateTime? startDate,
    DateTime? endDate,
    Map<String, String?>? pageToken,
  }) async {
    try {
      final result = await datasources[oauth.type.datasourceType]?.fetchMessageForInbox(
        oauth: oauth,
        user: user,
        channels: channels,
        q: q,
        pageToken: pageToken,
        startDate: startDate,
        endDate: endDate,
      );

      return right(result ?? ChatFetchResultEntity(messages: [], hasMore: false));
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, ChatFetchResultEntity>> searchMessage({
    required OAuthEntity oauth,
    required UserEntity user,
    required String q,
    Map<String, String?>? pageToken,
    List<MessageChannelEntity>? channels,
    SearchSortType sortType = SearchSortType.relevant,
  }) async {
    try {
      final result = await datasources[oauth.type.datasourceType]?.searchMessage(oauth: oauth, user: user, q: q, pageToken: pageToken, channels: channels, sortType: sortType);
      return right(result!);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, MessageEntity?>> postMessage({
    required MessageChannelEntityType type,
    required OAuthEntity oauth,
    required MessageChannelEntity channel,
    required MessageEntity message,
    String? threadId,
    bool? isEdit,
  }) async {
    try {
      final result = await datasources[oauth.type.datasourceType]?.postMessage(channel: channel, message: message, oauth: oauth, threadId: threadId, isEdit: isEdit);
      return right(result);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, bool>> deleteMessage({required MessageChannelEntityType type, required OAuthEntity oauth, required String channelId, required String messageId}) async {
    try {
      final result = await datasources[type.datasourceType]?.deleteMessage(oauth: oauth, channelId: channelId, messageId: messageId);
      return right(result!);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, MessageThreadFetchResultEntity>> fetchReplies({
    required OAuthEntity oauth,
    required MessageChannelEntity channel,
    required String parentMessageId,
    String? oldestMessageId,
    String? nextCursor,
    bool? fetchLocal,
  }) async {
    try {
      final result = await datasources[channel.type.datasourceType]?.fetchReplies(
        oauth: oauth,
        channel: channel,
        parentMessageId: parentMessageId,
        nextCursor: nextCursor,
        oldestId: oldestMessageId,
      );
      return right(result!);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, bool>> addReaction({
    required MessageChannelEntityType type,
    required OAuthEntity oauth,

    required String channelId,
    required String messageId,
    required String emoji,
  }) async {
    try {
      final result = await datasources[type.datasourceType]?.addReaction(oauth: oauth, channelId: channelId, emoji: emoji, messageId: messageId);
      return right(result!);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, bool>> removeReaction({
    required MessageChannelEntityType type,
    required OAuthEntity oauth,
    required String channelId,
    required String messageId,
    required String emoji,
  }) async {
    try {
      final result = await datasources[type.datasourceType]?.removeReaction(oauth: oauth, channelId: channelId, emoji: emoji, messageId: messageId);
      return right(result!);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, List<MessageReactionEntity>>> fetchReactions({
    required MessageChannelEntityType type,
    required OAuthEntity oauth,
    required String channelId,
    required String messageId,
  }) async {
    try {
      final result = await datasources[type.datasourceType]?.fetchReactions(oauth: oauth, channelId: channelId, messageId: messageId);
      return right(result!);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, MessageUploadingTempFileEntity>> getFileUploadUrl({required MessageChannelEntityType type, required OAuthEntity oauth, required PlatformFile file}) async {
    try {
      final result = await datasources[type.datasourceType]?.uploadFileToServer(oauth: oauth, file: file);
      return right(result!);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, List<MessageFileEntity>>> postFilesTochannel({
    required MessageChannelEntityType type,
    required OAuthEntity oauth,

    required String channelId,
    required List<MessageUploadingTempFileEntity> fileDataList,
    required MessageEntity message,
    String? threadId,
  }) async {
    try {
      final result = await datasources[type.datasourceType]?.postFilesToChannel(
        oauth: oauth,
        channelId: channelId,
        fileDataList: fileDataList,
        threadId: threadId,
        message: message,
      );
      return right(result ?? []);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, void>> setReadCursor({
    required MessageChannelEntityType type,
    required OAuthEntity oauth,
    required String userId,
    required String channelId,
    required DateTime lastReadAt,
    required DateTime? lastUpdatedAt,
  }) async {
    try {
      final result = await datasources[type.datasourceType]?.setReadCursor(
        oauth: oauth,
        channelId: channelId,
        lastReadAt: lastReadAt,
        userId: userId,
        lastUpdatedAt: lastUpdatedAt,
      );
      return right(result);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, List<MessageMemberEntity>?>> fetchMembers({required MessageChannelEntityType type, required OAuthEntity oauth, required List<String> userIds}) async {
    try {
      final result = await datasources[type.datasourceType]?.fetchMembers(oauth: oauth, userIds: userIds);
      return right(result);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, List<MessageGroupEntity>?>> fetchGroups({required MessageChannelEntityType type, required OAuthEntity oauth, required List<String> groupIds}) async {
    try {
      final result = await datasources[type.datasourceType]?.fetchGroups(oauth: oauth, groupIds: groupIds);
      return right(result);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, List<MessageEmojiEntity>?>> fetchEmojis({required MessageChannelEntityType type, required OAuthEntity oauth, required List<String> emojiIds}) async {
    try {
      final result = await datasources[type.datasourceType]?.fetchEmojis(oauth: oauth, emojiIds: emojiIds);
      return right(result);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, String?>> getMessagePermalink({
    required MessageChannelEntityType type,
    required OAuthEntity oauth,
    required String channelId,
    required MessageEntity message,
  }) async {
    try {
      final result = await datasources[type.datasourceType]?.getMessagePermalink(oauth: oauth, channelId: channelId, message: message);
      return right(result);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, void>> attachMessageChangeListener({required UserEntity user, required OAuthEntity oauth}) async {
    await datasources[oauth.type.datasourceType]?.attachMessageChangeListener(user: user, oauth: oauth);
    return right(true);
  }

  Future<void> detachMessageChangeListener({required OAuthEntity oauth}) async {
    await datasources[oauth.type.datasourceType]?.detachMessageChangeListener(oauth: oauth);
  }

  Future<Either<Failure, Map<String, List<String>>>> fetchPresence({required OAuthEntity oauth}) async {
    try {
      final result = await datasources[oauth.type.datasourceType]?.fetchPresence(oauth: oauth);
      return right(result!);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }
}
