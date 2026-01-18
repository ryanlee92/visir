import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/contextmenu/src/ContextMenuArea.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/auth/application/notification_controller.dart';
import 'package:Visir/features/auth/domain/entities/user_entity.dart';
import 'package:Visir/features/calendar/application/calendar_event_list_controller.dart';
import 'package:Visir/features/calendar/application/calendar_list_controller.dart';
import 'package:Visir/features/chat/application/chat_channel_list_controller.dart';
import 'package:Visir/features/chat/application/chat_list_controller.dart';
import 'package:Visir/features/chat/application/chat_thread_list_controller.dart';
import 'package:Visir/features/chat/domain/entities/message_channel_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_event_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_member_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_reaction_entity.dart';
import 'package:Visir/features/chat/domain/entities/slack/slack_message_entity.dart';
import 'package:Visir/features/chat/domain/entities/slack/slack_message_event_entity.dart';
import 'package:Visir/features/chat/providers.dart';
import 'package:Visir/features/common/domain/entities/update_entity.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/google_api_handler.dart';
import 'package:Visir/features/common/presentation/utils/log_event.dart';
import 'package:Visir/features/common/presentation/utils/microsoft_api_handler.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/desktop_scaffold.dart';
import 'package:Visir/features/common/presentation/widgets/fgbg_detector.dart';
import 'package:Visir/features/common/presentation/widgets/fixed_overlay_host.dart';
import 'package:Visir/features/common/presentation/widgets/mobile_scaffold.dart';
import 'package:Visir/features/common/presentation/widgets/subscription_done_widget.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/tutorial/app_first_open_popup.dart';
import 'package:Visir/features/common/presentation/widgets/tutorial/feature_tutorial_widget.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/inbox/application/inbox_config_controller.dart';
import 'package:Visir/features/inbox/application/inbox_controller.dart';
import 'package:Visir/features/inbox/providers.dart';
import 'package:Visir/features/mail/application/mail_label_list_controller.dart';
import 'package:Visir/features/mail/application/mail_list_controller.dart';
import 'package:Visir/features/mail/application/mail_thread_list_controller.dart';
import 'package:Visir/features/mail/domain/entities/mail_entity.dart';
import 'package:Visir/features/mail/domain/entities/mail_label_entity.dart';
import 'package:Visir/features/mail/infrastructure/datasources/remote/google_mail_datasource.dart';
import 'package:Visir/features/mail/presentation/screens/mail_edit_screen.dart';
import 'package:Visir/features/mail/presentation/widgets/html_scrollsync_viewport.dart';
import 'package:Visir/features/mail/presentation/widgets/mail_draft_list.dart';
import 'package:Visir/features/mail/providers.dart';
import 'package:Visir/features/preference/application/connection_list_controller.dart';
import 'package:Visir/features/preference/application/last_app_open_close_date_controller.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/domain/entities/local_pref_entity.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:Visir/features/task/application/calendar_task_list_controller.dart';
import 'package:Visir/features/task/application/project_list_controller.dart';
import 'package:Visir/features/task/application/task_list_controller.dart';
import 'package:Visir/features/time_saved/actions.dart';
import 'package:Visir/features/time_saved/application/total_user_action_switch_list_controller.dart';
import 'package:Visir/features/time_saved/application/user_action_switch_list_controller.dart';
import 'package:Visir/features/time_saved/application/user_last_action_controller.dart';
import 'package:Visir/features/time_saved/domain/entities/user_action_entity.dart';
import 'package:Visir/features/time_saved/domain/entities/user_action_switch_count_entity.dart';
import 'package:Visir/features/time_saved/presentation/widgets/time_saved_button.dart';
import 'package:Visir/features/time_saved/presentation/widgets/total_saving_popup.dart';
import 'package:auto_updater/auto_updater.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:emoji_extension/emoji_extension.dart' hide Color;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_confetti/flutter_confetti.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis/gmail/v1.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_launcher/url_launcher.dart';

class MainScreen extends ConsumerStatefulWidget {
  static const routeName = 'main';

  const MainScreen({super.key});

  @override
  ConsumerState createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  Timer? focusTimer;
  late StreamSubscription<List<ConnectivityResult>> connectivitySubscription;

  bool prevIsForeground = true;
  bool pendingSubscriptionDone = false;

  late double previousTotalSaved;

  // OAuth listener debounce 타이머
  Timer? _mailOAuthDebounceTimer;
  Timer? _messengerOAuthDebounceTimer;

  @override
  void initState() {
    super.initState();
    previousTotalSaved = ref.read(totalSavedTimeProvider);

    tabNotifier.addListener(() {
      UserActionSwtichAction.onSwtichTab(targetTab: tabNotifier.value);
    });

    Utils.initiateAudioplayer();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Navigator.of(context).popUntil((route) => route.isFirst);

      // 무거운 작업들을 백그라운드로 이동 (UI 블로킹 방지)
      unawaited(_initializeBackgroundServices());
    });

    connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      refreshDataIfListenerDetached(isFirst: false);
    });
  }

  /// 백그라운드에서 무거운 서비스들을 초기화 (UI 블로킹 방지)
  Future<void> _initializeBackgroundServices() async {
    if (ref.read(shouldUseMockDataProvider)) return;

    final user = ref.read(authControllerProvider).requireValue;

    // autoUpdater 설정 (Windows/macOS만)
    if (PlatformX.isWindows || PlatformX.isMacOS) {
      try {
        String feedURL = user.updateChannel == UpdateChannel.beta ? 'https://visir.pro/appcast-beta.xml' : 'https://visir.pro/appcast.xml';
        await autoUpdater.setFeedURL(feedURL);
        await autoUpdater.checkForUpdates(inBackground: true);
        await autoUpdater.setScheduledCheckInterval(3600);
      } catch (e) {
        // autoUpdater 실패는 앱 동작에 영향 없음
      }
    }

    // 메일 리스너 연결
    try {
      final result = await ref.read(mailLabelListControllerProvider.notifier).attachMailChangeListener();
      if (result != null) {
        ref.read(authControllerProvider.notifier).updateGmailHistoryId(result);
      }
    } catch (e) {
      // 메일 리스너 실패는 앱 동작에 영향 없음
    }

    // 메시지 리스너 연결
    try {
      ref.read(chatChannelListControllerProvider.notifier).attachMessageChangeListener();
    } catch (e) {
      // 메시지 리스너 실패는 앱 동작에 영향 없음
    }
  }

  @override
  void dispose() {
    _mailOAuthDebounceTimer?.cancel();
    _messengerOAuthDebounceTimer?.cancel();
    connectivitySubscription.cancel();
    focusTimer?.cancel();
    super.dispose();
  }

  bool get isSignedIn => ref.read(isSignedInProvider);

  bool oAuthNotWorkPopupShown = false;

  void setFocus() {
    focusTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      Utils.focusApp(doNotFocus: true);
    });
  }

  void clearFocus() {
    focusTimer?.cancel();
  }

  void onGcalChanged(String calendarId) {
    [TabType.home, TabType.calendar].forEach((tabType) {
      if (ref.exists(calendarEventListControllerProvider(tabType: tabType))) {
        ref.read(calendarEventListControllerProvider(tabType: tabType).notifier).refresh();
      }
    });
  }

  void onOutlookCalChanged(String eventId) async {
    [TabType.home, TabType.calendar].forEach((tabType) {
      if (ref.exists(calendarEventListControllerProvider(tabType: tabType))) {
        ref.read(calendarEventListControllerProvider(tabType: tabType).notifier).refresh();
      }
    });
  }

  void onOutlookMailChanged(String messageId, String email, String changeType) async {
    final tabTypes = [...TabType.values];

    final LocalPrefEntity? pref = ref.read(localPrefControllerProvider).value;

    final outlookOAuths = [...(pref!.mailOAuths ?? [])].where((element) => element.type == OAuthType.microsoft);
    final oauth = outlookOAuths.where((element) => element.email == email).firstOrNull;
    if (oauth == null) return;

    final mail = await ref.read(microsoftMailDatasourceProvider).getMail(oauth: oauth, token: AccessToken.fromJson(oauth.accessToken), email: email, messageId: messageId);

    final currentLabelId = (mail?.labelIds ?? []).where((e) => e != CommonMailLabels.pinned.id && e == CommonMailLabels.unread.id).firstOrNull;

    final addLabelIds = <String>[];
    final removeLabelIds = <String>[];

    if (mail == null) {
      if (changeType == 'deleted') {
        String? mailId = messageId;
        List<String> labelIds = [];
        ref.read(mailLabelListControllerProvider.notifier).removeMailLocal([TempMailEntity(id: mailId, labelIds: labelIds, hostEmail: email)]);
        ref.read(mailListControllerProvider.notifier).removeMailLocal([TempMailEntity(id: mailId, labelIds: labelIds, hostEmail: email)]);
        tabTypes.forEach((tabType) {
          if (ref.exists(mailThreadListControllerProvider(tabType: tabType))) {
            ref.read(mailThreadListControllerProvider(tabType: tabType).notifier).removeMailLocal(mailId);
          }
        });

        ref.read(inboxControllerProvider.notifier).removeMailInboxLocally(mailId);
      }
      return;
    }

    if (mail.msMessage?.isCreated == true) {
      ref.read(mailLabelListControllerProvider.notifier).addMailLocal([mail]);
      ref.read(mailListControllerProvider.notifier).addMailLocal([mail]);
      tabTypes.forEach((tabType) {
        if (ref.exists(mailThreadListControllerProvider(tabType: tabType))) {
          ref.read(mailThreadListControllerProvider(tabType: tabType).notifier).addMailLocal(mail);
        }
      });

      ref.read(inboxControllerProvider.notifier).upsertMailInboxLocally([mail]);
      return;
    }

    final visibleLabelId = ref.read(mailConditionProvider(TabType.mail).select((v) => v.label));

    if (changeType == 'deleted') {
      if (currentLabelId == null) return;
      if (currentLabelId == visibleLabelId) addLabelIds.add(currentLabelId);
      if (currentLabelId != visibleLabelId) removeLabelIds.add(visibleLabelId);
    } else if (changeType == 'created') {
      if (currentLabelId == null) return;
      addLabelIds.add(currentLabelId);
    } else if (changeType == 'updated') {
      final labelIds = mail.labelIds ?? [];
      if (labelIds.contains(CommonMailLabels.pinned.id)) {
        addLabelIds.add(CommonMailLabels.pinned.id);
      } else {
        removeLabelIds.add(CommonMailLabels.pinned.id);
      }
      if (labelIds.contains(CommonMailLabels.unread.id)) {
        addLabelIds.add(CommonMailLabels.unread.id);
      } else {
        removeLabelIds.add(CommonMailLabels.unread.id);
      }
    }

    ref.read(mailLabelListControllerProvider.notifier).addLabelsLocal([mail], addLabelIds);
    ref.read(mailListControllerProvider.notifier).addLabelsLocal([mail], addLabelIds);
    tabTypes.forEach((tabType) {
      if (ref.exists(mailThreadListControllerProvider(tabType: tabType))) {
        ref.read(mailThreadListControllerProvider(tabType: tabType).notifier).addLabelsLocal([mail.threadId!], addLabelIds);
      }
    });
    ref.read(inboxControllerProvider.notifier).upsertMailInboxLocally([mail]);

    ref.read(mailLabelListControllerProvider.notifier).removeLabelsLocal([mail], removeLabelIds);
    ref.read(mailListControllerProvider.notifier).removeLabelsLocal([mail], removeLabelIds);
    tabTypes.forEach((tabType) {
      if (ref.exists(mailThreadListControllerProvider(tabType: tabType))) {
        ref.read(mailThreadListControllerProvider(tabType: tabType).notifier).removeLabelsLocal([mail.threadId!], removeLabelIds);
      }
    });
    ref.read(inboxControllerProvider.notifier).upsertMailInboxLocally([mail]);
  }

  void onGmailChanged(String historyId, String email) async {
    final tabTypes = [...TabType.values];
    final LocalPrefEntity? pref = ref.read(localPrefControllerProvider).value;
    if (pref == null) return;

    final googleOAuths = [...(pref.mailOAuths ?? [])].where((element) => element.type == OAuthType.google);
    final oauth = googleOAuths.where((element) => element.email == email).firstOrNull;
    if (oauth == null) return;
    final clientId = await GoogleApiHandler.getClientId();
    final client = await GoogleApiHandler.getClient(oauth: oauth, scope: GoogleMailDatasource.scopes, clientId: clientId, isMail: true);
    final histories = await fetchHistories(client: client, historyId: historyId);

    for (final history in histories) {
      if (history.messagesAdded?.isNotEmpty == true) {
        for (final messageAdded in history.messagesAdded!) {
          final threads = await ref
              .read(googleMailDatasourceProvider)
              .fetchThreads(oauth: oauth, threadId: messageAdded.message!.threadId!, labelId: CommonMailLabels.inbox.id, email: email);
          MailEntity mail = threads.firstWhere((e) => e.id == messageAdded.message!.id).copyWith(threads: threads);

          if (messageAdded.message?.labelIds?.contains(CommonMailLabels.draft.id) == true) {
            final rfc822msgid = mail.gmailMessage?.payload?.headers?.firstWhereOrNull((element) => element.name?.toLowerCase() == 'message-id')?.value;
            final drafts = await GmailApi(client).users.drafts.list('me', q: 'rfc822msgid:${rfc822msgid}');
            final draft = drafts.drafts?.firstOrNull;
            if (draft == null) return;
            mail = mail.copyWith(draftId: draft.id);
          }

          ref.read(mailLabelListControllerProvider.notifier).addMailLocal([mail]);
          ref.read(mailListControllerProvider.notifier).addMailLocal([mail]);
          tabTypes.forEach((tabType) {
            if (ref.exists(mailThreadListControllerProvider(tabType: tabType))) {
              ref.read(mailThreadListControllerProvider(tabType: tabType).notifier).addMailLocal(mail);
            }
          });
          ref.read(inboxControllerProvider.notifier).upsertMailInboxLocally([mail]);
        }
      }

      if (history.messagesDeleted?.isNotEmpty == true) {
        for (final messageDeleted in history.messagesDeleted!) {
          String? mailId = messageDeleted.message?.id;
          List<String> labelIds = messageDeleted.message?.labelIds ?? [];
          if (mailId == null) return;

          ref.read(mailLabelListControllerProvider.notifier).removeMailLocal([TempMailEntity(id: mailId, labelIds: labelIds, hostEmail: email)]);
          ref.read(mailListControllerProvider.notifier).removeMailLocal([TempMailEntity(id: mailId, labelIds: labelIds, hostEmail: email)]);
          tabTypes.forEach((tabType) {
            if (ref.exists(mailThreadListControllerProvider(tabType: tabType))) {
              ref.read(mailThreadListControllerProvider(tabType: tabType).notifier).removeMailLocal(mailId);
            }
          });
          ref.read(inboxControllerProvider.notifier).removeMailInboxLocally(mailId);
        }
      }

      if (history.labelsAdded?.isNotEmpty == true) {
        for (final labelsAdded in history.labelsAdded!) {
          List<String> addLabelIds = labelsAdded.labelIds ?? [];

          final threads = await ref
              .read(googleMailDatasourceProvider)
              .fetchThreads(oauth: oauth, threadId: labelsAdded.message!.threadId!, labelId: CommonMailLabels.inbox.id, email: email);
          MailEntity mail = threads.firstWhere((e) => e.id == labelsAdded.message!.id).copyWith(threads: threads);

          if (labelsAdded.message?.labelIds?.contains(CommonMailLabels.draft.id) == true) {
            final rfc822msgid = mail.gmailMessage?.payload?.headers?.firstWhereOrNull((element) => element.name?.toLowerCase() == 'message-id')?.value;
            final drafts = await GmailApi(client).users.drafts.list('me', q: 'rfc822msgid:${rfc822msgid}');
            final draft = drafts.drafts?.firstOrNull;
            if (draft == null) return;
            mail = mail.copyWith(draftId: draft.id);
          }

          ref.read(mailLabelListControllerProvider.notifier).addLabelsLocal([mail], addLabelIds);
          ref.read(mailListControllerProvider.notifier).addLabelsLocal([mail], addLabelIds);
          tabTypes.forEach((tabType) {
            if (ref.exists(mailThreadListControllerProvider(tabType: tabType))) {
              ref.read(mailThreadListControllerProvider(tabType: tabType).notifier).addLabelsLocal([mail.threadId!], addLabelIds);
            }
          });
          ref.read(inboxControllerProvider.notifier).upsertMailInboxLocally([mail]);
        }
      }

      if (history.labelsRemoved?.isNotEmpty == true) {
        for (final labelsRemoved in history.labelsRemoved!) {
          List<String> removeLabelIds = labelsRemoved.labelIds ?? [];

          final threads = await ref
              .read(googleMailDatasourceProvider)
              .fetchThreads(oauth: oauth, threadId: labelsRemoved.message!.threadId!, labelId: CommonMailLabels.inbox.id, email: email);
          MailEntity mail = threads.firstWhere((e) => e.id == labelsRemoved.message!.id).copyWith(threads: threads);

          if (labelsRemoved.message?.labelIds?.contains(CommonMailLabels.draft.id) == true) {
            final rfc822msgid = mail.gmailMessage?.payload?.headers?.firstWhereOrNull((element) => element.name?.toLowerCase() == 'message-id')?.value;
            final drafts = await GmailApi(client).users.drafts.list('me', q: 'rfc822msgid:${rfc822msgid}');
            final draft = drafts.drafts?.firstOrNull;
            if (draft == null) return;
            mail = mail.copyWith(draftId: draft.id);
          }

          ref.read(mailLabelListControllerProvider.notifier).removeLabelsLocal([mail], removeLabelIds);
          ref.read(mailListControllerProvider.notifier).removeLabelsLocal([mail], removeLabelIds);
          tabTypes.forEach((tabType) {
            if (ref.exists(mailThreadListControllerProvider(tabType: tabType))) {
              ref.read(mailThreadListControllerProvider(tabType: tabType).notifier).removeLabelsLocal([mail.threadId!], removeLabelIds);
            }
          });
          ref.read(inboxControllerProvider.notifier).upsertMailInboxLocally([mail]);
        }
      }
    }
  }

  void onSlackChanged(MessageEventEntity event) async {
    final tabTypes = [...TabType.values];

    final channel = ref.read(chatChannelListControllerProvider.select((v) => v.values.expand((e) => e.channels).firstWhereOrNull((e) => e.id == event.channelId)));
    MessageChannelEntity? messageTabCurrentChannel = ref.read(chatConditionProvider(TabType.chat).select((v) => v.channel));

    final pref = ref.read(localPrefControllerProvider).value;
    final slackOAuths = pref?.messengerOAuths?.where((e) => e.type == OAuthType.slack);
    final slackOAuth = slackOAuths?.where((e) => e.teamId == channel?.teamId).firstOrNull;
    final members = ref.read(chatChannelListControllerProvider.select((v) => v[channel!.teamId]?.members));

    MessageMemberEntity? sender = members?.firstWhereOrNull((e) => e.id == event.userId);
    MessageMemberEntity? me = members?.firstWhereOrNull((e) => e.email == slackOAuth?.email);

    String teamId = event.teamId ?? channel?.teamId ?? '';
    if (teamId.isEmpty) return;

    if (me != null && sender != null && channel != null) {
      switch (event.slackEventEntityType) {
        case SlackMessageEventEntityType.message:
          switch (event.slackEventEntitySubtype) {
            case SlackMessageEntitySubtype.messageDeleted:
            case SlackMessageEntitySubtype.messageChanged:
              break;
            default:
              final message = event.getMessage(channel: channel);
              if (message == null) return;
              if (messageTabCurrentChannel?.id == channel.id) return;
              ref.read(chatChannelListControllerProvider.notifier).incrementChannelUnread(teamId: teamId, lastMessage: message, channel: channel);
              break;
          }
        default:
          break;
      }
    }

    if (pref != null) {
      if (event.slackEventEntityType == SlackMessageEventEntityType.message) {
        switch (event.slackEventEntitySubtype) {
          case SlackMessageEntitySubtype.messageDeleted:
          case SlackMessageEntitySubtype.messageChanged:
            break;
          default:
            if (event.userId == me?.id || messageTabCurrentChannel?.id == event.channelId) {
              ref.read(chatChannelListControllerProvider.notifier).setReadCursor(teamId: teamId, channelId: event.channelId!, lastReadAt: event.createdAt!);
            } else {
              ref.read(chatChannelListControllerProvider.notifier).setChannelUpdated(teamId: teamId, channelId: event.channelId!, lastUpdatedAt: event.createdAt!);
            }
            break;
        }
      }
    }

    if (channel?.meId != event.userId && channel != null) {
      switch (event.slackEventEntityType) {
        case SlackMessageEventEntityType.message:
          switch (event.slackEventEntitySubtype) {
            case SlackMessageEntitySubtype.messageDeleted:
              final messageId = event.messageId;
              if (messageId == null) return;
              ref.read(inboxControllerProvider.notifier).removeMessageInboxLocally(messageId);
              break;
            case SlackMessageEntitySubtype.messageChanged:
              final message = event.getMessage(channel: channel);
              if (message == null) return;
              ref.read(inboxControllerProvider.notifier).upsertMessageInboxLocally(message, channel);
              break;
            default:
              final message = event.getMessage(channel: channel);
              if (message == null) return;
              ref.read(inboxControllerProvider.notifier).upsertMessageInboxLocally(message, channel);
              break;
          }
        case SlackMessageEventEntityType.reactionAdded:
          break;
        case SlackMessageEventEntityType.reactionRemoved:
          break;
        case null:
          break;
      }
    }

    for (TabType tabType in tabTypes) {
      if (!ref.exists(chatListControllerProvider(tabType: tabType))) continue;
      MessageChannelEntity? currentChannel = ref.read(chatConditionProvider(tabType).select((v) => v.channel));
      if (currentChannel?.id != event.channelId) continue;
      if (currentChannel == null) continue;

      String? threadId = ref.read(chatConditionProvider(tabType).select((v) => v.threadId));
      final isCurrentThread = threadId != null && (event.threadId ?? event.previousThreadId) == threadId;

      switch (event.slackEventEntityType) {
        case SlackMessageEventEntityType.message:
          switch (event.slackEventEntitySubtype) {
            case SlackMessageEntitySubtype.messageDeleted:
              if (event.messageId == null) continue;
              if (event.threadId != null) {
                ref
                    .read(chatListControllerProvider(tabType: tabType).notifier)
                    .removeReplyLocally(replyId: event.previousMessageId!, replyUserId: event.userId!, messageId: event.previousThreadId!);
                if (!isCurrentThread) continue;
                ref.read(chatThreadListControllerProvider(tabType: tabType).notifier).deleteReplyLocally(id: event.previousMessageId!);
              } else {
                ref.read(chatListControllerProvider(tabType: tabType).notifier).deleteMessageLocally(id: event.previousThreadId!);
              }
              break;
            case SlackMessageEntitySubtype.messageChanged:
              if (event.messageId == null) continue;
              if (event.teamId == null) continue;
              if (event.channelId == null) continue;
              if (event.createdAt == null) continue;
              final message = event.getMessage(channel: currentChannel);
              if (message == null) continue;
              if (event.threadId != null) {
                if (!isCurrentThread) continue;
                ref.read(chatThreadListControllerProvider(tabType: tabType).notifier).updateReplyLocally(message: message);
              } else {
                ref.read(chatListControllerProvider(tabType: tabType).notifier).updateMessageLocally(message: message);
              }
              break;
            default:
              if (event.messageId == null) continue;
              if (event.teamId == null) continue;
              if (event.channelId == null) continue;
              if (event.createdAt == null) continue;
              final message = event.getMessage(channel: currentChannel);
              if (message == null) continue;
              if (event.threadId != null) {
                if (isCurrentThread) {
                  final result = ref.read(chatThreadListControllerProvider(tabType: tabType).notifier).updateReplyLocally(message: message);
                  if (result == true)
                    ref
                        .read(chatListControllerProvider(tabType: tabType).notifier)
                        .addReplyLocally(reply: message, messageId: event.threadId!, selfSent: false, threadOpened: true);
                } else {
                  ref.read(chatListControllerProvider(tabType: tabType).notifier).addReplyLocally(reply: message, messageId: event.threadId!, selfSent: false, threadOpened: false);
                }
              } else {
                ref.read(chatListControllerProvider(tabType: tabType).notifier).updateMessageLocally(message: message);
              }
              break;
          }
          break;
        case SlackMessageEventEntityType.reactionAdded:
          final reactionName = event.reaction;
          if (event.messageId == null) continue;
          if (reactionName == null) continue;
          if (event.threadId != null) {
            if (!isCurrentThread) continue;
            ref
                .read(chatThreadListControllerProvider(tabType: tabType).notifier)
                .addReactionLocally(messageId: event.messageId!, reactionType: MessageReactionEntityType.slack, reactionName: reactionName, userId: event.userId!);
          } else {
            ref
                .read(chatThreadListControllerProvider(tabType: tabType).notifier)
                .addReactionLocally(messageId: event.messageId!, reactionType: MessageReactionEntityType.slack, reactionName: reactionName, userId: event.userId!);
          }
          break;
        case SlackMessageEventEntityType.reactionRemoved:
          final reactionName = event.reaction;
          if (event.messageId == null) continue;
          if (reactionName == null) continue;
          if (event.threadId != null) {
            if (!isCurrentThread) continue;
            ref
                .read(chatThreadListControllerProvider(tabType: tabType).notifier)
                .removeReactionLocally(messageId: event.messageId!, reactionType: MessageReactionEntityType.slack, reactionName: reactionName, userId: event.userId!);
          } else {
            ref
                .read(chatThreadListControllerProvider(tabType: tabType).notifier)
                .removeReactionLocally(messageId: event.messageId!, reactionType: MessageReactionEntityType.slack, reactionName: reactionName, userId: event.userId!);
          }
          break;
        case null:
          break;
      }
    }
  }

  void checkPayloadThenAction() {
    final payload = notificationPayload;
    if (payload == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (payload['isHome'] != null) {
        tabNotifier.value = TabType.home;
        return;
      }

      switch (payload['type']) {
        case 'task':
          tabNotifier.value = TabType.home;
          break;
        case 'gcal':
          tabNotifier.value = TabType.home;
          break;
        case 'gmail':
          tabNotifier.value = TabType.mail;
          break;
        case 'slack':
          tabNotifier.value = TabType.chat;
          break;
      }
    });
  }

  void forceUpdateApp(UpdateEntity update) {
    if (PlatformX.isMacOS || PlatformX.isWindows) {
      autoUpdater.checkForUpdates(inBackground: false);
    } else if (PlatformX.isWeb) {
      html.window.location.reload();
    } else {
      launchUrl(Uri.parse(update.link ?? ''));
    }
  }

  void refreshDataIfListenerDetached({bool isFirst = false}) async {
    final isSignedIn = ref.read(authControllerProvider.select((value) => value.requireValue.isSignedIn));
    if (!isSignedIn) return;

    if (ref.read(authControllerProvider.notifier).isNotiListenerConnected != true) {
      final deviceId = ref.read(deviceIdProvider).value;
      if (deviceId != null) ref.read(authControllerProvider.notifier).attachNotiChannelListener(deviceId: deviceId);
    }

    if (ref.read(authControllerProvider.notifier).isUserListenerConnected != true) {
      ref
          .read(authControllerProvider.notifier)
          .attachUserChannelListener(
            onGcalChanged: onGcalChanged,
            onGmailChanged: onGmailChanged,
            onSlackChanged: onSlackChanged,
            onOutlookMailChanged: onOutlookMailChanged,
            onOutlookCalChanged: onOutlookCalChanged,
            onUpdateTask: (task) {
              ref.read(taskListControllerProvider.notifier).onUpdateTask(task);
              [TabType.home, TabType.calendar].forEach((tabType) {
                if (ref.exists(calendarTaskListControllerProvider(tabType: tabType))) {
                  ref.read(calendarTaskListControllerProvider(tabType: tabType).notifier).onUpdateTask(task);
                }
              });
            },
            onDeleteTask: (taskId) {
              ref.read(taskListControllerProvider.notifier).onDeleteTask(taskId);
              [TabType.home, TabType.calendar].forEach((tabType) {
                if (ref.exists(calendarTaskListControllerProvider(tabType: tabType))) {
                  ref.read(calendarTaskListControllerProvider(tabType: tabType).notifier).onDeleteTask(taskId);
                }
              });
            },
            onUpdateMessageUnread: (unread) {
              ref.read(chatChannelListControllerProvider.notifier).setChannelRead(teamId: unread.teamId, channelId: unread.channelId, lastReadAt: unread.lastMessageUserReadAt);
            },
            onUpdateInboxConfig: (config) {
              final date = ref.read(inboxListDateProvider);
              final isSignedIn = ref.read(authControllerProvider.select((v) => v.requireValue.isSignedIn));
              ref
                  .read(inboxConfigListControllerProvider(isSearch: false, year: date.year, month: date.month, day: date.day, isSignedIn: isSignedIn).notifier)
                  .updateInboxConfig(configs: [config], onlyLocal: true);
            },
            onDeleteInboxConfig: (configId) => {},
          );

      if (isFirst) return;

      // 세션 새로고침을 백그라운드로 이동
      unawaited(ref.read(authControllerProvider.notifier).refreshSession());

      // 데이터 새로고침을 백그라운드로 이동 (UI 블로킹 방지)
      unawaited(_refreshDataInBackground());
    }
  }

  /// 백그라운드에서 데이터를 새로고침 - 현재 탭 우선 (UI 블로킹 방지)
  Future<void> _refreshDataInBackground() async {
    try {
      final currentTab = tabNotifier.value;

      // 1순위: 현재 탭 즉시 로드
      await _refreshCurrentTab(currentTab);

      // 2순위: inbox (모든 탭에서 자주 참조)
      await Future.delayed(Duration(milliseconds: 100));
      ref.read(inboxControllerProvider.notifier).refresh();

      // 3순위: 나머지 탭들 순차 로드 (각 100ms 간격)
      await Future.delayed(Duration(milliseconds: 100));
      await _refreshOtherTabs(currentTab);
    } catch (e) {
      // 데이터 새로고침 실패는 앱 동작에 영향 없음
    }
  }

  Future<void> _refreshCurrentTab(TabType currentTab) async {
    switch (currentTab) {
      case TabType.home:
        // Home은 inbox와 함께 처리
        break;
      case TabType.task:
        ref.read(taskListControllerProvider.notifier).refresh();
        break;
      case TabType.mail:
        ref.read(mailLabelListControllerProvider.notifier).load(mergeNegativeBadge: true);
        ref.read(mailListControllerProvider.notifier).loadRecent();
        ref.read(mailThreadListControllerProvider(tabType: TabType.mail).notifier).loadThread();
        break;
      case TabType.chat:
        ref.read(chatListControllerProvider(tabType: TabType.chat).notifier).loadRecent();
        ref.read(chatThreadListControllerProvider(tabType: TabType.chat).notifier).load(isRefresh: true);
        break;
      case TabType.calendar:
        await ref.read(calendarListControllerProvider.notifier).load();
        break;
    }
  }

  Future<void> _refreshOtherTabs(TabType currentTab) async {
    // task (현재 탭이 아니면)
    if (currentTab != TabType.task) {
      await Future.delayed(Duration(milliseconds: 100));
      ref.read(taskListControllerProvider.notifier).refresh();
    }

    // calendar (현재 탭이 아니면)
    if (currentTab != TabType.calendar) {
      await Future.delayed(Duration(milliseconds: 100));
      ref.read(calendarListControllerProvider.notifier).load();
    }

    // mail (현재 탭이 아니면)
    if (currentTab != TabType.mail) {
      await Future.delayed(Duration(milliseconds: 100));
      if (currentTab != TabType.task) {
        ref.read(mailLabelListControllerProvider.notifier).load(mergeNegativeBadge: true);
      }
      ref.read(mailListControllerProvider.notifier).loadRecent();
      [...TabType.values].forEach((type) {
        if (ref.exists(mailThreadListControllerProvider(tabType: type))) {
          ref.read(mailThreadListControllerProvider(tabType: type).notifier).loadThread();
        }
      });
    }

    // message (현재 탭이 아니면)
    if (currentTab != TabType.chat) {
      await Future.delayed(Duration(milliseconds: 100));
      [...TabType.values].forEach((type) {
        if (ref.exists(chatListControllerProvider(tabType: type))) {
          ref.read(chatListControllerProvider(tabType: type).notifier).loadRecent();
        }
        if (ref.exists(chatThreadListControllerProvider(tabType: type))) {
          ref.read(chatThreadListControllerProvider(tabType: type).notifier).load(isRefresh: true);
        }
      });
    }
  }

  /// 백그라운드에서 API 연결을 체크 (UI 블로킹 방지)
  Future<void> _checkApiConnectionsInBackground() async {
    try {
      GoogleApiHandler.getConnections(ref);
      MicrosoftApiHandler.getConnections(ref);
    } catch (e) {
      // API 연결 체크 실패는 앱 동작에 영향 없음
    }
  }

  void showSubscriptionDone() {
    Navigator.of(Utils.mainContext).popUntil((route) => route.isFirst);

    Confetti.launch(
      context,
      options: const ConfettiOptions(
        particleCount: 300,
        angle: 90,
        spread: 360,
        startVelocity: 30,
        decay: 0.90,
        gravity: 0.8,
        drift: 0,
        flat: false,
        ticks: 300,
        scalar: 1.0,
        x: 0.5,
        y: 0.3,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Utils.setMainContext(context, ref: ref);

    final prefExists = ref.watch(localPrefControllerProvider.select((value) => value.value != null));
    if (!prefExists) {
      return SizedBox.shrink();
    }

    final mailOAuthsLength = ref.watch(localPrefControllerProvider.select((value) => value.value?.mailOAuths?.length ?? 0));

    // 빈 리스너들 제거 - 실제로 필요한 리스너만 유지
    ref.listen(localPrefControllerProvider, (previous, next) {});
    ref.listen(projectListControllerProvider, (prev, next) {});
    ref.listen(mailListControllerProvider, (previous, next) {});
    ref.listen(mailLabelListControllerProvider, (previous, next) {});
    ref.listen(taskListControllerProvider, (previous, next) {});
    ref.listen(chatChannelListControllerProvider, (previous, next) {
      ref.read(notificationControllerProvider.notifier).updateLinkedSlackTeam(Map.fromEntries(next.entries.map((e) => MapEntry(e.key, e.value.channels))));
    });
    ref.listen(calendarEventListControllerProvider(tabType: TabType.home), (previous, next) {});
    ref.listen(calendarTaskListControllerProvider(tabType: TabType.home), (previous, next) {});
    if (!PlatformX.isMobileView) ref.listen(calendarEventListControllerProvider(tabType: TabType.calendar), (previous, next) {});
    ref.listen(connectionListControllerProvider, (previous, next) {});
    ref.listen(authControllerProvider, (previous, next) {
      if (next.requireValue.isSignedIn) {
        bool prevOnSubscription = previous?.requireValue.onSubscription ?? false;
        bool nextOnSubscription = next.requireValue.onSubscription;
        if (!prevOnSubscription && nextOnSubscription) {
          pendingSubscriptionDone = true;
        }
      }
    });

    final isSignedIn = ref.watch(authControllerProvider.select((value) => value.requireValue.isSignedIn));
    if (isSignedIn) {
      ref.listen(notificationControllerProvider, (previous, next) {
        if (jsonEncode(previous?.value?.outlookMailServerCode) != jsonEncode(next.value?.outlookMailServerCode)) {
          final outlookMailServerCode = next.value?.outlookMailServerCode;
          final pref = ref.read(localPrefControllerProvider).value;
          final currentMailOAuths = [...(pref?.mailOAuths ?? [])];
          outlookMailServerCode?.forEach((key, value) {
            final serverCode = value is String ? jsonDecode(value) : value;
            if (serverCode != null) {
              final serverAccessToken = AccessToken.fromJson(serverCode['accessToken']);
              final serverRefreshToken = serverCode['refreshToken'];

              final currentOutlookMailOAuth = currentMailOAuths.where((e) => e.email == key && e.type == OAuthType.microsoft).firstOrNull;
              currentMailOAuths.removeWhere((e) => e.email == key && e.type == OAuthType.microsoft);

              if (currentOutlookMailOAuth != null) {
                final currentAccessToken = AccessToken.fromJson(currentOutlookMailOAuth.accessToken);
                final currentRefreshToken = currentOutlookMailOAuth.refreshToken;

                if (serverAccessToken.data != currentAccessToken.data && serverRefreshToken != currentRefreshToken) {
                  final newOAuth = currentOutlookMailOAuth.copyWith(
                    accessToken: serverAccessToken.toJson(),
                    refreshToken: serverRefreshToken,
                    serverCode: jsonEncode({'accessToken': serverAccessToken.toJson(), 'refreshToken': serverRefreshToken}),
                  );
                  ref.read(localPrefControllerProvider.notifier).set(mailOAuths: [...currentMailOAuths, newOAuth]);
                }
              }
            }
          });
        }
      });

      ref.listen(localPrefControllerProvider, (previous, next) {
        if (previous?.value?.notificationPayload != next.value?.notificationPayload) {
          checkPayloadThenAction();
        }

        if (previous?.value?.mailOAuths?.length != next.value?.mailOAuths?.length) {
          // 2초 debounce로 빈번한 OAuth 변경 시 중복 API 호출 방지
          _mailOAuthDebounceTimer?.cancel();
          _mailOAuthDebounceTimer = Timer(const Duration(seconds: 2), () {
            if (ref.read(shouldUseMockDataProvider)) return;
            ref.read(mailLabelListControllerProvider.notifier).attachMailChangeListener().then((r) {
              if (r != null) ref.read(authControllerProvider.notifier).updateGmailHistoryId(r);
            });
          });
        }

        if (previous?.value?.messengerOAuths?.length != next.value?.messengerOAuths?.length) {
          // 2초 debounce
          _messengerOAuthDebounceTimer?.cancel();
          _messengerOAuthDebounceTimer = Timer(const Duration(seconds: 2), () {
            if (ref.read(shouldUseMockDataProvider)) return;
            ref.read(chatChannelListControllerProvider.notifier).attachMessageChangeListener();
          });
        }
      });

      ref.listen(calendarListControllerProvider, (previous, next) {
        if (previous != next && !ref.read(shouldUseMockDataProvider)) {
          ref.read(calendarListControllerProvider.notifier).attachCalendarChangeListener();
        }
      });

      ref.listen(totalUserActionSwitchListControllerProvider, (previous, next) {
        if (previous == null) return;

        if (next.value != null && previous.value != null) {
          final pref = ref.read(localPrefControllerProvider).value;
          if (pref == null) return;

          double hourlyWage = ref.read(hourlyWageProvider);

          double previousTotalSavedMoney = previousTotalSaved * hourlyWage;
          double nextTotalSaved = next.value?.userActions.totalWastedTime ?? 0;
          double nextTotalSavedMoney = nextTotalSaved * hourlyWage;

          bool showPopup = Constants.moneySavedMilestones.any((standard) => standard > previousTotalSavedMoney && standard <= nextTotalSavedMoney);
          previousTotalSaved = nextTotalSaved;

          EasyDebounce.debounce('total_user_action_switch_list_controller_provider', const Duration(seconds: 1), () {
            ref.read(totalSavedTimeProvider.notifier).update(nextTotalSaved);
          });

          if (previousTotalSavedMoney != 0 && showPopup) {
            if (PlatformX.isDesktopView) {
              final timeSavedButtonOffset = Constants.timeSavedButtonKey.currentState?.getOffset();
              final buttonRect = Constants.timeSavedButtonKey.currentState?.getRect();

              if (timeSavedButtonOffset == null || buttonRect == null) return;

              showContextMenu(
                topLeft: Offset(timeSavedButtonOffset.dx, timeSavedButtonOffset.dy + buttonRect.height + 2),
                bottomRight: Offset(timeSavedButtonOffset.dx + buttonRect.width, timeSavedButtonOffset.dy + buttonRect.height + 2 + 38),
                context: context,
                child: TotalSavingPopup(),
                verticalPadding: 0,
                borderRadius: 8,
                width: 380,
                backgroundColor: Colors.transparent,
                clipBehavior: Clip.none,
                isPopupMenu: false,
                hideShadow: true,
              );
            }
          }
        }
      });

      ref.listen(userLastActionControllerProvider, (previous, next) {
        if (next.value != null) {
          if (previous?.value?.id != next.value?.id) {
            final lastActionOnThisDevice = ref.read(defaultUserActionSwitchListControllerProvider.notifier).lastAction;
            if (next.value?.id != lastActionOnThisDevice?.id) {
              ref.read(defaultUserActionSwitchListControllerProvider.notifier).saveUserActionSwtich(nextAction: next.value!, prevAction: previous?.value);
            }

            if (previous?.value != null && next.value != null) {
              if (previous?.value?.typeWithIdentifier != next.value?.typeWithIdentifier) {
                if (PlatformX.isDesktop) {
                  ref.read(appTransitionAnimationControllerProvider.notifier).triggerAnimation(prevAction: previous!.value!, nextAction: next.value!);
                }

                final count = ref.read(defaultUserActionSwitchListControllerProvider.notifier).appSwitchingCount;
                final timeSavedTutorialDone = ref.read(authControllerProvider).requireValue.timeSavedTutorialDone;

                if (count > 5 && !timeSavedTutorialDone) {
                  if (PlatformX.isDesktopView) {
                    final timeSavedButtonOffset = Constants.timeSavedButtonKey.currentState?.getOffset();
                    final buttonRect = Constants.timeSavedButtonKey.currentState?.getRect();

                    if (timeSavedButtonOffset == null || buttonRect == null) return;

                    showContextMenu(
                      topLeft: Offset(timeSavedButtonOffset.dx, timeSavedButtonOffset.dy + buttonRect.height + 2),
                      bottomRight: Offset(timeSavedButtonOffset.dx + buttonRect.width, timeSavedButtonOffset.dy + buttonRect.height + 2 + 38),
                      context: context,
                      child: FeatureTutorialWidget(type: FeatureTutorialType.timeSaved),
                      verticalPadding: 0,
                      borderRadius: 8,
                      width: 232,
                      backgroundColor: Colors.transparent,
                      clipBehavior: Clip.none,
                      isPopupMenu: false,
                      hideShadow: true,
                    );
                  } else if (PlatformX.isMobileView) {
                    Utils.showPopupDialog(
                      child: FeatureTutorialWidget(type: FeatureTutorialType.timeSaved),
                      size: Size(300, 0),
                      forcePopup: true,
                      barrierDismissible: true,
                      isFlexibleHeightPopup: true,
                    );
                  }
                }
              }
            }
          }
        }
      });
    }

    final tabTypes = [
      TabType.home,
      TabType.calendar,
      TabType.task,
      TabType.mail,
      TabType.chat,
    ].where((e) => ref.watch(isSignedInProvider) ? !ref.watch(tabHiddenProvider(e)) : true).toList();
    return FixedOverlayHost(
      overlayKey: MainScreen.routeName,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: context.brightness == Brightness.dark ? SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent) : SystemUiOverlayStyle.dark,
        child: FGBGDetector(
          onChanged: (isForeground, isFirst) async {
            if (!mounted) return;
            updateAppBadge(0);
            Utils.ref.read(authControllerProvider.notifier).clearBadge();

            if (isForeground && PlatformX.isMobileView) {
              FocusManager.instance.primaryFocus?.unfocus();
            }

            if (isForeground && isFirst && isSignedIn) {
              // API 연결 체크를 백그라운드로 이동
              _checkApiConnectionsInBackground();
            }

            if (isForeground) {
              prevIsForeground = true;
              final user = Utils.ref.read(authControllerProvider).requireValue;
              logAnalyticsEvent(eventName: user.onTrial ? 'trial_app_foreground' : 'app_foreground');

              // 앱이 열릴 때 날짜 저장 (정확한 시간 저장) - 빌드 완료 후 실행
              if (isSignedIn && isFirst) {
                Future(() {
                  Utils.ref.read(lastAppOpenCloseDateControllerNotifierProvider).set(DateTime.now());
                });
              }

              Utils.focusApp(forceReset: true);

              WidgetsBinding.instance.addPostFrameCallback((_) async {
                setFocus();

                checkPayloadThenAction();

                // 데이터 새로고침을 백그라운드로 이동
                refreshDataIfListenerDetached(isFirst: isFirst);

                // 구독 완료 팝업이 대기 중이면 실행
                if (pendingSubscriptionDone && isSignedIn) {
                  pendingSubscriptionDone = false;
                  showSubscriptionDone();
                  logAnalyticsEvent(eventName: 'subscribe_success');
                }
              });
            } else {
              if (!prevIsForeground) return;
              prevIsForeground = false;
              notificationPayload = null;
              logAnalyticsEvent(eventName: 'app_background');
              clearFocus();
            }
          },
          child: Stack(
            children: [
              ...[...TabType.values].map(
                (e) => Positioned(
                  top: 0,
                  left: 0,
                  width: 1,
                  height: 1,
                  child: ValueListenableBuilder(
                    valueListenable: mailViewportSyncVisibleNotifier[e] ?? ValueNotifier(false),
                    builder: (context, visible, child) {
                      return !visible && mailOAuthsLength > 0
                          ? Offstage(
                              child: HtmlViewportSync(
                                tabType: null,
                                key: mailViewportSyncKey[e],
                                html: 'about:blank',
                                scrollController: ScrollController(),
                                viewportHeight: 1,
                                width: context.width,
                              ),
                            )
                          : SizedBox.shrink();
                    },
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                width: 1,
                height: 1,
                child: ValueListenableBuilder(
                  valueListenable: mailEditScreenVisibleNotifier,
                  builder: (context, visible, child) {
                    return !visible && mailOAuthsLength > 0
                        ? Offstage(
                            child: MailEditScreen(key: mailEditScreenKey, bodyHtml: 'about:blank'),
                          )
                        : SizedBox.shrink();
                  },
                ),
              ),
              if (PlatformX.isDesktopView)
                Positioned.fill(
                  child: Material(
                    child: TextFormField(focusNode: Utils.mainFocus, keyboardType: TextInputType.none),
                  ),
                ),
              Positioned.fill(
                child: PlatformX.isDesktopView ? DesktopScaffold(desktopTabValues: tabTypes) : MobileScaffold(mobileTabValues: tabTypes),
              ),
              FutureBuilder(
                future: PlatformX.isWindows ? WebViewEnvironment.getAvailableVersion() : Future.value(''),
                builder: (context, snapshot) {
                  final availableVersion = snapshot.data;
                  final needWebView2 = snapshot.connectionState == ConnectionState.done && PlatformX.isWindows && availableVersion == null;
                  return StreamBuilder(
                    stream: ref.watch(supabaseProvider).value?.client.from('global_config').stream(primaryKey: ['id']),
                    builder: (context, snapshot) {
                      final configs = snapshot.data ?? [];
                      final minimumVersionData = configs.where((e) => e['id'] == 'update').firstOrNull?['json_value'] ?? Map<String, dynamic>.from({});
                      final minimumVersion = UpdateEntity.fromJson(minimumVersionData);
                      final currentBuildNumber = ref.watch(packageInfoProvider).value?.buildNumber;

                      if ((currentBuildNumber != null && minimumVersion.minimumBuild != null && int.parse(currentBuildNumber) < minimumVersion.minimumBuild!) || needWebView2)
                        return Positioned.fill(
                          child: Container(
                            color: Colors.black.withAlpha(127),
                            child: Center(
                              child: Container(
                                width: min(320, context.width - 72),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                                clipBehavior: Clip.antiAlias,
                                decoration: ShapeDecoration(
                                  color: context.surface,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  shadows: [BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 12, offset: Offset(0, 4), spreadRadius: 0)],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: double.infinity,
                                            child: Text(
                                              needWebView2 ? context.tr.webview2_required_title : context.tr.update_required_title,
                                              textAlign: TextAlign.center,
                                              style: context.titleMedium?.textColor(context.onBackground).textBold,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          SizedBox(
                                            width: double.infinity,
                                            child: Text(
                                              needWebView2 ? context.tr.webview2_required_body : context.tr.update_required_body,
                                              textAlign: TextAlign.center,
                                              style: context.titleSmall?.textColor(context.onInverseSurface),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    VisirButton(
                                      type: VisirButtonAnimationType.scaleAndOpacity,
                                      style: VisirButtonStyle(
                                        cursor: SystemMouseCursors.click,
                                        width: double.infinity,
                                        height: 36,
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                        backgroundColor: context.primary,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      onTap: () => needWebView2
                                          ? launchUrl(Uri.parse('https://developer.microsoft.com/en-us/microsoft-edge/webview2/?form=MA13LH'))
                                          : forceUpdateApp(minimumVersion),
                                      child: Text(
                                        needWebView2 ? context.tr.webview2_required_button : context.tr.update_required_button,
                                        textAlign: TextAlign.center,
                                        style: context.titleSmall?.textColor(context.onPrimary),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      return SizedBox.shrink();
                    },
                  );
                },
              ),
              if (PlatformX.isDesktopView)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: ValueListenableBuilder(
                    valueListenable: mailInputDraftEditListener,
                    builder: (context, mailEditScreen, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          MailDraftList(),
                          if (mailEditScreen == null) SizedBox(width: 24),
                          if (mailEditScreen != null) SizedBox(width: 12),
                          if (mailEditScreen != null) SizedBox(width: min(context.width - 264, 660)),
                        ],
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
