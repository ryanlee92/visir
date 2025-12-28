// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationEntity _$NotificationEntityFromJson(Map<String, dynamic> json) =>
    _NotificationEntity(
      id: json['id'] as String,
      deviceId: json['device_id'] as String,
      userId: json['user_id'] as String,
      platform: json['platform'] as String?,
      fcmToken: json['fcm_token'] as String?,
      apnsToken: json['apns_token'] as String?,
      showTaskNotification: json['show_task_notification'] as bool?,
      showCalendarNotification:
          json['show_calendar_notification'] as Map<String, dynamic>?,
      showGmailNotification:
          json['show_gmail_notification'] as Map<String, dynamic>?,
      showSlackNotification:
          json['show_slack_notification'] as Map<String, dynamic>?,
      showOutlookMailNotification:
          json['show_outlook_mail_notification'] as Map<String, dynamic>?,
      linkedGmails: (json['linked_gmails'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      linkedGoogleCalendars: (json['linked_google_calendars'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      linkedSlackTeams: (json['linked_slack_teams'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      tokenSlackTeams: (json['token_slack_teams'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      linkedOutlookMails: (json['linked_outlook_mails'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      gmailServerCode: json['gmail_server_code'] as Map<String, dynamic>?,
      gcalServerCode: json['gcal_server_code'] as Map<String, dynamic>?,
      slackServerCode: json['slack_server_code'] as Map<String, dynamic>?,
      gmailNotificationImage:
          json['gmail_notification_image'] as Map<String, dynamic>?,
      gcalNotificationImage:
          json['gcal_notification_image'] as Map<String, dynamic>?,
      slackNotificationImage:
          json['slack_notification_image'] as Map<String, dynamic>?,
      outlookMailServerCode:
          json['outlook_mail_server_code'] as Map<String, dynamic>?,
      outlookMailNotificationImage:
          json['outlook_mail_notification_image'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$NotificationEntityToJson(_NotificationEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'device_id': instance.deviceId,
      'user_id': instance.userId,
      'platform': ?instance.platform,
      'fcm_token': ?instance.fcmToken,
      'apns_token': ?instance.apnsToken,
      'show_task_notification': ?instance.showTaskNotification,
      'show_calendar_notification': ?instance.showCalendarNotification,
      'show_gmail_notification': ?instance.showGmailNotification,
      'show_slack_notification': ?instance.showSlackNotification,
      'show_outlook_mail_notification': ?instance.showOutlookMailNotification,
      'linked_gmails': ?instance.linkedGmails,
      'linked_google_calendars': ?instance.linkedGoogleCalendars,
      'linked_slack_teams': ?instance.linkedSlackTeams,
      'token_slack_teams': ?instance.tokenSlackTeams,
      'linked_outlook_mails': ?instance.linkedOutlookMails,
      'gmail_server_code': ?instance.gmailServerCode,
      'gcal_server_code': ?instance.gcalServerCode,
      'slack_server_code': ?instance.slackServerCode,
      'gmail_notification_image': ?instance.gmailNotificationImage,
      'gcal_notification_image': ?instance.gcalNotificationImage,
      'slack_notification_image': ?instance.slackNotificationImage,
      'outlook_mail_server_code': ?instance.outlookMailServerCode,
      'outlook_mail_notification_image': ?instance.outlookMailNotificationImage,
    };
