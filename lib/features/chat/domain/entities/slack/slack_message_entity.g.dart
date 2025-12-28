// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slack_message_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SlackMessageEntity _$SlackMessageEntityFromJson(
  Map<String, dynamic> json,
) => _SlackMessageEntity(
  type: json['type'] as String?,
  user: json['user'] as String?,
  text: json['text'] as String?,
  team: json['team'] as String?,
  ts: json['ts'] as String?,
  channel: json['channel'] as String?,
  subtype: $enumDecodeNullable(
    _$SlackMessageEntitySubtypeEnumMap,
    json['subtype'],
  ),
  deletedTs: json['deleted_ts'] as String?,
  eventTs: json['event_ts'] as String?,
  threadTs: json['thread_ts'] as String?,
  latestReply: json['latest_reply'] as String?,
  replyCount: (json['reply_count'] as num?)?.toInt(),
  replyUsersCount: (json['reply_users_count'] as num?)?.toInt(),
  replyUsers: (json['reply_users'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  isStarred: json['is_starred'] as bool?,
  hidden: json['hidden'] as bool?,
  isLocked: json['is_locked'] as bool?,
  subscribed: json['subscribed'] as bool?,
  pinnedTo: (json['pinned_to'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  attachments: (json['attachments'] as List<dynamic>?)
      ?.map(
        (e) => SlackMessageAttachmentEntity.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  edited: json['edited'] as Map<String, dynamic>?,
  reactions: (json['reactions'] as List<dynamic>?)
      ?.map(
        (e) => SlackMessageReactionEntity.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  clientMsgId: json['client_msg_id'] as String?,
  parentUserId: json['parent_user_id'] as String?,
  files: (json['files'] as List<dynamic>?)
      ?.map((e) => SlackMessageFileEntity.fromJson(e as Map<String, dynamic>))
      .toList(),
  blocks: (json['blocks'] as List<dynamic>?)
      ?.map((e) => SlackMessageBlockEntity.fromJson(e as Map<String, dynamic>))
      .toList(),
  botId: json['bot_id'] as String?,
  isLocalTempMessage: json['is_local_temp_message'] as bool?,
  link: json['link'] as String?,
);

Map<String, dynamic> _$SlackMessageEntityToJson(_SlackMessageEntity instance) =>
    <String, dynamic>{
      'type': ?instance.type,
      'user': ?instance.user,
      'text': ?instance.text,
      'team': ?instance.team,
      'ts': ?instance.ts,
      'channel': ?instance.channel,
      'subtype': ?_$SlackMessageEntitySubtypeEnumMap[instance.subtype],
      'deleted_ts': ?instance.deletedTs,
      'event_ts': ?instance.eventTs,
      'thread_ts': ?instance.threadTs,
      'latest_reply': ?instance.latestReply,
      'reply_count': ?instance.replyCount,
      'reply_users_count': ?instance.replyUsersCount,
      'reply_users': ?instance.replyUsers,
      'is_starred': ?instance.isStarred,
      'hidden': ?instance.hidden,
      'is_locked': ?instance.isLocked,
      'subscribed': ?instance.subscribed,
      'pinned_to': ?instance.pinnedTo,
      'attachments': ?instance.attachments?.map((e) => e.toJson()).toList(),
      'edited': ?instance.edited,
      'reactions': ?instance.reactions?.map((e) => e.toJson()).toList(),
      'client_msg_id': ?instance.clientMsgId,
      'parent_user_id': ?instance.parentUserId,
      'files': ?instance.files?.map((e) => e.toJson()).toList(),
      'blocks': ?instance.blocks?.map((e) => e.toJson()).toList(),
      'bot_id': ?instance.botId,
      'is_local_temp_message': ?instance.isLocalTempMessage,
      'link': ?instance.link,
    };

const _$SlackMessageEntitySubtypeEnumMap = {
  SlackMessageEntitySubtype.botMessage: 'bot_message',
  SlackMessageEntitySubtype.meMessage: 'me_message',
  SlackMessageEntitySubtype.messageChanged: 'message_changed',
  SlackMessageEntitySubtype.messageDeleted: 'message_deleted',
  SlackMessageEntitySubtype.messageReplied: 'message_replied',
  SlackMessageEntitySubtype.threadBroadcast: 'thread_broadcast',
  SlackMessageEntitySubtype.channelJoin: 'channel_join',
  SlackMessageEntitySubtype.channelLeave: 'channel_leave',
  SlackMessageEntitySubtype.channelTopic: 'channel_topic',
  SlackMessageEntitySubtype.channelPurpose: 'channel_purpose',
  SlackMessageEntitySubtype.channelName: 'channel_name',
  SlackMessageEntitySubtype.channelArchive: 'channel_archive',
  SlackMessageEntitySubtype.channelUnarchive: 'channel_unarchive',
  SlackMessageEntitySubtype.groupJoin: 'group_join',
  SlackMessageEntitySubtype.groupLeave: 'group_leave',
  SlackMessageEntitySubtype.groupTopic: 'group_topic',
  SlackMessageEntitySubtype.groupPurpose: 'group_purpose',
  SlackMessageEntitySubtype.groupName: 'group_name',
  SlackMessageEntitySubtype.groupArchive: 'group_archive',
  SlackMessageEntitySubtype.groupUnarchive: 'group_unarchive',
  SlackMessageEntitySubtype.fileShare: 'file_share',
  SlackMessageEntitySubtype.fileComment: 'file_comment',
  SlackMessageEntitySubtype.fileMention: 'file_mention',
  SlackMessageEntitySubtype.pinnedItem: 'pinned_item',
  SlackMessageEntitySubtype.unpinnedItem: 'unpinned_item',
  SlackMessageEntitySubtype.ekmAccessDenied: 'ekm_access_denied',
  SlackMessageEntitySubtype.channelPostingPermissions:
      'channel_posting_permissions',
  SlackMessageEntitySubtype.reminderAdd: 'reminder_add',
  SlackMessageEntitySubtype.botRemove: 'bot_remove',
  SlackMessageEntitySubtype.slackbotResponse: 'slackbot_response',
  SlackMessageEntitySubtype.botAdd: 'bot_add',
  SlackMessageEntitySubtype.tombstone: 'tombstone',
  SlackMessageEntitySubtype.joinerNotificationForInviter:
      'joiner_notification_for_inviter',
  SlackMessageEntitySubtype.appConversationJoin: 'app_conversation_join',
  SlackMessageEntitySubtype.channelConvertToPrivate:
      'channel_convert_to_private',
  SlackMessageEntitySubtype.huddleThread: 'huddle_thread',
  SlackMessageEntitySubtype.joinerNotification: 'joiner_notification',
};
