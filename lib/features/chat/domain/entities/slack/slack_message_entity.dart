// ignore_for_file: invalid_annotation_target

import 'dart:convert';
import 'dart:math';

import 'package:Visir/features/chat/domain/entities/message_channel_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_emoji_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_group_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_member_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_tag_entity.dart';
import 'package:Visir/features/chat/domain/entities/slack/chat_block/slack_message_block_entity.dart';
import 'package:Visir/features/chat/domain/entities/slack/chat_block/slack_message_block_rich_text_element_entity.dart';
import 'package:Visir/features/chat/domain/entities/slack/slack_message_attachment_entity.dart';
import 'package:Visir/features/chat/domain/entities/slack/slack_message_file_entity.dart';
import 'package:Visir/features/chat/domain/entities/slack/slack_message_reaction_entity.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:emoji_extension/emoji_extension.dart' hide Color;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:html/dom.dart' show Element, Text;
import 'package:html/parser.dart' as htmlParser;
import 'package:intl/intl.dart';

part 'slack_message_entity.freezed.dart';
part 'slack_message_entity.g.dart';

enum SlackMessageEntitySubtype {
  @JsonValue('bot_message')
  botMessage,
  @JsonValue('me_message')
  meMessage,
  @JsonValue('message_changed')
  messageChanged,
  @JsonValue('message_deleted')
  messageDeleted,
  @JsonValue('message_replied')
  messageReplied,
  @JsonValue('thread_broadcast')
  threadBroadcast,
  @JsonValue('channel_join')
  channelJoin,
  @JsonValue('channel_leave')
  channelLeave,
  @JsonValue('channel_topic')
  channelTopic,
  @JsonValue('channel_purpose')
  channelPurpose,
  @JsonValue('channel_name')
  channelName,
  @JsonValue('channel_archive')
  channelArchive,
  @JsonValue('channel_unarchive')
  channelUnarchive,
  @JsonValue('group_join')
  groupJoin,
  @JsonValue('group_leave')
  groupLeave,
  @JsonValue('group_topic')
  groupTopic,
  @JsonValue('group_purpose')
  groupPurpose,
  @JsonValue('group_name')
  groupName,
  @JsonValue('group_archive')
  groupArchive,
  @JsonValue('group_unarchive')
  groupUnarchive,
  @JsonValue('file_share')
  fileShare,
  @JsonValue('file_comment')
  fileComment,
  @JsonValue('file_mention')
  fileMention,
  @JsonValue('pinned_item')
  pinnedItem,
  @JsonValue('unpinned_item')
  unpinnedItem,
  @JsonValue('ekm_access_denied')
  ekmAccessDenied,
  @JsonValue('channel_posting_permissions')
  channelPostingPermissions,
  @JsonValue('reminder_add')
  reminderAdd,
  @JsonValue('bot_remove')
  botRemove,
  @JsonValue('slackbot_response')
  slackbotResponse,
  @JsonValue('bot_add')
  botAdd,
  @JsonValue('tombstone')
  tombstone,
  @JsonValue('joiner_notification_for_inviter')
  joinerNotificationForInviter,
  @JsonValue('app_conversation_join')
  appConversationJoin,
  @JsonValue('channel_convert_to_private')
  channelConvertToPrivate,
  @JsonValue('huddle_thread')
  huddleThread,
  @JsonValue('joiner_notification')
  joinerNotification,
}

@freezed
abstract class SlackMessageEntity with _$SlackMessageEntity {
  @JsonSerializable(fieldRename: FieldRename.snake)
  //https://api.slack.com/events/message
  const factory SlackMessageEntity({
    @JsonKey(includeIfNull: false) String? type,
    @JsonKey(includeIfNull: false) String? user,
    @JsonKey(includeIfNull: false) String? text,
    @JsonKey(includeIfNull: false) String? team,
    @JsonKey(includeIfNull: false) String? ts,
    @JsonKey(includeIfNull: false) String? channel,
    @JsonKey(includeIfNull: false) SlackMessageEntitySubtype? subtype,
    @JsonKey(includeIfNull: false) String? deletedTs,
    @JsonKey(includeIfNull: false) String? eventTs,
    @JsonKey(includeIfNull: false) String? threadTs,
    @JsonKey(includeIfNull: false) String? latestReply,
    @JsonKey(includeIfNull: false) int? replyCount,
    @JsonKey(includeIfNull: false) int? replyUsersCount,
    @JsonKey(includeIfNull: false) List<String>? replyUsers,
    @JsonKey(includeIfNull: false) bool? isStarred,
    @JsonKey(includeIfNull: false) bool? hidden,
    @JsonKey(includeIfNull: false) bool? isLocked,
    @JsonKey(includeIfNull: false) bool? subscribed,
    @JsonKey(includeIfNull: false) List<String>? pinnedTo,
    @JsonKey(includeIfNull: false) List<SlackMessageAttachmentEntity>? attachments,
    @JsonKey(includeIfNull: false) Map<String, dynamic>? edited,
    @JsonKey(includeIfNull: false) List<SlackMessageReactionEntity>? reactions,
    @JsonKey(includeIfNull: false) String? clientMsgId,
    @JsonKey(includeIfNull: false) String? parentUserId,
    @JsonKey(includeIfNull: false) List<SlackMessageFileEntity>? files,
    @JsonKey(includeIfNull: false) List<SlackMessageBlockEntity>? blocks,
    @JsonKey(includeIfNull: false) String? botId,
    //for local
    @JsonKey(includeIfNull: false) bool? isLocalTempMessage,
    @JsonKey(includeIfNull: false) String? link,
  }) = _SlackMessageEntity;

  /// Serialization
  factory SlackMessageEntity.fromJson(Map<String, dynamic> json) => _$SlackMessageEntityFromJson(json);

  static List<Map<String, dynamic>> _processHtmlElement(
    dynamic element,
    List<MessageChannelEntity> channels,
    List<MessageMemberEntity> members,
    List<MessageGroupEntity> groups,
    List<MessageEmojiEntity> emojis, {
    Map<String, dynamic>? accumulatedStyle,
  }) {
    final richTextElements = <Map<String, dynamic>>[];

    if (element is Element) {
      // Get the current element's style
      Map<String, dynamic>? currentStyle;
      if (element.localName == 'strong') {
        currentStyle = {'bold': true};
      } else if (element.localName == 'em') {
        currentStyle = {'italic': true};
      } else if (element.localName == 's' || element.localName == 'del') {
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
            // Handle mentions using the same regex pattern as MessageInputField
            RegExp reg = RegExp(r'@([^\s]+)|\u200b\u0040([^]*?)\u200b|\u200b\u0023([^]*?)\u200b', unicode: true);
            final tagMatches = reg.allMatches(text);
            final broadcastChannelTag = MessageTagEntity(type: MessageTagEntityType.broadcastChannel);
            final broadcastHereTag = MessageTagEntity(type: MessageTagEntityType.broadcastHere);

            var i = 0;
            for (var e in tagMatches) {
              if (text.substring(i, e.start).isNotEmpty) {
                richTextElements.add({'type': 'text', 'text': text.substring(i, e.start), if (combinedStyle != null) 'style': combinedStyle});
              }

              if (text.substring(e.start, e.end).isNotEmpty) {
                String tagName = text.substring(e.start, e.end).replaceAll('\u200b', '').replaceAll('@', '');
                MessageMemberEntity? member = members.firstWhereOrNull((m) => m.displayName == tagName);
                MessageGroupEntity? group = groups.firstWhereOrNull((g) => g.displayName == tagName);
                MessageChannelEntity? targetChannel = channels.firstWhereOrNull((c) => c.name == tagName);
                bool isBroadcastChannel = tagName == broadcastChannelTag.displayName;
                bool isBroadcastHere = tagName == broadcastHereTag.displayName;

                if (member != null) {
                  richTextElements.add({'type': 'user', 'user_id': member.id});
                } else if (group != null) {
                  richTextElements.add({'type': 'usergroup', 'usergroup_id': group.id});
                } else if (targetChannel != null) {
                  richTextElements.add({'type': 'channel', 'channel_id': targetChannel.id});
                } else if (isBroadcastChannel) {
                  richTextElements.add({'type': 'broadcast', 'range': 'channel'});
                } else if (isBroadcastHere) {
                  richTextElements.add({'type': 'broadcast', 'range': 'here'});
                } else {
                  richTextElements.add({'type': 'text', 'text': text.substring(e.start, e.end), if (combinedStyle != null) 'style': combinedStyle});
                }
              }
              i = e.end;
            }

            if (text.substring(i).isNotEmpty) {
              richTextElements.add({'type': 'text', 'text': text.substring(i), if (combinedStyle != null) 'style': combinedStyle});
            }
          }
        } else if (node is Element) {
          // For element nodes, recursively process them with accumulated styles
          if (node.localName == 'ol' || node.localName == 'ul') {
            // Skip lists here as they are handled in fromHtml
            return richTextElements;
          } else if (node.localName == 'blockquote') {
            // Handle blockquotes as rich_text_quote
            final quoteElements = _processHtmlElement(node, channels, members, groups, emojis, accumulatedStyle: combinedStyle);
            richTextElements.add({'type': 'rich_text_quote', 'elements': quoteElements});
          } else if (node.localName == 'br') {
            richTextElements.add({'type': 'text', 'text': '\n'});
          } else if (node.localName == 'a') {
            richTextElements.add({'type': 'link', 'text': node.text, 'url': node.attributes['href']});
          } else {
            richTextElements.addAll(_processHtmlElement(node, channels, members, groups, emojis, accumulatedStyle: combinedStyle));
          }
        }
      }
    } else {
      // Handle leaf elements
      final text = element.text;
      if (text.isNotEmpty) {
        // Handle mentions using the same regex pattern as MessageInputField
        RegExp reg = RegExp(r'@([^\s]+)|\u200b\u0040([^]*?)\u200b|\u200b\u0023([^]*?)\u200b', unicode: true);
        final tagMatches = reg.allMatches(text);
        final broadcastChannelTag = MessageTagEntity(type: MessageTagEntityType.broadcastChannel);
        final broadcastHereTag = MessageTagEntity(type: MessageTagEntityType.broadcastHere);

        var i = 0;
        for (var e in tagMatches) {
          if (text.substring(i, e.start).isNotEmpty) {
            richTextElements.add({'type': 'text', 'text': text.substring(i, e.start), if (accumulatedStyle != null) 'style': accumulatedStyle});
          }

          if (text.substring(e.start, e.end).isNotEmpty) {
            String tagName = text.substring(e.start, e.end).replaceAll('\u200b', '').replaceAll('@', '');
            MessageMemberEntity? member = members.firstWhereOrNull((m) => m.displayName == tagName);
            MessageGroupEntity? group = groups.firstWhereOrNull((g) => g.displayName == tagName);
            MessageChannelEntity? targetChannel = channels.firstWhereOrNull((c) => c.name == tagName);
            bool isBroadcastChannel = tagName == broadcastChannelTag.displayName;
            bool isBroadcastHere = tagName == broadcastHereTag.displayName;

            if (member != null) {
              richTextElements.add({'type': 'user', 'user_id': member.id});
            } else if (group != null) {
              richTextElements.add({'type': 'usergroup', 'usergroup_id': group.id});
            } else if (targetChannel != null) {
              richTextElements.add({'type': 'channel', 'channel_id': targetChannel.id});
            } else if (isBroadcastChannel) {
              richTextElements.add({'type': 'broadcast', 'range': 'channel'});
            } else if (isBroadcastHere) {
              richTextElements.add({'type': 'broadcast', 'range': 'here'});
            } else {
              richTextElements.add({'type': 'text', 'text': text.substring(e.start, e.end), if (accumulatedStyle != null) 'style': accumulatedStyle});
            }
          }
          i = e.end;
        }

        if (text.substring(i).isNotEmpty) {
          richTextElements.add({'type': 'text', 'text': text.substring(i), if (accumulatedStyle != null) 'style': accumulatedStyle});
        }
      }
    }

    return richTextElements;
  }

  factory SlackMessageEntity.fromHtml({
    String? id,
    required String html,
    required MessageChannelEntity channel,
    required List<MessageChannelEntity> channels,
    required List<MessageMemberEntity> members,
    required List<MessageGroupEntity> groups,
    required List<MessageEmojiEntity> emojis,
    required String userId,
    required String teamId,
    required List<SlackMessageFileEntity> files,
  }) {
    final document = htmlParser.parse(html);
    final text = document.body?.text ?? '';
    final blocks = <SlackMessageBlockEntity>[];
    final richTextElements = <Map<String, dynamic>>[];

    List<Map<String, dynamic>> processList(Element list, {int level = 0, int offset = 0}) {
      final isOrdered = list.localName == 'ol';

      List<Map<String, dynamic>> elements = [];

      for (var child in list.children) {
        if (child.localName == 'li') {
          // Process the list item's content using _processHtmlElement
          final richTextElements = _processHtmlElement(child, channels, members, groups, emojis);

          final data = {
            'type': 'rich_text_list',
            'style': isOrdered ? 'ordered' : 'bullet',
            'indent': level,
            'offset': offset,
            'border': 0,
            'elements': [
              {'type': 'rich_text_section', 'elements': richTextElements},
            ],
          };

          elements.add(data);
        }

        if (child.children.isNotEmpty) {
          for (var child in child.children) {
            int increment = 0;
            if (child.localName == 'ol' || child.localName == 'ul') {
              increment = 1;
              final nestedElements = processList(child, level: level + increment, offset: offset + increment);
              elements.addAll(nestedElements);
            }
          }
        }
      }

      return elements;
    }

    // Process all elements in document order
    final processedElements = <Element>{};
    final orderedElements = <Element>[];

    // First pass: collect all elements in document order
    void collectElements(Element element) {
      if (!processedElements.contains(element)) {
        orderedElements.add(element);
        processedElements.add(element);
      }
      for (var child in element.children) {
        collectElements(child);
      }
    }

    // Start collection from body
    if (document.body != null) {
      collectElements(document.body!);
    }

    void addRichTextSection() {
      if (richTextElements.isNotEmpty) {
        blocks.add(
          SlackMessageBlockEntity(
            type: SlackMessageBlockEntityType.richText,
            blockId: String.fromCharCodes(List.generate(3, (index) => Random().nextInt(26) + 65)),
            elements: [
              {
                'type': 'rich_text_section',
                'elements': [...richTextElements],
              },
            ],
          ),
        );

        richTextElements.clear();
      }
    }

    // Second pass: process elements in order
    for (final element in orderedElements) {
      // Process lists
      if (element.localName == 'ol' || element.localName == 'ul') {
        bool isChildOfList = false;
        Element? parent = element.parent;
        while (parent != null) {
          if (parent.localName == 'ol' || parent.localName == 'ul') {
            isChildOfList = true;
            break;
          }
          parent = parent.parent;
        }

        if (!isChildOfList) {
          addRichTextSection();
          blocks.add(
            SlackMessageBlockEntity(
              type: SlackMessageBlockEntityType.richText,
              blockId: String.fromCharCodes(List.generate(3, (index) => Random().nextInt(26) + 65)),
              elements: processList(element),
            ),
          );
        }
      }
      // Process pre tags
      else if (element.localName == 'pre') {
        final code = element.text;
        if (code.isNotEmpty) {
          addRichTextSection();
          blocks.add(
            SlackMessageBlockEntity(
              type: SlackMessageBlockEntityType.richText,
              blockId: String.fromCharCodes(List.generate(3, (index) => Random().nextInt(26) + 65)),
              elements: [
                {
                  'type': 'rich_text_preformatted',
                  'elements': [
                    {'type': 'text', 'text': code},
                  ],
                },
              ],
            ),
          );
        }
      }
      // Process blockquotes
      else if (element.localName == 'blockquote') {
        final blockElements = _processHtmlElement(element, channels, members, groups, emojis);

        if (richTextElements.isNotEmpty) {
          addRichTextSection();
          blocks.add(
            SlackMessageBlockEntity(
              type: SlackMessageBlockEntityType.richText,
              blockId: String.fromCharCodes(List.generate(3, (index) => Random().nextInt(26) + 65)),
              elements: [
                {'type': 'rich_text_quote', 'elements': blockElements},
              ],
            ),
          );
        }
      } else {
        if (element.localName == 'span' || element.localName == 'p') {
          if (element.parent?.localName != 'li') {
            richTextElements.addAll(_processHtmlElement(element, channels, members, groups, emojis));
          }
        }
        // Process links
        else if (element.localName == 'a') {
          if (element.parent?.localName != 'p' && element.parent?.localName != 'span') {
            final href = element.attributes['href'];
            final text = element.text;
            if (href != null) {
              richTextElements.add({'type': 'link', 'text': text, 'url': href});
            }
          }
        }
        // Process emojis
        else if (element.localName == 'emoji') {
          final name = element.attributes['name'];
          final unicode = element.attributes['unicode'];
          final url = element.attributes['src'];
          if (name != null) {
            richTextElements.add({'type': 'emoji', 'name': name, 'unicode': unicode, 'url': url});
          }
        }
        // Process mentions
        else if (element.classes.contains('user-mention')) {
          final userId = element.attributes['data-user-id'];
          if (userId != null) {
            richTextElements.add({'type': 'user', 'user_id': userId});
          }
        } else if (element.classes.contains('channel-mention')) {
          final channelId = element.attributes['data-channel-id'];
          if (channelId != null) {
            richTextElements.add({'type': 'channel', 'channel_id': channelId});
          }
        } else if (element.classes.contains('usergroup-mention')) {
          final groupId = element.attributes['data-group-id'];
          if (groupId != null) {
            richTextElements.add({'type': 'usergroup', 'usergroup_id': groupId});
          }
        } else if (element.classes.contains('broadcast-mention')) {
          final range = element.attributes['data-range'];
          if (range != null) {
            richTextElements.add({'type': 'broadcast', 'range': range});
          }
        }
      }
    }

    addRichTextSection();

    if (html == '<p><br/></p>') {
      blocks.clear();
    }

    return SlackMessageEntity(
      type: 'message',
      user: userId,
      team: teamId,
      channel: channel.id,
      text: text,
      ts: id ?? (DateTime.now().microsecondsSinceEpoch / 1000000).toStringAsFixed(6),
      blocks: blocks.isEmpty ? null : blocks,
      files: files,
      isLocalTempMessage: true,
    );
  }
}

extension SlackMessageEntityExtension on SlackMessageEntity {
  Map<String, List<String>> get getUserGroupEmojiIds {
    final List<String> userIds = [];
    final List<String> groupIds = [];
    final List<String> emojiIds = [];

    if (user?.isNotEmpty ?? false) {
      userIds.add(user!);
    }

    if (botId?.isNotEmpty ?? false) {
      userIds.add(botId!);
    }

    Map<String, List<String>> getUserGroupEmojiIdsFromSlackText(String text) {
      List<String> userIds = [];
      List<String> groupIds = [];
      List<String> emojiIds = [];

      // 1단계: 멘션, 채널, 링크 등의 특수 요소 처리
      RegExp specialElementsRegex = RegExp(
        r'<@([^>]+)>' + // 멘션
            r'|<!date\^(\d+)\^{([^>]+)}\|([^>]+)>' + // 날짜
            r'|<!(?:channel|here)>' + // broadcast 멘션
            r'|(?:<)?(?:https?:\/\/[^\s|>]+)(?:\|[^>]*)?(?:>)?' + // 일반 링크
            r'|`<([^|>]+)\|([^>]+)>`' + // 코드 블럭
            r'|:([^:\s]+):\s*' + // 이모지
            r'|`([^`]+)`', // 마크다운
        dotAll: true,
      );

      specialElementsRegex.allMatches(text).forEach((match) {
        if (match.group(1) != null) {
          // 멘션 처리
          final userId = match.group(1)!;
          userIds.add(userId);
        } else if (match.group(7) != null) {
          // 이모지 처리
          final emojiText = match.group(7)!;
          try {
            final element = jsonDecode(emojiText);
            emojiIds.add(element['name']);
          } catch (e) {
            emojiIds.add(emojiText);
          }
        }
      });

      emojiIds.addAll(reactions?.map((e) => e.name).whereType<String>().toList() ?? []);
      userIds.addAll(reactions?.map((e) => e.users).whereType<List<String>>().toList().expand((x) => x).toList() ?? []);
      return {'userIds': userIds, 'groupIds': groupIds, 'emojiIds': emojiIds};
    }

    if ((blocks == null || blocks!.isEmpty) && text != null) {
      final result = getUserGroupEmojiIdsFromSlackText(text!);
      userIds.addAll(result['userIds'] ?? []);
      groupIds.addAll(result['groupIds'] ?? []);
      emojiIds.addAll(result['emojiIds'] ?? []);
    }

    Map<String, List<String>> getUserGroupEmojiIdsFromRichTextElement(dynamic element) {
      List<String> userIds = [];
      List<String> groupIds = [];
      List<String> emojiIds = [];

      switch (element['type']) {
        case 'emoji':
          emojiIds.add(element['name']);
          break;
        case 'user':
          userIds.add(element['user_id']);
          break;
        case 'usergroup':
          groupIds.add(element['usergroup_id']);
          break;
        case 'rich_text_section':
          final result = getUserGroupEmojiIdsFromSlackText(element['elements'] ?? '');
          userIds.addAll(result['userIds'] ?? []);
          groupIds.addAll(result['groupIds'] ?? []);
          emojiIds.addAll(result['emojiIds'] ?? []);
          break;
        case 'date':
          final result = getUserGroupEmojiIdsFromSlackText(element['fallback'] ?? '');
          userIds.addAll(result['userIds'] ?? []);
          groupIds.addAll(result['groupIds'] ?? []);
          emojiIds.addAll(result['emojiIds'] ?? []);
          break;
        default:
          final result = getUserGroupEmojiIdsFromSlackText(element['elements'] ?? '');
          userIds.addAll(result['userIds'] ?? []);
          groupIds.addAll(result['groupIds'] ?? []);
          emojiIds.addAll(result['emojiIds'] ?? []);
          break;
      }

      return {'userIds': userIds, 'groupIds': groupIds, 'emojiIds': emojiIds};
    }

    Map<String, List<String>> getUserGroupEmojiIdsFromNestedElement(List<dynamic> elements) {
      List<String> userIds = [];
      List<String> groupIds = [];
      List<String> emojiIds = [];

      for (var i = 0; i < elements.length; i++) {
        try {
          Map<String, dynamic> element = elements[i] as Map<String, dynamic>;
          if (element['type'] == 'rich_text_list') {
            // Process list items
            for (var sectionData in element['elements'] ?? []) {
              final sectionElements = sectionData['elements'] ?? [];

              for (var sectionElement in sectionElements) {
                final result = getUserGroupEmojiIdsFromRichTextElement(sectionElement);
                userIds.addAll(result['userIds'] ?? []);
                groupIds.addAll(result['groupIds'] ?? []);
                emojiIds.addAll(result['emojiIds'] ?? []);
              }
            }

            // Check if we need to close the current list
          } else if (element['type'] == 'rich_text_quote') {
            final result = getUserGroupEmojiIdsFromNestedElement(element['elements'] ?? []);
            userIds.addAll(result['userIds'] ?? []);
            groupIds.addAll(result['groupIds'] ?? []);
            emojiIds.addAll(result['emojiIds'] ?? []);
          } else if (element['type'] == 'rich_text_preformatted') {
            final result = getUserGroupEmojiIdsFromNestedElement(element['elements'] ?? []);
            userIds.addAll(result['userIds'] ?? []);
            groupIds.addAll(result['groupIds'] ?? []);
            emojiIds.addAll(result['emojiIds'] ?? []);
          } else if (element['elements'] != null) {
            final result = getUserGroupEmojiIdsFromNestedElement(element['elements'] ?? []);
            userIds.addAll(result['userIds'] ?? []);
            groupIds.addAll(result['groupIds'] ?? []);
            emojiIds.addAll(result['emojiIds'] ?? []);
          } else {
            final result = getUserGroupEmojiIdsFromRichTextElement(element);
            userIds.addAll(result['userIds'] ?? []);
            groupIds.addAll(result['groupIds'] ?? []);
            emojiIds.addAll(result['emojiIds'] ?? []);
          }
        } catch (e) {}
      }

      return {'userIds': userIds, 'groupIds': groupIds, 'emojiIds': emojiIds};
    }

    Map<String, List<String>> getUserGroupEmojiIdsFromBlocks(List<SlackMessageBlockEntity> blocks) {
      List<String> userIds = [];
      List<String> groupIds = [];
      List<String> emojiIds = [];

      for (final block in blocks) {
        switch (block.type) {
          case SlackMessageBlockEntityType.richText:
            final result = getUserGroupEmojiIdsFromNestedElement(block.elements ?? []);
            userIds.addAll(result['userIds'] ?? []);
            groupIds.addAll(result['groupIds'] ?? []);
            emojiIds.addAll(result['emojiIds'] ?? []);
            break;
          case SlackMessageBlockEntityType.header:
            final result = getUserGroupEmojiIdsFromSlackText(block.text?.text ?? '');
            userIds.addAll(result['userIds'] ?? []);
            groupIds.addAll(result['groupIds'] ?? []);
            emojiIds.addAll(result['emojiIds'] ?? []);
            break;
          case SlackMessageBlockEntityType.section:
            final result = getUserGroupEmojiIdsFromSlackText(block.text?.text ?? '');
            userIds.addAll(result['userIds'] ?? []);
            groupIds.addAll(result['groupIds'] ?? []);
            emojiIds.addAll(result['emojiIds'] ?? []);
            break;
          case SlackMessageBlockEntityType.context:
            final result = getUserGroupEmojiIdsFromNestedElement(block.elements ?? []);
            userIds.addAll(result['userIds'] ?? []);
            groupIds.addAll(result['groupIds'] ?? []);
            emojiIds.addAll(result['emojiIds'] ?? []);
            break;
          default:
            break;
        }
      }

      return {'userIds': userIds, 'groupIds': groupIds, 'emojiIds': emojiIds};
    }

    final blockResult = getUserGroupEmojiIdsFromBlocks(blocks ?? []);
    userIds.addAll(blockResult['userIds'] ?? []);
    groupIds.addAll(blockResult['groupIds'] ?? []);
    emojiIds.addAll(blockResult['emojiIds'] ?? []);

    // Handle attachments

    for (SlackMessageAttachmentEntity attachment in attachments ?? []) {
      final result = getUserGroupEmojiIdsFromSlackText(attachment.pretext ?? '');
      userIds.addAll(result['userIds'] ?? []);
      groupIds.addAll(result['groupIds'] ?? []);
      emojiIds.addAll(result['emojiIds'] ?? []);

      final result2 = getUserGroupEmojiIdsFromSlackText(attachment.title ?? '');
      userIds.addAll(result2['userIds'] ?? []);
      groupIds.addAll(result2['groupIds'] ?? []);
      emojiIds.addAll(result2['emojiIds'] ?? []);

      final result3 = getUserGroupEmojiIdsFromSlackText(attachment.text ?? '');
      userIds.addAll(result3['userIds'] ?? []);
      groupIds.addAll(result3['groupIds'] ?? []);
      emojiIds.addAll(result3['emojiIds'] ?? []);

      final result4 = getUserGroupEmojiIdsFromBlocks(attachment.blocks?.map((e) => SlackMessageBlockEntity.fromJson(e)).toList() ?? []);
      userIds.addAll(result4['userIds'] ?? []);
      groupIds.addAll(result4['groupIds'] ?? []);
      emojiIds.addAll(result4['emojiIds'] ?? []);

      attachment.fields?.forEach((field) {
        final result5 = getUserGroupEmojiIdsFromSlackText(field['title'] ?? '');
        userIds.addAll(result5['userIds'] ?? []);
        groupIds.addAll(result5['groupIds'] ?? []);
        emojiIds.addAll(result5['emojiIds'] ?? []);

        final result6 = getUserGroupEmojiIdsFromSlackText(field['value'] ?? '');
        userIds.addAll(result6['userIds'] ?? []);
        groupIds.addAll(result6['groupIds'] ?? []);
        emojiIds.addAll(result6['emojiIds'] ?? []);
      });
    }

    return {
      'userIds': userIds.toSet().toList(),
      'groupIds': groupIds.toSet().toList(),
      'emojiIds': [...emojiIds, ...(reactions?.map((e) => e.name!) ?? []).whereType<String>().toList()].toSet().toList(),
    };
  }

  String _convertNestedElementsToString(
    List<dynamic> elements, {
    required List<MessageChannelEntity> channels,
    required List<MessageMemberEntity> members,
    required List<MessageGroupEntity> groups,
  }) {
    final buffer = StringBuffer();

    for (var i = 0; i < elements.length; i++) {
      try {
        final element = elements[i];
        if (element['type'] == 'rich_text_list') {
          final indent = element['indent'] ?? 0;
          final style = element['style'] ?? {'bullet': true};
          final prefix = style['bullet'] == true ? '• ' : '${i + 1}. ';

          // Process list items
          for (var sectionData in element['elements'] ?? []) {
            final section = SlackMessageBlockRichTextElementEntity.fromJson(sectionData);
            buffer.write('${'  ' * indent}$prefix');
            for (var sectionElement in section.elements ?? []) {
              buffer.write(_convertRichTextElementToString(element: sectionElement, channels: channels, members: members, groups: groups));
            }
            buffer.write('\n');
          }
        } else if (element['type'] == 'rich_text_quote') {
          buffer.write('> ${_convertNestedElementsToString(element['elements']!, channels: channels, members: members, groups: groups)}\n');
        } else if (element['type'] == 'rich_text_preformatted') {
          buffer.write('```\n${_convertNestedElementsToString(element['elements']!, channels: channels, members: members, groups: groups)}\n```\n');
        } else if (element['elements'] != null) {
          buffer.write(_convertNestedElementsToString(element['elements']!, channels: channels, members: members, groups: groups));
        } else {
          buffer.write(_convertRichTextElementToString(element: element, channels: channels, members: members, groups: groups));
        }
      } catch (e) {}
    }

    return buffer.toString();
  }

  String _convertSlackBlockToString({
    required List<SlackMessageBlockEntity> blocks,
    required List<MessageChannelEntity> channels,
    required List<MessageMemberEntity> members,
    required List<MessageGroupEntity> groups,
  }) {
    final buffer = StringBuffer();
    for (final block in (this.blocks ?? [])) {
      switch (block.type) {
        case SlackMessageBlockEntityType.divider:
          buffer.write('---');
          break;
        case SlackMessageBlockEntityType.richText:
          final elements = (block.elements ?? []).map((e) {
            if (e['style'] is String) {
              final newStyle = <String, bool>{};
              newStyle[e['style'] as String] = true;
              e = <String, dynamic>{...e, 'style': newStyle};
            }
            return e;
          }).toList();

          buffer.write(_convertNestedElementsToString(elements, channels: channels, members: members, groups: groups));
          break;
        case SlackMessageBlockEntityType.header:
          buffer.write('# ${_convertSlackTextToString(text: block.text?.text ?? '', channels: channels, members: members, groups: groups)}\n');
          break;
        case SlackMessageBlockEntityType.section:
          buffer.write('${_convertSlackTextToString(text: block.text?.text ?? '', channels: channels, members: members, groups: groups)}\n');
          break;
        case SlackMessageBlockEntityType.image:
          buffer.write('(Image)\n');
          break;
        case SlackMessageBlockEntityType.video:
          buffer.write('(Video)\n');
          break;
        case SlackMessageBlockEntityType.context:
          final elements = (block.elements ?? []).map((e) {
            if (e['style'] is String) {
              final newStyle = <String, bool>{};
              newStyle[e['style'] as String] = true;
              e = <String, dynamic>{...e, 'style': newStyle};
            }
            return e;
          }).toList();

          buffer.write(_convertNestedElementsToString(elements, channels: channels, members: members, groups: groups));
          break;
        default:
          break;
      }
    }

    return buffer.toString().trim();
  }

  String toSnippet({
    required MessageChannelEntity channel,
    required List<MessageChannelEntity> channels,
    required List<MessageMemberEntity> members,
    required List<MessageGroupEntity> groups,
  }) {
    final buffer = StringBuffer();

    if ((blocks == null || blocks!.isEmpty) && text != null) {
      buffer.write(_convertSlackTextToString(text: text!, channels: channels, members: members, groups: groups));
    }

    // Handle predefined message types first
    if (blocks?.isEmpty == true) {
      switch (subtype) {
        case SlackMessageEntitySubtype.channelJoin:
        case SlackMessageEntitySubtype.groupJoin:
          buffer.write(
            _convertSlackTextToString(
              text: '${Utils.mainContext.tr.chat_formatted_message_user_joines} #${channel.name}',
              channels: channels,
              members: members,
              groups: groups,
            ),
          );
        case SlackMessageEntitySubtype.channelArchive:
        case SlackMessageEntitySubtype.groupArchive:
          buffer.write(
            _convertSlackTextToString(
              text:
                  '${Utils.mainContext.tr.chat_formatted_message_user_archived} #${channel.name}. ${Utils.mainContext.tr.chat_formatted_message_user_archived_description}',
              channels: channels,
              members: members,
              groups: groups,
            ),
          );
        case SlackMessageEntitySubtype.channelUnarchive:
        case SlackMessageEntitySubtype.groupUnarchive:
          buffer.write(
            _convertSlackTextToString(
              text: '${Utils.mainContext.tr.chat_formatted_message_user_unarchived} #${channel.name}',
              channels: channels,
              members: members,
              groups: groups,
            ),
          );
        case SlackMessageEntitySubtype.channelLeave:
        case SlackMessageEntitySubtype.groupLeave:
          buffer.write(
            _convertSlackTextToString(
              text: '${Utils.mainContext.tr.chat_formatted_message_user_left} #${channel.name}',
              channels: channels,
              members: members,
              groups: groups,
            ),
          );
        default:
          break;
      }
    }

    // Handle blocks
    buffer.write(_convertSlackBlockToString(blocks: blocks ?? [], channels: channels, members: members, groups: groups));

    // Handle attachments
    for (SlackMessageAttachmentEntity attachment in attachments ?? []) {
      if (attachment.pretext != null) {
        buffer.write('${_convertSlackTextToString(text: attachment.pretext!, channels: channels, members: members, groups: groups)}\n');
      }
      if (attachment.title != null) {
        buffer.write('${_convertSlackTextToString(text: attachment.title!, channels: channels, members: members, groups: groups)}\n');
      }
      if (attachment.text != null) {
        buffer.write('${_convertSlackTextToString(text: attachment.text!, channels: channels, members: members, groups: groups)}\n');
      }
      if (attachment.blocks?.isNotEmpty == true) {
        buffer.write(
          _convertSlackBlockToString(
            blocks: attachment.blocks?.map((e) => SlackMessageBlockEntity.fromJson(e)).toList() ?? [],
            channels: channels,
            members: members,
            groups: groups,
          ),
        );
      }

      if (attachment.fields?.isNotEmpty == true) {
        for (var field in attachment.fields!) {
          buffer.write(
            '${_convertSlackTextToString(text: field['title'], channels: channels, members: members, groups: groups)}: ${_convertSlackTextToString(text: field['value'], channels: channels, members: members, groups: groups)}\n',
          );
        }
      }
    }

    for (SlackMessageFileEntity file in files ?? []) {
      buffer.write('${file.name}\n');
    }

    return buffer.toString();
  }

  String _convertSlackTextToString({
    required String text,
    required List<MessageChannelEntity> channels,
    required List<MessageMemberEntity> members,
    required List<MessageGroupEntity> groups,
  }) {
    // Convert &gt; to blockquote
    text = text.replaceAllMapped(RegExp(r'&gt;\s*(.*?)(?=\n|$)'), (match) {
      return '> ${match.group(1)}';
    });

    // 1단계: 멘션, 채널, 링크 등의 특수 요소 처리
    RegExp specialElementsRegex = RegExp(
      r'<@([^>]+)>' + // 멘션
          r'|<!date\^(\d+)\^{([^>]+)}\|([^>]+)>' + // 날짜
          r'|<!(?:channel|here)>' + // broadcast 멘션
          r'|(?:<)?(?:https?:\/\/[^\s|>]+)(?:\|[^>]*)?(?:>)?' + // 일반 링크
          r'|`<([^|>]+)\|([^>]+)>`' + // 코드 블럭
          r'|:([^:\s]+):\s*' + // 이모지
          r'|`([^`]+)`', // 마크다운
      dotAll: true,
    );

    text = text.replaceAllMapped(specialElementsRegex, (match) {
      if (match.group(1) != null) {
        // 멘션 처리
        final userId = match.group(1)!;
        final member = members.firstWhereOrNull((m) => m.id == userId);
        final group = groups.firstWhereOrNull((g) => g.id == userId);
        return member != null
            ? '@${member.displayName}'
            : group != null
            ? '@${group.displayName}'
            : '@${userId}';
      } else if (match.group(2) != null && match.group(3) != null && match.group(4) != null) {
        // 날짜 처리
        final timestamp = int.parse(match.group(2)!);
        final formatString = match.group(3)!;
        final fallbackText = match.group(4)!;
        final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
        final formattedDate = formatString == 'time'
            ? DateFormat.jm().format(date)
            : formatString == 'date_short_pretty'
            ? DateFormat.MMMd().format(date)
            : formatString == 'date_long_pretty'
            ? '${DateFormat.EEEE().format(date)}, ${DateFormat.MMMM().format(date)} ${date.day}${Utils.getOrdinalSuffix(date.day)}'
            : fallbackText;
        return ' ${formattedDate} ';
      } else if (match.group(5) != null) {
        // 코드 블럭 처리
        final url = match.group(5)!;
        final displayText = match.group(6) ?? url;
        return '`${displayText}`';
      } else if (match.group(7) != null) {
        // 이모지 처리
        final emojiText = match.group(7)!;

        try {
          final element = jsonDecode(emojiText);
          return Emojis.getOneOrNull((element['unicode'] ?? '').toUpperCase())?.value ?? '${element['name']}';
        } catch (e) {
          return Emojis.getOneOrNull(emojiText)?.value ?? emojiText;
        }
      } else if (match.group(8) != null) {
        // 마크다운 처리
        final codeText = match.group(8)!;
        return '`${codeText}`';
      } else {
        // 일반 링크 처리
        final matchedText = match.group(0)!;
        final parts = matchedText.split('|');
        final url = parts[0].replaceAll('<', '').replaceAll('>', '');
        final displayText = parts.length > 1 ? parts[1].replaceAll('>', '') : url;
        return displayText;
      }
    });

    // 2단계: 포맷팅 처리 (순차적으로)
    // 취소선 처리
    text = text.replaceAllMapped(RegExp(r'~([^~]+)~'), (match) {
      return '~${match.group(1)}~';
    });

    // 이탤릭 처리
    text = text.replaceAllMapped(RegExp(r'_([^_]+)_'), (match) {
      return '_${match.group(1)}_';
    });

    // 굵게 처리
    text = text.replaceAllMapped(RegExp(r'\*([^\*]+)\*'), (match) {
      return '*${match.group(1)}*';
    });

    // broadcast 멘션 처리
    return text.replaceAll('<!channel>', '@channel').replaceAll('<!here>', '@here');
  }

  String _convertRichTextElementToString({
    required Map<String, dynamic> element,
    required List<MessageChannelEntity> channels,
    required List<MessageMemberEntity> members,
    required List<MessageGroupEntity> groups,
  }) {
    if (element['type'] == null) return '';
    switch (element['type']) {
      case 'channel':
        final channelId = element['channel_id'];
        final targetChannel = channels.firstWhereOrNull((c) => c.id == channelId);
        return targetChannel != null ? '#${targetChannel.name}' : '#${channelId}';

      case 'emoji':
        final unicode = element['unicode'];
        final name = element['name'];
        final emoji = Emojis.getOneOrNull((unicode ?? '').toUpperCase())?.value;
        return emoji ?? ':${name}:';

      case 'link':
        return element['text'] ?? element['url'] ?? '';

      case 'text':
        String text = element['text'] ?? '';
        if (element['style']?['bold'] ?? false) text = '*$text*';
        if (element['style']?['italic'] ?? false) text = '_${text}_';
        if (element['style']?['strike'] ?? false) text = '~${text}~';
        if (element['style']?['code'] ?? false) text = '`${text}`';
        return text;

      case 'user':
        final userId = element['user_id'];
        final member = members.firstWhereOrNull((m) => m.id == userId);
        return member != null ? '@${member.displayName}' : '@${userId}';

      case 'usergroup':
        final groupId = element['usergroup_id'];
        final group = groups.firstWhereOrNull((g) => g.id == groupId);
        return group != null ? '@${group.displayName}' : '@${groupId}';

      case 'broadcast':
        return '@${element['range']}';

      default:
        return element['text'] ?? '';
    }
  }

  bool _isSingleEmoji(
    List<dynamic> elements, {
    required List<MessageChannelEntity> channels,
    required List<MessageMemberEntity> members,
    required List<MessageGroupEntity> groups,
  }) {
    if (elements.where((e) => e['type'] == 'emoji').length == 1 &&
        _convertNestedElementsToString(
          elements.where((e) => e['type'] != 'emoji').toList(),
          channels: channels,
          members: members,
          groups: groups,
        ).trim().isEmpty) {
      return true;
    }
    return false;
  }

  String _convertNestedElementsToHtml({
    required List<dynamic> elements,
    required List<MessageChannelEntity> channels,
    required List<MessageMemberEntity> members,
    required List<MessageGroupEntity> groups,
    required List<MessageEmojiEntity> emojis,
    required bool? forEdit,
  }) {
    final buffer = StringBuffer();

    for (var i = 0; i < elements.length; i++) {
      try {
        Map<String, dynamic> element = elements[i];
        if (element['type'] == 'rich_text_list') {
          final indent = element['indent'] ?? 0;
          final style = element['style'] ?? {'bullet': true};
          final tagName = style['bullet'] == true ? 'ul' : 'ol';

          final prevElement = i > 0 ? elements[i - 1] : null;
          final nextElement = i < elements.length - 1 ? elements[i + 1] : null;

          // Handle list nesting
          if (prevElement == null || prevElement['type'] != 'rich_text_list' || (prevElement['indent'] ?? 0) < indent) {
            final count = indent - (prevElement?['indent'] ?? -1);
            for (var i = 0; i < count; i++) {
              String listStyle;
              if ((indent + i) % 3 == 0) {
                listStyle = tagName == 'ul' ? 'list-style-type:disc' : 'list-style-type:decimal';
              } else if ((indent + i) % 3 == 1) {
                listStyle = tagName == 'ul' ? 'list-style-type:circle' : 'list-style-type:lower-alpha';
              } else {
                listStyle = tagName == 'ul' ? 'list-style-type:square' : 'list-style-type:lower-roman';
              }
              buffer.write('<$tagName style="$listStyle">');
            }
          }

          // Process list items
          for (var sectionData in element['elements'] ?? []) {
            buffer.write('<li>');

            // Process the list item's content
            final sectionElements = sectionData['elements'] ?? [];

            for (var sectionElement in sectionElements) {
              buffer.write(
                _convertRichTextElementToHtml(
                  element: sectionElement,
                  channels: channels,
                  members: members,
                  groups: groups,
                  emojis: emojis,
                  forEdit: forEdit,
                  isSingleEmoji: _isSingleEmoji(sectionElements, channels: channels, members: members, groups: groups),
                ),
              );
            }
            if (forEdit != true) buffer.write('</li>');
          }

          // Check if we need to close the current list
          if (nextElement == null || nextElement['type'] != 'rich_text_list' || (nextElement['indent'] ?? 0) < indent) {
            final count = indent - (nextElement?['indent'] ?? -1);
            for (var i = 0; i < count; i++) {
              buffer.write('</$tagName>');
            }

            if (forEdit == true) buffer.write('</li>');
          }
        } else if (element['type'] == 'rich_text_quote') {
          buffer.write(
            '<blockquote>${_convertNestedElementsToHtml(elements: element['elements']!, channels: channels, members: members, groups: groups, emojis: emojis, forEdit: forEdit)}</blockquote>',
          );
        } else if (element['type'] == 'rich_text_preformatted') {
          buffer.write(
            '<pre>${_convertNestedElementsToHtml(elements: element['elements']!, channels: channels, members: members, groups: groups, emojis: emojis, forEdit: forEdit)}</pre>',
          );
        } else if (element['elements'] != null) {
          buffer.write(
            _convertNestedElementsToHtml(
              elements: element['elements']!,
              channels: channels,
              members: members,
              groups: groups,
              emojis: emojis,
              forEdit: forEdit,
            ),
          );
        } else {
          buffer.write(
            _convertRichTextElementToHtml(
              element: element,
              channels: channels,
              members: members,
              groups: groups,
              emojis: emojis,
              forEdit: forEdit,
              verbatim: element['verbatim'] != false,
              isSingleEmoji: _isSingleEmoji(elements, channels: channels, members: members, groups: groups),
            ),
          );
        }
      } catch (e) {}
    }

    return buffer.toString();
  }

  String _convertSlackBlockToHtml({
    required List<SlackMessageBlockEntity> blocks,
    required List<MessageChannelEntity> channels,
    required List<MessageMemberEntity> members,
    required List<MessageGroupEntity> groups,
    required List<MessageEmojiEntity> emojis,
    required bool? forEdit,
  }) {
    final buffer = StringBuffer();
    for (final block in blocks) {
      switch (block.type) {
        case SlackMessageBlockEntityType.divider:
          buffer.write('<hr>');
          break;
        case SlackMessageBlockEntityType.richText:
          final elements = (block.elements ?? []).map((e) {
            if (e['style'] is String) {
              final newStyle = <String, bool>{};
              newStyle[e['style'] as String] = true;
              e = <String, dynamic>{...e, 'style': newStyle};
            }
            return e;
          }).toList();

          buffer.write(
            _convertNestedElementsToHtml(elements: elements, channels: channels, members: members, groups: groups, emojis: emojis, forEdit: forEdit),
          );
          break;
        case SlackMessageBlockEntityType.header:
          if (forEdit != true)
            buffer.write(
              '<h3>${_convertSlackTextToHtml(text: block.text?.text ?? '', channels: channels, members: members, groups: groups, emojis: emojis, forEdit: forEdit)}</h3>',
            );
          break;
        case SlackMessageBlockEntityType.section:
          if (forEdit != true)
            buffer.write(
              '<p>${_convertSlackTextToHtml(text: block.text?.text ?? '', channels: channels, members: members, groups: groups, emojis: emojis, forEdit: forEdit)}</p>',
            );
          break;
        case SlackMessageBlockEntityType.image:
          if (forEdit != true) buffer.write('<div class="image-container"><img src="${block.imageUrl}" alt="${block.altText ?? ''}"></div>');
          break;
        case SlackMessageBlockEntityType.video:
          if (forEdit != true)
            buffer.write('''
            <div class="video-container">
              <p>${block.description?['text'] ?? ''}</p>
              <a href="${block.videoUrl}" class="link">${_convertSlackTextToHtml(text: block.title?['text'] ?? '', channels: channels, members: members, groups: groups, emojis: emojis, forEdit: forEdit)}</a> 
            </div>
          ''');
          break;
        case SlackMessageBlockEntityType.context:
          final elements = (block.elements ?? []).map((e) {
            if (e['style'] is String) {
              final newStyle = <String, bool>{};
              newStyle[e['style'] as String] = true;
              e = <String, dynamic>{...e, 'style': newStyle};
            }
            return e;
          }).toList();

          buffer.write('''
            <div class="context-container">
              ${_convertNestedElementsToHtml(elements: elements, channels: channels, members: members, groups: groups, emojis: emojis, forEdit: forEdit)}
            </div>
          ''');
          break;
        default:
          break;
      }
    }

    return buffer.toString();
  }

  String toHtml({
    required MessageChannelEntity channel,
    required List<MessageChannelEntity> channels,
    required List<MessageMemberEntity> members,
    required List<MessageGroupEntity> groups,
    required List<MessageEmojiEntity> emojis,
    bool? forEdit,
  }) {
    final buffer = StringBuffer();

    if ((blocks == null || blocks!.isEmpty) && text != null) {
      buffer.write(_convertSlackTextToHtml(text: text!, channels: channels, members: members, groups: groups, emojis: emojis, forEdit: forEdit));
    }

    // Handle predefined message types first
    if (blocks?.isEmpty == true) {
      if (forEdit != true) {
        switch (subtype) {
          case SlackMessageEntitySubtype.channelJoin:
          case SlackMessageEntitySubtype.groupJoin:
            buffer.write('<p>${Utils.mainContext.tr.chat_formatted_message_user_joines} #${channel.name}</p>');
          case SlackMessageEntitySubtype.channelArchive:
          case SlackMessageEntitySubtype.groupArchive:
            buffer.write(
              '<p>${Utils.mainContext.tr.chat_formatted_message_user_archived} #${channel.name}. ${Utils.mainContext.tr.chat_formatted_message_user_archived_description}</p>',
            );
          case SlackMessageEntitySubtype.channelUnarchive:
          case SlackMessageEntitySubtype.groupUnarchive:
            buffer.write('<p>${Utils.mainContext.tr.chat_formatted_message_user_unarchived} #${channel.name}</p>');
          case SlackMessageEntitySubtype.channelLeave:
          case SlackMessageEntitySubtype.groupLeave:
            buffer.write('<p>${Utils.mainContext.tr.chat_formatted_message_user_left} #${channel.name}</p>');
          default:
            break;
        }
      }
    }

    // Handle blocks
    buffer.write(_convertSlackBlockToHtml(blocks: blocks ?? [], channels: channels, members: members, groups: groups, emojis: emojis, forEdit: forEdit));

    // Handle attachments
    if (forEdit != true) {
      for (SlackMessageAttachmentEntity attachment in attachments ?? []) {
        final fromChannelId = attachment.fromUrl?.split('/').reversed.elementAt(1);
        final fromChannel = channels.firstWhereOrNull((c) => c.id == fromChannelId);

        buffer.write('''
        <div class="attachment">
          ${attachment.pretext != null ? '<p>${_convertSlackTextToHtml(text: attachment.pretext!, channels: channels, members: members, groups: groups, emojis: emojis, forEdit: forEdit)}</p>' : ''}
          <div class="attachment-content" style="border-left: 3px solid ${attachment.color != null
            ? attachment.color?.startsWith('#') == true
                  ? attachment.color
                  : '#${attachment.color}'
            : '${Utils.mainContext.surfaceVariant.value.toRadixString(16).padLeft(8, '0')}'}; border-radius: 4px; padding-left: 8px; margin-top: 8px;">
            <div class="attachment-content-wrapper">
              ${attachment.serviceIcon != null ? '''
                <div class="service-info">
                  <serviceicon src="${attachment.serviceIcon}" class="service-icon" text="${attachment.serviceName}">
                </div>
              ''' : ''}
              ${attachment.authorName != null ? '''
                <div class="author-info">
                  <img src="${attachment.authorIcon}" class="author-icon">
                  <span>${attachment.authorName}</span>
                </div>
              ''' : ''}
              ${attachment.title != null ? '''
                <div class="title-section">
                  <a href="${attachment.titleLink}" class="link">${_convertSlackTextToHtml(text: attachment.title!, channels: channels, members: members, groups: groups, emojis: emojis, forEdit: forEdit)}</a>
                </div>
              ''' : ''}
              ${attachment.text != null ? '<div class="text-section"><p>${_convertSlackTextToHtml(text: attachment.text!, channels: channels, members: members, groups: groups, emojis: emojis, forEdit: forEdit)}</p></div>' : ''}
              ${attachment.blocks?.isNotEmpty == true ? '<div class="blocks-section">${_convertSlackBlockToHtml(blocks: attachment.blocks?.map((e) => SlackMessageBlockEntity.fromJson(e)).toList() ?? [], channels: channels, members: members, groups: groups, emojis: emojis, forEdit: forEdit)}</div>' : ''}
              ${attachment.fields?.isNotEmpty == true ? '''
                <div class="attachment-fields"> 
                  ${attachment.fields!.map((field) {
                return '''
                    <div class="attachment-field">
                      <p>${_convertSlackTextToHtml(text: field['title'], channels: channels, members: members, groups: groups, emojis: emojis, forEdit: forEdit, verbatim: field['verbatim'] != false)}</p>
                      <p>${_convertSlackTextToHtml(text: field['value'], channels: channels, members: members, groups: groups, emojis: emojis, forEdit: forEdit, verbatim: field['verbatim'] != false)}</p>
                    </div>
                  ''';
              }).join('')}
                </div>
              ''' : ''}
              ${attachment.footer != null ? '''
                <div class="attachment-footer">
                  <footericon src="${attachment.footerIcon}" class="footer-icon" text="${attachment.footer}"/>  
                </div>
              ''' : ''}
              ${fromChannel != null ? '''
                <div class="forwarded-message-footer">
                  <span> | ${fromChannel.isChannel == true ? Utils.mainContext.tr.message_forwarded_view_message : Utils.mainContext.tr.message_forwarded_view_conversation}</span>
                </div>
              ''' : ''}
            </div>
          </div>
        </div>
      ''');
      }
    }

    return _trimHtml(buffer.toString());
  }

  String _trimHtml(String html) {
    final orignalLength = html.length;
    html = html.startsWith('<br/>') ? html.substring(5) : html;
    html = html.endsWith('<br/>') ? html.substring(0, html.length - 5) : html;
    if (html.length != orignalLength) {
      return _trimHtml(html);
    }
    return html;
  }

  String _convertSlackTextToHtml({
    required String text,
    String? searchQuery,
    required List<MessageChannelEntity> channels,
    required List<MessageMemberEntity> members,
    required List<MessageGroupEntity> groups,
    required List<MessageEmojiEntity> emojis,
    required bool? forEdit,
    bool? verbatim = true,
  }) {
    final generalTag = forEdit == true ? 'p' : 'span';
    // 먼저 검색 하이라이트 처리
    final searchPattern = searchQuery?.isNotEmpty == true ? RegExp(RegExp.escape(searchQuery!), caseSensitive: false) : null;
    if (searchPattern != null) {
      text = text.replaceAllMapped(searchPattern, (match) {
        return '<$generalTag class="search-highlight">${match.group(0)}</$generalTag>';
      });
    }

    // 2단계: 포맷팅 처리 (순차적으로)
    // Convert &gt; to blockquote
    text = text.replaceAllMapped(RegExp(r'&gt;\s*(.*?)(?=\n|$)'), (match) {
      return '<blockquote>${match.group(1)}</blockquote>';
    });

    // 취소선 처리
    text = text.replaceAllMapped(RegExp(r'~([^~]+)~'), (match) {
      return '<del>${match.group(1)}</del>';
    });

    // 이탤릭 처리
    text = text.replaceAllMapped(RegExp(r'_([^_]+)_'), (match) {
      return '<em>${match.group(1)}</em>';
    });

    // 굵게 처리
    text = text.replaceAllMapped(RegExp(r'\*([^\*]+)\*'), (match) {
      return '<strong>${match.group(1)}</strong>';
    });

    // 1단계: 멘션, 채널, 링크 등의 특수 요소 처리
    RegExp specialElementsRegex = RegExp(
      r'<@([^>]+)>' + // 멘션
          r'|<!date\^(\d+)\^{([^>]+)}\|([^>]+)>' + // 날짜
          r'|<!(?:channel|here)>' + // broadcast 멘션
          r'|(?:<)?(?:https?:\/\/[^\s|>]+)(?:\|[^>]*)?(?:>)?' + // 일반 링크
          r'|`<([^|>]+)\|([^>]+)>`' + // 코드 블럭
          r'|:([^:\s]+):\s*' + // 이모지
          r'|`([^`]+)`', // 마크다운
      dotAll: true,
    );

    text = text.replaceAllMapped(specialElementsRegex, (match) {
      if (match.group(1) != null) {
        // 멘션 처리
        final userId = match.group(1)!;
        final member = members.firstWhereOrNull((m) => m.id == userId);
        return member != null
            ? '<$generalTag class="user-mention" data-user-id="${member.id}">@${member.displayName}</$generalTag>'
            : '<$generalTag class="user-mention" data-user-id="${userId}">@${userId}</$generalTag>';
      } else if (match.group(2) != null && match.group(3) != null && match.group(4) != null) {
        // 날짜 처리
        final timestamp = int.parse(match.group(2)!);
        final formatString = match.group(3)!;
        final fallbackText = match.group(4)!;
        final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
        final formattedDate = formatString == 'time'
            ? DateFormat.jm().format(date)
            : formatString == 'date_short_pretty'
            ? DateFormat.MMMd().format(date)
            : formatString == 'date_long_pretty'
            ? '${DateFormat.EEEE().format(date)}, ${DateFormat.MMMM().format(date)} ${date.day}${Utils.getOrdinalSuffix(date.day)}'
            : fallbackText;
        return ' ${formattedDate} ';
      } else if (match.group(5) != null) {
        // 코드 블럭 처리
        final url = match.group(5)!;
        final displayText = match.group(6) ?? url;
        return '<code><a href="${url}" class="link">${displayText}</a></code>';
      } else if (match.group(7) != null) {
        // 이모지 처리
        final emojiText = match.group(7)!;
        try {
          final element = jsonDecode(emojiText);
          final customEmoji = emojis.firstWhereOrNull((e) => e.name == element['name']);
          return '<emoji class="emoji" src="${customEmoji?.url ?? element['url']}" name="${element['name']}" unicode="${element['unicode']}"></emoji>';
        } catch (e) {
          final customEmoji = emojis.firstWhereOrNull((e) => e.name == emojiText);
          if (customEmoji != null) return '<emoji class="emoji" src="${customEmoji.url}" name="${customEmoji.name}"></emoji>';
          final emoji = Emojis.getOneOrNull(emojiText);
          return '<emoji class="emoji" src="null" name="${emoji?.name.toLowerCase()}" unicode="${emoji?.unicode.toLowerCase()}"></emoji>';
        }
      } else if (match.group(8) != null) {
        // 마크다운 처리
        final codeText = match.group(8)!;
        return '<code>${codeText}</code>';
      } else {
        // 일반 링크 처리
        final matchedText = match.group(0)!;
        final parts = matchedText.split('|');
        final url = parts[0].replaceAll('<', '').replaceAll('>', '');
        final displayText = parts.length > 1 ? parts[1].replaceAll('>', '') : url;

        return '<a href="${url}" class="link">${displayText}</a>';
      }
    });

    // 줄바꿈 처리
    text = text.replaceAll('\n', '<br/>');

    // Verbatim 이 false일 경우 padding-right 추가
    if (verbatim == false) {
      text = '<span style="padding-right: 18px;">$text</span>';
    }

    // broadcast 멘션 처리
    return text
        .replaceAll('<!channel>', '<$generalTag class="broadcast-mention" data-range="channel">@channel</$generalTag>')
        .replaceAll('<!here>', '<$generalTag class="broadcast-mention" data-range="here">@here</$generalTag>');
  }

  String _convertRichTextElementToHtml({
    required Map<String, dynamic> element,
    required List<MessageChannelEntity> channels,
    required List<MessageMemberEntity> members,
    required List<MessageGroupEntity> groups,
    required List<MessageEmojiEntity> emojis,
    required bool? forEdit,
    bool? verbatim = true,
    bool? isSingleEmoji = false,
  }) {
    final generalTag = forEdit == true ? 'p' : 'span';
    if (element['type'] == null) return '';

    switch (element['type']) {
      case 'channel':
        final channelId = element['channel_id'];
        final targetChannel = channels.firstWhereOrNull((c) => c.id == channelId);
        return targetChannel != null
            ? '<$generalTag class="channel-mention" data-channel-id="${targetChannel.id}">#${targetChannel.name}</$generalTag>'
            : '<$generalTag class="channel-mention" data-channel-id="${channelId}">#${channelId}</$generalTag>';

      case 'emoji':
        final emoji = emojis.firstWhereOrNull((e) => e.name == element['name']);
        return '<emoji class="emoji" src="${emoji?.url ?? element['url']}" name="${element['name']}" unicode="${element['unicode']}" single="${isSingleEmoji ?? false}"></emoji>';

      case 'image':
        return '<icon src="${element['image_url']}" alt="${element['alt_text']}"></icon>';

      case 'link':
        return '<a href="${element['url'] ?? element['text']}">${element['text'] ?? element['url']}</a>';

      case 'text':
        String text = element['text'] ?? '';
        text = text.replaceAll('\n', '<br/>');

        // String text = _convertSlackTextToHtml(
        //     text: element['text'] ?? '', channel: channel, channels: channels, forEdit: forEdit, verbatim: element['verbatim'] != false);
        if (element['style']?['bold'] ?? false) text = '<strong>$text</strong>';
        if (element['style']?['italic'] ?? false) text = '<em>$text</em>';
        if (element['style']?['strike'] ?? false) text = '<del>$text</del>';
        if (element['style']?['code'] ?? false) text = '<code>$text</code>';
        return text;

      case 'user':
        final userId = element['user_id'];
        final member = members.firstWhereOrNull((m) => m.id == userId);
        return member != null
            ? '<$generalTag class="user-mention" data-user-id="${member.id}">@${member.displayName}</$generalTag>'
            : '<$generalTag class="user-mention" data-user-id="${userId}">@${userId}</$generalTag>';

      case 'usergroup':
        final groupId = element['usergroup_id'];
        final group = groups.firstWhereOrNull((g) => g.id == groupId);
        return group != null
            ? '<$generalTag class="usergroup-mention" data-group-id="${group.id}">@${group.displayName}</$generalTag>'
            : '<$generalTag class="usergroup-mention" data-group-id="${groupId}">@${groupId}</$generalTag>';

      case 'broadcast':
        return '<$generalTag class="broadcast-mention">@${element['range']}</$generalTag>';

      case 'rich_text_section':
        String text = _convertSlackTextToHtml(
          text: element['text'] ?? '',
          channels: channels,
          members: members,
          groups: groups,
          emojis: emojis,
          forEdit: forEdit,
          verbatim: element['verbatim'] != false,
        );
        if (element['style']?['bold'] ?? false) text = '<strong>$text</strong>';
        if (element['style']?['italic'] ?? false) text = '<em>$text</em>';
        if (element['style']?['strike'] ?? false) text = '<del>$text</del>';
        if (element['style']?['code'] ?? false) text = '<code>$text</code>';
        return text;
      case 'date':
        String text = _convertSlackTextToHtml(
          text: element['fallback'] ?? '',
          channels: channels,
          members: members,
          groups: groups,
          emojis: emojis,
          forEdit: forEdit,
          verbatim: element['verbatim'] != false,
        );
        if (element['style']?['bold'] ?? false) text = '<strong>$text</strong>';
        if (element['style']?['italic'] ?? false) text = '<em>$text</em>';
        if (element['style']?['strike'] ?? false) text = '<del>$text</del>';
        if (element['style']?['code'] ?? false) text = '<code>$text</code>';
        return text;
      case 'color':
        return '<color>${element['value']}</color>';

      default:
        return _convertSlackTextToHtml(
          text: element['text'] ?? '',
          channels: channels,
          members: members,
          groups: groups,
          emojis: emojis,
          forEdit: forEdit,
          verbatim: element['verbatim'] != false,
        );
    }
  }
}
