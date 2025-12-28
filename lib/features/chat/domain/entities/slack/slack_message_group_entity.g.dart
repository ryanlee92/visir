// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slack_message_group_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SlackMessageGroupEntity _$SlackMessageGroupEntityFromJson(
  Map<String, dynamic> json,
) => _SlackMessageGroupEntity(
  id: json['id'] as String?,
  teamId: json['team_id'] as String?,
  isUsergroup: json['is_usergroup'] as bool?,
  name: json['name'] as String?,
  description: json['description'] as String?,
  handle: json['handle'] as String?,
  isExternal: json['is_external'] as bool?,
  dateCreate: (json['date_create'] as num?)?.toInt(),
  dateUpdate: (json['date_update'] as num?)?.toInt(),
  dateDelete: (json['date_delete'] as num?)?.toInt(),
  autoType: json['auto_type'] as String?,
  createdBy: json['created_by'] as String?,
  updatedBy: json['updated_by'] as String?,
  deletedBy: json['deleted_by'] as String?,
  prefs: json['prefs'] as Map<String, dynamic>?,
  users: (json['users'] as List<dynamic>?)?.map((e) => e as String).toList(),
  userCount: (json['user_count'] as num?)?.toInt(),
);

Map<String, dynamic> _$SlackMessageGroupEntityToJson(
  _SlackMessageGroupEntity instance,
) => <String, dynamic>{
  'id': ?instance.id,
  'team_id': ?instance.teamId,
  'is_usergroup': ?instance.isUsergroup,
  'name': ?instance.name,
  'description': ?instance.description,
  'handle': ?instance.handle,
  'is_external': ?instance.isExternal,
  'date_create': ?instance.dateCreate,
  'date_update': ?instance.dateUpdate,
  'date_delete': ?instance.dateDelete,
  'auto_type': ?instance.autoType,
  'created_by': ?instance.createdBy,
  'updated_by': ?instance.updatedBy,
  'deleted_by': ?instance.deletedBy,
  'prefs': ?instance.prefs,
  'users': ?instance.users,
  'user_count': ?instance.userCount,
};
