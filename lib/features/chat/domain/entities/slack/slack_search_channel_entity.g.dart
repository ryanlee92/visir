// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slack_search_channel_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SlackSearchChannelEntity _$SlackSearchChannelEntityFromJson(
  Map<String, dynamic> json,
) => _SlackSearchChannelEntity(
  id: json['id'] as String?,
  isExtShared: json['is_ext_shared'] as bool?,
  isMpim: json['is_mpim'] as bool?,
  isOrgShared: json['is_org_shared'] as bool?,
  isPendingExtShared: json['is_pending_ext_shared'] as bool?,
  isPrivate: json['is_private'] as bool?,
  isShared: json['is_shared'] as bool?,
  name: json['name'] as String?,
);

Map<String, dynamic> _$SlackSearchChannelEntityToJson(
  _SlackSearchChannelEntity instance,
) => <String, dynamic>{
  'id': ?instance.id,
  'is_ext_shared': ?instance.isExtShared,
  'is_mpim': ?instance.isMpim,
  'is_org_shared': ?instance.isOrgShared,
  'is_pending_ext_shared': ?instance.isPendingExtShared,
  'is_private': ?instance.isPrivate,
  'is_shared': ?instance.isShared,
  'name': ?instance.name,
};
