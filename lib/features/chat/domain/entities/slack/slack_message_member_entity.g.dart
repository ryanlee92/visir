// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slack_message_member_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SlackMessageTeamMemberEntity _$SlackMessageTeamMemberEntityFromJson(
  Map<String, dynamic> json,
) => _SlackMessageTeamMemberEntity(
  alwaysActive: json['always_active'] as bool?,
  color: json['color'] as String?,
  deleted: json['deleted'] as bool?,
  has2fa: json['has2fa'] as bool?,
  id: json['id'] as String?,
  isAdmin: json['is_admin'] as bool?,
  isAppUser: json['is_app_user'] as bool?,
  isBot: json['is_bot'] as bool?,
  isInvitedUser: json['is_invited_user'] as bool?,
  isOwner: json['is_owner'] as bool?,
  isPrimaryOwner: json['is_primary_owner'] as bool?,
  isRestricted: json['is_restricted'] as bool?,
  isStranger: json['is_stranger'] as bool?,
  isUltraRestricted: json['is_ultra_restricted'] as bool?,
  locale: json['locale'] as String?,
  name: json['name'] as String?,
  profile: json['profile'] == null
      ? null
      : SlackMessageMemberProfileEntity.fromJson(
          json['profile'] as Map<String, dynamic>,
        ),
  twoFactorType: json['two_factor_type'] as String?,
  tz: json['tz'] as String?,
  tzLabel: json['tz_label'] as String?,
  tzOffset: (json['tz_offset'] as num?)?.toInt(),
  updated: (json['updated'] as num?)?.toInt(),
);

Map<String, dynamic> _$SlackMessageTeamMemberEntityToJson(
  _SlackMessageTeamMemberEntity instance,
) => <String, dynamic>{
  'always_active': ?instance.alwaysActive,
  'color': ?instance.color,
  'deleted': ?instance.deleted,
  'has2fa': ?instance.has2fa,
  'id': ?instance.id,
  'is_admin': ?instance.isAdmin,
  'is_app_user': ?instance.isAppUser,
  'is_bot': ?instance.isBot,
  'is_invited_user': ?instance.isInvitedUser,
  'is_owner': ?instance.isOwner,
  'is_primary_owner': ?instance.isPrimaryOwner,
  'is_restricted': ?instance.isRestricted,
  'is_stranger': ?instance.isStranger,
  'is_ultra_restricted': ?instance.isUltraRestricted,
  'locale': ?instance.locale,
  'name': ?instance.name,
  'profile': ?instance.profile?.toJson(),
  'two_factor_type': ?instance.twoFactorType,
  'tz': ?instance.tz,
  'tz_label': ?instance.tzLabel,
  'tz_offset': ?instance.tzOffset,
  'updated': ?instance.updated,
};
