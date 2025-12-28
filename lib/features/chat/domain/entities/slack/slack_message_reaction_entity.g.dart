// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slack_message_reaction_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SlackMessageReactionEntity _$SlackMessageReactionEntityFromJson(
  Map<String, dynamic> json,
) => _SlackMessageReactionEntity(
  name: json['name'] as String?,
  count: (json['count'] as num?)?.toInt(),
  users: (json['users'] as List<dynamic>?)?.map((e) => e as String).toList(),
);

Map<String, dynamic> _$SlackMessageReactionEntityToJson(
  _SlackMessageReactionEntity instance,
) => <String, dynamic>{
  'name': ?instance.name,
  'count': ?instance.count,
  'users': ?instance.users,
};
