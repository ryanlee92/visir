import 'dart:math';

import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/master_detail_flow/src/details_item.dart';
import 'package:Visir/dependency/modal_bottom_sheet/src/utils/modal_scroll_controller.dart';
import 'package:Visir/features/chat/application/chat_channel_list_controller.dart';
import 'package:Visir/features/chat/application/chat_draft_controller.dart';
import 'package:Visir/features/chat/application/chat_emoji_list_controller.dart';
import 'package:Visir/features/chat/application/chat_file_list_controller.dart';
import 'package:Visir/features/chat/application/chat_group_list_controller.dart';
import 'package:Visir/features/chat/application/chat_member_list_controller.dart';
import 'package:Visir/features/chat/application/chat_thread_list_controller.dart';
import 'package:Visir/features/chat/domain/entities/message_channel_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_emoji_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_group_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_member_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_tag_entity.dart';
import 'package:Visir/features/chat/domain/entities/state/chat_fetch_result_entity.dart';
import 'package:Visir/features/chat/presentation/widgets/chat_input/message_input_field.dart';
import 'package:Visir/features/chat/presentation/widgets/chat_widget/message_widget.dart';
import 'package:Visir/features/chat/presentation/widgets/new_message_widget.dart';
import 'package:Visir/features/chat/providers.dart';
import 'package:Visir/features/chat/utils.dart';
import 'package:Visir/features/common/domain/entities/linked_item_entity.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
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
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image_platform_interface/cached_network_image_platform_interface.dart' show ImageRenderMethodForWeb;
import 'package:collection/collection.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_delta_from_html/parser/html_to_delta.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:super_sliver_list/super_sliver_list.dart';

class ChatThreadScreen extends ConsumerStatefulWidget {
  final MessageChannelEntity channel;
  final MessageEntity parentMessage;
  final OAuthType oAuthType;
  final void Function() onCloseButtonPressed;
  final Future<void> Function({required String channelId})? moveToChannel;

  final bool Function(KeyEvent event)? onKeyDown;
  final bool Function(KeyEvent event)? onKeyRepeat;

  final List<MessageEmojiEntity> emojis;
  final List<MessageMemberEntity> members;
  final List<MessageGroupEntity> groups;

  final LinkedMessageEntity? taskMessage;
  final List<String>? taskMessageGroupIds;
  final VoidCallback? deleteTask;
  final InboxConfigEntity? inboxConfig;
  final TabType tabType;
  final VoidCallback close;
  final VoidCallback? onClose;
  final bool? isFromMobileTaskEdit;
  final Color? backgroundColor;

  final void Function(MessageEntity chat)? onDragStart;
  final void Function(MessageEntity chat, Offset offset)? onDragUpdate;
  final void Function(MessageEntity chat)? onDragEnd;

  const ChatThreadScreen({
    super.key,
    required this.channel,
    required this.parentMessage,
    required this.oAuthType,
    required this.onCloseButtonPressed,
    required this.moveToChannel,
    required this.tabType,
    required this.close,
    required this.emojis,
    required this.members,
    required this.groups,
    this.onClose,
    this.taskMessage,
    this.taskMessageGroupIds,
    this.onKeyDown,
    this.onKeyRepeat,
    this.deleteTask,
    this.inboxConfig,
    this.isFromMobileTaskEdit,
    this.backgroundColor,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => ChatThreadScreenState();
}

class ChatThreadScreenState extends ConsumerState<ChatThreadScreen> {
  ValueNotifier<double> inputAreaHeightNotifier = ValueNotifier(0);
  ValueNotifier<String> currentTagIdNotifier = ValueNotifier('');
  ValueNotifier<bool> isCurrentNotifier = ValueNotifier(true);

  ScrollController? scrollController;
  ListController listController = ListController();
  ScrollController tagListScrollController = ScrollController();
  FocusNode textFormFieldfocusNode = FocusNode();

  double get inputAreaDefaultHeight => 62;

  late MessageChannelEntity _channel;

  MessageEntity get _parent => widget.parentMessage;

  final List<MessageTagEntity> tagList = [];

  String tagSearchWord = '';

  bool get isMobileView => PlatformX.isMobileView;

  bool get isFromInbox => widget.tabType != TabType.chat;

  GlobalKey inputAreaKey = GlobalKey();

  late CustomTagController replyController;

  TabType get tabType => widget.tabType;

  double get appbarSize => isFromInbox ? 48 : 52;

  String get teamId => ref.read(chatConditionProvider(widget.tabType).select((v) => v.channel!.teamId));
  List<MessageChannelEntity> get channels => ref.read(chatChannelListControllerProvider.select((v) => v[teamId]?.channels ?? []));
  List<MessageMemberEntity> get members => ref.read(chatMemberListControllerProvider(tabType: tabType).select((v) => v.members));
  List<MessageGroupEntity> get groups => ref.read(chatGroupListControllerProvider(tabType: tabType).select((v) => v.groups));
  List<MessageEmojiEntity> get emojis => ref.read(chatEmojiListControllerProvider(tabType: tabType).select((v) => v.emojis));

  ValueNotifier<bool> showLoadingNotifier = ValueNotifier(false);

  GlobalKey sendButtonKey = GlobalKey();

  GlobalKey<MessageInputFieldState> messageInputFieldKey = GlobalKey<MessageInputFieldState>();

  ValueNotifier<bool> sendingFailedMessageInputFieldNotifier = ValueNotifier(false);

  OverlayEntry? newMessageIndicatorOverlayEntry;

  String get overlayKey => '${widget.tabType.name}-reply-list';

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

    _channel = widget.channel;

    replyController = CustomTagController(channels: channels, channel: _channel);
    replyController.addListener(onTextChanged);
    isCurrentNotifier.addListener(() {
      if (!isCurrentNotifier.value) return;
      currentTagIdNotifier.value = '';
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showLoadingOnMobile();
      textFormFieldfocusNode.addListener(onTextFormFieldFocusChanged);
    });
  }

  void scrollListener() {
    if (scrollController == null) return;
    if (scrollController!.offset > scrollController!.position.maxScrollExtent - 10) {
      hideNewMessageIndicator();
    }
  }

  @override
  void dispose() {
    ref.read(chatConditionProvider(tabType).notifier).clearThread();

    scrollController?.removeListener(scrollListener);
    scrollController?.dispose();

    textFormFieldfocusNode.unfocus();
    replyController.removeListener(onTextChanged);
    textFormFieldfocusNode.removeListener(onTextFormFieldFocusChanged);
    widget.onClose?.call();
    replyController.dispose();
    inputAreaHeightNotifier.dispose();
    currentTagIdNotifier.dispose();
    isCurrentNotifier.dispose();
    listController.dispose();

    newMessageIndicatorOverlayEntry?.remove();
    newMessageIndicatorOverlayEntry?.dispose();
    newMessageIndicatorOverlayEntry = null;
    super.dispose();
  }

  int newMessageCount = 0;
  void showNewMessageIndicator() {
    if (scrollController == null) return;
    if (scrollController!.offset > scrollController!.position.maxScrollExtent - 10) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        scrollController?.jumpTo(scrollController!.position.maxScrollExtent);
      });
      return;
    }

    final inputAreaStack = inputAreaKey.currentContext?.findRenderObject() as RenderBox?;
    if (inputAreaStack == null) return;

    final prevEntry = newMessageIndicatorOverlayEntry;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      final inputAreaStackPosition = inputAreaStack.localToGlobal(Offset.zero);
      final stackOffset = FixedOverlayHost.getStackOffset(overlayKey);
      newMessageCount++;

      newMessageIndicatorOverlayEntry = OverlayEntry(
        builder: (BuildContext context) {
          return Padding(
            padding: EdgeInsets.only(top: inputAreaStackPosition.dy - (stackOffset?.dy ?? 0) - 38),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [NewMessageWidget(scrollController: scrollController, isReverse: false, count: newMessageCount)],
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

  void onTextFormFieldFocusChanged() {
    setState(() {});
  }

  void updateChannelLocally(ChatFetchResultEntity? result) {
    if (result == null) return;
    final channel = Utils.ref.read(chatChannelListControllerProvider.notifier).updateChannelLocally(teamId: _channel.teamId, channel: result.channel);
    _channel = channel ?? _channel;
    replyController.setChannel(_channel);
    setState(() {});
  }

  Offset? caretOffset;
  void onTextChanged() {
    final value = replyController.text.trim();

    refreshTagSearchResult();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (value.isEmpty) {
        replyController.tagListVisible = false;
      } else if (((value.length == 1 || replyController.selection.start == 1) && value[0] == '@' && (value.length < 2 || value[1] == ' '))) {
        caretOffset = messageInputFieldKey.currentState?.getCaretOffset();
        replyController.tagListVisible = true;
      } else if ((value.length > 1 &&
          replyController.selection.start > 1 &&
          value.length >= replyController.selection.start &&
          (value.substring(replyController.selection.start - 2, replyController.selection.start) == ' @' ||
              value.substring(replyController.selection.start - 2, replyController.selection.start) == '\n@'))) {
        caretOffset = messageInputFieldKey.currentState?.getCaretOffset();
        replyController.tagListVisible = true;
      }

      if (replyController.tagListVisible) {
        currentTagIdNotifier.value = tagList.firstOrNull?.id ?? '';
      }

      setState(() {});
    });
  }

  void clearMessage() {
    replyController.clear();
    ref.read(chatDraftControllerProvider(teamId: _channel.teamId, channelId: _channel.id, threadId: widget.parentMessage.id).notifier).setDraft(null);
  }

  Future<void> refreshTagSearchResult() async {
    tagList.clear();

    final broadcastChannelTag = MessageTagEntity(type: MessageTagEntityType.broadcastChannel);
    final broadcastHereTag = MessageTagEntity(type: MessageTagEntityType.broadcastHere);

    if (replyController.value.selection.end > 1) {
      int? searchFromIndex = replyController.text.substring(0, replyController.value.selection.end).lastIndexOf('@') + 1;
      if (searchFromIndex >= 0) {
        tagSearchWord = replyController.text.substring(searchFromIndex, replyController.value.selection.end);
      } else {
        tagSearchWord = '';
      }
    } else {
      tagSearchWord = '';
    }

    if (widget.channel.isChannel) {
      if (broadcastChannelTag.id?.toLowerCase().startsWith(tagSearchWord.toLowerCase()) ?? false) {
        tagList.add(broadcastChannelTag);
      }
      if (broadcastHereTag.id?.toLowerCase().startsWith(tagSearchWord.toLowerCase()) ?? false) {
        tagList.add(broadcastHereTag);
      }
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

    final matchedChannelsContain = ref
        .read(chatChannelListControllerProvider.select((v) => v[teamId]?.availableChannels ?? []))
        .where((e) => (e.name?.toLowerCase().startsWith(tagSearchWord.toLowerCase()) ?? false))
        .toList();

    if (widget.channel.isChannel) {
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
    final lastIndex = replyController.text.substring(0, replyController.value.selection.end).lastIndexOf('@');
    replyController.text = replyController.text.replaceRange(lastIndex, replyController.value.selection.end, tagString);
    messageInputFieldKey.currentState?.requestFocus();
    replyController.updateSelection(TextSelection.collapsed(offset: lastIndex + tagString.length), ChangeSource.local);
    replyController.tagListVisible = false;

    switch (tag.type) {
      case MessageTagEntityType.member:
        replyController.addTaggedData(member: tag.member);
        break;
      case MessageTagEntityType.memberGroup:
        replyController.addTaggedData(group: tag.memberGroup);
        break;
      case MessageTagEntityType.channel:
        replyController.addTaggedData(channel: tag.channel);
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

  void checkPayloadThenAction() {
    final payload = notificationPayload;
    if (payload == null) return;
    if ((payload['isHome'] != null) == (tabType == TabType.chat)) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      switch (payload['type']) {
        case 'slack':
          final channelId = payload['channelId'];
          final messageId = payload['messageId'];
          final threadId = payload['threadId'];
          if (_channel.id != channelId) return;
          if (_parent.id != threadId) return;
          if (messageId == null) return;
          if (channelId == null) return;

          if (!mounted) return;
          final repliesData = ref.read(chatThreadListControllerProvider(tabType: tabType).select((v) => v?.messages ?? []));
          final replies = repliesData.where((m) => m.id != _parent.id).toList();
          final index = replies.indexWhere((e) => e.id == messageId);
          if (index < 0) return;
          notificationPayload = null;
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
          break;
      }
    });
  }

  bool doEmptyTapAction({bool? checkTag}) {
    if (replyController.tagListVisible) {
      if (checkTag == true) {
        replyController.tagListVisible = false;
        setState(() {});
      }

      return true;
    }

    if (textFormFieldfocusNode.hasFocus) {
      textFormFieldfocusNode.unfocus();
      return true;
    }

    return false;
  }

  double prevKeyboardHeight = 0;

  bool _onKeyRepeat(KeyEvent event, {bool? justReturnResult}) {
    final result = widget.onKeyRepeat?.call(event);
    if (result == true) return true;

    final logicalKeyPressed = ServicesBinding.instance.keyboard.logicalKeysPressed.where((e) => e != LogicalKeyboardKey.escape);

    if (logicalKeyPressed.length == 1) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        final repliesData = ref.read(chatThreadListControllerProvider(tabType: tabType).select((v) => v?.messages ?? []));
        final replies = repliesData.where((m) => m.id != _parent.id).toList();

        if (selectedMessageId.isNotEmpty) {
          final messageIndex = replies.indexWhere((e) => e.id == selectedMessageId);
          final newMessageIndex = messageIndex + 1;
          if (replies.length > newMessageIndex) {
            selectedMessageId = replies[newMessageIndex].id ?? '';
            return true;
          }
        }
      }

      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        final repliesData = ref.read(chatThreadListControllerProvider(tabType: tabType).select((v) => v?.messages ?? []));
        final replies = repliesData.where((m) => m.id != _parent.id).toList();

        if (selectedMessageId.isNotEmpty) {
          final messageIndex = replies.indexWhere((e) => e.id == selectedMessageId);
          final newMessageIndex = messageIndex - 1;
          if (newMessageIndex > -1) {
            selectedMessageId = replies[newMessageIndex].id ?? '';
            return true;
          }
        }
      }
    }

    return false;
  }

  bool _onKeyDown(KeyEvent event, {bool? justReturnResult}) {
    final result = widget.onKeyDown?.call(event);
    if (result == true) return true;

    final logicalKeyPressed = ServicesBinding.instance.keyboard.logicalKeysPressed.where((e) => e != LogicalKeyboardKey.escape).toList();

    if (logicalKeyPressed.length <= 2) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        final repliesData = ref.read(chatThreadListControllerProvider(tabType: tabType).select((v) => v?.messages ?? []));
        final replies = repliesData.where((m) => m.id != _parent.id).toList();

        if (selectedMessageId.isNotEmpty) {
          final messageIndex = replies.indexWhere((e) => e.id == selectedMessageId);
          final newMessageIndex = messageIndex + 1;
          if (replies.length > newMessageIndex) {
            selectedMessageId = replies[newMessageIndex].id ?? '';

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

      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        final repliesData = ref.read(chatThreadListControllerProvider(tabType: tabType).select((v) => v?.messages ?? []));
        final replies = repliesData.where((m) => m.id != _parent.id).toList();

        if (selectedMessageId.isNotEmpty) {
          final messageIndex = replies.indexWhere((e) => e.id == selectedMessageId);
          final newMessageIndex = messageIndex - 1;
          if (newMessageIndex > -1) {
            selectedMessageId = replies[newMessageIndex].id ?? '';

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
        final repliesData = ref.read(chatThreadListControllerProvider(tabType: tabType).select((v) => v?.messages ?? []));
        final replies = repliesData.where((m) => m.id != _parent.id).toList();
        if (selectedMessageId == replies.lastOrNull?.id) {
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
      messageInputFieldKey.currentState?.requestFocus();
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    scrollController ??= ModalScrollController.ofSyncGroup(context)?.addAndGet() ?? ScrollController();
    final members = ref.watch(chatMemberListControllerProvider(tabType: tabType).select((v) => v.members));
    final groups = ref.watch(chatGroupListControllerProvider(tabType: tabType).select((v) => v.groups));
    final emojis = ref.watch(chatEmojiListControllerProvider(tabType: tabType).select((v) => v.emojis));

    ref.listen(chatThreadListControllerProvider(tabType: tabType), (prev, next) {
      checkPayloadThenAction();

      if (next?.messages.lastOrNull?.isMyMessage(channel: _channel) != true && next?.messages.lastOrNull?.id != prev?.messages.lastOrNull?.id) {
        showNewMessageIndicator();
      }

      if (prev?.messages.length != next?.messages.length) {
        if (!mounted) return;
        final pref = ref.read(localPrefControllerProvider).value;
        final slackOAuth = pref?.messengerOAuths?.firstWhereOrNull((e) => e.team?.id == _channel.teamId);
        final me = members.firstWhereOrNull((m) => m.email == slackOAuth?.email);
        if (next?.messages.lastOrNull?.userId == me?.id) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            scrollController?.jumpTo(scrollController!.position.maxScrollExtent);
          });
        }
      }

      if (next?.messages.isNotEmpty == true) {
        final result = next!;

        if (result.isRateLimited ?? false) {
          Utils.showRateLimitedToast(type: RateLimitType.slack);
          return;
        }

        final lastReadAt = result.messages.lastOrNull?.createdAt;
        if (lastReadAt == null) return;
        if (!mounted) return;

        ref.read(chatChannelListControllerProvider.notifier).setReadCursor(teamId: _channel.teamId, channelId: _channel.id, lastReadAt: lastReadAt);
      }
    });

    ref.listen(localPrefControllerProvider, (previous, next) {
      if (previous?.value?.notificationPayload != next.value?.notificationPayload) {
        checkPayloadThenAction();
      }
    });

    final repliesData = ref.watch(chatThreadListControllerProvider(tabType: tabType).select((v) => v?.messages ?? []));
    final replies = repliesData.where((m) => m.id != _parent.id && members.any((e) => e.id == m.userId)).toList();

    bool _isCurrent = ModalRoute.of(context)?.isCurrent ?? false;
    isCurrentNotifier.value = _isCurrent;

    Color backgroundColor = widget.backgroundColor ?? context.background;

    if (scrollController == null) return Container(color: backgroundColor);

    return KeyboardShortcut(
      targetTab: widget.tabType,
      onKeyDown: _onKeyDown,
      onKeyRepeat: _onKeyRepeat,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: doEmptyTapAction,
        child: FGBGDetector(
          onChanged: (isForeground, isFirst) {
            if (!isForeground) return;
            checkPayloadThenAction();
            if (isFirst) return;
            if (PlatformX.isMobileView) return;
            if (tabNotifier.value != widget.tabType) return;
            messageInputFieldKey.currentState?.requestFocus();
          },
          child: ValueListenableBuilder(
            valueListenable: MobileScaffold.largeTabBar,
            builder: (context, largeTabBar, child) {
              return ValueListenableBuilder<double>(
                valueListenable: inputAreaHeightNotifier,
                builder: (context, inputAreaHeightValue, _) {
                  bool showBackButton = isFromInbox || isMobileView || (MediaQuery.of(context).size.width < Constants.chatScreenBreakPoint);
                  final tabMargin = PlatformX.isMobileView
                      ? ModalScrollController.of(context) != null
                            ? max(context.padding.bottom - 8, 8.0)
                            : (largeTabBar ? MobileScaffold.bottomPaddingForLargeTabBar : MobileScaffold.bottomPaddingForSmallTabBar)
                      : 0.0;

                  return Container(
                    color: backgroundColor,
                    padding: PlatformX.isMobileView ? EdgeInsets.only(bottom: tabMargin) : EdgeInsets.zero,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        if (PlatformX.isMobile && prevKeyboardHeight != context.viewInset.bottom && scrollController?.hasClients == true) {
                          scrollController?.jumpTo(scrollController!.position.maxScrollExtent);
                        }

                        prevKeyboardHeight = context.viewInset.bottom;
                        return Stack(
                          children: [
                            Positioned.fill(
                              top: 0,
                              left: 0,
                              right: 0,
                              bottom: max(0, MediaQuery.of(context).viewInsets.bottom - (widget.isFromMobileTaskEdit == true ? 0 : kMainTabBarHeight - 6)),
                              child: DropTarget(
                                enable: replyController.editingMessageId == null,
                                onDragDone: (detail) async {
                                  if (tabNotifier.value != widget.tabType) return;
                                  for (final e in detail.files) {
                                    final bytes = await e.readAsBytes();
                                    final platformFile = PlatformFile(
                                      path: e.path,
                                      name: path.basename(e.path),
                                      size: bytes.lengthInBytes,
                                      bytes: bytes,
                                      identifier: e.path,
                                    );
                                    ref
                                        .read(chatFileListControllerProvider(tabType: widget.tabType, isThread: true).notifier)
                                        .getFileUploadUrl(type: _channel.type, file: platformFile);
                                  }
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: inputAreaHeightValue),
                                  child: DetailsItem(
                                    customBottomPadding: 0,
                                    scrollController: scrollController,
                                    scrollPhysics: Utils.getScrollPhysicsForBottomSheet(context, scrollController),
                                    listController: listController,
                                    showLoadingNotifier: showLoadingNotifier,
                                    onRefresh: () async {
                                      await ref.read(chatThreadListControllerProvider(tabType: tabType).notifier).load(isRefresh: true);
                                    },
                                    bodyWrapper: (child) => FixedOverlayHost(key: ValueKey(overlayKey), overlayKey: overlayKey, child: child),
                                    hideBackButton: !showBackButton,
                                    actions: [],
                                    leadings: [
                                      if (!showBackButton)
                                        VisirAppBarButton(
                                          icon: VisirIconType.close,
                                          onTap: widget.onCloseButtonPressed,
                                          options: VisirButtonOptions(
                                            tabType: widget.tabType,
                                            shortcuts: [
                                              VisirButtonKeyboardShortcut(
                                                message: context.tr.close,
                                                keys: [LogicalKeyboardKey.escape],
                                                prevOnKeyDown: widget.onKeyDown,
                                                prevOnKeyRepeat: widget.onKeyRepeat,
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                    title: context.tr.chat_thread,
                                    bodyPadding: EdgeInsets.zero,
                                    children: [
                                      Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(top: 11, bottom: 5),
                                            child: MessageWidget(
                                              onDragStart: widget.onDragStart,
                                              onDragUpdate: widget.onDragUpdate,
                                              onDragEnd: widget.onDragEnd,
                                              tabType: tabType,
                                              channel: _channel,
                                              channels: channels,
                                              members: members,
                                              groups: groups,
                                              emojis: emojis,
                                              scrollController: scrollController!,
                                              onTap: () {},
                                              message: _parent,
                                              parentMessage: _parent,
                                              openDetails: () {},
                                              moveToChannel: widget.moveToChannel,
                                              prevMesasge: null,
                                              nextMessage: null,
                                              hoverBackgroundColor: context.surfaceVariant,
                                              channelLastReadAt: null,
                                              backgroundColor: _parent.id == replyController.editingMessageId ? context.primary.withValues(alpha: 0.1) : null,
                                              onEdit: () {
                                                var delta = HtmlToDelta().convert(
                                                  _parent.toHtml(
                                                    channel: _channel,
                                                    channels: channels,
                                                    members: members,
                                                    groups: groups,
                                                    emojis: emojis,
                                                    forEdit: true,
                                                  ),
                                                  transformTableAsEmbed: false,
                                                );
                                                replyController.document = Document.fromJson(delta.toJson());
                                                replyController.editingMessageId = _parent.id;
                                                messageInputFieldKey.currentState?.requestFocus();
                                                replyController.updateSelection(
                                                  TextSelection.collapsed(offset: replyController.text.length),
                                                  ChangeSource.local,
                                                );
                                              },
                                            ),
                                          ),
                                          if (replies.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 7),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    '${replies.length} ${context.tr.chat_replies}',
                                                    style: context.labelMedium?.textColor(context.surfaceTint),
                                                  ),
                                                  SizedBox(width: 12),
                                                  Expanded(child: Container(height: 1, color: context.surfaceVariant)),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                      ...replies.map((reply) {
                                        final index = replies.indexOf(reply);
                                        final prevMessage = index == 0 ? null : replies[index - 1];
                                        final nextMessage = index == replies.length - 1 ? null : replies[index + 1];

                                        return MessageWidget(
                                          onDragStart: widget.onDragStart,
                                          onDragUpdate: widget.onDragUpdate,
                                          onDragEnd: widget.onDragEnd,
                                          tabType: tabType,
                                          channel: _channel,
                                          channels: channels,
                                          members: members,
                                          groups: groups,
                                          emojis: emojis,
                                          scrollController: scrollController!,
                                          message: reply,
                                          openDetails: () {},
                                          onTap: () {},
                                          parentMessage: _parent,
                                          moveToChannel: widget.moveToChannel,
                                          prevMesasge: nextMessage,
                                          nextMessage: prevMessage,
                                          hoverBackgroundColor: context.surfaceVariant,
                                          backgroundColor: reply.id == replyController.editingMessageId
                                              ? context.primary.withValues(alpha: 0.1)
                                              : reply.id == widget.taskMessage?.messageId
                                              ? context.tertiary.withValues(alpha: context.isDarkMode ? 0.4 : 0.2)
                                              : widget.taskMessageGroupIds?.contains(reply.id) == true
                                              ? context.tertiary.withValues(alpha: context.isDarkMode ? 0.2 : 0.1)
                                              : null,
                                          channelLastReadAt: null,
                                          onEdit: () {
                                            var delta = HtmlToDelta().convert(
                                              reply.toHtml(
                                                channel: _channel,
                                                channels: channels,
                                                members: members,
                                                groups: groups,
                                                emojis: emojis,
                                                forEdit: true,
                                              ),
                                              transformTableAsEmbed: false,
                                            );
                                            replyController.document = Document.fromJson(delta.toJson());
                                            replyController.editingMessageId = reply.id;
                                          },
                                        );
                                      }).toList(),
                                      SizedBox(height: 8),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              child: Padding(
                                padding: EdgeInsets.only(bottom: max(0, MediaQuery.of(context).viewInsets.bottom - scrollViewBottomPadding.bottom - tabMargin)),
                                child: Container(
                                  key: inputAreaKey,
                                  width: constraints.maxWidth,
                                  color: Colors.transparent,
                                  padding: EdgeInsets.only(left: 8, right: 8, bottom: 0),
                                  child: (_channel.isArchived || _channel.isDmWithDeletedUser)
                                      ? Transform.translate(
                                          offset: Offset(0, -8),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                                            decoration: ShapeDecoration(
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(width: 1, color: context.surface),
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
                                          child: LayoutBuilder(
                                            builder: (context, constraints) {
                                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                                final inputAreaHeight = inputAreaKey.currentContext?.size?.height ?? 0;
                                                if (inputAreaHeight != inputAreaHeightNotifier.value) {
                                                  inputAreaHeightNotifier.value = inputAreaHeight;
                                                }
                                              });
                                              return Container(
                                                decoration: BoxDecoration(
                                                  color: backgroundColor,
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: (textFormFieldfocusNode.hasFocus) ? context.surfaceVariant : context.outline,
                                                    width: 1,
                                                  ),
                                                ),
                                                child: MessageInputField(
                                                  key: messageInputFieldKey,
                                                  threadId: widget.parentMessage.id,
                                                  onLastMessageSelected: () {
                                                    selectedMessageId = replies.lastOrNull?.id ?? '';
                                                  },
                                                  tabType: widget.tabType,
                                                  messageController: replyController,
                                                  focusNode: textFormFieldfocusNode,
                                                  isFromInbox: isFromInbox,
                                                  channel: _channel,
                                                  channels: channels,
                                                  members: members,
                                                  groups: groups,
                                                  emojis: emojis,
                                                  highlightNextTag: highlightNextTag,
                                                  highlightPreviousTag: highlightPreviousTag,
                                                  enterTag: enterTag,
                                                  isThread: true,
                                                  isEdit: replyController.editingMessageId != null,
                                                  onPressEscape: () {
                                                    if (replyController.tagListVisible) {
                                                      replyController.tagListVisible = false;
                                                      setState(() {});
                                                      return true;
                                                    } else if (replyController.editingMessageId != null) {
                                                      clearMessage();
                                                      return true;
                                                    }
                                                    return false;
                                                  },
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: (isMobileView ? context.viewInset.bottom : 0) + (caretOffset?.dy ?? 0) + 32,
                              left: 42.0 + (caretOffset?.dx ?? 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Visibility(
                                    visible: replyController.tagListVisible && tagList.isNotEmpty,
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 8, right: 16),
                                      child: TapRegion(
                                        onTapOutside: (tap) {
                                          replyController.tagListVisible = false;
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
                        );
                      },
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
