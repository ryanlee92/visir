import 'dart:async';

import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/showcase_tutorial/src/enum.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/auth/presentation/screens/auth_screen.dart';
import 'package:Visir/features/calendar/presentation/screens/main_calendar_widget.dart';
import 'package:Visir/features/chat/application/chat_channel_list_controller.dart';
import 'package:Visir/features/chat/presentation/screens/chat_screen.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/showcase_wrapper.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/inbox/presentation/screens/inbox_list_screen.dart';
import 'package:Visir/features/mail/application/mail_label_list_controller.dart';
import 'package:Visir/features/mail/domain/entities/mail_label_entity.dart';
import 'package:Visir/features/mail/presentation/screens/mail_screen.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/presentation/screens/preference_screen.dart';
import 'package:Visir/features/task/presentation/screens/task_screen.dart';
import 'package:Visir/features/time_saved/application/user_action_switch_list_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 배지 카운트 계산을 위한 최적화된 provider들
final _mailUnreadsProvider = Provider<int>((ref) {
  final labels = ref.watch(mailLabelListControllerProvider);
  final unreadMailList = labels.values.expand((e) => e).where((l) => l.id == CommonMailLabels.inbox.id && l.unread > 0).toList();
  return unreadMailList.length;
});

final _messageUnreadsProvider = Provider<int>((ref) {
  final excludedChannelIds = ref.watch(authControllerProvider.select((value) => value.requireValue.userExcludedChannelIds));
  final channels = ref.watch(
    chatChannelListControllerProvider.select((v) => v.values.expand((e) => e.channels).where((e) => !excludedChannelIds.contains(e.id)).toList()),
  );
  final finalChannelList = channels.where((e) => !e.isDm && !e.isGroupDm && e.hasUnreadMessage).toList();
  final finalDMList = channels.where((e) => (e.isDm || e.isGroupDm) && e.hasUnreadMessage).toList();

  return [...finalChannelList, ...finalDMList].where((e) => e.hasUnreadMessage).length;
});

final _oauthNotWorkExistsProvider = Provider<bool>((ref) {
  final messengerOAuthsNeedReAuth = ref.watch(
    localPrefControllerProvider.select((value) => value.value?.messengerOAuths?.any((e) => e.needReAuth == true) ?? false),
  );
  final mailOAuthsNeedReAuth = ref.watch(localPrefControllerProvider.select((value) => value.value?.mailOAuths?.any((e) => e.needReAuth == true) ?? false));
  final calendarOAuthsNeedReAuth = ref.watch(
    localPrefControllerProvider.select((value) => value.value?.calendarOAuths?.any((e) => e.needReAuth == true) ?? false),
  );

  return messengerOAuthsNeedReAuth || mailOAuthsNeedReAuth || calendarOAuthsNeedReAuth;
});

class MobileTabItem extends ConsumerStatefulWidget {
  final TabType? tabType;

  final GlobalKey<MainCalendarWidgetState> inboxCalendarScreenKey;
  final GlobalKey<InboxListScreenState> inboxListScreenKey;
  final GlobalKey<MailScreenState> mailScreenKey;
  final GlobalKey<ChatScreenState> chatScreenKey;
  final GlobalKey<TaskScreenState> taskScreenKey;

  const MobileTabItem({
    super.key,
    required this.tabType,
    required this.inboxListScreenKey,
    required this.mailScreenKey,
    required this.chatScreenKey,
    required this.inboxCalendarScreenKey,
    required this.taskScreenKey,
  });

  @override
  _MobileTabItemState createState() => _MobileTabItemState();
}

class _MobileTabItemState extends ConsumerState<MobileTabItem> {
  String savedMoneyString = '0';
  StreamSubscription<List<ConnectivityResult>>? connectivitySubscription;
  bool isInternetConnected = true;

  bool get isSignedIn => ref.read(isSignedInProvider);

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
  void initState() {
    super.initState();
    if (widget.tabType == null) {
      UserActionSwitchListControllerProviderX.savedTimeInHoursNotifier.addListener(updateMoneyString);
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
  }

  @override
  void dispose() {
    if (widget.tabType == null) {
      UserActionSwitchListControllerProviderX.savedTimeInHoursNotifier.removeListener(updateMoneyString);
      connectivitySubscription?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 배지 카운트 계산을 별도 provider로 분리하여 불필요한 리빌드 방지
    final mailUnreads = ref.watch(_mailUnreadsProvider);
    final messageUnreads = ref.watch(_messageUnreadsProvider);
    final oauthNotWorkExists = ref.watch(_oauthNotWorkExistsProvider);
    final hideUnreadIndicator = ref.watch(hideUnreadIndicatorProvider);
    ref.watch(defaultUserActionSwitchListControllerProvider);

    final name = ref.watch(authControllerProvider.select((e) => e.requireValue.name));
    final avatarUrl = ref.watch(authControllerProvider.select((e) => e.requireValue.avatarUrl));

    if (widget.tabType == null) {
      ref.listen(hourlyWageProvider, (prev, hourlyWage) {
        updateMoneyString();
      });

      ref.listen(authControllerProvider.select((v) => v.requireValue.userTotalDays), (prev, userTotalDays) {
        updateMoneyString();
      });
    }

    return ValueListenableBuilder(
      valueListenable: tabNotifier,
      builder: (context, tab, child) {
        bool isCurrentTab = tab == widget.tabType;

        int newCount = 0;
        switch (widget.tabType) {
          case TabType.chat:
            newCount = messageUnreads;
            break;
          case TabType.home:
            break;
          case TabType.mail:
            newCount = mailUnreads;
            break;
          case TabType.calendar:
            break;
          case TabType.task:
            break;
          case null:
            newCount = oauthNotWorkExists ? 1 : 0;
            break;
        }

        String newCountString = newCount < 1
            ? ''
            : newCount > 99
            ? '99+'
            : newCount.toString();

        final buttonSize = 24.0;

        final button = Stack(
          children: [
            VisirButton(
              style: VisirButtonStyle(width: 36, height: 40, borderRadius: BorderRadius.circular(6), clickMargin: EdgeInsets.symmetric(horizontal: 3)),
              type: VisirButtonAnimationType.scaleAndOpacity,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // SizedBox(height: 4),
                      if (widget.tabType == null)
                        if (!isInternetConnected)
                          VisirIcon(type: VisirIconType.networkUnavailable, size: buttonSize)
                        else if (isSignedIn)
                          Container(
                            width: buttonSize,
                            height: buttonSize,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(7), color: context.surfaceTint),
                            child: AdvancedAvatar(
                              name: name,
                              image: avatarUrl == null
                                  ? AssetImage('assets/place_holder/img_default_profile.png') as ImageProvider
                                  : CachedNetworkImageProvider(proxyUrl(avatarUrl)),
                              size: buttonSize - 2,
                              autoTextSize: true,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
                              style: TextStyle(color: context.onPrimary),
                            ),
                          )
                        else
                          VisirIcon(type: VisirIconType.login, size: buttonSize)
                      else
                        widget.tabType!.getVisirIcon(size: buttonSize, isSelected: isCurrentTab),
                      // SizedBox(height: 4),
                      // Text(
                      //   widget.tabType?.getTitle(context) ?? (isSignedIn ? '\$${savedMoneyString}' : context.tr.sign_in),
                      //   style: context.bodySmall
                      //       ?.textColor(widget.tabType == null ? context.tertiary : (isCurrentTab ? context.outlineVariant : context.surfaceTint))
                      //       .appFont(context),
                      //   maxLines: 1,
                      // ),
                    ],
                  ),
                  if (newCountString.isNotEmpty && !hideUnreadIndicator)
                    Positioned(
                      top: 8,
                      right: -6,
                      child: Container(
                        width: 6,
                        height: 6,
                        clipBehavior: Clip.antiAlias,
                        decoration: ShapeDecoration(
                          color: context.error,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                ],
              ),
              onTap: () async {
                if (widget.tabType == null) {
                  if (isSignedIn) {
                    Utils.showPopupDialog(child: PreferenceScreen(key: Utils.preferenceScreenKey));
                  } else {
                    Utils.showPopupDialog(child: AuthScreen());
                  }
                  return;
                }
                HapticFeedback.lightImpact();
                if (tabNotifier.value != widget.tabType) {
                  tabNotifier.value = widget.tabType!;
                } else if (Utils.mobileTabContexts[widget.tabType!] != null) {
                  Navigator.of(Utils.mobileTabContexts[widget.tabType!]!).maybePop();
                }
              },
            ),
          ],
        );

        if (widget.tabType?.showcaseKey != null) {
          return ShowcaseWrapper(showcaseKey: widget.tabType!.showcaseKey!, child: button, tooltipPosition: TooltipPosition.top);
        }

        return button;
      },
    );
  }
}
