// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_pref_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LocalPrefEntity _$LocalPrefEntityFromJson(
  Map<String, dynamic> json,
) => _LocalPrefEntity(
  calendarOAuths: (json['calendar_o_auths'] as List<dynamic>?)
      ?.map((e) => OAuthEntity.fromJson(e as Map<String, dynamic>))
      .toList(),
  mailOAuths: (json['mail_o_auths'] as List<dynamic>?)
      ?.map((e) => OAuthEntity.fromJson(e as Map<String, dynamic>))
      .toList(),
  messengerOAuths: (json['messenger_o_auths'] as List<dynamic>?)
      ?.map((e) => OAuthEntity.fromJson(e as Map<String, dynamic>))
      .toList(),
  notificationPayload: (json['notification_payload'] as Map<String, dynamic>?)
      ?.map((k, e) => MapEntry(k, e as String)),
  showCalendarNotifications:
      (json['show_calendar_notifications'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as bool),
      ),
  mailNotificationFilterTypes:
      (json['mail_notification_filter_types'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, $enumDecode(_$MailNotificationFilterTypeEnumMap, e)),
      ),
  mailNotificationFilterLabelIds:
      (json['mail_notification_filter_label_ids'] as Map<String, dynamic>?)
          ?.map(
            (k, e) => MapEntry(
              k,
              (e as List<dynamic>).map((e) => e as String).toList(),
            ),
          ),
  messageDmNotificationFilterTypes:
      (json['message_dm_notification_filter_types'] as Map<String, dynamic>?)
          ?.map(
            (k, e) => MapEntry(
              k,
              $enumDecode(_$MessagNotificationFilterTypeEnumMap, e),
            ),
          ),
  messageChannelNotificationFilterTypes:
      (json['message_channel_notification_filter_types']
              as Map<String, dynamic>?)
          ?.map(
            (k, e) => MapEntry(
              k,
              $enumDecode(_$MessagNotificationFilterTypeEnumMap, e),
            ),
          ),
  googleConnectionSyncToken:
      (json['google_connection_sync_token'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String?),
      ),
  quickLinks: (json['quick_links'] as List<dynamic>?)
      ?.map((e) => Map<String, String?>.from(e as Map))
      .toList(),
  aiApiKeys: (json['ai_api_keys'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  selectedAgentModel: json['selected_agent_model'] as Map<String, dynamic>?,
  calendarType: (json['calendar_type'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  calendarIntervalScale:
      (json['calendar_interval_scale'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
  lastUsedCalendarId: (json['last_used_calendar_id'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  lastUsedProjectId: (json['last_used_project_id'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  chatChannelStateList:
      (json['chat_channel_state_list'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
  chatLastChannel: (json['chat_last_channel'] as Map<String, dynamic>?)?.map(
    (k, e) =>
        MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
  ),
  inboxSuggestionSort: (json['inbox_suggestion_sort'] as Map<String, dynamic>?)
      ?.map((k, e) => MapEntry(k, e as String)),
  inboxSuggestionFilter:
      (json['inbox_suggestion_filter'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
);

Map<String, dynamic> _$LocalPrefEntityToJson(
  _LocalPrefEntity instance,
) => <String, dynamic>{
  'calendar_o_auths': ?instance.calendarOAuths?.map((e) => e.toJson()).toList(),
  'mail_o_auths': ?instance.mailOAuths?.map((e) => e.toJson()).toList(),
  'messenger_o_auths': ?instance.messengerOAuths
      ?.map((e) => e.toJson())
      .toList(),
  'notification_payload': ?instance.notificationPayload,
  'show_calendar_notifications': ?instance.showCalendarNotifications,
  'mail_notification_filter_types': ?instance.mailNotificationFilterTypes?.map(
    (k, e) => MapEntry(k, _$MailNotificationFilterTypeEnumMap[e]!),
  ),
  'mail_notification_filter_label_ids':
      ?instance.mailNotificationFilterLabelIds,
  'message_dm_notification_filter_types': ?instance
      .messageDmNotificationFilterTypes
      ?.map((k, e) => MapEntry(k, _$MessagNotificationFilterTypeEnumMap[e]!)),
  'message_channel_notification_filter_types': ?instance
      .messageChannelNotificationFilterTypes
      ?.map((k, e) => MapEntry(k, _$MessagNotificationFilterTypeEnumMap[e]!)),
  'google_connection_sync_token': ?instance.googleConnectionSyncToken,
  'quick_links': ?instance.quickLinks,
  'ai_api_keys': ?instance.aiApiKeys,
  'selected_agent_model': ?instance.selectedAgentModel,
  'calendar_type': ?instance.calendarType,
  'calendar_interval_scale': ?instance.calendarIntervalScale,
  'last_used_calendar_id': ?instance.lastUsedCalendarId,
  'last_used_project_id': ?instance.lastUsedProjectId,
  'chat_channel_state_list': ?instance.chatChannelStateList,
  'chat_last_channel': ?instance.chatLastChannel,
  'inbox_suggestion_sort': ?instance.inboxSuggestionSort,
  'inbox_suggestion_filter': ?instance.inboxSuggestionFilter,
};

const _$MailNotificationFilterTypeEnumMap = {
  MailNotificationFilterType.none: 'none',
  MailNotificationFilterType.withSpecificLables: 'withSpecificLables',
  MailNotificationFilterType.all: 'all',
};

const _$MessagNotificationFilterTypeEnumMap = {
  MessagNotificationFilterType.none: 'none',
  MessagNotificationFilterType.mentions: 'mentions',
  MessagNotificationFilterType.all: 'all',
};
