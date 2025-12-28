import 'dart:async';
import 'dart:math';

import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/contextmenu/src/ContextMenuArea.dart';
import 'package:Visir/dependency/master_detail_flow/master_detail_flow.dart';
import 'package:Visir/dependency/master_detail_flow/src/widget.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/auth/domain/entities/user_entity.dart';
import 'package:Visir/features/calendar/presentation/widgets/calendar_simple_create_widget.dart';
import 'package:Visir/features/common/domain/entities/linked_item_entity.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/color_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/list_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/log_event.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/bottom_dialog_option.dart';
import 'package:Visir/features/common/presentation/widgets/fgbg_detector.dart';
import 'package:Visir/features/common/presentation/widgets/keyboard_shortcut.dart';
import 'package:Visir/features/common/presentation/widgets/multi_finger_gesture_detector.dart';
import 'package:Visir/features/common/presentation/widgets/visir_app_bar.dart';
import 'package:Visir/features/common/presentation/widgets/visir_badge.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/common/presentation/widgets/visir_list_item.dart';
import 'package:Visir/features/common/presentation/widgets/visir_search_bar.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/inbox/presentation/widgets/inbox_draggable.dart';
import 'package:Visir/features/mail/actions.dart';
import 'package:Visir/features/mail/application/mail_label_list_controller.dart';
import 'package:Visir/features/mail/application/mail_list_controller.dart';
import 'package:Visir/features/mail/domain/entities/mail_entity.dart';
import 'package:Visir/features/mail/domain/entities/mail_label_entity.dart';
import 'package:Visir/features/mail/domain/entities/mail_user_entity.dart';
import 'package:Visir/features/mail/presentation/screens/mail_detail_screen.dart';
import 'package:Visir/features/mail/presentation/widgets/mail_action_confirm_popup.dart';
import 'package:Visir/features/mail/providers.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:Visir/features/task/presentation/widgets/mobile_task_or_event_switcher_widget.dart';
import 'package:Visir/features/task/presentation/widgets/simple_task_or_event_switcher_widget.dart';
import 'package:collection/collection.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:super_context_menu/super_context_menu.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

import '../../../../dependency/flutter_swipe_action_cell/lib/core/cell.dart';

enum MailRightClickOptionType { reply, replyAll, forward, read, pin, createTask, archive, delete, spam, untrash }

extension MailRightClickOptionTypeX on MailRightClickOptionType {
  String getTitle(BuildContext context, List<MailEntity> mails, String labelId) {
    switch (this) {
      case MailRightClickOptionType.reply:
        return context.tr.mail_reply;
      case MailRightClickOptionType.replyAll:
        return context.tr.mail_reply_all;
      case MailRightClickOptionType.forward:
        return context.tr.mail_forward;
      case MailRightClickOptionType.read:
        return mails.where((e) => e.isUnread).isNotEmpty ? context.tr.mail_detail_tooltip_mark_as_read : context.tr.mail_detail_tooltip_mark_as_unread;
      case MailRightClickOptionType.pin:
        return mails.where((e) => e.isPinned).isNotEmpty ? context.tr.mail_detail_tooltip_unpin : context.tr.mail_detail_tooltip_pin;
      case MailRightClickOptionType.createTask:
        return context.tr.mail_detail_tooltip_task;
      case MailRightClickOptionType.archive:
        return mails.where((e) => e.isArchive).isNotEmpty ? context.tr.mail_detail_tooltip_unarchive : context.tr.mail_detail_tooltip_archive;
      case MailRightClickOptionType.delete:
        return labelId == CommonMailLabels.trash.id || labelId == CommonMailLabels.spam.id
            ? context.tr.mail_detail_tooltip_delete_forever
            : context.tr.mail_detail_tooltip_delete;
      case MailRightClickOptionType.spam:
        return mails.where((e) => e.isSpam).isNotEmpty ? context.tr.mail_detail_tooltip_not_spam : context.tr.mail_detail_tooltip_report_spam;
      case MailRightClickOptionType.untrash:
        return context.tr.mail_detail_tooltip_move_to_inbox;
    }
  }

  Color getTitleColor(BuildContext context, List<MailEntity> mails) {
    switch (this) {
      case MailRightClickOptionType.reply:
      case MailRightClickOptionType.replyAll:
      case MailRightClickOptionType.forward:
      case MailRightClickOptionType.read:
      case MailRightClickOptionType.pin:
      case MailRightClickOptionType.createTask:
      case MailRightClickOptionType.archive:
      case MailRightClickOptionType.untrash:
        return context.outlineVariant;
      case MailRightClickOptionType.delete:
        return context.error;
      case MailRightClickOptionType.spam:
        return mails.where((e) => e.isSpam).isNotEmpty ? context.outlineVariant : context.error;
    }
  }

  bool isDistructive(List<MailEntity> mails) {
    switch (this) {
      case MailRightClickOptionType.reply:
      case MailRightClickOptionType.replyAll:
      case MailRightClickOptionType.forward:
      case MailRightClickOptionType.read:
      case MailRightClickOptionType.pin:
      case MailRightClickOptionType.createTask:
      case MailRightClickOptionType.archive:
      case MailRightClickOptionType.untrash:
        return false;
      case MailRightClickOptionType.delete:
        return true;
      case MailRightClickOptionType.spam:
        return mails.where((e) => e.isSpam).isNotEmpty ? false : true;
    }
  }

  VisirIconType getIcon(List<MailEntity> mails) {
    switch (this) {
      case MailRightClickOptionType.reply:
        return VisirIconType.reply;
      // if (PlatformX.isApple) return CupertinoIcons.reply;
      // if (PlatformX.isWindows) return FluentIcons.arrow_reply_16_filled;
      // return CupertinoIcons.reply;
      case MailRightClickOptionType.replyAll:
        return VisirIconType.replyAll;
      // if (PlatformX.isApple) return CupertinoIcons.reply_all;
      // if (PlatformX.isWindows) return FluentIcons.arrow_reply_all_16_filled;
      // return CupertinoIcons.reply_all;
      case MailRightClickOptionType.forward:
        return VisirIconType.forward;
      // if (PlatformX.isApple) return CupertinoIcons.arrowshape_turn_up_right;
      // if (PlatformX.isWindows) return FluentIcons.arrow_forward_16_filled;
      // return Icons.forward;
      case MailRightClickOptionType.read:
        bool isUnread = mails.where((e) => e.isUnread).isNotEmpty;
        return isUnread ? VisirIconType.show : VisirIconType.hide;
      // if (PlatformX.isApple) return isUnread ? CupertinoIcons.eye : CupertinoIcons.eye_slash;
      // if (PlatformX.isWindows) return isUnread ? FluentIcons.eye_16_filled : FluentIcons.eye_off_16_filled;
      // return isUnread ? Icons.visibility : Icons.visibility_off;
      case MailRightClickOptionType.pin:
        bool isPinned = mails.where((e) => e.isPinned).isNotEmpty;
        return !isPinned ? VisirIconType.pin : VisirIconType.pinOff;
      // if (PlatformX.isApple) return !isPinned ? CupertinoIcons.pin : CupertinoIcons.pin_slash;
      // if (PlatformX.isWindows) return !isPinned ? FluentIcons.pin_16_filled : FluentIcons.pin_off_16_filled;
      // return !isPinned ? Icons.push_pin : Icons.push_pin_outlined;
      case MailRightClickOptionType.createTask:
        return VisirIconType.task;
      // if (PlatformX.isApple) return CupertinoIcons.checkmark_circle;
      // if (PlatformX.isWindows) return FluentIcons.checkmark_circle_16_filled;
      // return Icons.check;
      case MailRightClickOptionType.archive:
        bool isArchive = mails.where((e) => e.isArchive).isNotEmpty;
        return isArchive ? VisirIconType.archive : VisirIconType.archiveOff;
      // if (PlatformX.isApple) return isArchive ? CupertinoIcons.archivebox : CupertinoIcons.archivebox;
      // if (PlatformX.isWindows) return isArchive ? FluentIcons.archive_16_filled : FluentIcons.archive_16_filled;
      // return isArchive ? Icons.archive : Icons.archive_outlined;
      case MailRightClickOptionType.delete:
        return VisirIconType.trash;
      // if (PlatformX.isApple) return CupertinoIcons.trash;
      // if (PlatformX.isWindows) return FluentIcons.delete_16_filled;
      // return Icons.delete;
      case MailRightClickOptionType.spam:
        bool isSpam = mails.where((e) => e.isSpam).isNotEmpty;
        return isSpam ? VisirIconType.spam : VisirIconType.spam;
      // if (PlatformX.isApple) return isSpam ? CupertinoIcons.exclamationmark_triangle : CupertinoIcons.exclamationmark_triangle;
      // if (PlatformX.isWindows) return isSpam ? FluentIcons.book_exclamation_mark_20_filled : FluentIcons.book_exclamation_mark_20_filled;
      // return isSpam ? Icons.delete : Icons.delete_outlined;
      case MailRightClickOptionType.untrash:
        return VisirIconType.trash;
      // if (PlatformX.isApple) return CupertinoIcons.trash_slash;
      // if (PlatformX.isWindows) return FluentIcons.arrow_down_12_filled;
      // return Icons.arrow_back;
    }
  }

  IconData getMenuIcon(List<MailEntity> mails) {
    switch (this) {
      case MailRightClickOptionType.reply:
        return Icons.reply;
      case MailRightClickOptionType.replyAll:
        return Icons.reply_all;
      case MailRightClickOptionType.forward:
        return Icons.forward;
      case MailRightClickOptionType.read:
        final isUnread = mails.any((e) => e.isUnread);
        return isUnread ? Icons.visibility : Icons.visibility_off;
      case MailRightClickOptionType.pin:
        final isPinned = mails.any((e) => e.isPinned);
        return isPinned ? Icons.push_pin : Icons.push_pin_outlined;
      case MailRightClickOptionType.createTask:
        return Icons.check_circle_outline;
      case MailRightClickOptionType.archive:
        final isArchive = mails.any((e) => e.isArchive);
        return isArchive ? Icons.unarchive : Icons.archive;
      case MailRightClickOptionType.delete:
        return Icons.delete;
      case MailRightClickOptionType.spam:
        final isSpam = mails.any((e) => e.isSpam);
        return isSpam ? Icons.report_off : Icons.report;
      case MailRightClickOptionType.untrash:
        return Icons.move_to_inbox;
    }
  }
}

class MailListScreen extends ConsumerStatefulWidget {
  final String labelId;
  final String labelName;
  final String? hostEmail;
  final VoidCallback toggleSidebar;
  final bool showMobileUI;

  final void Function(MailEntity mail)? onDragStart;
  final void Function(MailEntity mail, Offset offset)? onDragUpdate;
  final void Function(MailEntity mail)? onDragEnd;

  const MailListScreen({
    Key? key,
    required this.toggleSidebar,
    required this.labelId,
    required this.labelName,
    required this.hostEmail,
    required this.showMobileUI,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
  }) : super(key: key);

  @override
  MailListScreenState createState() => MailListScreenState();
}

class MailListScreenState extends ConsumerState<MailListScreen> {
  Timer? resizeTimer;

  String get labelId => widget.labelId;

  ScrollController scrollController = ScrollController();
  ListController listController = ListController();

  TabType get tabType => TabType.mail;

  String? get searchQuery => ref.read(mailConditionProvider(tabType).select((v) => v.query));

  bool get showMobileUI => widget.showMobileUI;

  double get buttonSize => 32;

  RefreshController refreshController = RefreshController();

  final FocusNode mailSearchFocusNode = FocusNode();

  GlobalKey<MasterDetailsFlowState> mailListMasterDetailsKey = GlobalKey();

  ValueNotifier<bool> showLoadingNotifier = ValueNotifier(false);

  bool get isDarkMode => context.isDarkMode;

  List<LogicalKeyboardKey> get logicalKeyPressed => ServicesBinding.instance.keyboard.logicalKeysPressed.where((e) => e != LogicalKeyboardKey.escape).toList();

  bool get controlPressed => (logicalKeyPressed.isMetaPressed && PlatformX.isApple) || (logicalKeyPressed.isControlPressed && !PlatformX.isApple);

  bool get shiftPressed => logicalKeyPressed.isShiftPressed;

  bool isSearch = false;

  String get placeHolderTitle {
    if (isSearch) {
      return context.tr.mail_no_search_results;
    } else if (labelId == CommonMailLabels.inbox.id) {
      return context.tr.mail_no_email_inbox;
    } else if (labelId == CommonMailLabels.unread.id) {
      return context.tr.mail_no_email_unread;
    } else if (labelId == CommonMailLabels.pinned.id) {
      return context.tr.mail_no_email_pinned;
    } else if (labelId == CommonMailLabels.draft.id) {
      return context.tr.mail_no_email_draft;
    } else if (labelId == CommonMailLabels.sent.id) {
      return context.tr.mail_no_email_sent;
    } else if (labelId == CommonMailLabels.spam.id) {
      return context.tr.mail_no_email_spam;
    } else if (labelId == CommonMailLabels.trash.id) {
      return context.tr.mail_no_email_trash;
    } else {
      return '';
    }
  }

  List<String> selectedItemIds = [];
  String? get selectedItemId => mailListMasterDetailsKey.currentState?.selectedItem?.id;

  @override
  void initState() {
    super.initState();
    mailSearchFocusNode.onKeyEvent = onKeyEventTextField;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showLoadingOnMobile();
      onShowcaseOnListener();
    });

    isShowcaseOn.addListener(onShowcaseOnListener);
  }

  void onShowcaseOnListener() {
    if (isShowcaseOn.value == mailCreateTaskShowcaseKeyString) {
      EasyThrottle.throttle('mailListScreen:showcaseCreateTask', Duration(milliseconds: 3000), () {
        openDetails(id: targetMailMessageId);
      });
    }
  }

  void showLoadingOnMobile() {
    showLoadingNotifier.value = false;
  }

  void hideLoadingOnMobile() {
    showLoadingNotifier.value = false;
  }

  void addToSelectedItemIds(List<String> ids, {bool? forceSelect}) {
    if (selectedItemIds.toSet().intersection(ids.toSet()).length == ids.length && forceSelect != true) {
      if (selectedItemIds.where((e) => !ids.contains(e)).length > 0) {
        selectedItemIds.removeWhere((e) => ids.contains(e));
      }
    } else {
      selectedItemIds = [...ids, ...selectedItemIds, selectedItemId].whereType<String>().toList().unique((e) => e);
    }

    selectedItemIds.remove('multiple_select');

    setState(() {});

    // Desktop sizing is used universally; keep processing even on mobile.

    if (PlatformX.isMobileView) return;
    if (selectedItemIds.length > 1) {
      openDetails(id: 'multiple_select');
    } else {
      openDetails(id: selectedItemIds.first);
      selectedItemIds = [];
    }
  }

  void removeFromSelectedItemIds(List<String> ids) {
    if (selectedItemIds.where((e) => !ids.contains(e)).length == 0) return;
    selectedItemIds.removeWhere((e) => ids.contains(e));
    setState(() {});
    if (selectedItemIds.isEmpty) closeDetails();
  }

  void resetSelectedItemIds() {
    selectedItemIds = [];
    setState(() {});
    closeDetails();
  }

  @override
  dispose() {
    isShowcaseOn.removeListener(onShowcaseOnListener);
    listController.dispose();
    scrollController.dispose();
    resizeTimer?.cancel();
    super.dispose();
  }

  void closeDetails() {
    mailListMasterDetailsKey.currentState?.closeDetails().then((e) {
      mailViewportSyncVisibleNotifier[tabType]!.value = false;
    });
  }

  KeyEventResult onKeyEventTextField(FocusNode node, KeyEvent event) {
    final key = event.logicalKey;
    if (event is KeyDownEvent) {
      if (ServicesBinding.instance.keyboard.logicalKeysPressed.length == 1 && key == LogicalKeyboardKey.escape) {
        unsearch();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  bool _onKeyDown(KeyEvent event, {bool? justReturnResult}) {
    final key = event.logicalKey;

    if (ServicesBinding.instance.keyboard.logicalKeysPressed.length == 1 && key == LogicalKeyboardKey.escape) {
      if (isSearch) {
        if (justReturnResult == true) return true;
        unsearch();
        return true;
      }

      if (selectedItemIds.isNotEmpty) {
        if (justReturnResult == true) return true;
        resetSelectedItemIds();
        return true;
      }
    }
    final logicalKeyPressed = ServicesBinding.instance.keyboard.logicalKeysPressed.where((e) => e != LogicalKeyboardKey.escape);

    if (logicalKeyPressed.length == 2) {
      if (shiftPressed || controlPressed) {
        final selectedItemId = selectedItemIds.isEmpty ? mailListMasterDetailsKey.currentState?.selectedItem?.id : selectedItemIds.first;
        if (logicalKeyPressed.contains(LogicalKeyboardKey.arrowUp)) {
          if (justReturnResult == true) return true;
          final newItemId = mailListMasterDetailsKey.currentState?.prevItemId(selectedItemId);
          if (newItemId != null && selectedItemId != null) {
            if (!selectedItemIds.contains(newItemId)) {
              addToSelectedItemIds([newItemId]);
            } else {
              addToSelectedItemIds([selectedItemId]);
            }
          }
          return true;
        }

        if (logicalKeyPressed.contains(LogicalKeyboardKey.arrowDown)) {
          if (justReturnResult == true) return true;
          final newItemId = mailListMasterDetailsKey.currentState?.nextItemId(selectedItemId);
          if (newItemId != null && selectedItemId != null) {
            if (!selectedItemIds.contains(newItemId)) {
              addToSelectedItemIds([newItemId]);
            } else {
              addToSelectedItemIds([selectedItemId]);
            }
          }
          return true;
        }
      }
    }

    if (logicalKeyPressed.length == 1) {
      if (logicalKeyPressed.contains(LogicalKeyboardKey.arrowUp)) {
        if (justReturnResult == true) return true;
        final selectedItemId = selectedItemIds.isEmpty ? mailListMasterDetailsKey.currentState?.selectedItem?.id : selectedItemIds.first;
        final newItemId = mailListMasterDetailsKey.currentState?.prevItemId(selectedItemId);
        if (selectedItemIds.isNotEmpty && newItemId != null) {
          resetSelectedItemIds();
          openDetails(id: newItemId);
        } else {
          mailListMasterDetailsKey.currentState?.selectPrev();
        }
        return true;
      }

      if (logicalKeyPressed.contains(LogicalKeyboardKey.arrowDown)) {
        if (justReturnResult == true) return true;
        final selectedItemId = selectedItemIds.isEmpty ? mailListMasterDetailsKey.currentState?.selectedItem?.id : selectedItemIds.first;
        final newItemId = mailListMasterDetailsKey.currentState?.nextItemId(selectedItemId);
        if (selectedItemIds.isNotEmpty && newItemId != null) {
          resetSelectedItemIds();
          openDetails(id: newItemId);
        } else {
          mailListMasterDetailsKey.currentState?.selectNext();
        }
        return true;
      }
    }

    if (selectedItemIds.length > 1) {
      final mails = ref.read(mailListControllerProvider.select((e) => e.list));

      if (logicalKeyPressed.length == 2) {
        if (controlPressed) {
          if (logicalKeyPressed.contains(LogicalKeyboardKey.keyP)) {
            if (justReturnResult == true) return true;
            final targetMailsUnpinned = mails
                .map((e) => e.threads ?? [e])
                .expand((e) => e)
                .where((e) => selectedItemIds.contains(e.id) && !e.isPinned)
                .toList();
            final targetMailsPinned = mails.map((e) => e.threads ?? [e]).expand((e) => e).where((e) => selectedItemIds.contains(e.id) && e.isPinned).toList();
            if (labelId != CommonMailLabels.pinned.id && targetMailsUnpinned.isNotEmpty) {
              MailAction.pin(mails: targetMailsUnpinned, tabType: tabType);
            } else if (targetMailsPinned.isEmpty) {
              MailAction.unpin(mails: targetMailsPinned, tabType: tabType);
            }
            return true;
          }

          if (logicalKeyPressed.contains(LogicalKeyboardKey.delete) || logicalKeyPressed.contains(LogicalKeyboardKey.backspace)) {
            if (justReturnResult == true) return true;
            final targetMails = mails.map((e) => e.threads ?? [e]).expand((e) => e).where((e) => selectedItemIds.contains(e.id) && !e.isTrash).toList();
            if (labelId != CommonMailLabels.trash.id && targetMails.isNotEmpty) {
              MailAction.trash(mails: targetMails, tabType: tabType);
              resetSelectedItemIds();
              closeDetails();
            }

            return true;
          }
        }

        if (shiftPressed) {
          if (logicalKeyPressed.contains(LogicalKeyboardKey.keyI)) {
            if (justReturnResult == true) return true;
            final targetMails = mails.map((e) => e.threads ?? [e]).expand((e) => e).where((e) => selectedItemIds.contains(e.id) && e.isUnread).toList();
            if (labelId != CommonMailLabels.sent.id && targetMails.isNotEmpty) {
              MailAction.read(mails: targetMails, tabType: tabType);
            }
            return true;
          }

          if (logicalKeyPressed.contains(LogicalKeyboardKey.keyU)) {
            if (justReturnResult == true) return true;
            final targetMails = mails.map((e) => e.threads ?? [e]).expand((e) => e).where((e) => selectedItemIds.contains(e.id) && !e.isUnread).toList();
            if (labelId != CommonMailLabels.sent.id && targetMails.isNotEmpty) {
              MailAction.unread(mails: targetMails, tabType: tabType);
            }
            return true;
          }

          if (logicalKeyPressed.contains(LogicalKeyboardKey.digit3)) {
            if (justReturnResult == true) return true;
            final targetMails = mails.map((e) => e.threads ?? [e]).expand((e) => e).where((e) => selectedItemIds.contains(e.id) && !e.isTrash).toList();
            if (labelId != CommonMailLabels.trash.id && targetMails.isNotEmpty) {
              MailAction.trash(mails: targetMails, tabType: tabType);
              resetSelectedItemIds();
              closeDetails();
            }
            return true;
          }

          if (logicalKeyPressed.contains(LogicalKeyboardKey.digit1)) {
            if (justReturnResult == true) return true;
            final targetMails = mails.map((e) => e.threads ?? [e]).expand((e) => e).where((e) => selectedItemIds.contains(e.id) && !e.isSpam).toList();
            if (labelId != CommonMailLabels.spam.id && targetMails.isNotEmpty) {
              MailAction.spam(mails: targetMails, tabType: tabType);
              resetSelectedItemIds();
              closeDetails();
            }

            return true;
          }
        }
      }

      if (logicalKeyPressed.length == 1) {
        if (logicalKeyPressed.contains(LogicalKeyboardKey.keyS)) {
          if (justReturnResult == true) return true;
          final targetMails = mails.map((e) => e.threads ?? [e]).expand((e) => e).where((e) => selectedItemIds.contains(e.id) && !e.isPinned).toList();
          if (labelId != CommonMailLabels.pinned.id && targetMails.isNotEmpty) {
            MailAction.pin(mails: targetMails, tabType: tabType);
          }
          return true;
        }

        if (logicalKeyPressed.contains(LogicalKeyboardKey.keyE)) {
          if (justReturnResult == true) return true;
          final targetMails = mails.map((e) => e.threads ?? [e]).expand((e) => e).where((e) => selectedItemIds.contains(e.id) && !e.isArchive).toList();
          if (labelId != CommonMailLabels.archive.id && targetMails.isNotEmpty) {
            MailAction.archive(mails: targetMails, tabType: tabType);
            resetSelectedItemIds();
            closeDetails();
          }

          return true;
        }

        if (logicalKeyPressed.contains(LogicalKeyboardKey.exclamation)) {
          if (justReturnResult == true) return true;
          final targetMails = mails.map((e) => e.threads ?? [e]).expand((e) => e).where((e) => selectedItemIds.contains(e.id) && !e.isSpam).toList();
          if (labelId != CommonMailLabels.spam.id && targetMails.isNotEmpty) {
            MailAction.spam(mails: targetMails, tabType: tabType);
            resetSelectedItemIds();
            closeDetails();
          }
          return true;
        }
      }
    }

    return false;
  }

  bool _onKeyRepeat(KeyEvent event, {bool? justReturnResult}) {
    final logicalKeyPressed = ServicesBinding.instance.keyboard.logicalKeysPressed.where((e) => e != LogicalKeyboardKey.escape);
    if (logicalKeyPressed.length == 1) {
      if (logicalKeyPressed.contains(LogicalKeyboardKey.arrowUp)) {
        if (justReturnResult == true) return true;
        final selectedItemId = selectedItemIds.isEmpty ? mailListMasterDetailsKey.currentState?.selectedItem?.id : selectedItemIds.first;
        final newItemId = mailListMasterDetailsKey.currentState?.prevItemId(selectedItemId);
        if (selectedItemIds.isNotEmpty && newItemId != null) {
          resetSelectedItemIds();
          openDetails(id: newItemId);
        } else {
          mailListMasterDetailsKey.currentState?.selectPrev();
        }
        return true;
      }

      if (logicalKeyPressed.contains(LogicalKeyboardKey.arrowDown)) {
        if (justReturnResult == true) return true;
        final selectedItemId = selectedItemIds.isEmpty ? mailListMasterDetailsKey.currentState?.selectedItem?.id : selectedItemIds.first;
        final newItemId = mailListMasterDetailsKey.currentState?.nextItemId(selectedItemId);
        if (selectedItemIds.isNotEmpty && newItemId != null) {
          resetSelectedItemIds();
          openDetails(id: newItemId);
        } else {
          mailListMasterDetailsKey.currentState?.selectNext();
        }
        return true;
      }
    }

    if (logicalKeyPressed.length == 2) {
      if (shiftPressed || controlPressed) {
        final selectedItemId = selectedItemIds.isEmpty ? mailListMasterDetailsKey.currentState?.selectedItem?.id : selectedItemIds.first;
        if (logicalKeyPressed.contains(LogicalKeyboardKey.arrowUp)) {
          if (justReturnResult == true) return true;
          final newItemId = mailListMasterDetailsKey.currentState?.prevItemId(selectedItemId);
          if (newItemId != null && selectedItemId != null) {
            if (!selectedItemIds.contains(newItemId)) {
              addToSelectedItemIds([newItemId]);
            } else {
              addToSelectedItemIds([selectedItemId]);
            }
          }
          return true;
        }

        if (logicalKeyPressed.contains(LogicalKeyboardKey.arrowDown)) {
          if (justReturnResult == true) return true;
          final newItemId = mailListMasterDetailsKey.currentState?.nextItemId(selectedItemId);
          if (newItemId != null && selectedItemId != null) {
            if (!selectedItemIds.contains(newItemId)) {
              addToSelectedItemIds([newItemId]);
            } else {
              addToSelectedItemIds([selectedItemId]);
            }
          }
          return true;
        }
      }
    }

    return false;
  }

  Widget buildAppBarButton(VisirIconType icon, VoidCallback onTap, {VisirButtonOptions? options}) {
    return VisirAppBarButton(icon: icon, onTap: onTap, options: options).getButton(context: context);
  }

  void close() {
    mailListMasterDetailsKey.currentState?.closeDetails();
  }

  void search() {
    if (isSearch) {
      mailSearchFocusNode.requestFocus();
      return;
    }

    isSearch = true;
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      mailSearchFocusNode.requestFocus();
    });
  }

  void unsearch() {
    ref.read(mailConditionProvider(tabType).notifier).setQuery(null);
    mailSearchFocusNode.unfocus();
    isSearch = false;
    setState(() {});
  }

  Future<void> refresh() async {
    hideLoadingOnMobile();
    await ref.read(mailListControllerProvider.notifier).refresh();
    ref.read(mailLabelListControllerProvider.notifier).load();
    showLoadingOnMobile();
  }

  Future<bool> loadMore() async {
    hideLoadingOnMobile();
    try {
      if (isSearch && searchQuery != null) {
        await ref.read(mailListControllerProvider.notifier).search(loadMore: true);
      } else {
        await ref.read(mailListControllerProvider.notifier).loadMore();
      }
      showLoadingOnMobile();
      return ref.read(mailListControllerProvider.notifier).isAbleToLoadMore == true;
    } catch (e) {
      showLoadingOnMobile();
      return false;
    }
  }

  void compose() {
    Utils.showMailEditScreen();
    logAnalyticsEvent(eventName: 'mail_compose');
  }

  void openDetails({required String id}) {
    if (mailListMasterDetailsKey.currentState?.selectedItem?.id == id) return;
    mailListMasterDetailsKey.currentState?.openDetails(id: id);
  }

  void checkPayloadThenAction() {
    final payload = notificationPayload;
    if (payload == null) return;
    if (payload['isHome'] != null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      switch (payload['type']) {
        case 'gmail':
          final mailId = payload['mailId'];
          final threadId = payload['threadId'];
          if (threadId == null) return;
          if (mailId == null) return;
          if (labelId != CommonMailLabels.inbox.id || widget.hostEmail != null) return;
          if (ref.read(mailConditionProvider(tabType)).threadId == threadId) return;

          final messages = ref.read(mailListControllerProvider.select((v) => v.list));
          final index = messages.indexWhere((e) => e.threadId == threadId);

          if (index < 0) return;
          Future.delayed(Duration(milliseconds: 1000), () {
            if (!mounted) return;
            if (!listController.isAttached) return;
            listController.animateToItem(
              index: index,
              scrollController: scrollController,
              alignment: 0.5,
              duration: (distance) => Duration(milliseconds: 100),
              curve: (distance) => Curves.easeInOut,
            );
          });

          openDetails(id: mailId);
          break;
      }
    });
  }

  Future<void> swipeButtonAction(CompletionHandler handler, MailPrefSwipeActionType actionType, MailEntity mail) async {
    List<MailPrefSwipeActionType> removeFromListActionTypes = [
      MailPrefSwipeActionType.archive,
      MailPrefSwipeActionType.delete,
      MailPrefSwipeActionType.reportSpam,
    ];

    if (labelId == CommonMailLabels.unread.id) {
      removeFromListActionTypes.add(MailPrefSwipeActionType.readUnread);
    } else if (labelId == CommonMailLabels.pinned.id) {
      removeFromListActionTypes.add(MailPrefSwipeActionType.pinUnpin);
    }

    bool isRemoveFromList = removeFromListActionTypes.contains(actionType);

    await handler(isRemoveFromList);

    switch (actionType) {
      case MailPrefSwipeActionType.none:
        break;
      case MailPrefSwipeActionType.readUnread:
        if (mail.isUnread) {
          MailAction.read(mails: mail.threads?.where((e) => e.isUnread).toList() ?? [mail], tabType: tabType);
        } else {
          MailAction.unread(mails: mail.threads?.where((e) => !e.isUnread).toList() ?? [mail], tabType: tabType);
        }
        break;
      case MailPrefSwipeActionType.pinUnpin:
        if (mail.isPinned) {
          MailAction.unpin(mails: mail.threads?.where((e) => e.isPinned).toList() ?? [mail], tabType: tabType);
        } else {
          MailAction.pin(mails: mail.threads?.where((e) => !e.isPinned).toList() ?? [mail], tabType: tabType);
        }
        break;
      case MailPrefSwipeActionType.createTask:
        Utils.showPopupDialog(
          child: MobileTaskOrEventSwitcherWidget(
            isEvent: false,
            isAllDay: true,
            selectedDate: DateUtils.dateOnly(DateTime.now()),
            startDate: DateUtils.dateOnly(DateTime.now()),
            endDate: DateUtils.dateOnly(DateTime.now()),
            tabType: tabType,
            titleHintText: mail.subject,
            description: mail.snippet,
            originalTaskMail: LinkedMailEntity(
              title: mail.subject ?? '',
              hostMail: mail.hostEmail,
              fromName: mail.from?.name ?? mail.from?.email ?? '',
              messageId: mail.id!,
              threadId: mail.threadId!,
              type: mail.type,
              date: mail.date ?? DateTime.now(),
              link: mail.link,
              pageToken: mail.pageToken,
              labelIds: mail.labelIds ?? [],
              encrypted: true,
              timezone: mail.timezone,
            ),
            calendarTaskEditSourceType: CalendarTaskEditSourceType.mail,
          ),
        );
        break;
      case MailPrefSwipeActionType.archive:
        MailAction.archive(mails: mail.threads?.where((e) => !e.isArchive).toList() ?? [mail], tabType: tabType);
        break;

      case MailPrefSwipeActionType.delete:
        if (mail.isDraft) {
          MailAction.removeDarft(mail: mail);
        } else if (mail.isTrash || mail.isSpam) {
          MailAction.delete(mails: mail.threads ?? [mail], tabType: tabType);
        } else {
          MailAction.trash(mails: mail.threads?.where((e) => !e.isTrash).toList() ?? [mail], tabType: tabType);
        }
        break;

      case MailPrefSwipeActionType.reportSpam:
        MailAction.spam(mails: mail.threads?.where((e) => !e.isSpam).toList() ?? [mail], tabType: tabType);
        break;
    }

    setState(() {});
  }

  List<SwipeAction> swipeActions({required MailEntity mail, required MailPrefSwipeActionType type}) {
    List<SwipeAction> defaultActions = [
      SwipeAction(
        performsFirstActionWithFullSwipe: true,
        title: type.getSwipeButtonTitle(context, mail.isUnread, mail.isPinned),
        subtitle: type.getSwipeButtonSubtitle(context, mail.isUnread, mail.isPinned),
        icon: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: type.getColor(context)),
          alignment: Alignment.center,
          child: VisirIcon(type: type.icon, size: 16, color: context.onSurface),
        ),
        style: context.labelLarge!.textColor(context.onPrimary).textBold.appFont(context),
        widthSpace: 100,
        color: Colors.transparent,
        onTap: (CompletionHandler handler) {
          HapticFeedback.lightImpact();
          swipeButtonAction(handler, type, mail);
        },
      ),
    ];

    if (mail.isDraft) {
      if (type == MailPrefSwipeActionType.delete) {
        return defaultActions;
      } else {
        return [];
      }
    } else if (mail.isSpam) {
      switch (type) {
        case MailPrefSwipeActionType.none:
        case MailPrefSwipeActionType.readUnread:
        case MailPrefSwipeActionType.pinUnpin:
        case MailPrefSwipeActionType.createTask:
        case MailPrefSwipeActionType.reportSpam:
          return [];
        case MailPrefSwipeActionType.archive:
        case MailPrefSwipeActionType.delete:
          return defaultActions;
      }
    } else if (mail.isTrash) {
      switch (type) {
        case MailPrefSwipeActionType.none:
        case MailPrefSwipeActionType.readUnread:
        case MailPrefSwipeActionType.pinUnpin:
        case MailPrefSwipeActionType.createTask:
        case MailPrefSwipeActionType.archive:
          return [];
        case MailPrefSwipeActionType.delete:
        case MailPrefSwipeActionType.reportSpam:
          return defaultActions;
      }
    } else if (mail.isSent) {
      if (type == MailPrefSwipeActionType.reportSpam) {
        return [];
      } else {
        return defaultActions;
      }
    } else {
      switch (type) {
        case MailPrefSwipeActionType.none:
          return [];
        case MailPrefSwipeActionType.readUnread:
        case MailPrefSwipeActionType.pinUnpin:
        case MailPrefSwipeActionType.createTask:
        case MailPrefSwipeActionType.archive:
        case MailPrefSwipeActionType.delete:
        case MailPrefSwipeActionType.reportSpam:
          return defaultActions;
      }
    }
  }

  MailUserEntity getMeFromMail(MailEntity mail) {
    final pref = ref.read(localPrefControllerProvider).value;

    final mailOAuth = (pref?.mailOAuths ?? []).firstWhereOrNull((element) => element.email == mail.hostEmail);

    return MailUserEntity(
      name: mailOAuth!.name,
      email: mailOAuth.email,
      type: mailOAuth.type == OAuthType.google ? MailEntityType.google : MailEntityType.google,
    );
  }

  List<MailRightClickOptionType> rightClickOptions(List<MailEntity> mails) {
    List<MailRightClickOptionType> items = labelId.toLowerCase() == CommonMailLabels.draft.name.toLowerCase()
        ? [MailRightClickOptionType.delete]
        : [...MailRightClickOptionType.values];
    if (labelId.toLowerCase() == CommonMailLabels.spam.name.toLowerCase()) {
      items.remove(MailRightClickOptionType.read);
      items.remove(MailRightClickOptionType.pin);
      items.remove(MailRightClickOptionType.createTask);
      items.remove(MailRightClickOptionType.untrash);
    } else if (labelId.toLowerCase() == CommonMailLabels.trash.name.toLowerCase()) {
      items.remove(MailRightClickOptionType.pin);
      items.remove(MailRightClickOptionType.createTask);
      items.remove(MailRightClickOptionType.read);
      items.remove(MailRightClickOptionType.archive);
    } else if (labelId.toLowerCase() == CommonMailLabels.sent.name.toLowerCase()) {
      items.remove(MailRightClickOptionType.spam);
      items.remove(MailRightClickOptionType.untrash);
    } else {
      items.remove(MailRightClickOptionType.untrash);
    }

    final toWithoutMe = mails.length != 1 ? [] : mails.first.to.where((u) => u.email != mails.first.hostEmail).toList();
    if (toWithoutMe.isEmpty) {
      items.remove(MailRightClickOptionType.replyAll);
    }

    if (mails.length != 1) {
      items.remove(MailRightClickOptionType.forward);
      items.remove(MailRightClickOptionType.reply);
      items.remove(MailRightClickOptionType.createTask);
    }

    final containsOutlookEmail = mails.any((e) => e.type == MailEntityType.microsoft);
    if (containsOutlookEmail && (labelId == CommonMailLabels.trash.id || labelId == CommonMailLabels.spam.id)) items.remove(MailRightClickOptionType.delete);

    return items;
  }

  void reply(MailEntity e) {
    logAnalyticsEvent(eventName: 'mail_reply');
    Utils.replyMail(mail: e, me: getMeFromMail(e));
  }

  void replyAll(MailEntity e) {
    logAnalyticsEvent(eventName: 'mail_reply_all');
    Utils.replyAllMail(mail: e, me: getMeFromMail(e));
  }

  void forward(MailEntity e) {
    logAnalyticsEvent(eventName: 'mail_forward');
    Utils.forwardMail(mail: e, me: getMeFromMail(e));
  }

  void showCreateTaskPopup(MailEntity mail, Offset? offset, UserEntity user) {
    if (PlatformX.isMobile) {
      Utils.showPopupDialog(
        child: MobileTaskOrEventSwitcherWidget(
          isEvent: false,
          isAllDay: true,
          selectedDate: DateUtils.dateOnly(DateTime.now()),
          startDate: DateUtils.dateOnly(DateTime.now()),
          endDate: DateUtils.dateOnly(DateTime.now()),
          tabType: tabType,
          titleHintText: mail.subject,
          description: mail.snippet,
          originalTaskMail: LinkedMailEntity(
            title: mail.subject ?? '',
            hostMail: mail.hostEmail,
            fromName: mail.from?.name ?? mail.from?.email ?? '',
            messageId: mail.id!,
            threadId: mail.threadId!,
            type: mail.type,
            date: mail.date ?? DateTime.now(),
            link: mail.link,
            pageToken: mail.pageToken,
            labelIds: mail.labelIds ?? [],
            encrypted: true,
          ),
          calendarTaskEditSourceType: CalendarTaskEditSourceType.mail,
        ),
      );
    } else if (offset != null) {
      showContextMenu(
        topLeft: Offset(offset.dx, offset.dy),
        bottomRight: Offset(offset.dx + 0, offset.dy + 0),
        context: context,
        child: SimpleTaskOrEventSwithcerWidget(
          tabType: tabType,
          isEvent: false,
          startDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, DateTime.now().hour, (DateTime.now().minute ~/ 15 + 1) * 15),
          endDate: DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            DateTime.now().hour,
            (DateTime.now().minute ~/ 15 + 1) * 15,
          ).add(Duration(minutes: user.userTaskDefaultDurationInMinutes)),
          isAllDay: true,
          selectedDate: DateUtils.dateOnly(DateTime.now()),
          titleHintText: mail.subject,
          description: mail.snippet,
          originalTaskMail: LinkedMailEntity(
            title: mail.subject ?? '',
            hostMail: mail.hostEmail,
            fromName: mail.from?.name ?? mail.from?.email ?? '',
            messageId: mail.id!,
            threadId: mail.threadId!,
            type: mail.type,
            date: mail.date ?? DateTime.now(),
            link: mail.link,
            pageToken: mail.pageToken,
            labelIds: mail.labelIds ?? [],
            encrypted: true,
          ),
          calendarTaskEditSourceType: CalendarTaskEditSourceType.mail,
        ),
        verticalPadding: 16.0,
        borderRadius: 6.0,
        width: Constants.desktopCreateTaskPopupWidth,
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        clipBehavior: Clip.none,
        isPopupMenu: false,
        hideShadow: true,
      );
    }
  }

  void showMailOptionsBottomDialog({required MailEntity mail, required List<MailEntity> mails, required BuildContext context}) async {
    if (selectedItemIds.isEmpty) {
      addToSelectedItemIds([mail.id!]);
    } else if (!selectedItemIds.contains(mail.id)) {
      resetSelectedItemIds();
      addToSelectedItemIds([mail.id!]);
    }

    List<MailEntity> targetMails = selectedItemIds.contains(mail.id!) ? mails.where((e) => selectedItemIds.contains(e.id)).toList() : [mail];

    final options = rightClickOptions(targetMails);
    final simpleButtonOptions = options
        .where((e) => [MailRightClickOptionType.reply, MailRightClickOptionType.replyAll, MailRightClickOptionType.forward].contains(e))
        .toList();
    options.removeWhere((e) => [MailRightClickOptionType.reply, MailRightClickOptionType.replyAll, MailRightClickOptionType.forward].contains(e));

    await Utils.showBottomDialog(
      title: TextSpan(text: context.tr.mail_options),
      body: Column(
        children: [
          if (simpleButtonOptions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 8, left: 16, right: 16),
              child: Row(
                spacing: 8.0,
                children: [
                  ...simpleButtonOptions.map(
                    (e) => Expanded(
                      child: VisirButton(
                        type: VisirButtonAnimationType.scaleAndOpacity,
                        style: VisirButtonStyle(
                          border: Border.all(width: 1, color: context.outline),
                          borderRadius: BorderRadius.circular(8),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                        ),
                        onTap: () {
                          context.pop();
                          getMailAction(type: e, mails: targetMails);
                        },
                        child: simpleButtonOptions.contains(MailRightClickOptionType.replyAll)
                            ? VisirIcon(type: e.getIcon(targetMails), size: 16, color: isDarkMode ? context.onSurface : context.shadow, isSelected: true)
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  VisirIcon(type: e.getIcon(mails), size: 16, color: isDarkMode ? context.onSurface : context.shadow, isSelected: true),
                                  const SizedBox(width: 12),
                                  Text(
                                    e.getTitle(context, mails, labelId),
                                    style: context.bodyLarge?.textColor(isDarkMode ? context.onSurface : context.shadow),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ...options
              .map(
                (e) => BottomDialogOption(
                  icon: e.getIcon(targetMails),
                  title: e.getTitle(context, targetMails, labelId),
                  onTap: () => getMailAction(type: e, mails: targetMails),
                  isWarning: e.getTitleColor(context, targetMails) == context.error,
                ),
              )
              .toList(),
        ],
      ),
    );

    resetSelectedItemIds();
  }

  void getMailAction({required MailRightClickOptionType type, required List<MailEntity> mails, Offset? position}) {
    final user = ref.read(authControllerProvider).requireValue;
    switch (type) {
      case MailRightClickOptionType.reply:
        if (mails.length == 1) reply(mails.first);
        break;
      case MailRightClickOptionType.replyAll:
        if (mails.length == 1) replyAll(mails.first);
        break;
      case MailRightClickOptionType.forward:
        if (mails.length == 1) forward(mails.first);
        break;
      case MailRightClickOptionType.read:
        if (mails.where((e) => e.isUnread).isNotEmpty) {
          mails = mails.map((e) => e.threads ?? [e]).expand((e) => e).toList();
          final targetMails = mails.where((e) => e.isUnread).toList();
          MailAction.read(mails: targetMails, tabType: tabType);
        } else {
          final targetMails = mails.where((e) => !e.isUnread).toList();
          MailAction.unread(mails: targetMails, tabType: tabType);
        }
        break;
      case MailRightClickOptionType.pin:
        if (mails.where((e) => !e.isPinned).isNotEmpty) {
          final targetMails = mails.where((e) => !e.isPinned).toList();
          MailAction.pin(mails: targetMails, tabType: tabType);
        } else {
          mails = mails.map((e) => e.threads ?? [e]).expand((e) => e).toList();
          final targetMails = mails.where((e) => e.isPinned).toList();
          MailAction.unpin(mails: targetMails, tabType: tabType);
        }
        break;
      case MailRightClickOptionType.createTask:
        if (mails.length == 1) showCreateTaskPopup(mails.first, position, user);
      case MailRightClickOptionType.archive:
        if (mails.where((e) => !e.isArchive).isNotEmpty) {
          mails = mails.map((e) => e.threads ?? [e]).expand((e) => e).toList();
          final targetMails = mails.where((e) => !e.isArchive).toList();
          MailAction.archive(mails: targetMails, tabType: tabType);
        } else {
          final targetMails = mails.where((e) => e.isArchive).toList();
          MailAction.unarchive(mails: targetMails, tabType: tabType);
        }
        break;
      case MailRightClickOptionType.delete:
        if (labelId == CommonMailLabels.draft.id) {
          final targetMails = mails.where((e) => e.isDraft).toList();
          targetMails.forEach((m) => MailAction.removeDarft(mail: m));
        } else if (labelId == CommonMailLabels.trash.id || labelId == CommonMailLabels.spam.id) {
          mails = mails.map((e) => e.threads ?? [e]).expand((e) => e).toList();
          MailAction.delete(mails: mails, tabType: tabType);
        } else {
          mails = mails.map((e) => e.threads ?? [e]).expand((e) => e).toList();
          final targetMails = mails.where((e) => !e.isTrash).toList();
          MailAction.trash(mails: targetMails, tabType: tabType);
        }
        resetSelectedItemIds();
        closeDetails();
        break;
      case MailRightClickOptionType.spam:
        if (mails.where((e) => !e.isSpam).isNotEmpty) {
          mails = mails.map((e) => e.threads ?? [e]).expand((e) => e).toList();
          final targetMails = mails.where((e) => !e.isSpam).toList();
          MailAction.spam(mails: targetMails, tabType: tabType);
        } else {
          mails = mails.map((e) => e.threads ?? [e]).expand((e) => e).toList();
          final targetMails = mails.where((e) => e.isSpam).toList();
          MailAction.unspam(mails: targetMails, tabType: tabType);
        }
        resetSelectedItemIds();
        closeDetails();
        break;
      case MailRightClickOptionType.untrash:
        mails = mails.map((e) => e.threads ?? [e]).expand((e) => e).toList();
        final targetMails = mails.where((e) => e.isTrash).toList();

        MailAction.untrash(mails: targetMails, tabType: tabType);
        resetSelectedItemIds();
        closeDetails();
        break;
    }
  }

  Widget buildDraggable({required Widget child, required MailEntity mail}) {
    final ratio = ref.watch(zoomRatioProvider);
    final feedbackWidget = Material(
      color: Colors.transparent,
      child: Opacity(
        opacity: 0.5,
        child: Container(
          constraints: BoxConstraints(maxWidth: 180),
          decoration: BoxDecoration(color: context.surface, borderRadius: BorderRadius.circular(6)),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Text(mail.subject ?? context.tr.mail_no_subject, style: context.bodyLarge?.textColor(context.onBackground)),
        ),
      ),
    );

    if (PlatformX.isMobileView) {
      return InboxLongPressDraggable(
        scaleFactor: ratio,
        dragAnchorStrategy: (InboxDraggable<Object> d, BuildContext context, Offset point) {
          return Offset(d.feedbackOffset.dx, d.feedbackOffset.dy);
        },
        onDragStarted: () => widget.onDragStart?.call(mail),
        onDragUpdate: (details) => widget.onDragUpdate?.call(mail, details.globalPosition / ratio),
        onDragEnd: (details) => widget.onDragEnd?.call(mail),
        hitTestBehavior: HitTestBehavior.opaque,
        feedback: feedbackWidget,
        child: child,
      );
    }

    return InboxDraggable(
      scaleFactor: ratio,
      dragAnchorStrategy: (InboxDraggable<Object> d, BuildContext context, Offset point) {
        return Offset(d.feedbackOffset.dx, d.feedbackOffset.dy);
      },
      onDragStarted: () => widget.onDragStart?.call(mail),
      onDragUpdate: (details) => widget.onDragUpdate?.call(mail, details.globalPosition / ratio),
      onDragEnd: (details) => widget.onDragEnd?.call(mail),
      hitTestBehavior: HitTestBehavior.opaque,
      feedback: feedbackWidget,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mails = ref.watch(mailListControllerProvider.select((v) => v.list));
    final mailColors = ref.watch(authControllerProvider.select((e) => e.requireValue.userMailColors));
    final mailSwipeLeftActionType = ref.watch(authControllerProvider.select((e) => e.requireValue.userMailSwipeLeftActionType));

    ref.listen(mailListControllerProvider, (previous, next) {
      checkPayloadThenAction();
    });

    ref.listen(localPrefControllerProvider, (previous, next) {
      if (previous?.value?.notificationPayload != next.value?.notificationPayload) {
        checkPayloadThenAction();
      }
    });

    ref.listen(mailConditionProvider(tabType), (previous, next) {
      if (next.threadId == null) {
        closeDetails();
      }
    });
    final closableDrawer = ref.watch(resizableClosableDrawerProvider(tabType));

    return FGBGDetector(
      onChanged: (isForeground, isFirst) {
        if (!isForeground) return;
        checkPayloadThenAction();
      },
      child: KeyboardShortcut(
        targetTab: tabType,
        onKeyDown: _onKeyDown,
        onKeyRepeat: _onKeyRepeat,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return MultiFingerGestureDetector(
              builder: (multiFingerGestureController) => Container(
                child: MasterDetailsFlow(
                  tabType: tabType,
                  key: mailListMasterDetailsKey,
                  isDetailExpanded: true,
                  beforeOpenDetails: (id) {
                    final mail = mails.firstWhereOrNull((e) => e.id == id);
                    if (mail == null) return;
                    ref
                        .read(mailConditionProvider(tabType).notifier)
                        .openJustThread(threadId: mail.threadId!, threadEmail: mail.hostEmail, type: mail.type, threads: [mail]);
                    mailViewportSyncVisibleNotifier[tabType]!.value = false;
                  },
                  afterOpenDetails: (id) {
                    mailViewportSyncVisibleNotifier[tabType]!.value = true;
                  },
                  refocusOnItemDeleted: true,
                  onTargetResized: (width) {},
                  enableDetailsSelection: true,
                  listController: listController,
                  refreshController: refreshController,
                  scrollController: scrollController,
                  masterBackgroundColor: context.background,
                  detailBackgroundColor: context.background,
                  appbarSize: showMobileUI
                      ? isSearch
                            ? 56
                            : 52
                      : 48,
                  topPadding: 0,
                  breakpoint: 240,
                  minMasterResizableWidth: 240,
                  minDetailResizableWidth: 240,
                  // maxResizableWidth: constraints.maxWidth - 360,
                  // initialMasterPanelWidth: masterWidth,
                  masterAppBar: DetailsAppBarSize.small,
                  lateralDetailsAppBar: DetailsAppBarSize.small,
                  showAppBarDivider: true,
                  masterShowLoadingNotifier: showLoadingNotifier,

                  leadings: isSearch
                      ? [
                          Expanded(
                            child: VisirSearchBar(
                              initialValue: searchQuery,
                              hintText: context.tr.mail_search_placeholder,
                              onClose: unsearch,
                              focusNode: mailSearchFocusNode,
                              onSubmitted: (value) async {
                                ref.read(mailConditionProvider(tabType).notifier).setQuery(value);
                                close();
                                mailSearchFocusNode.requestFocus();
                                logAnalyticsEvent(eventName: 'mail_search');
                              },
                            ),
                          ),
                        ]
                      : [
                          SizedBox(width: 6),
                          if (closableDrawer == null) buildAppBarButton(VisirIconType.control, widget.toggleSidebar),
                          buildAppBarButton(
                            VisirIconType.search,
                            search,
                            options: VisirButtonOptions(
                              tabType: tabType,
                              shortcuts: [
                                VisirButtonKeyboardShortcut(
                                  message: context.tr.search_mail,
                                  keys: [
                                    LogicalKeyboardKey.keyF,
                                    if (PlatformX.isApple) LogicalKeyboardKey.meta,
                                    if (!PlatformX.isApple) LogicalKeyboardKey.control,
                                  ],
                                ),
                              ],
                            ),
                          ),
                          VisirAppBarButton(isDivider: true).getButton(context: context),
                          Container(
                            padding: const EdgeInsets.only(left: 6),
                            constraints: BoxConstraints(maxWidth: 200),
                            child: Text(
                              widget.labelName,
                              style: context.titleLarge?.textColor(context.outlineVariant).textBold.appFont(context),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                  actions: isSearch
                      ? null
                      : [
                          if (selectedItemIds.isNotEmpty && showMobileUI)
                            VisirButton(
                              type: VisirButtonAnimationType.scaleAndOpacity,
                              style: VisirButtonStyle(
                                cursor: SystemMouseCursors.click,
                                height: buttonSize,
                                backgroundColor: context.primary,
                                borderRadius: BorderRadius.circular(6),
                                padding: EdgeInsets.symmetric(horizontal: 8),
                              ),
                              onTap: resetSelectedItemIds,
                              child: Row(
                                children: [
                                  Text(context.tr.n_selected(selectedItemIds.length), style: context.labelLarge?.textColor(context.onPrimary).appFont(context)),
                                  SizedBox(width: 6),
                                  VisirIcon(type: VisirIconType.closeWithCircle, color: context.onPrimary, size: 16, isSelected: true),
                                ],
                              ),
                            ),
                          if (labelId != CommonMailLabels.trash.id && labelId != CommonMailLabels.spam.id && labelId != CommonMailLabels.draft.id)
                            if (PlatformX.isDesktopView)
                              VisirButton(
                                type: VisirButtonAnimationType.scaleAndOpacity,
                                style: VisirButtonStyle(
                                  cursor: SystemMouseCursors.click,
                                  height: buttonSize,
                                  backgroundColor: context.primary,
                                  borderRadius: BorderRadius.circular(6),
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                ),
                                options: VisirButtonOptions(
                                  tabType: tabType,
                                  shortcuts: [
                                    VisirButtonKeyboardShortcut(
                                      message: '',
                                      keys: [
                                        LogicalKeyboardKey.keyN,
                                        if (PlatformX.isApple) LogicalKeyboardKey.meta,
                                        if (!PlatformX.isApple) LogicalKeyboardKey.control,
                                      ],
                                    ),
                                  ],
                                ),
                                onTap: compose,
                                child: Row(
                                  children: [
                                    VisirIcon(type: VisirIconType.edit, color: context.onPrimary, size: 16, isSelected: true),
                                    SizedBox(width: 6),
                                    Text(context.tr.mail_compose, style: context.labelLarge?.textColor(context.onPrimary).appFont(context)),
                                  ],
                                ),
                              )
                            else
                              VisirAppBarButton(icon: VisirIconType.edit, onTap: compose).getButton(context: context),
                          if (labelId == CommonMailLabels.trash.id)
                            VisirButton(
                              type: VisirButtonAnimationType.scaleAndOpacity,
                              style: VisirButtonStyle(
                                height: buttonSize,
                                backgroundColor: context.error,
                                borderRadius: BorderRadius.circular(6),
                                padding: EdgeInsets.symmetric(horizontal: 10),
                              ),
                              onTap: () async {
                                if (showMobileUI) {
                                  Utils.showMobileConfirmPopup(
                                    title: context.tr.mail_empty_trash,
                                    description: context.tr.mail_empty_description,
                                    onPressConfirm: () => MailAction.deleteAll(labelId: CommonMailLabels.trash.id, tabType: tabType),
                                  );
                                } else {
                                  Utils.showPopupDialog(
                                    forcePopup: true,
                                    isFlexibleHeightPopup: true,
                                    size: Size(320, 0),
                                    child: MailActionConfirmPopup(
                                      title: context.tr.mail_empty_trash,
                                      description: context.tr.mail_empty_description,
                                      onPressOk: () => MailAction.deleteAll(labelId: CommonMailLabels.trash.id, tabType: tabType),
                                    ),
                                  );
                                }
                              },
                              child: Row(
                                children: [
                                  VisirIcon(type: VisirIconType.trash, color: context.onPrimary, size: 16),
                                  SizedBox(width: 6),
                                  Text(context.tr.mail_empty_trash, style: context.labelLarge?.textColor(context.onPrimary).appFont(context)),
                                ],
                              ),
                            ),
                          if (labelId == CommonMailLabels.spam.id)
                            VisirButton(
                              type: VisirButtonAnimationType.scaleAndOpacity,
                              style: VisirButtonStyle(
                                height: buttonSize,
                                backgroundColor: context.error,
                                borderRadius: BorderRadius.circular(6),
                                padding: EdgeInsets.symmetric(horizontal: 10),
                              ),
                              onTap: () {
                                if (showMobileUI) {
                                  Utils.showMobileConfirmPopup(
                                    title: context.tr.mail_empty_spam,
                                    description: context.tr.mail_empty_description,
                                    onPressConfirm: () => MailAction.deleteAll(labelId: CommonMailLabels.spam.id, tabType: tabType),
                                  );
                                } else {
                                  Utils.showPopupDialog(
                                    forcePopup: true,
                                    isFlexibleHeightPopup: true,
                                    size: Size(320, 0),
                                    child: MailActionConfirmPopup(
                                      title: context.tr.mail_empty_spam,
                                      description: context.tr.mail_empty_description,
                                      onPressOk: () => MailAction.deleteAll(labelId: CommonMailLabels.spam.id, tabType: tabType),
                                    ),
                                  );
                                }
                              },
                              child: Row(
                                children: [
                                  VisirIcon(type: VisirIconType.trash, color: context.onPrimary, size: 16),
                                  SizedBox(width: 6),
                                  Text(context.tr.mail_empty_spam, style: context.labelLarge?.textColor(context.onPrimary).appFont(context)),
                                ],
                              ),
                            ),
                          if (labelId == CommonMailLabels.draft.id)
                            VisirButton(
                              type: VisirButtonAnimationType.scaleAndOpacity,
                              style: VisirButtonStyle(
                                height: buttonSize,
                                backgroundColor: context.error,
                                borderRadius: BorderRadius.circular(6),
                                padding: EdgeInsets.symmetric(horizontal: 10),
                              ),
                              onTap: () {
                                if (showMobileUI) {
                                  Utils.showMobileConfirmPopup(
                                    title: context.tr.mail_discard_drafts,
                                    description: context.tr.mail_discard_drafts_description,
                                    onPressConfirm: () => MailAction.deleteAll(labelId: CommonMailLabels.draft.id, tabType: tabType),
                                  );
                                } else {
                                  Utils.showPopupDialog(
                                    forcePopup: true,
                                    isFlexibleHeightPopup: true,
                                    size: Size(320, 0),
                                    child: MailActionConfirmPopup(
                                      title: context.tr.mail_discard_drafts,
                                      description: context.tr.mail_discard_drafts_description,
                                      onPressOk: () => MailAction.deleteAll(labelId: CommonMailLabels.draft.id, tabType: tabType),
                                    ),
                                  );
                                }
                              },
                              child: Row(
                                children: [
                                  VisirIcon(type: VisirIconType.trash, color: context.onPrimary, size: 16),
                                  SizedBox(width: 6),
                                  Text(context.tr.mail_discard_drafts, style: context.labelLarge?.textColor(context.onPrimary).appFont(context)),
                                ],
                              ),
                            ),
                          SizedBox(width: 6),
                        ],
                  pageDetailsAppBar: DetailsAppBarSize.small,
                  autoImplyLeading: false,
                  onLoading: loadMore,
                  onRefresh: showMobileUI
                      ? () async {
                          await refresh();
                          logAnalyticsEvent(eventName: 'refresh', properties: {'tab': tabType.name});
                        }
                      : null,

                  items: [
                    MasterItem(
                      'multiple_select',
                      'multiple_select',
                      onTap: () {},
                      customWidget: (selected) {
                        return SizedBox.shrink();
                      },

                      detailsBuilder: (context, isSmall, onClose) {
                        Widget Function({required VisirIconType icon, required String title, required VoidCallback onTap}) buildActionButton =
                            ({required VisirIconType icon, required String title, required VoidCallback onTap}) {
                              return IntrinsicWidth(
                                child: VisirButton(
                                  type: VisirButtonAnimationType.scaleAndOpacity,
                                  style: VisirButtonStyle(
                                    cursor: SystemMouseCursors.click,
                                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                    backgroundColor: context.surface,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  onTap: onTap,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      VisirIcon(type: icon, color: context.onSurface, size: 16),
                                      SizedBox(width: 10),
                                      Text(title, style: context.titleSmall?.textColor(context.outlineVariant)),
                                    ],
                                  ),
                                ),
                              );
                            };

                        return Container(
                          child: Center(
                            child: selectedItemIds.isEmpty
                                ? Text(context.tr.mail_no_email_selected, style: context.titleMedium?.textColor(context.surfaceTint))
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          VisirIcon(type: VisirIconType.mail, size: 22, color: context.onBackground),
                                          SizedBox(width: 12),
                                          Text(
                                            context.tr.n_selected(selectedItemIds.length),
                                            style: context.titleLarge?.textBold.textColor(context.onBackground),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 24),
                                      Wrap(
                                        alignment: WrapAlignment.center,
                                        runAlignment: WrapAlignment.center,
                                        runSpacing: 10,
                                        spacing: 10,
                                        children: [
                                          if (labelId != CommonMailLabels.sent.id &&
                                              mails.where((e) => selectedItemIds.contains(e.id) && e.isUnread).isNotEmpty)
                                            buildActionButton(
                                              icon: VisirIconType.show,
                                              title: context.tr.mail_detail_tooltip_mark_as_read,
                                              onTap: () async {
                                                final targetMails = mails.where((e) => selectedItemIds.contains(e.id) && e.isUnread).toList();
                                                MailAction.read(mails: targetMails.map((e) => e.threads ?? [e]).expand((e) => e).toList(), tabType: tabType);
                                              },
                                            ),
                                          if (labelId != CommonMailLabels.pinned.id &&
                                              mails.where((e) => selectedItemIds.contains(e.id) && !e.isPinned).isNotEmpty)
                                            buildActionButton(
                                              icon: VisirIconType.pin,
                                              title: context.tr.mail_detail_tooltip_pin,
                                              onTap: () {
                                                final targetMails = mails.where((e) => selectedItemIds.contains(e.id) && !e.isPinned).toList();
                                                MailAction.pin(mails: targetMails, tabType: tabType);
                                              },
                                            ),
                                          if (labelId != CommonMailLabels.archive.id &&
                                              mails.where((e) => selectedItemIds.contains(e.id) && !e.isArchive).isNotEmpty)
                                            buildActionButton(
                                              icon: VisirIconType.archive,
                                              title: context.tr.mail_detail_tooltip_archive,
                                              onTap: () {
                                                final targetMails = mails.where((e) => selectedItemIds.contains(e.id) && !e.isArchive).toList();
                                                MailAction.archive(mails: targetMails.map((e) => e.threads ?? [e]).expand((e) => e).toList(), tabType: tabType);
                                                resetSelectedItemIds();
                                                closeDetails();
                                              },
                                            ),
                                          if (labelId != CommonMailLabels.trash.id &&
                                              mails.where((e) => selectedItemIds.contains(e.id) && !e.isTrash).isNotEmpty)
                                            buildActionButton(
                                              icon: VisirIconType.trash,
                                              title: context.tr.mail_detail_tooltip_delete,
                                              onTap: () {
                                                final targetMails = mails.where((e) => selectedItemIds.contains(e.id) && !e.isTrash).toList();
                                                MailAction.trash(mails: targetMails.map((e) => e.threads ?? [e]).expand((e) => e).toList(), tabType: tabType);
                                                resetSelectedItemIds();
                                                closeDetails();
                                              },
                                            ),
                                          if (labelId != CommonMailLabels.spam.id && mails.where((e) => selectedItemIds.contains(e.id) && !e.isSpam).isNotEmpty)
                                            buildActionButton(
                                              icon: VisirIconType.spam,
                                              title: context.tr.mail_detail_tooltip_report_spam,
                                              onTap: () {
                                                final targetMails = mails.where((e) => selectedItemIds.contains(e.id) && !e.isSpam).toList();
                                                MailAction.spam(mails: targetMails.map((e) => e.threads ?? [e]).expand((e) => e).toList(), tabType: tabType);
                                                resetSelectedItemIds();
                                                closeDetails();
                                              },
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                          ),
                        );
                      },
                    ),
                    ...mails.mapIndexed((index, e) {
                      String subject = e.subject ?? '';
                      String snippet = e.snippet ?? '';

                      final targetMails = selectedItemIds.contains(e.id!) ? mails.where((e) => selectedItemIds.contains(e.id)).toList() : [e];

                      return MasterItem(
                        e.id!,
                        subject,
                        onTap: () {},
                        customWidget: (itemSelected) {
                          final selected = selectedItemIds.isEmpty ? itemSelected : selectedItemIds.contains(e.id);
                          final child = VisirListItem(
                            isSelected: PlatformX.isMobileView ? selectedItemIds.contains(e.id) : selected,
                            addTopMargin: index == 0,
                            sectionBuilder: (height, style, verticalPadding, horizontalPadding) {
                              return TextSpan(
                                children: [
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: Container(
                                      width: 4,
                                      height: height,
                                      margin: EdgeInsets.only(right: horizontalPadding),
                                      decoration: BoxDecoration(
                                        color: mailColors[e.hostEmail] != null ? ColorX.fromHex(mailColors[e.hostEmail]!) : Colors.transparent,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                  if (e.isPinned)
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: Padding(
                                        padding: EdgeInsets.only(right: horizontalPadding),
                                        child: VisirIcon(type: VisirIconType.pin, color: context.primary, size: height, isSelected: true),
                                      ),
                                    ),
                                  TextSpan(
                                    text: labelId == CommonMailLabels.draft.id
                                        ? (e.to.map((e) => e.name ?? e.email).join(', ')).isEmpty
                                              ? '(${context.tr.mail_no_recepients})'
                                              : e.to.map((e) => e.name ?? e.email).join(', ')
                                        : labelId == CommonMailLabels.sent.id
                                        ? 'To: ${e.to.map((e) => e.name ?? e.email).join(', ')}'
                                        : e.threadFrom.isEmpty
                                        ? (e.from?.name ?? e.from?.email ?? '')
                                        : e.threadFrom
                                              .map((f) => f.email == e.hostEmail ? context.tr.mail_me : f.name ?? f.email)
                                              .toList()
                                              .unique((e) => e)
                                              .join(', '),
                                  ),
                                ],
                              );
                            },
                            sectionTrailingBuilder: (height, style, verticalPadding, horizontalPadding) {
                              return TextSpan(
                                children: [
                                  if (e.isUnread)
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: Container(
                                        margin: EdgeInsets.only(right: horizontalPadding),
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(color: context.primary, borderRadius: BorderRadius.circular(3)),
                                      ),
                                    ),
                                  if (e.threadCount > 1)
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: Padding(
                                        padding: EdgeInsets.only(right: horizontalPadding),
                                        child: VisirBadge(style: style!, text: e.threadCount.toString(), horizontalPadding: horizontalPadding),
                                      ),
                                    ),
                                  TextSpan(text: (e.getDateString(context) ?? ''), style: style),
                                ],
                              );
                            },
                            titleBuilder: (height, style, verticalPadding, horizontalPadding) {
                              return TextSpan(
                                text: subject.isEmpty ? '(${context.tr.mail_no_subject})' : subject,
                                style: style?.textColor(e.isUnread || labelId == CommonMailLabels.draft.id ? context.onSurface : context.inverseSurface),
                              );
                            },
                            detailsBuilder: (height, style, verticalPadding, horizontalPadding) {
                              return Text(
                                snippet.isEmpty ? '(${context.tr.mail_no_content})' : snippet,
                                style: style?.textColor(isDarkMode ? (selected ? context.shadow : context.inverseSurface) : context.inverseSurface),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              );
                            },
                            onTap: () {
                              if (e.isDraft) {
                                MailAction.openDraft(mail: e);
                                return;
                              }
                              if (e.id == null) return;
                              if (controlPressed) {
                                addToSelectedItemIds([e.id!]);
                              } else if (shiftPressed) {
                                final currentIndex = mails.indexWhere((m) => e.id == m.id);
                                final lastPressedIndex = mails.indexWhere((m) => m.id == (selectedItemIds.firstOrNull ?? selectedItemId));
                                List<MailEntity> selectedMails = mails.sublist(min(currentIndex, lastPressedIndex), max(currentIndex, lastPressedIndex) + 1);
                                if (currentIndex > lastPressedIndex) selectedMails = selectedMails.reversed.toList();
                                addToSelectedItemIds(selectedMails.map((e) => e.id).whereType<String>().toList());
                              } else {
                                resetSelectedItemIds();
                                openDetails(id: e.id!);
                              }
                            },
                            onTapDown: selectedItemIds.contains(e.id)
                                ? (details) => multiFingerGestureController.notifyTapDownFromWidgetListeners(selectedItemIds)
                                : null,
                            onTapUp: selectedItemIds.contains(e.id)
                                ? (details) => multiFingerGestureController.notifyTapUpFromWidgetListeners(selectedItemIds)
                                : null,
                            onTapCancel: selectedItemIds.contains(e.id)
                                ? () => multiFingerGestureController.notifyTapUpFromWidgetListeners(selectedItemIds)
                                : null,
                            onTwoFingerDragSelect: () {
                              addToSelectedItemIds([e.id!]);
                            },
                            onTwoFingerDragDisselect: () {
                              removeFromSelectedItemIds([e.id!]);
                            },
                            multiFingerGestureController: multiFingerGestureController,
                          );

                          return Column(
                            children: [
                              SwipeActionCell(
                                isDraggable: showMobileUI,
                                editModeOffset: 40,
                                key: ObjectKey(e.id),
                                backgroundColor: Colors.transparent,
                                leadingActions: [
                                  SwipeAction(
                                    performsFirstActionWithFullSwipe: true,
                                    icon: Container(
                                      width: 24,
                                      height: 24,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: context.surface),
                                      child: VisirIcon(type: VisirIconType.more, size: 16, color: context.onSurface),
                                    ),
                                    widthSpace: 100,
                                    onTap: (CompletionHandler handler) {
                                      showMailOptionsBottomDialog(mail: e, mails: mails, context: context);
                                      handler(false);
                                    },
                                    color: Colors.transparent,
                                  ),
                                ],
                                trailingActions: swipeActions(mail: e, type: mailSwipeLeftActionType),
                                child: PlatformX.isDesktopView
                                    ? ContextMenuWidget(
                                        menuProvider: (request) {
                                          return Menu(
                                            children: [
                                              ...rightClickOptions(targetMails)
                                                  .map((e) {
                                                    return [
                                                      MenuAction(
                                                        title: e.getTitle(context, targetMails, labelId),
                                                        image: MenuImage.icon(e.getMenuIcon(targetMails)),
                                                        attributes: MenuActionAttributes(destructive: e.isDistructive(targetMails)),
                                                        callback: () => getMailAction(mails: targetMails, type: e, position: request.location),
                                                      ),
                                                      if (e == MailRightClickOptionType.forward) MenuSeparator(),
                                                    ];
                                                  })
                                                  .toList()
                                                  .expand((e) => e),
                                            ],
                                          );
                                        },
                                        child: buildDraggable(child: child, mail: e),
                                      )
                                    : buildDraggable(child: child, mail: e),
                              ),
                            ],
                          );
                        },
                        detailsBuilder: (context, isSmall, onClose) {
                          return labelId == CommonMailLabels.draft.id
                              ? const SizedBox.shrink()
                              : MailDetailScreen(
                                  tabType: tabType,
                                  key: ValueKey(e.id!),
                                  threads: e.threads ?? [e],
                                  anchorMailId: e.id!,
                                  close: closeDetails,
                                  onClose: onClose,
                                  onKeyDown: (event) => _onKeyDown(event, justReturnResult: true),
                                  onKeyRepeat: (event) => _onKeyRepeat(event, justReturnResult: true),
                                );
                        },
                      );
                    }).toList(),
                  ],
                  nothingSelectedWidget: Text(context.tr.mail_no_email_selected, style: context.titleMedium?.textColor(context.surfaceTint)),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
