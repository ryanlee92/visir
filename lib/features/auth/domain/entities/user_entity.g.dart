// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserEntity _$UserEntityFromJson(Map<String, dynamic> json) => _UserEntity(
  id: json['id'] as String,
  name: json['name'] as String?,
  email: json['email'] as String?,
  avatarUrl: json['avatar_url'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  subscriptionEndAt: json['subscription_end_at'] == null
      ? null
      : DateTime.parse(json['subscription_end_at'] as String),
  badge: (json['badge'] as num?)?.toInt(),
  calendarColors: (json['calendar_colors'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  mailColors: (json['mail_colors'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  mailSignatures: (json['mail_signatures'] as List<dynamic>?)
      ?.map((e) => MailSignatureEntity.fromJson(e as Map<String, dynamic>))
      .toList(),
  defaultSignatures: (json['default_signatures'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, (e as num).toInt()),
  ),
  mailInboxFilterTypes:
      (json['mail_inbox_filter_types'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, $enumDecode(_$MailInboxFilterTypeEnumMap, e)),
      ),
  mailInboxFilterLabelIds:
      (json['mail_inbox_filter_label_ids'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
      ),
  messageDmInboxFilterTypes:
      (json['message_dm_inbox_filter_types'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, $enumDecode(_$ChatInboxFilterTypeEnumMap, e)),
      ),
  messageChannelInboxFilterTypes:
      (json['message_channel_inbox_filter_types'] as Map<String, dynamic>?)
          ?.map(
            (k, e) => MapEntry(k, $enumDecode(_$ChatInboxFilterTypeEnumMap, e)),
          ),
  taskColorHex: json['task_color_hex'] as String?,
  taskDefaultDurationInMinutes:
      (json['task_default_duration_in_minutes'] as num?)?.toInt(),
  inboxCalendarDoubleClickActionType: $enumDecodeNullable(
    _$InboxCalendarActionTypeEnumMap,
    json['inbox_calendar_double_click_action_type'],
  ),
  inboxCalendarDragActionType: $enumDecodeNullable(
    _$InboxCalendarActionTypeEnumMap,
    json['inbox_calendar_drag_action_type'],
  ),
  inboxFloatingButtonActionType: $enumDecodeNullable(
    _$InboxCalendarActionTypeEnumMap,
    json['inbox_floating_button_action_type'],
  ),
  defaultTaskReminderType: $enumDecodeNullable(
    _$TaskReminderOptionTypeEnumMap,
    json['default_task_reminder_type'],
  ),
  defaultAllDayTaskReminderType: $enumDecodeNullable(
    _$TaskReminderOptionTypeEnumMap,
    json['default_all_day_task_reminder_type'],
  ),
  completedTaskOptionType: $enumDecodeNullable(
    _$CompletedTaskOptionTypeEnumMap,
    json['completed_task_option_type'],
  ),
  showUnreadChannelsOnly: json['show_unread_channels_only'] as bool?,
  showUnreadDmsOnly: json['show_unread_dms_only'] as bool?,
  sortChannelType: $enumDecodeNullable(
    _$SortChannelTypeEnumMap,
    json['sort_channel_type'],
  ),
  excludedChannelIds: (json['excluded_channel_ids'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  mailSwipeRightActionType: $enumDecodeNullable(
    _$MailPrefSwipeActionTypeEnumMap,
    json['mail_swipe_right_action_type'],
  ),
  mailSwipeLeftActionType: $enumDecodeNullable(
    _$MailPrefSwipeActionTypeEnumMap,
    json['mail_swipe_left_action_type'],
  ),
  mailContentThemeType: $enumDecodeNullable(
    _$MailContentThemeTypeEnumMap,
    json['mail_content_theme_type'],
  ),
  firstDayOfWeek: (json['first_day_of_week'] as num?)?.toInt(),
  weekViewStartWeekday: (json['week_view_start_weekday'] as num?)?.toInt(),
  defaultDurationInMinutes: (json['default_duration_in_minutes'] as num?)
      ?.toInt(),
  defaultCalendarId: json['default_calendar_id'] as String?,
  lastGmailHistoryIds: (json['last_gmail_history_ids'] as Map<String, dynamic>?)
      ?.map((k, e) => MapEntry(k, e as String)),
  updateChannel: $enumDecodeNullable(
    _$UpdateChannelEnumMap,
    json['update_channel'],
  ),
  taskCompletionSound: json['task_completion_sound'] as bool?,
  mobileAppOpened: json['mobile_app_opened'] as bool?,
  desktopAppOpened: json['desktop_app_opened'] as bool?,
  quickLinks: (json['quick_links'] as List<dynamic>?)
      ?.map((e) => Map<String, String?>.from(e as Map))
      .toList(),
  subscription: json['subscription'] == null
      ? null
      : UserSubscriptionEntity.fromJson(
          json['subscription'] as Map<String, dynamic>,
        ),
  lemonSqueezyCustomerId: (json['lemon_squeezy_customer_id'] as num?)?.toInt(),
  isAdmin: json['is_admin'] as bool?,
  includeConferenceLinkOnHomeTab:
      json['include_conference_link_on_home_tab'] as bool?,
  includeConferenceLinkOnCalendarTab:
      json['include_conference_link_on_calendar_tab'] as bool?,
  isFreeUser: json['is_free_user'] as bool?,
  userTutorialDoneList: (json['user_tutorial_done_list'] as List<dynamic>?)
      ?.map((e) => $enumDecode(_$UserTutorialTypeEnumMap, e))
      .toList(),
  aiCredits: (json['ai_credits'] as num?)?.toDouble(),
  aiCreditsUpdatedAt: json['ai_credits_updated_at'] == null
      ? null
      : DateTime.parse(json['ai_credits_updated_at'] as String),
);

Map<String, dynamic> _$UserEntityToJson(
  _UserEntity instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': ?instance.name,
  'email': ?instance.email,
  'avatar_url': ?instance.avatarUrl,
  'created_at': ?instance.createdAt?.toIso8601String(),
  'updated_at': ?instance.updatedAt?.toIso8601String(),
  'subscription_end_at': ?instance.subscriptionEndAt?.toIso8601String(),
  'badge': ?instance.badge,
  'calendar_colors': ?instance.calendarColors,
  'mail_colors': ?instance.mailColors,
  'mail_signatures': ?instance.mailSignatures?.map((e) => e.toJson()).toList(),
  'default_signatures': ?instance.defaultSignatures,
  'mail_inbox_filter_types': ?instance.mailInboxFilterTypes?.map(
    (k, e) => MapEntry(k, _$MailInboxFilterTypeEnumMap[e]!),
  ),
  'mail_inbox_filter_label_ids': ?instance.mailInboxFilterLabelIds,
  'message_dm_inbox_filter_types': ?instance.messageDmInboxFilterTypes?.map(
    (k, e) => MapEntry(k, _$ChatInboxFilterTypeEnumMap[e]!),
  ),
  'message_channel_inbox_filter_types': ?instance.messageChannelInboxFilterTypes
      ?.map((k, e) => MapEntry(k, _$ChatInboxFilterTypeEnumMap[e]!)),
  'task_color_hex': ?instance.taskColorHex,
  'task_default_duration_in_minutes': ?instance.taskDefaultDurationInMinutes,
  'inbox_calendar_double_click_action_type':
      ?_$InboxCalendarActionTypeEnumMap[instance
          .inboxCalendarDoubleClickActionType],
  'inbox_calendar_drag_action_type':
      ?_$InboxCalendarActionTypeEnumMap[instance.inboxCalendarDragActionType],
  'inbox_floating_button_action_type':
      ?_$InboxCalendarActionTypeEnumMap[instance.inboxFloatingButtonActionType],
  'default_task_reminder_type':
      ?_$TaskReminderOptionTypeEnumMap[instance.defaultTaskReminderType],
  'default_all_day_task_reminder_type':
      ?_$TaskReminderOptionTypeEnumMap[instance.defaultAllDayTaskReminderType],
  'completed_task_option_type':
      ?_$CompletedTaskOptionTypeEnumMap[instance.completedTaskOptionType],
  'show_unread_channels_only': ?instance.showUnreadChannelsOnly,
  'show_unread_dms_only': ?instance.showUnreadDmsOnly,
  'sort_channel_type': ?_$SortChannelTypeEnumMap[instance.sortChannelType],
  'excluded_channel_ids': ?instance.excludedChannelIds,
  'mail_swipe_right_action_type':
      ?_$MailPrefSwipeActionTypeEnumMap[instance.mailSwipeRightActionType],
  'mail_swipe_left_action_type':
      ?_$MailPrefSwipeActionTypeEnumMap[instance.mailSwipeLeftActionType],
  'mail_content_theme_type':
      ?_$MailContentThemeTypeEnumMap[instance.mailContentThemeType],
  'first_day_of_week': ?instance.firstDayOfWeek,
  'week_view_start_weekday': ?instance.weekViewStartWeekday,
  'default_duration_in_minutes': ?instance.defaultDurationInMinutes,
  'default_calendar_id': ?instance.defaultCalendarId,
  'last_gmail_history_ids': ?instance.lastGmailHistoryIds,
  'update_channel': ?_$UpdateChannelEnumMap[instance.updateChannel],
  'task_completion_sound': ?instance.taskCompletionSound,
  'mobile_app_opened': ?instance.mobileAppOpened,
  'desktop_app_opened': ?instance.desktopAppOpened,
  'quick_links': ?instance.quickLinks,
  'subscription': ?instance.subscription?.toJson(),
  'lemon_squeezy_customer_id': ?instance.lemonSqueezyCustomerId,
  'is_admin': ?instance.isAdmin,
  'include_conference_link_on_home_tab':
      ?instance.includeConferenceLinkOnHomeTab,
  'include_conference_link_on_calendar_tab':
      ?instance.includeConferenceLinkOnCalendarTab,
  'is_free_user': ?instance.isFreeUser,
  'user_tutorial_done_list': ?instance.userTutorialDoneList
      ?.map((e) => _$UserTutorialTypeEnumMap[e]!)
      .toList(),
  'ai_credits': ?instance.aiCredits,
  'ai_credits_updated_at': ?instance.aiCreditsUpdatedAt?.toIso8601String(),
};

const _$MailInboxFilterTypeEnumMap = {
  MailInboxFilterType.none: 'none',
  MailInboxFilterType.withSpecificLables: 'withSpecificLables',
  MailInboxFilterType.all: 'all',
};

const _$ChatInboxFilterTypeEnumMap = {
  ChatInboxFilterType.none: 'none',
  ChatInboxFilterType.mentions: 'mentions',
  ChatInboxFilterType.all: 'all',
};

const _$InboxCalendarActionTypeEnumMap = {
  InboxCalendarActionType.calendar: 'calendar',
  InboxCalendarActionType.task: 'task',
  InboxCalendarActionType.lastCreated: 'lastCreated',
};

const _$TaskReminderOptionTypeEnumMap = {
  TaskReminderOptionType.custom: 'custom',
  TaskReminderOptionType.none: 'none',
  TaskReminderOptionType.atTheStart: 'atTheStart',
  TaskReminderOptionType.fiveMinutesBefore: 'fiveMinutesBefore',
  TaskReminderOptionType.tenMinutesBefore: 'tenMinutesBefore',
  TaskReminderOptionType.thirtyMinutesBefore: 'thirtyMinutesBefore',
  TaskReminderOptionType.hourBefore: 'hourBefore',
  TaskReminderOptionType.fifteenHoursBefore: 'fifteenHoursBefore',
  TaskReminderOptionType.nineHoursAfter: 'nineHoursAfter',
  TaskReminderOptionType.dayBefore: 'dayBefore',
};

const _$CompletedTaskOptionTypeEnumMap = {
  CompletedTaskOptionType.show: 'show',
  CompletedTaskOptionType.hide: 'hide',
  CompletedTaskOptionType.delete: 'delete',
};

const _$SortChannelTypeEnumMap = {
  SortChannelType.alphabetically: 'alphabetically',
  SortChannelType.mostRecent: 'mostRecent',
};

const _$MailPrefSwipeActionTypeEnumMap = {
  MailPrefSwipeActionType.none: 'none',
  MailPrefSwipeActionType.readUnread: 'readUnread',
  MailPrefSwipeActionType.pinUnpin: 'pinUnpin',
  MailPrefSwipeActionType.createTask: 'createTask',
  MailPrefSwipeActionType.archive: 'archive',
  MailPrefSwipeActionType.delete: 'delete',
  MailPrefSwipeActionType.reportSpam: 'reportSpam',
};

const _$MailContentThemeTypeEnumMap = {
  MailContentThemeType.followTaskeyTheme: 'followTaskeyTheme',
  MailContentThemeType.light: 'light',
  MailContentThemeType.dark: 'dark',
};

const _$UpdateChannelEnumMap = {
  UpdateChannel.stable: 'stable',
  UpdateChannel.beta: 'beta',
};

const _$UserTutorialTypeEnumMap = {
  UserTutorialType.desktopInboxDrag: 'desktopInboxDrag',
  UserTutorialType.mobileInboxDrag: 'mobileInboxDrag',
  UserTutorialType.desktopGcalPermission: 'desktopGcalPermission',
  UserTutorialType.mobileGcalPermission: 'mobileGcalPermission',
  UserTutorialType.desktopGmailPermission: 'desktopGmailPermission',
  UserTutorialType.mobileGmailPermission: 'mobileGmailPermission',
  UserTutorialType.desktopInboxFilter: 'desktopInboxFilter',
  UserTutorialType.mobileInboxFilter: 'mobileInboxFilter',
  UserTutorialType.timeSaved: 'timeSaved',
  UserTutorialType.timeSavedShare: 'timeSavedShare',
  UserTutorialType.earlyAccessEnd: 'earlyAccessEnd',
};
