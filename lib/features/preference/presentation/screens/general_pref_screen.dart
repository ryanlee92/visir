import 'dart:io';

import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/contextmenu/src/ContextMenuArea.dart';
import 'package:Visir/dependency/custom_dialog/flutter_custom_dialog.dart';
import 'package:Visir/dependency/master_detail_flow/src/details_item.dart';
import 'package:Visir/dependency/modal_bottom_sheet/src/utils/modal_scroll_controller.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/auth/domain/entities/user_entity.dart';
import 'package:Visir/features/auth/providers.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/string_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/log_event.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/presentation/widgets/selection_widget.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/common/presentation/widgets/visir_list_item.dart';
import 'package:Visir/features/common/presentation/widgets/visir_list_section.dart';
import 'package:Visir/features/common/provider.dart' hide TextScaler;
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/presentation/screens/preference_screen.dart';
import 'package:Visir/features/preference/presentation/widgets/mobile_version_check_popup.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:auto_updater/auto_updater.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeneralPrefScreen extends ConsumerStatefulWidget {
  final bool isSmall;

  final VoidCallback? onClose;

  const GeneralPrefScreen({super.key, required this.isSmall, this.onClose});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GeneralPrefScreenState();
}

class _GeneralPrefScreenState extends ConsumerState<GeneralPrefScreen> {
  ScrollController? _scrollController;

  bool launchAtStartupEnabled = false;

  @override
  void initState() {
    super.initState();

    if (PlatformX.isPureDesktop) {
      launchAtStartup.isEnabled().then((value) {
        launchAtStartupEnabled = value;
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    widget.onClose?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scrollController ??= ModalScrollController.ofSyncGroup(context)?.addAndGet() ?? ScrollController();
    final isAdmin = ref.watch(authControllerProvider.select((v) => v.requireValue.userIsAdmin));
    final userDataOnSupabase = ref.watch(authRepositoryProvider.select((value) => value.client.auth.currentUser));
    final themeMode = ref.watch(themeSwitchProvider);
    final currentTextScaler = ref.watch(textScalerProvider);
    final homeCalendarRatio = ref.watch(homeCalendarRatioProvider);

    final buttonWidth = PreferenceScreen.buttonWidth;
    final buttonHeight = PreferenceScreen.buttonHeight;

    return LayoutBuilder(
      builder: (context, constraints) {
        return DetailsItem(
          title: widget.isSmall ? context.tr.general_title : null,
          hideBackButton: !widget.isSmall,
          appbarColor: context.background,
          bodyColor: context.background,
          scrollController: _scrollController,
          scrollPhysics: Utils.getScrollPhysicsForBottomSheet(context, _scrollController),
          children: [
            VisirListSection(
              removeTopMargin: true,
              titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: context.tr.general_pref_appearance, style: baseStyle),
            ),

            VisirListItem(
              verticalPaddingOverride: 0,
              titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: context.tr.general_theme_title, style: baseStyle),
              titleTrailingBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(
                children: [
                  WidgetSpan(
                    child: PopupMenu(
                      forcePopup: true,
                      location: PopupMenuLocation.bottom,
                      width: buttonWidth,
                      borderRadius: 6,
                      type: ContextMenuActionType.tap,
                      popup: SelectionWidget<ThemeMode>(
                        current: themeMode,
                        items: ThemeMode.values,
                        getTitle: (themeMode) => themeMode.getTitle(context),
                        onSelect: (themeMode) {
                          final user = ref.read(authControllerProvider).requireValue;
                          ref.read(themeSwitchProvider.notifier).update(themeMode);
                          Utils.updateWidgetData(themeMode: themeMode, userEmail: user.email ?? '');
                          logAnalyticsEvent(eventName: 'theme_change', properties: {'option': themeMode..getTitle(context)});
                        },
                      ),
                      style: VisirButtonStyle(
                        width: buttonWidth,
                        height: buttonHeight,
                        backgroundColor: context.surface,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 12),
                          Expanded(child: Text(themeMode.getTitle(context), style: context.bodyMedium?.textColor(context.outlineVariant))),
                          VisirIcon(type: VisirIconType.arrowDown, size: 12, color: context.outlineVariant),
                          SizedBox(width: 10),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (PlatformX.isDesktop)
              VisirListItem(
                verticalPaddingOverride: 0,
                titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: context.tr.general_text_size, style: baseStyle),
                titleTrailingBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(
                  children: [
                    WidgetSpan(
                      child: AnimatedToggleSwitch<double>.rolling(
                        current: currentTextScaler,
                        values: [0.8, 0.9, 1.0, 1.1, 1.2],
                        height: buttonHeight,
                        indicatorSize: Size(buttonWidth / 5, buttonHeight),
                        indicatorIconScale: 1,
                        iconOpacity: 0.5,
                        borderWidth: 0,
                        onChanged: (textScaler) => ref.read(textScalerProvider.notifier).update(textScaler),
                        iconBuilder: (textScaler, selected) =>
                            Text('Aa', style: context.bodyMedium?.textColor(context.onBackground), textScaler: TextScaler.linear(textScaler)),
                        style: ToggleStyle(
                          backgroundColor: context.surface,
                          borderRadius: BorderRadius.circular(6),
                          borderColor: context.surface.withValues(alpha: 1),
                          indicatorColor: context.surfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            VisirListItem(
              verticalPaddingOverride: 0,
              titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: context.tr.general_pref_hide_unread_indicator, style: baseStyle),
              titleTrailingBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(
                children: [
                  WidgetSpan(
                    child: AnimatedToggleSwitch<bool>.rolling(
                      current: ref.watch(hideUnreadIndicatorProvider),
                      values: [true, false],
                      height: buttonHeight,
                      indicatorSize: Size(buttonWidth / 2, buttonHeight),
                      indicatorIconScale: 1,
                      iconOpacity: 0.5,
                      borderWidth: 0,
                      onChanged: (hideUnreadIndicator) => ref.read(hideUnreadIndicatorProvider.notifier).update(hideUnreadIndicator),
                      iconBuilder: (hideUnreadIndicator, selected) => VisirIcon(
                        type: hideUnreadIndicator ? VisirIconType.badgeOff : VisirIconType.badgeOn,
                        size: 16,
                        color: selected
                            ? hideUnreadIndicator
                                  ? context.onBackground
                                  : context.error
                            : context.onBackground,
                        isSelected: true,
                      ),
                      style: ToggleStyle(
                        backgroundColor: context.surface,
                        borderRadius: BorderRadius.circular(6),
                        borderColor: context.surface.withValues(alpha: 1),
                        indicatorColor: context.surfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (PlatformX.isDesktopView)
              VisirListItem(
                verticalPaddingOverride: 0,
                titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: context.tr.home_calendar_default_ratio, style: baseStyle),
                titleTrailingBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(
                  children: [
                    WidgetSpan(
                      child: AnimatedToggleSwitch<String>.rolling(
                        current: homeCalendarRatio.join(' : '),
                        values: [
                          [1, 1].join(' : '),
                          [1, 2].join(' : '),
                        ],
                        height: buttonHeight,
                        indicatorSize: Size(buttonWidth / 2, buttonHeight),
                        indicatorIconScale: 1,
                        iconOpacity: 0.5,
                        borderWidth: 0,
                        onChanged: (ratio) async {
                          ref.read(homeCalendarRatioProvider.notifier).update(ratio.split(' : ').map((e) => int.parse(e)).toList());
                        },
                        iconBuilder: (ratio, selected) => Text(ratio, style: baseStyle?.textColor(selected ? context.onBackground : null)),
                        style: ToggleStyle(
                          backgroundColor: context.surface,
                          borderRadius: BorderRadius.circular(6),
                          borderColor: context.surface.withValues(alpha: 1),
                          indicatorColor: context.surfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            if (PlatformX.isPureDesktop)
              VisirListSection(
                titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: context.tr.system, style: baseStyle),
              ),

            if (PlatformX.isPureDesktop)
              VisirListItem(
                verticalPaddingOverride: 0,
                titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: context.tr.launch_at_startup, style: baseStyle),
                titleTrailingBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(
                  children: [
                    WidgetSpan(
                      child: AnimatedToggleSwitch<bool>.rolling(
                        current: launchAtStartupEnabled,
                        values: [false, true],
                        height: buttonHeight,
                        indicatorSize: Size(buttonWidth / 2, buttonHeight),
                        indicatorIconScale: 1,
                        iconOpacity: 0.5,
                        borderWidth: 0,
                        onChanged: (launchAtStartupEnabled) async {
                          this.launchAtStartupEnabled = launchAtStartupEnabled;
                          setState(() {});
                          if (launchAtStartupEnabled) {
                            await launchAtStartup.enable();
                          } else {
                            await launchAtStartup.disable();
                          }
                          launchAtStartup.isEnabled().then((value) {
                            this.launchAtStartupEnabled = value;
                            setState(() {});
                          });
                        },
                        iconBuilder: (launchAtStartupEnabled, selected) => VisirIcon(
                          type: launchAtStartupEnabled ? VisirIconType.launchAtStartupOn : VisirIconType.launchAtStartupOff,
                          size: 16,
                          color: selected
                              ? launchAtStartupEnabled
                                    ? context.onBackground
                                    : context.error
                              : context.onBackground,
                          isSelected: true,
                        ),
                        style: ToggleStyle(
                          backgroundColor: context.surface,
                          borderRadius: BorderRadius.circular(6),
                          borderColor: context.surface.withValues(alpha: 1),
                          indicatorColor: context.surfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            VisirListSection(
              titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: context.tr.preference_customize_tabs, style: baseStyle),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [TabType.calendar, TabType.task, TabType.mail, TabType.chat].map((e) {
                  return AnimatedToggleSwitch<bool>.rolling(
                    current: !ref.watch(tabHiddenProvider(e)),
                    values: [true, false],
                    height: (constraints.maxWidth - 32) / 4 - 6,
                    indicatorSize: Size(buttonHeight, (constraints.maxWidth - 32) / 4 - 6),
                    indicatorIconScale: 1,
                    iconOpacity: 0.5,
                    borderWidth: 0,
                    onChanged: (isShown) async {
                      ref.read(tabHiddenProvider(e).notifier).update(e, !isShown);
                      if (tabNotifier.value == e && !isShown) tabNotifier.value = TabType.home;
                    },
                    iconBuilder: (isShown, selected) => VisirIcon(
                      type: !isShown ? VisirIconType.close : e.getVisirIcon(size: 16).type,
                      size: 16,
                      color: selected
                          ? !isShown
                                ? context.error
                                : context.onBackground
                          : context.onBackground,
                      isSelected: isShown,
                    ),
                    style: ToggleStyle(
                      backgroundColor: context.surface,
                      borderRadius: BorderRadius.circular(6),
                      borderColor: context.surface.withValues(alpha: 1),
                      indicatorColor: context.surfaceVariant,
                    ),
                  ).vertical();
                }).toList(),
              ),
            ),

            VisirListSection(
              titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: context.tr.version_title, style: baseStyle),
            ),

            FutureBuilder(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                String? version = snapshot.data?.version;
                String? buildNumber = snapshot.data?.buildNumber;

                return VisirListItem(
                  verticalPaddingOverride: 0,
                  titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: 'v$version+$buildNumber', style: baseStyle),
                  titleTrailingBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(
                    children: [
                      WidgetSpan(
                        child: VisirButton(
                          type: VisirButtonAnimationType.scaleAndOpacity,
                          style: VisirButtonStyle(
                            cursor: SystemMouseCursors.click,
                            height: buttonHeight,
                            width: buttonWidth,
                            backgroundColor: Constants.hasProductionBuild ? context.primary : context.surface,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          onTap: () async {
                            if (PlatformX.isDesktop) {
                              await autoUpdater.checkForUpdates();
                            } else if (PlatformX.isMobile) {
                              final isLatestVersion = await Utils.isLatestVersionInMobile();
                              Utils.showPopupDialog(
                                forcePopup: true,
                                isFlexibleHeightPopup: true,
                                size: Size(300, 0),
                                child: MobileVersionCheckPopup(isLatestVersion: isLatestVersion),
                              );
                            }
                          },
                          child: Center(
                            child: Text(
                              Constants.hasProductionBuild ? context.tr.version_update_version : context.tr.version_check_for_updates,
                              style: context.bodyLarge?.textColor(context.onBackground),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            VisirListSection(
              titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: context.tr.account_title, style: baseStyle),
            ),

            VisirListItem(
              verticalPaddingOverride: 0,
              titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: context.tr.emailprovider, style: baseStyle),
              detailsBuilder: (height, baseStyle, subStyle, horizontalSpacing) =>
                  Text('${userDataOnSupabase?.email} (${userDataOnSupabase?.appMetadata['provider']?.toString().capitalize() ?? ''})', style: baseStyle),
            ),

            SizedBox(height: 8),

            VisirListItem(
              verticalPaddingOverride: 0,
              titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: context.tr.manage_account, style: baseStyle),
              detailsBuilder: (height, baseStyle, subStyle, horizontalSpacing) => Padding(
                padding: EdgeInsets.symmetric(vertical: horizontalSpacing),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: VisirButton(
                        type: VisirButtonAnimationType.scaleAndOpacity,
                        style: VisirButtonStyle(
                          cursor: SystemMouseCursors.click,
                          height: buttonHeight,
                          backgroundColor: context.surface,
                          borderRadius: BorderRadius.circular(6),
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          alignment: Alignment.centerLeft,
                        ),
                        onTap: () async {
                          Navigator.pop(Utils.mainContext);
                          await Future.delayed(Duration(milliseconds: 200));
                          Utils.ref.read(authControllerProvider.notifier).signOut();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            VisirIcon(type: VisirIconType.logout, size: 16, color: context.onBackground, isSelected: true),
                            SizedBox(width: 6),
                            Text(context.tr.account_sign_out, style: baseStyle?.textColor(context.onBackground)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: VisirButton(
                        type: VisirButtonAnimationType.scaleAndOpacity,
                        style: VisirButtonStyle(
                          cursor: SystemMouseCursors.click,
                          height: buttonHeight,
                          backgroundColor: context.error.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(6),
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          alignment: Alignment.centerLeft,
                        ),
                        onTap: () async {
                          final dialog = YYDialog().build(context)
                            ..width = 280
                            ..borderRadius = 12
                            ..backgroundColor = context.surface
                            ..text(
                              text: context.tr.delete_confirm_text,
                              color: context.onBackground,
                              fontSize: context.bodyLarge!.fontSize,
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            )
                            ..doubleButton(
                              gravity: Gravity.right,
                              text1: context.tr.cancel,
                              color1: context.primary,
                              fontSize1: context.bodyMedium?.fontSize,
                              isClickAutoDismiss: true,
                              onTap1: () async {},
                              text2: context.tr.delete_confirm_title,
                              color2: context.error,
                              fontSize2: context.bodyMedium?.fontSize,
                              onTap2: () async {
                                Navigator.of(context).popUntil((route) => route.isFirst);
                                Navigator.pop(Utils.mainContext);
                                await Future.delayed(Duration(milliseconds: 200));
                                Utils.ref.read(authControllerProvider.notifier).deleteUser();
                              },
                            );
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            dialog.show();
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            VisirIcon(type: VisirIconType.trash, size: 16, color: context.onBackground, isSelected: true),
                            SizedBox(width: 6),
                            Text(context.tr.account_delete, style: baseStyle?.textColor(context.onBackground)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (isAdmin)
              VisirListSection(
                titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: 'Debug', style: baseStyle),
              ),

            if (isAdmin)
              VisirListItem(
                verticalPaddingOverride: 0,
                titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: 'Debug DB', style: baseStyle),
                titleTrailingBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(
                  children: [
                    WidgetSpan(
                      child: AnimatedToggleSwitch<bool>.rolling(
                        current: useDebugDb,
                        values: [true, false],
                        height: PreferenceScreen.buttonHeight,
                        indicatorSize: Size(PreferenceScreen.buttonWidth / 2, PreferenceScreen.buttonHeight),
                        indicatorIconScale: 1,
                        iconOpacity: 0.5,
                        borderWidth: 0,
                        onChanged: (value) async {
                          SharedPreferences.getInstance().then((value) async {
                            await value.setBool('useDebugDb', !useDebugDb);
                            exit(0);
                          });
                        },
                        iconBuilder: (useDebugDb, selected) => VisirIcon(
                          type: useDebugDb ? VisirIconType.check : VisirIconType.close,
                          size: 16,
                          color: !selected ? context.onBackground : context.onBackground,
                          isSelected: true,
                        ),
                        style: ToggleStyle(
                          backgroundColor: context.surface,
                          borderRadius: BorderRadius.circular(6),
                          borderColor: context.surface.withValues(alpha: 1),
                          indicatorColor: context.surfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (isAdmin)
              VisirListItem(
                verticalPaddingOverride: 0,
                titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: 'Use Beta Build', style: baseStyle),
                titleTrailingBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(
                  children: [
                    WidgetSpan(
                      child: AnimatedToggleSwitch<bool>.rolling(
                        current: ref.watch(authControllerProvider.select((v) => v.requireValue.updateChannel == UpdateChannel.beta)),
                        values: [true, false],
                        height: PreferenceScreen.buttonHeight,
                        indicatorSize: Size(PreferenceScreen.buttonWidth / 2, PreferenceScreen.buttonHeight),
                        indicatorIconScale: 1,
                        iconOpacity: 0.5,
                        borderWidth: 0,
                        onChanged: (value) async {
                          final _user = ref.read(authControllerProvider).requireValue;
                          ref
                              .read(authControllerProvider.notifier)
                              .updateUser(user: _user.copyWith(updateChannel: value ? UpdateChannel.beta : UpdateChannel.stable));
                        },
                        iconBuilder: (value, selected) => VisirIcon(
                          type: value ? VisirIconType.check : VisirIconType.close,
                          size: 16,
                          color: !selected ? context.onBackground : context.onBackground,
                          isSelected: true,
                        ),
                        style: ToggleStyle(
                          backgroundColor: context.surface,
                          borderRadius: BorderRadius.circular(6),
                          borderColor: context.surface.withValues(alpha: 1),
                          indicatorColor: context.surfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
