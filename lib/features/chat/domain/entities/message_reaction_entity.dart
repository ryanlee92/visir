import 'package:Visir/features/chat/domain/entities/slack/slack_message_reaction_entity.dart';

enum MessageReactionEntityType {
  slack,
}

class MessageReactionEntity {
  //for slack
  final SlackMessageReactionEntity? _slackMessageReaction;

  //common
  final MessageReactionEntityType type;

  MessageReactionEntity.fromSlack({SlackMessageReactionEntity? reaction})
      : _slackMessageReaction = reaction,
        type = MessageReactionEntityType.slack;

  factory MessageReactionEntity.fromJson(Map<String, dynamic> json) {
    MessageReactionEntityType messageReactionType = MessageReactionEntityType.values.firstWhere(
      (e) => e.name == json['messageReactionType'],
      orElse: () => MessageReactionEntityType.slack,
    );

    if (messageReactionType == MessageReactionEntityType.slack) {
      return MessageReactionEntity.fromSlack(
        reaction: SlackMessageReactionEntity.fromJson(json['_slackMessageReaction']),
      );
    }

    return MessageReactionEntity.fromSlack(
      reaction: SlackMessageReactionEntity.fromJson(json['_slackMessageReaction']),
    );
  }

  factory MessageReactionEntity({required MessageReactionEntityType type, required String name, required int count, required List<String> users}) {
    switch (type) {
      case MessageReactionEntityType.slack:
        return MessageReactionEntity.fromSlack(
          reaction: SlackMessageReactionEntity(name: name, count: count, users: users),
        );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "messageReactionType": type.name,
      "_slackMessageReaction": _slackMessageReaction?.toJson(),
    };
  }

  String? get name {
    switch (type) {
      case MessageReactionEntityType.slack:
        return _slackMessageReaction?.name;
    }
  }

  String? get displayName {
    switch (type) {
      case MessageReactionEntityType.slack:
        return _slackMessageReaction?.name?.replaceAll('crossed_fingers:', 'hand_with_index_and_middle_fingers_crossed');
    }
  }

  int? get count {
    switch (type) {
      case MessageReactionEntityType.slack:
        return _slackMessageReaction?.count;
    }
  }

  List<String> get users {
    switch (type) {
      case MessageReactionEntityType.slack:
        return _slackMessageReaction?.users ?? [];
    }
  }

  SlackMessageReactionEntity? get slackMessageReaction {
    switch (type) {
      case MessageReactionEntityType.slack:
        return _slackMessageReaction;
    }
  }
}
