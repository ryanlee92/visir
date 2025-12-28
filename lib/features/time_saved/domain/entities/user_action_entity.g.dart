// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_action_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserActionEntity _$UserActionEntityFromJson(Map<String, dynamic> json) =>
    _UserActionEntity(
      id: json['id'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      type: $enumDecode(_$UserActionTypeEnumMap, json['type']),
      oAuthType: $enumDecodeNullable(_$OAuthTypeEnumMap, json['o_auth_type']),
      identifier: json['identifier'] as String?,
    );

Map<String, dynamic> _$UserActionEntityToJson(_UserActionEntity instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'created_at': ?instance.createdAt?.toIso8601String(),
      'type': _$UserActionTypeEnumMap[instance.type]!,
      'o_auth_type': ?_$OAuthTypeEnumMap[instance.oAuthType],
      'identifier': ?instance.identifier,
    };

const _$UserActionTypeEnumMap = {
  UserActionType.task: 'task',
  UserActionType.calendar: 'calendar',
  UserActionType.message: 'message',
  UserActionType.mail: 'mail',
};

const _$OAuthTypeEnumMap = {
  OAuthType.google: 'google',
  OAuthType.apple: 'apple',
  OAuthType.microsoft: 'microsoft',
  OAuthType.slack: 'slack',
  OAuthType.discord: 'discord',
};
