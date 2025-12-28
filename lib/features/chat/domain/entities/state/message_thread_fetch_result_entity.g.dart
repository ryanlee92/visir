// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_thread_fetch_result_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MessageThreadFetchResultEntity _$MessageThreadFetchResultEntityFromJson(
  Map<String, dynamic> json,
) => _MessageThreadFetchResultEntity(
  messages: (json['messages'] as List<dynamic>)
      .map((e) => MessageEntity.fromJson(e as Map<String, dynamic>))
      .toList(),
  members: (json['members'] as List<dynamic>?)
      ?.map((e) => MessageMemberEntity.fromJson(e as Map<String, dynamic>))
      .toList(),
  groups: (json['groups'] as List<dynamic>?)
      ?.map((e) => MessageGroupEntity.fromJson(e as Map<String, dynamic>))
      .toList(),
  emojis: (json['emojis'] as List<dynamic>?)
      ?.map((e) => MessageEmojiEntity.fromJson(e as Map<String, dynamic>))
      .toList(),
  hasMore: json['has_more'] as bool,
  channel: json['channel'] == null
      ? null
      : MessageChannelEntity.fromJson(json['channel'] as Map<String, dynamic>),
  nextCursor: json['next_cursor'] as String?,
  hasRecent: json['has_recent'] as bool?,
  isRateLimited: json['is_rate_limited'] as bool?,
  nextPageTokens: (json['next_page_tokens'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String?),
  ),
  sequence: (json['sequence'] as num?)?.toInt(),
);

Map<String, dynamic> _$MessageThreadFetchResultEntityToJson(
  _MessageThreadFetchResultEntity instance,
) => <String, dynamic>{
  'messages': instance.messages.map((e) => e.toJson()).toList(),
  'members': ?instance.members?.map((e) => e.toJson()).toList(),
  'groups': ?instance.groups?.map((e) => e.toJson()).toList(),
  'emojis': ?instance.emojis?.map((e) => e.toJson()).toList(),
  'has_more': instance.hasMore,
  'channel': ?instance.channel?.toJson(),
  'next_cursor': ?instance.nextCursor,
  'has_recent': ?instance.hasRecent,
  'is_rate_limited': ?instance.isRateLimited,
  'next_page_tokens': ?instance.nextPageTokens,
  'sequence': ?instance.sequence,
};
