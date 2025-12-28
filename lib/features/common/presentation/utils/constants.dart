import 'package:Visir/features/auth/domain/entities/user_entity.dart';
import 'package:Visir/features/calendar/presentation/screens/main_calendar_widget.dart';
import 'package:Visir/features/chat/domain/entities/message_team_entity.dart';
import 'package:Visir/features/chat/domain/entities/slack/slack_message_team_entity.dart';
import 'package:Visir/features/chat/domain/entities/slack/slack_message_team_icon_entity.dart';
import 'package:Visir/features/common/presentation/utils/extensions/color_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/inbox/presentation/screens/inbox_list_screen.dart';
import 'package:Visir/features/preference/domain/entities/local_pref_entity.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:Visir/features/task/domain/entities/project_entity.dart';
import 'package:Visir/features/task/domain/entities/task_entity.dart';
import 'package:Visir/features/time_saved/presentation/widgets/time_saved_button.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Constants {
  static GlobalKey<MainCalendarWidgetState> inboxCalendarScreenKey = GlobalKey();
  static GlobalKey<InboxListScreenState> inboxListScreenKey = GlobalKey();
  static GlobalKey<TimeSavedButtonState> timeSavedButtonKey = GlobalKey();

  static int desktopTitleBarHeight = 40;
  static int chatScreenBreakPoint = 520;

  static double desktopCreateTaskPopupWidth = 300;

  static int timerPerAppSwitchingInSeconds = 5;
  static double appSwitchingProductivityLossRate = 0.15;

  static String GoogleCalendarAccountStorageKey = 'google_calendar_accounts';
  static String gmailAccountStorageKey = 'gmail_accounts';

  static String tosUrl = 'https://visir.pro/terms';
  static String privacyUrl = 'https://visir.pro/privacy';
  static String slackAuthUrl = 'https://slack.com/signin';
  static String taskeyDownloadUrl = 'https://visir.pro/download';
  static String taskeyHomeUrl = 'https://visir.pro/';

  static String appGroupIdentifier = 'group.com.wavetogether.fillin';

  // ValueNotifier로 변경하여 백그라운드 업데이트 지원
  static final ValueNotifier<bool> isBetaBuildNotifier = ValueNotifier(false);
  static bool get isBetaBuild => isBetaBuildNotifier.value;
  static set isBetaBuild(bool value) => isBetaBuildNotifier.value = value;

  static final ValueNotifier<bool> hasProductionBuildNotifier = ValueNotifier(false);
  static bool get hasProductionBuild => hasProductionBuildNotifier.value;
  static set hasProductionBuild(bool value) => hasProductionBuildNotifier.value = value;

  static String supportEmail = 'support@wavetogether.com';

  static List<double> moneySavedMilestones = [10, 50, 100, 500, 1000, 5000, 10000, 15000, 20000, 25000, 30000, 35000, 40000, 45000, 50000];

  static List<Color> taskColors = [
    Colors.red.shade500,
    Colors.deepOrange.shade500,
    Colors.orange.shade500,
    Colors.yellow.shade500,
    Colors.lightGreen.shade500,
    Colors.green.shade500,
    Colors.teal.shade500,
    Colors.lightBlue.shade500,
    Colors.indigo.shade500,
    Colors.deepPurple.shade500,
    Colors.purple.shade500,
    Colors.brown.shade500,
  ];
}

extension TaskColorName on Color {
  String get name {
    if (this.toHex() == Colors.red.shade500.toHex()) {
      return 'Red';
    }

    if (this.toHex() == Colors.deepOrange.shade500.toHex()) {
      return 'Deep orange';
    }

    if (this.toHex() == Colors.orange.shade500.toHex()) {
      return 'orange';
    }

    if (this.toHex() == Colors.yellow.shade500.toHex()) {
      return 'yellow';
    }

    if (this.toHex() == Colors.lightGreen.shade500.toHex()) {
      return 'lightGreen';
    }

    if (this.toHex() == Colors.green.shade500.toHex()) {
      return 'green';
    }

    if (this.toHex() == Colors.teal.shade500.toHex()) {
      return 'teal';
    }

    if (this.toHex() == Colors.lightBlue.shade500.toHex()) {
      return 'lightBlue';
    }

    if (this.toHex() == Colors.indigo.shade500.toHex()) {
      return 'indigo';
    }

    if (this.toHex() == Colors.deepPurple.shade500.toHex()) {
      return 'deepPurple';
    }

    if (this.toHex() == Colors.purple.shade500.toHex()) {
      return 'purple';
    }

    if (this.toHex() == Colors.brown.shade500.toHex()) {
      return 'brown';
    }

    return this.toHex();
  }
}

List<ProjectEntity> mockProjects() {
  return [ProjectEntity(id: 'onboarding', name: 'Onboarding', createdAt: DateTime.now(), updatedAt: DateTime.now(), color: Colors.red.shade500, ownerId: fakeUserId)];
}

// default tasks
List<TaskEntity> mockTasks({required DateTime now, required BuildContext context, String? userId}) => [
  TaskEntity(
    id: 'mock_task_before_signin_tour_1',
    title: context.tr.default_task_before_signin_tour_title,
    description: context.tr.default_task_before_signin_tour_desc,
    createdAt: DateTime.now().subtract(Duration(minutes: 2)),
    updatedAt: DateTime.now().subtract(Duration(minutes: 2)),
    startAt: DateUtils.dateOnly(now),
    endAt: DateUtils.dateOnly(now).add(const Duration(days: 1)),
    recurrenceEndAt: DateUtils.dateOnly(now).add(const Duration(days: 1)),
    isAllDay: true,
    doNotApplyDateOffset: true,
    projectId: userId ?? 'onboarding',
  ),
  TaskEntity(
    id: 'mock_task_before_signin_explore_2',
    title: context.tr.default_task_before_signin_explore_title,
    description: context.tr.default_task_before_signin_explore_desc,
    createdAt: DateTime.now().subtract(Duration(minutes: 3)),
    updatedAt: DateTime.now().subtract(Duration(minutes: 3)),
    startAt: DateUtils.dateOnly(now),
    endAt: DateUtils.dateOnly(now).add(const Duration(days: 1)),
    recurrenceEndAt: DateUtils.dateOnly(now).add(const Duration(days: 1)),
    isAllDay: true,
    doNotApplyDateOffset: true,
    projectId: userId ?? 'onboarding',
  ),
  TaskEntity(
    id: 'mock_task_before_signin_inbox_3',
    title: context.tr.default_task_before_signin_inbox_title,
    description: context.tr.default_task_before_signin_inbox_desc,
    createdAt: DateTime.now().subtract(Duration(minutes: 4)),
    updatedAt: DateTime.now().subtract(Duration(minutes: 4)),
    startAt: DateUtils.dateOnly(now),
    endAt: DateUtils.dateOnly(now).add(const Duration(days: 1)),
    recurrenceEndAt: DateUtils.dateOnly(now).add(const Duration(days: 1)),
    isAllDay: true,
    doNotApplyDateOffset: true,
    projectId: userId ?? 'onboarding',
  ),
  TaskEntity(
    id: 'mock_task_before_signin_quickview_4',
    title: context.tr.default_task_before_signin_quickview_title,
    description: context.tr.default_task_before_signin_quickview_desc,
    createdAt: DateTime.now().subtract(Duration(minutes: 5)),
    updatedAt: DateTime.now().subtract(Duration(minutes: 5)),
    startAt: DateUtils.dateOnly(now),
    endAt: DateUtils.dateOnly(now).add(const Duration(days: 1)),
    recurrenceEndAt: DateUtils.dateOnly(now).add(const Duration(days: 1)),
    isAllDay: true,
    doNotApplyDateOffset: true,
    projectId: userId ?? 'onboarding',
  ),
  TaskEntity(
    id: 'mock_task_before_signin_signin_5',
    title: context.tr.default_task_before_signin_signin_title,
    description: context.tr.default_task_before_signin_signin_desc,
    createdAt: DateTime.now().subtract(Duration(minutes: 6)),
    updatedAt: DateTime.now().subtract(Duration(minutes: 6)),
    startAt: DateUtils.dateOnly(now),
    endAt: DateUtils.dateOnly(now).add(const Duration(days: 1)),
    recurrenceEndAt: DateUtils.dateOnly(now).add(const Duration(days: 1)),
    isAllDay: true,
    doNotApplyDateOffset: true,
    projectId: userId ?? 'onboarding',
  ),
];

List<TaskEntity> afterLoginTasks({required DateTime now, required BuildContext context, required String ownerId}) => [
  TaskEntity(
    id: Uuid().v4(),
    ownerId: ownerId,
    title: context.tr.default_task_after_signin_connect_services_title,
    description: context.tr.default_task_after_signin_connect_services_desc,
    createdAt: DateTime.now().subtract(Duration(minutes: 2)),
    updatedAt: DateTime.now().subtract(Duration(minutes: 2)),
    startAt: DateUtils.dateOnly(now),
    endAt: DateUtils.dateOnly(now).add(const Duration(days: 1)),
    recurrenceEndAt: DateUtils.dateOnly(now).add(const Duration(days: 1)),
    isAllDay: true,
    status: TaskStatus.none,
    doNotApplyDateOffset: true,
    projectId: ownerId,
  ),
  TaskEntity(
    id: Uuid().v4(),
    ownerId: ownerId,
    title: context.tr.default_task_after_signin_revisit_tabs_title,
    description: context.tr.default_task_after_signin_revisit_tabs_desc,
    createdAt: DateTime.now().subtract(Duration(minutes: 3)),
    updatedAt: DateTime.now().subtract(Duration(minutes: 3)),
    startAt: DateUtils.dateOnly(now),
    endAt: DateUtils.dateOnly(now).add(const Duration(days: 1)),
    recurrenceEndAt: DateUtils.dateOnly(now).add(const Duration(days: 1)),
    isAllDay: true,
    status: TaskStatus.none,
    doNotApplyDateOffset: true,
    projectId: ownerId,
  ),
  TaskEntity(
    id: Uuid().v4(),
    ownerId: ownerId,
    title: context.tr.default_task_after_signin_schedule_ai_title,
    description: context.tr.default_task_after_signin_schedule_ai_desc,
    createdAt: DateTime.now().subtract(Duration(minutes: 4)),
    updatedAt: DateTime.now().subtract(Duration(minutes: 4)),
    startAt: DateUtils.dateOnly(now),
    endAt: DateUtils.dateOnly(now).add(const Duration(days: 1)),
    recurrenceEndAt: DateUtils.dateOnly(now).add(const Duration(days: 1)),
    isAllDay: true,
    status: TaskStatus.none,
    doNotApplyDateOffset: true,
    projectId: ownerId,
  ),
  TaskEntity(
    id: Uuid().v4(),
    ownerId: ownerId,
    title: context.tr.default_task_after_signin_reply_in_quick_view_title,
    description: context.tr.default_task_after_signin_reply_in_quick_view_desc,
    createdAt: DateTime.now().subtract(Duration(minutes: 5)),
    updatedAt: DateTime.now().subtract(Duration(minutes: 5)),
    startAt: DateUtils.dateOnly(now),
    endAt: DateUtils.dateOnly(now).add(const Duration(days: 1)),
    recurrenceEndAt: DateUtils.dateOnly(now).add(const Duration(days: 1)),
    isAllDay: true,
    status: TaskStatus.none,
    doNotApplyDateOffset: true,
    projectId: ownerId,
  ),
  TaskEntity(
    id: Uuid().v4(),
    ownerId: ownerId,
    title: context.tr.default_task_after_signin_create_from_message_title,
    description: context.tr.default_task_after_signin_create_from_message_desc,
    createdAt: DateTime.now().subtract(Duration(minutes: 6)),
    updatedAt: DateTime.now().subtract(Duration(minutes: 6)),
    startAt: DateUtils.dateOnly(now),
    endAt: DateUtils.dateOnly(now).add(const Duration(days: 1)),
    recurrenceEndAt: DateUtils.dateOnly(now).add(const Duration(days: 1)),
    isAllDay: true,
    status: TaskStatus.none,
    doNotApplyDateOffset: true,
    projectId: ownerId,
  ),
  TaskEntity(
    id: Uuid().v4(),
    ownerId: ownerId,
    title: context.tr.default_task_after_signin_use_free_trial_title,
    description: context.tr.default_task_after_signin_use_free_trial_desc,
    createdAt: DateTime.now().subtract(Duration(minutes: 7)),
    updatedAt: DateTime.now().subtract(Duration(minutes: 7)),
    startAt: DateUtils.dateOnly(now),
    endAt: DateUtils.dateOnly(now).add(const Duration(days: 1)),
    recurrenceEndAt: DateUtils.dateOnly(now).add(const Duration(days: 1)),
    isAllDay: true,
    status: TaskStatus.none,
    doNotApplyDateOffset: true,
    projectId: ownerId,
  ),
];

List<TaskEntity> nearTrialEndTasks({required DateTime now, required BuildContext context, required String ownerId}) => [
  TaskEntity(
    id: Uuid().v4(),
    ownerId: ownerId,
    title: context.tr.default_task_near_trial_end_check_time_saved_title,
    description: context.tr.default_task_near_trial_end_check_time_saved_desc,
    createdAt: DateTime.now().subtract(Duration(minutes: 2)),
    updatedAt: DateTime.now().subtract(Duration(minutes: 2)),
    startAt: DateUtils.dateOnly(now),
    endAt: DateUtils.dateOnly(now).add(const Duration(days: 1)),
    recurrenceEndAt: DateUtils.dateOnly(now).add(const Duration(days: 1)),
    isAllDay: true,
    status: TaskStatus.none,
    doNotApplyDateOffset: true,
    projectId: ownerId,
  ),
  TaskEntity(
    id: Uuid().v4(),
    ownerId: ownerId,
    title: context.tr.default_task_near_trial_end_share_image_title,
    description: context.tr.default_task_near_trial_end_share_image_desc,
    createdAt: DateTime.now().subtract(Duration(minutes: 3)),
    updatedAt: DateTime.now().subtract(Duration(minutes: 3)),
    startAt: DateUtils.dateOnly(now),
    endAt: DateUtils.dateOnly(now).add(const Duration(days: 1)),
    recurrenceEndAt: DateUtils.dateOnly(now).add(const Duration(days: 1)),
    isAllDay: true,
    status: TaskStatus.none,
    doNotApplyDateOffset: true,
    projectId: ownerId,
  ),
  TaskEntity(
    id: Uuid().v4(),
    ownerId: ownerId,
    title: context.tr.default_task_near_trial_end_start_subscription_title,
    description: context.tr.default_task_near_trial_end_start_subscription_desc,
    createdAt: DateTime.now().subtract(Duration(minutes: 4)),
    updatedAt: DateTime.now().subtract(Duration(minutes: 4)),
    startAt: DateUtils.dateOnly(now),
    endAt: DateUtils.dateOnly(now).add(const Duration(days: 1)),
    recurrenceEndAt: DateUtils.dateOnly(now).add(const Duration(days: 1)),
    isAllDay: true,
    status: TaskStatus.none,
    doNotApplyDateOffset: true,
    projectId: ownerId,
  ),
];

// showcase constants
GlobalKey _inboxListDescriptionShowcaseKey = GlobalKey(debugLabel: 'inboxListDescriptionShowcaseKey');
GlobalKey _inboxItemShowcaseKey = GlobalKey(debugLabel: 'inboxItemShowcaseKey');
GlobalKey _taskCalendarShowcaseKey = GlobalKey(debugLabel: 'taskCalendarShowcaseKey');
GlobalKey taskOnCalendarShowcaseKey = GlobalKey(debugLabel: 'taskOnCalendarShowcaseKey');
GlobalKey taskOnCalendarShowcaseKey2 = GlobalKey(debugLabel: 'taskOnCalendarShowcaseKey2');
GlobalKey eventOnCalendarShowcaseKey = GlobalKey(debugLabel: 'eventOnCalendarShowcaseKey');

GlobalKey _taskLinkedMailDetailShowcaseKey = GlobalKey(debugLabel: 'taskLinkedMailDetailShowcaseKey');
GlobalKey _taskLinkedChatDetailShowcaseKey = GlobalKey(debugLabel: 'taskLinkedChatDetailShowcaseKey');

GlobalKey _taskLinkedMailShowcaseKey = GlobalKey(debugLabel: 'taskLinkedMailShowcaseKey');
GlobalKey _taskLinkedChatShowcaseKey = GlobalKey(debugLabel: 'taskLinkedChatShowcaseKey');

GlobalKey _taskTabShowcaseKey = GlobalKey(debugLabel: 'taskTabShowcaseKey');
GlobalKey _mailTabShowcaseKey = GlobalKey(debugLabel: 'mailTabShowcaseKey');
GlobalKey _chatTabShowcaseKey = GlobalKey(debugLabel: 'chatTabShowcaseKey');
GlobalKey _calendarTabShowcaseKey = GlobalKey(debugLabel: 'calendarTabShowcaseKey');

GlobalKey _chatCreateTaskShowcaseKey = GlobalKey(debugLabel: 'chatCreateTaskShowcaseKey');
GlobalKey _mailCreateTaskShowcaseKey = GlobalKey(debugLabel: 'mailCreateTaskShowcaseKey');

String inboxListDescriptionShowcaseKeyString = 'inboxListDescriptionShowcaseKey';
String inboxItemShowcaseKeyString = 'inboxItemShowcaseKey';
String taskCalendarShowcaseKeyString = 'taskCalendarShowcaseKey';
String taskOnCalendarShowcaseKeyString = 'taskOnCalendarShowcaseKey';
String taskLinkedMailShowcaseKeyString = 'taskLinkedMailShowcaseKey';
String taskLinkedChatShowcaseKeyString = 'taskLinkedChatShowcaseKey';
String taskLinkedMailDetailShowcaseKeyString = 'taskLinkedMailDetailShowcaseKey';
String taskLinkedChatDetailShowcaseKeyString = 'taskLinkedChatDetailShowcaseKey';
String taskTabShowcaseKeyString = 'taskTabShowcaseKey';
String mailTabShowcaseKeyString = 'mailTabShowcaseKey';
String chatTabShowcaseKeyString = 'chatTabShowcaseKey';
String calendarTabShowcaseKeyString = 'calendarTabShowcaseKey';
String chatCreateTaskShowcaseKeyString = 'chatCreateTaskShowcaseKey';
String mailCreateTaskShowcaseKeyString = 'mailCreateTaskShowcaseKey';

String linkedChatEventId = "82ec12262eeb4566b0dab11a";
String linkedMailTaskId = "0010e4d1-d5f2-4205-992f-ea9a08295b1e";
String targetChatMessageId = '1757159820.000717';
String targetChatChannelId = 'C1001';
String targetMailMessageId = 'm_0120_01';

ValueNotifier<String?> isShowcaseOn = ValueNotifier(null);

Map<String, ShowcaseEntity> getShowcaseEntities() => {
  inboxListDescriptionShowcaseKeyString: ShowcaseEntity(
    key: _inboxListDescriptionShowcaseKey,
    title: Utils.mainContext.tr.tour_inbox_list_title,
    description: Utils.mainContext.tr.tour_inbox_list_description,
    listTitle: Utils.mainContext.tr.tour_inbox_list_subject,
  ),
  inboxItemShowcaseKeyString: ShowcaseEntity(
    key: _inboxItemShowcaseKey,
    title: Utils.mainContext.tr.tour_inbox_item_title,
    description: Utils.mainContext.tr.tour_inbox_item_description,
    listTitle: Utils.mainContext.tr.tour_inbox_item_subject,
  ),
  taskCalendarShowcaseKeyString: ShowcaseEntity(
    key: _taskCalendarShowcaseKey,
    title: Utils.mainContext.tr.tour_task_calendar_title,
    description: Utils.mainContext.tr.tour_task_calendar_description,
    listTitle: Utils.mainContext.tr.tour_task_calendar_subject,
  ),
  taskOnCalendarShowcaseKeyString: ShowcaseEntity(
    key: taskOnCalendarShowcaseKey,
    keys: [eventOnCalendarShowcaseKey],
    title: Utils.mainContext.tr.tour_task_on_calendar_title,
    description: Utils.mainContext.tr.tour_task_on_calendar_description,
    listTitle: Utils.mainContext.tr.tour_task_on_calendar_subject,
  ),
  taskLinkedMailShowcaseKeyString: ShowcaseEntity(
    key: _taskLinkedMailShowcaseKey,
    keys: [taskOnCalendarShowcaseKey2],
    title: Utils.mainContext.tr.tour_task_linked_mail_title,
    description: Utils.mainContext.tr.tour_task_linked_mail_description,
    listTitle: Utils.mainContext.tr.tour_task_linked_mail_subject,
  ),
  taskLinkedChatShowcaseKeyString: ShowcaseEntity(
    key: _taskLinkedChatShowcaseKey,
    keys: [eventOnCalendarShowcaseKey],
    title: Utils.mainContext.tr.tour_task_linked_chat_title,
    description: Utils.mainContext.tr.tour_task_linked_chat_description,
    listTitle: Utils.mainContext.tr.tour_task_linked_chat_subject,
  ),
  taskLinkedMailDetailShowcaseKeyString: ShowcaseEntity(
    key: _taskLinkedMailDetailShowcaseKey,
    title: Utils.mainContext.tr.tour_task_linked_mail_detail_title,
    description: Utils.mainContext.tr.tour_task_linked_mail_detail_description,
    listTitle: Utils.mainContext.tr.tour_task_linked_mail_detail_subject,
  ),
  taskLinkedChatDetailShowcaseKeyString: ShowcaseEntity(
    key: _taskLinkedChatDetailShowcaseKey,
    title: Utils.mainContext.tr.tour_task_linked_chat_detail_title,
    description: Utils.mainContext.tr.tour_task_linked_chat_detail_description,
    listTitle: Utils.mainContext.tr.tour_task_linked_chat_detail_subject,
  ),
  taskTabShowcaseKeyString: ShowcaseEntity(
    key: _taskTabShowcaseKey,
    title: Utils.mainContext.tr.tour_task_tab_title,
    description: Utils.mainContext.tr.tour_task_tab_description,
    listTitle: Utils.mainContext.tr.tour_task_tab_subject,
  ),
  mailTabShowcaseKeyString: ShowcaseEntity(
    key: _mailTabShowcaseKey,
    title: Utils.mainContext.tr.tour_mail_tab_title,
    description: Utils.mainContext.tr.tour_mail_tab_description,
    listTitle: Utils.mainContext.tr.tour_mail_tab_subject,
  ),
  chatTabShowcaseKeyString: ShowcaseEntity(
    key: _chatTabShowcaseKey,
    title: Utils.mainContext.tr.tour_chat_tab_title,
    description: Utils.mainContext.tr.tour_chat_tab_description,
    listTitle: Utils.mainContext.tr.tour_chat_tab_subject,
  ),
  calendarTabShowcaseKeyString: ShowcaseEntity(
    key: _calendarTabShowcaseKey,
    title: Utils.mainContext.tr.tour_calendar_tab_title,
    description: Utils.mainContext.tr.tour_calendar_tab_description,
    listTitle: Utils.mainContext.tr.tour_calendar_tab_subject,
  ),
  chatCreateTaskShowcaseKeyString: ShowcaseEntity(
    key: _chatCreateTaskShowcaseKey,
    title: Utils.mainContext.tr.tour_chat_create_task_title,
    description: Utils.mainContext.tr.tour_chat_create_task_description,
    listTitle: Utils.mainContext.tr.tour_chat_create_task_subject,
  ),
  mailCreateTaskShowcaseKeyString: ShowcaseEntity(
    key: _mailCreateTaskShowcaseKey,
    title: Utils.mainContext.tr.tour_mail_create_task_title,
    description: Utils.mainContext.tr.tour_mail_create_task_description,
    listTitle: Utils.mainContext.tr.tour_mail_create_task_subject,
  ),
};

class ShowcaseEntity {
  GlobalKey key;
  List<GlobalKey>? keys;
  String title;
  String listTitle;
  String description;

  ShowcaseEntity({required this.key, this.keys, required this.title, required this.description, required this.listTitle});
}

// mock data constants
Duration dateOffset = DateUtils.dateOnly(DateTime.now()).difference(DateTime(2025, 9, 13, 6, 0));
// Mail: 가장 최근 메일(2025-09-09 05:34:17 UTC)을 현재 시간으로 맞춤
Duration mailDateOffset = DateTime.now().toUtc().difference(DateTime.utc(2025, 9, 9, 5, 34, 17));
// Chat: 가장 최근 메시지(2025-09-10 14:18:00 UTC)를 현재 시간으로 맞춤 (약 10개 정도 보이도록)
Duration chatDateOffset = DateTime.now().toUtc().difference(DateTime.utc(2025, 9, 10, 14, 18, 0));

String fakeUserId = 'fake';
String fakeUserEmail = 'alex@taskey.work';

UserEntity fakeUser = UserEntity(
  id: fakeUserId,
  name: 'Alex',
  email: fakeUserEmail,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
  isFreeUser: true,
  userTutorialDoneList: UserTutorialType.values,
  mailColors: {fakeUserEmail: Colors.red.toHex(), companyEmail: Colors.teal.toHex()},
);

String companyEmail = 'alex@wavetogether.com';
String taskeyIcon = 'https://azukhxinzrivjforwnsc.supabase.co/storage/v1/object/public/logo/taskey.png';
String waveIcon = 'https://azukhxinzrivjforwnsc.supabase.co/storage/v1/object/public/logo/wave.png';

LocalPrefEntity fakeLocalPref = LocalPrefEntity(
  calendarOAuths: [
    OAuthEntity(email: fakeUser.email!, accessToken: {}, refreshToken: '', type: OAuthType.google),
    OAuthEntity(email: companyEmail, accessToken: {}, refreshToken: '', type: OAuthType.microsoft),
  ],
  mailOAuths: [
    OAuthEntity(email: fakeUser.email!, accessToken: {}, refreshToken: '', type: OAuthType.google),
    OAuthEntity(email: companyEmail, accessToken: {}, refreshToken: '', type: OAuthType.microsoft),
  ],
  messengerOAuths: [
    OAuthEntity(
      email: fakeUser.email!,
      accessToken: {},
      refreshToken: '',
      type: OAuthType.slack,
      team: MessageTeamEntity.fromSlack(
        team: SlackMessageTeamEntity(
          id: 'taskey',
          name: 'Visir',
          domain: 'taskey.work',
          email_domain: 'taskey.work',
          avatar_base_url: 'https://taskey.work',
          isVerified: true,
          enterprise_id: 'taskey',
          enterprise_name: 'Visir',
          icon: SlackMessageTeamIconEntity(image_44: taskeyIcon, image_132: taskeyIcon),
        ),
      ),
    ),
    OAuthEntity(
      email: fakeUser.email!,
      accessToken: {},
      refreshToken: '',
      type: OAuthType.slack,
      team: MessageTeamEntity.fromSlack(
        team: SlackMessageTeamEntity(
          id: 'wave',
          name: 'Wave',
          domain: 'wavetogether.com',
          email_domain: 'wavetogether.com',
          avatar_base_url: 'https://wavetogether.com',
          isVerified: true,
          enterprise_id: 'wave',
          enterprise_name: 'Wave',
          icon: SlackMessageTeamIconEntity(image_44: waveIcon, image_132: waveIcon),
        ),
      ),
    ),
  ],
);

const fakeMeJson = {
  'wave': {'id': 'U1001', 'team_id': 'T1001', 'name': 'alex.taylor', 'real_name': 'Alex Taylor', 'tz': 'America/New_York'},
  'taskey': {'id': 'U0001', 'team_id': 'T0001', 'name': 'alex.taylor', 'real_name': 'Alex Taylor', 'tz': 'America/New_York'},
};
const fakeMembersJson = {
  'wave': [
    {
      "id": 'U1001',
      "team_id": "T1001",
      "name": "alex.taylor",
      "real_name": "Alex Taylor",
      "tz": "America/New_York",
      "profile": {
        "title": "Founder & CEO",
        "real_name": "Alex Taylor",
        "display_name": "Alex",
        "email": "alex.taylor@wave.example.com",
        "image_72": "https://azukhxinzrivjforwnsc.supabase.co/storage/v1/object/public/logo/U1001.jpeg",
      },
      "is_admin": true,
      "is_owner": true,
    },
    {
      "id": "U1002",
      "team_id": "T1001",
      "name": "olivia.green",
      "real_name": "Olivia Green",
      "tz": "America/Chicago",
      "profile": {
        "title": "COO",
        "real_name": "Olivia Green",
        "display_name": "Olivia",
        "email": "olivia.green@wave.example.com",
        "image_72": "https://azukhxinzrivjforwnsc.supabase.co/storage/v1/object/public/logo/U1002.jpeg",
      },
      "is_admin": true,
    },
    {
      "id": "U1003",
      "team_id": "T1001",
      "name": "ethan.clark",
      "real_name": "Ethan Clark",
      "tz": "America/Los_Angeles",
      "profile": {
        "title": "Backend Engineer",
        "real_name": "Ethan Clark",
        "display_name": "Ethan",
        "email": "ethan.clark@wave.example.com",
        "image_72": "https://azukhxinzrivjforwnsc.supabase.co/storage/v1/object/public/logo/U1003.jpeg",
      },
    },
    {
      "id": "U1004",
      "team_id": "T1001",
      "name": "sophia.martin",
      "real_name": "Sophia Martin",
      "tz": "America/New_York",
      "profile": {
        "title": "CTO",
        "real_name": "Sophia Martin",
        "display_name": "Sophia",
        "email": "sophia.martin@wave.example.com",
        "image_72": "https://azukhxinzrivjforwnsc.supabase.co/storage/v1/object/public/logo/U1004.jpeg",
      },
      "is_admin": true,
    },
    {
      "id": "U1005",
      "team_id": "T1001",
      "name": "daniel.harris",
      "real_name": "Daniel Harris",
      "tz": "America/Denver",
      "profile": {
        "title": "PM",
        "real_name": "Daniel Harris",
        "display_name": "Daniel",
        "email": "daniel.harris@wave.example.com",
        "image_72": "https://azukhxinzrivjforwnsc.supabase.co/storage/v1/object/public/logo/U1005.jpeg",
      },
    },
    {
      "id": "U1006",
      "team_id": "T1001",
      "name": "ava.thomas",
      "real_name": "Ava Thomas",
      "tz": "America/Los_Angeles",
      "profile": {
        "title": "Designer",
        "real_name": "Ava Thomas",
        "display_name": "Ava",
        "email": "ava.thomas@wave.example.com",
        "image_72": "https://azukhxinzrivjforwnsc.supabase.co/storage/v1/object/public/logo/U1006.jpeg",
      },
    },
    {
      "id": "U1007",
      "team_id": "T1001",
      "name": "liam.white",
      "real_name": "Liam White",
      "tz": "America/New_York",
      "profile": {
        "title": "Marketing",
        "real_name": "Liam White",
        "display_name": "Liam",
        "email": "liam.white@wave.example.com",
        "image_72": "https://azukhxinzrivjforwnsc.supabase.co/storage/v1/object/public/logo/U1007.jpeg",
      },
    },
    {
      "id": "U1008",
      "team_id": "T1001",
      "name": "wave-bot",
      "real_name": "Wave Bot",
      "tz": "UTC",
      "profile": {
        "title": "Automation Bot",
        "real_name": "Wave Bot",
        "display_name": "Wave Bot",
        "email": "bot@wave.example.com",
        "image_72": "https://azukhxinzrivjforwnsc.supabase.co/storage/v1/object/public/logo/wave.png",
      },
      "is_bot": true,
    },
  ],
  'taskey': [
    {
      "id": 'U0001',
      "team_id": "T0001",
      "name": "alex.taylor",
      "deleted": false,
      "real_name": "Alex Taylor",
      "tz": "America/New_York",
      "profile": {
        "title": "Founder & CEO",
        "real_name": "Alex Taylor",
        "display_name": "Alex",
        "email": "alex.taylor@example.com",
        "image_72": "https://azukhxinzrivjforwnsc.supabase.co/storage/v1/object/public/logo/U0001.jpeg",
      },
      "is_admin": true,
      "is_owner": true,
    },
    {
      "id": "U0002",
      "team_id": "T0001",
      "name": "jane.smith",
      "real_name": "Jane Smith",
      "tz": "America/Chicago",
      "profile": {
        "title": "COO",
        "real_name": "Jane Smith",
        "display_name": "Jane",
        "email": "jane.smith@example.com",
        "image_72": "https://azukhxinzrivjforwnsc.supabase.co/storage/v1/object/public/logo/U0002.jpeg",
      },
      "is_admin": true,
    },
    {
      "id": "U0003",
      "team_id": "T0001",
      "name": "michael.brown",
      "real_name": "Michael Brown",
      "tz": "America/Los_Angeles",
      "profile": {
        "title": "Backend Engineer",
        "real_name": "Michael Brown",
        "display_name": "Mike",
        "email": "mike.brown@example.com",
        "image_72": "https://azukhxinzrivjforwnsc.supabase.co/storage/v1/object/public/logo/U0003.jpeg",
      },
    },
    {
      "id": "U0004",
      "team_id": "T0001",
      "name": "emily.johnson",
      "real_name": "Emily Johnson",
      "tz": "America/New_York",
      "profile": {
        "title": "CTO",
        "real_name": "Emily Johnson",
        "display_name": "Emily",
        "email": "emily.johnson@example.com",
        "image_72": "https://azukhxinzrivjforwnsc.supabase.co/storage/v1/object/public/logo/U0004.jpeg",
      },
      "is_admin": true,
    },
    {
      "id": "U0005",
      "team_id": "T0001",
      "name": "david.wilson",
      "real_name": "David Wilson",
      "tz": "America/Denver",
      "profile": {
        "title": "PM",
        "real_name": "David Wilson",
        "display_name": "David",
        "email": "david.wilson@example.com",
        "image_72": "https://azukhxinzrivjforwnsc.supabase.co/storage/v1/object/public/logo/U0005.jpeg",
      },
    },
    {
      "id": "U0006",
      "team_id": "T0001",
      "name": "sarah.miller",
      "real_name": "Sarah Miller",
      "tz": "America/Los_Angeles",
      "profile": {
        "title": "Designer",
        "real_name": "Sarah Miller",
        "display_name": "Sarah",
        "email": "sarah.miller@example.com",
        "image_72": "https://azukhxinzrivjforwnsc.supabase.co/storage/v1/object/public/logo/U0006.jpeg",
      },
    },
    {
      "id": "U0007",
      "team_id": "T0001",
      "name": "chris.moore",
      "real_name": "Chris Moore",
      "tz": "America/New_York",
      "profile": {
        "title": "Marketing",
        "real_name": "Chris Moore",
        "display_name": "Chris",
        "email": "chris.moore@example.com",
        "image_72": "https://azukhxinzrivjforwnsc.supabase.co/storage/v1/object/public/logo/U0007.jpeg",
      },
    },
    {
      "id": "U0008",
      "team_id": "T0001",
      "name": "taskey-bot",
      "real_name": "Visir Bot",
      "tz": "UTC",
      "profile": {
        "title": "Automation Bot",
        "real_name": "Visir Bot",
        "display_name": "Visir Bot",
        "email": "bot@taskey.example.com",
        "image_72": "https://azukhxinzrivjforwnsc.supabase.co/storage/v1/object/public/logo/taskey.png",
      },
      "is_bot": true,
    },
  ],
};

const fakeChannelJson = {
  'wave': [
    {
      "id": "C1001",
      "name": "all-general",
      "is_channel": true,
      "is_group": false,
      "is_im": false,
      "created": 1695000000,
      "is_archived": false,
      "is_general": true,
      "creator": "U1001",
      "name_normalized": "general",
      "is_private": false,
      "is_mpim": false,
      "members": ["U1001", "U1002", "U1003", "U1004", "U1005", "U1006", "U1007", "U1008"],
      "topic": {"value": "Company-wide announcements", "creator": "U1001"},
      "purpose": {"value": "Everyone is here", "creator": "U1001"},
      "num_members": 8,
    },
    {
      "id": "C1002",
      "name": "all-random",
      "is_channel": true,
      "is_group": false,
      "is_im": false,
      "created": 1695003600,
      "is_archived": false,
      "creator": "U1002",
      "name_normalized": "random",
      "is_private": false,
      "is_mpim": false,
      "members": ["U1001", "U1002", "U1003", "U1005", "U1007"],
      "topic": {"value": "Casual banter and memes", "creator": "U1002"},
      "purpose": {"value": "Keep it light", "creator": "U1002"},
      "num_members": 5,
    },
    {
      "id": "C1003",
      "name": "wave-features",
      "is_channel": true,
      "is_group": false,
      "is_im": false,
      "created": 1695007200,
      "is_archived": false,
      "creator": "U1003",
      "name_normalized": "feature-updates",
      "is_private": false,
      "is_mpim": false,
      "members": ["U1001", "U1002", "U1003", "U1004", "U1006"],
      "topic": {"value": "Feature launches", "creator": "U1003"},
      "purpose": {"value": "Share release info", "creator": "U1003"},
      "num_members": 5,
    },
    {
      "id": "C1004",
      "name": "wave-support",
      "is_channel": true,
      "is_group": false,
      "is_im": false,
      "created": 1695010800,
      "is_archived": false,
      "creator": "U1004",
      "name_normalized": "support",
      "is_private": false,
      "is_mpim": false,
      "members": ["U1001", "U1003", "U1004", "U1006", "U1008"],
      "topic": {"value": "Customer tickets", "creator": "U1004"},
      "purpose": {"value": "Handle support requests", "creator": "U1004"},
      "num_members": 5,
    },
    {
      "id": "C1005",
      "name": "project-ocean",
      "is_channel": false,
      "is_group": true,
      "is_im": false,
      "created": 1695014400,
      "is_archived": false,
      "creator": "U1005",
      "name_normalized": "project-ocean",
      "is_private": true,
      "is_mpim": false,
      "members": ["U1001", "U1003", "U1005", "U1006"],
      "topic": {"value": "Ocean project planning", "creator": "U1005"},
      "purpose": {"value": "Discuss roadmap & deliverables", "creator": "U1005"},
      "num_members": 4,
    },
    {
      "id": "C1006",
      "name": "wave-leadership",
      "is_channel": false,
      "is_group": true,
      "is_im": false,
      "created": 1695018000,
      "is_archived": false,
      "creator": "U1001",
      "name_normalized": "leadership",
      "is_private": true,
      "is_mpim": false,
      "members": ["U1001", "U1002", "U1004"],
      "topic": {"value": "Leadership sync", "creator": "U1001"},
      "purpose": {"value": "Align exec decisions", "creator": "U1001"},
      "num_members": 3,
    },
    {
      "id": "G1001",
      "is_channel": false,
      "is_group": true,
      "is_im": false,
      "is_mpim": true,
      "created": 1695028800,
      "is_archived": false,
      "is_private": true,
      "members": ["U1001", "U1002", "U1006"],
    },
    {
      "id": "G1002",
      "is_channel": false,
      "is_group": true,
      "is_im": false,
      "is_mpim": true,
      "created": 1695032400,
      "is_archived": false,
      "is_private": true,
      "members": ["U1003", "U1004", "U1005"],
    },
    {
      "id": "D1001",
      "is_channel": false,
      "is_group": false,
      "is_im": true,
      "created": 1695021600,
      "is_archived": false,
      "user": "U1002", // Alex ↔ Olivia
    },
    {
      "id": "D1002",
      "is_channel": false,
      "is_group": false,
      "is_im": true,
      "created": 1695025200,
      "is_archived": false,
      "user": "U1003", // Alex ↔ Ethan
    },
    {
      "id": "D1003",
      "is_channel": false,
      "is_group": false,
      "is_im": true,
      "created": 1695028800,
      "is_archived": false,
      "user": "U1004", // Alex ↔ Sophia
    },
    {
      "id": "D1004",
      "is_channel": false,
      "is_group": false,
      "is_im": true,
      "created": 1695032400,
      "is_archived": false,
      "user": "U1005", // Alex ↔ Daniel
    },
    {
      "id": "D1005",
      "is_channel": false,
      "is_group": false,
      "is_im": true,
      "created": 1695036000,
      "is_archived": false,
      "user": "U1006", // Alex ↔ Ava
    },
  ],
  'taskey': [
    {
      "id": "C0001",
      "name": "general",
      "is_channel": true,
      "is_group": false,
      "is_im": false,
      "created": 1693478400,
      "is_archived": false,
      "is_general": true,
      "creator": "U0001",
      "name_normalized": "general",
      "is_private": false,
      "is_mpim": false,
      "members": ["U0001", "U0002", "U0003", "U0004", "U0005", "U0006", "U0007", "U0008"],
      "topic": {"value": "Company-wide announcements", "creator": "U0001"},
      "purpose": {"value": "Everyone is in this channel", "creator": "U0001"},
      "num_members": 8,
    },
    {
      "id": "C0002",
      "name": "random",
      "is_channel": true,
      "is_group": false,
      "is_im": false,
      "created": 1693564801,
      "is_archived": false,
      "is_general": false,
      "creator": "U0002",
      "name_normalized": "random",
      "is_private": false,
      "is_mpim": false,
      "members": ["U0001", "U0002", "U0003", "U0005", "U0007"],
      "topic": {"value": "Casual talk and memes", "creator": "U0002"},
      "purpose": {"value": "Keep it fun", "creator": "U0002"},
      "num_members": 5,
    },
    {
      "id": "C0003",
      "name": "product-announcements",
      "is_channel": true,
      "is_group": false,
      "is_im": false,
      "created": 1693651202,
      "is_archived": false,
      "creator": "U0003",
      "name_normalized": "product-announcements",
      "is_private": false,
      "is_mpim": false,
      "members": ["U0001", "U0002", "U0003", "U0004", "U0005", "U0006"],
      "topic": {"value": "Public product updates", "creator": "U0003"},
      "purpose": {"value": "Announce changes to the team", "creator": "U0003"},
      "num_members": 6,
    },
    {
      "id": "C0004",
      "name": "support",
      "is_channel": true,
      "is_group": false,
      "is_im": false,
      "created": 1693737603,
      "is_archived": false,
      "creator": "U0004",
      "name_normalized": "support",
      "is_private": false,
      "is_mpim": false,
      "members": ["U0001", "U0003", "U0004", "U0006", "U0008"],
      "topic": {"value": "Customer issues", "creator": "U0004"},
      "purpose": {"value": "Coordinate support responses", "creator": "U0004"},
      "num_members": 5,
    },
    {
      "id": "C0005",
      "name": "project-alpha",
      "is_channel": false,
      "is_group": true,
      "is_im": false,
      "created": 1693824004,
      "is_archived": false,
      "creator": "U0005",
      "name_normalized": "project-alpha",
      "is_private": true,
      "is_mpim": false,
      "members": ["U0001", "U0003", "U0004", "U0005"],
      "topic": {"value": "Internal project planning", "creator": "U0005"},
      "purpose": {"value": "Roadmap, blockers, deliverables", "creator": "U0005"},
      "num_members": 4,
    },
    {
      "id": "C0006",
      "name": "leadership",
      "is_channel": false,
      "is_group": true,
      "is_im": false,
      "created": 1693910405,
      "is_archived": false,
      "creator": "U0001",
      "name_normalized": "leadership",
      "is_private": true,
      "is_mpim": false,
      "members": ["U0001", "U0002", "U0004"],
      "topic": {"value": "Exec-only planning", "creator": "U0001"},
      "purpose": {"value": "Align leadership", "creator": "U0001"},
      "num_members": 3,
    },
    {
      "id": "G0001",
      "is_channel": false,
      "is_group": true,
      "is_im": false,
      "is_mpim": true,
      "created": 1694256008,
      "is_archived": false,
      "is_private": true,
      "members": ["U0001", "U0002", "U0006"],
    },
    {
      "id": "G0002",

      "is_channel": false,
      "is_group": true,
      "is_im": false,
      "is_mpim": true,
      "created": 1694332409,
      "is_archived": false,
      "is_private": true,
      "members": ["U0003", "U0004", "U0005"],
    },
    {
      "id": "D0001",
      "is_channel": false,
      "is_group": false,
      "is_im": true,
      "created": 1696001000,
      "is_archived": false,
      "user": "U0002", // Alex ↔ Jane
    },
    {
      "id": "D0002",
      "is_channel": false,
      "is_group": false,
      "is_im": true,
      "created": 1696002000,
      "is_archived": false,
      "user": "U0003", // Alex ↔ Michael
    },
    {
      "id": "D0003",
      "is_channel": false,
      "is_group": false,
      "is_im": true,
      "created": 1696003000,
      "is_archived": false,
      "user": "U0004", // Alex ↔ Emily
    },
    {
      "id": "D0004",
      "is_channel": false,
      "is_group": false,
      "is_im": true,
      "created": 1696004000,
      "is_archived": false,
      "user": "U0005", // Alex ↔ David
    },
    {
      "id": "D0005",
      "is_channel": false,
      "is_group": false,
      "is_im": true,
      "created": 1696005000,
      "is_archived": false,
      "user": "U0006", // Alex ↔ Sarah
    },
    {
      "id": "D0006",
      "is_channel": false,
      "is_group": false,
      "is_im": true,
      "created": 1696006000,
      "is_archived": false,
      "user": "U0007", // Alex ↔ Chris
    },
  ],
};
