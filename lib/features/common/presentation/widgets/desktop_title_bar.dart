import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/contextmenu/src/ContextMenuArea.dart';
import 'package:Visir/dependency/showcase_tutorial/src/showcase_widget.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/calendar/application/calendar_event_list_controller.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/log_event.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/desktop_reset_button.dart';
import 'package:Visir/features/common/presentation/widgets/desktop_scaffold.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/common/presentation/widgets/tourlist_widget.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/inbox/application/inbox_controller.dart';
import 'package:Visir/features/task/application/calendar_task_list_controller.dart';
import 'package:Visir/features/time_saved/presentation/widgets/time_saved_button.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum WindowsMenuHover { minimize, maximize, close }

class DesktopTitleBar extends ConsumerStatefulWidget {
  final bool isExpired;

  DesktopTitleBar({required this.isExpired});

  @override
  _DesktopTitleBarState createState() => _DesktopTitleBarState();
}

class _DesktopTitleBarState extends ConsumerState<DesktopTitleBar> {
  final TextEditingController searchController = TextEditingController();
  final FocusNode globalSearchFocusNode = FocusNode();

  bool enableSearch = false;

  @override
  void initState() {
    super.initState();
    disableDragging();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  enableDragging() async {
    if (!PlatformX.isWeb && PlatformX.isDesktop) {
      appWindow.startDragging();
    }
  }

  disableDragging() async {}

  toggleMaximizeStatus() async {
    if (!PlatformX.isWeb && PlatformX.isDesktop) {
      appWindow.maximizeOrRestore();
    }
  }

  final showdow = BoxShadow(color: Utils.mainContext.onBackground.withValues(alpha: 0.20), blurRadius: 1, offset: Offset(0, 0), spreadRadius: 0);

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
    calendarTabShowcaseKeyString,
  ];

  Widget buildDesktopTutorialButton() {
    return SizedBox.shrink();
    return Row(
      children: [
        VisirButton(
          type: VisirButtonAnimationType.scaleAndOpacity,
          style: VisirButtonStyle(
            backgroundColor: context.primary,
            padding: EdgeInsets.symmetric(horizontal: 8),
            height: 28,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(6), bottomLeft: Radius.circular(6)),
          ),
          onTap: () async {
            await Future.wait([
              ref.read(calendarTaskListControllerProvider(tabType: TabType.home).notifier).refresh(showLoading: true, isChunkUpdate: true),
              ref.read(calendarEventListControllerProvider(tabType: TabType.home).notifier).refresh(showLoading: true, isChunkUpdate: true),
            ]);

            Navigator.of(Utils.mainContext).popUntil((route) => route.isFirst);
            final keys = showcaseKeys.map((e) => getShowcaseEntities()[e]!.key).toList();
            tabNotifier.value = TabType.home;
            ref.read(inboxControllerProvider.notifier).refresh();
            logAnalyticsEvent(eventName: 'onboarding_tutorial_button');
            await Future.delayed(Duration(milliseconds: 1000));
            ShowCaseWidget.of(Utils.mainContext).startShowCase(keys);
          },
          child: Row(
            children: [
              VisirIcon(type: VisirIconType.play, size: 16, color: context.onPrimary, isSelected: true),
              SizedBox(width: 8),
              Text(context.tr.take_a_tour, style: context.bodyMedium?.textColor(context.onPrimary)),
            ],
          ),
        ),
        SizedBox(width: 1),
        PopupMenu(
          type: ContextMenuActionType.tap,
          location: PopupMenuLocation.bottom,
          height: 400,
          popup: SizedBox(height: 400, child: TourListWidget(showcaseKeys: showcaseKeys)),
          style: VisirButtonStyle(
            backgroundColor: context.primary,
            height: 28,
            width: 28,
            borderRadius: BorderRadius.only(topRight: Radius.circular(6), bottomRight: Radius.circular(6)),
          ),
          child: VisirIcon(type: VisirIconType.list, size: 16, color: context.onPrimary),
        ),
      ],
    );
  }

  Widget buildDesktopThemeButton() {
    return VisirButton(
      type: VisirButtonAnimationType.scaleAndOpacity,
      style: VisirButtonStyle(
        cursor: SystemMouseCursors.click,
        height: 32,
        width: 32,
        margin: EdgeInsets.only(right: DesktopScaffold.cardPadding, left: DesktopScaffold.cardPadding),
        backgroundColor: context.background,
        borderRadius: BorderRadius.circular(DesktopScaffold.cardRadius),
      ),

      onTap: () async {
        ref.read(themeSwitchProvider.notifier).update(context.isDarkMode ? ThemeMode.light : ThemeMode.dark);
      },
      child: VisirIcon(
        type: context.isDarkMode ? VisirIconType.dark : VisirIconType.light,
        color: context.isDarkMode ? context.secondaryContainer : context.primaryContainer,
        size: context.isDarkMode ? 16 : 20,
        isSelected: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isSignedIn = ref.watch(authControllerProvider.select((v) => v.requireValue.isSignedIn));
    return Material(
      color: Colors.transparent,
      child: Container(
        color: widget.isExpired ? context.surface : null,
        width: double.infinity,
        height: 32 + DesktopScaffold.backgroundPadding + DesktopScaffold.cardPadding,
        padding: EdgeInsets.only(top: DesktopScaffold.backgroundPadding, bottom: DesktopScaffold.cardPadding),
        child: Stack(
          children: [
            Positioned.fill(
              child: Row(
                children: [
                  if (PlatformX.isWindows && !widget.isExpired) TimeSavedButton(key: Constants.timeSavedButtonKey),
                  if (PlatformX.isWindows && !widget.isExpired && isSignedIn) DesktopResetButton(),
                  if (PlatformX.isWindows) buildDesktopThemeButton(),
                  if (PlatformX.isWindows && !widget.isExpired && !isSignedIn) buildDesktopTutorialButton(),
                  Expanded(
                    child: GestureDetector(
                      onPanEnd: (details) {
                        disableDragging();
                      },
                      onPanStart: (details) {
                        enableDragging();
                      },
                      onDoubleTap: toggleMaximizeStatus,
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                  if (PlatformX.isMacOS && !widget.isExpired) buildDesktopTutorialButton(),
                  if (PlatformX.isMacOS) buildDesktopThemeButton(),
                  if (PlatformX.isMacOS && !widget.isExpired) DesktopResetButton(),
                  if (PlatformX.isMacOS && !widget.isExpired) TimeSavedButton(key: Constants.timeSavedButtonKey),
                ],
              ),
            ),
            if (!widget.isExpired)
              Positioned.fill(
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: []),
              ),
            if (PlatformX.isWindows)
              Positioned(
                top: 0,
                right: 0,
                bottom: 0,
                child: FocusScope(
                  canRequestFocus: false,
                  child: Row(
                    children: [
                      VisirButton(
                        type: VisirButtonAnimationType.scaleAndOpacity,
                        onTap: appWindow.minimize,
                        style: VisirButtonStyle(
                          cursor: SystemMouseCursors.click,
                          width: 38,
                          height: 32,
                          margin: EdgeInsets.only(right: DesktopScaffold.cardPadding),
                          alignment: Alignment.center,
                          borderRadius: BorderRadius.circular(DesktopScaffold.cardRadius),
                        ),
                        child: Icon(FluentIcons.line_horizontal_1_16_regular, size: 16, color: context.onBackground),
                      ),
                      VisirButton(
                        type: VisirButtonAnimationType.scaleAndOpacity,
                        style: VisirButtonStyle(
                          cursor: SystemMouseCursors.click,
                          width: 38,
                          height: 32,
                          margin: EdgeInsets.only(right: DesktopScaffold.cardPadding),
                          alignment: Alignment.center,
                          borderRadius: BorderRadius.circular(DesktopScaffold.cardRadius),
                        ),
                        onTap: appWindow.isMaximized == true ? appWindow.restore : appWindow.maximize,
                        child: Icon(appWindow.isMaximized == true ? FluentIcons.square_multiple_16_regular : FluentIcons.square_16_regular, size: 16, color: context.onBackground),
                      ),
                      VisirButton(
                        type: VisirButtonAnimationType.scaleAndOpacity,
                        style: VisirButtonStyle(
                          cursor: SystemMouseCursors.click,
                          width: 38,
                          height: 32,
                          margin: EdgeInsets.only(right: DesktopScaffold.backgroundPadding),
                          borderRadius: BorderRadius.circular(DesktopScaffold.cardRadius),
                          hoverColor: Color(0xffff0000),
                          alignment: Alignment.center,
                        ),
                        onTap: appWindow.close,
                        builder: (isHover) => Icon(FluentIcons.dismiss_16_regular, size: 16, color: isHover ? context.onError : context.onBackground),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
