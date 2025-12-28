// ignore_for_file: invalid_annotation_target

import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'local_pref_entity.freezed.dart';
part 'local_pref_entity.g.dart';

enum TabBarDisplayType { standard, alwaysCollapsed }

extension TabBarDisplayTypeX on TabBarDisplayType {
  String getTitle(BuildContext context) {
    switch (this) {
      case TabBarDisplayType.standard:
        return context.tr.general_pref_tab_bar_standard;
      case TabBarDisplayType.alwaysCollapsed:
        return context.tr.general_pref_tab_bar_always_collapsed;
    }
  }
}

enum InboxLastCreateEventType { calendar, task }

enum MailNotificationFilterType { none, withSpecificLables, all }

extension MailNotificationFilterTypeX on MailNotificationFilterType {
  String getTitle(BuildContext context) {
    switch (this) {
      case MailNotificationFilterType.none:
        return context.tr.mail_pref_filter_none;
      case MailNotificationFilterType.withSpecificLables:
        return context.tr.mail_pref_filter_with_specific_labels;
      case MailNotificationFilterType.all:
        return context.tr.mail_pref_filter_all;
    }
  }

  String getDescription(BuildContext context) {
    switch (this) {
      case MailNotificationFilterType.none:
        return context.tr.mail_pref_filter_none;
      case MailNotificationFilterType.withSpecificLables:
        return context.tr.mail_pref_filter_with_labels;
      case MailNotificationFilterType.all:
        return context.tr.mail_pref_filter_all_mails;
    }
  }
}

enum MessagNotificationFilterType { none, mentions, all }

extension MessagNotificationFilterTypeX on MessagNotificationFilterType {
  String getTitle(BuildContext context) {
    switch (this) {
      case MessagNotificationFilterType.none:
        return context.tr.message_pref_filter_none;
      case MessagNotificationFilterType.mentions:
        return context.tr.message_pref_filter_mentions;
      case MessagNotificationFilterType.all:
        return context.tr.message_pref_filter_all;
    }
  }
}

@freezed
abstract class LocalPrefEntity with _$LocalPrefEntity {
  const LocalPrefEntity._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory LocalPrefEntity({
    @JsonKey(includeIfNull: false) List<OAuthEntity>? calendarOAuths,
    @JsonKey(includeIfNull: false) List<OAuthEntity>? mailOAuths,
    @JsonKey(includeIfNull: false) List<OAuthEntity>? messengerOAuths,
    @JsonKey(includeIfNull: false) Map<String, String>? notificationPayload,
    @JsonKey(includeIfNull: false) Map<String, bool>? showCalendarNotifications,
    @JsonKey(includeIfNull: false) Map<String, MailNotificationFilterType>? mailNotificationFilterTypes,
    @JsonKey(includeIfNull: false) Map<String, List<String>>? mailNotificationFilterLabelIds,
    @JsonKey(includeIfNull: false) Map<String, MessagNotificationFilterType>? messageDmNotificationFilterTypes,
    @JsonKey(includeIfNull: false) Map<String, MessagNotificationFilterType>? messageChannelNotificationFilterTypes,
    @JsonKey(includeIfNull: false) Map<String, String?>? googleConnectionSyncToken,
    @JsonKey(includeIfNull: false) List<Map<String, String?>>? quickLinks,
    @JsonKey(includeIfNull: false) Map<String, String>? aiApiKeys,
    @JsonKey(includeIfNull: false) Map<String, dynamic>? selectedAgentModel,
    @JsonKey(includeIfNull: false) Map<String, String>? calendarType,
    @JsonKey(includeIfNull: false) Map<String, double>? calendarIntervalScale,
    @JsonKey(includeIfNull: false) List<String>? lastUsedCalendarId,
    @JsonKey(includeIfNull: false) List<String>? lastUsedProjectId,
    @JsonKey(includeIfNull: false) Map<String, String>? chatChannelStateList,
    @JsonKey(includeIfNull: false) Map<String, List<String>>? chatLastChannel,
    @JsonKey(includeIfNull: false) Map<String, String>? inboxSuggestionSort,
    @JsonKey(includeIfNull: false) Map<String, String>? inboxSuggestionFilter,
  }) = _LocalPrefEntity;

  /// Serialization
  factory LocalPrefEntity.fromJson(Map<String, dynamic> json) => _$LocalPrefEntityFromJson(json);

  TabBarDisplayType get prefTabBarDisplayType => TabBarDisplayType.alwaysCollapsed;

  Map<String, bool> get prefShowCalendarNotifications => showCalendarNotifications ?? {};

  Map<String, MailNotificationFilterType> get prefMailNotificationFilterTypes => mailNotificationFilterTypes ?? {};

  Map<String, List<String>> get prefMailNotificationFilterLabelIds => mailNotificationFilterLabelIds ?? {};

  Map<String, MessagNotificationFilterType> get prefMessageDmNotificationFilterTypes => messageDmNotificationFilterTypes ?? {};

  Map<String, MessagNotificationFilterType> get prefMessageChannelNotificationFilterTypes => messageChannelNotificationFilterTypes ?? {};

  Map<String, String> get prefAiApiKeys => aiApiKeys ?? {};

  Map<String, dynamic>? get prefSelectedAgentModel => selectedAgentModel;

  Map<String, String> get prefCalendarType => calendarType ?? {};

  Map<String, double> get prefCalendarIntervalScale => calendarIntervalScale ?? {};

  List<String> get prefLastUsedCalendarId => lastUsedCalendarId ?? [];

  List<String> get prefLastUsedProjectId => lastUsedProjectId ?? [];

  Map<String, String> get prefChatChannelStateList => chatChannelStateList ?? {};

  Map<String, List<String>> get prefChatLastChannel => chatLastChannel ?? {};

  Map<String, String> get prefInboxSuggestionSort => inboxSuggestionSort ?? {};

  Map<String, String> get prefInboxSuggestionFilter => inboxSuggestionFilter ?? {};
}
