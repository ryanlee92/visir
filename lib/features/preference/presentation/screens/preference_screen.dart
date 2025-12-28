import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/master_detail_flow/master_detail_flow.dart';
import 'package:Visir/dependency/master_detail_flow/src/widget.dart';
import 'package:Visir/dependency/modal_bottom_sheet/src/utils/modal_scroll_controller.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/auth/presentation/screens/subscription_screen.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/visir_app_bar.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/common/presentation/widgets/visir_list_item.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/presentation/screens/agent_pref_screen.dart';
import 'package:Visir/features/preference/presentation/screens/calendar_pref_screen.dart';
import 'package:Visir/features/preference/presentation/screens/chat_pref_screen.dart';
import 'package:Visir/features/preference/presentation/screens/general_pref_screen.dart';
import 'package:Visir/features/preference/presentation/screens/integration_screen.dart';
import 'package:Visir/features/preference/presentation/screens/mail_pref_screen.dart';
import 'package:Visir/features/preference/presentation/screens/notification_pref_screen.dart';
import 'package:Visir/features/preference/presentation/screens/privacy_screen.dart';
import 'package:Visir/features/preference/presentation/screens/task_pref_screen.dart';
import 'package:Visir/features/preference/presentation/screens/terms_screen.dart';
import 'package:Visir/features/task/presentation/screens/project_management_screen.dart';
import 'package:Visir/features/time_saved/application/user_action_switch_list_controller.dart';
import 'package:Visir/features/time_saved/presentation/screens/time_saved_screen.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum PreferenceScreenType { general, subscription, agent, integration, notification, project, task, mail, chat, calendar, privacy, terms, download, saved }

extension PreferenceScreenTypeX on PreferenceScreenType {
  String get id {
    switch (this) {
      case PreferenceScreenType.general:
        return 'general';
      case PreferenceScreenType.integration:
        return 'integration';
      case PreferenceScreenType.project:
        return 'project';
      case PreferenceScreenType.task:
        return 'task';
      case PreferenceScreenType.chat:
        return 'chat';
      case PreferenceScreenType.mail:
        return 'mail';
      case PreferenceScreenType.calendar:
        return 'calendar';
      case PreferenceScreenType.notification:
        return 'notification';
      case PreferenceScreenType.privacy:
        return 'privacy';
      case PreferenceScreenType.terms:
        return 'terms';
      case PreferenceScreenType.saved:
        return 'saved';
      case PreferenceScreenType.subscription:
        return 'subscription';
      case PreferenceScreenType.download:
        return 'download';
      case PreferenceScreenType.agent:
        return 'agent';
    }
  }

  String getTitle(BuildContext context, WidgetRef ref, String? savedMoneyString) {
    switch (this) {
      case PreferenceScreenType.general:
        return context.tr.general_title;
      case PreferenceScreenType.integration:
        return context.tr.integration_pref_title;
      case PreferenceScreenType.project:
        return context.tr.project_pref_title;
      case PreferenceScreenType.task:
        return context.tr.home_pref_title;
      case PreferenceScreenType.chat:
        return context.tr.chat_pref_title;
      case PreferenceScreenType.mail:
        return context.tr.mail_pref_title;
      case PreferenceScreenType.calendar:
        return context.tr.calendar_pref_title;
      case PreferenceScreenType.notification:
        return context.tr.notification_pref_title;
      case PreferenceScreenType.privacy:
        return context.tr.pref_privacy;
      case PreferenceScreenType.terms:
        return context.tr.pref_terms;
      case PreferenceScreenType.saved:
        return context.tr.time_saved_button_title(savedMoneyString ?? '0');
      case PreferenceScreenType.subscription:
        return context.tr.pref_subscription;
      case PreferenceScreenType.download:
        return PlatformX.isDesktop ? context.tr.download_for_mobile : context.tr.download_for_desktop;
      case PreferenceScreenType.agent:
        return context.tr.agent_pref_title;
    }
  }

  Color getColor(BuildContext context) {
    switch (this) {
      case PreferenceScreenType.general:
      case PreferenceScreenType.integration:
      case PreferenceScreenType.project:
      case PreferenceScreenType.notification:
      case PreferenceScreenType.task:
      case PreferenceScreenType.chat:
      case PreferenceScreenType.mail:
      case PreferenceScreenType.calendar:
      case PreferenceScreenType.privacy:
      case PreferenceScreenType.terms:
      case PreferenceScreenType.subscription:
      case PreferenceScreenType.download:
      case PreferenceScreenType.agent:
        return context.outlineVariant;
      case PreferenceScreenType.saved:
        return context.tertiary;
    }
  }

  VisirIconType? get icon {
    switch (this) {
      case PreferenceScreenType.general:
        return VisirIconType.settings;
      case PreferenceScreenType.integration:
        return VisirIconType.integration;
      case PreferenceScreenType.project:
        return VisirIconType.project;
      case PreferenceScreenType.task:
        return VisirIconType.task;
      case PreferenceScreenType.chat:
        return VisirIconType.chat;
      case PreferenceScreenType.mail:
        return VisirIconType.mail;
      case PreferenceScreenType.calendar:
        return VisirIconType.calendar;
      case PreferenceScreenType.notification:
        return VisirIconType.notification;
      case PreferenceScreenType.privacy:
        return VisirIconType.privacy;
      case PreferenceScreenType.terms:
        return VisirIconType.terms;
      case PreferenceScreenType.saved:
        return VisirIconType.trophy;
      case PreferenceScreenType.subscription:
        return VisirIconType.subscription;
      case PreferenceScreenType.download:
        return VisirIconType.download;
      case PreferenceScreenType.agent:
        return VisirIconType.agent; // Using chat icon for agent, can be changed if there's a better icon
    }
  }

  String? get assetImagePath {
    switch (this) {
      case PreferenceScreenType.general:
      case PreferenceScreenType.integration:
      case PreferenceScreenType.task:
      case PreferenceScreenType.chat:
      case PreferenceScreenType.mail:
      case PreferenceScreenType.calendar:
      case PreferenceScreenType.notification:
      case PreferenceScreenType.privacy:
      case PreferenceScreenType.terms:
      case PreferenceScreenType.saved:
      case PreferenceScreenType.subscription:
      case PreferenceScreenType.download:
      case PreferenceScreenType.project:
      case PreferenceScreenType.agent:
        return null;
    }
  }

  Widget detailsBuilder(BuildContext context, bool isSmall, VoidCallback onClose, void Function()? closeOnMobile) {
    return Builder(
      builder: (context) {
        switch (this) {
          case PreferenceScreenType.general:
            return GeneralPrefScreen(isSmall: isSmall, onClose: onClose);
          case PreferenceScreenType.integration:
            return IntegrationScreen(isSmall: isSmall, onClose: onClose);
          case PreferenceScreenType.task:
            return TaskPrefScreen(isSmall: isSmall, onClose: onClose);
          case PreferenceScreenType.chat:
            return ChatPrefScreen(isSmall: isSmall, onClose: onClose);
          case PreferenceScreenType.mail:
            return MailPrefScreen(isSmall: isSmall, onClose: onClose);
          case PreferenceScreenType.calendar:
            return CalendarPrefScreen(isSmall: isSmall, onClose: onClose);
          case PreferenceScreenType.notification:
            return NotificationPrefScreen(isSmall: isSmall, onClose: onClose);
          case PreferenceScreenType.privacy:
            return PrivacyScreen(isSmall: isSmall, onClose: onClose);
          case PreferenceScreenType.terms:
            return TermsScreen(isSmall: isSmall, onClose: onClose);
          case PreferenceScreenType.saved:
            return TimeSavedScreen(closeOnMobile: closeOnMobile);
          case PreferenceScreenType.subscription:
            return SubscriptionScreen(isSmall: isSmall, onClose: onClose);
          case PreferenceScreenType.project:
            return ProjectManagementScreen(isSmall: isSmall, onClose: onClose);
          case PreferenceScreenType.download:
            return SizedBox.shrink();
          case PreferenceScreenType.agent:
            return AgentPrefScreen(isSmall: isSmall, onClose: onClose);
        }
      },
    );
  }
}

class PreferenceScreen extends ConsumerStatefulWidget {
  static bool isOpened = false;
  static double buttonWidth = 125;
  static double buttonHeight = 36;

  final PreferenceScreenType? initialPreferenceScreenType;

  const PreferenceScreen({super.key, this.initialPreferenceScreenType});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => PreferenceScreenState();
}

class PreferenceScreenState extends ConsumerState<PreferenceScreen> {
  ScrollController? _scrollController;

  GlobalKey<MasterDetailsFlowState> masterDetailsKey = GlobalKey<MasterDetailsFlowState>();

  bool get isDetailOpened => masterDetailsKey.currentState?.selectedItem != null;

  int? get currentIndex => masterDetailsKey.currentState?.currentIndex;

  PreferenceScreenType? initialPreferenceScreenType;

  String? savedMoneyString;

  @override
  void initState() {
    super.initState();
    PreferenceScreen.isOpened = true;

    if (widget.initialPreferenceScreenType == null) {
      if (!PlatformX.isMobile) {
        switch (tabNotifier.value) {
          case TabType.task:
            initialPreferenceScreenType = PreferenceScreenType.task;
          case TabType.chat:
            initialPreferenceScreenType = PreferenceScreenType.chat;
          case TabType.mail:
            initialPreferenceScreenType = PreferenceScreenType.mail;
          case TabType.calendar:
            initialPreferenceScreenType = PreferenceScreenType.calendar;
          case TabType.home:
            initialPreferenceScreenType = PreferenceScreenType.general;
        }
      }
    } else {
      initialPreferenceScreenType = widget.initialPreferenceScreenType ?? PreferenceScreenType.general;
    }

    UserActionSwitchListControllerProviderX.savedTimeInHoursNotifier.addListener(updateMoneyString);
    updateMoneyString();
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    PreferenceScreen.isOpened = false;
    UserActionSwitchListControllerProviderX.savedTimeInHoursNotifier.removeListener(updateMoneyString);
    super.dispose();
  }

  MasterItemBase item({required PreferenceScreenType type, required int index, required int maxIndex}) {
    final messengerOAuthsNeedReAuth = ref.watch(
      localPrefControllerProvider.select((value) {
        final oauths = value.value?.messengerOAuths?.map((e) => e.needReAuth) ?? [];
        return (oauths.length == 1 || oauths.isEmpty) ? oauths.firstOrNull == true : oauths.reduce((a1, a2) => a1 == true ? a1 : a2) == true;
      }),
    );
    final mailOAuthsNeedReAuth = ref.watch(
      localPrefControllerProvider.select((value) {
        final oauths = value.value?.mailOAuths?.map((e) => e.needReAuth) ?? [];
        return (oauths.length == 1 || oauths.isEmpty) ? oauths.firstOrNull == true : oauths.reduce((a1, a2) => a1 == true ? a1 : a2) == true;
      }),
    );
    final calendarOAuthsNeedReAuth = ref.watch(
      localPrefControllerProvider.select((value) {
        final oauths = value.value?.calendarOAuths?.map((e) => e.needReAuth) ?? [];
        return (oauths.length == 1 || oauths.isEmpty) ? oauths.firstOrNull == true : oauths.reduce((a1, a2) => a1 == true ? a1 : a2) == true;
      }),
    );
    final oauthNotWorkExists = messengerOAuthsNeedReAuth || mailOAuthsNeedReAuth || calendarOAuthsNeedReAuth;

    final indexKey = [
      LogicalKeyboardKey.digit1,
      LogicalKeyboardKey.digit2,
      LogicalKeyboardKey.digit3,
      LogicalKeyboardKey.digit4,
      LogicalKeyboardKey.digit5,
      LogicalKeyboardKey.digit6,
      LogicalKeyboardKey.digit7,
      LogicalKeyboardKey.digit8,
      LogicalKeyboardKey.digit9,
      LogicalKeyboardKey.digit0,
    ];

    List<List<LogicalKeyboardKey>>? subkeys;

    final currentIndex = masterDetailsKey.currentState?.currentIndex;

    if (currentIndex != null) {
      int prevIndex = currentIndex == 0 ? maxIndex : currentIndex - 1;
      int nextIndex = currentIndex == maxIndex ? 0 : currentIndex + 1;

      bool isPrevOfCurrent = index == prevIndex;
      bool isNextOfCurrent = index == nextIndex;

      if (isPrevOfCurrent) {
        subkeys = [
          [LogicalKeyboardKey.arrowUp],
        ];
      } else if (isNextOfCurrent) {
        subkeys = [
          [LogicalKeyboardKey.arrowDown],
        ];
      }
    }

    return MasterItem(
      type.id,
      type.getTitle(context, ref, savedMoneyString),
      detailsBuilder: (context, isSmall, onClose) => type.detailsBuilder(context, isSmall, onClose, () => masterDetailsKey.currentState?.closeDetails()),
      customWidget: (selected) {
        return VisirListItem(
          onTap: type == PreferenceScreenType.terms
              ? () => Utils.launchUrlExternal(url: Constants.tosUrl)
              : type == PreferenceScreenType.privacy
              ? () => Utils.launchUrlExternal(url: Constants.privacyUrl)
              : type == PreferenceScreenType.download
              ? () => Utils.launchUrlExternal(url: Constants.taskeyDownloadUrl)
              : () => masterDetailsKey.currentState?.openDetails(id: type.id),
          isSelected: selected,
          buttonOptions: VisirButtonOptions(
            tooltipLocation: VisirButtonTooltipLocation.none,
            shortcuts: indexKey.length <= index
                ? null
                : [
                    VisirButtonKeyboardShortcut(
                      message: '',
                      keys: [indexKey[index], if (PlatformX.isApple) LogicalKeyboardKey.meta, if (!PlatformX.isApple) LogicalKeyboardKey.control],
                      subkeys: subkeys,
                    ),
                  ],
          ),
          titleBuilder: (height, baseStyle, verticalPadding, horizontalPadding) => TextSpan(
            children: [
              if (type.icon != null)
                WidgetSpan(
                  child: Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: VisirIcon(type: type.icon!, size: height, color: type.getColor(context), isSelected: true),
                  ),
                ),
              TextSpan(text: type.getTitle(context, ref, savedMoneyString), style: baseStyle?.textColor(type.getColor(context))),
            ],
          ),
          titleTrailingBuilder:
              (type.id == PreferenceScreenType.integration.id && oauthNotWorkExists) ||
                  (type.id == PreferenceScreenType.download.id || type.id == PreferenceScreenType.privacy.id || type.id == PreferenceScreenType.terms.id)
              ? (height, baseStyle, verticalPadding, horizontalPadding) => TextSpan(
                  children: [
                    if (type.id == PreferenceScreenType.integration.id && oauthNotWorkExists)
                      WidgetSpan(
                        child: Container(
                          width: height,
                          height: height,
                          clipBehavior: Clip.antiAlias,
                          decoration: ShapeDecoration(
                            color: context.error,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          child: VisirIcon(type: VisirIconType.caution, size: height * 2 / 3, color: context.onError, isSelected: true),
                        ),
                      ),
                    if (type.id == PreferenceScreenType.download.id || type.id == PreferenceScreenType.privacy.id || type.id == PreferenceScreenType.terms.id)
                      WidgetSpan(
                        child: VisirIcon(type: VisirIconType.openBrowser, size: height, color: context.onBackground, isSelected: true),
                      ),
                  ],
                )
              : null,
        );
      },
    );
  }

  Widget textButton({required String text, required Future<void> Function() onTap}) {
    return IntrinsicWidth(
      child: VisirButton(
        type: VisirButtonAnimationType.scale,
        style: VisirButtonStyle(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          clipBehavior: Clip.antiAlias,
          backgroundColor: context.surface,
          borderRadius: BorderRadius.circular(4),
          cursor: SystemMouseCursors.click,
        ),
        onTap: onTap,
        child: Text(text, style: context.bodyMedium?.textColor(context.onBackground)),
      ),
    );
  }

  void updateMoneyString() {
    final prefHourlyWage = ref.read(hourlyWageProvider);
    double totalSavedTimeInHours = UserActionSwitchListControllerProviderX.savedTimeInHoursNotifier.value;
    double totalSavedMoney = totalSavedTimeInHours * prefHourlyWage;
    final nextSavedMoneyString = Utils.numberFormatter(totalSavedMoney);
    if (savedMoneyString != nextSavedMoneyString) {
      savedMoneyString = nextSavedMoneyString;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    _scrollController ??= ModalScrollController.ofSyncGroup(context)?.addAndGet() ?? ScrollController();
    final isAdmin = ref.watch(authControllerProvider.select((v) => v.requireValue.userIsAdmin));

    bool isMobileView = PlatformX.isMobileView;
    ref.watch(themeSwitchProvider);

    ref.listen(hourlyWageProvider, (prev, hourlyWage) {
      updateMoneyString();
    });

    ref.listen(authControllerProvider.select((v) => v.requireValue.userTotalDays), (prev, userTotalDays) {
      updateMoneyString();
    });

    final messengerOAuthsIsEmpty = ref.watch(localPrefControllerProvider.select((value) => value.value?.messengerOAuths?.isEmpty)) ?? true;
    final mailOAuthsIsEmpty = ref.watch(localPrefControllerProvider.select((value) => value.value?.mailOAuths?.isEmpty)) ?? true;
    final calendarOAuthsIsEmpty = ref.watch(localPrefControllerProvider.select((value) => value.value?.calendarOAuths?.isEmpty)) ?? true;

    final screenTypes = [...PreferenceScreenType.values];
    if (!isMobileView) screenTypes.remove(PreferenceScreenType.saved);

    if ((PlatformX.isIOS && Constants.isBetaBuild && !isAdmin)) screenTypes.remove(PreferenceScreenType.subscription);

    if (messengerOAuthsIsEmpty) screenTypes.remove(PreferenceScreenType.chat);
    if (mailOAuthsIsEmpty) screenTypes.remove(PreferenceScreenType.mail);
    if (calendarOAuthsIsEmpty) screenTypes.remove(PreferenceScreenType.calendar);

    List<MasterItemBase> items = screenTypes.mapIndexed((index, e) => item(type: e, index: index, maxIndex: screenTypes.length - 1)).toList();

    if (_scrollController == null) return const SizedBox.shrink();
    return Material(
      color: context.surface,
      child: Padding(
        padding: EdgeInsets.all(PlatformX.isDesktopView ? 3.0 : 0),
        child: MasterDetailsFlow(
          afterOpenDetails: (id) {
            setState(() {});
          },
          key: masterDetailsKey,
          isResizable: false,
          scrollController: _scrollController!,
          scrollPhysics: Utils.getScrollPhysicsForBottomSheet(context, _scrollController),
          onTargetResized: (width) {},
          appbarSize: 48,
          initialPage: initialPreferenceScreenType == null || !screenTypes.contains(initialPreferenceScreenType)
              ? PlatformX.isMobileView
                    ? null
                    : 0
              : screenTypes.indexOf(initialPreferenceScreenType!),
          initialMasterPanelWidth: 180,
          minMasterResizableWidth: 180,
          minDetailResizableWidth: 180,
          maxMasterResizableWidth: 260,
          breakpoint: 520,
          detailBackgroundColor: context.background,
          masterBackgroundColor: context.background,
          masterAppBar: DetailsAppBarSize.small,
          lateralDetailsAppBar: DetailsAppBarSize.small,
          pageDetailsAppBar: DetailsAppBarSize.small,
          showAppBarDivider: true,
          autoImplyLeading: false,
          leadings: [
            Expanded(
              child: VisirAppBar(
                title: context.tr.preferences_title,
                leadings: [
                  VisirAppBarButton(
                    icon: VisirIconType.close,
                    onTap: Utils.mainContext.pop,
                    options: VisirButtonOptions(
                      tooltipLocation: VisirButtonTooltipLocation.right,
                      shortcuts: [
                        VisirButtonKeyboardShortcut(message: context.tr.close, keys: [LogicalKeyboardKey.escape]),
                      ],
                    ),
                  ),
                ],
                trailings: [],
              ),
            ),
          ],
          items: items,
        ),
      ),
    );
  }
}
