import 'package:Visir/config/providers.dart';
import 'package:Visir/features/chat/application/chat_channel_list_controller.dart';
import 'package:Visir/features/chat/application/chat_file_list_controller.dart';
import 'package:Visir/features/chat/application/chat_list_controller.dart';
import 'package:Visir/features/chat/application/chat_thread_list_controller.dart';
import 'package:Visir/features/chat/domain/entities/message_channel_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_emoji_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_file_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_group_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_member_entity.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';

class MessageAction {
  static Future<bool> postMessage({
    String? id,
    required String html,
    required MessageChannelEntity channel,
    required List<MessageChannelEntity> channels,
    required List<MessageMemberEntity> members,
    required List<MessageGroupEntity> groups,
    required List<MessageEmojiEntity> emojis,
    required TabType tabType,
    bool? forceSend,
  }) async {
    final restTabType = [...TabType.values]..removeWhere((element) => element == tabType);
    List<MessageFileEntity>? files;
    if (id == null) {
      files = (await Utils.ref
          .read(chatFileListControllerProvider(tabType: tabType, isThread: false).notifier)
          .postFilesToChannel(type: channel.type, html: html));

      if (files?.isNotEmpty == true) {
        [...TabType.values].forEach((type) {
          if (Utils.ref.exists(chatListControllerProvider(tabType: type))) {
            Utils.ref
                .read(chatListControllerProvider(tabType: type).notifier)
                .postMessageLocally(id: id, html: html, files: files!, channel: channel, channels: channels, members: members, groups: groups, emojis: emojis);
          }
        });

        return true;
      } else if (files == null && forceSend != true) {
        return false;
      }
    }

    final result = forceSend == true
        ? await Utils.ref
              .read(chatListControllerProvider(tabType: tabType).notifier)
              .postMessage(
                id: id,
                html: html,
                files: [],
                channel: channel,
                channels: channels,
                members: members,
                groups: groups,
                emojis: emojis,
                targetTab: tabType,
                forceSend: forceSend,
              )
        : await Utils.ref
              .read(chatListControllerProvider(tabType: tabType).notifier)
              .postMessage(
                id: id,
                html: html,
                files: [],
                channel: channel,
                channels: channels,
                members: members,
                groups: groups,
                emojis: emojis,
                targetTab: tabType,
              );

    if (!result) return false;
    restTabType.forEach((type) {
      if (Utils.ref.exists(chatListControllerProvider(tabType: type))) {
        Utils.ref
            .read(chatListControllerProvider(tabType: type).notifier)
            .postMessage(
              id: id,
              html: html,
              files: [],
              channel: channel,
              channels: channels,
              members: members,
              groups: groups,
              emojis: emojis,
              targetTab: tabType,
            );
      }
    });

    return true;
  }

  static Future<void> deleteMessage({required MessageEntity message, required MessageChannelEntity channel, required TabType tabType}) async {
    final restTabType = [...TabType.values]..removeWhere((element) => element == tabType);
    final result = await Utils.ref
        .read(chatListControllerProvider(tabType: tabType).notifier)
        .deleteMessage(message: message, channel: channel, targetTab: tabType);
    if (result != true) return;
    restTabType.forEach((type) {
      if (Utils.ref.exists(chatListControllerProvider(tabType: type))) {
        Utils.ref.read(chatListControllerProvider(tabType: type).notifier).deleteMessageLocally(id: message.id!);
      }
    });
  }

  static Future<void> addReaction({
    required MessageEntity message,
    required MessageChannelEntity channel,
    required String emoji,
    required String userId,
    required TabType tabType,
  }) async {
    final restTabType = [...TabType.values]..removeWhere((element) => element == tabType);
    final result = await Utils.ref
        .read(chatListControllerProvider(tabType: tabType).notifier)
        .addReaction(message: message, channel: channel, emoji: emoji, userId: userId, targetTab: tabType);
    if (result != true) return;
    restTabType.forEach((type) {
      if (Utils.ref.exists(chatListControllerProvider(tabType: type))) {
        Utils.ref
            .read(chatListControllerProvider(tabType: type).notifier)
            .addReaction(message: message, channel: channel, emoji: emoji, userId: userId, targetTab: tabType);
      }
    });
  }

  static Future<void> removeReaction({
    required MessageEntity message,
    required MessageChannelEntity channel,
    required String emoji,
    required String userId,
    required TabType tabType,
  }) async {
    final restTabType = [...TabType.values]..removeWhere((element) => element == tabType);
    final result = await Utils.ref
        .read(chatListControllerProvider(tabType: tabType).notifier)
        .removeReaction(message: message, channel: channel, emoji: emoji, userId: userId, targetTab: tabType);
    if (!result) return;
    restTabType.forEach((type) {
      if (Utils.ref.exists(chatListControllerProvider(tabType: type))) {
        Utils.ref
            .read(chatListControllerProvider(tabType: type).notifier)
            .removeReaction(message: message, channel: channel, emoji: emoji, userId: userId, targetTab: tabType);
      }
    });
  }

  static Future<bool> postReply({
    required String? id,
    required String html,
    required List<MessageChannelEntity> channels,
    required MessageChannelEntity channel,
    required List<MessageMemberEntity> members,
    required List<MessageGroupEntity> groups,
    required List<MessageEmojiEntity> emojis,
    required String threadId,
    required TabType tabType,
  }) async {
    final restTabType = [...TabType.values]..removeWhere((element) => element == tabType);
    List<MessageFileEntity>? files;
    if (id == null) {
      files = (await Utils.ref
          .read(chatFileListControllerProvider(tabType: tabType, isThread: true).notifier)
          .postFilesToChannel(type: channel.type, html: html));

      if (files?.isNotEmpty == true) {
        [...TabType.values].forEach((type) {
          if (Utils.ref.exists(chatThreadListControllerProvider(tabType: type))) {
            Utils.ref.read(chatThreadListControllerProvider(tabType: type).notifier).postReplyLocally(html: html, files: files!, targetTab: tabType);
          }
        });
        return true;
      } else if (files == null) {
        return false;
      }
    }

    final reply = await Utils.ref
        .read(chatThreadListControllerProvider(tabType: tabType).notifier)
        .postReply(id: id, html: html, files: [], targetTab: tabType);

    if (reply == null) return false;
    if (reply.createdAt != null) {
      Utils.ref.read(chatChannelListControllerProvider.notifier).setReadCursor(teamId: channel.teamId, channelId: channel.id, lastReadAt: reply.createdAt!);
    }

    restTabType.forEach((type) {
      if (Utils.ref.exists(chatThreadListControllerProvider(tabType: type))) {
        Utils.ref.read(chatThreadListControllerProvider(tabType: type).notifier).postReply(id: id, html: html, files: [], targetTab: tabType);
      }
    });

    Utils.ref
        .read(chatListControllerProvider(tabType: tabType).notifier)
        .addReplyLocally(messageId: reply.threadId!, reply: reply, selfSent: true, threadOpened: true);
    restTabType.forEach((type) {
      if (Utils.ref.exists(chatListControllerProvider(tabType: type))) {
        Utils.ref
            .read(chatListControllerProvider(tabType: type).notifier)
            .addReplyLocally(messageId: reply.threadId!, reply: reply, selfSent: true, threadOpened: true);
      }
    });

    return true;
  }

  static Future<void> deleteReply({
    required MessageEntity message,
    required MessageEntity parent,
    required MessageChannelEntity channel,
    required TabType tabType,
  }) async {
    final restTabType = [...TabType.values]..removeWhere((element) => element == tabType);
    final result = await Utils.ref.read(chatThreadListControllerProvider(tabType: tabType).notifier).deleteReply(message: message, targetTab: tabType);
    if (!result) return;
    restTabType.forEach((type) {
      if (Utils.ref.exists(chatThreadListControllerProvider(tabType: type))) {
        Utils.ref.read(chatThreadListControllerProvider(tabType: type).notifier).deleteReply(message: message, targetTab: tabType);
      }
    });
  }

  static Future<void> addReplyReaction({
    required MessageEntity message,
    required String emoji,
    required String userId,
    required MessageChannelEntity channel,
    required MessageEntity parent,
    required TabType tabType,
  }) async {
    final restTabType = [...TabType.values]..removeWhere((element) => element == tabType);
    final result = await Utils.ref
        .read(chatThreadListControllerProvider(tabType: tabType).notifier)
        .addReaction(message: message, emoji: emoji, userId: userId, targetTab: tabType);

    if (!result) return;
    restTabType.forEach((type) {
      if (Utils.ref.exists(chatThreadListControllerProvider(tabType: type))) {
        Utils.ref
            .read(chatThreadListControllerProvider(tabType: type).notifier)
            .addReaction(message: message, emoji: emoji, userId: userId, targetTab: tabType);
      }
    });
  }

  static Future<void> removeReplyReaction({
    required MessageEntity message,
    required String emoji,
    required String userId,
    required MessageChannelEntity channel,
    required MessageEntity parent,
    required TabType tabType,
  }) async {
    final restTabType = [...TabType.values]..removeWhere((element) => element == tabType);
    final result = await Utils.ref
        .read(chatThreadListControllerProvider(tabType: tabType).notifier)
        .removeReaction(message: message, emoji: emoji, userId: userId, targetTab: tabType);

    if (!result) return;
    restTabType.forEach((type) {
      if (Utils.ref.exists(chatThreadListControllerProvider(tabType: type))) {
        Utils.ref
            .read(chatThreadListControllerProvider(tabType: type).notifier)
            .removeReaction(message: message, emoji: emoji, userId: userId, targetTab: tabType);
      }
    });
  }
}
