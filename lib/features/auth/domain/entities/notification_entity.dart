// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_entity.freezed.dart';
part 'notification_entity.g.dart';

@freezed
abstract class NotificationEntity with _$NotificationEntity {
  @JsonSerializable(fieldRename: FieldRename.snake)

  /// Factory Constructor
  const factory NotificationEntity({
    required String id,
    required String deviceId,
    required String userId,
    @JsonKey(includeIfNull: false) String? platform,
    @JsonKey(includeIfNull: false) String? fcmToken,
    @JsonKey(includeIfNull: false) String? apnsToken,
    @JsonKey(includeIfNull: false) bool? showTaskNotification,
    @JsonKey(includeIfNull: false) Map<dynamic, dynamic>? showCalendarNotification,
    @JsonKey(includeIfNull: false) Map<dynamic, dynamic>? showGmailNotification,
    @JsonKey(includeIfNull: false) Map<dynamic, dynamic>? showSlackNotification,
    @JsonKey(includeIfNull: false) Map<dynamic, dynamic>? showOutlookMailNotification,
    @JsonKey(includeIfNull: false) List<String>? linkedGmails,
    @JsonKey(includeIfNull: false) List<String>? linkedGoogleCalendars,
    @JsonKey(includeIfNull: false) List<String>? linkedSlackTeams,
    @JsonKey(includeIfNull: false) List<String>? tokenSlackTeams,
    @JsonKey(includeIfNull: false) List<String>? linkedOutlookMails,
    @JsonKey(includeIfNull: false) Map<dynamic, dynamic>? gmailServerCode,
    @JsonKey(includeIfNull: false) Map<dynamic, dynamic>? gcalServerCode,
    @JsonKey(includeIfNull: false) Map<dynamic, dynamic>? slackServerCode,
    @JsonKey(includeIfNull: false) Map<dynamic, dynamic>? gmailNotificationImage,
    @JsonKey(includeIfNull: false) Map<dynamic, dynamic>? gcalNotificationImage,
    @JsonKey(includeIfNull: false) Map<dynamic, dynamic>? slackNotificationImage,
    @JsonKey(includeIfNull: false) Map<dynamic, dynamic>? outlookMailServerCode,
    @JsonKey(includeIfNull: false) Map<dynamic, dynamic>? outlookMailNotificationImage,
  }) = _NotificationEntity;

  factory NotificationEntity.fromJson(Map<String, dynamic> json) => _$NotificationEntityFromJson(json);
}
