import 'package:Visir/features/chat/domain/entities/slack/slack_message_group_entity.dart';

enum MessageGroupEntityType {
  slack,
}

class MessageGroupEntity {
  //for slack
  final SlackMessageGroupEntity? _slackGroup;

  //common
  final MessageGroupEntityType type;

  MessageGroupEntity.fromSlack({required SlackMessageGroupEntity group})
      : _slackGroup = group,
        type = MessageGroupEntityType.slack;

  factory MessageGroupEntity.fromJson(Map<String, dynamic> json) {
    MessageGroupEntityType teamMemberGroupType = MessageGroupEntityType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => MessageGroupEntityType.slack,
    );

    if (teamMemberGroupType == MessageGroupEntityType.slack) {
      return MessageGroupEntity.fromSlack(
        group: SlackMessageGroupEntity.fromJson(json['_slackGroup']),
      );
    }

    return MessageGroupEntity.fromSlack(
      group: SlackMessageGroupEntity.fromJson(json['_slackGroup']),
    );
  }

  toJson() {
    return {
      "type": type.name,
      "_slackGroup": _slackGroup?.toJson(),
    };
  }

  String? get id {
    switch (type) {
      case MessageGroupEntityType.slack:
        return _slackGroup?.id;
    }
  }

  String? get name {
    switch (type) {
      case MessageGroupEntityType.slack:
        return _slackGroup?.name;
    }
  }

  String? get displayName {
    switch (type) {
      case MessageGroupEntityType.slack:
        return _slackGroup?.handle;
    }
  }

  List<String>? get users {
    switch (type) {
      case MessageGroupEntityType.slack:
        return _slackGroup?.users;
    }
  }

  DateTime? get createdAt {
    switch (type) {
      case MessageGroupEntityType.slack:
        return _slackGroup?.dateCreate == null ? null : DateTime.fromMillisecondsSinceEpoch(_slackGroup!.dateCreate! * 1000);
    }
  }

  DateTime? get deletedAt {
    switch (type) {
      case MessageGroupEntityType.slack:
        return _slackGroup?.dateDelete == null ? null : DateTime.fromMillisecondsSinceEpoch(_slackGroup!.dateDelete! * 1000);
    }
  }

  DateTime? get updatedAt {
    switch (type) {
      case MessageGroupEntityType.slack:
        return _slackGroup?.dateUpdate == null ? null : DateTime.fromMillisecondsSinceEpoch(_slackGroup!.dateUpdate! * 1000);
    }
  }
}
