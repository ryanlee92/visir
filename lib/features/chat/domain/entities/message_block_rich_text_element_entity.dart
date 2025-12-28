import 'package:Visir/features/chat/domain/entities/message_block_entity.dart';
import 'package:Visir/features/chat/domain/entities/slack/chat_block/slack_message_block_rich_text_element_entity.dart';

enum MessageBlockRichTextElementEntityType {
  channel,
  emoji,
  link,
  text,
  user,
  usergroup,
  broadcast,
  richTextSection,
  date,
  color,
}

extension MessageBlockRichTextElementEntityTypeX on MessageBlockRichTextElementEntityType {
  SlackMessageBlockRichTextElementEntityType get slack {
    switch (this) {
      case MessageBlockRichTextElementEntityType.channel:
        return SlackMessageBlockRichTextElementEntityType.channel;
      case MessageBlockRichTextElementEntityType.emoji:
        return SlackMessageBlockRichTextElementEntityType.emoji;
      case MessageBlockRichTextElementEntityType.link:
        return SlackMessageBlockRichTextElementEntityType.link;
      case MessageBlockRichTextElementEntityType.text:
        return SlackMessageBlockRichTextElementEntityType.text;
      case MessageBlockRichTextElementEntityType.user:
        return SlackMessageBlockRichTextElementEntityType.user;
      case MessageBlockRichTextElementEntityType.usergroup:
        return SlackMessageBlockRichTextElementEntityType.usergroup;
      case MessageBlockRichTextElementEntityType.broadcast:
        return SlackMessageBlockRichTextElementEntityType.broadcast;
      case MessageBlockRichTextElementEntityType.richTextSection:
        return SlackMessageBlockRichTextElementEntityType.richTextSection;
      case MessageBlockRichTextElementEntityType.date:
        return SlackMessageBlockRichTextElementEntityType.date;
      case MessageBlockRichTextElementEntityType.color:
        return SlackMessageBlockRichTextElementEntityType.color;
    }
  }
}

class MessageBlockRichTextElementEntity {
  final SlackMessageBlockRichTextElementEntity? _slackRichTextElement;
  final MessageBlockInegrationType type;

  MessageBlockRichTextElementEntity.fromSlack({required SlackMessageBlockRichTextElementEntity element})
      : _slackRichTextElement = element,
        type = MessageBlockInegrationType.slack;

  MessageBlockRichTextElementEntity.fromText(
      {required this.type, required MessageBlockRichTextElementEntityType elementType, required String text, String? url})
      : _slackRichTextElement = type == MessageBlockInegrationType.slack
            ? SlackMessageBlockRichTextElementEntity(
                type: elementType.slack,
                text: text,
                url: url,
              )
            : null;

  factory MessageBlockRichTextElementEntity.fromJson(Map<String, dynamic> json) {
    MessageBlockInegrationType type = MessageBlockInegrationType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => MessageBlockInegrationType.slack,
    );

    if (type == MessageBlockInegrationType.slack) {
      return MessageBlockRichTextElementEntity.fromSlack(
        element: SlackMessageBlockRichTextElementEntity.fromJson(json['_slackRichTextElement']),
      );
    }

    return MessageBlockRichTextElementEntity.fromSlack(
      element: SlackMessageBlockRichTextElementEntity.fromJson(json['_slackRichTextElement']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "type": type.name,
      "_slackRichTextElement": _slackRichTextElement?.toJson(),
    };
  }

  List<MessageBlockRichTextElementEntity> get elements {
    switch (type) {
      case MessageBlockInegrationType.slack:
        return (_slackRichTextElement?.elements ?? [])
            .map((e) => MessageBlockRichTextElementEntity.fromSlack(element: SlackMessageBlockRichTextElementEntity.fromJson(e)))
            .toList();
    }
  }

  MessageBlockRichTextElementEntityType? get elementType {
    switch (type) {
      case MessageBlockInegrationType.slack:
        switch (_slackRichTextElement?.type) {
          case SlackMessageBlockRichTextElementEntityType.channel:
            return MessageBlockRichTextElementEntityType.channel;
          case SlackMessageBlockRichTextElementEntityType.emoji:
            return MessageBlockRichTextElementEntityType.emoji;
          case SlackMessageBlockRichTextElementEntityType.link:
            return MessageBlockRichTextElementEntityType.link;
          case SlackMessageBlockRichTextElementEntityType.text:
            return MessageBlockRichTextElementEntityType.text;
          case SlackMessageBlockRichTextElementEntityType.user:
            return MessageBlockRichTextElementEntityType.user;
          case SlackMessageBlockRichTextElementEntityType.usergroup:
            return MessageBlockRichTextElementEntityType.usergroup;
          case SlackMessageBlockRichTextElementEntityType.broadcast:
            return MessageBlockRichTextElementEntityType.broadcast;
          case SlackMessageBlockRichTextElementEntityType.richTextSection:
            return MessageBlockRichTextElementEntityType.richTextSection;
          case SlackMessageBlockRichTextElementEntityType.date:
            return MessageBlockRichTextElementEntityType.date;
          case SlackMessageBlockRichTextElementEntityType.color:
            return MessageBlockRichTextElementEntityType.color;
          default:
            return null;
        }
    }
  }

  Map<String, bool>? get style {
    switch (type) {
      case MessageBlockInegrationType.slack:
        return _slackRichTextElement?.style;
    }
  }

  String? get channelId {
    switch (type) {
      case MessageBlockInegrationType.slack:
        return _slackRichTextElement?.channelId;
    }
  }

  String? get unicode {
    switch (type) {
      case MessageBlockInegrationType.slack:
        return _slackRichTextElement?.unicode;
    }
  }

  String? get name {
    switch (type) {
      case MessageBlockInegrationType.slack:
        return _slackRichTextElement?.name;
    }
  }

  String? get text {
    switch (type) {
      case MessageBlockInegrationType.slack:
        return _slackRichTextElement?.text;
    }
  }

  String? get url {
    switch (type) {
      case MessageBlockInegrationType.slack:
        return _slackRichTextElement?.url;
    }
  }

  String? get userId {
    switch (type) {
      case MessageBlockInegrationType.slack:
        return _slackRichTextElement?.userId;
    }
  }

  String? get usergroupId {
    switch (type) {
      case MessageBlockInegrationType.slack:
        return _slackRichTextElement?.usergroupId;
    }
  }

  String? get range {
    switch (type) {
      case MessageBlockInegrationType.slack:
        return _slackRichTextElement?.range;
    }
  }

  String? get fallback {
    switch (type) {
      case MessageBlockInegrationType.slack:
        return _slackRichTextElement?.fallback;
    }
  }

  String? get value {
    switch (type) {
      case MessageBlockInegrationType.slack:
        return _slackRichTextElement?.value;
    }
  }
}
