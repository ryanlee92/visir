import 'package:Visir/features/chat/domain/entities/slack/slack_message_emoji_entity.dart';

enum MessageEmojiEntityType { slack }

class MessageEmojiEntity {
  //for slack
  final SlackMessagEmojiEntity? _slackEmoji;

  //common
  final MessageEmojiEntityType type;

  MessageEmojiEntity.fromSlack({required SlackMessagEmojiEntity emoji}) : _slackEmoji = emoji, type = MessageEmojiEntityType.slack;

  factory MessageEmojiEntity.fromJson(Map<String, dynamic> json) {
    MessageEmojiEntityType messageTeamEmojiType = MessageEmojiEntityType.values.firstWhere(
      (e) => e.name == json['emojiType'],
      orElse: () => MessageEmojiEntityType.slack,
    );

    if (messageTeamEmojiType == MessageEmojiEntityType.slack) {
      return MessageEmojiEntity.fromSlack(emoji: SlackMessagEmojiEntity.fromJson(json['_slackEmoji']));
    }

    return MessageEmojiEntity.fromSlack(emoji: SlackMessagEmojiEntity.fromJson(json['_slackEmoji']));
  }

  Map<String, dynamic> toJson() {
    return {"emojiType": type.name, "_slackEmoji": _slackEmoji?.toJson()};
  }

  SlackMessagEmojiEntity? get slackEmoji => _slackEmoji;

  String? get id {
    switch (type) {
      case MessageEmojiEntityType.slack:
        return _slackEmoji?.name;
    }
  }

  String? get name {
    switch (type) {
      case MessageEmojiEntityType.slack:
        return _slackEmoji?.name;
    }
  }

  String? get url {
    switch (type) {
      case MessageEmojiEntityType.slack:
        return _slackEmoji?.url;
    }
  }

  bool get isAlias {
    switch (type) {
      case MessageEmojiEntityType.slack:
        return _slackEmoji?.url.startsWith('alias:') ?? false;
    }
  }

  String? get aliasOriginalName {
    if (!isAlias) return null;
    switch (type) {
      case MessageEmojiEntityType.slack:
        return _slackEmoji?.url.replaceAll('alias:', '');
    }
  }
}

extension MessageEmojiEntityListX on List<MessageEmojiEntity> {
  MessageEmojiEntity? getCustomEmojiFromName({required String? name}) {
    return this.where((e) => e.name == name).firstOrNull;
  }
}
