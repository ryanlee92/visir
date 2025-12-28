import 'package:Visir/features/chat/domain/entities/message_channel_entity.dart';
import 'package:Visir/features/chat/domain/entities/slack/slack_message_team_entity.dart';

enum MessageTeamEntityType { slack }

extension MessageTeamEntityTypeX on MessageTeamEntityType {
  MessageChannelEntityType get channelType {
    switch (this) {
      case MessageTeamEntityType.slack:
        return MessageChannelEntityType.slack;
    }
  }
}

class MessageTeamEntity {
  final SlackMessageTeamEntity? _slackTeam;
  final MessageTeamEntityType type;

  MessageTeamEntity.fromSlack({required SlackMessageTeamEntity team}) : _slackTeam = team, type = MessageTeamEntityType.slack;

  factory MessageTeamEntity.fromJson(Map<String, dynamic> json) {
    MessageTeamEntityType type = MessageTeamEntityType.values.firstWhere((e) => e.name == json['type'], orElse: () => MessageTeamEntityType.slack);

    if (type == MessageTeamEntityType.slack) {
      return MessageTeamEntity.fromSlack(team: SlackMessageTeamEntity.fromJson(json['_slackTeam']));
    }

    return MessageTeamEntity.fromSlack(team: SlackMessageTeamEntity.fromJson(json['_slackTeam']));
  }

  Map<String, dynamic> toJson() {
    return {"type": type.name, "_slackTeam": _slackTeam?.toJson()};
  }

  String? get id {
    switch (type) {
      case MessageTeamEntityType.slack:
        return _slackTeam?.id;
    }
  }

  String? get name {
    switch (type) {
      case MessageTeamEntityType.slack:
        return _slackTeam?.name;
    }
  }

  String? get smallIconUrl {
    switch (type) {
      case MessageTeamEntityType.slack:
        return _slackTeam?.icon?.image_44 ?? '';
    }
  }

  String? get largeIconUrl {
    switch (type) {
      case MessageTeamEntityType.slack:
        return _slackTeam?.icon?.image_132 ?? '';
    }
  }
}
