import 'package:Visir/features/chat/domain/entities/message_block_element_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_block_text_object_entity.dart';
import 'package:Visir/features/chat/domain/entities/slack/chat_block/slack_message_block_entity.dart';
import 'package:Visir/features/chat/domain/entities/slack/chat_block/slack_message_block_rich_text_entity.dart';

enum MessageBlockInegrationType {
  slack,
}

enum MessageBlockEntityType {
  actions,
  context,
  divider,
  file,
  header,
  image,
  input,
  richText,
  section,
  video,
}

class MessageBlockEntity {
  final SlackMessageBlockEntity? _slackMessageBlock;
  final MessageBlockInegrationType type;

  MessageBlockEntity.fromSlack({required SlackMessageBlockEntity block})
      : _slackMessageBlock = block,
        type = MessageBlockInegrationType.slack;

  factory MessageBlockEntity.fromJson(Map<String, dynamic> json) {
    MessageBlockInegrationType type = MessageBlockInegrationType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => MessageBlockInegrationType.slack,
    );

    if (type == MessageBlockInegrationType.slack) {
      return MessageBlockEntity.fromSlack(
        block: SlackMessageBlockEntity.fromJson(json['_slackMessageBlock']),
      );
    }

    return MessageBlockEntity.fromSlack(
      block: SlackMessageBlockEntity.fromJson(json['_slackMessageBlock']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "type": type.name,
      "_slackMessageBlock": _slackMessageBlock?.toJson(),
    };
  }

  SlackMessageBlockEntity? get slackMessageBlock {
    switch (type) {
      case MessageBlockInegrationType.slack:
        return _slackMessageBlock;
    }
  }

  MessageBlockEntityType? get blockType {
    switch (type) {
      case MessageBlockInegrationType.slack:
        switch (_slackMessageBlock?.type) {
          case SlackMessageBlockEntityType.actions:
            return MessageBlockEntityType.actions;
          case SlackMessageBlockEntityType.context:
            return MessageBlockEntityType.context;
          case SlackMessageBlockEntityType.divider:
            return MessageBlockEntityType.divider;
          case SlackMessageBlockEntityType.file:
            return MessageBlockEntityType.file;
          case SlackMessageBlockEntityType.header:
            return MessageBlockEntityType.header;
          case SlackMessageBlockEntityType.image:
            return MessageBlockEntityType.image;
          case SlackMessageBlockEntityType.input:
            return MessageBlockEntityType.input;
          case SlackMessageBlockEntityType.richText:
            return MessageBlockEntityType.richText;
          case SlackMessageBlockEntityType.section:
            return MessageBlockEntityType.section;
          case SlackMessageBlockEntityType.video:
            return MessageBlockEntityType.video;
          case null:
            return null;
        }
    }
  }

  bool get isUnavailable {
    switch (type) {
      case MessageBlockInegrationType.slack:
        List<MessageBlockEntityType> list = [
          MessageBlockEntityType.actions,
          MessageBlockEntityType.file,
          MessageBlockEntityType.input,
        ];
        return list.contains(blockType);
    }
  }

  List<MessageBlockElementEntity> get elements {
    switch (type) {
      case MessageBlockInegrationType.slack:
        return (_slackMessageBlock?.elements ?? [])
            .map((e) => MessageBlockElementEntity.fromSlack(element: SlackMessageBlockElementEntity.fromJson(e)))
            .toList();
    }
  }

  MessageBlockTextObjectEntity? get text {
    switch (type) {
      case MessageBlockInegrationType.slack:
        return _slackMessageBlock?.text == null ? null : MessageBlockTextObjectEntity.fromSlack(object: _slackMessageBlock!.text!);
    }
  }

  String? get id {
    switch (type) {
      case MessageBlockInegrationType.slack:
        return _slackMessageBlock?.blockId;
    }
  }

  String? get imageUrl {
    switch (type) {
      case MessageBlockInegrationType.slack:
        return _slackMessageBlock?.imageUrl;
    }
  }

  String? get videoUrl {
    switch (type) {
      case MessageBlockInegrationType.slack:
        return _slackMessageBlock?.videoUrl;
    }
  }

  Map<String, dynamic>? get title {
    switch (type) {
      case MessageBlockInegrationType.slack:
        return _slackMessageBlock?.title ?? {};
    }
  }

  Map<String, dynamic>? get description {
    switch (type) {
      case MessageBlockInegrationType.slack:
        return _slackMessageBlock?.description ?? {};
    }
  }
}
