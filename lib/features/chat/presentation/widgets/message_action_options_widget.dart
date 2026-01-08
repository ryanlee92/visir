import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/contextmenu/src/ContextMenuArea.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/calendar/presentation/widgets/calendar_simple_create_widget.dart';
import 'package:Visir/features/chat/actions.dart';
import 'package:Visir/features/chat/application/chat_channel_list_controller.dart';
import 'package:Visir/features/chat/domain/entities/message_channel_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_emoji_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_group_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_member_entity.dart';
import 'package:Visir/features/chat/presentation/widgets/message_add_emoji_widget.dart';
import 'package:Visir/features/common/domain/entities/linked_item_entity.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/presentation/widgets/selection_widget.dart';
import 'package:Visir/features/common/presentation/widgets/showcase_wrapper.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_config_entity.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_entity.dart';
import 'package:Visir/features/inbox/presentation/widgets/agent_input_field.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:Visir/features/task/presentation/widgets/simple_task_or_event_switcher_widget.dart';
import 'package:Visir/features/time_saved/actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum MessageActionType { edit, delete }

extension MessageActionTypeX on MessageActionType {
  String getTitle(BuildContext context) {
    switch (this) {
      case MessageActionType.delete:
        return context.tr.delete_message;
      case MessageActionType.edit:
        return context.tr.edit_message;
    }
  }

  Color getTitleColor(BuildContext context) {
    switch (this) {
      case MessageActionType.delete:
        return context.error;
      case MessageActionType.edit:
        return context.onSurface;
    }
  }
}

class MessageActionOptions extends ConsumerStatefulWidget {
  final MessageChannelEntity channel;
  final List<MessageChannelEntity> channels;
  final List<MessageMemberEntity> members;
  final List<MessageGroupEntity> groups;
  final List<MessageEmojiEntity> emojis;
  final MessageEntity message;
  final MessageEntity? parentMessage;
  final Color? backgroundColor;
  final VoidCallback openDetails;
  final VoidCallback onEdit;
  final TabType tabType;
  final OAuthEntity? oauth;

  const MessageActionOptions({
    required this.onEdit,
    required this.channel,
    required this.channels,
    required this.members,
    required this.groups,
    required this.emojis,
    required this.message,
    required this.parentMessage,
    required this.openDetails,
    required this.tabType,
    this.backgroundColor,
    this.oauth,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MessageActionOptionsState();
}

class _MessageActionOptionsState extends ConsumerState<MessageActionOptions> with SingleTickerProviderStateMixin {
  bool get isReply => widget.parentMessage != null;
  bool get isDarkMode => context.isDarkMode;

  MessageMemberEntity get sender => widget.members.firstWhere((e) => e.id == widget.message.userId);

  void startChat() {
    final channels = ref.read(chatChannelListControllerProvider.select((v) => v[widget.channel.teamId]?.channels ?? []));
    
    // Create InboxEntity from MessageEntity
    final inboxConfig = InboxConfigEntity(
      inboxUniqueId: InboxEntity.getInboxIdFromChat(widget.message),
      userId: ref.read(authControllerProvider).requireValue.id,
      dateTime: widget.message.createdAt ?? DateTime.now(),
    );
    
    final inbox = InboxEntity.fromChat(
      widget.message,
      inboxConfig,
      widget.channel,
      sender,
      channels,
      widget.members,
      widget.groups,
    );

    // Navigate to home tab
    Navigator.maybeOf(Utils.mainContext)?.popUntil((route) => route.isFirst);
    tabNotifier.value = TabType.home;
    UserActionSwtichAction.onSwtichTab(targetTab: TabType.home);

    // Add tag to AgentInputField after navigation - retry multiple times
    void tryAddTag({int retryCount = 0}) {
      final agentInputFieldState = AgentInputField.of(Utils.mainContext);
      if (agentInputFieldState != null) {
        agentInputFieldState.addInboxTag(inbox);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          agentInputFieldState.requestFocus();
        });
      } else if (retryCount < 10) {
        Future.delayed(Duration(milliseconds: 100 * (retryCount + 1)), () {
          tryAddTag(retryCount: retryCount + 1);
        });
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      tryAddTag();
    });
  }

  bool keepFocus = false;
  String currentPopupKey = '';

  late AnimationController _tourHighlightController;
  late Animation<Color?> _tourHighlightAnimation;

  @override
  void initState() {
    super.initState();
    _tourHighlightController = AnimationController(
      duration: const Duration(milliseconds: 500), // 한 번 깜빡이는 시간
      vsync: this,
    );

    if (isShowcaseOn.value != null) {
      _tourHighlightController.repeat(reverse: true);
    }

    _tourHighlightAnimation = ColorTween(
      begin: Utils.mainContext.primary.withValues(alpha: 0.25),
      end: Utils.mainContext.primary,
    ).animate(_tourHighlightController);
  }

  @override
  void dispose() {
    _tourHighlightController.dispose();
    super.dispose();
  }

  void handleKeepFocus(bool focus, String popupKey) {
    // Future.delayed(Duration(milliseconds: 250), () {
    //   if (currentPopupKey == popupKey || currentPopupKey.isEmpty) {
    //     currentPopupKey = popupKey;
    //     keepFocus = focus;
    //     // setState(() {});
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    final channels = ref.read(chatChannelListControllerProvider.select((v) => v[widget.channel.teamId]?.channels ?? []));
    final user = ref.read(authControllerProvider).requireValue;

    if (sender.displayName == null) {
      return const SizedBox.shrink();
    }

    return ShowcaseWrapper(
      showcaseKey: widget.message.id == targetChatMessageId ? chatCreateTaskShowcaseKeyString : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        height: 32,
        decoration: ShapeDecoration(
          color: context.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(width: 1, color: context.surfaceVariant.withValues(alpha: 0.5)),
          ),
          shadows: PopupMenu.popupShadow,
        ),
        child: Row(
          children: [
            PopupMenu(
              forcePopup: true,
              enabled: !keepFocus,
              closeOnTapWhenDisabled: true,
              location: PopupMenuLocation.bottom,
              width: 358,
              height: 420,
              type: ContextMenuActionType.tap,
              beforePopup: () => handleKeepFocus(true, 'emoji'),
              afterPopup: () => handleKeepFocus(false, 'emoji'),
              popup: MessageAddEmojiWidget(
                channel: widget.channel,
                message: widget.message,
                parentMessage: widget.parentMessage,
                tabType: widget.tabType,
                oauth: widget.oauth,
              ),
              style: VisirButtonStyle(borderRadius: BorderRadius.circular(4), padding: EdgeInsets.all(6)),
              options: VisirButtonOptions(
                tabType: widget.tabType,
                bypassTextField: true,
                shortcuts: [
                  VisirButtonKeyboardShortcut(
                    keys: [LogicalKeyboardKey.keyS, if (PlatformX.isApple) LogicalKeyboardKey.meta, if (!PlatformX.isApple) LogicalKeyboardKey.control],
                    message: context.tr.reaction,
                  ),
                ],
              ),
              child: VisirIcon(type: VisirIconType.emoji, size: 16, isSelected: true),
            ),
            if (!isReply)
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Material(
                  color: Colors.transparent,
                  child: VisirButton(
                    key: ValueKey('${widget.parentMessage?.id}_${keepFocus}_reply_button'),
                    type: keepFocus ? VisirButtonAnimationType.none : VisirButtonAnimationType.scaleAndOpacity,
                    style: VisirButtonStyle(padding: EdgeInsets.all(6)),
                    options: VisirButtonOptions(
                      tabType: widget.tabType,
                      shortcuts: [
                        VisirButtonKeyboardShortcut(
                          keys: [LogicalKeyboardKey.keyA, if (PlatformX.isApple) LogicalKeyboardKey.meta, if (!PlatformX.isApple) LogicalKeyboardKey.control],
                          message: context.tr.reply_in_thread,
                        ),
                      ],
                    ),
                    onTap: keepFocus ? context.pop : widget.openDetails,
                    child: VisirIcon(type: VisirIconType.thread, size: 16, isSelected: true),
                  ),
                ),
              ),
            AnimatedBuilder(
              animation: _tourHighlightAnimation,
              builder: (context, child) {
                return PopupMenu(
                  forcePopup: true,
                  location: PopupMenuLocation.bottom,
                  width: Constants.desktopCreateTaskPopupWidth,
                  type: ContextMenuActionType.tap,
                  backgroundColor: Colors.transparent,
                  borderRadius: 6,
                  clipBehavior: Clip.none,
                  beforePopup: () => handleKeepFocus(true, 'task'),
                  afterPopup: () => handleKeepFocus(false, 'task'),
                  hideShadow: true,
                  enabled: !keepFocus,
                  closeOnTapWhenDisabled: true,
                  popup: SimpleTaskOrEventSwithcerWidget(
                    tabType: widget.tabType,
                    isEvent: false,
                    startDate: DateTime(
                      DateTime.now().year,
                      DateTime.now().month,
                      DateTime.now().day,
                      DateTime.now().hour,
                      (DateTime.now().minute ~/ 15 + 1) * 15,
                    ),
                    endDate: DateTime(
                      DateTime.now().year,
                      DateTime.now().month,
                      DateTime.now().day,
                      DateTime.now().hour,
                      (DateTime.now().minute ~/ 15 + 1) * 15,
                    ).add(Duration(minutes: user.userTaskDefaultDurationInMinutes)),
                    isAllDay: true,
                    selectedDate: DateUtils.dateOnly(DateTime.now()),
                    titleHintText: widget.message.toSnippet(channel: widget.channel, channels: channels, members: widget.members, groups: widget.groups),
                    originalTaskMessage: LinkedMessageEntity(
                      teamId: widget.channel.teamId,
                      channelId: widget.channel.id,
                      userId: widget.message.userId ?? '',
                      messageId: widget.message.id!,
                      threadId: widget.message.threadId ?? '',
                      userName: sender.displayName!,
                      channelName: widget.channel.displayName,
                      type: widget.message.type,
                      date: widget.message.createdAt ?? DateTime.now(),
                      link: widget.message.link,
                      pageToken: widget.message.pageToken,
                      isDm: widget.channel.isDm,
                      isChannel: widget.channel.isChannel,
                      isGroupDm: widget.channel.isGroupDm,
                      isUserTagged: widget.message.isUserTagged(userId: widget.channel.meId, groups: widget.groups),
                      isMe: widget.message.userId == widget.channel.meId,
                    ),
                    calendarTaskEditSourceType: CalendarTaskEditSourceType.message,
                  ),
                  style: VisirButtonStyle(
                    borderRadius: BorderRadius.circular(4),
                    padding: EdgeInsets.all(6),
                    backgroundColor: isShowcaseOn.value != null ? _tourHighlightAnimation.value : Colors.transparent,
                  ),
                  options: VisirButtonOptions(
                    tabType: widget.tabType,
                    bypassTextField: true,
                    shortcuts: [
                      VisirButtonKeyboardShortcut(
                        keys: [LogicalKeyboardKey.keyT, if (PlatformX.isApple) LogicalKeyboardKey.meta, if (!PlatformX.isApple) LogicalKeyboardKey.control],
                        message: context.tr.mail_detail_tooltip_task,
                      ),
                    ],
                  ),
                  child: VisirIcon(type: VisirIconType.task, size: 16, isSelected: true),
                );
              },
            ),
            VisirButton(
              type: VisirButtonAnimationType.scaleAndOpacity,
              style: VisirButtonStyle(
                borderRadius: BorderRadius.circular(4),
                padding: EdgeInsets.all(6),
              ),
              options: VisirButtonOptions(
                tabType: widget.tabType,
                bypassTextField: true,
                shortcuts: [
                  VisirButtonKeyboardShortcut(
                    keys: [LogicalKeyboardKey.keyL, if (PlatformX.isApple) LogicalKeyboardKey.meta, if (!PlatformX.isApple) LogicalKeyboardKey.control],
                    message: '',
                    onTrigger: () {
                      startChat();
                      return true;
                    },
                  ),
                ],
              ),
              onTap: startChat,
              child: VisirIcon(type: VisirIconType.at, size: 16, isSelected: true),
            ),
            if (widget.message.isMyMessage(channel: widget.channel))
              PopupMenu(
                forcePopup: true,
                location: PopupMenuLocation.bottom,
                width: 128,
                type: ContextMenuActionType.tap,
                borderRadius: 6,
                enabled: !keepFocus,
                closeOnTapWhenDisabled: true,
                beforePopup: () => handleKeepFocus(true, 'more'),
                afterPopup: () => handleKeepFocus(false, 'more'),
                popup: SelectionWidget<MessageActionType?>(
                  current: null,
                  getTitle: (item) => item?.getTitle(context) ?? '',
                  cellHeight: 36,
                  onSelect: (item) async {
                    switch (item) {
                      case MessageActionType.delete:
                        if (widget.parentMessage == null) {
                          MessageAction.deleteMessage(tabType: widget.tabType, message: widget.message, channel: widget.channel);
                        } else {
                          MessageAction.deleteReply(tabType: widget.tabType, message: widget.message, channel: widget.channel, parent: widget.parentMessage!);
                        }
                      case MessageActionType.edit:
                        widget.onEdit.call();
                        break;
                      case null:
                        break;
                    }
                  },
                  getTitleColor: (item) => item?.getTitleColor(context) ?? context.outlineVariant,
                  items: MessageActionType.values,
                ),
                style: VisirButtonStyle(borderRadius: BorderRadius.circular(4), padding: EdgeInsets.all(6)),
                options: VisirButtonOptions(
                  tabType: widget.tabType,
                  bypassTextField: true,
                  shortcuts: [
                    VisirButtonKeyboardShortcut(
                      keys: [LogicalKeyboardKey.keyE, if (PlatformX.isApple) LogicalKeyboardKey.meta, if (!PlatformX.isApple) LogicalKeyboardKey.control],
                      message: MessageActionType.edit.getTitle(context),
                      onTrigger: () {
                        widget.onEdit.call();
                        return true;
                      },
                    ),
                    VisirButtonKeyboardShortcut(
                      keys: [LogicalKeyboardKey.keyD, if (PlatformX.isApple) LogicalKeyboardKey.meta, if (!PlatformX.isApple) LogicalKeyboardKey.control],
                      message: MessageActionType.delete.getTitle(context),
                      onTrigger: () {
                        if (widget.parentMessage == null) {
                          MessageAction.deleteMessage(tabType: widget.tabType, message: widget.message, channel: widget.channel);
                        } else {
                          MessageAction.deleteReply(tabType: widget.tabType, message: widget.message, channel: widget.channel, parent: widget.parentMessage!);
                        }
                        return true;
                      },
                    ),
                  ],
                ),
                child: VisirIcon(type: VisirIconType.more, size: 16, isSelected: true),
              ),
          ],
        ),
      ),
    );
  }
}
