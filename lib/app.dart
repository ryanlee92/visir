import 'dart:async';

import 'package:Visir/bootstrap.dart';
import 'package:Visir/config/platform_registry_windows.dart';
import 'package:Visir/config/providers.dart';
import 'package:Visir/config/router.dart';
import 'package:Visir/config/theme.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/auth/presentation/screens/auth_wrapper.dart';
import 'package:Visir/features/common/presentation/screens/error_screen.dart';
import 'package:Visir/features/common/presentation/screens/keep_provider_widget.dart';
import 'package:Visir/features/common/presentation/screens/main_screen.dart';
import 'package:Visir/features/common/presentation/screens/splash_screen.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/screenshot_generator.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/desktop_scaffold.dart';
import 'package:Visir/features/common/presentation/widgets/keyboard_shortcut.dart';
import 'package:Visir/features/common/provider.dart' hide TextScaler;
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/l10n/app_localizations.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:screenshot/screenshot.dart';

class ExampleApp extends ConsumerStatefulWidget {
  const ExampleApp({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ExampleAppState();
}

class _ExampleAppState extends ConsumerState<ExampleApp> {
  final titlebarChannel = const MethodChannel('custom/titlebar');
  bool initialized = false;
  Timer? _timer;
  GoRouter? router;
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await bootstrap(WidgetsBinding.instance, ref.container);

      initialized = true;
      setState(() {});

      if (PlatformX.isMobileView) {
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      }

      if (PlatformX.isDesktop) {
        // localPrefControllerProvider가 로드될 때까지 기다림
        var localPrefAsync = ref.read(localPrefControllerProvider);
        int retryCount = 0;
        while (localPrefAsync.isLoading && retryCount < 50) {
          await Future.delayed(const Duration(milliseconds: 100));
          localPrefAsync = ref.read(localPrefControllerProvider);
          retryCount++;
        }
        // 그 다음 windowSizeProvider를 읽어서 캐싱된 사이즈를 가져옴
        final rect = await ref.read(windowSizeProvider.future);
        if (PlatformX.isWindows) {
          doWhenWindowReady(() {
            onWindowReady(rect);
          });
        }

        if (PlatformX.isMacOS) {
          try {
            onWindowReady(rect);
          } catch (e) {
            doWhenWindowReady(() {
              onWindowReady(rect);
            });
          }
        }

        if (PlatformX.isMacOS) {
          _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) async {
            if (!mounted) {
              timer.cancel();
              return;
            }
            final ratio = ref.watch(zoomRatioProvider);
            await titlebarChannel.invokeMethod('updateButtonPosition', {'height': (Constants.desktopTitleBarHeight + DesktopScaffold.backgroundPadding) * ratio});
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _takeScreenshot() async {
    if (!mounted) return;

    final context = Utils.mainContext;
    final theme = Theme.of(context).brightness == Brightness.dark ? 'dark' : 'light';

    final generator = ScreenshotGenerator(controller: _screenshotController, context: context);

    await generator.saveToFile(theme: theme, pixelRatio: 2.0, delay: const Duration(milliseconds: 200));
  }

  bool _onScreenshotKeyDown(KeyEvent event) {
    if (!ref.read(shouldUseMockDataProvider)) return false;

    final logicalKeysPressed = ServicesBinding.instance.keyboard.logicalKeysPressed;
    final isModifierPressed =
        (logicalKeysPressed.contains(LogicalKeyboardKey.metaLeft) && PlatformX.isApple) || (logicalKeysPressed.contains(LogicalKeyboardKey.control) && !PlatformX.isApple);
    final isShiftPressed =
        logicalKeysPressed.contains(LogicalKeyboardKey.shift) ||
        logicalKeysPressed.contains(LogicalKeyboardKey.shiftLeft) ||
        logicalKeysPressed.contains(LogicalKeyboardKey.shiftRight);

    if (isModifierPressed && isShiftPressed && event.logicalKey == LogicalKeyboardKey.keyS) {
      _takeScreenshot();
      return true;
    }

    return false;
  }

  void onWindowReady(Rect? rect) {
    appWindow.minSize = Size(1080, 640);

    if (rect != null) {
      appWindow.size = Size(rect.width, rect.height);
      appWindow.position = Offset(rect.left, rect.top);
    } else {
      appWindow.size = Size(1280, 720);
      appWindow.alignment = Alignment.center;
    }

    appWindow.show();
    Future.delayed(const Duration(seconds: 1), () {
      WindowPositionPoller(ref: ref).start();
    });
  }

  void _configureImageCache() {
    PaintingBinding.instance.imageCache.maximumSize = 100;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 50 << 20;
  }

  @override
  Widget build(BuildContext context) {
    Utils.setMainContext(context, ref: ref);

    final textScaler = ref.watch(textScalerProvider);
    Utils.themeMode = ref.watch(themeSwitchProvider);
    Utils.lightTheme = AppTheme(Brightness.light).getThemeData(context);
    Utils.darkTheme = AppTheme(Brightness.dark).getThemeData(context);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Utils.windowSize = context.size!;
    });

    _configureImageCache();

    if (!PlatformX.isWindows) {
      FlutterNativeSplash.remove();
    }

    // auth controller의 persist 로딩 상태 확인
    final authAsync = ref.watch(authControllerProvider);
    final prefExists = ref.watch(localPrefControllerProvider.select((value) => value.value != null));

    // persist가 로딩 중이거나 값이 없으면 splash 화면 표시
    if (authAsync.isLoading || !prefExists || !initialized) {
      return SplashScreen();
    }

    final isSignedIn = ref.watch(isSignedInProvider);
    if (!isSignedIn)
      return Screenshot(
        controller: _screenshotController,
        child: KeyboardShortcut(
          onKeyDown: _onScreenshotKeyDown,
          child: MaterialApp(
            title: 'Visir',
            theme: Utils.lightTheme,
            darkTheme: Utils.darkTheme,
            themeMode: Utils.themeMode,
            localizationsDelegates: [...AppLocalizations.localizationsDelegates, FlutterQuillLocalizations.delegate],
            // routeInformationParser: router!.routeInformationParser,
            // routerDelegate: router!.routerDelegate,
            // routeInformationProvider: router!.routeInformationProvider,
            debugShowCheckedModeBanner: false,
            scrollBehavior: const ScrollBehavior().copyWith(physics: const VisirBouncingScrollPhysics()),
            builder: (context, child) {
              return MediaQuery(
                data: PlatformX.isDesktop ? context.mediaQuery.copyWith(textScaler: TextScaler.linear(textScaler)) : context.mediaQuery,
                child: const AuthWrapper(key: ValueKey('auth')),
              );
            },
          ),
        ),
      );

    router ??= GoRouter(
      routes: [
        GoRoute(
          path: '/',
          name: MainScreen.routeName,
          pageBuilder: (context, state) {
            return buildPageWithDefaultTransition(
              context: context,
              state: state,
              child: const MainScreen(key: ValueKey('main')),
            );
          },
        ),
      ],
      refreshListenable: RiverpodListenable(ref, isSignedInProvider),
      debugLogDiagnostics: kDebugMode,
      errorBuilder: (context, state) => ErrorScreen(message: 'Error'),
    );

    return Builder(
      builder: (context) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          Utils.windowSize = context.size!;
        });

        return Screenshot(
          controller: _screenshotController,
          child: KeyboardShortcut(
            onKeyDown: _onScreenshotKeyDown,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(child: KeepProviderWidget()),
                Positioned.fill(
                  child: DevicePixelRatio(
                    child: MaterialApp.router(
                      title: 'Visir',
                      theme: Utils.lightTheme,
                      darkTheme: Utils.darkTheme,
                      themeMode: Utils.themeMode,
                      localizationsDelegates: [...AppLocalizations.localizationsDelegates, FlutterQuillLocalizations.delegate],
                      routeInformationParser: router!.routeInformationParser,
                      routerDelegate: router!.routerDelegate,
                      routeInformationProvider: router!.routeInformationProvider,
                      debugShowCheckedModeBanner: false,
                      scrollBehavior: const ScrollBehavior().copyWith(physics: const VisirBouncingScrollPhysics()),
                      builder: (context, child) {
                        return MediaQuery(
                          data: PlatformX.isDesktop ? context.mediaQuery.copyWith(textScaler: TextScaler.linear(textScaler)) : context.mediaQuery,
                          child: child ?? SizedBox.shrink(),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Route observer to use with RouteAware
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

class RiverpodListenable extends ChangeNotifier {
  RiverpodListenable(this.ref, this.provider) {
    ref.listen(provider, (previous, next) {
      notifyListeners();
    });
  }

  final WidgetRef ref;
  final ProviderListenable provider;
}

class DevicePixelRatio extends ConsumerWidget {
  final Widget child;

  const DevicePixelRatio({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratio = ref.watch(zoomRatioProvider);
    return FractionallySizedBox(
      widthFactor: 1 / ratio,
      heightFactor: 1 / ratio,
      child: Transform.scale(scale: ratio, child: child),
    );
  }
}

class ReverseDevicePixelRatio extends ConsumerWidget {
  final Widget child;

  const ReverseDevicePixelRatio({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratio = ref.watch(zoomRatioProvider);
    return FractionallySizedBox(
      widthFactor: ratio,
      heightFactor: ratio,
      child: Transform.scale(scale: 1 / ratio, child: child),
    );
  }
}

class WindowPositionPoller {
  final WidgetRef ref;
  WindowPositionPoller({required this.ref});

  Offset _lastPos = appWindow.position; // Offset(dx, dy)
  Size _lastSize = appWindow.size;
  Timer? _timer;

  void start() {
    _timer ??= Timer.periodic(const Duration(milliseconds: 1000), (_) async {
      Offset now = appWindow.position;
      Size size = appWindow.size;
      if (PlatformX.isMacOS) {
        final frame = await getMacWindowFrame();
        // bitsdojo_window uses working-rect (menu bar excluded) top-left coordinates for position
        now = Offset(frame.x, frame.yTopLeftWorking);
        size = Size(frame.contentWidth, frame.contentHeight);
      } else if (PlatformX.isWindows) {
        final frame = await getWindowsWindowFrame();
        now = frame.offset;
        size = frame.size;
      }

      if (size.width == 600 && size.height == 506) return;

      if (now != _lastPos || _lastSize != size) {
        _lastPos = now;
        _lastSize = size;
        ref.read(windowSizeProvider.notifier).updateSize(Rect.fromLTWH(now.dx, now.dy, size.width, size.height));
      }
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }
}

const _ch = MethodChannel('window_info');

Future<({double x, double yTopLeft, double yTopLeftWorking, double menuBarHeight, double width, double height, double scale, double contentWidth, double contentHeight})>
getMacWindowFrame() async {
  final m = Map<String, dynamic>.from(await _ch.invokeMethod('getFrame'));
  return (
    x: (m['x'] as num).toDouble(),
    yTopLeft: (m['yTopLeft'] as num).toDouble(), // 상단-좌측 기준 Y (전체 화면)
    yTopLeftWorking: (m['yTopLeftWorking'] as num).toDouble(), // 작업 영역 기준 상단-좌측 Y
    menuBarHeight: (m['menuBarHeight'] as num).toDouble(),
    width: (m['width'] as num).toDouble(),
    height: (m['height'] as num).toDouble(),
    scale: (m['scale'] as num).toDouble(),
    contentWidth: (m['contentWidth'] as num).toDouble(),
    contentHeight: (m['contentHeight'] as num).toDouble(),
  );
}
