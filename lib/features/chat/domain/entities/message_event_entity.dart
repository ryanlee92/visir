import 'package:Visir/features/chat/domain/entities/message_channel_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_entity.dart';
import 'package:Visir/features/chat/domain/entities/slack/slack_message_entity.dart';
import 'package:Visir/features/chat/domain/entities/slack/slack_message_event_entity.dart';

enum MessageEventEntityType { slack }

class MessageEventEntity {
  //for slack
  final SlackMessageEventEntity? _slackMessageEvent;

  // common
  final MessageEventEntityType type;

  MessageEventEntity.fromSlack({SlackMessageEventEntity? messageEvent}) : _slackMessageEvent = messageEvent, type = MessageEventEntityType.slack;

  factory MessageEventEntity.fromJson(Map<String, dynamic> json) {
    MessageEventEntityType messageEventType = MessageEventEntityType.values.firstWhere(
      (e) => e.name == json['messageEventType'],
      orElse: () => MessageEventEntityType.slack,
    );

    if (messageEventType == MessageEventEntityType.slack) {
      return MessageEventEntity.fromSlack(messageEvent: SlackMessageEventEntity.fromJson(json['_messageEvent']));
    }

    return MessageEventEntity.fromSlack(messageEvent: SlackMessageEventEntity.fromJson(json['_messageEvent']));
  }

  Map<String, dynamic> toJson() {
    return {"messageEventType": type.name, "_slackMessageEvent": _slackMessageEvent};
  }

  String? get teamId {
    switch (type) {
      case MessageEventEntityType.slack:
        switch (slackEventEntityType) {
          case SlackMessageEventEntityType.message:
          case SlackMessageEventEntityType.reactionAdded:
          case SlackMessageEventEntityType.reactionRemoved:
            return _slackMessageEvent?.team;
          case null:
            return null;
        }
    }
  }

  String? get userId {
    switch (type) {
      case MessageEventEntityType.slack:
        return _slackMessageEvent?.user ?? _slackMessageEvent?.previousMessage?['user'] ?? _slackMessageEvent?.message?['user'];
    }
  }

  String? get messageId {
    switch (type) {
      case MessageEventEntityType.slack:
        switch (slackEventEntityType) {
          case SlackMessageEventEntityType.message:
            return _slackMessageEvent?.message?['ts'] ?? _slackMessageEvent?.ts;
          case SlackMessageEventEntityType.reactionAdded:
          case SlackMessageEventEntityType.reactionRemoved:
            return _slackMessageEvent?.item?['ts'];
          case null:
            return null;
        }
    }
  }

  String? get channelId {
    switch (type) {
      case MessageEventEntityType.slack:
        switch (slackEventEntityType) {
          case SlackMessageEventEntityType.message:
            return _slackMessageEvent?.channel;
          case SlackMessageEventEntityType.reactionAdded:
          case SlackMessageEventEntityType.reactionRemoved:
            return _slackMessageEvent?.item?['channel'] ?? null;
          case null:
            return null;
        }
    }
  }

  String? get threadId {
    switch (type) {
      case MessageEventEntityType.slack:
        switch (slackEventEntityType) {
          case SlackMessageEventEntityType.message:
            return _slackMessageEvent?.message?['thread_ts'] ?? _slackMessageEvent?.threadTs;
          case SlackMessageEventEntityType.reactionAdded:
          case SlackMessageEventEntityType.reactionRemoved:
            return _slackMessageEvent?.item?['ts'];
          case null:
            return null;
        }
    }
  }

  String? get reaction {
    switch (type) {
      case MessageEventEntityType.slack:
        return _slackMessageEvent?.reaction;
    }
  }

  SlackMessageEventEntityType? get slackEventEntityType {
    switch (type) {
      case MessageEventEntityType.slack:
        return _slackMessageEvent?.type;
    }
  }

  SlackMessageEntitySubtype? get slackEventEntitySubtype {
    switch (type) {
      case MessageEventEntityType.slack:
        return _slackMessageEvent?.subtype;
    }
  }

  MessageEntity? getMessage({required MessageChannelEntity channel}) {
    switch (type) {
      case MessageEventEntityType.slack:
        return MessageEntity.fromJson({
          'messageType': MessageEntityType.slack,
          '_slackMessage': {...(_slackMessageEvent?.message ?? _slackMessageEvent?.toJson() ?? {}), 'channel': channel.id},
        });
    }
  }

  DateTime? get createdAt {
    switch (type) {
      case MessageEventEntityType.slack:
        return _slackMessageEvent?.ts == null ? null : DateTime.fromMicrosecondsSinceEpoch((double.tryParse(_slackMessageEvent!.ts!)! * 1000000).toInt());
    }
  }

  String? get previousThreadId {
    switch (type) {
      case MessageEventEntityType.slack:
        switch (slackEventEntityType) {
          case SlackMessageEventEntityType.message:
            return _slackMessageEvent?.previousMessage?['thread_ts'] ?? null;
          case SlackMessageEventEntityType.reactionAdded:
          case SlackMessageEventEntityType.reactionRemoved:
            return null;
          case null:
            return null;
        }
    }
  }

  String? get previousMessageId {
    switch (type) {
      case MessageEventEntityType.slack:
        switch (slackEventEntityType) {
          case SlackMessageEventEntityType.message:
            return _slackMessageEvent?.previousMessage?['ts'] ?? null;
          case SlackMessageEventEntityType.reactionAdded:
          case SlackMessageEventEntityType.reactionRemoved:
            return null;
          case null:
            return null;
        }
    }
  }
}
