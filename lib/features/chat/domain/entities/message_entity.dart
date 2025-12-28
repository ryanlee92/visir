import 'dart:math';

import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/chat/domain/entities/message_attachment_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_block_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_block_rich_text_element_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_channel_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_emoji_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_file_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_group_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_member_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_reaction_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_tag_entity.dart';
import 'package:Visir/features/chat/domain/entities/slack/slack_message_entity.dart';
import 'package:Visir/features/chat/domain/entities/slack/slack_message_file_entity.dart';
import 'package:Visir/features/chat/domain/entities/slack/slack_message_reaction_entity.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/html_unescape_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:emoji_extension/emoji_extension.dart' hide Color;
import 'package:flutter/foundation.dart';
import 'package:html/dom.dart' show Element, Text;
import 'package:html/parser.dart' as htmlParser;
import 'package:html_unescape/html_unescape.dart';

enum MessageEntityType { slack }

enum SearchSortType { timestamp, relevant }

extension SearchSortTypeX on SearchSortType {
  String get slackValue {
    switch (this) {
      case SearchSortType.timestamp:
        return 'timestamp';
      case SearchSortType.relevant:
        return 'score';
    }
  }
}

extension MessageEntityTypeX on MessageEntityType {
  String get icon {
    switch (this) {
      case MessageEntityType.slack:
        return '${(kDebugMode && kIsWeb) ? "" : "assets/"}logos/logo_slack.png';
    }
  }

  String get title {
    switch (this) {
      case MessageEntityType.slack:
        return 'Slack';
    }
  }

  OAuthType get oAuthType {
    switch (this) {
      case MessageEntityType.slack:
        return OAuthType.slack;
    }
  }
}

enum MessageEntityPredefinedType {
  botMessage,
  meMessage,
  messageChanged,
  messageDeleted,
  messageReplied,
  threadBroadcast,
  channelJoin,
  channelLeave,
  channelTopic,
  channelPurpose,
  channelName,
  channelArchive,
  channelUnarchive,
  groupJoin,
  groupLeave,
  groupTopic,
  groupPurpose,
  groupName,
  groupArchive,
  groupUnarchive,
  fileShare,
  fileComment,
  fileMention,
  pinnedItem,
  unpinnedItem,
  ekmAccessDenied,
  channelPostingPermissions,
  reminderAdd,
  botRemove,
  slackbotResponse,
  botAdd,
  tombstone,
  joinerNotificationForInviter,
  joinerNotification,
  appConversationJoin,
  channelConvertToPrivate,
}

class MessageEntity {
  bool get isSignedIn => Utils.ref.read(isSignedInProvider);

  //for slack
  final SlackMessageEntity? _slackMessage;

  //common
  final MessageEntityType type;

  SlackMessageEntity? get slackMessage => _slackMessage;

  final String? pageToken;
  final DateTime? _replyReadAt;
  final List<String>? _replyIds;

  MessageEntity.fromSlack({required SlackMessageEntity message, this.pageToken, DateTime? replyReadAt, List<String>? replyIds})
    : _replyReadAt = replyReadAt,
      _replyIds = replyIds,
      _slackMessage = message,
      type = MessageEntityType.slack;

  factory MessageEntity.fromJson(Map<String, dynamic> json) {
    MessageEntityType messageType = MessageEntityType.values.firstWhere((e) => e.name == json['type'], orElse: () => MessageEntityType.slack);

    switch (messageType) {
      case MessageEntityType.slack:
        return MessageEntity.fromSlack(message: SlackMessageEntity.fromJson(json['_slackMessage']));
    }
  }

  factory MessageEntity.fromText({
    required MessageEntityType type,
    required String text,
    required MessageChannelEntity currentChannel,
    required List<MessageChannelEntity> channels,
    required List<MessageMemberEntity> members,
    required List<MessageGroupEntity> groups,
    required List<MessageEmojiEntity> emojis,
    required List<MessageFileEntity> files,
    required MessageMemberEntity me,
  }) {
    switch (type) {
      case MessageEntityType.slack:
        String ts = (DateTime.now().microsecondsSinceEpoch / 1000000).toStringAsFixed(6);
        String formattedText = '';
        List<Map<String, dynamic>> richTextBlockSectionElements = [];

        final broadcastChannelTag = MessageTagEntity(type: MessageTagEntityType.broadcastChannel);
        final broadcastHereTag = MessageTagEntity(type: MessageTagEntityType.broadcastHere);

        RegExp reg = RegExp(r'@([^\s]+)|\u200b\u0040([^]*?)\u200b|\u200b\u0023([^]*?)\u200b', unicode: true);
        final tagMatches = reg.allMatches(text);

        var i = 0;
        for (var e in tagMatches) {
          if (text.substring(i, e.start).isNotEmpty) {
            formattedText += text.substring(i, e.start);
            richTextBlockSectionElements.add({'type': 'text', 'text': text.substring(i, e.start)});
          }

          if (text.substring(e.start, e.end).isNotEmpty) {
            String tagName = text.substring(e.start, e.end).replaceAll('\u200b', '').replaceAll('@', '');
            MessageMemberEntity? member = members.firstWhereOrNull((e) => e.displayName == tagName);
            MessageGroupEntity? memberGroup = groups.firstWhereOrNull((e) => e.displayName == tagName);
            MessageChannelEntity? channel = channels.firstWhereOrNull((e) => e.name == tagName);
            bool isBroadcastChannel = tagName == broadcastChannelTag.displayName;
            bool isBroadcastHere = tagName == broadcastHereTag.displayName;

            String? format = member != null
                ? '<@${member.id}>'
                : memberGroup != null
                ? '<!subteam^${memberGroup.id}|@${memberGroup.name}>'
                : channel != null
                ? '<#${channel.id}|${channel.name}>'
                : isBroadcastChannel
                ? '<!channel>'
                : isBroadcastHere
                ? '<!here>'
                : text.substring(e.start, e.end);
            formattedText += format;

            if (member != null) {
              richTextBlockSectionElements.add({'type': 'user', 'user_id': member.id});
            } else if (memberGroup != null) {
              richTextBlockSectionElements.add({'type': 'usergroup', 'usergroup_id': memberGroup.id});
            } else if (channel != null) {
              richTextBlockSectionElements.add({'type': 'channel', 'channel_id': channel.id});
            } else if (isBroadcastChannel) {
              richTextBlockSectionElements.add({'type': 'broadcast', 'range': 'channel'});
            } else if (isBroadcastHere) {
              richTextBlockSectionElements.add({'type': 'broadcast', 'range': 'here'});
            } else {
              richTextBlockSectionElements.add({'type': 'text', 'text': text.substring(e.start, e.end)});
            }
          }
          i = e.end;
        }

        if (text.substring(i).isNotEmpty) {
          formattedText += text.substring(i);
          richTextBlockSectionElements.add({'type': 'text', 'text': text.substring(i)});
        }

        return MessageEntity.fromSlack(
          message: SlackMessageEntity.fromJson({
            'type': 'message',
            'team': currentChannel.teamId,
            'channel': currentChannel.id,
            'user': me.id,
            'text': formattedText,
            'ts': ts,
            'is_local_temp_message': true,
            'files': files.isEmpty ? null : files.map((e) => e.slackFile!.toJson()).toList(),
            if (tagMatches.isNotEmpty)
              'blocks': [
                {
                  'type': "rich_text",
                  'block_id': String.fromCharCodes(List.generate(3, (index) => Random().nextInt(26) + 65)),
                  'elements': [
                    {'type': 'rich_text_section', 'elements': richTextBlockSectionElements},
                  ],
                },
              ],
          }),
        );
    }
  }

  factory MessageEntity.fromHtml({
    String? id,
    required MessageEntityType type,
    required String html,
    required MessageChannelEntity currentChannel,
    required List<MessageChannelEntity> channels,
    required List<MessageMemberEntity> members,
    required List<MessageGroupEntity> groups,
    required List<MessageEmojiEntity> emojis,
    required List<MessageFileEntity> files,
    required String meId,
  }) {
    switch (type) {
      case MessageEntityType.slack:
        return MessageEntity.fromSlack(
          message: SlackMessageEntity.fromHtml(
            id: id,
            html: html,
            channel: currentChannel,
            channels: channels,
            members: members,
            groups: groups,
            emojis: emojis,
            userId: meId,
            teamId: currentChannel.teamId,
            files: files.map((e) => e.slackFile).whereType<SlackMessageFileEntity>().toList(),
          ),
        );
    }
  }

  // Helper function to process element content
  static void processElementContent(
    dynamic element,
    MessageChannelEntity currentChannel,
    List<MessageChannelEntity> channels,
    List<MessageMemberEntity> members,
    List<MessageGroupEntity> groups,
    List<MessageEmojiEntity> emojis,
    MessageTagEntity broadcastChannelTag,
    MessageTagEntity broadcastHereTag,
    void Function(String text, Map<String, dynamic>? style) onProcess, {
    Map<String, dynamic>? accumulatedStyle,
  }) {
    if (element is Element) {
      // Get the current element's style
      Map<String, dynamic>? currentStyle;
      if (element.localName == 'strong') {
        currentStyle = {'bold': true};
      } else if (element.localName == 'em') {
        currentStyle = {'italic': true};
      } else if (element.localName == 's') {
        currentStyle = {'strike': true};
      } else if (element.localName == 'code') {
        currentStyle = {'code': true};
      }

      // Combine with accumulated styles from parent elements
      Map<String, dynamic>? combinedStyle = accumulatedStyle;
      if (currentStyle != null) {
        combinedStyle = {...?accumulatedStyle, ...currentStyle};
      }

      // Process each child node
      for (var node in element.nodes) {
        if (node is Text) {
          // For text nodes, apply the combined style
          final text = node.text;
          if (text.isNotEmpty) {
            onProcess(text, combinedStyle);
          }
        } else if (node is Element) {
          // For element nodes, recursively process them with accumulated styles
          processElementContent(node, currentChannel, channels, members, groups, emojis, broadcastChannelTag, broadcastHereTag, onProcess, accumulatedStyle: combinedStyle);
        }
      }
    } else {
      // Handle leaf elements
      final text = element.text;
      if (text.startsWith('@')) {
        // Handle mentions
        final userName = text.substring(1);
        final member = members.firstWhereOrNull((m) => m.displayName == userName);
        if (member != null) {
          onProcess('<@${member.id}>', null);
        } else {
          final group = groups.firstWhereOrNull((g) => g.displayName == userName);
          if (group != null) {
            onProcess('<!subteam^${group.id}>', null);
          } else if (userName == broadcastChannelTag.displayName) {
            onProcess('<!channel>', null);
          } else if (userName == broadcastHereTag.displayName) {
            onProcess('<!here>', null);
          } else {
            onProcess(text, null);
          }
        }
      } else if (text.startsWith('#')) {
        // Handle channel mentions
        final channelName = text.substring(1);
        final channel = channels.firstWhereOrNull((c) => c.name == channelName);
        if (channel != null) {
          onProcess('<#${channel.id}>', null);
        } else {
          onProcess(text, null);
        }
      } else {
        // Handle text formatting
        Map<String, dynamic>? style;
        if (element.localName == 'strong') {
          style = {'bold': true};
        } else if (element.localName == 'em') {
          style = {'italic': true};
        } else if (element.localName == 'del') {
          style = {'strike': true};
        } else if (element.localName == 'code') {
          style = {'code': true};
        }
        onProcess(text, style);
      }
    }
  }

  Map<String, dynamic> toJson() {
    return {"type": type.name, "_slackMessage": _slackMessage?.toJson()};
  }

  MessageEntity copyWith({
    List<MessageReactionEntity>? reactions,
    int? replyCount,
    String? latestReply,
    int? replyUsersCount,
    List<String>? replyUsers,
    DateTime? replyReadAt,
    List<String>? replyIds,
    DateTime? createdAt,
  }) {
    switch (type) {
      case MessageEntityType.slack:
        return MessageEntity.fromSlack(
          message: _slackMessage!.copyWith(
            replyCount: replyCount ?? this.replyCount,
            latestReply: latestReply ?? this.latestReply,
            replyUsersCount: replyUsersCount ?? this.replyUsersCount,
            replyUsers: replyUsers ?? this.replyUsers,
            reactions:
                reactions?.map((e) => e.slackMessageReaction).whereType<SlackMessageReactionEntity>().toList() ??
                this.reactions.map((e) => e.slackMessageReaction).whereType<SlackMessageReactionEntity>().toList(),
            ts: ((createdAt ?? this.createdAt)!.microsecondsSinceEpoch / 1000000).toString(),
          ),
          replyReadAt: replyReadAt ?? this._replyReadAt,
          replyIds: replyIds ?? this._replyIds,
        );
    }
  }

  int? get replyUsersCount {
    switch (type) {
      case MessageEntityType.slack:
        return _slackMessage?.replyUsersCount;
    }
  }

  String? get id {
    switch (type) {
      case MessageEntityType.slack:
        return _slackMessage?.ts;
    }
  }

  String? get channelId {
    switch (type) {
      case MessageEntityType.slack:
        return _slackMessage?.channel;
    }
  }

  String? get text {
    switch (type) {
      case MessageEntityType.slack:
        return _slackMessage?.text;
    }
  }

  String toSnippet({
    required MessageChannelEntity channel,
    required List<MessageChannelEntity> channels,
    required List<MessageMemberEntity> members,
    required List<MessageGroupEntity> groups,
  }) {
    final unescape = HtmlUnescape();
    switch (type) {
      case MessageEntityType.slack:
        return unescape.convertOrNull(_slackMessage?.toSnippet(channel: channel, channels: channels, members: members, groups: groups)) ?? '';
    }
  }

  bool isUserTagged({required String userId, required List<MessageGroupEntity> groups}) {
    bool result = false;
    if (blocks.isEmpty) {
      final _text = text ?? '';
      final userContainGroups = groups.where((group) => group.users?.contains(userId) ?? false).toList();
      final userContainGroupIds = userContainGroups.map((e) => e.id).whereType<String>().toList();
      if (_text.contains('<@${userId}>')) {
        result = true;
      } else if (_text.contains('<!channel>')) {
        result = true;
      } else if (_text.contains('<!here>')) {
        result = true;
      } else if (userContainGroupIds.any((e) => _text.contains(e))) {
        result = true;
      }
    } else {
      blocks.forEach((block) {
        switch (block.blockType) {
          case MessageBlockEntityType.richText:
            block.elements.forEach((richText) {
              richText.elements.forEach((element) {
                switch (element.elementType) {
                  case MessageBlockRichTextElementEntityType.user:
                    if (element.userId == userId) result = true;
                  case MessageBlockRichTextElementEntityType.usergroup:
                    MessageGroupEntity? group = groups.firstWhere((m) => m.id == element.usergroupId);
                    if ((group.users ?? []).contains(userId)) result = true;
                  case MessageBlockRichTextElementEntityType.broadcast:
                    result = true;
                  case MessageBlockRichTextElementEntityType.channel:
                  case MessageBlockRichTextElementEntityType.emoji:
                  case MessageBlockRichTextElementEntityType.link:
                  case MessageBlockRichTextElementEntityType.text:
                  case MessageBlockRichTextElementEntityType.richTextSection:
                  case MessageBlockRichTextElementEntityType.date:
                  case MessageBlockRichTextElementEntityType.color:
                  default:
                    break;
                }
              });
            });
            break;
          case MessageBlockEntityType.section:
            // section 블록의 text도 확인
            final blockText = block.text?.text ?? '';
            final userContainGroups = groups.where((group) => group.users?.contains(userId) ?? false).toList();
            final userContainGroupIds = userContainGroups.map((e) => e.id).whereType<String>().toList();
            if (blockText.contains('<@${userId}>')) {
              result = true;
            } else if (blockText.contains('<!channel>')) {
              result = true;
            } else if (blockText.contains('<!here>')) {
              result = true;
            } else if (userContainGroupIds.any((e) => blockText.contains(e))) {
              result = true;
            }
            break;
          case MessageBlockEntityType.actions:
          case MessageBlockEntityType.context:
          case MessageBlockEntityType.divider:
          case MessageBlockEntityType.file:
          case MessageBlockEntityType.header:
          case MessageBlockEntityType.image:
          case MessageBlockEntityType.input:
          case MessageBlockEntityType.video:
          default:
            break;
        }
      });
    }
    return result;
  }

  Map<String, List<String>> get getUserGroupEmojiIds {
    switch (type) {
      case MessageEntityType.slack:
        return _slackMessage?.getUserGroupEmojiIds ?? {};
    }
  }

  String getRichTextSnippet({
    required MessageBlockRichTextElementEntity element,
    required List<MessageChannelEntity> channels,
    required List<MessageMemberEntity> members,
    required List<MessageGroupEntity> groups,
  }) {
    if (element.elementType == null) return '';
    List<String> strings = [];
    switch (element.elementType) {
      case MessageBlockRichTextElementEntityType.channel:
        MessageChannelEntity? channel = channels.firstWhereOrNull((m) => m.id == element.channelId);
        if (channel != null) {
          strings.add('#${channel.displayName}');
        } else {
          strings.add('#${element.channelId}');
        }
        break;
      case MessageBlockRichTextElementEntityType.emoji:
        if (element.unicode != null) {
          strings.add(Emojis.getOneOrNull(element.name!)?.value ?? '');
        } else {
          strings.add(element.name ?? '');
        }
        break;
      case MessageBlockRichTextElementEntityType.link:
        strings.add(element.text ?? element.url ?? '');
        break;
      case MessageBlockRichTextElementEntityType.text:
        strings.add(element.text ?? '');
        break;
      case MessageBlockRichTextElementEntityType.user:
        MessageMemberEntity? member = members.firstWhereOrNull((m) => m.id == element.userId);
        if (member != null) {
          strings.add('@${member.displayName}');
        }
        break;
      case MessageBlockRichTextElementEntityType.usergroup:
        MessageGroupEntity? group = groups.firstWhere((m) => m.id == element.usergroupId);
        strings.add('@${group.displayName}');
        break;
      case MessageBlockRichTextElementEntityType.broadcast:
        strings.add('@${element.range}');
        break;
      case MessageBlockRichTextElementEntityType.richTextSection:
        strings.add(element.text ?? '');
        break;
      case MessageBlockRichTextElementEntityType.date:
        strings.add(element.fallback ?? '');
        break;
      case MessageBlockRichTextElementEntityType.color:
        strings.add(element.value ?? '');
        break;
      default:
        break;
    }
    return strings.join('');
  }

  bool get isBotMessage {
    switch (type) {
      case MessageEntityType.slack:
        return _slackMessage?.user?.startsWith('B') ?? _slackMessage?.botId != null;
    }
  }

  String? get userId {
    switch (type) {
      case MessageEntityType.slack:
        return _slackMessage?.user ?? _slackMessage?.botId;
    }
  }

  String? get teamId {
    switch (type) {
      case MessageEntityType.slack:
        return _slackMessage?.team;
    }
  }

  List<MessageReactionEntity> get reactions {
    switch (type) {
      case MessageEntityType.slack:
        return _slackMessage?.reactions?.map((e) => MessageReactionEntity.fromSlack(reaction: e)).toList() ?? [];
    }
  }

  int get replyCount {
    switch (type) {
      case MessageEntityType.slack:
        return _slackMessage?.replyCount ?? 0;
    }
  }

  String? get latestReply {
    switch (type) {
      case MessageEntityType.slack:
        return _slackMessage?.latestReply;
    }
  }

  DateTime? get replyReadAt {
    switch (type) {
      case MessageEntityType.slack:
        return _replyReadAt;
    }
  }

  List<String> get replyIds {
    switch (type) {
      case MessageEntityType.slack:
        return _replyIds ?? [];
    }
  }

  List<String> get replyUsers {
    switch (type) {
      case MessageEntityType.slack:
        return _slackMessage?.replyUsers ?? [];
    }
  }

  bool get isReply {
    switch (type) {
      case MessageEntityType.slack:
        return _slackMessage?.parentUserId != null;
    }
  }

  DateTime? get createdAt {
    switch (type) {
      case MessageEntityType.slack:
        final createdAt = _slackMessage?.ts == null ? null : DateTime.fromMicrosecondsSinceEpoch((double.tryParse(_slackMessage!.ts!)! * 1000000).toInt(), isUtc: true);
        // Mock data 사용 시에도 offset 적용 (mock data는 원본 timestamp를 사용하므로)
        final shouldUseMockData = Utils.ref.read(shouldUseMockDataProvider);
        if (shouldUseMockData) return createdAt?.add(chatDateOffset);
        return createdAt;
    }
  }

  DateTime? get createdAtMiliseconds {
    switch (type) {
      case MessageEntityType.slack:
        final createdAt = _slackMessage?.ts == null ? null : DateTime.fromMillisecondsSinceEpoch((double.tryParse(_slackMessage!.ts!)! * 1000).toInt(), isUtc: true);
        if (!isSignedIn) return createdAt?.add(chatDateOffset);
        return createdAt;
    }
  }

  DateTime? get deletedAt {
    switch (type) {
      case MessageEntityType.slack:
        final deletedAt = _slackMessage?.deletedTs == null
            ? null
            : DateTime.fromMicrosecondsSinceEpoch((double.tryParse(_slackMessage!.deletedTs!)! * 1000000).toInt(), isUtc: true);
        if (!isSignedIn) return deletedAt?.add(chatDateOffset);
        return deletedAt;
    }
  }

  DateTime? get eventCreatedAt {
    switch (type) {
      case MessageEntityType.slack:
        final eventCreatedAt = _slackMessage?.eventTs == null
            ? null
            : DateTime.fromMicrosecondsSinceEpoch((double.tryParse(_slackMessage!.eventTs!)! * 1000000).toInt(), isUtc: true);
        if (!isSignedIn) return eventCreatedAt?.add(chatDateOffset);
        return eventCreatedAt;
    }
  }

  DateTime? get threadCreatedAt {
    switch (type) {
      case MessageEntityType.slack:
        final threadCreatedAt = _slackMessage?.threadTs == null
            ? null
            : DateTime.fromMicrosecondsSinceEpoch((double.tryParse(_slackMessage!.threadTs!)! * 1000000).toInt(), isUtc: true);
        if (!isSignedIn) return threadCreatedAt?.add(chatDateOffset);
        return threadCreatedAt;
    }
  }

  String? get threadId {
    switch (type) {
      case MessageEntityType.slack:
        return _slackMessage?.threadTs;
    }
  }

  DateTime? get latestReplyAt {
    switch (type) {
      case MessageEntityType.slack:
        final latestReplyAt = latestReply == null ? null : DateTime.fromMicrosecondsSinceEpoch((double.tryParse(latestReply!)! * 1000000).toInt(), isUtc: true);
        if (!isSignedIn) return latestReplyAt?.add(chatDateOffset);
        return latestReplyAt;
    }
  }

  DateTime? get latestReplyAtMiliSeconds {
    switch (type) {
      case MessageEntityType.slack:
        final latestReplyAtMiliSeconds = latestReply == null ? null : DateTime.fromMillisecondsSinceEpoch((double.tryParse(latestReply!)! * 1000).toInt(), isUtc: true);
        if (!isSignedIn) return latestReplyAtMiliSeconds?.add(chatDateOffset);
        return latestReplyAtMiliSeconds;
    }
  }

  List<MessageFileEntity> get files {
    switch (type) {
      case MessageEntityType.slack:
        return _slackMessage?.files?.map((e) => MessageFileEntity.fromSlack(file: e)).toList() ?? [];
    }
  }

  List<MessageFileEntity> get imageFiles {
    switch (type) {
      case MessageEntityType.slack:
        return files.where((e) => e.isImage).toList();
    }
  }

  List<MessageFileEntity> get videoFiles {
    switch (type) {
      case MessageEntityType.slack:
        return files.where((e) => e.isVideo).toList();
    }
  }

  List<MessageFileEntity> get audioFiles {
    switch (type) {
      case MessageEntityType.slack:
        return files.where((e) => e.isAudio).toList();
    }
  }

  List<MessageFileEntity> get extraFiles {
    switch (type) {
      case MessageEntityType.slack:
        return files.where((e) => (!e.isImage && !e.isVideo && !e.isAudio)).toList();
    }
  }

  List<MessageBlockEntity> get blocks {
    switch (type) {
      case MessageEntityType.slack:
        return _slackMessage?.blocks?.map((e) => MessageBlockEntity.fromSlack(block: e)).toList() ?? [];
    }
  }

  List<MessageAttachmentEntity> get attachments {
    switch (type) {
      case MessageEntityType.slack:
        return _slackMessage?.attachments?.map((e) => MessageAttachmentEntity.fromSlack(attachment: e)).toList() ?? [];
    }
  }

  bool get isUnavailable {
    switch (type) {
      case MessageEntityType.slack:
        return blocks.where((e) => e.isUnavailable).toList().isNotEmpty;
    }
  }

  bool get isEdited {
    switch (type) {
      case MessageEntityType.slack:
        return _slackMessage?.edited != null;
    }
  }

  bool get isPinned {
    switch (type) {
      case MessageEntityType.slack:
        return _slackMessage?.isStarred ?? false;
    }
  }

  bool get isUnread {
    switch (type) {
      case MessageEntityType.slack:
        return false;
    }
  }

  String? get link {
    switch (type) {
      case MessageEntityType.slack:
        return _slackMessage?.link;
    }
  }

  MessageEntityPredefinedType? get predefinedType {
    switch (type) {
      case MessageEntityType.slack:
        switch (_slackMessage?.subtype) {
          case SlackMessageEntitySubtype.botMessage:
            return MessageEntityPredefinedType.botMessage;
          case SlackMessageEntitySubtype.meMessage:
            return MessageEntityPredefinedType.meMessage;
          case SlackMessageEntitySubtype.messageChanged:
            return MessageEntityPredefinedType.messageChanged;
          case SlackMessageEntitySubtype.messageDeleted:
            return MessageEntityPredefinedType.messageDeleted;
          case SlackMessageEntitySubtype.messageReplied:
            return MessageEntityPredefinedType.messageReplied;
          case SlackMessageEntitySubtype.threadBroadcast:
            return MessageEntityPredefinedType.threadBroadcast;
          case SlackMessageEntitySubtype.channelJoin:
            return MessageEntityPredefinedType.channelJoin;
          case SlackMessageEntitySubtype.channelLeave:
            return MessageEntityPredefinedType.channelLeave;
          case SlackMessageEntitySubtype.channelTopic:
            return MessageEntityPredefinedType.channelTopic;
          case SlackMessageEntitySubtype.channelPurpose:
            return MessageEntityPredefinedType.channelPurpose;
          case SlackMessageEntitySubtype.channelName:
            return MessageEntityPredefinedType.channelName;
          case SlackMessageEntitySubtype.channelArchive:
            return MessageEntityPredefinedType.channelArchive;
          case SlackMessageEntitySubtype.channelUnarchive:
            return MessageEntityPredefinedType.channelUnarchive;
          case SlackMessageEntitySubtype.groupJoin:
            return MessageEntityPredefinedType.groupJoin;
          case SlackMessageEntitySubtype.groupLeave:
            return MessageEntityPredefinedType.groupLeave;
          case SlackMessageEntitySubtype.groupTopic:
            return MessageEntityPredefinedType.groupTopic;
          case SlackMessageEntitySubtype.groupPurpose:
            return MessageEntityPredefinedType.groupPurpose;
          case SlackMessageEntitySubtype.groupName:
            return MessageEntityPredefinedType.groupName;
          case SlackMessageEntitySubtype.groupArchive:
            return MessageEntityPredefinedType.groupArchive;
          case SlackMessageEntitySubtype.groupUnarchive:
            return MessageEntityPredefinedType.groupUnarchive;
          case SlackMessageEntitySubtype.fileShare:
            return MessageEntityPredefinedType.fileShare;
          case SlackMessageEntitySubtype.fileComment:
            return MessageEntityPredefinedType.fileComment;
          case SlackMessageEntitySubtype.fileMention:
            return MessageEntityPredefinedType.fileMention;
          case SlackMessageEntitySubtype.pinnedItem:
            return MessageEntityPredefinedType.pinnedItem;
          case SlackMessageEntitySubtype.unpinnedItem:
            return MessageEntityPredefinedType.unpinnedItem;
          case SlackMessageEntitySubtype.ekmAccessDenied:
            return MessageEntityPredefinedType.ekmAccessDenied;
          case SlackMessageEntitySubtype.channelPostingPermissions:
            return MessageEntityPredefinedType.channelPostingPermissions;
          case SlackMessageEntitySubtype.reminderAdd:
            return MessageEntityPredefinedType.reminderAdd;
          case SlackMessageEntitySubtype.botRemove:
            return MessageEntityPredefinedType.botRemove;
          case SlackMessageEntitySubtype.slackbotResponse:
            return MessageEntityPredefinedType.slackbotResponse;
          case SlackMessageEntitySubtype.botAdd:
            return MessageEntityPredefinedType.botAdd;
          case SlackMessageEntitySubtype.tombstone:
            return MessageEntityPredefinedType.tombstone;
          case SlackMessageEntitySubtype.joinerNotificationForInviter:
            return MessageEntityPredefinedType.joinerNotificationForInviter;
          case SlackMessageEntitySubtype.joinerNotification:
            return MessageEntityPredefinedType.joinerNotification;
          case SlackMessageEntitySubtype.appConversationJoin:
            return MessageEntityPredefinedType.appConversationJoin;
          case SlackMessageEntitySubtype.channelConvertToPrivate:
            return MessageEntityPredefinedType.channelConvertToPrivate;
          case SlackMessageEntitySubtype.huddleThread:
            return null;
          case null:
            return null;
        }
    }
  }

  bool get isLocalTempMessage {
    switch (type) {
      case MessageEntityType.slack:
        return _slackMessage?.isLocalTempMessage ?? false;
    }
  }

  bool isMyMessage({required MessageChannelEntity channel}) {
    return userId == channel.meId;
  }

  String toHtml({
    required MessageChannelEntity channel,
    required List<MessageChannelEntity> channels,
    required bool forEdit,
    required List<MessageMemberEntity> members,
    required List<MessageGroupEntity> groups,
    required List<MessageEmojiEntity> emojis,
  }) {
    switch (type) {
      case MessageEntityType.slack:
        return _slackMessage?.toHtml(channel: channel, channels: channels, forEdit: forEdit, members: members, groups: groups, emojis: emojis) ?? '';
    }
  }

  String toText({
    required MessageChannelEntity channel,
    required List<MessageChannelEntity> channels,
    required List<MessageMemberEntity> members,
    required List<MessageGroupEntity> groups,
    required List<MessageEmojiEntity> emojis,
  }) {
    switch (type) {
      case MessageEntityType.slack:
        final htmlString = _slackMessage?.toHtml(channel: channel, channels: channels, members: members, groups: groups, emojis: emojis) ?? '';
        final document = htmlParser.parse(htmlString);
        final text = document.body?.text ?? '';
        return text.trim();
    }
  }
}
