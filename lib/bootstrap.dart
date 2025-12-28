import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:Visir/config/providers.dart' as providers;
import 'package:Visir/config/providers.dart';
import 'package:Visir/config/url_strategy.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/common/infrastructure/entities/environment.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/task/application/task_list_controller.dart';
import 'package:Visir/firebase_options.dart';
import 'package:Visir/flavors.dart';
import 'package:color_mesh/color_mesh.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:home_widget/home_widget.dart';
import 'package:http/http.dart' as http;
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:media_kit/media_kit.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/platform_registry.dart';

/// 버전 체크를 백그라운드에서 수행 (UI 블로킹 방지)
Future<void> _checkVersionInBackground() async {
  try {
    if (PlatformX.isWindows || PlatformX.isMacOS) {
      final response = await http.get(Uri.parse('https://visir.pro/appcast.xml'));
      if (response.statusCode == 200) {
        final xml = response.body;
        String? prodBuild;

        if (PlatformX.isWindows) {
          final winAttr =
              RegExp(r'sparkle:os="windows"[^>]*?sparkle:version="([^"]+)"', caseSensitive: false, dotAll: true).firstMatch(xml) ??
              RegExp(r'sparkle:version="([^"]+)"[^>]*?sparkle:os="windows"', caseSensitive: false, dotAll: true).firstMatch(xml);
          final versionAttr = winAttr?.group(1)?.trim();
          if (versionAttr != null) {
            final buildMatch = RegExp(r'(\d+)$').firstMatch(versionAttr);
            prodBuild = buildMatch?.group(1);
          }
        } else {
          final macTag = RegExp(r'<sparkle:version>\s*(\d+)\s*</sparkle:version>', caseSensitive: false).firstMatch(xml);
          prodBuild = macTag?.group(1)?.trim();
        }

        final pkg = await PackageInfo.fromPlatform();
        final prodBuildNumber = int.tryParse(prodBuild!.trim());
        final currentBuild = int.tryParse(pkg.buildNumber.trim());
        Constants.isBetaBuild = prodBuildNumber! < currentBuild!;
        Constants.hasProductionBuild = prodBuildNumber > currentBuild;
      }
    } else if (PlatformX.isIOS || PlatformX.isAndroid) {
      final newVersionPlus = NewVersionPlus();
      final status = await newVersionPlus.getVersionStatus();
      if (status != null) {
        final localVersionString = status.localVersion;
        final storeVersionString = status.storeVersion;
        final localVersion = localVersionString.split('.').map(int.tryParse).whereType<int>().toList();
        final storeVersion = storeVersionString.split('.').map(int.tryParse).whereType<int>().toList();
        for (int i = 0; i < localVersion.length; i++) {
          if (localVersion[i] > storeVersion[i]) {
            Constants.isBetaBuild = true;
            break;
          }

          if (localVersion[i] > storeVersion[i]) {
            Constants.hasProductionBuild = true;
          }
        }
      }
    }
  } catch (e) {}
}

/// GoogleSignIn 초기화를 백그라운드에서 수행 (UI 블로킹 방지)
Future<void> _initializeGoogleSignIn(Environment env) async {
  final clientId = PlatformX.isAppAuthSupported
      ? PlatformX.isAndroid
            ? env.googleClientIdAndroid
            : env.googleClientIdIOS
      : PlatformX.isWeb
      ? env.googleClientIdWeb
      : env.googleClientIdDesktop;

  if (PlatformX.isGoogleSignInSupported) {
    final GoogleSignIn signIn = GoogleSignIn.instance;
    try {
      await signIn.initialize(clientId: clientId, serverClientId: env.googleClientIdWeb);
    } catch (e) {}
  }
}

/// Initializes services and controllers before the start of the application
Future<ProviderContainer> bootstrap(WidgetsBinding widgetsBinding, ProviderContainer container) async {
  final sharedPref = await SharedPreferences.getInstance();
  useDebugDb = kDebugMode ? useDebugDb : sharedPref.getBool('useDebugDb') ?? useDebugDb;
  await MeshGradient.precacheShader();

  _checkVersionInBackground();

  final supportDirectory = await getApplicationSupportDirectory();
  if (PlatformX.isPureDesktop) {
    final documentDirectory = await getApplicationDocumentsDirectory();

    // move taskey.db to supportDirectory
    final dbName = providers.useDebugDb ? 'taskey_debug' : 'taskey';
    final taskeyDbPath = join(documentDirectory.path, '$dbName.sqlite');
    final taskeyDbSupportPath = join(supportDirectory.path, '$dbName.sqlite');
    if (await File(taskeyDbPath).exists()) {
      await File(taskeyDbPath).copy(taskeyDbSupportPath);
      await File(taskeyDbPath).delete();
    }

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    launchAtStartup.setup(appName: packageInfo.appName, appPath: Platform.resolvedExecutable);
  }

  initializeHomeWidget();

  if (!PlatformX.isWindows) {
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }
  if (PlatformX.isWindows) {
    setupRegistry();
    try {
      final availableVersion = await WebViewEnvironment.getAvailableVersion();
      if (availableVersion == null) {
      } else {
        webViewEnvironment = await WebViewEnvironment.create(settings: WebViewEnvironmentSettings(userDataFolder: supportDirectory.path));
      }
    } catch (e) {}
  }

  F.appFlavor = Flavor.local;

  MediaKit.ensureInitialized();
  configureAppUrlStrategy();

  final configFile = await rootBundle.loadString('assets/config/config.json');
  final env = Environment.fromJson(json.decode(configFile) as Map<String, dynamic>);

  // GoogleSignIn 초기화를 백그라운드로 이동 (앱 초기화 블로킹 방지)
  unawaited(_initializeGoogleSignIn(env));

  HttpOverrides.global = MyHttpOverrides();
  await providers.initializeProviders(container);
  return container;
}

/// Creates a fresh ProviderContainer and initializes app providers.
/// Use this during auth state transitions to refresh all providers
/// without re-running global platform/service bootstrapping.
Future<ProviderContainer> createProviderContainer() async {
  final container = ProviderContainer(overrides: []);
  await providers.initializeProviders(container);
  return container;
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..maxConnectionsPerHost = 2000
      ..badCertificateCallback = (_, __, ___) => true;
  }
}

Future<void> initializeHomeWidget() async {
  if (PlatformX.isMobile) {
    await HomeWidget.setAppGroupId(Constants.appGroupIdentifier);
    await HomeWidget.registerInteractivityCallback(backgroundCallback);
  }
}

@pragma("vm:entry-point")
Future<void> backgroundCallback(Uri? uri) async {
  if (uri == null) return;

  final host = uri.host;
  final queryParameters = uri.queryParameters;

  if (host == 'toggletaskstatus') {
    final taskId = queryParameters['id'];
    final recurringTaskId = queryParameters['recurringTaskId'];
    final startAtMs = queryParameters['startAtMs'];
    final endAtMs = queryParameters['endAtMs'];

    if (taskId == null) return;

    final dateGroupedAppointments = await HomeWidget.getWidgetData<String>('dateGroupedAppointments');

    if (dateGroupedAppointments != null) {
      try {
        // JSON 문자열을 Map으로 변환
        final Map<String, dynamic> appointmentsMap = json.decode(dateGroupedAppointments);

        // 각 날짜별로 순회하면서 task 찾기
        appointmentsMap.forEach((dateKey, dateData) {
          final appointments = dateData['appointments'] as List;
          for (var i = 0; i < appointments.length; i++) {
            if (appointments[i]['id'] == taskId) {
              // task를 찾으면 isDone을 true로 업데이트
              appointments[i]['isDone'] = true;
              // taskAlldayCount 감소 (0 미만으로 내려가지 않도록)
              final currentCount = dateData['taskAlldayCount'] as int;
              dateData['taskAlldayCount'] = currentCount > 0 ? currentCount - 1 : 0;
            }
          }
        });

        // 업데이트된 데이터를 다시 저장
        HomeWidget.saveWidgetData('dateGroupedAppointments', json.encode(appointmentsMap)).then((value) {
          if (value == true) {
            Utils.updateWidgetCore();
          }
        });
      } catch (e) {}
    }

    // Supabase 초기화를 먼저 수행
    final configFile = await rootBundle.loadString('assets/config/${F.envFileName}');
    final env = Environment.fromJson(json.decode(configFile) as Map<String, dynamic>);

    try {
      await Supabase.initialize(
        url: env.supabaseUrl,
        anonKey: env.supabaseAnonKey,
        debug: kDebugMode,
        authOptions: FlutterAuthClientOptions(autoRefreshToken: true, authFlowType: AuthFlowType.pkce, detectSessionInUri: true),
      );
    } catch (e) {
      // Supabase가 이미 초기화되어 있을 수 있음
    }

    final container = ProviderContainer();

    try {
      final user = await container.read(authControllerProvider).requireValue;
      final prefValue = await container.read(localPrefControllerProvider).value;
      final pref = prefValue;

      if (user.isSignedIn != true) return;

      final taskController = container.read(taskListControllerProvider.notifier);
      await taskController.refresh(pref: pref, user: user);
      await taskController.toggleTaskStatusOnBackground(
        taskId: taskId,
        recurringTaskId: recurringTaskId ?? '',
        startAtMs: int.parse(startAtMs ?? '0'),
        endAtMs: int.parse(endAtMs ?? '0'),
      );
    } catch (e) {
      // 에러 처리
    }
  }
}
