import 'dart:math';

import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/contextmenu/src/ContextMenuArea.dart';
import 'package:Visir/dependency/master_detail_flow/master_detail_flow.dart';
import 'package:Visir/dependency/modal_bottom_sheet/src/utils/modal_scroll_controller.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/auth/domain/entities/user_entity.dart';
import 'package:Visir/features/calendar/presentation/widgets/calendar_simple_create_widget.dart';
import 'package:Visir/features/common/domain/entities/linked_item_entity.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/log_event.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/desktop_scaffold.dart';
import 'package:Visir/features/common/presentation/widgets/fgbg_detector.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/presentation/widgets/selection_widget.dart';
import 'package:Visir/features/common/presentation/widgets/showcase_wrapper.dart';
import 'package:Visir/features/common/presentation/widgets/visir_app_bar.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/common/presentation/widgets/tutorial/feature_tutorial_widget.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_config_entity.dart';
import 'package:Visir/features/mail/actions.dart';
import 'package:Visir/features/mail/application/mail_list_controller.dart';
import 'package:Visir/features/mail/application/mail_thread_list_controller.dart';
import 'package:Visir/features/mail/domain/entities/mail_entity.dart';
import 'package:Visir/features/mail/domain/entities/mail_file_entity.dart';
import 'package:Visir/features/mail/domain/entities/mail_user_entity.dart';
import 'package:Visir/features/mail/presentation/widgets/html_scrollsync_viewport.dart';
import 'package:Visir/features/mail/presentation/widgets/mail_attachment_widget.dart';
import 'package:Visir/features/mail/presentation/widgets/mail_content_widget.dart';
import 'package:Visir/features/mail/providers.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/task/presentation/widgets/mobile_task_or_event_switcher_widget.dart';
import 'package:Visir/features/task/presentation/widgets/simple_task_or_event_switcher_widget.dart';
import 'package:Visir/features/time_saved/actions.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

enum MailActionPopupType { read, pin, archive, trash, spam }

enum MailSendPopupType { reply, replyAll, forward }

extension MailActionPopupTypeX on MailActionPopupType {
  String getTitle(BuildContext context, MailEntity mail) {
    switch (this) {
      case MailActionPopupType.read:
        if (mail.isUnread == true) {
          return context.tr.mail_detail_tooltip_mark_as_read;
        }
        return context.tr.mail_detail_tooltip_mark_as_unread;
      case MailActionPopupType.pin:
        if (mail.isPinned == true) {
          return context.tr.mail_detail_tooltip_unpin;
        }
        return context.tr.mail_detail_tooltip_pin;
      case MailActionPopupType.archive:
        if (mail.isArchive == true) {
          context.tr.mail_detail_tooltip_unarchive;
        }
        return context.tr.mail_detail_tooltip_archive;
      case MailActionPopupType.trash:
        if (mail.isTrash == true) {
          return context.tr.mail_detail_tooltip_undelete;
        }
        return context.tr.mail_detail_tooltip_delete;
      case MailActionPopupType.spam:
        if (mail.isSpam == true) {
          return context.tr.mail_detail_tooltip_report_unspam;
        }
        return context.tr.mail_detail_tooltip_report_spam;
    }
  }
}

extension MailSendPopupTypeX on MailSendPopupType {
  String getTitle(BuildContext context, MailEntity mail) {
    switch (this) {
      case MailSendPopupType.reply:
        return context.tr.mail_reply;
      case MailSendPopupType.replyAll:
        return context.tr.mail_reply_all;
      case MailSendPopupType.forward:
        return context.tr.mail_forward;
    }
  }
}

class MailDetailScreen extends ConsumerStatefulWidget {
  final TabType tabType;
  final List<MailEntity>? threads;
  final LinkedMailEntity? taskMail;
  final bool Function(KeyEvent event)? onKeyDown;
  final bool Function(KeyEvent event)? onKeyRepeat;
  final VoidCallback? deleteTask;
  final InboxConfigEntity? inboxConfig;
  final VoidCallback close;
  final VoidCallback? onClose;
  final String anchorMailId;
  final Color? backgroundColor;

  const MailDetailScreen({
    super.key,
    this.backgroundColor,
    required this.tabType,
    this.threads,
    this.taskMail,
    this.inboxConfig,
    this.onKeyDown,
    this.onKeyRepeat,
    this.deleteTask,
    this.onClose,
    required this.close,
    required this.anchorMailId,
  });

  @override
  ConsumerState createState() => MailDetailScreenState();
}

class MailDetailScreenState extends ConsumerState<MailDetailScreen> {
  final createTaskButtonKey = ValueKey('mail_detail_screen_task');
  bool isShowCreateTaskTutorial = false;

  final maxWidth = 800;

  ScrollController? scrollController;
  ListController listController = ListController();

  String get threadId => widget.taskMail?.threadId ?? (widget.threads!.first.threadId ?? widget.threads!.first.id!);

  List<MailEntity>? get threads =>
      (ref.read(mailThreadListControllerProvider(tabType: tabType)).isNotEmpty == true
              ? ref.read(mailThreadListControllerProvider(tabType: tabType))
              : null ?? Utils.ref.read(mailListControllerProvider.notifier).getThreadsFromTaskMailLocally(widget.taskMail) ?? widget.threads)
          ?.where((e) => !e.isDraft)
          .toList();

  MailUserEntity get me {
    final pref = ref.read(localPrefControllerProvider).value;
    final hostEmail = ref.read(mailConditionProvider(tabType)).threadEmail;
    final mails = pref?.mailOAuths ?? [];
    final mailOAuth = mails.firstWhereOrNull((element) => element.email == hostEmail);
    return MailUserEntity(name: mailOAuth!.name, email: mailOAuth.email, type: MailEntityTypeX.fromOAuthType(mailOAuth.type));
  }

  MailEntity? get anchorMail => threads?.where((e) => e.id == widget.anchorMailId).firstOrNull?.copyWith(threads: threads);

  int? get threadLength => threads?.length;

  bool get isFromInbox => widget.taskMail != null;

  TabType get tabType => widget.tabType;

  bool get isUnread => threads?.where((e) => e.isUnread).isNotEmpty == true;

  bool get isPinned => threads?.where((e) => e.isPinned).isNotEmpty == true;

  bool get isArchive => threads?.where((e) => !e.isArchive).isEmpty == true;

  bool get isTrash => threads?.where((e) => !e.isTrash).isEmpty == true;

  bool get isSpam => threads?.where((e) => !e.isSpam).isEmpty == true;

  bool get isSent => anchorMail?.isSent ?? false;

  bool get isDarkMode => context.isDarkMode;

  bool isDownloadingAll = false;

  String get title {
    if (widget.taskMail?.title.isNotEmpty == true) return widget.taskMail!.title;
    if (anchorMail?.subject?.isNotEmpty == true) return anchorMail!.subject!;
    return context.tr.mail_empty_subject;
  }

  Map<String, GlobalKey<HtmlViewportSyncState>> syncKey = {};
  Map<String, ValueNotifier<bool>> syncVisibleNotifier = {};

  @override
  void initState() {
    super.initState();
    syncVisibleNotifier[widget.anchorMailId] = ValueNotifier(true);
    setSyncKey();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      mailViewportSyncVisibleNotifier[widget.tabType]!.value = true;
      UserActionSwtichAction.onOpenMail(mailHost: widget.taskMail?.hostMail ?? widget.threads!.first.hostEmail);
      readOnFirst();
      showCreateTaskTutorial();
    });

    final user = ref.read(authControllerProvider).requireValue;
    logAnalyticsEvent(
      eventName: isFromInbox
          ? 'inbox_${widget.taskMail!.type.title}'
          : user.onTrial
          ? 'trial_mail_read'
          : 'mail_read',
    );

    if (isFromInbox) {
      notificationPayload = {'isHome': 'true', 'type': widget.taskMail!.type.title.toLowerCase(), 'mailId': widget.taskMail!.messageId, 'threadId': widget.taskMail!.threadId};
    }
  }

  void setSyncKey() {
    threads?.forEach((e) {
      if (e.id != null && syncVisibleNotifier[e.id!] == null) {
        syncVisibleNotifier[e.id!] = ValueNotifier(false);
        syncKey[e.id!] = GlobalKey();
      }
    });
  }

  bool isScrolled = false;

  void scrollListener() {
    if (scrollController?.hasClients != true) return;
    isScrolled = true;
    scrollController?.jumpTo(scrollController?.position.pixels ?? 0);
  }

  @override
  void dispose() {
    syncVisibleNotifier.values.forEach((e) => e.dispose());
    scrollController?.removeListener(scrollListener);
    scrollController?.dispose();
    widget.onClose?.call();
    listController.dispose();
    super.dispose();
  }

  void showCreateTaskTutorial() {
    if (PlatformX.isMobile) return;
    if (!mounted) return;

    Future.delayed(Duration(milliseconds: 500), () {
      if (!mounted) return;

      final createTaskFromMailTutorialDone = ref.read(createTaskFromMailTutorialDoneProvider);
      if (createTaskFromMailTutorialDone) return;

      final box = Utils.findRenderBoxByValueKey(createTaskButtonKey);

      if (box != null) {
        final offset = box.localToGlobal(Offset.zero);
        final rect = offset & box.size;

        isShowCreateTaskTutorial = true;
        setState(() {});

        showContextMenu(
          topLeft: Offset(offset.dx, offset.dy),
          bottomRight: Offset(offset.dx + rect.width, offset.dy + rect.height),
          context: context,
          child: FeatureTutorialWidget(type: FeatureTutorialType.createTaskFromMail),
          verticalPadding: 0,
          borderRadius: 8,
          width: 232,
          backgroundColor: Colors.transparent,
          clipBehavior: Clip.none,
          isPopupMenu: false,
          hideShadow: false,
        );
      }
    });
  }

  Future<void> toggleRead() async {
    if (isUnread) {
      MailAction.read(mails: threads?.where((e) => e.isUnread).toList() ?? [], tabType: tabType);
    } else {
      MailAction.unread(mails: [threads?.where((e) => e.from?.email != e.hostEmail).last ?? anchorMail!], tabType: tabType);
    }
  }

  Future<void> togglePin() async {
    if (isPinned) {
      MailAction.unpin(mails: threads?.where((e) => e.isPinned).toList() ?? [], tabType: tabType);
    } else {
      MailAction.pin(mails: [threads?.where((e) => e.from?.email != e.hostEmail).last ?? anchorMail!], tabType: tabType);
    }
  }

  Future<void> toggleTrash() async {
    if (isTrash) {
      MailAction.untrash(mails: threads?.where((e) => e.isTrash).toList() ?? [], tabType: tabType);
    } else {
      MailAction.trash(mails: threads?.where((e) => !e.isTrash).toList() ?? [], tabType: tabType);
    }
  }

  Future<void> toggleArchive() async {
    if (isArchive) {
      MailAction.unarchive(mails: threads?.where((e) => !e.isArchive).toList() ?? [], tabType: tabType);
    } else {
      MailAction.archive(mails: threads?.where((e) => e.isArchive).toList() ?? [], tabType: tabType);
    }
  }

  Future<void> toggleSpam() async {
    if (isSpam) {
      MailAction.unspam(mails: threads?.where((e) => !e.isSpam).toList() ?? [], tabType: tabType);
    } else {
      MailAction.spam(mails: threads?.where((e) => e.isSpam).toList() ?? [], tabType: tabType);
    }
  }

  Future<void> deleteForever() async {
    MailAction.delete(mails: threads ?? [], tabType: tabType);
  }

  void reply(MailEntity e) {
    logAnalyticsEvent(eventName: isFromInbox ? 'inbox_${widget.taskMail!.type.title}_reply' : 'mail_reply');
    Utils.replyMail(mail: e, me: me);
  }

  void replyAll(MailEntity e) {
    logAnalyticsEvent(eventName: isFromInbox ? 'inbox_${widget.taskMail!.type.title}_reply_all' : 'mail_reply_all');
    Utils.replyAllMail(mail: e, me: me);
  }

  void forward(MailEntity e) {
    logAnalyticsEvent(eventName: isFromInbox ? 'inbox_${widget.taskMail!.type.title}_forward' : 'mail_forward');
    Utils.forwardMail(mail: e, me: me);
  }

  void checkPayloadThenAction() {
    final payload = notificationPayload;

    if (payload == null) return;
    if ((payload['isHome'] != null) == (tabType == TabType.mail)) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      switch (payload['type']) {
        case 'gmail':
          final mailId = payload['mailId'];
          final threadId = payload['threadId'];
          if (threadId == null) return;
          if (mailId == null) return;
          if (ref.read(mailConditionProvider(tabType)).threadId != threadId) return;
          syncVisibleNotifier[mailId] = ValueNotifier(true);
          final list = ref.read(mailThreadListControllerProvider(tabType: tabType));
          final index = list.indexWhere((e) => e.id == mailId);

          if (index <= 0) return;
          if (isScrolled) return;
          Future.delayed(Duration(milliseconds: 1000), () {
            if (!mounted) return;
            if (!listController.isAttached) return;
            if (scrollController == null) return;
            listController.animateToItem(
              index: index,
              scrollController: scrollController!,
              alignment: 0.5,
              duration: (distance) => Duration(milliseconds: 100),
              curve: (distance) => Curves.easeInOut,
            );
          });

          notificationPayload = null;
          break;
      }
    });
  }

  Widget skeletonWidget() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 20, bottom: 20, left: 16, right: 136),
          child: Container(
            height: 12,
            decoration: ShapeDecoration(
              color: context.surfaceVariant,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(top: 16, bottom: 42, left: 16, right: 196),
          color: context.surface,
          child: Container(
            height: 12,
            decoration: ShapeDecoration(
              color: context.surfaceVariant,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 20, left: 16, right: 190),
          child: Container(
            height: 12,
            decoration: ShapeDecoration(
              color: context.surfaceVariant,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 16, bottom: 20, left: 16, right: 240),
          child: Container(
            height: 12,
            decoration: ShapeDecoration(
              color: context.surfaceVariant,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ),
        ),
      ],
    );
  }

  bool firstRead = false;

  void readOnFirst() {
    if (threads != null && anchorMail != null && !firstRead) {
      firstRead = true;
      final unreadCount = widget.threads?.where((e) => e.isUnread).length;
      MailAction.read(mails: threads?.where((e) => e.isUnread).toList() ?? [], tabType: widget.tabType, unreadCount: unreadCount);
    }
  }

  bool isToTextOverflowing = false;
  bool isCcTextOverflowing = false;

  double? toTextlastMaxWidth;
  double? ccTextlastMaxWidth;

  bool isToTextCollapsed = true;
  bool isCcTextCollapsed = true;
  bool isBccTextCollapsed = true;

  @override
  Widget build(BuildContext context) {
    scrollController ??= ModalScrollController.ofSyncGroup(context)?.addAndGet() ?? ScrollController();
    ref.listen(mailThreadListControllerProvider(tabType: tabType), (prev, next) {
      checkPayloadThenAction();
      readOnFirst();
      setSyncKey();
    });

    ref.listen(localPrefControllerProvider, (previous, next) {
      if (previous?.value?.notificationPayload != next.value?.notificationPayload) {
        checkPayloadThenAction();
      }
    });

    ref.watch(mailThreadListControllerProvider(tabType: tabType));
    ref.watch(themeSwitchProvider);

    final list = threads ?? [];

    final MasterDetailsFlowSettings? settings = MasterDetailsFlowSettings.of(context);
    bool isMobileView = PlatformX.isMobileView;
    bool isSmallMobileView = isMobileView && MediaQueryData.fromView(View.of(context)).size.width <= 300;

    Color backgroundColor = context.background;

    final mailContentThemeType = ref.watch(authControllerProvider.select((e) => e.requireValue.userMailContentThemeType));
    final taskDefaultDurationInMinutes = ref.watch(authControllerProvider.select((e) => e.requireValue.userDefaultDurationInMinutes));

    bool isMailDarkTheme = mailContentThemeType == MailContentThemeType.followTaskeyTheme
        ? context.brightness == Brightness.dark
        : mailContentThemeType == MailContentThemeType.dark;

    bool createTaskFromMailTutorialDone = ref.watch(createTaskFromMailTutorialDoneProvider);

    if (widget.taskMail != null && ref.read(mailConditionProvider(tabType).select((v) => v.threadId)) != widget.taskMail?.threadId) {
      return Container(color: widget.backgroundColor ?? backgroundColor);
    }

    return FGBGDetector(
      onChanged: (isForeground, isFirst) {
        if (!isForeground) return;
        checkPayloadThenAction();
      },
      child: Container(
        color: widget.backgroundColor ?? backgroundColor,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                ...(threads ?? []).map(
                  (e) => e.id == widget.anchorMailId
                      ? Positioned.fill(child: SizedBox.shrink())
                      : Positioned(
                          top: 0,
                          left: 0,
                          width: 1,
                          height: 1,
                          child: ValueListenableBuilder(
                            valueListenable: syncVisibleNotifier[e.id!] ?? ValueNotifier(false),
                            builder: (context, value, child) {
                              return value
                                  ? SizedBox.shrink()
                                  : HtmlViewportSync(
                                      tabType: widget.tabType,
                                      key: syncKey[e.id!],
                                      html: '',
                                      scrollController: ScrollController(),
                                      viewportHeight: 0,
                                      width: constraints.maxWidth,
                                    );
                            },
                          ),
                        ),
                ),
                Positioned.fill(
                  child: DetailsItem(
                    bodyColor: widget.backgroundColor,
                    appbarColor: widget.backgroundColor,
                    scrollController: scrollController,
                    listController: listController,
                    scrollPhysics: Utils.getScrollPhysicsForBottomSheet(context, scrollController),
                    appBarWrapper: (child) => ShowcaseWrapper(
                      showcaseKey: tabType == TabType.mail ? mailCreateTaskShowcaseKeyString : null,
                      onBeforeShowcase: () async {
                        if (PlatformX.isDesktopView) return;
                        await Future.delayed(Duration(milliseconds: 1000));
                      },
                      child: child,
                    ),
                    leadings: [
                      VisirAppBarButton(
                        key: ValueKey('mail_detail_screen_close_${settings?.large}'),
                        icon: PlatformX.isDesktopView
                            ? VisirIconType.close
                            : Navigator.canPop(context)
                            ? VisirIconType.arrowLeft
                            : Navigator.canPop(Utils.mainContext)
                            ? VisirIconType.close
                            : VisirIconType.arrowLeft,
                        onTap: widget.close,
                        options: VisirButtonOptions(
                          tabType: widget.tabType,
                          shortcuts: [
                            VisirButtonKeyboardShortcut(
                              keys: [LogicalKeyboardKey.escape],
                              message: settings?.large != true ? context.tr.go_back : context.tr.close,
                              prevOnKeyDown: widget.onKeyDown,
                              prevOnKeyRepeat: widget.onKeyRepeat,
                              onTrigger: () {
                                if (mailEditScreenVisibleNotifier.value) return false;
                                widget.close();
                                return true;
                              },
                            ),
                          ],
                        ),
                      ),
                      ...[
                        VisirAppBarButton(isDivider: true),
                        if (!isSpam && !isTrash) ...[
                          VisirAppBarButton(
                            key: ValueKey('mail_detail_screen_read_${anchorMail?.isUnread}'),
                            icon: anchorMail?.isUnread == true ? VisirIconType.show : VisirIconType.hide,
                            onTap: toggleRead,
                            options: VisirButtonOptions(
                              tabType: widget.tabType,
                              shortcuts: [
                                if (anchorMail?.isUnread == true)
                                  VisirButtonKeyboardShortcut(
                                    keys: [LogicalKeyboardKey.keyI, LogicalKeyboardKey.shift],
                                    message: context.tr.mail_detail_tooltip_mark_as_read,
                                    prevOnKeyDown: widget.onKeyDown,
                                    prevOnKeyRepeat: widget.onKeyRepeat,
                                  ),
                                if (anchorMail?.isUnread == false)
                                  VisirButtonKeyboardShortcut(
                                    keys: [LogicalKeyboardKey.keyU, LogicalKeyboardKey.shift],
                                    message: context.tr.mail_detail_tooltip_mark_as_unread,
                                    prevOnKeyDown: widget.onKeyDown,
                                    prevOnKeyRepeat: widget.onKeyRepeat,
                                  ),
                              ],
                            ),
                          ),
                          VisirAppBarButton(
                            key: ValueKey('mail_detail_screen_pin_${isPinned}'),
                            icon: VisirIconType.pin,
                            onTap: togglePin,
                            foregroundColor: isPinned == true ? context.primary : null,
                            options: VisirButtonOptions(
                              tabType: widget.tabType,
                              shortcuts: [
                                VisirButtonKeyboardShortcut(
                                  keys: [LogicalKeyboardKey.keyP, if (PlatformX.isApple) LogicalKeyboardKey.meta, if (!PlatformX.isApple) LogicalKeyboardKey.control],
                                  subkeys: [
                                    [LogicalKeyboardKey.keyS],
                                  ],
                                  prevOnKeyDown: widget.onKeyDown,
                                  prevOnKeyRepeat: widget.onKeyRepeat,
                                  message: isPinned != true ? context.tr.mail_detail_tooltip_pin : context.tr.mail_detail_tooltip_unpin,
                                ),
                              ],
                            ),
                          ),
                          if (list.isNotEmpty) ...[
                            if (isMobileView)
                              VisirAppBarButton(
                                key: createTaskButtonKey,
                                hightlight: isShowcaseOn.value != null,
                                icon: VisirIconType.checkWithCircle,
                                onTap: () => Utils.showPopupDialog(
                                  child: MobileTaskOrEventSwitcherWidget(
                                    isAllDay: true,
                                    isEvent: false,
                                    selectedDate: DateUtils.dateOnly(DateTime.now()),
                                    startDate: DateUtils.dateOnly(DateTime.now()),
                                    endDate: DateUtils.dateOnly(DateTime.now()),
                                    tabType: widget.tabType,
                                    titleHintText: title,
                                    description: widget.threads?.first.snippet,
                                    originalTaskMail: LinkedMailEntity(
                                      title: list.first.subject ?? '',
                                      hostMail: list.first.hostEmail,
                                      fromName: list.first.from?.name ?? list.first.from?.email ?? '',
                                      messageId: list.first.id!,
                                      threadId: list.first.threadId!,
                                      type: list.first.type,
                                      date: list.first.date ?? DateTime.now(),
                                      link: list.first.link,
                                      pageToken: list.first.pageToken,
                                      labelIds: list.first.labelIds ?? [],
                                      encrypted: true,
                                      timezone: list.first.timezone,
                                    ),
                                    calendarTaskEditSourceType: CalendarTaskEditSourceType.mail,
                                  ),
                                ),
                                options: VisirButtonOptions(tabType: widget.tabType, message: context.tr.mail_detail_tooltip_task),
                              )
                            else
                              VisirAppBarButton(
                                key: createTaskButtonKey,
                                icon: VisirIconType.checkWithCircle,
                                hightlight: isShowcaseOn.value != null,
                                popup: SimpleTaskOrEventSwithcerWidget(
                                  tabType: widget.tabType,
                                  isEvent: false,
                                  startDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, DateTime.now().hour, (DateTime.now().minute ~/ 15 + 1) * 15),
                                  endDate: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day,
                                    DateTime.now().hour,
                                    (DateTime.now().minute ~/ 15 + 1) * 15,
                                  ).add(Duration(minutes: taskDefaultDurationInMinutes)),
                                  isAllDay: true,
                                  selectedDate: DateUtils.dateOnly(DateTime.now()),
                                  titleHintText: title,
                                  description: threads?.firstOrNull?.snippet,
                                  originalTaskMail: LinkedMailEntity(
                                    title: list.firstOrNull?.subject ?? '',
                                    hostMail: list.first.hostEmail,
                                    fromName: list.first.from?.name ?? list.first.from?.email ?? '',
                                    messageId: list.first.id!,
                                    threadId: list.first.threadId!,
                                    type: list.first.type,
                                    date: list.first.date ?? DateTime.now(),
                                    link: list.first.link,
                                    pageToken: list.first.pageToken,
                                    labelIds: list.first.labelIds ?? [],
                                    encrypted: true,
                                    timezone: list.first.timezone,
                                  ),
                                  calendarTaskEditSourceType: CalendarTaskEditSourceType.mail,
                                ),
                                popupBackgroundColor: Colors.transparent,
                                popupWidth: Constants.desktopCreateTaskPopupWidth,
                                backgroundColor: (isShowCreateTaskTutorial && !createTaskFromMailTutorialDone) ? context.outlineVariant.withValues(alpha: 0.1) : Colors.transparent,
                                clipBehavior: Clip.none,
                                hideShadow: true,
                                options: VisirButtonOptions(
                                  tabType: widget.tabType,
                                  shortcuts: [
                                    VisirButtonKeyboardShortcut(
                                      keys: [LogicalKeyboardKey.keyT, if (PlatformX.isApple) LogicalKeyboardKey.meta, if (!PlatformX.isApple) LogicalKeyboardKey.control],
                                      prevOnKeyDown: widget.onKeyDown,
                                      prevOnKeyRepeat: widget.onKeyRepeat,
                                      message: context.tr.mail_detail_tooltip_task,
                                    ),
                                  ],
                                ),
                              ),
                            VisirAppBarButton(isDivider: true),
                          ],
                        ],
                        if (!isTrash)
                          VisirAppBarButton(
                            key: ValueKey('mail_detail_screen_archive_${isArchive}'),
                            icon: VisirIconType.archive,
                            onTap: toggleArchive,
                            foregroundColor: isArchive == true ? context.primary : null,
                            options: VisirButtonOptions(
                              tabType: widget.tabType,
                              message: isArchive != true ? null : context.tr.mail_detail_tooltip_unarchive,
                              shortcuts: [
                                if (isArchive != true)
                                  VisirButtonKeyboardShortcut(
                                    keys: [LogicalKeyboardKey.keyE],
                                    message: context.tr.mail_detail_tooltip_archive,
                                    prevOnKeyDown: widget.onKeyDown,
                                    prevOnKeyRepeat: widget.onKeyRepeat,
                                  ),
                              ],
                            ),
                          ),
                        ...isSmallMobileView
                            ? [
                                VisirAppBarButton(
                                  icon: VisirIconType.more,
                                  popup: SelectionWidget<MailActionPopupType>(
                                    onSelect: (type) {
                                      switch (type) {
                                        case MailActionPopupType.trash:
                                          toggleTrash();
                                          break;
                                        case MailActionPopupType.spam:
                                          toggleSpam();
                                          break;
                                        default:
                                          break;
                                      }
                                    },
                                    items: [MailActionPopupType.trash, MailActionPopupType.spam],
                                    getTitle: (item) => item.getTitle(context, anchorMail!),
                                  ),
                                ),
                              ]
                            : [
                                VisirAppBarButton(
                                  key: ValueKey('mail_detail_screen_trash_spam_${(isSpam || isTrash)}'),
                                  icon: VisirIconType.trash,
                                  onTap: (isSpam || isTrash) ? deleteForever : toggleTrash,
                                  options: VisirButtonOptions(
                                    tabType: widget.tabType,
                                    message: (isSpam || isTrash) ? context.tr.mail_detail_tooltip_delete_forever : null,
                                    shortcuts: [
                                      if (!isSpam && !isTrash)
                                        VisirButtonKeyboardShortcut(
                                          keys: [LogicalKeyboardKey.digit3, LogicalKeyboardKey.shift],
                                          subkeys: [
                                            [LogicalKeyboardKey.delete, if (PlatformX.isApple) LogicalKeyboardKey.meta, if (!PlatformX.isApple) LogicalKeyboardKey.control],
                                            [LogicalKeyboardKey.backspace, if (PlatformX.isApple) LogicalKeyboardKey.meta, if (!PlatformX.isApple) LogicalKeyboardKey.control],
                                          ],
                                          message: context.tr.mail_detail_tooltip_delete,
                                          prevOnKeyDown: widget.onKeyDown,
                                          prevOnKeyRepeat: widget.onKeyRepeat,
                                        ),
                                    ],
                                  ),
                                ),
                                if (!isSent)
                                  VisirAppBarButton(
                                    key: ValueKey('mail_detail_screen_spam_${(isSpam)}'),
                                    icon: VisirIconType.spam,
                                    onTap: toggleSpam,
                                    foregroundColor: isSpam == true ? context.primary : null,
                                    options: VisirButtonOptions(
                                      tabType: widget.tabType,
                                      message: isSpam ? context.tr.mail_detail_tooltip_not_spam : null,
                                      shortcuts: [
                                        if (!isSpam)
                                          VisirButtonKeyboardShortcut(
                                            keys: [LogicalKeyboardKey.digit1, LogicalKeyboardKey.shift],
                                            subkeys: [
                                              [LogicalKeyboardKey.exclamation],
                                            ],
                                            message: context.tr.mail_detail_tooltip_report_spam,
                                            prevOnKeyDown: widget.onKeyDown,
                                            prevOnKeyRepeat: widget.onKeyRepeat,
                                          ),
                                      ],
                                    ),
                                  ),
                                if (isTrash)
                                  VisirAppBarButton(
                                    key: ValueKey('mail_detail_screen_trash_${(isTrash)}'),
                                    child: Text(context.tr.mail_detail_tooltip_move_to_inbox, style: context.labelLarge?.textColor(context.onPrimary).textBold.appFont(context)),
                                    onTap: toggleTrash,
                                  ),
                              ],
                      ],
                    ],
                    title: '',
                    hideBackButton: true,
                    children: [
                      if (list.isEmpty) skeletonWidget(),
                      if (list.isNotEmpty)
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                color: Colors.transparent,
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  strutStyle: StrutStyle(forceStrutHeight: true, height: context.titleMedium?.height, fontSize: context.titleMedium?.fontSize),
                                  title,
                                  style: context.titleMedium?.textColor(context.onSurface).textBold,
                                ),
                              ),
                            ),
                            if (isFromInbox)
                              TooltipTheme(
                                data: TooltipThemeData(
                                  textStyle: context.bodyMedium?.textColor(context.onBackground),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 6, offset: Offset(0, 4))],
                                  ),
                                ),
                                child: PopupMenu(
                                  forcePopup: true,
                                  width: 128,
                                  borderRadius: 6,
                                  location: PopupMenuLocation.bottom,
                                  type: ContextMenuActionType.tap,
                                  popup: SelectionWidget<MailActionPopupType>(
                                    cellHeight: 36,
                                    onSelect: (type) {
                                      switch (type) {
                                        case MailActionPopupType.trash:
                                          toggleTrash();
                                          break;
                                        case MailActionPopupType.spam:
                                          toggleSpam();
                                          break;
                                        case MailActionPopupType.read:
                                          toggleRead();
                                          break;
                                        case MailActionPopupType.pin:
                                          togglePin();
                                          break;
                                        case MailActionPopupType.archive:
                                          toggleArchive();
                                          break;
                                      }
                                    },
                                    items: [...MailActionPopupType.values],
                                    getTitle: (item) => item.getTitle(context, anchorMail!),
                                  ),
                                  style: VisirButtonStyle(
                                    width: 32,
                                    height: 32,
                                    borderRadius: BorderRadius.circular(6),
                                    margin: EdgeInsets.all(12),
                                    cursor: SystemMouseCursors.click,
                                  ),
                                  options: VisirButtonOptions(tabType: widget.tabType, message: context.tr.mail_actions),
                                  child: VisirIcon(type: VisirIconType.more, size: 16),
                                ),
                              ),
                          ],
                        ),
                      ...(list.map((e) {
                        if (e.html == null) return SizedBox.shrink();
                        return Container(
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(DesktopScaffold.cardRadius), color: context.surface),
                          margin: EdgeInsets.only(left: DesktopScaffold.cardPadding, right: DesktopScaffold.cardPadding, bottom: DesktopScaffold.cardPadding),
                          child: ValueListenableBuilder(
                            valueListenable: e.id == widget.anchorMailId ? mailViewportSyncVisibleNotifier[widget.tabType]! : (syncVisibleNotifier[e.id!] ?? ValueNotifier(false)),
                            builder: (context, value, child) {
                              final valueListenable = e.id == widget.anchorMailId
                                  ? mailViewportSyncVisibleNotifier[widget.tabType]!
                                  : (syncVisibleNotifier[e.id!] ?? ValueNotifier(false));

                              if (!value) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: VisirButton(
                                    key: ValueKey('mail_details_screen_collapsed:${e.id}'),
                                    type: VisirButtonAnimationType.opacity,
                                    onTap: () {
                                      if (e.id == null) return;
                                      valueListenable.value = true;
                                      setState(() {});
                                    },
                                    style: VisirButtonStyle(cursor: SystemMouseCursors.click, borderRadius: BorderRadius.circular(6)),
                                    options: VisirButtonOptions(tabType: widget.tabType, message: context.tr.expand, tooltipLocation: VisirButtonTooltipLocation.pointer),
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 8),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text.rich(
                                                            TextSpan(
                                                              children: [
                                                                TextSpan(
                                                                  text: e.from?.name ?? e.from?.email ?? '',
                                                                  style: context.bodyLarge?.textColor(context.outlineVariant).textBold,
                                                                ),
                                                              ],
                                                            ),
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                        SizedBox(width: 8),
                                                        Text(e.threadDateString ?? '', style: context.bodyMedium?.textColor(context.onInverseSurface)),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: double.maxFinite,
                                          // color: context.surfaceVariant,
                                          padding: EdgeInsets.only(left: 12, right: 12, top: 0, bottom: 8),
                                          child: Text(
                                            e.snippet ?? '(No Content)',
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                            style: context.bodyLarge?.textColor(context.inverseSurface),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              final _html = e.html!;
                              final String _body = _html;
                              const String _head = '';

                              List<MailFileEntity> attachments = [
                                ...e.getAttachments().where((a) {
                                  if (a.cid.trim().isEmpty) return true;
                                  return !_body.contains('cid:${a.cid}');
                                }),
                              ];

                              Widget Function(bool isCollapsed) toTextWidget = (isCollapsed) => VisirButton(
                                type: VisirButtonAnimationType.opacity,
                                style: VisirButtonStyle(cursor: SystemMouseCursors.click),
                                onTap: () {
                                  setState(() {
                                    isToTextCollapsed = !isToTextCollapsed;
                                  });
                                },
                                child: Row(
                                  children: [
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(text: 'To.  ', style: context.bodyMedium?.textColor(context.secondary)),
                                          ...e.to
                                              .map((user) {
                                                bool isMe = user.email == me.email;
                                                String userName = (user.name ?? '');
                                                return [
                                                  TextSpan(
                                                    text: ref.read(shouldUseMockDataProvider)
                                                        ? 'Alex Chen'
                                                        : '${isMe
                                                              ? me.name
                                                              : userName.isEmpty
                                                              ? user.email
                                                              : userName} ',
                                                    style: context.bodyLarge?.textColor(context.outlineVariant),
                                                  ),
                                                  TextSpan(text: '<${user.email}>  ', style: context.bodyMedium?.textColor(context.onInverseSurface)),
                                                ];
                                              })
                                              .expand((t) => t),
                                        ],
                                      ),
                                      maxLines: isCollapsed ? 1 : null,
                                    ),
                                  ],
                                ),
                              );

                              Widget Function(bool isCollapsed) ccTextSpan = (isCollapsed) => VisirButton(
                                type: VisirButtonAnimationType.opacity,
                                style: VisirButtonStyle(cursor: SystemMouseCursors.click),
                                onTap: () {
                                  setState(() {
                                    isCcTextCollapsed = !isCcTextCollapsed;
                                  });
                                },
                                child: Row(
                                  children: [
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(text: 'Cc.  ', style: context.bodyMedium?.textColor(context.secondary)),
                                          ...e.cc
                                              .map((user) {
                                                String userName = (user.name == null || user.name == 'null' || user.name!.isEmpty) ? 'Alex Chen' : user.name!;
                                                return [
                                                  TextSpan(text: '$userName ', style: context.bodyLarge?.textColor(context.outlineVariant)),
                                                  TextSpan(text: '<${user.email}>   ', style: context.bodyMedium?.textColor(context.onInverseSurface)),
                                                ];
                                              })
                                              .expand((t) => t),
                                        ],
                                      ),
                                      maxLines: isCollapsed ? 1 : null,
                                    ),
                                  ],
                                ),
                              );

                              Widget Function(bool isCollapsed) bccTextSpan = (isCollapsed) => VisirButton(
                                type: VisirButtonAnimationType.opacity,
                                style: VisirButtonStyle(cursor: SystemMouseCursors.click),
                                onTap: () {
                                  setState(() {
                                    isBccTextCollapsed = !isBccTextCollapsed;
                                  });
                                },
                                child: Row(
                                  children: [
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(text: 'Bcc.  ', style: context.bodyMedium?.textColor(context.secondary)),
                                          ...e.bcc
                                              .map((user) {
                                                String userName = (user.name == null || user.name == 'null' || user.name!.isEmpty) ? 'Alex Chen' : user.name!;
                                                return [
                                                  TextSpan(text: '$userName ', style: context.bodyLarge?.textColor(context.outlineVariant)),
                                                  TextSpan(text: '<${user.email}>   ', style: context.bodyMedium?.textColor(context.onInverseSurface)),
                                                ];
                                              })
                                              .expand((t) => t),
                                        ],
                                      ),
                                      maxLines: isCollapsed ? 1 : null,
                                    ),
                                  ],
                                ),
                              );

                              return Column(
                                children: [
                                  Container(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: VisirButton(
                                            key: ValueKey('mail_details_screen_expanded:${e.id}'),
                                            type: VisirButtonAnimationType.opacity,
                                            style: VisirButtonStyle(padding: EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 8), cursor: SystemMouseCursors.click),
                                            onTap: () {
                                              if (e.id == null) return;
                                              valueListenable.value = false;
                                              setState(() {});
                                            },
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text.rich(
                                                        TextSpan(
                                                          children: [
                                                            TextSpan(
                                                              text: e.from?.name ?? '',
                                                              style: PlatformX.isMobileView
                                                                  ? context.titleSmall?.textColor(context.outlineVariant).textBold
                                                                  : context.bodyLarge?.textColor(context.outlineVariant).textBold,
                                                            ),
                                                            if (e.from?.name?.isNotEmpty == true) WidgetSpan(child: SizedBox(width: 6)),
                                                            TextSpan(
                                                              text: '<${e.from?.email ?? ''}>',
                                                              style: PlatformX.isMobileView
                                                                  ? context.bodyLarge?.textColor(context.onInverseSurface)
                                                                  : context.bodyMedium?.textColor(context.onInverseSurface),
                                                            ),
                                                          ],
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      e.threadDateString ?? '',
                                                      style: PlatformX.isMobileView
                                                          ? context.bodyLarge?.textColor(context.onInverseSurface)
                                                          : context.bodyMedium?.textColor(context.onInverseSurface),
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(top: e.cc.isEmpty && e.bcc.isEmpty ? 3 : 0),
                                                  child: Row(
                                                    crossAxisAlignment: e.cc.isEmpty && e.bcc.isEmpty ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                                                    children: [
                                                      Expanded(
                                                        child: Column(
                                                          children: [
                                                            Padding(
                                                              padding: EdgeInsets.only(top: e.cc.isEmpty && e.bcc.isEmpty ? 0 : 6),
                                                              child: AnimatedCrossFade(
                                                                duration: const Duration(milliseconds: 160),
                                                                crossFadeState: isToTextCollapsed ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                                                firstChild: toTextWidget(true),
                                                                secondChild: toTextWidget(false),
                                                              ),
                                                            ),
                                                            if (e.cc.isNotEmpty)
                                                              Padding(
                                                                padding: const EdgeInsets.only(top: 3),
                                                                child: AnimatedCrossFade(
                                                                  duration: const Duration(milliseconds: 160),
                                                                  crossFadeState: isCcTextCollapsed ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                                                  firstChild: ccTextSpan(true),
                                                                  secondChild: ccTextSpan(false),
                                                                ),
                                                              ),
                                                            if (e.bcc.isNotEmpty)
                                                              Padding(
                                                                padding: const EdgeInsets.only(top: 3),
                                                                child: AnimatedCrossFade(
                                                                  duration: const Duration(milliseconds: 160),
                                                                  crossFadeState: isBccTextCollapsed ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                                                  firstChild: bccTextSpan(true),
                                                                  secondChild: bccTextSpan(false),
                                                                ),
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                      VisirButton(
                                                        type: VisirButtonAnimationType.scaleAndOpacity,
                                                        style: VisirButtonStyle(
                                                          margin: EdgeInsets.only(left: 4, right: 6, top: e.cc.isEmpty && e.bcc.isEmpty ? 0 : 3),
                                                          borderRadius: BorderRadius.circular(6),
                                                          cursor: SystemMouseCursors.click,
                                                          width: 28,
                                                          height: 28,
                                                        ),
                                                        onTap: () => reply(e),
                                                        options: VisirButtonOptions<MailSendPopupType>(
                                                          tabType: widget.tabType,
                                                          tooltipLocation: VisirButtonTooltipLocation.top,
                                                          message: context.tr.mail_reply,
                                                        ),
                                                        child: VisirIcon(type: VisirIconType.reply, color: context.onSurfaceVariant, size: 14, isSelected: true),
                                                      ),
                                                      if (e.cc.isEmpty)
                                                        VisirButton(
                                                          type: VisirButtonAnimationType.scaleAndOpacity,
                                                          style: VisirButtonStyle(
                                                            borderRadius: BorderRadius.circular(6),
                                                            cursor: SystemMouseCursors.click,
                                                            margin: EdgeInsets.only(top: e.cc.isEmpty && e.bcc.isEmpty ? 0 : 3),
                                                            width: 28,
                                                            height: 28,
                                                          ),
                                                          options: VisirButtonOptions<MailSendPopupType>(
                                                            tabType: widget.tabType,
                                                            tooltipLocation: VisirButtonTooltipLocation.top,
                                                            message: context.tr.mail_forward,
                                                          ),
                                                          onTap: () => forward(e),
                                                          child: VisirIcon(type: VisirIconType.forward, color: context.onSurfaceVariant, size: 14, isSelected: true),
                                                        ),
                                                      if (e.cc.isNotEmpty)
                                                        PopupMenu(
                                                          forcePopup: true,
                                                          width: 128,
                                                          borderRadius: 6,
                                                          type: ContextMenuActionType.tap,
                                                          location: PopupMenuLocation.bottom,
                                                          style: VisirButtonStyle(
                                                            borderRadius: BorderRadius.circular(6),
                                                            cursor: SystemMouseCursors.click,
                                                            margin: EdgeInsets.only(top: e.cc.isEmpty && e.bcc.isEmpty ? 0 : 3),
                                                            width: 28,
                                                            height: 28,
                                                          ),
                                                          options: VisirButtonOptions<MailSendPopupType>(
                                                            tabType: widget.tabType,
                                                            message: context.tr.mail_actions,
                                                            doNotConvertCase: true,
                                                            customShortcutTooltip: '',
                                                            shortcuts: [
                                                              VisirButtonKeyboardShortcut<MailSendPopupType>(
                                                                keys: [LogicalKeyboardKey.keyA],
                                                                itemTitle: MailSendPopupType.replyAll.getTitle(context, e),
                                                                prevOnKeyDown: widget.onKeyDown,
                                                                prevOnKeyRepeat: widget.onKeyRepeat,
                                                                message: context.tr.mail_reply_all,
                                                                onTrigger: () {
                                                                  replyAll(e);
                                                                  return true;
                                                                },
                                                              ),
                                                              VisirButtonKeyboardShortcut<MailSendPopupType>(
                                                                keys: [LogicalKeyboardKey.keyF],
                                                                itemTitle: MailSendPopupType.forward.getTitle(context, e),
                                                                prevOnKeyDown: widget.onKeyDown,
                                                                prevOnKeyRepeat: widget.onKeyRepeat,
                                                                message: context.tr.mail_reply,
                                                                onTrigger: () {
                                                                  forward(e);
                                                                  return true;
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                          child: VisirIcon(type: VisirIconType.more, color: context.onSurfaceVariant, size: 16),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  RepaintBoundary(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(DesktopScaffold.cardRadius),
                                      child: scrollController == null
                                          ? SizedBox.shrink()
                                          : MailContentWidget(
                                              key: ValueKey(e.id),
                                              syncKey: e.id == widget.anchorMailId ? mailViewportSyncKey[widget.tabType]! : syncKey[e.id!]!,
                                              body: _body,
                                              head: _head,
                                              maxHeight: constraints.maxHeight,
                                              scrollController: scrollController!,
                                              isFromInbox: isFromInbox,
                                              isDarkTheme: isMailDarkTheme,
                                              width: constraints.maxWidth - 4 * DesktopScaffold.cardPadding,
                                              mail: e,
                                              tabType: tabType,
                                              onScrollInsideIframe: (dx, dy) {
                                                scrollController?.jumpTo(min(max(0, scrollController!.offset + dy), scrollController!.position.maxScrollExtent));
                                              },
                                              onTapInsideWebView: () {
                                                Navigator.of(Utils.mainContext).popUntil((route) => route.isFirst);
                                              },
                                            ),
                                    ),
                                  ),
                                  if (attachments.isNotEmpty)
                                    RepaintBoundary(
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 8),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      context.tr.mail_attachments,
                                                      style: PlatformX.isMobileView
                                                          ? context.titleSmall?.textColor(context.outlineVariant).textBold
                                                          : context.bodyLarge?.textColor(context.outlineVariant).textBold,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    VisirButton(
                                                      type: VisirButtonAnimationType.scaleAndOpacity,
                                                      style: VisirButtonStyle(
                                                        cursor: isDownloadingAll ? SystemMouseCursors.basic : SystemMouseCursors.click,
                                                        hoverColor: Colors.transparent,
                                                      ),
                                                      onTap: () async {
                                                        if (isDownloadingAll) return;
                                                        isDownloadingAll = true;
                                                        setState(() {});

                                                        final attachmentIds = attachments.map((a) => a.id).whereType<String>().toList();
                                                        final fetchResult = await ref
                                                            .read(mailThreadListControllerProvider(tabType: tabType).notifier)
                                                            .fetchAttachments(mail: e, attachmentIds: attachmentIds);

                                                        final data = fetchResult.entries
                                                            .map((entry) {
                                                              final attachment = attachments.firstWhereOrNull((a) => a.id == entry.key);
                                                              if (attachment == null) return null;
                                                              final bytes = entry.value;
                                                              return {"name": attachment.name, "data": bytes};
                                                            })
                                                            .whereType<Map>()
                                                            .toList();

                                                        await downloadBytes(
                                                          bytes: data.map((e) => e['data'] as Uint8List).toList(),
                                                          names: data.map((e) => e['name'] as String).toList(),
                                                          extensions: null,
                                                          context: context,
                                                        );

                                                        isDownloadingAll = false;
                                                        setState(() {});
                                                      },
                                                      builder: (isHover) => isDownloadingAll
                                                          ? SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 1, color: context.secondary))
                                                          : Text(
                                                              context.tr.mail_download_all,
                                                              style: context.bodyLarge
                                                                  ?.textColor(context.secondary)
                                                                  .copyWith(decoration: isHover ? TextDecoration.underline : TextDecoration.none),
                                                            ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 12),
                                                Wrap(
                                                  spacing: 12,
                                                  runSpacing: 12,
                                                  alignment: WrapAlignment.start,
                                                  runAlignment: WrapAlignment.start,
                                                  children: attachments.map((a) => MailAttachmentWidget(email: e, file: a, tabType: widget.tabType)).toList(),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 8, bottom: 8, left: 12, right: 12),
                                    child: Row(
                                      children: [
                                        VisirButton(
                                          type: VisirButtonAnimationType.scaleAndOpacity,
                                          style: VisirButtonStyle(
                                            cursor: SystemMouseCursors.click,
                                            padding: PlatformX.isMobileView ? EdgeInsets.symmetric(vertical: 8, horizontal: 12) : EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                                            backgroundColor: context.surfaceVariant,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          onTap: () => reply(e),
                                          child: Row(
                                            children: [
                                              VisirIcon(type: VisirIconType.reply, color: context.onSurfaceVariant, size: 14, isSelected: true),
                                              SizedBox(width: 6),
                                              Text(context.tr.mail_reply, style: context.bodyLarge?.textColor(context.onSurfaceVariant)),
                                            ],
                                          ),
                                        ),
                                        if (e.to.length > 1 || e.cc.length > 0) SizedBox(width: DesktopScaffold.cardPadding),
                                        if (e.to.length > 1 || e.cc.length > 0)
                                          VisirButton(
                                            type: VisirButtonAnimationType.scaleAndOpacity,
                                            style: VisirButtonStyle(
                                              cursor: SystemMouseCursors.click,
                                              padding: PlatformX.isMobileView
                                                  ? EdgeInsets.symmetric(vertical: 8, horizontal: 12)
                                                  : EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                                              backgroundColor: context.surfaceVariant,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            onTap: () => replyAll(e),
                                            child: Row(
                                              children: [
                                                VisirIcon(type: VisirIconType.replyAll, color: context.onSurfaceVariant, size: 14, isSelected: true),
                                                SizedBox(width: 6),
                                                Text(context.tr.mail_reply_all, style: context.bodyLarge?.textColor(context.onSurfaceVariant)),
                                              ],
                                            ),
                                          ),
                                        SizedBox(width: DesktopScaffold.cardPadding),
                                        VisirButton(
                                          type: VisirButtonAnimationType.scaleAndOpacity,
                                          style: VisirButtonStyle(
                                            cursor: SystemMouseCursors.click,
                                            padding: PlatformX.isMobileView ? EdgeInsets.symmetric(vertical: 8, horizontal: 12) : EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                                            backgroundColor: context.surfaceVariant,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          onTap: () => forward(e),
                                          child: Row(
                                            children: [
                                              VisirIcon(type: VisirIconType.forward, color: context.onSurfaceVariant, size: 14, isSelected: true),
                                              SizedBox(width: 6),
                                              Text(context.tr.mail_forward, style: context.bodyLarge?.textColor(context.onSurfaceVariant)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        );
                      })),
                      Container(height: context.padding.bottom),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
