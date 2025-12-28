// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mail_fetch_result_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MailFetchResultEntity _$MailFetchResultEntityFromJson(
  Map<String, dynamic> json,
) => _MailFetchResultEntity(
  messages: (json['messages'] as List<dynamic>)
      .map((e) => MailEntity.fromJson(e as Map<String, dynamic>))
      .toList(),
  hasMore: json['has_more'] as bool,
  nextPageToken: json['next_page_token'] as String?,
  hasRecent: json['has_recent'] as bool?,
  isRateLimited: json['is_rate_limited'] as bool?,
);

Map<String, dynamic> _$MailFetchResultEntityToJson(
  _MailFetchResultEntity instance,
) => <String, dynamic>{
  'messages': instance.messages.map((e) => e.toJson()).toList(),
  'has_more': instance.hasMore,
  'next_page_token': ?instance.nextPageToken,
  'has_recent': ?instance.hasRecent,
  'is_rate_limited': ?instance.isRateLimited,
};
