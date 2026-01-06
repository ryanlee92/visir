import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:Visir/config/providers.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/auth/domain/entities/notification_entity.dart';
import 'package:Visir/features/auth/domain/entities/user_entity.dart';
import 'package:Visir/features/auth/infrastructure/repositories/auth_repository.dart';
import 'package:Visir/features/auth/providers.dart';
import 'package:Visir/features/calendar/application/calendar_list_controller.dart';
import 'package:Visir/features/calendar/domain/entities/calendar_entity.dart';
import 'package:Visir/features/calendar/providers.dart';
import 'package:Visir/features/chat/domain/entities/message_channel_entity.dart';
import 'package:Visir/features/chat/providers.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/log_event.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/mail/domain/entities/mail_label_entity.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/domain/entities/local_pref_entity.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:emoji_extension/emoji_extension.dart' hide Platform;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/experimental/persist.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis/gmail/v1.dart' as Gmail;
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:windows_taskbar/windows_taskbar.dart';

part 'notification_controller.g.dart';

final localNotificationPlugin = FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> notificationTapBackground(NotificationResponse notificationResponse) async {
  onLocalNotificationTapped(notificationResponse, null);
}

@pragma('vm:entry-point')
Future<void> onNotificationBackground(RemoteMessage message) async {
  Utils.insertInboxWidgetDataFromNotification(message: message);
  final data = message.data;
  if (data['badge'] is int) {
    await updateAppBadge(data['badge']);
  }
}

Future<void> onLocalNotificationTapped(NotificationResponse response, Ref? ref) async {
  final providerContainer = ProviderContainer();
  LocalPrefEntity? localPref = ref?.read(localPrefControllerProvider).value ?? providerContainer.read(localPrefControllerProvider).value;
  if (localPref == null) await Future.delayed(Duration(milliseconds: 1000));
  localPref = ref?.read(localPrefControllerProvider).requireValue ?? providerContainer.read(localPrefControllerProvider).requireValue;

  final payload = response.payload == null ? null : (jsonDecode(response.payload!) as Map<String, dynamic>).map((key, value) => MapEntry(key, value.toString()));
  notificationPayload = payload;
  if (ref == null) {
    await providerContainer.read(localPrefControllerProvider.notifier).set(notificationPayload: payload);
  } else {
    await ref.read(localPrefControllerProvider.notifier).set(notificationPayload: payload);
  }

  appWindow.show();

  switch (payload?['type']) {
    case 'slack':
      logAnalyticsEvent(eventName: 'notification_slack');
      break;
    case 'task':
      logAnalyticsEvent(eventName: 'notification_task');
      break;
    case 'gcal':
      logAnalyticsEvent(eventName: 'notification_google_calendar');
      break;
    case 'gmail':
      logAnalyticsEvent(eventName: 'notification_gmail');
      break;
  }
}

Future<void> onRemoteNotificationTapped(Map<String, dynamic> data) async {
  if (data['type'] == 'slack_notification') {
    String? threadId = data['thread_id'];
    String messageId = data['event_id'];
    String channelId = data['channel_id'];

    notificationPayload = {'type': 'slack', 'channelId': channelId.toUpperCase(), 'messageId': messageId, 'threadId': threadId ?? ''};
    logAnalyticsEvent(eventName: 'notification_slack');
  } else if (data['type'] == 'calendar_reminder') {
    final reminder = jsonDecode(data['reminder']);
    String type = 'task';
    switch (reminder['provider']) {
      case 'google':
        type = 'gcal';
        break;
    }
    notificationPayload = {'type': type, 'eventId': reminder['event_id'], 'date': reminder['date'].toString()};
    if (type == 'task') logAnalyticsEvent(eventName: 'notification_task');
    if (type == 'gcal') logAnalyticsEvent(eventName: 'notification_google_calendar');
  } else if (data['type'] == 'gmail_notification') {
    notificationPayload = {'type': 'gmail', 'threadId': data['threadId'], 'mailId': data['messageId']};
    logAnalyticsEvent(eventName: 'notification_gmail');
  }

  await Utils.ref.read(localPrefControllerProvider.notifier).set(notificationPayload: notificationPayload);
}

bool isLocalNotificationInitialized = false;

final notificationControllerProvider = Provider.autoDispose<AsyncValue<NotificationEntity?>>((ref) {
  final isSignedIn = ref.watch(authControllerProvider.select((v) => v.requireValue.isSignedIn));
  return ref.watch(notificationControllerInternalProvider(isSignedIn: isSignedIn));
});

final _notificationControllerNotifierProvider = Provider.autoDispose<NotificationControllerInternal>((ref) {
  final isSignedIn = ref.watch(authControllerProvider.select((v) => v.requireValue.isSignedIn));
  return ref.watch(notificationControllerInternalProvider(isSignedIn: isSignedIn).notifier);
});

extension NotificationControllerProviderX on ProviderListenable<AsyncValue<NotificationEntity?>> {
  ProviderListenable<NotificationControllerInternal> get notifier => _notificationControllerNotifierProvider;
}

@riverpod
class NotificationControllerInternal extends _$NotificationControllerInternal {
  late AuthRepository repository;

  final _recievedMessages = <String>[];
  String? apns;
  String? userId;

  Map<String, List<CalendarEntity>>? calendarMap;

  @override
  Future<NotificationEntity?> build({required bool isSignedIn}) async {
    repository = ref.watch(authRepositoryProvider);
    userId = ref.watch(authControllerProvider.select((v) => v.requireValue.id));
    ref.listen(calendarListControllerProvider, (prev, next) {
      calendarMap = next;
      _updateNotification(useDefaultFcmToken: true);
    });

    if (ref.watch(shouldUseMockDataProvider)) return null;
    final deviceId = ref.read(deviceIdProvider).asData?.value;
    if (deviceId?.isNotEmpty != true) return null;

    await persist(
      ref.watch(storageProvider.future),
      key: 'notification_${isSignedIn}',
      encode: (NotificationEntity? state) => state == null ? '' : jsonEncode(state.toJson()),
      decode: (String encoded) {
        final trimmed = encoded.trim();
        if (trimmed.isEmpty || trimmed == 'null') {
          return null;
        }
        return NotificationEntity.fromJson(jsonDecode(trimmed) as Map<String, dynamic>);
      },
      options: Utils.storageOptions,
    ).future;

    // deviceId를 build에서 캡처하여 initialize에 전달
    initialize(deviceId: deviceId);

    return state.value ?? NotificationEntity(id: '${userId}-${deviceId!}', userId: userId!, deviceId: deviceId);
  }

  Future<void> initialize({String? deviceId}) async {
    await _getNotification();

    if (PlatformX.isPureDesktop) {
      // deviceId가 제공되면 사용, 없으면 provider에서 읽기 (하지만 ref.mounted 체크)
      final fcmToken = deviceId ?? (ref.mounted ? ref.read(deviceIdProvider).value : null);
      if (fcmToken != null) {
        _updateNotification(fcmToken: fcmToken);
      }
    } else {
      await FirebaseMessaging.instance.requestPermission();

      if (PlatformX.isApple) {
        apns = await FirebaseMessaging.instance.getAPNSToken();
      }

      // 전역 변수에서 가져오기 (Edge Function에서 업데이트됨)
      FirebaseMessaging.instance.getToken(vapidKey: PlatformX.isWeb ? fcmWebVapidKey : null).then((token) => _updateNotification(fcmToken: token));
      FirebaseMessaging.instance.onTokenRefresh.listen((token) => _updateNotification(fcmToken: token));
      FirebaseMessaging.onBackgroundMessage(onNotificationBackground);
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(alert: false, badge: false, sound: false);
      FirebaseMessaging.onMessage.listen((message) async {
        final messageId = message.messageId;

        if (_recievedMessages.contains(messageId)) {
          return;
        }

        if (messageId != null) {
          _recievedMessages.add(messageId);
        }

        final data = message.data;

        if (data['badge'] is int) {
          updateAppBadge(data['badge']);
        }

        Map<String, String> payload = {};

        if (data['type'] == 'slack_notification') {
          String? threadId = message.data['thread_id'];
          String messageId = message.data['event_id'];
          String channelId = message.data['channel_id'];

          payload = {'type': 'slack', 'channelId': channelId, 'messageId': messageId, 'threadId': threadId ?? ''};
        } else if (data['type'] == 'calendar_reminder') {
          final reminder = jsonDecode(data['reminder']);
          String type = 'task';
          switch (reminder['provider']) {
            case 'google':
              type = 'gcal';
              break;
          }
          payload = {'type': type, 'eventId': reminder['event_id'], 'date': reminder['date'].toString()};
        } else if (data['type'] == 'gmail_notification') {
          payload = {'type': 'gmail', 'threadId': data['threadId'], 'mailId': data['messageId']};
        }

        if (data['type'] == 'slack_notification') {
          final channelId = data['channel_id'];
          final threadId = data['thread_id'];

          String? currentChannelId =
              (ref.exists(chatConditionProvider(TabType.chat)) ? ref.read(chatConditionProvider(TabType.chat).select((v) => v.channel?.id)) : null) ??
              (ref.exists(chatConditionProvider(TabType.home)) ? ref.read(chatConditionProvider(TabType.home).select((v) => v.channel?.id)) : null);

          String? currentThreadId =
              (ref.exists(chatConditionProvider(TabType.chat)) ? ref.read(chatConditionProvider(TabType.chat).select((v) => v.threadId)) : null) ??
              (ref.exists(chatConditionProvider(TabType.home)) ? ref.read(chatConditionProvider(TabType.home).select((v) => v.threadId)) : null);

          if ((currentChannelId == null || currentChannelId != channelId) && (currentThreadId == null || currentThreadId != threadId)) {
            if (message.notification != null && message.notification!.title != null && message.notification!.body != null) {
              await sendLocalNotificationCore(
                id: message.messageId.hashCode,
                title: message.notification!.title!,
                body: message.notification!.body!,
                imagePath: message.data['imageUrl'],
                threadId: message.threadId,
                payload: payload,
              );
            }
          }
        } else {
          if (message.notification != null && message.notification!.title != null && message.notification!.body != null) {
            await sendLocalNotificationCore(
              id: message.messageId.hashCode,
              title: message.notification!.title!,
              body: message.notification!.body!,
              imagePath: message.data['imageUrl'],
              threadId: message.threadId,
              payload: payload,
            );
          }
        }
      });
    }

    if (!PlatformX.isWeb) {
      final iconPath = WindowsImage.getAssetUri('assets/app_icon/visir_icon_dark_default.png').toFilePath();
      await localNotificationPlugin.initialize(
        InitializationSettings(
          android: AndroidInitializationSettings('ic_notification'),
          iOS: DarwinInitializationSettings(),
          macOS: DarwinInitializationSettings(),
          linux: LinuxInitializationSettings(defaultActionName: 'open'),
          windows: WindowsInitializationSettings(appName: 'Visir', appUserModelId: 'WaveCorporation.Visir', guid: '6D809377-6AF0-444B-8957-A3773F02200E', iconPath: iconPath),
        ),
        onDidReceiveNotificationResponse: (response) => onLocalNotificationTapped(response, ref),
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );

      if (PlatformX.isAndroid) {
        await localNotificationPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(
          AndroidNotificationChannel('visir_notification', 'Visir Notification', importance: Importance.max),
        );
        await localNotificationPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.pendingNotificationRequests();
      } else if (PlatformX.isMacOS) {
        await localNotificationPlugin.resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>()?.pendingNotificationRequests();
      } else if (PlatformX.isLinux) {
        await localNotificationPlugin.resolvePlatformSpecificImplementation<LinuxFlutterLocalNotificationsPlugin>()?.pendingNotificationRequests();
      } else if (PlatformX.isWindows) {
        await localNotificationPlugin.resolvePlatformSpecificImplementation<FlutterLocalNotificationsWindows>()?.pendingNotificationRequests();
      }
    }

    isLocalNotificationInitialized = true;
    updateAppBadge(0);

    if (!PlatformX.isPureDesktop) {
      // Get any messages which caused the application to open from
      // a terminated state.
      RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

      // If the message also contains a data property with a "type" of "chat",
      // navigate to a chat screen
      if (initialMessage != null) {
        onRemoteNotificationTapped(initialMessage.data);
      }

      // Also handle any interaction when the app is in the background via a
      // Stream listener
      FirebaseMessaging.onMessageOpenedApp.listen((message) => onRemoteNotificationTapped(message.data));
    }
  }

  Future<NotificationEntity?> _getNotification() async {
    if (userId!.isSignedIn) return null;
    if (!ref.mounted) return null;
    final deviceIdAsync = ref.read(deviceIdProvider);
    if (!deviceIdAsync.hasValue) return null;
    final deviceId = deviceIdAsync.asData?.value;
    if (deviceId?.isNotEmpty != true) return null;
    final result = await repository.getNotification(userId: userId!, deviceId: deviceId!);
    return result.fold((l) => null, (r) {
      state = AsyncData(r);
      return r;
    });
  }

  FutureOr<NotificationEntity?> _updateNotification({bool? useDefaultFcmToken, String? fcmToken}) async {
    final prevNotification = state.value;
    if (useDefaultFcmToken == true) fcmToken = state.value?.fcmToken;
    if (fcmToken == null) return null;
    if (!ref.mounted) return null;
    String? deviceId = ref.read(deviceIdProvider).asData?.value;
    if (deviceId?.isNotEmpty != true) return null;
    if (!ref.mounted) return null;
    final pref = ref.read(localPrefControllerProvider).value;
    if (pref == null) return null;
    if (!ref.mounted) return null;
    final user = ref.read(authControllerProvider).requireValue;
    if (ref.read(shouldUseMockDataProvider)) return null;
    final userId = user.id;

    // gmail part
    final gmailOauths = pref.mailOAuths?.where((e) => e.type == OAuthType.google).toList() ?? [];
    final linkedGmails = gmailOauths.map((e) => e.email).toList()..sort((a, b) => a.compareTo(b));
    final gmailServerCode = Map<String, String>.fromEntries(
      gmailOauths.map((o) {
        if (o.serverCode == null) return null;
        return MapEntry(o.email, o.serverCode!);
      }).whereType<MapEntry<String, String>>(),
    );
    final gmailNotificationImage = Map<String, String>.fromEntries(
      gmailOauths.map((o) {
        if (o.notificationUrl == null) return null;
        return MapEntry(o.email, o.notificationUrl!);
      }).whereType<MapEntry<String, String>>(),
    );
    final showGmailNotification = {};
    showGmailNotification.addEntries(
      linkedGmails.map((email) {
        final filterTypes = pref.prefMailNotificationFilterTypes[email] ?? MailNotificationFilterType.all;
        switch (filterTypes) {
          case MailNotificationFilterType.none:
            return MapEntry(email, []);
          case MailNotificationFilterType.withSpecificLables:
            return MapEntry(email, pref.prefMailNotificationFilterLabelIds[email]);
          case MailNotificationFilterType.all:
            return MapEntry(email, [CommonMailLabels.inbox.id]);
        }
      }),
    );

    // outlook part
    final outlookOauths = pref.mailOAuths?.where((e) => e.type == OAuthType.microsoft).toList() ?? [];
    final linkedOutlookMails = outlookOauths.map((e) => e.email).toList()..sort((a, b) => a.compareTo(b));
    final outlookServerCode = Map<String, String>.fromEntries(
      outlookOauths.map((o) {
        if (o.serverCode == null) return null;
        return MapEntry(o.email, o.serverCode!);
      }).whereType<MapEntry<String, String>>(),
    );
    final outlookNotificationImage = Map<String, String>.fromEntries(
      outlookOauths.map((o) {
        if (o.notificationUrl == null) return null;
        return MapEntry(o.email, o.notificationUrl!);
      }).whereType<MapEntry<String, String>>(),
    );
    final showOutlookMailNotification = {};
    showOutlookMailNotification.addEntries(
      linkedOutlookMails.map((email) {
        final filterTypes = pref.prefMailNotificationFilterTypes[email] ?? MailNotificationFilterType.all;
        switch (filterTypes) {
          case MailNotificationFilterType.none:
            return MapEntry(email, []);
          case MailNotificationFilterType.withSpecificLables:
            return MapEntry(email, pref.prefMailNotificationFilterLabelIds[email]);
          case MailNotificationFilterType.all:
            return MapEntry(email, [CommonMailLabels.inbox.id]);
        }
      }),
    );

    // calendar part
    final localCalendarResult = calendarMap;
    final List<CalendarEntity>? calendars = localCalendarResult?.values.expand((e) => e).toList();
    final calOauths = pref.calendarOAuths ?? [];
    final calendarHide = ref.read(calendarHideProvider(TabType.home));
    final linkedCalendars = calendars?.where((e) => calOauths.where((o) => o.email == e.email).isNotEmpty && !calendarHide.contains(e.uniqueId)).toList();
    final calServerCode = Map<String, String>.fromEntries(
      linkedCalendars?.map((o) {
            final calOauth = calOauths.where((e) => e.email == o.email).firstOrNull;
            if (calOauth?.serverCode == null) return null;
            return MapEntry(o.id, calOauth?.serverCode!);
          }).whereType<MapEntry<String, String>>() ??
          [],
    );
    final calNotificationImageEntries = <MapEntry<String, String>>[];
    linkedCalendars?.forEach((o) {
      final calOauth = calOauths.where((e) => e.email == o.email).firstOrNull;
      if (calOauth?.notificationUrl != null) {
        calNotificationImageEntries.add(MapEntry(o.id, calOauth!.notificationUrl!));
      }
    });
    final calNotificationImage = Map<String, String>.fromEntries(calNotificationImageEntries);
    final linkedCalendarIds = (linkedCalendars ?? []).map((e) => e.id).toList()..sort((a, b) => a.compareTo(b));
    final showCalendarNotification = {};
    localCalendarResult?.keys.forEach((key) {
      final calendars = localCalendarResult[key] ?? [];
      final enabled = pref.prefShowCalendarNotifications[key] ?? true;
      showCalendarNotification.addEntries(calendars.map((c) => MapEntry(c.id, enabled)));
    });

    // slack part
    final slackOauths = (pref.messengerOAuths ?? []).where((e) => e.type == OAuthType.slack).toList();
    final linkedSlackTeams = slackOauths.where((e) => e.teamId != null).toList()..sort((a, b) => a.teamId!.compareTo(b.teamId!));
    final linkedSlackTeamIds = linkedSlackTeams.map((e) => e.teamId!).toList()..sort((a, b) => a.compareTo(b));

    final tokenSlackTeams = slackOauths.where((e) => !e.isAppAuth).map((e) => e.teamId).whereType<String>().toList()..sort((a, b) => a.compareTo(b));
    final slackNotificationImage = Map<String, String>.fromEntries(
      slackOauths.map((o) {
        if (o.notificationUrl == null) return null;
        return MapEntry(o.team?.id ?? '', o.notificationUrl!);
      }).whereType<MapEntry<String, String>>(),
    );

    // update notification
    NotificationEntity notification = NotificationEntity(
      id: '${userId}-${deviceId!}',
      userId: userId,
      platform: PlatformX.name,
      deviceId: deviceId,
      fcmToken: fcmToken,
      apnsToken: apns,
      showTaskNotification: ref.read(showTaskNotificationProvider),
      linkedGmails: linkedGmails,
      gmailServerCode: gmailServerCode,
      showGmailNotification: showGmailNotification,
      gmailNotificationImage: gmailNotificationImage,
      linkedOutlookMails: linkedOutlookMails,
      outlookMailServerCode: outlookServerCode,
      outlookMailNotificationImage: outlookNotificationImage,
      showOutlookMailNotification: showOutlookMailNotification,
      linkedGoogleCalendars: linkedCalendarIds,
      gcalServerCode: calServerCode,
      gcalNotificationImage: calNotificationImage,
      showCalendarNotification: showCalendarNotification,
      linkedSlackTeams: linkedSlackTeamIds,
      tokenSlackTeams: tokenSlackTeams,
      slackNotificationImage: slackNotificationImage,
    );

    if (prevNotification == notification) return notification;

    final result = await repository.saveNotification(notification: notification);
    return result.fold((l) => null, (r) {
      state = AsyncData(r);
      return r;
    });
  }

  Future<void> updateShowTaskNotification(bool value) async {
    if (!ref.mounted) return;
    String? deviceId = ref.read(deviceIdProvider).asData?.value;
    if (deviceId?.isNotEmpty != true) return;
    final notification = state.value;
    if (notification == null) return;

    if (value == notification.showTaskNotification) return;

    await repository.updateShowTaskNotification(notificationId: notification.id, showTaskNotification: value);
  }

  Future<void> updateLinkedGmail() async {
    if (!ref.mounted) return;
    String? deviceId = ref.read(deviceIdProvider).asData?.value;
    if (deviceId?.isNotEmpty != true) return;
    final notification = state.value;
    if (notification == null) return;
    final pref = ref.read(localPrefControllerProvider).value;
    if (pref == null) return;
    if (ref.read(shouldUseMockDataProvider)) return;

    final oauths = pref.mailOAuths?.where((e) => e.type == OAuthType.google).toList() ?? [];
    final linkedGmails = oauths.map((e) => e.email).toList()..sort((a, b) => a.compareTo(b));
    final gmailServerCode = Map<String, String>.fromEntries(
      oauths.map((o) {
        if (o.serverCode == null) return null;
        return MapEntry(o.email, o.serverCode!);
      }).whereType<MapEntry<String, String>>(),
    );
    final gmailNotificationImage = Map<String, String>.fromEntries(
      oauths.map((o) {
        if (o.notificationUrl == null) return null;
        return MapEntry(o.email, o.notificationUrl!);
      }).whereType<MapEntry<String, String>>(),
    );

    await repository.updateLinkedGmail(
      notificationId: notification.id,
      linkedGmails: linkedGmails,
      gmailServerCode: gmailServerCode,
      gmailNotificationImage: gmailNotificationImage,
    );
  }

  Future<void> updateLinkedMsMail() async {
    if (!ref.mounted) return;
    String? deviceId = ref.read(deviceIdProvider).asData?.value;
    if (deviceId?.isNotEmpty != true) return;
    final notification = state.value;
    if (notification == null) return;
    final pref = ref.read(localPrefControllerProvider).value;
    if (pref == null) return;
    if (ref.read(shouldUseMockDataProvider)) return;

    final oauths = pref.mailOAuths?.where((e) => e.type == OAuthType.microsoft).toList() ?? [];
    final linkedOutlookMails = oauths.map((e) => e.email).toList()..sort((a, b) => a.compareTo(b));
    final outlookServerCode = Map<String, String>.fromEntries(
      oauths.map((o) {
        if (o.serverCode == null) return null;
        return MapEntry(o.email, o.serverCode!);
      }).whereType<MapEntry<String, String>>(),
    );
    final outlookNotificationImage = Map<String, String>.fromEntries(
      oauths.map((o) {
        if (o.notificationUrl == null) return null;
        return MapEntry(o.email, o.notificationUrl!);
      }).whereType<MapEntry<String, String>>(),
    );

    await repository.updateLinkedMsMail(
      notificationId: notification.id,
      linkedOutlookMails: linkedOutlookMails,
      outlookMailServerCode: outlookServerCode,
      outlookMailNotificationImage: outlookNotificationImage,
    );
  }

  Future<void> updateLinkedCalendar(Map<String, List<CalendarEntity>> calendars) async {
    if (!ref.mounted) return;
    String? deviceId = ref.read(deviceIdProvider).asData?.value;
    if (deviceId?.isNotEmpty != true) return;
    final notification = state.value;
    if (notification == null) return;
    final pref = ref.read(localPrefControllerProvider).value;
    if (pref == null) return;
    if (ref.read(shouldUseMockDataProvider)) return;

    final oauths = pref.calendarOAuths ?? [];

    final calendarHide = ref.read(calendarHideProvider(TabType.home));

    final linkedCalendars = calendars.values.expand((e) => e).where((e) => oauths.where((o) => o.email == e.email).isNotEmpty && !calendarHide.contains(e.uniqueId)).toList();
    final calServerCode = Map<String, String>.fromEntries(
      linkedCalendars.map((o) {
        final calOauth = oauths.where((e) => e.email == o.email).firstOrNull;
        if (calOauth?.serverCode == null) return null;
        return MapEntry(o.id, calOauth?.serverCode!);
      }).whereType<MapEntry<String, String>>(),
    );
    final calNotificationImageEntries = <MapEntry<String, String>>[];
    linkedCalendars.forEach((o) {
      final calOauth = oauths.where((e) => e.email == o.email).firstOrNull;
      if (calOauth?.notificationUrl != null) {
        calNotificationImageEntries.add(MapEntry(o.id, calOauth!.notificationUrl!));
      }
    });
    final calNotificationImage = Map<String, String>.fromEntries(calNotificationImageEntries);
    final linkedCalendarIds = linkedCalendars.map((e) => e.id).toList()..sort((a, b) => a.compareTo(b));

    await repository.updateLinkedCalendar(
      notificationId: notification.id,
      linkedCalendars: linkedCalendarIds,
      calServerCode: calServerCode,
      calNotificationImage: calNotificationImage,
    );
  }

  Future<void> updateLinkedSlackTeam(Map<String, List<MessageChannelEntity>> channels) async {
    if (!ref.mounted) return;
    String? deviceId = ref.read(deviceIdProvider).asData?.value;
    if (deviceId?.isNotEmpty != true) return;
    final notification = state.value;
    if (notification == null) return;
    final pref = ref.read(localPrefControllerProvider).value;
    if (pref == null) return null;
    if (ref.read(shouldUseMockDataProvider)) return null;

    final oauths = (pref.messengerOAuths ?? []).where((e) => e.type == OAuthType.slack).toList();

    final linkedSlackTeams = oauths.where((e) => e.teamId != null).toList()..sort((a, b) => a.teamId!.compareTo(b.teamId!));
    final linkedSlackTeamIds = linkedSlackTeams.map((e) => e.teamId!).toList()..sort((a, b) => a.compareTo(b));
    final tokenSlackTeams = oauths.where((e) => !e.isAppAuth).map((e) => e.teamId).whereType<String>().toList()..sort((a, b) => a.compareTo(b));

    final slackNotificationImage = Map<String, String>.fromEntries(
      oauths.map((o) {
        if (o.notificationUrl == null) return null;
        return MapEntry(o.team?.id ?? '', o.notificationUrl!);
      }).whereType<MapEntry<String, String>>(),
    );

    final showSlackNotification = <String, String>{};
    showSlackNotification.addEntries(
      linkedSlackTeams.map((oauth) {
        final filterTypes = pref.prefMessageChannelNotificationFilterTypes['${oauth.teamId}${oauth.email}'] ?? MessagNotificationFilterType.mentions;
        final meId = channels[oauth.teamId]?.firstOrNull?.meId;
        if (meId == null) return null;
        switch (filterTypes) {
          case MessagNotificationFilterType.none:
            return MapEntry('channel-${oauth.teamId}-${meId}', 'none');
          case MessagNotificationFilterType.mentions:
            return MapEntry('channel-${oauth.teamId}-${meId}', 'mentions');
          case MessagNotificationFilterType.all:
            return MapEntry('channel-${oauth.teamId}-${meId}', 'all');
        }
      }).whereType<MapEntry<String, String>>(),
    );
    showSlackNotification.addEntries(
      linkedSlackTeams.map((oauth) {
        final filterTypes = pref.prefMessageDmNotificationFilterTypes['${oauth.teamId}${oauth.email}'] ?? MessagNotificationFilterType.all;
        final meId = channels[oauth.teamId]?.firstOrNull?.meId;
        if (meId == null) return null;
        switch (filterTypes) {
          case MessagNotificationFilterType.none:
            return MapEntry('dm-${oauth.teamId}-${meId}', 'none');
          case MessagNotificationFilterType.mentions:
            return MapEntry('dm-${oauth.teamId}-${meId}', 'mentions');
          case MessagNotificationFilterType.all:
            return MapEntry('dm-${oauth.teamId}-${meId}', 'all');
        }
      }).whereType<MapEntry<String, String>>(),
    );

    await repository.updateLinkedSlackTeam(
      notificationId: notification.id,
      linkedSlackTeams: linkedSlackTeamIds,
      tokenSlackTeams: tokenSlackTeams,
      slackNotificationImage: slackNotificationImage,
      showSlackNotification: showSlackNotification,
    );
  }
}

Future<List<Gmail.History>> fetchHistories({required Client client, required String historyId, String? nextPageToken}) async {
  final histories = await Gmail.GmailApi(client).users.history.list('me', startHistoryId: historyId, maxResults: 500, pageToken: nextPageToken);
  List<Gmail.History> historyList = histories.history ?? [];

  if (histories.nextPageToken != null) {
    final newResponse = await fetchHistories(client: client, historyId: historyId, nextPageToken: histories.nextPageToken);
    historyList.addAll(newResponse);
  }

  return historyList;
}

Future<void> updateAppBadge(int number) async {
  if (PlatformX.isWeb) return;
  if (PlatformX.isWindows) {
    if (number > 0) {
      WindowsTaskbar.setOverlayIcon(ThumbnailToolbarAssetIcon('assets/app_icon/ic_badge.ico'));
    } else {
      WindowsTaskbar.resetOverlayIcon();
    }
    return;
  }
  if (PlatformX.isAndroid && !(await AppBadgePlus.isSupported())) return;
  AppBadgePlus.updateBadge(number);
}

Future<void> sendLocalNotificationCore({
  required int id,
  required String title,
  required String body,
  String? subtitle,
  String? imagePath,
  String? threadId,
  Map<String, dynamic>? payload,
  int? badge,
}) async {
  if (title.isEmpty) return;

  if (imagePath != null) {
    final Directory directory = await getApplicationCacheDirectory();
    final String filePath = '${directory.path}/${imagePath.split('/').last}';
    final http.Response response = await http.get(Uri.parse(imagePath));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    imagePath = filePath;
  }

  NotificationDetails platformChannelSpecifics = NotificationDetails(
    macOS: DarwinNotificationDetails(
      subtitle: subtitle,
      interruptionLevel: InterruptionLevel.timeSensitive,
      attachments: imagePath == null ? null : [DarwinNotificationAttachment(imagePath)],
      threadIdentifier: threadId,
      presentSound: true,
      presentBanner: true,
    ),
    iOS: DarwinNotificationDetails(
      subtitle: subtitle,
      attachments: imagePath == null ? null : [DarwinNotificationAttachment(imagePath)],
      interruptionLevel: InterruptionLevel.timeSensitive,
      threadIdentifier: threadId,
      presentSound: true,
      presentBanner: true,
    ),
    android: AndroidNotificationDetails(
      'visir_notification',
      'Visir Notification',
      importance: Importance.high,
      priority: Priority.high,
      subText: subtitle,
      groupKey: threadId,
      styleInformation: imagePath == null ? null : BigPictureStyleInformation(FilePathAndroidBitmap(imagePath)),
    ),
    windows: WindowsNotificationDetails(
      images: imagePath == null ? [] : [WindowsImage(Uri.parse(imagePath), altText: '', placement: WindowsImagePlacement.appLogoOverride)],
      subtitle: subtitle,
    ),
  );

  final subtitleNotShown = PlatformX.isLinux;

  try {
    await localNotificationPlugin.show(
      id,
      title,
      subtitleNotShown ? '${subtitle == null ? '' : '• $subtitle \n'}${body}' : body,
      platformChannelSpecifics,
      payload: payload == null ? null : jsonEncode(payload),
    );
  } catch (e) {}

  if (PlatformX.isAndroid || PlatformX.isIOS || PlatformX.isMacOS) {
    AppBadgePlus.updateBadge(badge ?? 0);
  } else if (PlatformX.isWindows) {
    if ((badge ?? 0) > 0) {
      WindowsTaskbar.setOverlayIcon(ThumbnailToolbarAssetIcon('assets/app_icon/ic_badge.ico'));
    } else {
      WindowsTaskbar.resetOverlayIcon();
    }
  }
}
