import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/showcase_tutorial/showcase_tutorial.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/auth/presentation/screens/auth_screen.dart';
import 'package:Visir/features/common/presentation/screens/expired_screen.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/desktop_sidbar.dart';
import 'package:Visir/features/common/presentation/widgets/desktop_title_bar.dart';
import 'package:Visir/features/common/presentation/widgets/keyboard_shortcut.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/preference/presentation/screens/preference_screen.dart';
import 'package:auto_updater/auto_updater.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DesktopCard extends StatelessWidget {
  final Widget child;
  final bool? withShadow;
  final Color? backgroundColor;
  final bool forceCard;
  final bool? removeTopBorderRadius;
  final bool? removeBottomBorderRadius;

  const DesktopCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.withShadow = false,
    this.forceCard = false,
    this.removeTopBorderRadius = false,
    this.removeBottomBorderRadius = false,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformX.isMobileView && !forceCard)
      return ClipRRect(
        borderRadius: BorderRadius.vertical(
          top: removeTopBorderRadius == true ? Radius.zero : Radius.circular(20),
          bottom: removeBottomBorderRadius == true ? Radius.zero : Radius.circular(20),
        ),
        child: Container(color: context.background, child: child),
      );

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.vertical(
          top: removeTopBorderRadius == true ? Radius.zero : Radius.circular(DesktopScaffold.cardRadius),
          bottom: removeBottomBorderRadius == true ? Radius.zero : Radius.circular(DesktopScaffold.cardRadius),
        ),
        boxShadow: withShadow == true ? PopupMenu.popupShadow : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(
          top: removeTopBorderRadius == true ? Radius.zero : Radius.circular(DesktopScaffold.cardRadius),
          bottom: removeBottomBorderRadius == true ? Radius.zero : Radius.circular(DesktopScaffold.cardRadius),
        ),
        child: child,
      ),
    );
  }
}

class DesktopScaffold extends ConsumerStatefulWidget {
  final List<TabType> desktopTabValues;

  static const double backgroundPadding = 8;
  static const double cardPadding = 6;
  static const double cardRadius = 8;

  const DesktopScaffold({super.key, required this.desktopTabValues});

  @override
  ConsumerState<DesktopScaffold> createState() => _DesktopScaffoldState();
}

class _DesktopScaffoldState extends ConsumerState<DesktopScaffold> {
  // static const _channel = MethodChannel('app.menu');

  late PageController controller;
  final _pageViewKey = ValueKey('desktop_page_view');

  bool get isSignedIn => ref.read(isSignedInProvider);

  @override
  void initState() {
    super.initState();
    controller = PageController(initialPage: widget.desktopTabValues.indexOf(tabNotifier.value));
    tabNotifier.addListener(onTabChanged);
    FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
    isShowcaseOn.addListener(onShowcaseOnChanged);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      updatePlatformMenuItems();
    });
  }

  @override
  void didUpdateWidget(DesktopScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    // desktopTabValues가 변경되면 PageController 재생성
    if (oldWidget.desktopTabValues != widget.desktopTabValues) {
      final currentPage = controller.hasClients ? controller.page?.round() ?? 0 : 0;
      controller.dispose();
      controller = PageController(initialPage: currentPage < widget.desktopTabValues.length ? currentPage : 0);
    }
  }

  void onShowcaseOnChanged() {
    if (isShowcaseOn.value == inboxListDescriptionShowcaseKeyString ||
        isShowcaseOn.value == inboxItemShowcaseKeyString ||
        isShowcaseOn.value == taskCalendarShowcaseKeyString ||
        isShowcaseOn.value == taskOnCalendarShowcaseKeyString ||
        isShowcaseOn.value == taskLinkedMailShowcaseKeyString ||
        isShowcaseOn.value == taskLinkedChatShowcaseKeyString ||
        isShowcaseOn.value == taskLinkedMailDetailShowcaseKeyString ||
        isShowcaseOn.value == taskLinkedChatDetailShowcaseKeyString) {
      tabNotifier.value = TabType.home;
    }

    if (isShowcaseOn.value == taskTabShowcaseKeyString) {
      Navigator.of(Utils.mainContext).popUntil((route) => route.isFirst);
      tabNotifier.value = TabType.task;
    }

    if (isShowcaseOn.value == mailTabShowcaseKeyString || isShowcaseOn.value == mailCreateTaskShowcaseKeyString) {
      tabNotifier.value = TabType.mail;
    }

    if (isShowcaseOn.value == chatTabShowcaseKeyString || isShowcaseOn.value == chatCreateTaskShowcaseKeyString) {
      tabNotifier.value = TabType.chat;
    }

    if (isShowcaseOn.value == calendarTabShowcaseKeyString) {
      tabNotifier.value = TabType.calendar;
    }
  }

  void onTabChanged() {
    controller.jumpToPage(widget.desktopTabValues.indexOf(tabNotifier.value));
  }

  @override
  void dispose() {
    tabNotifier.removeListener(onTabChanged);
    isShowcaseOn.removeListener(onShowcaseOnChanged);
    controller.dispose();
    super.dispose();
  }

  void scaleUp() {
    if (kIsWeb) return;
    if (PlatformX.isMobileView) return;
    final ratio = Utils.ref.read(zoomRatioProvider);
    Utils.ref.read(zoomRatioProvider.notifier).setRatio(ratio + 0.05);
  }

  void scaleDown() {
    if (kIsWeb) return;
    if (PlatformX.isMobileView) return;
    final ratio = Utils.ref.read(zoomRatioProvider);
    Utils.ref.read(zoomRatioProvider.notifier).setRatio(ratio - 0.05);
  }

  void scaleZero() {
    if (kIsWeb) return;
    if (PlatformX.isMobileView) return;
    Utils.ref.read(zoomRatioProvider.notifier).setRatio(1);
  }

  bool _onKeyDown(KeyEvent event, {bool? justReturnResult}) {
    // if (inboxSelectedItemWidget.value != null) return false;

    final logicalKeyPressed = ServicesBinding.instance.keyboard.logicalKeysPressed.where((e) => e != LogicalKeyboardKey.escape).toList();

    if (logicalKeyPressed.length == 2) {
      if ((logicalKeyPressed.isMetaPressed && PlatformX.isApple) || (logicalKeyPressed.isControlPressed && !PlatformX.isApple)) {
        if (logicalKeyPressed.contains(LogicalKeyboardKey.minus)) {
          if (justReturnResult == true) return true;
          if (!isSignedIn) return true;
          scaleDown();
          return true;
        }
        if (logicalKeyPressed.contains(LogicalKeyboardKey.equal)) {
          if (justReturnResult == true) return true;
          if (!isSignedIn) return true;
          scaleUp();
          return true;
        }
        if (logicalKeyPressed.contains(LogicalKeyboardKey.digit0)) {
          if (justReturnResult == true) return true;
          if (!isSignedIn) return true;
          scaleZero();
          return true;
        }
        if (logicalKeyPressed.contains(LogicalKeyboardKey.keyW)) {
          if (justReturnResult == true) return true;
          if (!PlatformX.isWeb && PlatformX.isDesktop) {
            appWindow.close();
          }
          return true;
        }
      }
    }

    if (ServicesBinding.instance.keyboard.logicalKeysPressed.length == 1 && event.logicalKey == LogicalKeyboardKey.escape) {
      if (Navigator.of(Utils.mainContext).canPop()) {
        Navigator.of(Utils.mainContext).maybePop();
        return true;
      }
    }

    return false;
  }

  void updatePlatformMenuItems() {
    if (PlatformX.isWindows) return;
    final user = ref.read(authControllerProvider).requireValue;
    WidgetsBinding.instance.platformMenuDelegate.setMenus([
      PlatformMenu(
        label: 'Visir',
        menus: <PlatformMenuItem>[
          PlatformMenuItemGroup(members: [PlatformProvidedMenuItem(type: PlatformProvidedMenuItemType.about)]),
          PlatformMenuItemGroup(members: [PlatformProvidedMenuItem(type: PlatformProvidedMenuItemType.servicesSubmenu)]),
          PlatformMenuItemGroup(
            members: [
              if (user.isSignedIn)
                PlatformMenuItem(
                  label: context.tr.preferences_title,
                  shortcut: const SingleActivator(LogicalKeyboardKey.comma, meta: true),
                  onSelected: () async {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    Utils.showPopupDialog(
                      child: PreferenceScreen(key: Utils.preferenceScreenKey),
                      size: Size(640, 560),
                    );
                  },
                ),
              PlatformMenuItem(
                label: context.tr.version_check_for_updates,
                onSelected: () async {
                  await autoUpdater.checkForUpdates();
                },
              ),
            ],
          ),
          PlatformMenuItemGroup(
            members: [
              PlatformProvidedMenuItem(type: PlatformProvidedMenuItemType.hide),
              PlatformProvidedMenuItem(type: PlatformProvidedMenuItemType.hideOtherApplications),
              PlatformProvidedMenuItem(type: PlatformProvidedMenuItemType.showAllApplications),
            ],
          ),

          PlatformMenuItemGroup(members: [PlatformProvidedMenuItem(type: PlatformProvidedMenuItemType.quit)]),
        ],
      ),
      PlatformMenu(
        label: context.tr.edit,
        menus: [
          PlatformProvidedMenuItem(type: PlatformProvidedMenuItemType.startSpeaking),
          PlatformProvidedMenuItem(type: PlatformProvidedMenuItemType.stopSpeaking),
        ],
      ),
      PlatformMenu(
        label: context.tr.view,
        menus: [PlatformProvidedMenuItem(type: PlatformProvidedMenuItemType.toggleFullScreen)],
      ),
      PlatformMenu(
        label: context.tr.window,
        menus: [
          PlatformMenuItemGroup(
            members: [
              PlatformProvidedMenuItem(type: PlatformProvidedMenuItemType.minimizeWindow),
              PlatformProvidedMenuItem(type: PlatformProvidedMenuItemType.zoomWindow),
            ],
          ),
          PlatformMenuItemGroup(members: [PlatformProvidedMenuItem(type: PlatformProvidedMenuItemType.arrangeWindowsInFront)]),
        ],
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeSwitchProvider);
    bool isSignedIn = ref.watch(authControllerProvider.select((v) => v.requireValue.isSignedIn));
    bool onSubscription = ref.watch(authControllerProvider.select((v) => v.requireValue.onSubscription));
    Utils.setMainContext(context, force: true, ref: ref);

    final padding = DesktopScaffold.backgroundPadding;

    final child = MediaQuery(
      data: context.mediaQuery.copyWith(textScaler: context.textScaler.clamp(minScaleFactor: 0.8, maxScaleFactor: 1.5)),
      child: KeyboardShortcut(
        bypassMailEditScreen: true,
        onKeyDown: _onKeyDown,
        child: Container(
          color: context.isDarkMode ? context.background : context.surface,
          child: Stack(
            children: [
              Positioned.fill(child: meshLoadingBackground),
              Positioned.fill(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    DesktopTitleBar(isExpired: !onSubscription),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: padding, right: padding, left: padding),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            DesktopSidebar(desktopTabValues: widget.desktopTabValues),
                            SizedBox(width: DesktopScaffold.cardPadding),
                            Expanded(
                              child: ExcludeFocusTraversal(
                                child: PageView(
                                  key: _pageViewKey,
                                  controller: controller,
                                  scrollDirection: Axis.vertical,
                                  children: widget.desktopTabValues.map((e) => e.getScreen(context)).toList(),
                                  physics: NeverScrollableScrollPhysics(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!onSubscription && isSignedIn) Positioned.fill(child: ExpiredScreen()),
            ],
          ),
        ),
      ),
    );

    if (!isSignedIn)
      return ShowCaseWidget(
        onStart: (index, key) {
          if (index != 0) return;
          isShowcaseOn.value = getShowcaseEntities().entries.firstWhereOrNull((e) => e.value.key == key)?.key;
        },
        onComplete: (index, key) {
          index = index ?? 0;
          if (index + 1 < ShowCaseWidget.of(Utils.mainContext).ids!.length) {
            final nextKey = ShowCaseWidget.of(Utils.mainContext).ids?[index + 1];
            isShowcaseOn.value = getShowcaseEntities().entries.firstWhereOrNull((e) => e.value.key == nextKey)?.key;
          }
        },
        onFinish: () {
          isShowcaseOn.value = null;
          Navigator.of(Utils.mainContext).popUntil((route) => route.isFirst);
          Utils.showPopupDialog(child: AuthScreen(), size: Size(480, 600));
        },
        blurValue: 0,
        builder: Builder(
          builder: (context) {
            Utils.setMainContext(context, force: true, ref: ref);
            return child;
          },
        ),
      );

    return child;
  }
}
