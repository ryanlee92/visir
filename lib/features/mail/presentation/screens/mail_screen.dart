import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/admin_scaffold/admin_scaffold.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/log_event.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/desktop_scaffold.dart';
import 'package:Visir/features/common/presentation/widgets/fgbg_detector.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/presentation/widgets/visir_empty_widget.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_entity.dart';
import 'package:Visir/features/mail/application/mail_label_list_controller.dart';
import 'package:Visir/features/mail/domain/entities/mail_label_entity.dart';
import 'package:Visir/features/mail/presentation/screens/mail_list_screen.dart';
import 'package:Visir/features/mail/presentation/widgets/mail_side_bar.dart';
import 'package:Visir/features/mail/providers.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/presentation/screens/preference_screen.dart';
import 'package:Visir/features/task/presentation/widgets/timeblock_drop_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_resizable_container/flutter_resizable_container.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MailScreen extends ConsumerStatefulWidget {
  const MailScreen({super.key});

  @override
  ConsumerState createState() => MailScreenState();
}

final kBreakpoint = 892;

class MailScreenState extends ConsumerState<MailScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  GlobalKey<AdminScaffoldState> adminScaffoldKey = GlobalKey<AdminScaffoldState>();
  GlobalKey<MailListScreenState> mailListScreenKey = GlobalKey<MailListScreenState>();
  GlobalKey<TimeblockDropWidgetState> timeblockDropWidgetKey = GlobalKey<TimeblockDropWidgetState>();

  bool get isMailOpen => mailListScreenKey.currentState?.mailListMasterDetailsKey.currentState?.selectedItem != null;

  bool get isSidebarOpen => adminScaffoldKey.currentState?.isDrawerOpen ?? false;

  bool get isSearch => mailListScreenKey.currentState?.isSearch ?? false;

  bool get isDarkMode => context.isDarkMode;

  TabType get tabType => TabType.mail;

  @override
  void initState() {
    super.initState();
    isShowcaseOn.addListener(onShowcaseOnListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onShowcaseOnListener();
    });
  }

  void onShowcaseOnListener() {
    if (isShowcaseOn.value == mailTabShowcaseKeyString || isShowcaseOn.value == mailCreateTaskShowcaseKeyString) {
      selectLabel(label: CommonMailLabels.inbox.id, email: null);
    }
  }

  @override
  void dispose() {
    isShowcaseOn.removeListener(onShowcaseOnListener);
    super.dispose();
  }

  void toggleSidebar() {
    adminScaffoldKey.currentState?.toggleSidebar();
  }

  void closeDetails() {
    mailListScreenKey.currentState?.closeDetails();
  }

  void checkPayloadThenAction() {
    final payload = notificationPayload;

    if (payload == null) return;
    if (payload['isHome'] != null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      switch (payload['type']) {
        case 'gmail':
          final hostEmail = ref.read(mailConditionProvider(tabType).select((v) => v.email));
          final labelId = ref.read(mailConditionProvider(tabType).select((v) => v.label));
          if (labelId == CommonMailLabels.inbox.id && hostEmail == null) return;
          selectLabel(label: CommonMailLabels.inbox.id, email: null);
          break;
      }
    });
  }

  void compose() {
    Utils.showMailEditScreen();
    logAnalyticsEvent(eventName: 'mail_compose');
  }

  void selectLabel({required String label, required String? email}) {
    ref.read(mailConditionProvider(tabType).notifier).setLabelAndEmail(label, email);
    mailListScreenKey = GlobalKey();
    adminScaffoldKey.currentState?.closeSidebar();
  }

  bool showTimeblockDropWidget = false;
  Offset dragOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final list = ref.watch(localPrefControllerProvider.select((v) => v.value?.mailOAuths ?? []));

    ref.listen(mailLabelListControllerProvider, (previous, next) {
      checkPayloadThenAction();
    });

    ref.listen(localPrefControllerProvider, (previous, next) {
      if (previous?.value?.notificationPayload != next.value?.notificationPayload) {
        checkPayloadThenAction();
      }
    });

    final hostEmail = ref.watch(mailConditionProvider(tabType).select((v) => v.email));
    final labelId = ref.watch(mailConditionProvider(tabType).select((v) => v.label));

    final labels = ref.watch(mailLabelListControllerProvider);
    final commonLabel = CommonMailLabels.values.where((e) => e.id == labelId).firstOrNull;
    final labelName = commonLabel != null
        ? CommonMailLabels.values.where((e) => e.id == labelId).firstOrNull?.getTitle(context)
        : labels[hostEmail]?.where((e) => e.id == labelId).firstOrNull?.name;

    ref.listen(resizableClosableDrawerProvider(tabType), (previous, next) {});
    final ratio = ref.watch(zoomRatioProvider);

    return FGBGDetector(
      onChanged: (isForeground, isFirst) {
        if (!isForeground) return;
        checkPayloadThenAction();
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: AdminScaffold(
              tabType: tabType,
              key: adminScaffoldKey,
              sideBar: MailSideBar(tabType: tabType),
              body: list.isEmpty
                  ? ResizableContainer(
                      direction: Axis.horizontal,
                      children: [
                        if (ref.watch(resizableClosableDrawerProvider(tabType)) != null)
                          ResizableChild(
                            size: ResizableSize.expand(min: 120, max: 220),
                            child: DesktopCard(child: ref.watch(resizableClosableDrawerProvider(tabType))!),
                            divider: ResizableDivider(thickness: DesktopScaffold.cardPadding, color: Colors.transparent),
                          ),
                        ResizableChild(
                          child: DesktopCard(
                            child: Material(
                              color: context.background,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Center(
                                      child: VisirEmptyWidget(
                                        message: context.tr.no_integration_yet_for_mail,
                                        buttonText: context.tr.integrate_new_accounts,
                                        buttonIcon: VisirIconType.integration,
                                        secondaryButtonText: context.tr.hide_tab,
                                        onSecondaryButtonTap: () {
                                          ref.read(tabHiddenProvider(tabType).notifier).update(tabType, true);
                                          if (tabNotifier.value == tabType) tabNotifier.value = TabType.home;
                                        },
                                        onButtonTap: () {
                                          Utils.showPopupDialog(
                                            child: PreferenceScreen(
                                              key: Utils.preferenceScreenKey,
                                              initialPreferenceScreenType: PreferenceScreenType.integration,
                                            ),
                                            size: PlatformX.isMobileView ? null : Size(640, 560),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : MailListScreen(
                      key: mailListScreenKey,
                      labelId: '${labelId}',
                      labelName: '${labelName}',
                      hostEmail: hostEmail,
                      toggleSidebar: toggleSidebar,
                      showMobileUI: PlatformX.isMobileView,
                      onDragStart: (mail) {
                        showTimeblockDropWidget = true;
                        setState(() {});
                      },
                      onDragEnd: (mail) {
                        timeblockDropWidgetKey.currentState
                            ?.onInboxDragEnd(InboxEntity.fromMail(mail, null), dragOffset)
                            .then((_) {
                              showTimeblockDropWidget = false;
                              setState(() {});
                            })
                            .catchError((e) {
                              showTimeblockDropWidget = false;
                              setState(() {});
                            });
                      },
                      onDragUpdate: (mail, offset) {
                        dragOffset = offset;
                        timeblockDropWidgetKey.currentState?.onInboxDragUpdate(InboxEntity.fromMail(mail, null), offset);
                      },
                    ),
            ),
          ),

          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            width: PlatformX.isMobileView ? context.width / ratio : 380,
            top: PlatformX.isMobileView
                ? showTimeblockDropWidget
                      ? 0
                      : context.mobileCardHeight / ratio
                : 0,
            right: PlatformX.isMobileView
                ? 0
                : showTimeblockDropWidget
                ? 380
                : 0,
            bottom: PlatformX.isMobileView ? null : 0,
            height: PlatformX.isMobileView ? context.mobileCardHeight / ratio : null,
            child: Transform.translate(
              offset: Offset(PlatformX.isDesktopView ? 380 : 0, PlatformX.isMobileView ? 0 : 0),
              child: Container(
                height: PlatformX.isMobileView ? context.mobileCardHeight / ratio : null,
                margin: PlatformX.isMobileView ? null : EdgeInsets.all(6),
                padding: EdgeInsets.all(PlatformX.isMobileView ? 0 : 6),
                decoration: BoxDecoration(
                  color: context.surface,
                  boxShadow: PopupMenu.popupShadow,
                  border: PlatformX.isMobileView ? null : Border.all(color: context.outline),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(PlatformX.isMobileView ? 20 : DesktopScaffold.cardRadius),
                    topRight: Radius.circular(PlatformX.isMobileView ? 20 : DesktopScaffold.cardRadius),
                    bottomLeft: Radius.circular(PlatformX.isMobileView ? 0 : DesktopScaffold.cardRadius),
                    bottomRight: Radius.circular(PlatformX.isMobileView ? 0 : DesktopScaffold.cardRadius),
                  ),
                ),
                child: TimeblockDropWidget(key: timeblockDropWidgetKey, tabType: tabType),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
