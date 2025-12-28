// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slack_channel_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SlackMessageChannelEntity _$SlackMessageChannelEntityFromJson(
  Map<String, dynamic> json,
) => _SlackMessageChannelEntity(
  teamId: json['team_id'] as String?,
  id: json['id'] as String?,
  name: json['name'] as String?,
  isChannel: json['is_channel'] as bool?,
  created: (json['created'] as num?)?.toInt(),
  creator: json['creator'] as String?,
  isArchived: json['is_archived'] as bool?,
  isGeneral: json['is_general'] as bool?,
  nameNormalized: json['name_normalized'] as String?,
  isShared: json['is_shared'] as bool?,
  isOrgShared: json['is_org_shared'] as bool?,
  isMember: json['is_member'] as bool?,
  isPrivate: json['is_private'] as bool?,
  isMpim: json['is_mpim'] as bool?,
  lastRead: json['last_read'] as String?,
  lastUpdated: json['last_updated'] == null
      ? null
      : DateTime.parse(json['last_updated'] as String),
  unreadCount: (json['unread_count'] as num?)?.toInt(),
  unreadCountDisplay: (json['unread_count_display'] as num?)?.toInt(),
  members: (json['members'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  topic: json['topic'] as Map<String, dynamic>?,
  purpose: json['purpose'] as Map<String, dynamic>?,
  previousNames: (json['previous_names'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  isGroup: json['is_group'] as bool?,
  isIm: json['is_im'] as bool?,
  user: json['user'] as String?,
  isUserDeleted: json['is_user_deleted'] as bool?,
  updated: (json['updated'] as num?)?.toInt(),
  unlinked: (json['unlinked'] as num?)?.toInt(),
  isPendingExtShared: json['is_pending_ext_shared'] as bool?,
  contextTeamId: json['context_team_id'] as String?,
  priority: (json['priority'] as num?)?.toDouble(),
  isOpen: json['is_open'] as bool?,
);

Map<String, dynamic> _$SlackMessageChannelEntityToJson(
  _SlackMessageChannelEntity instance,
) => <String, dynamic>{
  'team_id': ?instance.teamId,
  'id': ?instance.id,
  'name': ?instance.name,
  'is_channel': ?instance.isChannel,
  'created': ?instance.created,
  'creator': ?instance.creator,
  'is_archived': ?instance.isArchived,
  'is_general': ?instance.isGeneral,
  'name_normalized': ?instance.nameNormalized,
  'is_shared': ?instance.isShared,
  'is_org_shared': ?instance.isOrgShared,
  'is_member': ?instance.isMember,
  'is_private': ?instance.isPrivate,
  'is_mpim': ?instance.isMpim,
  'last_read': ?instance.lastRead,
  'last_updated': ?instance.lastUpdated?.toIso8601String(),
  'unread_count': ?instance.unreadCount,
  'unread_count_display': ?instance.unreadCountDisplay,
  'members': ?instance.members,
  'topic': ?instance.topic,
  'purpose': ?instance.purpose,
  'previous_names': ?instance.previousNames,
  'is_group': ?instance.isGroup,
  'is_im': ?instance.isIm,
  'user': ?instance.user,
  'is_user_deleted': ?instance.isUserDeleted,
  'updated': ?instance.updated,
  'unlinked': ?instance.unlinked,
  'is_pending_ext_shared': ?instance.isPendingExtShared,
  'context_team_id': ?instance.contextTeamId,
  'priority': ?instance.priority,
  'is_open': ?instance.isOpen,
};
