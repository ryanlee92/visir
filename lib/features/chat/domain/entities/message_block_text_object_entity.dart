import 'package:Visir/features/chat/domain/entities/message_block_entity.dart';
import 'package:Visir/features/chat/domain/entities/slack/chat_block/object/slack_message_block_text_object_entity.dart';

class MessageBlockTextObjectEntity {
  final SlackMessageBlockTextObjectEntity? _slackObject;
  final MessageBlockInegrationType type;

  MessageBlockTextObjectEntity.fromSlack({required SlackMessageBlockTextObjectEntity object})
      : _slackObject = object,
        type = MessageBlockInegrationType.slack;

  factory MessageBlockTextObjectEntity.fromJson(Map<String, dynamic> json) {
    MessageBlockInegrationType type = MessageBlockInegrationType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => MessageBlockInegrationType.slack,
    );

    if (type == MessageBlockInegrationType.slack) {
      return MessageBlockTextObjectEntity.fromSlack(
        object: SlackMessageBlockTextObjectEntity.fromJson(json['_slackObject']),
      );
    }

    return MessageBlockTextObjectEntity.fromSlack(
      object: SlackMessageBlockTextObjectEntity.fromJson(json['_slackObject']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "type": type.name,
      "_slackObject": _slackObject?.toJson(),
    };
  }

  String get text {
    switch (type) {
      case MessageBlockInegrationType.slack:
        return _slackObject?.text ?? '';
    }
  }

  bool get verbatim {
    switch (type) {
      case MessageBlockInegrationType.slack:
        return _slackObject?.verbatim ?? false;
    }
  }

  bool get emoji {
    switch (type) {
      case MessageBlockInegrationType.slack:
        return _slackObject?.emoji ?? false;
    }
  }
}
