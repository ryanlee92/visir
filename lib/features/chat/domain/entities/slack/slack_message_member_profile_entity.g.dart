// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slack_message_member_profile_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SlackMessageMemberProfileEntity _$SlackMessageMemberProfileEntityFromJson(
  Map<String, dynamic> json,
) => _SlackMessageMemberProfileEntity(
  avatarHash: json['avatar_hash'] as String?,
  displayName: json['display_name'] as String?,
  displayNameNormalized: json['display_name_normalized'] as String?,
  email: json['email'] as String?,
  fields: json['fields'] as Map<String, dynamic>?,
  firstName: json['first_name'] as String?,
  image_24: json['image_24'] as String?,
  image_32: json['image_32'] as String?,
  image_48: json['image_48'] as String?,
  image_72: json['image_72'] as String?,
  image_192: json['image_192'] as String?,
  image_512: json['image_512'] as String?,
  lastName: json['last_name'] as String?,
  phone: json['phone'] as String?,
  pronouns: json['pronouns'] as String?,
  realName: json['real_name'] as String?,
  realNameNormalized: json['real_name_normalized'] as String?,
  skype: json['skype'] as String?,
  startDate: json['start_date'] as String?,
  statusEmoji: json['status_emoji'] as String?,
  statusExpiration: (json['status_expiration'] as num?)?.toInt(),
  statsText: json['stats_text'] as String?,
  team: json['team'] as String?,
  title: json['title'] as String?,
);

Map<String, dynamic> _$SlackMessageMemberProfileEntityToJson(
  _SlackMessageMemberProfileEntity instance,
) => <String, dynamic>{
  'avatar_hash': ?instance.avatarHash,
  'display_name': ?instance.displayName,
  'display_name_normalized': ?instance.displayNameNormalized,
  'email': ?instance.email,
  'fields': ?instance.fields,
  'first_name': ?instance.firstName,
  'image_24': ?instance.image_24,
  'image_32': ?instance.image_32,
  'image_48': ?instance.image_48,
  'image_72': ?instance.image_72,
  'image_192': ?instance.image_192,
  'image_512': ?instance.image_512,
  'last_name': ?instance.lastName,
  'phone': ?instance.phone,
  'pronouns': ?instance.pronouns,
  'real_name': ?instance.realName,
  'real_name_normalized': ?instance.realNameNormalized,
  'skype': ?instance.skype,
  'start_date': ?instance.startDate,
  'status_emoji': ?instance.statusEmoji,
  'status_expiration': ?instance.statusExpiration,
  'stats_text': ?instance.statsText,
  'team': ?instance.team,
  'title': ?instance.title,
};
