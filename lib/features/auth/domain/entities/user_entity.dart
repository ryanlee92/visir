// ignore_for_file: invalid_annotation_target

import 'package:Visir/features/auth/domain/entities/subscription/user_subscription_entity.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/color_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/mail/domain/entities/mail_signature_entity.dart';
import 'package:Visir/features/task/domain/entities/task_reminder_option_type.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_entity.freezed.dart';
part 'user_entity.g.dart';

enum MailInboxFilterType { none, withSpecificLables, all }

extension MailInboxFilterTypeX on MailInboxFilterType {
  String getTitle(BuildContext context) {
    switch (this) {
      case MailInboxFilterType.none:
        return context.tr.mail_pref_filter_none;
      case MailInboxFilterType.withSpecificLables:
        return context.tr.mail_pref_filter_with_specific_labels;
      case MailInboxFilterType.all:
        return context.tr.mail_pref_filter_all;
    }
  }

  String getDescription(BuildContext context) {
    switch (this) {
      case MailInboxFilterType.none:
        return context.tr.mail_pref_filter_none;
      case MailInboxFilterType.withSpecificLables:
        return context.tr.mail_pref_filter_with_labels;
      case MailInboxFilterType.all:
        return context.tr.mail_pref_filter_all_mails;
    }
  }
}

enum ChatInboxFilterType { none, mentions, all }

extension MessageInboxFilterTypeX on ChatInboxFilterType {
  String getTitle(BuildContext context) {
    switch (this) {
      case ChatInboxFilterType.none:
        return context.tr.message_pref_filter_none;
      case ChatInboxFilterType.mentions:
        return context.tr.message_pref_filter_mentions;
      case ChatInboxFilterType.all:
        return context.tr.message_pref_filter_all;
    }
  }
}

enum InboxCalendarActionType { calendar, task, lastCreated }

extension InboxCalendarDoubleClickActionTypeX on InboxCalendarActionType {
  String getTitle(BuildContext context) {
    switch (this) {
      case InboxCalendarActionType.calendar:
        return context.tr.inbox_double_click_action_calendar_event;
      case InboxCalendarActionType.task:
        return context.tr.inbox_double_click_action_task;
      case InboxCalendarActionType.lastCreated:
        return context.tr.inbox_double_click_action_last_created;
    }
  }
}

enum SortChannelType { alphabetically, mostRecent }

extension SortChannelTypeX on SortChannelType {
  String getTitle(BuildContext context) {
    switch (this) {
      case SortChannelType.alphabetically:
        return context.tr.chat_alphabetically;
      case SortChannelType.mostRecent:
        return context.tr.chat_most_recent;
    }
  }
}

enum MailPrefSwipeActionType { none, readUnread, pinUnpin, createTask, archive, delete, reportSpam }

extension MailPrefSwipeActionTypeX on MailPrefSwipeActionType {
  String getTitle(BuildContext context) {
    switch (this) {
      case MailPrefSwipeActionType.none:
        return context.tr.mail_pref_swipe_none;
      case MailPrefSwipeActionType.readUnread:
        return context.tr.mail_pref_swipe_read_unread;
      case MailPrefSwipeActionType.pinUnpin:
        return context.tr.mail_pref_swipe_pin_unpin;
      case MailPrefSwipeActionType.createTask:
        return context.tr.mail_pref_swipe_create_task;
      case MailPrefSwipeActionType.archive:
        return context.tr.mail_pref_swipe_archive;
      case MailPrefSwipeActionType.delete:
        return context.tr.mail_pref_swipe_delete;
      case MailPrefSwipeActionType.reportSpam:
        return context.tr.mail_pref_swipe_report_spam;
    }
  }

  VisirIconType get icon {
    switch (this) {
      case MailPrefSwipeActionType.none:
        return VisirIconType.more;
      case MailPrefSwipeActionType.readUnread:
        return VisirIconType.show;
      case MailPrefSwipeActionType.pinUnpin:
        return VisirIconType.pin;
      case MailPrefSwipeActionType.createTask:
        return VisirIconType.task;
      case MailPrefSwipeActionType.archive:
        return VisirIconType.archive;
      case MailPrefSwipeActionType.delete:
        return VisirIconType.trash;
      case MailPrefSwipeActionType.reportSpam:
        return VisirIconType.spam;
    }
  }

  Color getColor(BuildContext context) {
    switch (this) {
      case MailPrefSwipeActionType.none:
        return Colors.transparent;
      case MailPrefSwipeActionType.readUnread:
        return Colors.lightBlue.shade500;
      case MailPrefSwipeActionType.pinUnpin:
        return Colors.orange.shade500;
      case MailPrefSwipeActionType.createTask:
        return context.secondary;
      case MailPrefSwipeActionType.archive:
        return context.tertiary;
      case MailPrefSwipeActionType.delete:
        return Colors.red.shade500;
      case MailPrefSwipeActionType.reportSpam:
        return Colors.deepOrange.shade500;
    }
  }

  String getButtonTitle(BuildContext context, bool isUnread, bool isPinned) {
    switch (this) {
      case MailPrefSwipeActionType.none:
      case MailPrefSwipeActionType.createTask:
      case MailPrefSwipeActionType.archive:
      case MailPrefSwipeActionType.delete:
      case MailPrefSwipeActionType.reportSpam:
        return getTitle(context);
      case MailPrefSwipeActionType.readUnread:
        return isUnread ? context.tr.mail_pref_swipe_read : context.tr.mail_pref_swipe_unread;
      case MailPrefSwipeActionType.pinUnpin:
        return isPinned ? context.tr.mail_pref_swipe_unpin : context.tr.mail_pref_swipe_pin;
    }
  }

  String getSwipeButtonTitle(BuildContext context, bool isUnread, bool isPinned) {
    switch (this) {
      case MailPrefSwipeActionType.none:
      case MailPrefSwipeActionType.readUnread:
      case MailPrefSwipeActionType.pinUnpin:
      case MailPrefSwipeActionType.archive:
      case MailPrefSwipeActionType.delete:
        return getButtonTitle(context, isUnread, isPinned);
      case MailPrefSwipeActionType.createTask:
      case MailPrefSwipeActionType.reportSpam:
        return getButtonTitle(context, isUnread, isPinned).split(' ').first;
    }
  }

  String? getSwipeButtonSubtitle(BuildContext context, bool isUnread, bool isPinned) {
    switch (this) {
      case MailPrefSwipeActionType.none:
      case MailPrefSwipeActionType.readUnread:
      case MailPrefSwipeActionType.pinUnpin:
      case MailPrefSwipeActionType.archive:
      case MailPrefSwipeActionType.delete:
        return null;
      case MailPrefSwipeActionType.createTask:
      case MailPrefSwipeActionType.reportSpam:
        return getButtonTitle(context, isUnread, isPinned).split(' ').last;
    }
  }
}

enum MailContentThemeType { followTaskeyTheme, light, dark }

extension MailContentThemeTypeX on MailContentThemeType {
  String getTitle(BuildContext context) {
    switch (this) {
      case MailContentThemeType.followTaskeyTheme:
        return context.tr.mail_pref_email_theme_follow_taskey_theme;
      case MailContentThemeType.light:
        return context.tr.mail_pref_email_theme_light;
      case MailContentThemeType.dark:
        return context.tr.mail_pref_email_theme_dark;
    }
  }
}

extension ThemeModeX on ThemeMode {
  String getTitle(BuildContext context) {
    switch (this) {
      case ThemeMode.system:
        return context.tr.general_theme_system;
      case ThemeMode.light:
        return context.tr.general_theme_light;
      case ThemeMode.dark:
        return context.tr.general_theme_dark;
    }
  }
}

enum CompletedTaskOptionType { show, hide, delete }

extension CompletedTaskOptionTypeX on CompletedTaskOptionType {
  String getTitle(BuildContext context) {
    switch (this) {
      case CompletedTaskOptionType.show:
        return context.tr.home_pref_completed_tasks_show;
      case CompletedTaskOptionType.hide:
        return context.tr.home_pref_completed_tasks_hide;
      case CompletedTaskOptionType.delete:
        return context.tr.home_pref_completed_tasks_delete;
    }
  }
}

extension StringX on String {
  bool get isSignedIn => this != fakeUser.id;
}

enum UpdateChannel { stable, beta }

enum UserTutorialType {
  desktopInboxDrag,
  mobileInboxDrag,
  desktopGcalPermission,
  mobileGcalPermission,
  desktopGmailPermission,
  mobileGmailPermission,
  desktopInboxFilter,
  mobileInboxFilter,
  timeSaved,
  timeSavedShare,
  earlyAccessEnd,
}

@freezed
abstract class UserEntity with _$UserEntity {
  const UserEntity._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  /// Factory Constructor
  const factory UserEntity({
    required String id,
    @JsonKey(includeIfNull: false) String? name,
    @JsonKey(includeIfNull: false) String? email,
    @JsonKey(includeIfNull: false) String? avatarUrl,
    @JsonKey(includeIfNull: false) DateTime? createdAt,
    @JsonKey(includeIfNull: false) DateTime? updatedAt,
    @JsonKey(includeIfNull: false) DateTime? subscriptionEndAt,
    @JsonKey(includeIfNull: false) int? badge,
    @JsonKey(includeIfNull: false) Map<String, String>? calendarColors,
    @JsonKey(includeIfNull: false) Map<String, String>? mailColors,
    @JsonKey(includeIfNull: false) List<MailSignatureEntity>? mailSignatures,
    @JsonKey(includeIfNull: false) Map<String, int>? defaultSignatures,
    @JsonKey(includeIfNull: false) Map<String, MailInboxFilterType>? mailInboxFilterTypes,
    @JsonKey(includeIfNull: false) Map<String, List<String>>? mailInboxFilterLabelIds,
    @JsonKey(includeIfNull: false) Map<String, ChatInboxFilterType>? messageDmInboxFilterTypes,
    @JsonKey(includeIfNull: false) Map<String, ChatInboxFilterType>? messageChannelInboxFilterTypes,
    @JsonKey(includeIfNull: false) String? taskColorHex,
    @JsonKey(includeIfNull: false) int? taskDefaultDurationInMinutes,
    @JsonKey(includeIfNull: false) InboxCalendarActionType? inboxCalendarDoubleClickActionType,
    @JsonKey(includeIfNull: false) InboxCalendarActionType? inboxCalendarDragActionType,
    @JsonKey(includeIfNull: false) InboxCalendarActionType? inboxFloatingButtonActionType,
    @JsonKey(includeIfNull: false) TaskReminderOptionType? defaultTaskReminderType,
    @JsonKey(includeIfNull: false) TaskReminderOptionType? defaultAllDayTaskReminderType,
    @JsonKey(includeIfNull: false) CompletedTaskOptionType? completedTaskOptionType,
    @JsonKey(includeIfNull: false) bool? showUnreadChannelsOnly,
    @JsonKey(includeIfNull: false) bool? showUnreadDmsOnly,
    @JsonKey(includeIfNull: false) SortChannelType? sortChannelType,
    @JsonKey(includeIfNull: false) List<String>? excludedChannelIds,
    @JsonKey(includeIfNull: false) MailPrefSwipeActionType? mailSwipeRightActionType,
    @JsonKey(includeIfNull: false) MailPrefSwipeActionType? mailSwipeLeftActionType,
    @JsonKey(includeIfNull: false) MailContentThemeType? mailContentThemeType,
    @JsonKey(includeIfNull: false) int? firstDayOfWeek,
    @JsonKey(includeIfNull: false) int? weekViewStartWeekday,
    @JsonKey(includeIfNull: false) int? defaultDurationInMinutes,
    @JsonKey(includeIfNull: false) String? defaultCalendarId,
    @JsonKey(includeIfNull: false) Map<String, String>? lastGmailHistoryIds,
    @JsonKey(includeIfNull: false) UpdateChannel? updateChannel,
    @JsonKey(includeIfNull: false) bool? taskCompletionSound,
    @JsonKey(includeIfNull: false) bool? mobileAppOpened,
    @JsonKey(includeIfNull: false) bool? desktopAppOpened,
    @JsonKey(includeIfNull: false) List<Map<String, String?>>? quickLinks,
    @JsonKey(includeIfNull: false) UserSubscriptionEntity? subscription,
    @JsonKey(includeIfNull: false) int? lemonSqueezyCustomerId,
    @JsonKey(includeIfNull: false) bool? isAdmin,
    @JsonKey(includeIfNull: false) bool? includeConferenceLinkOnHomeTab,
    @JsonKey(includeIfNull: false) bool? includeConferenceLinkOnCalendarTab,
    @JsonKey(includeIfNull: false) bool? isFreeUser,
    @JsonKey(includeIfNull: false) List<UserTutorialType>? userTutorialDoneList,
    @JsonKey(includeIfNull: false) double? aiCredits,
    @JsonKey(includeIfNull: false) DateTime? aiCreditsUpdatedAt,
  }) = _UserEntity;

  factory UserEntity.fromJson(Map<String, dynamic> json) => _$UserEntityFromJson(json);

  Map<String, String> get userMailColors => mailColors ?? {};

  Map<String, String> get userCalendarColors => calendarColors ?? {};

  List<MailSignatureEntity> get userMailSignatures => mailSignatures ?? [];

  Map<String, int> get userDefaultSignatures => defaultSignatures ?? {};

  Map<String, MailInboxFilterType> get userMailInboxFilterTypes => mailInboxFilterTypes ?? {};

  Map<String, List<String>> get userMilInboxFilterLabelIds => mailInboxFilterLabelIds ?? {};

  Map<String, ChatInboxFilterType> get userMessageDmInboxFilterTypes => messageDmInboxFilterTypes ?? {};

  Map<String, ChatInboxFilterType> get userMessageChannelInboxFilterTypes => messageChannelInboxFilterTypes ?? {};

  String get userTaskColorHex => taskColorHex ?? Colors.red.toHex();

  int get userTaskDefaultDurationInMinutes => taskDefaultDurationInMinutes ?? 60;

  InboxCalendarActionType get userInboxCalendarDoubleClickActionType => inboxCalendarDoubleClickActionType ?? InboxCalendarActionType.calendar;

  InboxCalendarActionType get userInboxCalendarDragActionType => inboxCalendarDragActionType ?? InboxCalendarActionType.calendar;

  InboxCalendarActionType get userInboxFloatingButtonActionType => inboxFloatingButtonActionType ?? InboxCalendarActionType.calendar;

  TaskReminderOptionType get userDefaultTaskReminderType => defaultTaskReminderType ?? TaskReminderOptionType.none;

  TaskReminderOptionType get userDefaultAllDayTaskReminderType => defaultAllDayTaskReminderType ?? TaskReminderOptionType.none;

  CompletedTaskOptionType get userCompletedTaskOptionType => completedTaskOptionType ?? CompletedTaskOptionType.show;

  String? get userDefaultCalendarId => defaultCalendarId?.isNotEmpty == true ? defaultCalendarId : null;

  bool get userShowUnreadChannelsOnly => showUnreadChannelsOnly ?? false;

  bool get userShowUnreadDmsOnly => showUnreadDmsOnly ?? false;

  bool get userTaskCompletionSound => taskCompletionSound ?? true;

  bool get userMobileAppOpened => mobileAppOpened ?? false;

  bool get userDesktopAppOpened => desktopAppOpened ?? false;

  List<UserTutorialType> get tutorialDoneList => userTutorialDoneList ?? [];

  bool get desktopInboxDragTutorialDone => tutorialDoneList.contains(UserTutorialType.desktopInboxDrag);

  bool get mobileInboxDragTutorialDone => tutorialDoneList.contains(UserTutorialType.mobileInboxDrag);

  bool get desktopGcalPermissionTutorialDone => tutorialDoneList.contains(UserTutorialType.desktopGcalPermission);

  bool get mobileGcalPermissionTutorialDone => tutorialDoneList.contains(UserTutorialType.mobileGcalPermission);

  bool get desktopGmailPermissionTutorialDone => tutorialDoneList.contains(UserTutorialType.desktopGmailPermission);

  bool get mobileGmailPermissionTutorialDone => tutorialDoneList.contains(UserTutorialType.mobileGmailPermission);

  bool get desktopInboxFilterTutorialDone => tutorialDoneList.contains(UserTutorialType.desktopInboxFilter);

  bool get mobileInboxFilterTutorialDone => tutorialDoneList.contains(UserTutorialType.mobileInboxFilter);

  bool get timeSavedTutorialDone => tutorialDoneList.contains(UserTutorialType.timeSaved);

  bool get earlyAccessEndTutorialDone => tutorialDoneList.contains(UserTutorialType.earlyAccessEnd);

  bool get timeSavedShareTutorialDone => tutorialDoneList.contains(UserTutorialType.timeSavedShare);

  bool get userIsAdmin => isAdmin ?? false;

  bool get userIncludeConferenceLinkOnHomeTab => includeConferenceLinkOnHomeTab ?? false;

  bool get userIncludeConferenceLinkOnCalendarTab => includeConferenceLinkOnCalendarTab ?? false;

  SortChannelType get userSortChannelType => sortChannelType ?? SortChannelType.alphabetically;

  List<String> get userExcludedChannelIds => excludedChannelIds ?? [];

  MailPrefSwipeActionType get userMailSwipeRightActionType => mailSwipeRightActionType ?? MailPrefSwipeActionType.readUnread;

  MailPrefSwipeActionType get userMailSwipeLeftActionType => mailSwipeLeftActionType ?? MailPrefSwipeActionType.pinUnpin;

  MailContentThemeType get userMailContentThemeType => mailContentThemeType ?? MailContentThemeType.followTaskeyTheme;

  int get userFirstDayOfWeek => firstDayOfWeek ?? 7;

  int get userWeekViewStartWeekday => weekViewStartWeekday ?? 0;

  int get userDefaultDurationInMinutes => defaultDurationInMinutes ?? 60;

  UpdateChannel get userUpdateChannel => updateChannel ?? UpdateChannel.stable;

  bool get isNeverSubscribed => subscription == null;

  bool get onSubscription {
    if (isFreeUser ?? false) return true;
    if (onTrial) return true;
    if (subscription == null) return false;
    return !subscription!.isExpired;
  }

  int get userTotalDays => isSignedIn == true
      ? createdAt != null
            ? DateTime.now().difference(createdAt!).inDays + 1
            : 1
      : 366;

  bool get isSignedIn => id != fakeUser.id;

  DateTime get freeTrialEndAt => createdAt?.add(const Duration(days: 7)) ?? DateTime.now();

  bool get onTrial => freeTrialEndAt.isAfter(DateTime.now());

  double get userAiCredits => aiCredits ?? 0.0;
}
