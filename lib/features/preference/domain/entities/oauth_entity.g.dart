// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'oauth_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OAuthEntity _$OAuthEntityFromJson(Map<String, dynamic> json) => _OAuthEntity(
  email: json['email'] as String,
  name: json['name'] as String?,
  imageUrl: json['image_url'] as String?,
  notificationUrl: json['notification_url'] as String?,
  serverCode: json['server_code'] as String?,
  accessToken: json['access_token'] as Map<String, dynamic>,
  refreshToken: json['refresh_token'] as String,
  type: $enumDecode(_$OAuthTypeEnumMap, json['type']),
  team: json['team'] == null
      ? null
      : MessageTeamEntity.fromJson(json['team'] as Map<String, dynamic>),
  needReAuth: json['need_re_auth'] as bool?,
);

Map<String, dynamic> _$OAuthEntityToJson(_OAuthEntity instance) =>
    <String, dynamic>{
      'email': instance.email,
      'name': ?instance.name,
      'image_url': ?instance.imageUrl,
      'notification_url': ?instance.notificationUrl,
      'server_code': ?instance.serverCode,
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
      'type': _$OAuthTypeEnumMap[instance.type]!,
      'team': ?instance.team?.toJson(),
      'need_re_auth': ?instance.needReAuth,
    };

const _$OAuthTypeEnumMap = {
  OAuthType.google: 'google',
  OAuthType.apple: 'apple',
  OAuthType.microsoft: 'microsoft',
  OAuthType.slack: 'slack',
  OAuthType.discord: 'discord',
};
