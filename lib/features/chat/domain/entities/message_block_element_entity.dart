import 'package:Visir/features/chat/domain/entities/message_block_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_block_rich_text_element_entity.dart';
import 'package:Visir/features/chat/domain/entities/slack/chat_block/slack_message_block_rich_text_entity.dart';

enum MessageBlockElementType {
  richTextSection,
  richTextList,
  richTextPreformatted,
  richTextQuote,
  image,
  mrkdwn,
}

class MessageBlockElementEntity {
  final SlackMessageBlockElementEntity? _slackRichText;
  final MessageBlockInegrationType type;

  MessageBlockElementEntity.fromSlack({required SlackMessageBlockElementEntity element})
      : _slackRichText = element,
        type = MessageBlockInegrationType.slack;

  factory MessageBlockElementEntity.fromJson(Map<String, dynamic> json) {
    MessageBlockInegrationType type = MessageBlockInegrationType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => MessageBlockInegrationType.slack,
    );

    if (type == MessageBlockInegrationType.slack) {
      return MessageBlockElementEntity.fromSlack(
        element: SlackMessageBlockElementEntity.fromJson(json['_slackRichText']),
      );
    }

    return MessageBlockElementEntity.fromSlack(
      element: SlackMessageBlockElementEntity.fromJson(json['_slackRichText']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "type": type.name,
      "_slackRichText": _slackRichText?.toJson(),
    };
  }

  MessageBlockElementType? get elementType {
    switch (type) {
      case MessageBlockInegrationType.slack:
        switch (_slackRichText?.type) {
          case SlackMessageBlockElementEntityType.richTextSection:
            return MessageBlockElementType.richTextSection;
          case SlackMessageBlockElementEntityType.richTextList:
            return MessageBlockElementType.richTextList;
          case SlackMessageBlockElementEntityType.richTextPreformatted:
            return MessageBlockElementType.richTextPreformatted;
          case SlackMessageBlockElementEntityType.richTextQuote:
            return MessageBlockElementType.richTextQuote;
          case SlackMessageBlockElementEntityType.image:
            return MessageBlockElementType.image;
          case SlackMessageBlockElementEntityType.mrkdwn:
            return MessageBlockElementType.mrkdwn;
          case null:
            return null;
        }
    }
  }

  List<MessageBlockRichTextElementEntity> get elements {
    switch (type) {
      case MessageBlockInegrationType.slack:
        return (_slackRichText?.elements ?? []).map((e) => MessageBlockRichTextElementEntity.fromSlack(element: e)).toList();
    }
  }

  String get imageUrl {
    switch (type) {
      case MessageBlockInegrationType.slack:
        return _slackRichText?.imageUrl ?? '';
    }
  }

  String get text {
    switch (type) {
      case MessageBlockInegrationType.slack:
        return _slackRichText?.text ?? '';
    }
  }

  String get style {
    switch (type) {
      case MessageBlockInegrationType.slack:
        return _slackRichText?.style ?? '';
    }
  }

  int get indent {
    switch (type) {
      case MessageBlockInegrationType.slack:
        return _slackRichText?.indent ?? 0;
    }
  }

  int get offset {
    switch (type) {
      case MessageBlockInegrationType.slack:
        return _slackRichText?.offset ?? 0;
    }
  }

  @override
  // ignore: non_nullable_equals_parameter
  bool operator ==(dynamic other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    return this.type == other.type && this._slackRichText == other._slackRichText;
  }
}
