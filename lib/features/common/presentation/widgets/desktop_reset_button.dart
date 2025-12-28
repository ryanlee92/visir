import 'dart:async';

import 'package:Visir/config/providers.dart';
import 'package:Visir/features/calendar/application/calendar_event_list_controller.dart';
import 'package:Visir/features/calendar/application/calendar_list_controller.dart';
import 'package:Visir/features/chat/application/chat_channel_list_controller.dart';
import 'package:Visir/features/chat/application/chat_list_controller.dart';
import 'package:Visir/features/chat/application/chat_thread_list_controller.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/widgets/custom_circualr_loading_indicator.dart';
import 'package:Visir/features/common/presentation/widgets/desktop_scaffold.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/inbox/application/inbox_controller.dart';
import 'package:Visir/features/mail/application/mail_label_list_controller.dart';
import 'package:Visir/features/mail/application/mail_list_controller.dart';
import 'package:Visir/features/task/application/calendar_task_list_controller.dart';
import 'package:Visir/features/task/application/task_list_controller.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DesktopResetButton extends ConsumerStatefulWidget {
  const DesktopResetButton({super.key}) : super();

  @override
  DesktopResetButtonState createState() => DesktopResetButtonState();
}

class DesktopResetButtonState extends ConsumerState<DesktopResetButton> with SingleTickerProviderStateMixin {
  AnimationController? animationController;
  Animation<Color?>? colorAnimation;

  bool get isDarkMode => context.isDarkMode;
  late StreamSubscription<List<ConnectivityResult>> connectivitySubscription;

  bool isInternetConnected = true;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(duration: const Duration(milliseconds: 1300), vsync: this);
    animationController?.addStatusListener(animationStatusListener);

    connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      if (result.contains(ConnectivityResult.mobile) ||
          result.contains(ConnectivityResult.wifi) ||
          result.contains(ConnectivityResult.ethernet) ||
          result.contains(ConnectivityResult.other) ||
          result.contains(ConnectivityResult.vpn)) {
        isInternetConnected = true;
      } else {
        isInternetConnected = false;
      }

      setState(() {});
    });
  }

  void animationStatusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      Future.delayed(Duration(milliseconds: 700), () {
        animationController?.reverse().then((value) {
          colorAnimation = null;
          setState(() {});
        });
      });
    }
  }

  void initiateColorAnimation() {
    final brightness = MediaQuery.of(context).platformBrightness;
    final themeMode = ref.read(themeSwitchProvider);
    final isDarkMode = themeMode == ThemeMode.dark || (themeMode == ThemeMode.system && brightness == Brightness.dark);

    colorAnimation = ColorTween(begin: (isDarkMode ? context.outlineVariant : context.shadow), end: context.error).animate(
      CurvedAnimation(
        parent: animationController!,
        curve: Interval(0.0, 0.3, curve: Curves.easeInOut),
        reverseCurve: Interval(0.7, 1.0, curve: Curves.easeInOut),
      ),
    );
  }

  Future<void> refresh() async {
    switch (tabNotifier.value) {
      case TabType.home:
        await refreshHome();
        break;
      case TabType.calendar:
        await refreshCalendar();
        break;
      case TabType.chat:
        await refreshChat();
        break;
      case TabType.mail:
        await refreshMail();
        break;
      case TabType.task:
        await refreshTask();
        break;
    }
  }

  Future<void> refreshHome() async {
    final tabType = tabNotifier.value;
    if (tabNotifier.value != TabType.home) return;
    Completer<void> completer = Completer<void>();
    int result = 0;
    if (ref.exists(inboxControllerProvider)) {
      ref.read(inboxControllerProvider.notifier).refresh().whenComplete(() {
        result++;
        if (result == 4) completer.complete();
      });
    } else {
      result++;
      if (result == 4) completer.complete();
    }

    if (ref.exists(calendarListControllerProvider)) {
      ref.read(calendarListControllerProvider.notifier).load().whenComplete(() {
        result++;
        if (ref.exists(calendarEventListControllerProvider(tabType: tabType))) {
          ref.read(calendarEventListControllerProvider(tabType: tabType).notifier).load().whenComplete(() {
            result++;
            if (result == 4) completer.complete();
          });
        } else {
          result++;
          if (result == 4) completer.complete();
        }
      });
    } else {
      result++;
      if (result == 4) completer.complete();
    }

    if (ref.exists(calendarTaskListControllerProvider(tabType: tabType))) {
      ref.read(calendarTaskListControllerProvider(tabType: tabType).notifier).load().whenComplete(() {
        result++;
        if (result == 4) completer.complete();
      });
    } else {
      result++;
      if (result == 4) completer.complete();
    }
    return completer.future;
  }

  Future<void> refreshCalendar() async {
    final tabType = tabNotifier.value;
    if (tabNotifier.value != TabType.calendar) return;
    Completer<void> completer = Completer<void>();
    int result = 0;
    if (ref.exists(calendarListControllerProvider)) {
      ref.read(calendarListControllerProvider.notifier).load().whenComplete(() {
        result++;
        if (ref.exists(calendarEventListControllerProvider(tabType: tabType))) {
          ref.read(calendarEventListControllerProvider(tabType: tabType).notifier).load().whenComplete(() {
            result++;
            if (result == 3) completer.complete();
          });
        } else {
          result++;
          if (result == 3) completer.complete();
        }
      });
    } else {
      result++;
      if (result == 3) completer.complete();
    }

    if (ref.exists(calendarTaskListControllerProvider(tabType: tabType))) {
      ref.read(calendarTaskListControllerProvider(tabType: tabType).notifier).load().whenComplete(() {
        result++;
        if (result == 3) completer.complete();
      });
    } else {
      result++;
      if (result == 3) completer.complete();
    }
    return completer.future;
  }

  Future<void> refreshChat() async {
    final tabType = tabNotifier.value;
    if (tabNotifier.value != TabType.chat) return;

    Completer<void> completer = Completer<void>();
    int result = 0;
    if (ref.exists(chatChannelListControllerProvider)) {
      ref.read(chatChannelListControllerProvider.notifier).load().whenComplete(() {
        result++;
        if (ref.exists(chatListControllerProvider(tabType: tabType))) {
          ref.read(chatListControllerProvider(tabType: tabType).notifier).loadRecent().whenComplete(() {
            result++;
            if (result == 3) completer.complete();
          });
        } else {
          result++;
          if (result == 3) completer.complete();
        }
        if (ref.exists(chatThreadListControllerProvider(tabType: tabType))) {
          ref.read(chatThreadListControllerProvider(tabType: tabType).notifier).load().whenComplete(() {
            result++;
            if (result == 3) completer.complete();
          });
        } else {
          result++;
          if (result == 3) completer.complete();
        }
      });
    } else {
      result++;
      if (result == 3) completer.complete();
    }

    return completer.future;
  }

  Future<void> refreshMail() async {
    if (tabNotifier.value != TabType.mail) return;

    Completer<void> completer = Completer<void>();
    int result = 0;
    if (ref.exists(mailLabelListControllerProvider)) {
      ref.read(mailLabelListControllerProvider.notifier).load().whenComplete(() {
        result++;
        if (ref.exists(mailListControllerProvider)) {
          ref.read(mailListControllerProvider.notifier).refresh().whenComplete(() {
            result++;
            if (result == 2) completer.complete();
          });
        } else {
          result++;
          if (result == 2) completer.complete();
        }
      });
    } else {
      result++;
      if (result == 2) completer.complete();
    }
    return completer.future;
  }

  Future<void> refreshTask() async {
    if (tabNotifier.value != TabType.task) return;

    Completer<void> completer = Completer<void>();
    int result = 0;
    if (ref.exists(taskListControllerProvider)) {
      ref.read(taskListControllerProvider.notifier).refresh().whenComplete(() {
        result++;
        if (result == 1) completer.complete();
      });
    } else {
      result++;
      if (result == 1) completer.complete();
    }
    return completer.future;
  }

  @override
  void dispose() {
    animationController?.removeStatusListener(animationStatusListener);
    animationController?.dispose();
    connectivitySubscription.cancel();
    super.dispose();
  }

  void setErrorIndicator() async {
    EasyDebounce.debounce('errorAnimResetButton', Duration(milliseconds: 1000), () async {
      initiateColorAnimation();
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {});
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          animationController?.forward();
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: tabNotifier,
      builder: (context, tabType, child) {
        ref.watch(loadingStatusProvider);
        bool isLoading = ref.watch(loadingStatusProvider.notifier).isLoading(tabType);
        bool isError = ref.watch(loadingStatusProvider.notifier).isError(tabType);
        if (isError) setErrorIndicator();

        return VisirButton(
          key: Key('refreshButton_${isLoading}_${isError}'),
          type: VisirButtonAnimationType.scaleAndOpacity,
          style: VisirButtonStyle(
            cursor: SystemMouseCursors.click,
            height: 32,
            width: 32,
            padding: const EdgeInsets.all(5),
            backgroundColor: context.background,
            borderRadius: BorderRadius.circular(DesktopScaffold.cardRadius),
          ),
          options: VisirButtonOptions(
            shortcuts: [
              VisirButtonKeyboardShortcut(
                message: context.tr.refresh,
                keys: [LogicalKeyboardKey.keyR, if (PlatformX.isApple) LogicalKeyboardKey.meta, if (!PlatformX.isApple) LogicalKeyboardKey.control],
              ),
            ],
          ),
          onTap: refresh,
          child: !ref.read(shouldUseMockDataProvider) && isLoading
              ? CustomCircularLoadingIndicator(size: 18, color: context.outlineVariant)
              : colorAnimation == null || !isInternetConnected
              ? VisirIcon(
                  type: !isInternetConnected ? VisirIconType.networkUnavailable : VisirIconType.refresh,
                  color: !isInternetConnected ? context.error : (isDarkMode ? context.outlineVariant : context.shadow),
                  size: 16,
                )
              : AnimatedBuilder(
                  animation: colorAnimation!,
                  builder: (context, child) {
                    return VisirIcon(type: VisirIconType.refresh, color: colorAnimation!.value, size: 16);
                  },
                ),
        );
      },
    );
  }
}
