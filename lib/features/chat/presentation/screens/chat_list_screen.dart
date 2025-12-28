import 'dart:async';
import 'dart:math';

import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/master_detail_flow/src/details_item.dart';
import 'package:Visir/dependency/master_detail_flow/src/enums.dart';
import 'package:Visir/dependency/master_detail_flow/src/master_item.dart';
import 'package:Visir/dependency/master_detail_flow/src/widget.dart';
import 'package:Visir/dependency/modal_bottom_sheet/src/utils/modal_scroll_controller.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/chat/application/chat_channel_list_controller.dart';
import 'package:Visir/features/chat/application/chat_draft_controller.dart';
import 'package:Visir/features/chat/application/chat_emoji_list_controller.dart';
import 'package:Visir/features/chat/application/chat_file_list_controller.dart';
import 'package:Visir/features/chat/application/chat_group_list_controller.dart';
import 'package:Visir/features/chat/application/chat_list_controller.dart';
import 'package:Visir/features/chat/application/chat_member_list_controller.dart';
import 'package:Visir/features/chat/domain/entities/message_channel_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_emoji_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_group_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_member_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_tag_entity.dart';
import 'package:Visir/features/chat/domain/entities/state/chat_fetch_result_entity.dart';
import 'package:Visir/features/chat/presentation/screens/chat_thread_screen.dart';
import 'package:Visir/features/chat/presentation/widgets/chat_input/message_input_field.dart';
import 'package:Visir/features/chat/presentation/widgets/chat_widget/message_widget.dart';
import 'package:Visir/features/chat/presentation/widgets/new_message_widget.dart';
import 'package:Visir/features/chat/providers.dart';
import 'package:Visir/features/chat/utils.dart';
import 'package:Visir/features/common/domain/entities/linked_item_entity.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/log_event.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/custom_circualr_loading_indicator.dart';
import 'package:Visir/features/common/presentation/widgets/fgbg_detector.dart';
import 'package:Visir/features/common/presentation/widgets/fixed_overlay_host.dart';
import 'package:Visir/features/common/presentation/widgets/keyboard_shortcut.dart';
import 'package:Visir/features/common/presentation/widgets/mobile_scaffold.dart';
import 'package:Visir/features/common/presentation/widgets/visir_app_bar.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_config_entity.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:Visir/features/time_saved/actions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image_platform_interface/cached_network_image_platform_interface.dart' show ImageRenderMethodForWeb;
import 'package:collection/collection.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_delta_from_html/parser/html_to_delta.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  final OAuthType? oAuthType;
  final Future<void> Function({required String channelId})? moveToChannel;
  final bool Function(KeyEvent event)? onKeyDown;
  final bool Function(KeyEvent event)? onKeyRepeat;

  final LinkedMessageEntity? taskMessage;
  final List<String>? taskMessageGroupIds;
  final TabType tabType;
  final VoidCallback? deleteTask;
  final InboxConfigEntity? inboxConfig;
  final bool? isFromMobileTaskEdit;
  final VoidCallback close;
  final VoidCallback? onClose;
  final VoidCallback? onControl;

  final Color? backgroundColor;

  final void Function(MessageEntity chat)? onDragStart;
  final void Function(MessageEntity chat, Offset offset)? onDragUpdate;
  final void Function(MessageEntity chat)? onDragEnd;

  const ChatListScreen({
    super.key,
    this.onControl,
    this.oAuthType,
    this.moveToChannel,
    this.taskMessage,
    this.taskMessageGroupIds,
    required this.tabType,
    required this.close,
    this.onKeyDown,
    this.onKeyRepeat,
    this.deleteTask,
    this.inboxConfig,
    this.isFromMobileTaskEdit,
    this.onClose,
    this.backgroundColor,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => ChatListScreenState();
}

class ChatListScreenState extends ConsumerState<ChatListScreen> {
  Timer? resizeTimer;

  ValueNotifier<double> inputAreaHeightNotifier = ValueNotifier(0);
  ValueNotifier<String> currentTagIdNotifier = ValueNotifier('');
  ValueNotifier<bool> isCurrentNotifier = ValueNotifier(true);

  ScrollController? scrollController;
  ListController listController = ListController();
  ScrollController tagListScrollController = ScrollController();
  RefreshController refreshController = RefreshController(initialRefresh: false);

  late CustomTagController messageController;

  final FocusNode messageFocusNode = FocusNode();
  final List<MessageTagEntity> tagList = [];

  String tagSearchWord = '';

  GlobalKey inputAreaKey = GlobalKey();
  GlobalKey<MessageInputFieldState> messageInputFieldKey = GlobalKey<MessageInputFieldState>();
  GlobalKey<MasterDetailsFlowState> masterDetailsKey = GlobalKey<MasterDetailsFlowState>();
  GlobalKey<ChatThreadScreenState> chatThreadScreenKey = GlobalKey<ChatThreadScreenState>();

  bool get isReplyListOpened => masterDetailsKey.currentState?.selectedItem != null;

  bool get isMobileView => PlatformX.isMobileView;
  bool get isDarkMode => context.isDarkMode;

  bool get isFromInbox => widget.tabType != TabType.chat;

  double get inputAreaDefaultHeight => 62;

  TabType get tabType => widget.tabType;

  bool hasUnreadAtFirst = false;

  ValueNotifier<bool> showLoadingNotifier = ValueNotifier(false);

  GlobalKey sendButtonKey = GlobalKey();
  OverlayEntry? newMessageIndicatorOverlayEntry;

  String get overlayKey => '${widget.tabType.name}-message';

  MessageChannelEntity get _channel {
    final channelId = ref.read(chatConditionProvider(tabType)).channel?.id;
    return channels.firstWhereOrNull((e) => e.id == channelId) ?? ref.read(chatConditionProvider(tabType)).channel!;
  }

  String get teamId => ref.read(chatConditionProvider(widget.tabType).select((v) => v.channel!.teamId));
  List<MessageChannelEntity> get channels => ref.read(chatChannelListControllerProvider.select((v) => v[teamId]?.channels ?? []));
  List<MessageMemberEntity> get members => ref.read(chatMemberListControllerProvider(tabType: tabType).select((v) => v.members));
  List<MessageGroupEntity> get groups => ref.read(chatGroupListControllerProvider(tabType: tabType).select((v) => v.groups));
  List<MessageEmojiEntity> get emojis => ref.read(chatEmojiListControllerProvider(tabType: tabType).select((v) => v.emojis));

  late MessageChannelEntity initialChannel;

  String get selectedMessageId => MessageWidget.selectedMessageIdNotifier.value;
  set selectedMessageId(String value) {
    if (MessageWidget.selectedMessageIdNotifier.value == value) return;
    MessageWidget.selectedMessageIdNotifier.value = value;
  }

  void showLoadingOnMobile() {
    showLoadingNotifier.value = PlatformX.isMobileView;
  }

  void hideLoadingOnMobile() {
    showLoadingNotifier.value = false;
  }

  @override
  void initState() {
    super.initState();

    initialChannel = _channel;
    hasUnreadAtFirst = _channel.hasUnreadMessage;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      inputAreaHeightNotifier.value = inputAreaDefaultHeight;
      UserActionSwtichAction.onOpenMessageChannel();
    });

    messageFocusNode.addListener(() => setState(() {}));
    isCurrentNotifier.addListener(() {
      if (isCurrentNotifier.value) {
        currentTagIdNotifier.value = '';
      }
    });

    messageController = CustomTagController(channels: channels, channel: _channel);
    if (PlatformX.isMobileView) {
      messageController.skipRequestKeyboard = PlatformX.isMobileView;
    }
    messageController.addListener(onTextChanged);

    if (widget.taskMessage != null) {
      notificationPayload = {
        'isHome': 'true',
        'type': widget.taskMessage!.type.name,
        'channelId': widget.taskMessage!.channelId,
        'messageId': widget.taskMessage!.messageId,
        'threadId': widget.taskMessage!.threadId,
      };
    }

    refreshTagSearchResult();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showLoadingOnMobile();
    });

    if (!isFromInbox) {
      final user = ref.read(authControllerProvider).requireValue;
      logAnalyticsEvent(
        eventName: _channel.isChannel
            ? user.onTrial
                  ? 'trial_chat_channel'
                  : 'chat_channel'
            : 'chat_dm',
      );
    }
    if (isFromInbox && widget.inboxConfig != null) logAnalyticsEvent(eventName: 'inbox_slack');

    isShowcaseOn.addListener(onShowcaseOnListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onShowcaseOnListener();
    });
  }

  void scrollListener() {
    if (scrollController == null) return;
    if (scrollController!.position.pixels < -40 && isFromInbox) {
      EasyThrottle.throttle('message_load_recent', Duration(seconds: 1), () {
        refreshController.requestRefresh(duration: Duration(milliseconds: 250), curve: Curves.easeInOut);
      });
    }

    if (scrollController!.offset < 10) {
      hideNewMessageIndicator();
    }
  }

  void onShowcaseOnListener() {
    if (isShowcaseOn.value == chatCreateTaskShowcaseKeyString) {
      if (_channel.id == targetChatChannelId) {
        if (PlatformX.isMobileView) return;
        selectedMessageId = targetChatMessageId;
        scrollController?.jumpTo(0);
      }
      return;
    }
  }

  @override
  void dispose() {
    ref.read(chatConditionProvider(tabType).notifier).clear();

    scrollController?.removeListener(scrollListener);
    scrollController?.dispose();
    isShowcaseOn.removeListener(onShowcaseOnListener);

    newMessageIndicatorOverlayEntry?.remove();
    newMessageIndicatorOverlayEntry?.dispose();
    newMessageIndicatorOverlayEntry = null;

    messageFocusNode.unfocus();
    messageFocusNode.dispose();
    widget.onClose?.call();
    messageController.removeListener(onTextChanged);
    inputAreaHeightNotifier.dispose();

    currentTagIdNotifier.dispose();
    isCurrentNotifier.dispose();
    messageController.dispose();
    listController.dispose();
    resizeTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(ChatListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final taskMessageId = widget.taskMessage?.messageId;
    final oldMessageId = oldWidget.taskMessage?.messageId;

    final taskThreadId = widget.taskMessage?.threadId;
    final oldThreadId = oldWidget.taskMessage?.threadId;

    if (taskMessageId != oldMessageId) {
      if (taskThreadId != oldThreadId && oldThreadId != null) {
        closeDetails();
        Future.delayed(Duration(milliseconds: 500), () {
          if (!mounted) return;
          notificationPayload = {
            'isHome': 'true',
            'type': widget.taskMessage!.type.name,
            'channelId': widget.taskMessage!.channelId,
            'messageId': widget.taskMessage!.messageId,
            'threadId': widget.taskMessage!.threadId,
          };
          checkPayloadThenAction();
          setState(() {});
        });
      } else {
        notificationPayload = {
          'isHome': 'true',
          'type': widget.taskMessage!.type.name,
          'channelId': widget.taskMessage!.channelId,
          'messageId': widget.taskMessage!.messageId,
          'threadId': widget.taskMessage!.threadId,
        };
        checkPayloadThenAction();
      }
    }
  }

  int newMessageCount = 0;
  void showNewMessageIndicator() {
    if (isShowcaseOn.value != null) return;
    final inputAreaStack = inputAreaKey.currentContext?.findRenderObject() as RenderBox?;
    if (inputAreaStack == null) return;

    final prevEntry = newMessageIndicatorOverlayEntry;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (scrollController == null) return;
      if (!scrollController!.hasClients) return;
      if (scrollController!.offset < 10) return;

      final inputAreaStackPosition = inputAreaStack.localToGlobal(Offset.zero);
      final stackOffset = FixedOverlayHost.getStackOffset(overlayKey);
      newMessageCount++;

      newMessageIndicatorOverlayEntry = OverlayEntry(
        builder: (BuildContext context) {
          return Padding(
            padding: EdgeInsets.only(top: inputAreaStackPosition.dy - (stackOffset?.dy ?? 0) - 38),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [NewMessageWidget(scrollController: scrollController, isReverse: true, count: newMessageCount)],
            ),
          );
        },
      );

      FixedOverlayHost.insert(overlayKey, 'newMessageIndicator', newMessageIndicatorOverlayEntry!);

      if (prevEntry != null) {
        prevEntry.remove();
        prevEntry.dispose();
      }
    });
  }

  void hideNewMessageIndicator() {
    if (newMessageIndicatorOverlayEntry?.mounted != true) return;
    newMessageIndicatorOverlayEntry?.remove();
    newMessageIndicatorOverlayEntry?.dispose();
    newMessageIndicatorOverlayEntry = null;
    newMessageCount = 0;
  }

  Offset? caretOffset;
  void onTextChanged() {
    if (PlatformX.isMobileView && !messageFocusNode.hasFocus) {
      messageController.skipRequestKeyboard = true;
    }
    final value = messageController.text.trimRight();

    refreshTagSearchResult();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (value.isEmpty) {
        messageController.tagListVisible = false;
      } else if (((value.length == 1 || messageController.selection.start == 1) && value[0] == '@' && (value.length < 2 || value[1] == ' '))) {
        caretOffset = messageInputFieldKey.currentState?.getCaretOffset();
        messageController.tagListVisible = true;
      } else if ((value.length > 1 &&
          messageController.selection.start > 1 &&
          value.length >= messageController.selection.start &&
          (value.substring(messageController.selection.start - 2, messageController.selection.start) == ' @' ||
              value.substring(messageController.selection.start - 2, messageController.selection.start) == '\n@'))) {
        caretOffset = messageInputFieldKey.currentState?.getCaretOffset();
        messageController.tagListVisible = true;
      }

      setState(() {});
    });
  }

  Future<void> refreshTagSearchResult() async {
    tagList.clear();

    final broadcastChannelTag = MessageTagEntity(type: MessageTagEntityType.broadcastChannel);
    final broadcastHereTag = MessageTagEntity(type: MessageTagEntityType.broadcastHere);

    if (messageController.value.selection.end > 1) {
      int? searchFromIndex = messageController.text.substring(0, messageController.value.selection.end).lastIndexOf('@') + 1;
      if (searchFromIndex >= 0) {
        tagSearchWord = messageController.text.substring(searchFromIndex, messageController.value.selection.end);
      } else {
        tagSearchWord = '';
      }
    } else {
      tagSearchWord = '';
    }

    final pref = ref.read(localPrefControllerProvider).value;
    if (pref == null) return;

    final matchedMembersContain = ref
        .read(chatChannelListControllerProvider.select((v) => v[teamId]?.members ?? []))
        .where((e) => (e.displayName?.toLowerCase().startsWith(tagSearchWord.toLowerCase()) ?? false))
        .toList();

    final matchedMemberGroupsContain = ref
        .read(chatChannelListControllerProvider.select((v) => v[teamId]?.groups ?? []))
        .where((e) => (e.displayName?.toLowerCase().startsWith(tagSearchWord.toLowerCase()) ?? false))
        .toList();

    final matchedChannelsContain = channels.where((e) => (e.name?.toLowerCase().startsWith(tagSearchWord.toLowerCase()) ?? false)).toList();

    if (_channel.isChannel) {
      if (broadcastChannelTag.id?.toLowerCase().startsWith(tagSearchWord.toLowerCase()) ?? false) {
        tagList.add(broadcastChannelTag);
      }
      if (broadcastHereTag.id?.toLowerCase().startsWith(tagSearchWord.toLowerCase()) ?? false) {
        tagList.add(broadcastHereTag);
      }
    }

    matchedMembersContain.forEach((e) {
      if (tagList.firstWhereOrNull((t) => t.id == e.id && t.type == MessageTagEntityType.member) == null) {
        tagList.add(MessageTagEntity(type: MessageTagEntityType.member, member: e));
      }
    });
    matchedMemberGroupsContain.forEach((e) {
      if (tagList.firstWhereOrNull((t) => t.id == e.id && t.type == MessageTagEntityType.memberGroup) == null) {
        tagList.add(MessageTagEntity(type: MessageTagEntityType.memberGroup, memberGroup: e));
      }
    });
    matchedChannelsContain.forEach((e) {
      if (tagList.firstWhereOrNull((t) => t.id == e.id && t.type == MessageTagEntityType.channel) == null) {
        tagList.add(MessageTagEntity(type: MessageTagEntityType.channel, channel: e));
      }
    });

    tagList.sort((a, b) {
      final aStartsWith = a.displayName?.toLowerCase().startsWith(tagSearchWord.toLowerCase()) ?? false;
      final bStartsWith = b.displayName?.toLowerCase().startsWith(tagSearchWord.toLowerCase()) ?? false;
      if (aStartsWith && !bStartsWith) return -1;
      if (!aStartsWith && bStartsWith) return 1;
      return 0;
    });

    currentTagIdNotifier.value = tagList.firstOrNull?.id ?? '';
  }

  void highlightPreviousTag() {
    int index = tagList.indexWhere((e) => e.id == currentTagIdNotifier.value);
    if (index > -1) {
      int previousIndex = index == 0 ? tagList.length - 1 : index - 1;
      currentTagIdNotifier.value = tagList[previousIndex].id ?? '';

      final tagWidgetKey = tagList[previousIndex].globalObjectKey;
      if (tagWidgetKey.currentContext?.findRenderObject() != null) {
        tagListScrollController.position.ensureVisible(
          tagWidgetKey.currentContext!.findRenderObject()!,
          duration: const Duration(milliseconds: 200),
          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtStart,
        );
      } else if (previousIndex == tagList.length - 1) {
        tagListScrollController.jumpTo(tagListScrollController.position.maxScrollExtent);
      }
    }
  }

  void highlightNextTag() {
    int index = tagList.indexWhere((e) => e.id == currentTagIdNotifier.value);
    if (index > -1) {
      int nextIndex = index == tagList.length - 1 ? 0 : index + 1;
      currentTagIdNotifier.value = tagList[nextIndex].id ?? '';

      final tagWidgetKey = tagList[nextIndex].globalObjectKey;
      if (tagWidgetKey.currentContext?.findRenderObject() != null) {
        tagListScrollController.position.ensureVisible(
          tagWidgetKey.currentContext!.findRenderObject()!,
          duration: const Duration(milliseconds: 200),
          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
        );
      } else if (nextIndex == 0) {
        tagListScrollController.jumpTo(0.0);
      }
    }
  }

  void enterTag() {
    int index = tagList.indexWhere((e) => e.id == currentTagIdNotifier.value);
    final tag = tagList[index];
    String tagString = '\u200b${tag.type == MessageTagEntityType.channel ? '#' : '@'}${tag.displayName}\u200b ';
    final lastIndex = messageController.text.substring(0, messageController.value.selection.end).lastIndexOf('@');
    messageController.text = (messageController.text).replaceRange(lastIndex, messageController.value.selection.end, tagString);
    messageInputFieldKey.currentState?.requestFocus();
    messageController.updateSelection(TextSelection.collapsed(offset: lastIndex + tagString.length), ChangeSource.local);
    messageController.tagListVisible = false;

    switch (tag.type) {
      case MessageTagEntityType.member:
        messageController.addTaggedData(member: tag.member);
        break;
      case MessageTagEntityType.memberGroup:
        messageController.addTaggedData(group: tag.memberGroup);
        break;
      case MessageTagEntityType.channel:
        messageController.addTaggedData(channel: tag.channel);
        break;
      case MessageTagEntityType.broadcastChannel:
      case MessageTagEntityType.broadcastHere:
      case MessageTagEntityType.task:
      case MessageTagEntityType.event:
      case MessageTagEntityType.connection:
      case MessageTagEntityType.project:
        break;
    }

    setState(() {});
  }

  void updateChannelLocally(ChatFetchResultEntity? result) {
    if (result == null) return;
    ref.read(chatChannelListControllerProvider.notifier).updateChannelLocally(teamId: _channel.teamId, channel: result.channel);
    if (!mounted) return;
    messageController.setChannel(_channel);
    setState(() {});
  }

  void openDetails({required String threadId, bool? forceOpen}) {
    String? prevThreadId = ref.read(chatConditionProvider(widget.tabType)).threadId;
    if (forceOpen != true && prevThreadId == threadId && masterDetailsKey.currentState?.isDetailOpened == true) return;
    ref.read(chatConditionProvider(widget.tabType).notifier).setThread(threadId);
    masterDetailsKey.currentState?.openDetails(id: threadId);
  }

  void closeDetails() {
    // Utils.ref.read(resizableClosableWidgetProvider(widget.tabType).notifier).setWidget(null);
    masterDetailsKey.currentState?.closeDetails();
  }

  void checkPayloadThenAction() {
    final payload = notificationPayload;
    if (payload == null) return;
    if ((payload['isHome'] != null) == (tabType == TabType.chat)) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      switch (payload['type']) {
        case 'slack':
          final channelId = payload['channelId'];
          final messageId = payload['messageId'];
          final threadId = payload['threadId'];

          if (_channel.id != channelId) return;
          if (messageId == null) return;
          if (channelId == null) return;

          if (threadId == null) {
            closeDetails();
          }

          if (threadId?.isNotEmpty != true || messageId == threadId) {
            final messageData = ref.read(chatListControllerProvider(tabType: tabType).select((v) => v?.messages ?? []));
            final messages = messageData.where((e) => e.id != null).toList();
            final index = messages.indexWhere((e) => e.id == messageId);
            if (index < 0) {
              if (ref.read(loadingStatusProvider.select((v) => v[ChatListController.stringKey(tabType)])) != LoadingState.loading) {
                ref.read(chatListControllerProvider(tabType: tabType).notifier).loadRecent().then((_) {
                  checkPayloadThenAction();
                });
              }
              return;
            }
            if (mounted && index > 0) {
              Future.delayed(Duration(milliseconds: 1000), () {
                if (!mounted) return;
                if (scrollController == null) return;
                if (!listController.isAttached) return;
                listController.animateToItem(
                  index: index,
                  scrollController: scrollController!,
                  alignment: 0.5,
                  duration: (distance) => Duration(milliseconds: 100),
                  curve: (distance) => Curves.easeInOut,
                );
              });
            }

            notificationPayload = null;
            return;
          } else {
            final messageData = ref.read(chatListControllerProvider(tabType: tabType).select((v) => v?.messages ?? []));
            final messages = messageData.where((e) => e.id != null).toList();
            final index = messages.indexWhere((e) => e.id == threadId);
            if (index < 0) {
              if (ref.read(loadingStatusProvider.select((v) => v[ChatListController.stringKey(tabType)])) != LoadingState.loading) {
                ref.read(chatListControllerProvider(tabType: tabType).notifier).loadRecent().then((_) {
                  checkPayloadThenAction();
                });
              }
              return;
            }

            if (mounted && index > 0) {
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

              Future.delayed(Duration(milliseconds: 1000), () {
                if (!mounted) return;
                openDetails(threadId: threadId!);
              });
            }
          }

          break;
      }
    });
  }

  bool _onKeyRepeat(KeyEvent event, {bool? justReturnResult}) {
    final result = widget.onKeyRepeat?.call(event);
    if (result == true) return true;
    return handleKey(event);
  }

  bool _onKeyDown(KeyEvent event, {bool? justReturnResult}) {
    final result = widget.onKeyDown?.call(event);
    if (result == true) return true;
    return handleKey(event);
  }

  bool handleKey(KeyEvent event) {
    if (masterDetailsKey.currentState?.isDetailOpened == true) return false;

    final logicalKeyPressed = ServicesBinding.instance.keyboard.logicalKeysPressed.where((e) => e != LogicalKeyboardKey.escape).toList();

    if (logicalKeyPressed.length <= 2) {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        final messageData = ref.watch(chatListControllerProvider(tabType: tabType).select((v) => v?.messages ?? []));
        final messages = messageData.where((e) => e.id != null && members.any((m) => m.id == e.userId)).toList();

        if (selectedMessageId.isNotEmpty) {
          final messageIndex = messages.indexWhere((e) => e.id == selectedMessageId);
          final newMessageIndex = messageIndex + 1;
          if (messages.length > newMessageIndex) {
            selectedMessageId = messages[newMessageIndex].id ?? '';

            int? minVisible = listController.visibleRange?.$1;
            int? maxVisible = listController.visibleRange?.$2;
            if (minVisible != null && maxVisible != null) {
              if (newMessageIndex <= minVisible || newMessageIndex >= maxVisible) {
                if (scrollController == null) return false;
                listController.animateToItem(
                  index: newMessageIndex,
                  scrollController: scrollController!,
                  alignment: 1,
                  duration: (distance) => Duration(milliseconds: 200),
                  curve: (distance) => Curves.easeInOut,
                );
              }
            }

            return true;
          }
        }
      }

      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        final messageData = ref.watch(chatListControllerProvider(tabType: tabType).select((v) => v?.messages ?? []));
        final messages = messageData.where((e) => e.id != null && members.any((m) => m.id == e.userId)).toList();

        if (selectedMessageId.isNotEmpty) {
          final messageIndex = messages.indexWhere((e) => e.id == selectedMessageId);
          final newMessageIndex = messageIndex - 1;
          if (newMessageIndex > -1) {
            selectedMessageId = messages[newMessageIndex].id ?? '';

            int? minVisible = listController.visibleRange?.$1;
            int? maxVisible = listController.visibleRange?.$2;
            if (minVisible != null && maxVisible != null) {
              if (newMessageIndex <= minVisible || newMessageIndex >= maxVisible) {
                if (scrollController == null) return false;
                listController.animateToItem(
                  index: newMessageIndex,
                  scrollController: scrollController!,
                  alignment: 1,
                  duration: (distance) => Duration(milliseconds: 200),
                  curve: (distance) => Curves.easeInOut,
                );
              }
            }

            return true;
          }
        }
      }
    }

    if (logicalKeyPressed.length == 2) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown && (PlatformX.isApple ? logicalKeyPressed.isMetaPressed : logicalKeyPressed.isControlPressed)) {
        final messageData = ref.watch(chatListControllerProvider(tabType: tabType).select((v) => v?.messages ?? []));
        final messages = messageData.where((e) => e.id != null && members.any((m) => m.id == e.userId)).toList();
        if (selectedMessageId == messages.firstOrNull?.id) {
          selectedMessageId = '';
          messageInputFieldKey.currentState?.requestFocus();
          return true;
        }
      }
    }

    if (event.logicalKey == LogicalKeyboardKey.escape) {
      if (selectedMessageId.isNotEmpty) {
        selectedMessageId = '';
        return true;
      }
    }

    if (event.logicalKey == LogicalKeyboardKey.tab) {
      if (masterDetailsKey.currentState?.isDetailOpened == true) return false;
      messageInputFieldKey.currentState?.requestFocus();
      return true;
    }

    return false;
  }

  Widget skeletonWidget() {
    int count = 2;
    Widget cell = Container(
      height: 36,
      margin: EdgeInsets.only(bottom: 24, left: 16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: ShapeDecoration(
              color: context.surfaceVariant,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 16,
                decoration: ShapeDecoration(
                  color: context.surfaceVariant,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 104,
                height: 12,
                decoration: ShapeDecoration(
                  color: context.surfaceVariant,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return Column(children: List.generate(count, (index) => cell));
  }

  bool isLoadingMore = false;

  bool doEmptyTapAction({bool? checkTag}) {
    if (messageController.tagListVisible) {
      if (checkTag == true) {
        messageController.tagListVisible = false;
        setState(() {});
      }
      return true;
    }

    if (messageFocusNode.hasFocus) {
      messageFocusNode.unfocus();
      return true;
    }

    return false;
  }

  void clearMessage() {
    messageController.clear();
    ref.read(chatDraftControllerProvider(teamId: _channel.teamId, channelId: _channel.id).notifier).setDraft(null);
  }

  String prevThreadId = '';

  @override
  Widget build(BuildContext context) {
    if (scrollController == null) {
      scrollController ??= ModalScrollController.ofSyncGroup(context)?.addAndGet() ?? ScrollController();
      scrollController?.addListener(scrollListener);
    }
    final members = ref.watch(chatMemberListControllerProvider(tabType: tabType).select((v) => v.members));
    final groups = ref.watch(chatGroupListControllerProvider(tabType: tabType).select((v) => v.groups));
    final emojis = ref.watch(chatEmojiListControllerProvider(tabType: tabType).select((v) => v.emojis));

    ref.watch(chatChannelListControllerProvider);
    final messageData = ref.watch(chatListControllerProvider(tabType: tabType).select((v) => v));

    final messages = messageData?.messages.where((e) => e.id != null).toList() ?? [];
    final hasMore = messageData?.hasMore ?? false;
    final hasRecent = messageData?.hasRecent ?? false;

    isCurrentNotifier.value = ModalRoute.of(context)?.isCurrent ?? false;

    ref.listen(chatFileListControllerProvider(tabType: widget.tabType, isThread: false), ((previous, next) async {
      if (!mounted) return;
      final height = next.isNotEmpty == true ? inputAreaKey.currentContext?.size?.height ?? inputAreaDefaultHeight : inputAreaDefaultHeight;
      inputAreaHeightNotifier.value = height;
    }));

    ref.listen(chatListControllerProvider(tabType: tabType), (prev, next) {
      checkPayloadThenAction();

      if (next?.messages.isNotEmpty == true) {
        final result = next!;

        if (result.isRateLimited ?? false) {
          Utils.showRateLimitedToast(type: RateLimitType.slack);
          return;
        }

        final lastReadAt = result.messages.firstOrNull?.createdAt;
        if (lastReadAt == null) return;
        if (!mounted) return;
        ref.read(chatChannelListControllerProvider.notifier).setReadCursor(teamId: _channel.teamId, channelId: _channel.id, lastReadAt: lastReadAt);

        if (next.messages.firstOrNull?.isMyMessage(channel: _channel) != true && next.messages.firstOrNull?.id != prev?.messages.firstOrNull?.id) {
          showNewMessageIndicator();
        }
      }
    });

    ref.listen(localPrefControllerProvider, (previous, next) {
      if (previous?.value?.notificationPayload != next.value?.notificationPayload) {
        checkPayloadThenAction();
      }
    });

    Color backgroundColor = widget.backgroundColor ?? context.background;

    final resizableClosableDrawer = ref.watch(resizableClosableDrawerProvider(widget.tabType));

    if (scrollController == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: doEmptyTapAction,
      child: KeyboardShortcut(
        targetTab: widget.tabType,
        onKeyDown: _onKeyDown,
        onKeyRepeat: _onKeyRepeat,
        child: FGBGDetector(
          onChanged: (isForeground, isFirst) {
            if (!isForeground) return;
            checkPayloadThenAction();
          },
          child: ValueListenableBuilder(
            valueListenable: MobileScaffold.largeTabBar,
            builder: (context, largeTabBar, child) {
              final tabMargin = PlatformX.isMobileView
                  ? ModalScrollController.of(context) != null
                        ? max(context.padding.bottom - 8, 8.0)
                        : (largeTabBar ? MobileScaffold.bottomPaddingForLargeTabBar : MobileScaffold.bottomPaddingForSmallTabBar)
                  : 0.0;
              return ValueListenableBuilder<double>(
                valueListenable: inputAreaHeightNotifier,
                builder: (context, inputAreaHeightValue, _) {
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 250),
                    color: PlatformX.isMobileView ? context.background : null,
                    padding: PlatformX.isMobileView ? EdgeInsets.only(bottom: tabMargin) : EdgeInsets.zero,
                    child: DetailsItem(
                      removeDivider: true,
                      hideBackButton: true,
                      bodyColor: Colors.transparent,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Builder(
                              builder: (context) {
                                final leadingBeforeText = [
                                  if (PlatformX.isDesktopView && tabType != TabType.chat)
                                    VisirAppBarButton(icon: VisirIconType.close, onTap: widget.close).getButton(context: context)
                                  else if (Navigator.canPop(context))
                                    VisirAppBarButton(icon: VisirIconType.arrowLeft, onTap: widget.close).getButton(context: context),
                                  if (!Navigator.canPop(context) && resizableClosableDrawer == null)
                                    VisirAppBarButton(icon: VisirIconType.control, onTap: widget.onControl).getButton(context: context),
                                  // if (tabType == TabType.chat) VisirAppBarButton(icon: VisirIconType.search, onTap: () {}).getButton(context: context),
                                ];
                                return MasterDetailsFlow(
                                  onDetailsClosed: () {
                                    // ref.read(resizableClosableWidgetProvider(widget.tabType).notifier).setWidget(null);
                                  },
                                  disableOpenDetailsOnTap: !isMobileView,
                                  bodyWrapper: (child) => FixedOverlayHost(overlayKey: overlayKey, child: child),
                                  onTargetResized: (width) {},
                                  leadings: [
                                    SizedBox(width: 6),
                                    ...leadingBeforeText,
                                    if (leadingBeforeText.isNotEmpty) VisirAppBarButton(isDivider: true).getButton(context: context) else SizedBox(width: 4),
                                    Expanded(
                                      child: Container(
                                        padding: EdgeInsets.only(left: 6),
                                        child: Text(
                                          '${_channel.isDm ? '' : '#'} ${_channel.displayName}',
                                          style: context.titleLarge?.textColor(context.outlineVariant).textBold.appFont(context),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                  showAppBarDivider: isMobileView || isFromInbox,
                                  masterShowLoadingNotifier: showLoadingNotifier,
                                  isDetailExpanded: true,
                                  scrollController: scrollController!,
                                  scrollPhysics: Utils.getScrollPhysicsForBottomSheet(context, scrollController),
                                  listController: listController,
                                  key: masterDetailsKey,
                                  reverse: true,
                                  customVerticalPadding: 8,
                                  refreshController: refreshController,
                                  breakpoint: isFromInbox ? context.width.floor() + 10 : Constants.chatScreenBreakPoint,
                                  minMasterResizableWidth: 320,
                                  minDetailResizableWidth: 320,
                                  masterAppBar: DetailsAppBarSize.small,
                                  lateralDetailsAppBar: DetailsAppBarSize.small,
                                  pageDetailsAppBar: DetailsAppBarSize.small,
                                  masterBackgroundColor: backgroundColor,
                                  enableMasterSelection: true,
                                  enableDetailsSelection: true,
                                  autoImplyLeading: false,
                                  dividerColor: context.surface,
                                  onLoading: () async {
                                    final result = await ref.read(chatListControllerProvider(tabType: tabType).notifier).getMoreMessages(channel: _channel);
                                    updateChannelLocally(result);
                                    if (result?.isRateLimited ?? false) {
                                      Utils.showRateLimitedToast(type: RateLimitType.slack);
                                    }
                                    return true;
                                  },
                                  appbarSize: isFromInbox
                                      ? isMobileView
                                            ? 53
                                            : 48
                                      : isMobileView
                                      ? 53
                                      : 1,
                                  enableDropTarget: messageController.editingMessageId == null,
                                  onDragDone: (detail) async {
                                    if (tabNotifier.value != widget.tabType) return;
                                    for (final e in detail.files) {
                                      final bytes = await e.readAsBytes();
                                      final platformFile = PlatformFile(name: e.name, size: bytes.lengthInBytes, bytes: bytes, identifier: e.path);
                                      ref
                                          .read(chatFileListControllerProvider(tabType: widget.tabType, isThread: false).notifier)
                                          .getFileUploadUrl(type: _channel.type, file: platformFile);
                                    }
                                  },
                                  bottom: Container(
                                    color: backgroundColor,
                                    padding: EdgeInsets.only(
                                      bottom: max(0, MediaQuery.of(context).viewInsets.bottom - tabMargin - scrollViewBottomPadding.bottom),
                                    ),
                                    child: Container(
                                      key: inputAreaKey,
                                      width: double.maxFinite,
                                      padding: EdgeInsets.only(left: 8, right: 8, bottom: 0),
                                      child: (_channel.isArchived || _channel.isDmWithDeletedUser)
                                          ? Transform.translate(
                                              offset: Offset(0, -8),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                                                decoration: ShapeDecoration(
                                                  shape: RoundedRectangleBorder(
                                                    side: BorderSide(width: 1, color: context.surface, strokeAlign: -1),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                ),
                                                child: Text(
                                                  _channel.isDmWithDeletedUser
                                                      ? context.tr.chat_channel_viewing_dm_with_deactivated_account
                                                      : '${context.tr.chat_channel_you_are_viewing} #${_channel.displayName} ${context.tr.chat_channel_archived}',
                                                  style: context.titleSmall?.textColor(context.surface),
                                                ),
                                              ),
                                            )
                                          : Transform.translate(
                                              offset: Offset(0, -8),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: backgroundColor,
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(color: (messageFocusNode.hasFocus) ? context.surfaceVariant : context.outline, width: 1),
                                                ),
                                                child: MessageInputField(
                                                  key: messageInputFieldKey,
                                                  tabType: widget.tabType,
                                                  messageController: messageController,
                                                  focusNode: messageFocusNode,
                                                  isFromInbox: isFromInbox,
                                                  channel: _channel,
                                                  channels: channels,
                                                  members: members,
                                                  groups: groups,
                                                  emojis: emojis,
                                                  highlightNextTag: highlightNextTag,
                                                  highlightPreviousTag: highlightPreviousTag,
                                                  enterTag: enterTag,
                                                  isThread: false,
                                                  isEdit: messageController.editingMessageId != null,
                                                  onLastMessageSelected: () {
                                                    selectedMessageId = messages.firstOrNull?.id ?? '';
                                                  },
                                                  onPressEscape: () {
                                                    if (messageController.tagListVisible) {
                                                      messageController.tagListVisible = false;
                                                      setState(() {});
                                                      return true;
                                                    } else if (messageController.editingMessageId != null) {
                                                      clearMessage();
                                                      return true;
                                                    }
                                                    return false;
                                                  },
                                                  onKeyDown: _onKeyDown,
                                                  onKeyRepeat: _onKeyRepeat,
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                                  items: [
                                    if (isFromInbox && messages.isNotEmpty && hasRecent)
                                      MasterItem(
                                        'load more',
                                        'load more',
                                        onTap: () {},
                                        customWidget: (selected) => Container(
                                          padding: EdgeInsets.only(top: 0, bottom: 24),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              // SizedBox(width: 8),
                                              Text(
                                                context.tr.message_loaded_until(DateFormat('HH:mm a').format(messages.first.createdAt!)),
                                                style: context.bodyMedium?.textColor(context.onBackground),
                                              ),
                                              if (isLoadingMore)
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                                  child: CustomCircularLoadingIndicator(size: 8, color: context.secondary),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    if (messageData == null)
                                      MasterItem('empty messages', 'empty messages', onTap: () {}, customWidget: (selected) => skeletonWidget())
                                    else ...[
                                      ...messages.mapIndexed((index, message) {
                                        final prevMessage = index == 0 ? null : messages[index - 1];
                                        final nextMessage = index == messages.length - 1 ? null : messages[index + 1];

                                        return MasterItem(
                                          message.id!,
                                          message.id!,
                                          detailsBuilder: ((context, isSmall, onClose) {
                                            if (prevThreadId != message.id) {
                                              chatThreadScreenKey = GlobalKey(debugLabel: message.id);
                                              prevThreadId = message.id!;
                                            }

                                            return ChatThreadScreen(
                                              onDragStart: widget.onDragStart,
                                              onDragUpdate: widget.onDragUpdate,
                                              onDragEnd: widget.onDragEnd,
                                              key: chatThreadScreenKey,
                                              tabType: widget.tabType,
                                              channel: _channel,
                                              oAuthType: isFromInbox ? widget.taskMessage!.type.oAuthType : widget.oAuthType!,
                                              parentMessage: message,
                                              backgroundColor: widget.backgroundColor,
                                              isFromMobileTaskEdit: widget.isFromMobileTaskEdit,
                                              onCloseButtonPressed: closeDetails,
                                              emojis: emojis,
                                              members: members,
                                              groups: groups,
                                              moveToChannel: widget.moveToChannel,
                                              taskMessage: widget.taskMessage,
                                              deleteTask: widget.deleteTask,
                                              inboxConfig: widget.inboxConfig,
                                              close: closeDetails,
                                              onKeyDown: (event) => _onKeyDown(event, justReturnResult: true),
                                              onKeyRepeat: (event) => _onKeyRepeat(event, justReturnResult: true),
                                              onClose: () {
                                                final prevThreadId = ref.read(chatConditionProvider(widget.tabType).select((v) => v.threadId));
                                                if (prevThreadId == message.id! && masterDetailsKey.currentState?.isDetailOpened != true) {
                                                  ref.read(chatConditionProvider(widget.tabType).notifier).setThread(null);
                                                }

                                                onClose();
                                              },
                                            );
                                          }),
                                          customWidget: (selected) {
                                            bool showDateDivider() {
                                              if (nextMessage == null) return true;
                                              if (message.createdAt == null) return false;
                                              if (nextMessage.createdAt == null) return false;
                                              return !DateUtils.isSameDay(message.createdAt!, nextMessage.createdAt!);
                                            }

                                            bool showReadCursorLine() {
                                              if (!hasUnreadAtFirst) return false;
                                              if (initialChannel.lastReadAt == null) return false;
                                              if (message.createdAtMiliseconds == null) return false;
                                              if (nextMessage == null) return false;
                                              if (nextMessage.createdAtMiliseconds == null) return false;

                                              return initialChannel.lastReadAt!.isAtSameMomentAs(nextMessage.createdAtMiliseconds!) &&
                                                  initialChannel.lastReadAt!.isBefore(message.createdAtMiliseconds!);
                                            }

                                            return Column(
                                              children: [
                                                showDateDivider()
                                                    ? Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                                                        child: Row(
                                                          children: [
                                                            if (showReadCursorLine())
                                                              Container(
                                                                width: 39.4,
                                                                height: 1,
                                                                color: showReadCursorLine() ? context.error : context.surfaceVariant,
                                                              ),
                                                            Expanded(
                                                              child: Container(height: 1, color: showReadCursorLine() ? context.error : context.surfaceVariant),
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets.symmetric(horizontal: 12),
                                                              child: Text(
                                                                message.createdAt!.year == DateTime.now().year
                                                                    ? DateFormat('EEE, MMM d').format(message.createdAt!)
                                                                    : DateFormat('MMM d, yyyy').format(message.createdAt!),
                                                                style: context.bodyMedium?.textColor(context.surfaceTint).appFont(context),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Container(height: 1, color: showReadCursorLine() ? context.error : context.surfaceVariant),
                                                            ),
                                                            if (showReadCursorLine())
                                                              Padding(
                                                                padding: EdgeInsets.only(left: 12),
                                                                child: Text(
                                                                  context.tr.chat_new,
                                                                  style: context.labelMedium?.textColor(context.error).appFont(context),
                                                                ),
                                                              ),
                                                          ],
                                                        ),
                                                      )
                                                    : showReadCursorLine()
                                                    ? Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                              child: Container(height: 1, color: showReadCursorLine() ? context.error : context.surfaceVariant),
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets.only(left: 12),
                                                              child: Text(context.tr.chat_new, style: context.labelMedium?.textColor(context.error)),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    : const SizedBox.shrink(),
                                                MessageWidget(
                                                  onDragStart: widget.onDragStart,
                                                  onDragUpdate: widget.onDragUpdate,
                                                  onDragEnd: widget.onDragEnd,
                                                  tabType: tabType,
                                                  channel: _channel,
                                                  channels: channels,
                                                  members: members,
                                                  groups: groups,
                                                  emojis: emojis,
                                                  message: message,
                                                  scrollController: scrollController!,
                                                  openDetails: () {
                                                    if (PlatformX.isMobileView && doEmptyTapAction(checkTag: true)) return;
                                                    openDetails(threadId: message.threadId ?? message.id!, forceOpen: true);
                                                  },
                                                  onEdit: () {
                                                    var delta = HtmlToDelta().convert(
                                                      message.toHtml(
                                                        channel: _channel,
                                                        channels: channels,
                                                        members: members,
                                                        groups: groups,
                                                        emojis: emojis,
                                                        forEdit: true,
                                                      ),
                                                      transformTableAsEmbed: false,
                                                    );
                                                    messageController.document = Document.fromJson(delta.toJson());
                                                    messageController.editingMessageId = message.id;
                                                    messageInputFieldKey.currentState?.requestFocus();
                                                    messageController.updateSelection(
                                                      TextSelection.collapsed(offset: messageController.text.length),
                                                      ChangeSource.local,
                                                    );
                                                  },
                                                  moveToChannel: widget.moveToChannel,
                                                  prevMesasge: prevMessage,
                                                  nextMessage: nextMessage,
                                                  hoverBackgroundColor: PlatformX.isDesktopView && isFromInbox ? context.surfaceTint : context.surfaceVariant,
                                                  backgroundColor: message.id == messageController.editingMessageId
                                                      ? context.primary.withValues(alpha: 0.1)
                                                      : message.id == widget.taskMessage?.messageId
                                                      ? context.tertiary.withValues(alpha: 0.1)
                                                      : null,
                                                  channelLastReadAt: _channel.lastReadAt,
                                                  onTap: () {
                                                    if (PlatformX.isMobileView) {
                                                      if (doEmptyTapAction(checkTag: true)) return;
                                                      openDetails(threadId: message.threadId ?? message.id!, forceOpen: true);
                                                    }
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }).toList(),
                                      if (hasMore == false &&
                                          (ref.read(loadingStatusProvider.select((v) => v[ChatListController.stringKey(tabType)])) == LoadingState.success) &&
                                          !(ref.read(loadingStatusProvider.select((v) => v[ChatListController.stringKey(tabType)])) == LoadingState.loading))
                                        MasterItem(
                                          'very first',
                                          'very first',
                                          onTap: () {},
                                          customWidget: (selected) {
                                            return Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(bottom: 8),
                                                    child: Text(
                                                      '#${_channel.displayName}',
                                                      style: context.headlineMedium?.textColor(context.outlineVariant).copyWith(fontFamily: 'Roboto'),
                                                    ),
                                                  ),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          _channel.isDm
                                                              ? '${context.tr.chat_this_is_the_very_beginning_of_dm_with} ${_channel.displayName}.'
                                                              : _channel.isGroupDm
                                                              ? '${context.tr.chat_this_is_the_very_beginning_of_dm_with} ${_channel.membersNameString}.'
                                                              : '${context.tr.chat_this_is_the_very_beginning} #${_channel.displayName} ${context.tr.chat_channel}.',
                                                          style: context.titleMedium?.textColor(context.outlineVariant),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                    ],
                                  ],
                                );
                              },
                            ),
                          ),
                          Positioned(
                            bottom: (isMobileView ? context.viewInset.bottom : 0) + (caretOffset?.dy ?? 0) + 32,
                            left: 42.0 + (caretOffset?.dx ?? 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Visibility(
                                  visible: messageController.tagListVisible && tagList.isNotEmpty,
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 8, right: 16),
                                    child: TapRegion(
                                      onTapOutside: (tap) {
                                        messageController.tagListVisible = false;
                                        setState(() {});
                                      },
                                      behavior: HitTestBehavior.opaque,
                                      child: Container(
                                        width: 200,
                                        constraints: BoxConstraints(maxHeight: 240),
                                        decoration: BoxDecoration(
                                          color: context.surface,
                                          borderRadius: BorderRadius.circular(6),
                                          boxShadow: [BoxShadow(color: Color(0x3F000000), blurRadius: 12, offset: Offset(0, 4), spreadRadius: 0)],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(6),
                                          child: SuperListView.builder(
                                            controller: tagListScrollController,
                                            shrinkWrap: true,
                                            itemCount: tagList.length,
                                            itemBuilder: (context, index) {
                                              MessageTagEntity tag = tagList[index];
                                              bool isFirst = index == 0;
                                              bool isLast = index == tagList.length - 1;

                                              return Padding(
                                                key: tagList[index].globalObjectKey,
                                                padding: EdgeInsets.only(top: isFirst ? 6 : 0, bottom: isLast ? 6 : 0),
                                                child: GestureDetector(
                                                  onTapDown: (details) {
                                                    currentTagIdNotifier.value = tag.id ?? '';
                                                  },
                                                  onTapUp: (details) {
                                                    enterTag();
                                                  },
                                                  onLongPressDown: (details) {
                                                    currentTagIdNotifier.value = tag.id ?? '';
                                                  },
                                                  onLongPressUp: () {
                                                    enterTag();
                                                  },
                                                  child: MouseRegion(
                                                    cursor: SystemMouseCursors.click,
                                                    onEnter: (event) {
                                                      currentTagIdNotifier.value = tag.id ?? '';
                                                    },
                                                    child: ValueListenableBuilder<String>(
                                                      valueListenable: currentTagIdNotifier,
                                                      builder: (context, value, child) {
                                                        bool isHovering = value == tag.id;

                                                        return Container(
                                                          height: 36,
                                                          padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                                          color: isHovering ? context.outlineVariant.withValues(alpha: 0.1) : Colors.transparent,
                                                          child: Row(
                                                            children: [
                                                              Container(
                                                                width: 24,
                                                                height: 24,
                                                                decoration: ShapeDecoration(
                                                                  image: tag.type == MessageTagEntityType.member
                                                                      ? DecorationImage(
                                                                          image: CachedNetworkImageProvider(
                                                                            proxyUrl(tag.profileImageSmall ?? ''),
                                                                            imageRenderMethodForWeb: ImageRenderMethodForWeb.HttpGet,
                                                                          ),
                                                                          fit: BoxFit.fill,
                                                                        )
                                                                      : null,
                                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                                                ),
                                                                child: tag.iconData == null ? null : VisirIcon(type: tag.iconData!, size: 16),
                                                              ),
                                                              const SizedBox(width: 8),
                                                              Expanded(
                                                                child: Text(
                                                                  tag.formattedName ?? '',
                                                                  style: context.titleSmall?.textColor(context.outlineVariant),
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
