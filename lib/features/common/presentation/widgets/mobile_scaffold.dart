import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/draggable_float_widget/src/enum_state_event.dart';
import 'package:Visir/dependency/modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:Visir/dependency/showcase_tutorial/src/showcase_widget.dart';
import 'package:Visir/dependency/toasty_box/model/toast_model.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/chat/presentation/screens/chat_screen.dart';
import 'package:Visir/features/common/presentation/screens/expired_screen.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/mobile_tab_item.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/common/presentation/widgets/tourlist_widget.dart';
import 'package:Visir/features/common/provider.dart' hide TextScaler;
import 'package:Visir/features/mail/presentation/screens/mail_screen.dart';
import 'package:Visir/features/task/presentation/screens/task_screen.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final kMainTabBarHeight = 52.0;
final kMobileDevicePixelRatio = 1.2;

ScrollController? modalScrollController;

class MobileScaffold extends ConsumerStatefulWidget {
  final List<TabType> mobileTabValues;

  static ValueNotifier<bool> largeTabBar = ValueNotifier(true);
  static double bottomPaddingForSmallTabBar = 0;
  static double bottomPaddingForLargeTabBar = 0;

  const MobileScaffold({super.key, required this.mobileTabValues});

  @override
  ConsumerState<MobileScaffold> createState() => _MobileScaffoldState();
}

class _MobileScaffoldState extends ConsumerState<MobileScaffold> {
  late PageController controller;
  late PageController tabController;
  GlobalKey<MailScreenState> mailScreenKey = GlobalKey();
  GlobalKey<ChatScreenState> chatScreenKey = GlobalKey();
  GlobalKey<TaskScreenState> taskScreenKey = GlobalKey();
  bool showInboxCalendarPopupOnMobile = false;

  GlobalKey smallTabScrollKey = GlobalKey();
  final _pageViewKey = ValueKey('mobile_page_view');

  StreamController<OperateEvent> eventStreamController = StreamController.broadcast();

  final showcaseKeys = [
    inboxListDescriptionShowcaseKeyString,
    inboxItemShowcaseKeyString,
    taskCalendarShowcaseKeyString,
    taskOnCalendarShowcaseKeyString,
    taskLinkedMailShowcaseKeyString,
    taskLinkedMailDetailShowcaseKeyString,
    taskLinkedChatShowcaseKeyString,
    taskLinkedChatDetailShowcaseKeyString,
    taskTabShowcaseKeyString,
    mailTabShowcaseKeyString,
    mailCreateTaskShowcaseKeyString,
    chatTabShowcaseKeyString,
    chatCreateTaskShowcaseKeyString,
  ];

  final tabItemSmallWidth = 80;
  final tabItemSmallHeight = 32;

  double? deviceWidth;

  BuildContext? scrollableContext;

  @override
  void initState() {
    super.initState();

    if (PlatformX.isAndroid) BackButtonInterceptor.add(onBackButtonPressed);

    tabNotifier.value = TabType.home;
    controller = PageController(initialPage: widget.mobileTabValues.indexOf(tabNotifier.value));
    tabController = PageController(initialPage: widget.mobileTabValues.indexOf(tabNotifier.value));
    tabNotifier.addListener(onTabChanged);
    isShowcaseOn.addListener(onShowcaseOnChanged);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      tabController.addListener(onTabControllerChanged);
    });
  }

  void onTabControllerChanged() {
    final pageOffset = tabController.offset / tabItemSmallWidth * (deviceWidth ?? context.width);
    controller.jumpTo(pageOffset);

    final index = tabController.offset / tabItemSmallWidth;
    if (index.round().toDouble() == index) {
      tabNotifier.value = widget.mobileTabValues[index.round()];
    }
  }

  void onTabChanged() {
    controller.jumpToPage(widget.mobileTabValues.indexOf(tabNotifier.value));
    tabController.jumpToPage(widget.mobileTabValues.indexOf(tabNotifier.value));
  }

  @override
  void didUpdateWidget(MobileScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    // mobileTabValues가 변경되면 PageController 재생성
    if (oldWidget.mobileTabValues != widget.mobileTabValues) {
      final currentPage = controller.hasClients ? controller.page?.round() ?? 0 : 0;
      controller.dispose();
      tabController.dispose();
      controller = PageController(initialPage: currentPage < widget.mobileTabValues.length ? currentPage : 0);
      tabController = PageController(initialPage: currentPage < widget.mobileTabValues.length ? currentPage : 0);
    }
  }

  @override
  void dispose() {
    if (PlatformX.isAndroid) BackButtonInterceptor.remove(onBackButtonPressed);
    isShowcaseOn.removeListener(onShowcaseOnChanged);
    tabController.removeListener(onTabControllerChanged);
    tabNotifier.removeListener(onTabChanged);
    controller.dispose();
    tabController.dispose();
    eventStreamController.close(); // Memory optimization: close StreamController
    backButtonExitTimer?.cancel(); // Memory optimization: cancel timer
    super.dispose();
  }

  void onShowcaseOnChanged() {
    if (isShowcaseOn.value == taskCalendarShowcaseKeyString ||
        isShowcaseOn.value == taskOnCalendarShowcaseKeyString ||
        isShowcaseOn.value == taskLinkedMailShowcaseKeyString ||
        isShowcaseOn.value == taskLinkedChatShowcaseKeyString ||
        isShowcaseOn.value == taskLinkedMailDetailShowcaseKeyString ||
        isShowcaseOn.value == taskLinkedChatDetailShowcaseKeyString) {
      tabNotifier.value = TabType.calendar;
    }

    if (isShowcaseOn.value == inboxListDescriptionShowcaseKeyString || isShowcaseOn.value == inboxItemShowcaseKeyString) {
      Navigator.of(Utils.mainContext).popUntil((route) => route.isFirst);
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
  }

  Future<void> onUpdateVisibilitiyCalendarOnMobile(bool showCalendar) async {
    if (!showCalendar) {
      await Future.delayed(const Duration(milliseconds: 500));
    }
    showInboxCalendarPopupOnMobile = showCalendar;
    setState(() {});
  }

  Timer? backButtonExitTimer;
  bool isBackButtonPressed = false;
  bool onBackButtonPressed(bool stopDefaultButtonEvent, RouteInfo info) {
    if (Utils.mainContext.viewInset.bottom > 0) {
      FocusScope.of(context).unfocus();
      return true;
    }

    if (modalScrollController != null && modalScrollController!.offset > 0) {
      modalScrollController!.animateTo(0, duration: const Duration(milliseconds: 150), curve: Curves.easeInOut);
      return true;
    }

    if (Navigator.maybeOf(Utils.mainContext)?.canPop() == true) {
      if ((Utils.preferenceScreenKey.currentState?.mounted ?? false) && (Utils.preferenceScreenKey.currentState?.isDetailOpened ?? false)) {
        Utils.preferenceScreenKey.currentState?.masterDetailsKey.currentState?.closeDetails();
        return true;
      }

      Navigator.maybeOf(Utils.mainContext)?.maybePop();
      return true;
    }

    if (scrollableContext != null) {
      ScrollableState? scrollableState = Scrollable.maybeOf(scrollableContext!);
      if (scrollableState != null && scrollableState.position.pixels > 0) {
        scrollableState.position.animateTo(0, duration: const Duration(milliseconds: 150), curve: Curves.easeInOut);
        return true;
      }
    }

    if (Utils.mobileTabContexts[tabNotifier.value] != null) {
      if (Navigator.of(Utils.mobileTabContexts[tabNotifier.value]!).canPop()) {
        Navigator.of(Utils.mobileTabContexts[tabNotifier.value]!).maybePop();
        return true;
      }
    }

    if (!isBackButtonPressed) {
      isBackButtonPressed = true;
      backButtonExitTimer?.cancel();
      backButtonExitTimer = Timer(const Duration(milliseconds: 3000), () {
        isBackButtonPressed = false;
      });
      Utils.showToast(
        ToastModel(
          message: TextSpan(text: context.tr.press_back_button),
          buttons: [],
        ),
      );
      return true;
    }
    return false;
  }

  Widget buildDesktopTutorialButton() {
    double borderRadius = 12;
    return Container(
      child: Row(
        children: [
          VisirButton(
            type: VisirButtonAnimationType.scaleAndOpacity,
            style: VisirButtonStyle(
              backgroundColor: context.primary,
              padding: EdgeInsets.symmetric(horizontal: 8),
              height: kButtonSize,
              boxShadow: PopupMenu.popupShadow,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(borderRadius), bottomLeft: Radius.circular(borderRadius)),
            ),
            onTap: () {
              Navigator.of(Utils.mainContext).popUntil((route) => route.isFirst);
              final keys = showcaseKeys.map((e) => getShowcaseEntities()[e]!.key).toList();
              tabNotifier.value = TabType.home;
              ShowCaseWidget.of(Utils.mainContext).startShowCase(keys);
            },
            child: Row(
              children: [
                VisirIcon(type: VisirIconType.play, size: kIconSize, color: context.onPrimary, isSelected: true),
                SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(context.tr.take_a_tour, style: context.titleMedium?.textColor(context.onPrimary)),
                ),
              ],
            ),
          ),
          Container(width: 1, color: context.outline),
          VisirButton(
            type: VisirButtonAnimationType.scaleAndOpacity,
            onTap: () {
              Utils.showPopupDialog(child: TourListWidget(showcaseKeys: showcaseKeys));
            },
            style: VisirButtonStyle(
              boxShadow: PopupMenu.popupShadow,
              backgroundColor: context.primary,
              height: kButtonSize,
              width: kButtonSize,
              borderRadius: BorderRadius.only(topRight: Radius.circular(borderRadius), bottomRight: Radius.circular(borderRadius)),
            ),
            child: VisirIcon(type: VisirIconType.list, size: kIconSize, color: context.onPrimary),
          ),
        ],
      ),
    );
  }

  double kButtonSize = 42;
  double kIconSize = 20;

  double measureTextWidth(
    String text,
    TextStyle style, {
    TextDirection textDirection = TextDirection.ltr,
    TextScaler textScaler = TextScaler.noScaling, // Flutter 3.10+
  }) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: textDirection,
      textScaler: textScaler,
      maxLines: 1, // single line
    )..layout(); // no maxWidth -> natural width
    return tp.size.width;
  }

  @override
  Widget build(BuildContext context) {
    bool isSignedIn = ref.watch(authControllerProvider.select((v) => v.requireValue.isSignedIn));
    bool onSubscription = ref.watch(authControllerProvider.select((v) => v.requireValue.onSubscription));
    ref.watch(themeSwitchProvider);

    return NotificationListener(
      onNotification: (notification) {
        if (notification is ScrollMetricsNotification) {
          scrollableContext = notification.context;
        }

        if (notification is ScrollUpdateNotification) {
          if ((notification.dragDetails?.delta.dy ?? 0) > 0) {
            MobileScaffold.largeTabBar.value = true;
          } else if ((notification.dragDetails?.delta.dy ?? 0) < 0) {
            if (!MobileScaffold.largeTabBar.value || !mounted) return true;
            MobileScaffold.largeTabBar.value = false;
          }
        }
        return true;
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(statusBarColor: Colors.transparent),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(color: context.isDarkMode ? context.background : context.surface, child: meshLoadingBackground),
            ),
            Positioned(bottom: 0, height: 20, left: 0, right: 0, child: Container(color: context.background)),
            Positioned.fill(
              child: CupertinoScaffold(
                transitionBackgroundColor: Colors.transparent,
                topRadius: Radius.circular(20),
                body: LayoutBuilder(
                  builder: (context, constraints) {
                    deviceWidth = constraints.maxWidth;
                    Utils.setMainContext(context, force: true, ref: ref);

                    return Material(
                      color: Colors.transparent,
                      child: GestureDetector(
                        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Container(
                                padding: EdgeInsets.only(top: max(context.padding.top - 8, 20)),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                  child: PageView(
                                    key: _pageViewKey,
                                    controller: controller,
                                    children: widget.mobileTabValues.map((e) {
                                      return Navigator(
                                        pages: [
                                          MaterialPage(
                                            child: Builder(
                                              builder: (context) {
                                                Utils.mobileTabContexts[e] = context;
                                                return ClipRRect(
                                                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                                  child: e.getScreen(
                                                    context,
                                                    inboxCalendarScreenKey: Constants.inboxCalendarScreenKey,
                                                    inboxListScreenKey: Constants.inboxListScreenKey,
                                                    mailScreenKey: mailScreenKey,
                                                    chatScreenKey: chatScreenKey,
                                                    taskScreenKey: taskScreenKey,
                                                    onUpdateVisibilitiyCalendarOnMobile: onUpdateVisibilitiyCalendarOnMobile,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                    physics: NeverScrollableScrollPhysics(),
                                  ),
                                ),
                              ),
                            ),
                            ValueListenableBuilder(
                              valueListenable: MobileScaffold.largeTabBar,
                              builder: (context, value, child) {
                                final largeWidth = 260.0;
                                final width = (!value ? tabItemSmallWidth.toDouble() : largeWidth);
                                final height = (!value ? tabItemSmallHeight.toDouble() : kMainTabBarHeight);

                                MobileScaffold.bottomPaddingForLargeTabBar = kMainTabBarHeight + max(20, context.padding.bottom - 3);
                                MobileScaffold.bottomPaddingForSmallTabBar = tabItemSmallHeight.toDouble() + 20;

                                return AnimatedPositioned(
                                  bottom: (value ? max(20, context.padding.bottom - 3) : 20),
                                  left: (deviceWidth! - width) / 2,
                                  right: (deviceWidth! - width) / 2,
                                  height: height.toDouble(),
                                  duration: Duration(milliseconds: 250),
                                  child: VisirButton(
                                    type: VisirButtonAnimationType.scaleAndOpacity,
                                    onTap: value
                                        ? null
                                        : () {
                                            MobileScaffold.largeTabBar.value = true;
                                          },
                                    style: VisirButtonStyle(hoverColor: Colors.transparent),
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(height / 2),
                                        child: Stack(
                                          children: [
                                            Positioned.fill(
                                              child: BackdropFilter(
                                                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                                                child: Stack(
                                                  children: [
                                                    Positioned.fill(child: meshLoadingBackground),

                                                    IgnorePointer(
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          color: context.background.withValues(alpha: 0.7),
                                                          border: Border.all(color: context.onBackground.withValues(alpha: 0.1), width: 1),
                                                          borderRadius: BorderRadius.circular(height / 2),
                                                        ),
                                                      ),
                                                    ),

                                                    Positioned.fill(
                                                      child: LayoutBuilder(
                                                        builder: (context, constraints) {
                                                          return Stack(
                                                            alignment: Alignment.center,
                                                            children: [
                                                              AnimatedPositioned(
                                                                duration: Duration(milliseconds: 250),
                                                                left: value
                                                                    ? 0
                                                                    : (largeWidth - width) / 2 * -1 +
                                                                          (largeWidth - 24) / 5 * ((widget.mobileTabValues.indexOf(tabNotifier.value) - 2.5)) * -1,
                                                                top: 0,
                                                                width: largeWidth,
                                                                bottom: 0,
                                                                child: Padding(
                                                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                                                  child: AnimatedOpacity(
                                                                    opacity: value ? 1 : 0,
                                                                    duration: Duration(milliseconds: 250),
                                                                    child: Row(
                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                      children: [...widget.mobileTabValues, null].map((e) {
                                                                        return MobileTabItem(
                                                                          tabType: e,
                                                                          inboxListScreenKey: Constants.inboxListScreenKey,
                                                                          mailScreenKey: mailScreenKey,
                                                                          chatScreenKey: chatScreenKey,
                                                                          inboxCalendarScreenKey: Constants.inboxCalendarScreenKey,
                                                                          taskScreenKey: taskScreenKey,
                                                                        );
                                                                      }).toList(),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              IgnorePointer(
                                                                ignoring: value,
                                                                child: AnimatedOpacity(
                                                                  opacity: !value ? 1 : 0,
                                                                  duration: Duration(milliseconds: 250),
                                                                  child: Container(
                                                                    width: tabItemSmallWidth.toDouble(),
                                                                    height: tabItemSmallHeight.toDouble(),
                                                                    child: SingleChildScrollView(
                                                                      key: smallTabScrollKey,
                                                                      scrollDirection: Axis.horizontal,
                                                                      controller: tabController,
                                                                      physics: PageScrollPhysics(),
                                                                      child: Row(
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        children: [
                                                                          ...widget.mobileTabValues.map((e) {
                                                                            return Container(
                                                                              width: tabItemSmallWidth.toDouble(),
                                                                              height: tabItemSmallHeight.toDouble(),
                                                                              alignment: Alignment.center,
                                                                              child: e.getVisirIcon(size: tabItemSmallHeight - 12, isSelected: true),
                                                                            );
                                                                          }).toList(),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),

                            if (!onSubscription && isSignedIn) Positioned.fill(child: ExpiredScreen()),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
