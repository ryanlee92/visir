// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_draft_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatDraftEntity _$ChatDraftEntityFromJson(Map<String, dynamic> json) =>
    _ChatDraftEntity(
      id: json['id'] as String,
      teamId: json['team_id'] as String,
      channelId: json['channel_id'] as String,
      threadId: json['thread_id'] as String?,
      content: json['content'] as String,
      editingMessageId: json['editing_message_id'] as String?,
    );

Map<String, dynamic> _$ChatDraftEntityToJson(_ChatDraftEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'team_id': instance.teamId,
      'channel_id': instance.channelId,
      'thread_id': ?instance.threadId,
      'content': instance.content,
      'editing_message_id': ?instance.editingMessageId,
    };
