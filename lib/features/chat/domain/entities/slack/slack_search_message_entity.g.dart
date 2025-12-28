// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slack_search_message_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SlackSearchMessageEntity _$SlackSearchMessageEntityFromJson(
  Map<String, dynamic> json,
) => _SlackSearchMessageEntity(
  channel: json['channel'] == null
      ? null
      : SlackSearchChannelEntity.fromJson(
          json['channel'] as Map<String, dynamic>,
        ),
  iid: json['iid'] as String?,
  permalink: json['permalink'] as String?,
  team: json['team'] as String?,
  text: json['text'] as String?,
  ts: json['ts'] as String?,
  type: json['type'] as String?,
  user: json['user'] as String?,
  username: json['username'] as String?,
);

Map<String, dynamic> _$SlackSearchMessageEntityToJson(
  _SlackSearchMessageEntity instance,
) => <String, dynamic>{
  'channel': ?instance.channel?.toJson(),
  'iid': ?instance.iid,
  'permalink': ?instance.permalink,
  'team': ?instance.team,
  'text': ?instance.text,
  'ts': ?instance.ts,
  'type': ?instance.type,
  'user': ?instance.user,
  'username': ?instance.username,
};
