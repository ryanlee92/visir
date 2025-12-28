import 'package:Visir/features/chat/domain/entities/slack/slack_message_team_icon_entity.dart';

enum MessageTeamIconEntityType {
  slack,
}

class MessageTeamIconEntity {
  //for slack
  // ignore: unused_field
  final SlackMessageTeamIconEntity? _slackTeamIcon;

  //common
  final MessageTeamIconEntityType type;

  MessageTeamIconEntity.fromSlack({SlackMessageTeamIconEntity? teamIcon})
      : _slackTeamIcon = teamIcon,
        type = MessageTeamIconEntityType.slack;

  factory MessageTeamIconEntity.fromJson(Map<String, dynamic> json) {
    MessageTeamIconEntityType teamIconType = MessageTeamIconEntityType.values.firstWhere(
      (e) => e.name == json['teamIconType'],
      orElse: () => MessageTeamIconEntityType.slack,
    );

    if (teamIconType == MessageTeamIconEntityType.slack) {
      return MessageTeamIconEntity.fromSlack(
        teamIcon: SlackMessageTeamIconEntity.fromJson(json['_slackTeamIcon']),
      );
    }

    return MessageTeamIconEntity.fromSlack(
      teamIcon: SlackMessageTeamIconEntity.fromJson(json['_slackTeamIcon']),
    );
  }
}
