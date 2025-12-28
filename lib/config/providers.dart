import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:Visir/dependency/toasty_box/model/download_file_toast_model.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:Visir/features/calendar/presentation/screens/main_calendar_widget.dart';
import 'package:Visir/features/chat/presentation/screens/chat_screen.dart';
import 'package:Visir/features/common/infrastructure/entities/environment.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/google_api_handler.dart';
import 'package:Visir/features/common/presentation/utils/slack_api_handler.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/inbox/presentation/screens/inbox_list_screen.dart';
import 'package:Visir/features/inbox/presentation/screens/inbox_screen.dart';
import 'package:Visir/features/mail/presentation/screens/mail_edit_screen.dart';
import 'package:Visir/features/mail/presentation/screens/mail_screen.dart';
import 'package:Visir/features/mail/presentation/widgets/html_scrollsync_viewport.dart';
import 'package:Visir/features/preference/application/last_app_open_close_date_controller.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:Visir/features/task/presentation/screens/task_screen.dart';
import 'package:Visir/flavors.dart';
import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart' hide Storage;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:http/http.dart' as http;
import 'package:media_kit/media_kit.dart';
import 'package:mime/mime.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_sqflite/riverpod_sqflite.dart';
import 'package:riverpod_annotation/experimental/persist.dart';
import 'package:Visir/config/serialized_sqlite_storage.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/standalone.dart' as tzs;
import 'package:universal_html/html.dart' as html;

import '../dependency/rrule/rrule.dart';

String aesKey = '';
String openAiApiKey = '';
String microsoftClientSecret = '';
String googleCliendSecretWeb = '';
String googleCliendSecretDesktop = '';
String appleKey = '';
String applePem = '';
String googleAiKey = '';
String anthropicApiKey = '';
String googleAPiWeb = '';
String mixpanelToken = '';
String fcmWebVapidKey = '';

const kControllerDebouncMillisecond = 250;

List<Color> accountColors = [
  Colors.red,
  Colors.deepOrange,
  Colors.orange,
  Colors.yellow,
  Colors.lightGreen,
  Colors.green,
  Colors.teal,
  Colors.lightBlue,
  Colors.indigo,
  Colors.deepPurple,
  Colors.purple,
  Colors.brown,
  Colors.pinkAccent,
  Colors.cyan,
  Colors.lime,
  Colors.blueGrey,
];

ValueNotifier<bool> useDebugDbNotifier = ValueNotifier(kDebugMode ? false : false);
bool get useDebugDb => useDebugDbNotifier.value;
set useDebugDb(bool value) => useDebugDbNotifier.value = value;

final supabaseProvider = FutureProvider<supabase.Supabase>((ref) async {
  try {
    supabase.Supabase.instance.dispose();
  } catch (e) {}
  final configFile = await rootBundle.loadString('assets/config/${F.envFileName}');
  final env = Environment.fromJson(json.decode(configFile) as Map<String, dynamic>);

  // Supabase 초기화 (공개 키만 사용)
  final supabaseInstance = await supabase.Supabase.initialize(
    url: env.supabaseUrl,
    anonKey: env.supabaseAnonKey,
    debug: kDebugMode,
    authOptions: supabase.FlutterAuthClientOptions(
      autoRefreshToken: true,
      authFlowType: supabase.AuthFlowType.pkce,
      detectSessionInUri: true,
      localStorage: useDebugDb ? supabase.SharedPreferencesLocalStorage(persistSessionKey: "sb-${Uri.parse(env.supabaseUrl).host.split(".").first}-auth-token-debug") : null,
    ),
  );

  // 초기에는 config.json의 값 사용 (fallback)
  if (env.encryptAESKey.isNotEmpty) {
    aesKey = env.encryptAESKey;
  }

  return supabaseInstance;
});

// 로그인 후 민감한 설정을 Edge Function에서 가져오는 provider
final appConfigProvider = FutureProvider<void>((ref) async {
  final supabaseInstance = ref.watch(supabaseProvider).value;
  if (supabaseInstance == null) return;

  try {
    final currentUser = supabaseInstance.client.auth.currentUser;
    if (currentUser != null) {
      final response = await supabaseInstance.client.functions.invoke('get_app_config');
      if (response.status == 200 && response.data != null) {
        final privateConfig = response.data as Map<String, dynamic>;
        // 모든 민감한 키 설정
        if (privateConfig['encryptAESKey'] != null && (privateConfig['encryptAESKey'] as String).isNotEmpty) {
          aesKey = privateConfig['encryptAESKey'] as String;
        }
        if (privateConfig['openAiApiKey'] != null && (privateConfig['openAiApiKey'] as String).isNotEmpty) {
          openAiApiKey = privateConfig['openAiApiKey'] as String;
        }
        if (privateConfig['microsoftClientSecret'] != null && (privateConfig['microsoftClientSecret'] as String).isNotEmpty) {
          microsoftClientSecret = privateConfig['microsoftClientSecret'] as String;
        }
        if (privateConfig['googleCliendSecretWeb'] != null && (privateConfig['googleCliendSecretWeb'] as String).isNotEmpty) {
          googleCliendSecretWeb = privateConfig['googleCliendSecretWeb'] as String;
        }
        if (privateConfig['googleCliendSecretDesktop'] != null && (privateConfig['googleCliendSecretDesktop'] as String).isNotEmpty) {
          googleCliendSecretDesktop = privateConfig['googleCliendSecretDesktop'] as String;
        }
        if (privateConfig['appleKey'] != null && (privateConfig['appleKey'] as String).isNotEmpty) {
          appleKey = privateConfig['appleKey'] as String;
        }
        if (privateConfig['applePem'] != null && (privateConfig['applePem'] as String).isNotEmpty) {
          applePem = privateConfig['applePem'] as String;
        }
        if (privateConfig['googleAiKey'] != null && (privateConfig['googleAiKey'] as String).isNotEmpty) {
          googleAiKey = privateConfig['googleAiKey'] as String;
        }
        if (privateConfig['anthropicApiKey'] != null && (privateConfig['anthropicApiKey'] as String).isNotEmpty) {
          anthropicApiKey = privateConfig['anthropicApiKey'] as String;
        }
        if (privateConfig['googleAPiWeb'] != null && (privateConfig['googleAPiWeb'] as String).isNotEmpty) {
          googleAPiWeb = privateConfig['googleAPiWeb'] as String;
        }
        if (privateConfig['mixpanelToken'] != null && (privateConfig['mixpanelToken'] as String).isNotEmpty) {
          mixpanelToken = privateConfig['mixpanelToken'] as String;
        }
        if (privateConfig['fcmWebVapidKey'] != null && (privateConfig['fcmWebVapidKey'] as String).isNotEmpty) {
          fcmWebVapidKey = privateConfig['fcmWebVapidKey'] as String;
        }
      }
    }
  } catch (e) {
    // Edge Function 호출 실패 시 기존 값 유지
  }
});

final storageProvider = FutureProvider<Storage<String, String>>((ref) async {
  if (PlatformX.isDesktop) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  final dbPath = join((await getApplicationSupportDirectory()).path, useDebugDb ? 'taskey_riverpod_debug.db' : 'taskey_riverpod.db');

  // SQLite WAL 모드 활성화를 위해 데이터베이스 파일을 먼저 생성하고 설정
  try {
    final factory = PlatformX.isDesktop ? databaseFactoryFfi : databaseFactory;
    final db = await factory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          // WAL 모드 활성화 및 성능 최적화 설정
          await db.execute('PRAGMA journal_mode=WAL;');
          await db.execute('PRAGMA busy_timeout=60000;'); // 60초 대기 (동시 접근 문제 해결)
          await db.execute('PRAGMA synchronous=NORMAL;'); // WAL 모드에서 성능 향상
          await db.execute('PRAGMA wal_autocheckpoint=1000;'); // WAL 체크포인트 최적화
          await db.execute('PRAGMA cache_size=-64000;'); // 캐시 크기 증가 (64MB)
          await db.execute('PRAGMA temp_store=MEMORY;'); // 임시 테이블을 메모리에 저장
          // 직렬화를 통해 동시 접근을 방지하므로 threads 설정 불필요
        },
        onOpen: (db) async {
          // 기존 데이터베이스도 WAL 모드로 전환 및 성능 최적화 설정
          await db.execute('PRAGMA journal_mode=WAL;');
          await db.execute('PRAGMA busy_timeout=60000;'); // 60초 대기 (동시 접근 문제 해결)
          await db.execute('PRAGMA synchronous=NORMAL;'); // WAL 모드에서 성능 향상
          await db.execute('PRAGMA wal_autocheckpoint=1000;'); // WAL 체크포인트 최적화
          await db.execute('PRAGMA cache_size=-64000;'); // 캐시 크기 증가 (64MB)
          await db.execute('PRAGMA temp_store=MEMORY;'); // 임시 테이블을 메모리에 저장
          // 직렬화를 통해 동시 접근을 방지하므로 threads 설정 불필요
        },
      ),
    );
    await db.close();
  } catch (e) {
    // WAL 모드 설정 실패 시 무시 (JsonSqFliteStorage가 자체적으로 처리)
  }

  final baseStorage = await JsonSqFliteStorage.open(dbPath);

  // 직렬화 래퍼로 감싸서 동시 접근 방지
  // SerializedSqliteStorage는 Storage<String, String>을 구현하므로
  // persist 함수에서 사용 가능
  return SerializedSqliteStorage(baseStorage);
});

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

/// 로그인/로그아웃 시 사용자별 설정을 초기화하는 함수
/// sharedPref의 모든 키를 제거합니다
Future<void> clearUserSpecificSharedPreferences() async {
  final sharedPref = await SharedPreferences.getInstance();
  await sharedPref.clear();
}

final deviceIdProvider = FutureProvider<String>((ref) async {
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String? deviceId;

  if (PlatformX.isWeb) {
    final webBrowserInfo = await deviceInfo.webBrowserInfo;
    deviceId = '${webBrowserInfo.vendor ?? '-'} + ${webBrowserInfo.userAgent ?? '-'} + ${webBrowserInfo.hardwareConcurrency.toString()}';
  } else if (PlatformX.isAndroid) {
    const androidId = AndroidId();
    deviceId = await androidId.getId();
  } else if (PlatformX.isIOS) {
    final iosInfo = await deviceInfo.iosInfo;
    deviceId = iosInfo.identifierForVendor;
  } else if (PlatformX.isLinux) {
    final linuxInfo = await deviceInfo.linuxInfo;
    deviceId = linuxInfo.machineId;
  } else if (PlatformX.isWindows) {
    final windowsInfo = await deviceInfo.windowsInfo;
    deviceId = windowsInfo.deviceId;
  } else if (PlatformX.isMacOS) {
    final macOsInfo = await deviceInfo.macOsInfo;
    deviceId = macOsInfo.systemGUID;
  }

  return deviceId ?? '';
});

final packageInfoProvider = FutureProvider<PackageInfo>((ref) async {
  final PackageInfo packageInfo = await PackageInfo.fromPlatform();
  return packageInfo;
});

final timezoneProvider = FutureProvider<String>((ref) async {
  tz.initializeTimeZones();
  final String timezone = await FlutterTimezone.getLocalTimezone();
  tzs.setLocalLocation(tzs.getLocation(timezone));
  return timezone;
});

final rruleL10nEnProvider = FutureProvider<RruleL10nEn>((ref) async {
  return await RruleL10nEn.create();
});

String sendTaskOrEventChangeFcmFunctionUrl = 'https://us-central1-fillin-cd65f.cloudfunctions.net/sendtaskoreventchangenotificationforwidgets';

class VisirBouncingScrollPhysics extends BouncingScrollPhysics {
  const VisirBouncingScrollPhysics({ScrollPhysics? parent}) : super(parent: parent ?? const AlwaysScrollableScrollPhysics(), decelerationRate: ScrollDecelerationRate.normal);

  @override
  VisirBouncingScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return VisirBouncingScrollPhysics(parent: buildParent(ancestor));
  }

  // @override
  // SpringDescription get spring {
  //   // c = 15.5563491861
  //   // m = 0.5
  //   // k = 100
  //   // new_c = 7.7781745931;
  //   // new_m = 1;
  //   // new_k = 143.2812499993;
  //   // new_r = 46.5524317976;
  //   return SpringDescription.withDampingRatio(mass: 1, stiffness: 143.2812499993, ratio: 46.5524317976);
  // }
}

String proxyUrl(String url) {
  if (url.contains('secure.gravatar.com') == true) return url;
  if (PlatformX.isWeb) return 'https://azukhxinzrivjforwnsc.supabase.co/functions/v1/proxy?url=${url}';
  return url;
}

Future<dynamic> proxyCall({
  required OAuthEntity? oauth,
  required String url,
  required String method,
  required Map<String, dynamic>? body,
  required Map<String, dynamic> headers,
  required List<http.MultipartFile>? files,
  ResponseType? responseType,
}) async {
  if (headers['Content-type'] != 'multipart/form-data') {
    dynamic data;

    if (method == 'GET' && body != null) {
      url = '$url?${body.entries.map((e) => '${e.key}=${e.value}').join('&')}';
    }

    if (responseType == null) {
      final result = (method == 'POST')
          ? await http.post(Uri.parse(proxyUrl(url)), headers: headers.map((key, value) => MapEntry(key, value.toString())), body: jsonEncode(body))
          : await http.get(Uri.parse(proxyUrl(url)), headers: headers.map((key, value) => MapEntry(key, value.toString())));

      data = jsonDecode(result.body);
    } else {
      Dio dio = Dio();
      final result = (method == 'POST')
          ? await dio.post(
              proxyUrl(url),
              options: Options(headers: headers, responseType: responseType),
              data: body,
            )
          : await dio.get(
              proxyUrl(url),
              options: Options(headers: headers, responseType: responseType),
            );

      data = result.data;
    }

    if (oauth != null) {
      switch (oauth.type) {
        case OAuthType.google:
          String? error = data['error'];
          if (GoogleApiHandler.checkAuthNotWork(oauth, error ?? '')) {
            return jsonEncode(data);
          }
        case OAuthType.apple:
          break;
        case OAuthType.microsoft:
          break;
        case OAuthType.slack:
          if (data is Map) {
            bool? ok = data['ok'];
            String? error = data['error']?.toString();
            if (ok != null) {
              if (SlackApiHandler.checkAuthNotWork(oauth, ok, error)) {
                return jsonEncode(data);
              }

              SlackApiHandler.showErrorMessageToastIfNeeded(ok, error);
            }
          }
        case OAuthType.discord:
          break;
      }
    }

    if (data is Map) return jsonEncode(data);
    return data;
  } else {
    var request = http.MultipartRequest('POST', Uri.parse(proxyUrl(url)));
    request.headers.addAll({...headers});
    request.files.addAll(files!);
    http.StreamedResponse res = await request.send();
    if (res.statusCode != 200) return null;
    return res.stream;
  }
}

Future<Media> proxyMedia({required String url, OAuthEntity? oauth}) async {
  if (PlatformX.isWeb) {
    final result = await proxyCall(url: url, method: 'GET', body: null, oauth: oauth, headers: oauth?.authorizationHeaders ?? {}, files: null, responseType: ResponseType.bytes);
    return await Media.memory(result);
  } else {
    return Media(url, httpHeaders: oauth?.authorizationHeaders);
  }
}

Future<bool> proxyDownload({required String url, OAuthEntity? oauth, required String name, required BuildContext context, String? extension}) async {
  if (url.isEmpty) return false;
  try {
    final bytes = await proxyCall(url: url, method: 'GET', body: null, oauth: oauth, headers: oauth?.authorizationHeaders ?? {}, files: null, responseType: ResponseType.bytes);

    return await downloadBytes(url: url, bytes: [bytes], names: [name], context: context, extensions: extension == null ? null : [extension]);
  } catch (e) {
    return false;
  }
}

Future<bool> downloadBytes({String? url, required List<Uint8List> bytes, required List<String> names, required BuildContext context, List<String?>? extensions}) async {
  if (PlatformX.isWeb) {
    for (final byte in bytes) {
      final name = names[bytes.indexOf(byte)];
      final extension = extensions?[bytes.indexOf(byte)];
      final blob = html.Blob([byte]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute('download', '${name.contains('.') || extension == null ? name : '${name}.${extension}'}')
        ..click();
      html.Url.revokeObjectUrl(url);
    }
    return true;
  } else if (PlatformX.isDesktop) {
    if (bytes.length == 1) {
      final byte = bytes.first;
      final name = names.first;
      final extension = extensions?.first;
      String? outputFile = await FilePicker.platform.saveFile(fileName: name);

      if (outputFile == null) {
        return false;
      } else {
        File file = File(outputFile.contains('.') || extension == null ? outputFile : '${outputFile}.${extension}');
        await file.create(recursive: true);
        await file.writeAsBytes(byte);
        Utils.showToast(DownloadFileToastModel(path: file.path, isSuccess: true, downloadUrl: url ?? file.path, directoryPath: null));
        return true;
      }
    } else {
      final directoryPath = await FilePicker.platform.getDirectoryPath();
      if (directoryPath == null) return false;
      final result = await Future.wait(
        bytes.map((byte) async {
          final name = names[bytes.indexOf(byte)];
          final extension = extensions?[bytes.indexOf(byte)];
          String? outputFile = '${directoryPath}/${name.contains('.') || extension == null ? name : '${name}.${extension}'}';

          File file = File(outputFile.contains('.') || extension == null ? outputFile : '${outputFile}.${extension}');
          await file.create(recursive: true);
          await file.writeAsBytes(byte);
          return true;
        }),
      );
      final done = result.contains(false) ? false : true;
      if (done) {
        Utils.showToast(DownloadFileToastModel(path: directoryPath, isSuccess: true, downloadUrl: url, directoryPath: directoryPath));
      }

      return done;
    }
  } else {
    if (PlatformX.isAndroid) {
      Utils.showFileDownloadBottomDialogInAndroid(context: context, bytes: bytes, names: names, extensions: extensions);
      return true;
    } else {
      final files = bytes
          .map(
            (e) => XFile.fromData(
              e,
              mimeType: lookupMimeType('', headerBytes: e),
              name: names[bytes.indexOf(e)],
            ),
          )
          .toList();
      await SharePlus.instance.share(ShareParams(files: files, fileNameOverrides: names));
      return true;
    }
  }
}

Future<void> initializeProviders(ProviderContainer container) async {
  // 필수 Provider만 await로 초기화 (앱 시작에 반드시 필요)
  await Future.wait([
    container.read(supabaseProvider.future),
    container.read(deviceIdProvider.future),
    container.read(packageInfoProvider.future),
    container.read(rruleL10nEnProvider.future),
    container.read(timezoneProvider.future),
  ]);

  await container.read(authControllerProvider.future);

  // lastAppOpenCloseDateProvider 초기화
  try {
    container.read(lastAppOpenCloseDateProvider);
  } catch (e) {
    // ignore
  }

  try {
    await container.read(appConfigProvider.future);
  } catch (e) {
    // ignore
  }
}

ValueNotifier<TabType> tabNotifier = ValueNotifier<TabType>(TabType.home);

Map<String, String>? notificationPayload;

WebViewEnvironment? webViewEnvironment;

ValueNotifier<int> keyboardResetNotifier = ValueNotifier<int>(0);

ValueNotifier<Widget?> mailInputDraftEditListener = ValueNotifier(null);
ValueNotifier<int> mailInputDraftEditKeyboardResetNotifier = ValueNotifier(0);

GlobalKey<MailEditScreenState> mailEditScreenKey = GlobalKey();
ValueNotifier<bool> mailEditScreenVisibleNotifier = ValueNotifier(false);

double calendarViewMinWidth = 320;

Map<TabType, GlobalKey<HtmlViewportSyncState>> mailViewportSyncKey = {
  TabType.mail: GlobalKey(),
  TabType.home: GlobalKey(),
  TabType.task: GlobalKey(),
  TabType.calendar: GlobalKey(),
  TabType.chat: GlobalKey(),
};

Map<TabType, ValueNotifier<bool>> mailViewportSyncVisibleNotifier = {
  TabType.mail: ValueNotifier(false),
  TabType.home: ValueNotifier(false),
  TabType.task: ValueNotifier(false),
  TabType.calendar: ValueNotifier(false),
  TabType.chat: ValueNotifier(false),
};

enum TabType { home, chat, mail, calendar, task }

extension TabTypeX on TabType {
  String? get showcaseKey {
    switch (this) {
      case TabType.chat:
        return chatTabShowcaseKeyString;
      case TabType.mail:
        return mailTabShowcaseKeyString;
      case TabType.calendar:
        return calendarTabShowcaseKeyString;
      case TabType.task:
        return taskTabShowcaseKeyString;
      default:
        return null;
    }
  }

  VisirIcon getVisirIcon({required double size, bool isSelected = false}) {
    switch (this) {
      case TabType.home:
        return VisirIcon(type: VisirIconType.home, size: size, isSelected: isSelected);
      case TabType.chat:
        return VisirIcon(type: VisirIconType.chat, size: size, isSelected: isSelected);
      case TabType.mail:
        return VisirIcon(type: VisirIconType.mail, size: size, isSelected: isSelected);
      case TabType.calendar:
        return VisirIcon(type: VisirIconType.calendar, size: size, isSelected: isSelected);

      case TabType.task:
        return VisirIcon(type: VisirIconType.task, size: size, isSelected: isSelected);
    }
  }

  String getTitle(BuildContext context) {
    switch (this) {
      case TabType.home:
        return context.tr.tab_home;
      case TabType.chat:
        return context.tr.tab_chat;
      case TabType.mail:
        return context.tr.tab_mail;
      case TabType.calendar:
        return context.tr.tab_calendar;
      case TabType.task:
        return context.tr.tab_task;
    }
  }

  int get defaultOrder {
    switch (this) {
      case TabType.home:
        return 0;
      case TabType.calendar:
        return 1;
      case TabType.task:
        return 2;
      case TabType.mail:
        return 3;
      case TabType.chat:
        return 4;
    }
  }

  Widget getScreen(
    BuildContext context, {
    GlobalKey<MainCalendarWidgetState>? inboxCalendarScreenKey,
    GlobalKey<InboxListScreenState>? inboxListScreenKey,
    GlobalKey<MailScreenState>? mailScreenKey,
    GlobalKey<ChatScreenState>? chatScreenKey,
    GlobalKey<TaskScreenState>? taskScreenKey,
    void Function(bool showCalendarOnMobile)? onUpdateVisibilitiyCalendarOnMobile,
  }) {
    switch (this) {
      case TabType.home:
        return InboxScreen(tabType: TabType.home, inboxListScreenKey: inboxListScreenKey, onUpdateVisibilitiyCalendarOnMobile: onUpdateVisibilitiyCalendarOnMobile);
      case TabType.chat:
        return ChatScreen(key: chatScreenKey);
      case TabType.mail:
        return MailScreen(key: mailScreenKey);
      case TabType.calendar:
        return CalendarScreen();
      case TabType.task:
        return TaskScreen(key: taskScreenKey);
    }
  }
}
