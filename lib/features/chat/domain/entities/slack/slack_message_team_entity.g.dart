// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slack_message_team_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SlackTeamEntity _$SlackTeamEntityFromJson(Map<String, dynamic> json) =>
    _SlackTeamEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      domain: json['domain'] as String,
      email_domain: json['email_domain'] as String,
      avatar_base_url: json['avatar_base_url'] as String?,
      isVerified: json['is_verified'] as bool?,
      publicUrl: json['public_url'] as String?,
      enterprise_id: json['enterprise_id'] as String?,
      enterprise_name: json['enterprise_name'] as String?,
      icon: json['icon'] == null
          ? null
          : SlackMessageTeamIconEntity.fromJson(
              json['icon'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$SlackTeamEntityToJson(_SlackTeamEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'domain': instance.domain,
      'email_domain': instance.email_domain,
      'avatar_base_url': ?instance.avatar_base_url,
      'is_verified': ?instance.isVerified,
      'public_url': ?instance.publicUrl,
      'enterprise_id': ?instance.enterprise_id,
      'enterprise_name': ?instance.enterprise_name,
      'icon': ?instance.icon?.toJson(),
    };
