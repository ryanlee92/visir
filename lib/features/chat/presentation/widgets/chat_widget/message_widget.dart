import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/flutter_swipe_action_cell/lib/core/cell.dart';
import 'package:Visir/dependency/showcase_tutorial/src/layout_overlays.dart';
import 'package:Visir/dependency/toasty_box/model/toast_model.dart';
import 'package:Visir/features/calendar/presentation/widgets/calendar_simple_create_widget.dart';
import 'package:Visir/features/chat/actions.dart';
import 'package:Visir/features/chat/application/chat_channel_list_controller.dart';
import 'package:Visir/features/chat/application/chat_group_list_controller.dart';
import 'package:Visir/features/chat/application/chat_member_list_controller.dart';
import 'package:Visir/features/chat/domain/entities/message_channel_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_emoji_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_group_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_member_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_reaction_entity.dart';
import 'package:Visir/features/chat/presentation/widgets/chat_widget/message_reaction_button.dart';
import 'package:Visir/features/chat/presentation/widgets/message_action_options_widget.dart';
import 'package:Visir/features/chat/presentation/widgets/message_add_emoji_widget.dart';
import 'package:Visir/features/chat/presentation/widgets/message_audio_widget.dart';
import 'package:Visir/features/chat/presentation/widgets/message_file_widget.dart';
import 'package:Visir/features/chat/presentation/widgets/message_image_widget.dart';
import 'package:Visir/features/chat/presentation/widgets/message_user_tag_widget.dart';
import 'package:Visir/features/chat/presentation/widgets/message_video_widget.dart';
import 'package:Visir/features/common/domain/entities/linked_item_entity.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/color_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/bottom_dialog_option.dart';
import 'package:Visir/features/common/presentation/widgets/fixed_overlay_host.dart';
import 'package:Visir/features/common/presentation/widgets/proxy_network_image.dart';
import 'package:Visir/features/common/presentation/widgets/showcase_wrapper.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/common/provider.dart' hide TextScaler;
import 'package:Visir/features/inbox/domain/entities/inbox_config_entity.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_entity.dart';
import 'package:Visir/features/inbox/presentation/widgets/agent_input_field.dart';
import 'package:Visir/features/inbox/presentation/widgets/inbox_draggable.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/time_saved/actions.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:Visir/features/task/presentation/widgets/mobile_task_or_event_switcher_widget.dart';
import 'package:emoji_extension/emoji_extension.dart' hide Color;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shimmer_text/shimmer_text.dart';
import 'package:super_clipboard/super_clipboard.dart';

class MessageWidget extends ConsumerStatefulWidget {
  static ValueNotifier<String> selectedMessageIdNotifier = ValueNotifier('');

  final ScrollController scrollController;
  final MessageChannelEntity channel;
  final List<MessageChannelEntity> channels;
  final List<MessageMemberEntity> members;
  final List<MessageGroupEntity> groups;
  final List<MessageEmojiEntity> emojis;
  final MessageEntity message;
  final MessageEntity? parentMessage;
  final MessageEntity? prevMesasge;
  final MessageEntity? nextMessage;

  final Color? hoverBackgroundColor;
  final Color? backgroundColor;
  final TabType tabType;
  final void Function() openDetails;
  final DateTime? channelLastReadAt;
  final VoidCallback? onTap;
  final VoidCallback onEdit;

  final Future<void> Function({required String channelId})? moveToChannel;

  final void Function(MessageEntity chat)? onDragStart;
  final void Function(MessageEntity chat, Offset offset)? onDragUpdate;
  final void Function(MessageEntity chat)? onDragEnd;

  MessageWidget({
    Key? key,
    required this.scrollController,
    required this.channel,
    required this.channels,
    required this.members,
    required this.groups,
    required this.emojis,
    required this.message,
    required this.prevMesasge,
    required this.nextMessage,
    required this.tabType,
    this.hoverBackgroundColor,
    this.moveToChannel,
    this.parentMessage,
    this.backgroundColor,
    this.onTap,
    required this.openDetails,
    required this.channelLastReadAt,
    required this.onEdit,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
  }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MessageWidgetState();
}

class _MessageWidgetState extends ConsumerState<MessageWidget> with SingleTickerProviderStateMixin {
  double actionOptionsHeightStandard = 32;

  DateTime? _replyReadAt;

  bool get isReply => widget.parentMessage != null;

  bool get isMobileView => PlatformX.isMobileView;

  MessageMemberEntity? get sender => widget.members.firstWhereOrNull((e) => e.id == widget.message.userId);

  OverlayEntry? currentViewOverlayEntry;

  double get bottomMargin => isReply
      ? widget.nextMessage != null && widget.prevMesasge == null
            ? 16
            : 2
      : widget.prevMesasge == null
      ? isMobileView
            ? 16
            : 8
      : 2;

  String get overlayKey => widget.parentMessage == null ? '${widget.tabType.name}-message' : '${widget.tabType.name}-reply-list';

  bool forceShowOverlay = false;

  DateTime get replyReadAt {
    if (widget.message.replyReadAt != null && _replyReadAt != null) {
      if (widget.message.replyReadAt!.isAfter(_replyReadAt!)) return widget.message.replyReadAt!;
      return _replyReadAt!;
    }

    if (widget.message.replyReadAt != null) return widget.message.replyReadAt!;
    if (_replyReadAt != null) return _replyReadAt!;
    return DateTime.now();
  }

  late AnimationController _tourHighlightController;
  late Animation<Color?> _tourHighlightAnimation;

  @override
  void initState() {
    super.initState();
    _replyReadAt = widget.channelLastReadAt;

    _tourHighlightController = AnimationController(
      duration: const Duration(milliseconds: 500), // 한 번 깜빡이는 시간
      vsync: this,
    );

    if (isShowcaseOn.value != null) {
      _tourHighlightController.repeat(reverse: true);
    }

    _tourHighlightAnimation = ColorTween(
      begin: Utils.mainContext.primary.withValues(alpha: 0.0),
      end: Utils.mainContext.primary.withValues(alpha: 0.25),
    ).animate(_tourHighlightController);

    isShowcaseOn.addListener(onShowcaseOnListener);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      onShowcaseOnListener();
    });
  }

  @override
  void dispose() {
    isShowcaseOn.removeListener(onShowcaseOnListener);
    _tourHighlightController.stop();
    _tourHighlightController.dispose();
    super.dispose();
  }

  void onShowcaseOnListener() {
    if (widget.message.id == targetChatMessageId && isShowcaseOn.value == chatCreateTaskShowcaseKeyString) {
      if (PlatformX.isDesktopView) return;
      showMobileChatOption();
    }
  }

  void moveToChannel({required String? userId, required String? channelId}) {
    final channels = ref.read(chatChannelListControllerProvider.select((v) => v[widget.channel.teamId]?.availableChannelsAndDms ?? []));

    if (userId == null && channelId == null) return;

    String detailId = '';
    if (userId != null) {
      MessageMemberEntity? user = widget.members.where((e) => e.id == userId).firstOrNull;
      if (user == null) return;
      MessageChannelEntity? dmChannel = channels.where((c) => c.displayName == user.displayName).firstOrNull;
      if (dmChannel == null) return;
      detailId = dmChannel.id;
    } else if (channelId != null) {
      detailId = channelId;
    } else {
      return;
    }
    if (detailId == widget.channel.id) return;

    widget.moveToChannel?.call(channelId: detailId);
  }

  Widget richTextWithMouseCursor(List<InlineSpan> inlineSpans, TextStyle? style) {
    if (PlatformX.isDesktopView) {
      return ExtendGestureAreaConsumer(
        gesturePadding: EdgeInsets.zero,
        transparentHitTest: true,
        translate: Offset.zero,
        child: Text.rich(TextSpan(children: inlineSpans, style: style, mouseCursor: SystemMouseCursors.text)),
      );
    }

    return Text.rich(TextSpan(children: inlineSpans, style: style, mouseCursor: SystemMouseCursors.text));
  }

  Widget? htmlWidget;

  String? prevHtml;

  ThemeMode? prevTheme;

  Widget _buildMessageContent(List<MessageChannelEntity> channels, OAuthEntity? oauth, ThemeMode? theme) {
    TextStyle? defaultStyle = context.titleSmall?.textColor(context.outlineVariant);
    double defaultLineHeight = defaultStyle!.fontSize! * defaultStyle.height!;

    final html = widget.message.toHtml(channel: widget.channel, channels: channels, members: widget.members, groups: widget.groups, emojis: widget.emojis, forEdit: false);
    if (html.trim().isEmpty) return const SizedBox.shrink();

    if (htmlWidget != null && prevHtml == html && prevTheme == theme) {
      return htmlWidget!;
    }

    prevTheme = theme;
    prevHtml = html;

    htmlWidget = HtmlWidget(
      html,
      enableCaching: true,
      customStylesBuilder: (element) {
        final styles = element.attributes['style'];
        final styleMap = Map.fromEntries(
          styles
                  ?.split(';')
                  .map((e) {
                    final parts = e.split(':');
                    if (parts.length == 2) {
                      return MapEntry(parts[0].trim(), parts[1].trim());
                    }
                    return null;
                  })
                  .whereType<MapEntry<String, String>>()
                  .toList() ??
              <MapEntry<String, String>>[],
        );
        if (element.localName == 'pre') {
          return {...styleMap, 'background-color': context.surfaceVariant.toHex(), 'border-radius': '4px', 'padding': '8px 12px'};
        }

        if (element.localName == 'code') {
          return {...styleMap, 'background-color': context.surfaceVariant.toHex(), 'color': Colors.orange.toHex(), 'border-radius': '4px', 'padding': '2px'};
        }

        if (element.localName == 'ul' || element.localName == 'ol') {
          return {...styleMap, 'margin': '0px', 'padding-left': '18px'};
        }

        if (element.localName == 'li') {
          return {...styleMap, 'margin': '0px', 'padding': '0px'};
        }

        if (element.localName == 'blockquote') {
          return {...styleMap, 'margin': '0px', 'padding-left': '12px', 'border-left': '3px solid ${context.onInverseSurface.toHex()}'};
        }

        return null;
      },

      customWidgetBuilder: (element) {
        // TagExtension(
        //   tagsToExtend: {'blockquote'},
        //   builder: (extensionContext) {
        //     final element = extensionContext.element;
        //     if (element == null) return const SizedBox.shrink();
        //     return Container(
        //       margin: const EdgeInsets.symmetric(vertical: 2.0),
        //       decoration: BoxDecoration(
        //         border: Border(left: BorderSide(color: context.onBackground, width: 3)),
        //       ),
        //       child: Row(
        //         children: [
        //           Container(width: 21),
        //           Expanded(
        //             child: Text.rich(TextSpan(style: defaultStyle, children: extensionContext.inlineSpanChildren)),
        //           ),
        //         ],
        //       ),
        //     );
        //   },
        // ),
        if (element.localName == 'color') {
          return InlineCustomWidget(
            child: Text.rich(
              TextSpan(
                text: element.text,
                style: defaultStyle,
                children: [
                  WidgetSpan(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 1),
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 1, color: context.outline),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        color: ColorX.fromHex(element.text),
                      ),
                      width: defaultLineHeight - 4,
                      height: defaultLineHeight - 4,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (element.localName == 'a') {
          final url = element.attributes['href'];
          return InlineCustomWidget(
            child: IntrinsicWidth(
              child: VisirButton(
                style: VisirButtonStyle(alignment: Alignment.topLeft, cursor: WidgetStateMouseCursor.clickable, hoverColor: Colors.transparent),
                behavior: HitTestBehavior.opaque,
                type: VisirButtonAnimationType.scaleAndOpacity,
                onTap: () => Utils.launchUrlExternal(url: url ?? ''),
                builder: (isHover) =>
                    Text(element.text, style: defaultStyle.textColor(element.parent?.toString().contains('<html code>') == true ? Colors.orange : context.primary)),
              ),
            ),
          );
        } else if (element.localName == 'emoji') {
          final unicode = element.attributes['unicode'];
          final url = element.attributes['src'];
          final single = element.attributes['single'] == 'true';

          if (unicode != null && unicode != 'null') {
            final emoji = Emojis.getOneOrNull(unicode.toUpperCase())?.value;
            return InlineCustomWidget(
              child: Text(emoji ?? '', style: defaultStyle.copyWith(fontSize: defaultStyle.fontSize! * (single ? 2 : 1))),
            );
          } else {
            return InlineCustomWidget(
              child: ProxyNetworkImage(
                imageUrl: url ?? '',
                oauth: oauth,
                width: defaultLineHeight * (single ? 2 : 1),
                height: defaultLineHeight * (single ? 2 : 1),
                fit: BoxFit.cover,
                errorWidget: (context, url, object) => const SizedBox.shrink(),
              ),
            );
          }
        } else if (element.localName == 'img') {
          final src = element.attributes['src'];
          if (src == null) return const SizedBox.shrink();
          return InlineCustomWidget(
            child: MessageImageWidget(tabType: widget.tabType, imageFile: null, imageFiles: [], isFile: false, imageUrl: src, teamId: widget.channel.teamId, oauth: oauth),
          );
        } else if (element.localName == 'icon') {
          final src = element.attributes['src'];
          if (src == null) return const SizedBox.shrink();
          return InlineCustomWidget(
            child: Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: ProxyNetworkImage(imageUrl: src, width: defaultLineHeight, height: defaultLineHeight, fit: BoxFit.cover),
            ),
          );
        } else if (element.localName == 'serviceicon') {
          final src = element.attributes['src'];
          final text = element.attributes['text'];

          String footer = text ?? '';

          RegExp footerRegex = RegExp(r'<((?:https?:\/\/[^\s|>]+))\s*(?:\|([^>]*)\s*)?>');
          TextStyle? footerDefaultStyle = context.bodyMedium?.textColor(context.shadow);
          final matches = footerRegex.allMatches(footer);

          List<InlineSpan> spans = [];
          int lastMatchEnd = 0;
          Widget footerWidget;

          if (matches.isEmpty) {
            footerWidget = Text(footer, style: footerDefaultStyle);
          } else {
            for (final match in matches) {
              if (match.start > lastMatchEnd) {
                final substring = footer.substring(lastMatchEnd, match.start);
                spans.add(TextSpan(text: substring, style: defaultStyle, mouseCursor: SystemMouseCursors.text));
              }

              if (match.group(1) != null) {
                final url = match.group(1)!;
                final displayText = match.group(2) ?? match.group(1)!;

                spans.add(
                  WidgetSpan(
                    child: IntrinsicWidth(
                      child: VisirButton(
                        behavior: HitTestBehavior.opaque,
                        style: VisirButtonStyle(alignment: Alignment.topLeft, cursor: SystemMouseCursors.click, hoverColor: Colors.transparent),
                        type: VisirButtonAnimationType.scaleAndOpacity,
                        onTap: () => Utils.launchUrlExternal(url: url),
                        builder: (isHover) => Text(textScaler: TextScaler.noScaling, displayText, style: isHover ? footerDefaultStyle?.textUnderline : footerDefaultStyle),
                      ),
                    ),
                  ),
                );
              }

              lastMatchEnd = match.end;
            }
            // 마지막 매치 이후의 텍스트 처리
            if (lastMatchEnd < footer.length) {
              spans.add(TextSpan(text: footer.substring(lastMatchEnd), style: footerDefaultStyle, mouseCursor: SystemMouseCursors.text));
            }

            footerWidget = Text.rich(
              TextSpan(children: spans, style: defaultStyle, mouseCursor: SystemMouseCursors.text),
              style: footerDefaultStyle,
            );
          }

          return InlineCustomWidget(
            child: Row(
              children: [
                if (src != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: ProxyNetworkImage(imageUrl: src, width: defaultLineHeight, height: defaultLineHeight, fit: BoxFit.cover),
                  ),
                if (text != null) footerWidget,
              ],
            ),
          );
        } else if (element.localName == 'footericon') {
          final src = element.attributes['src'];
          final text = element.attributes['text'];

          String footer = text ?? '';

          RegExp footerRegex = RegExp(r'<((?:https?:\/\/[^\s|>]+))\s*(?:\|([^>]*)\s*)?>');
          TextStyle? footerDefaultStyle = context.bodyMedium?.textColor(context.shadow);
          final matches = footerRegex.allMatches(footer);

          List<InlineSpan> spans = [];
          int lastMatchEnd = 0;
          Widget footerWidget;

          if (matches.isEmpty) {
            footerWidget = Text(footer, style: footerDefaultStyle);
          } else {
            for (final match in matches) {
              if (match.start > lastMatchEnd) {
                final substring = footer.substring(lastMatchEnd, match.start);
                spans.add(TextSpan(text: substring, style: footerDefaultStyle, mouseCursor: SystemMouseCursors.text));
              }

              if (match.group(1) != null) {
                final url = match.group(1)!;
                final displayText = match.group(2) ?? match.group(1)!;

                spans.add(
                  WidgetSpan(
                    child: IntrinsicWidth(
                      child: VisirButton(
                        behavior: HitTestBehavior.opaque,
                        style: VisirButtonStyle(alignment: Alignment.topLeft, cursor: SystemMouseCursors.click, hoverColor: Colors.transparent),
                        type: VisirButtonAnimationType.scaleAndOpacity,
                        onTap: () => Utils.launchUrlExternal(url: url),
                        builder: (isHover) => Text(textScaler: TextScaler.noScaling, displayText, style: isHover ? footerDefaultStyle?.textUnderline : footerDefaultStyle),
                      ),
                    ),
                  ),
                );
              }

              lastMatchEnd = match.end;
            }
            // 마지막 매치 이후의 텍스트 처리
            if (lastMatchEnd < footer.length) {
              spans.add(TextSpan(text: footer.substring(lastMatchEnd), style: footerDefaultStyle, mouseCursor: SystemMouseCursors.text));
            }

            footerWidget = Text.rich(
              TextSpan(children: spans, style: footerDefaultStyle, mouseCursor: SystemMouseCursors.text),
              style: footerDefaultStyle,
            );
          }

          return InlineCustomWidget(
            child: Row(
              children: [
                if (src != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: ProxyNetworkImage(imageUrl: src, width: 10, height: 10, fit: BoxFit.cover),
                  ),
                if (text != null) footerWidget,
              ],
            ),
          );
        } else if (element.localName == 'span') {
          if (element.className.contains('user-mention')) {
            final memberId = element.attributes['data-user-id'];
            MessageMemberEntity? member = widget.members.where((m) => m.id == memberId).firstOrNull;
            if (member != null) {
              return InlineCustomWidget(
                child: MessageUserTagWidget(
                  text: element.text,
                  defaultStyle: defaultStyle.copyWith(decoration: TextDecoration.none),
                  isMe: false,
                  member: member,
                  moveTochannel: moveToChannel,
                ),
              );
            }

            final memberIsLoaded = ref.watch(chatMemberListControllerProvider(tabType: widget.tabType).select((v) => v.loadedMembers.contains(memberId)));
            return InlineCustomWidget(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(4.0)),
                child: memberIsLoaded
                    ? Text('Unknown user', style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer))
                    : SizedBox(
                        width: 60,
                        child: ShimmerText(
                          text: 'Loading...',
                          textSize: context.bodyMedium!.fontSize!,
                          textColor: context.surfaceVariant,
                          shiningColor: context.surface,
                          letterspacing: 0,
                        ),
                      ),
              ),
            );
          }

          if (element.className.contains('channel-mention')) {
            final channels = ref.read(chatChannelListControllerProvider.select((v) => v[widget.channel.teamId]?.channels ?? []));
            final channel = channels.firstWhereOrNull((e) => e.id == element.attributes['data-channel-id']);

            if (channel != null) {
              return InlineCustomWidget(
                child: IntrinsicWidth(
                  child: VisirButton(
                    style: VisirButtonStyle(alignment: Alignment.topLeft, cursor: WidgetStateMouseCursor.clickable),
                    behavior: HitTestBehavior.opaque,
                    type: VisirButtonAnimationType.scaleAndOpacity,
                    onTap: () => moveToChannel(userId: null, channelId: channel.id),
                    child: Text(element.text, style: defaultStyle.textColor(Colors.blue).copyWith(backgroundColor: Colors.blue.withValues(alpha: 0.2))),
                  ),
                ),
              );
            } else {
              return InlineCustomWidget(
                child: Text('Unknown channel', style: defaultStyle.textColor(Colors.blue).copyWith(backgroundColor: Colors.blue.withValues(alpha: 0.2))),
              );
            }
          }

          if (element.className.contains('usergroup-mention')) {
            MessageGroupEntity? group = widget.groups.firstWhereOrNull((m) => m.id == element.attributes['data-group-id']);
            if (group != null) {
              bool isMember = group.users?.contains(widget.channel.meId) ?? false;
              Color color = isMember ? Color(0xffffeb3b) : Colors.blue;
              return InlineCustomWidget(
                child: Text(element.text, style: defaultStyle.textColor(color).copyWith(backgroundColor: color.withValues(alpha: 0.2))),
              );
            } else {
              return InlineCustomWidget(
                child: Text('Unknown group', style: defaultStyle.textColor(Colors.blue).copyWith(backgroundColor: Colors.blue.withValues(alpha: 0.2))),
              );
            }
          }

          if (element.className.contains('broadcast-mention')) {
            return InlineCustomWidget(
              child: Text(element.text, style: defaultStyle.textColor(Color(0xffffeb3b)).copyWith(backgroundColor: Color(0xffffeb3b).withValues(alpha: 0.2))),
            );
          }
          return null;
        }

        return null;
      },
      renderMode: RenderMode.column,
      textStyle: defaultStyle,
    );
    return htmlWidget!;
  }

  double getRedBoxHeight(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    return box?.size.height ?? 32;
  }

  Color get actionButtonColor => Utils.mainContext.surfaceVariant;

  void showMobileChatOption() {
    Utils.showBottomDialog(
      title: TextSpan(text: context.tr.tab_chat),
      body: Column(
        children: [
          BottomDialogOption(
            icon: VisirIconType.emoji,
            title: context.tr.add_reaction,
            onTap: () {
              showModalBottomSheet(
                context: context,
                useRootNavigator: true,
                isScrollControlled: true,
                builder: (context) {
                  return Padding(
                    padding: MediaQuery.of(context).viewInsets,
                    child: MessageAddEmojiWidget(channel: widget.channel, message: widget.message, parentMessage: widget.parentMessage, tabType: widget.tabType, oauth: oauth),
                  );
                },
              );
            },
          ),
          if (!isReply) BottomDialogOption(icon: VisirIconType.thread, title: context.tr.reply_in_thread, onTap: widget.openDetails),
          ShowcaseWrapper(
            showcaseKey: widget.message.id == targetChatMessageId ? chatCreateTaskShowcaseKeyString : null,
            onBeforeShowcase: () async {
              await Future.delayed(Duration(milliseconds: 1000));
            },
            child: BottomDialogOption(
              icon: VisirIconType.task,
              title: context.tr.create_task,
              onTap: () {
                Utils.showPopupDialog(
                  child: MobileTaskOrEventSwitcherWidget(
                    isEvent: false,
                    isAllDay: true,
                    selectedDate: DateUtils.dateOnly(DateTime.now()),
                    startDate: DateUtils.dateOnly(DateTime.now()),
                    endDate: DateUtils.dateOnly(DateTime.now()),
                    tabType: widget.tabType,
                    titleHintText: widget.message.toSnippet(channel: widget.channel, channels: channels, members: widget.members, groups: widget.groups),
                    originalTaskMessage: LinkedMessageEntity(
                      teamId: widget.channel.teamId,
                      channelId: widget.channel.id,
                      userId: widget.message.userId ?? '',
                      messageId: widget.message.id!,
                      threadId: widget.message.threadId ?? '',
                      userName: sender?.displayName ?? widget.message.userId ?? 'Unknown User',
                      channelName: widget.channel.displayName,
                      type: widget.message.type,
                      date: widget.message.createdAt ?? DateTime.now(),
                      link: widget.message.link,
                      pageToken: widget.message.pageToken,
                      isDm: widget.channel.isDm,
                      isGroupDm: widget.channel.isGroupDm,
                      isChannel: widget.channel.isChannel,
                      isUserTagged: widget.message.isUserTagged(userId: widget.channel.meId, groups: widget.groups),
                      isMe: widget.message.userId == widget.channel.meId,
                    ),
                    calendarTaskEditSourceType: CalendarTaskEditSourceType.message,
                  ),
                );
              },
            ),
          ),
          BottomDialogOption(
            icon: VisirIconType.at,
            title: 'Start Chat',
            onTap: () {
              final channels = ref.read(chatChannelListControllerProvider.select((v) => v[widget.channel.teamId]?.channels ?? []));
              final sender = widget.members.firstWhereOrNull((e) => e.id == widget.message.userId);
              if (sender == null) return;
              
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
              Navigator.of(Utils.mainContext).maybePop();

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
            },
          ),
          BottomDialogOption(
            icon: VisirIconType.copy,
            title: context.tr.copy_message,
            onTap: () async {
              final clipboard = SystemClipboard.instance;
              if (clipboard == null) return;
              final item = DataWriterItem();
              item.add(Formats.plainText(widget.message.toSnippet(channel: widget.channel, channels: channels, members: widget.members, groups: widget.groups)));
              await clipboard.write([item]);
              Utils.showToast(
                ToastModel(
                  message: TextSpan(text: Utils.mainContext.tr.text_copied_to_clipboard),
                  buttons: [],
                ),
              );
            },
          ),
          if (widget.message.isMyMessage(channel: widget.channel)) BottomDialogOption(icon: VisirIconType.edit, title: context.tr.edit_message, onTap: widget.onEdit),
          if (widget.message.isMyMessage(channel: widget.channel))
            BottomDialogOption(
              icon: VisirIconType.trash,
              title: context.tr.delete_message,
              isWarning: true,
              onTap: () {
                if (widget.parentMessage == null) {
                  MessageAction.deleteMessage(tabType: widget.tabType, message: widget.message, channel: widget.channel);
                } else {
                  MessageAction.deleteReply(tabType: widget.tabType, message: widget.message, channel: widget.channel, parent: widget.parentMessage!);
                }
              },
            ),
        ],
      ),
    );
  }

  List<MessageChannelEntity> get channels => ref.read(chatChannelListControllerProvider.select((v) => v[widget.channel.teamId]?.channels ?? []));
  OAuthEntity? get oauth => ref.read(
    localPrefControllerProvider.select(
      (v) => v.value?.messengerOAuths?.where((e) => e.teamId == widget.channel.teamId && e.type == widget.channel.type.oAuthType).firstOrNull ?? null,
    ),
  );

  Widget buildDraggable({required Widget child, required MessageEntity chat}) {
    if (widget.tabType != TabType.chat) return child;
    final ratio = ref.watch(zoomRatioProvider);
    final feedbackWidget = Material(
      color: Colors.transparent,
      child: Opacity(
        opacity: 0.5,
        child: Container(
          constraints: BoxConstraints(maxWidth: 180),
          decoration: BoxDecoration(color: context.surface, borderRadius: BorderRadius.circular(6)),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Text(
            chat.toSnippet(
              channel: widget.channel,
              channels: channels,
              members: ref.read(chatMemberListControllerProvider(tabType: widget.tabType).select((v) => v.members)),
              groups: ref.read(chatGroupListControllerProvider(tabType: widget.tabType).select((v) => v.groups)),
            ),
            style: context.bodyLarge?.textColor(context.onBackground),
          ),
        ),
      ),
    );

    return InboxLongPressDraggable(
      scaleFactor: ratio,
      dragAnchorStrategy: (InboxDraggable<Object> d, BuildContext context, Offset point) {
        return Offset(d.feedbackOffset.dx, d.feedbackOffset.dy);
      },
      onDragStarted: () => widget.onDragStart?.call(chat),
      onDragUpdate: (details) => widget.onDragUpdate?.call(chat, details.globalPosition / ratio),
      onDragEnd: (details) => widget.onDragEnd?.call(chat),
      hitTestBehavior: HitTestBehavior.opaque,
      feedback: feedbackWidget,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    List<MessageReactionEntity> reactions = widget.message.reactions;

    final hideProfile =
        widget.nextMessage?.createdAt != null &&
        widget.message.createdAt != null &&
        widget.message.replyCount == 0 &&
        DateUtils.isSameDay(widget.nextMessage!.createdAt!, widget.message.createdAt!) &&
        widget.nextMessage!.createdAt!.difference(widget.message.createdAt!).inMinutes.abs() < 5 &&
        widget.nextMessage!.userId == widget.message.userId;

    final isTextOnly =
        widget.message.imageFiles.isEmpty &&
        widget.message.videoFiles.isEmpty &&
        widget.message.extraFiles.isEmpty &&
        widget.message.audioFiles.isEmpty &&
        reactions.isEmpty &&
        (isReply || widget.message.replyCount == 0);

    final team = ref
        .read(
          localPrefControllerProvider.select(
            (v) => v.value?.messengerOAuths?.where((e) => e.teamId == widget.channel.teamId && e.type == widget.channel.type.oAuthType).firstOrNull ?? null,
          ),
        )
        ?.team;

    final theme = ref.watch(themeSwitchProvider);
    final senderIsLoaded = ref.watch(chatMemberListControllerProvider(tabType: widget.tabType).select((v) => v.loadedMembers.contains(widget.message.userId)));

    return SwipeActionCell(
      isDraggable: PlatformX.isMobileView,
      key: ObjectKey(widget.message.id),
      backgroundColor: Colors.transparent,
      editModeOffset: 40,
      leadingActions: [
        SwipeAction(
          performsFirstActionWithFullSwipe: true,
          icon: Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: context.surface),
            child: VisirIcon(type: VisirIconType.more, size: 16, color: context.onSurface, isSelected: true),
          ),
          widthSpace: 100,
          onTap: (CompletionHandler handler) {
            showMobileChatOption();
            handler(false);
          },
          color: Colors.transparent,
        ),
      ],
      trailingActions: [
        SwipeAction(
          performsFirstActionWithFullSwipe: true,
          icon: Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: context.surface),
            child: VisirIcon(type: VisirIconType.thread, size: 16, color: context.onSurface, isSelected: true),
          ),
          widthSpace: 100,
          onTap: (CompletionHandler handler) {
            widget.openDetails();
            handler(false);
          },
          color: Colors.transparent,
        ),
      ],
      child: buildDraggable(
        chat: widget.message,
        child: RepaintBoundary(
          child: ValueListenableBuilder(
            valueListenable: MessageWidget.selectedMessageIdNotifier,
            builder: (context, selectedMessageId, child) {
              final result = VisirButton(
                style: VisirButtonStyle(
                  alignment: Alignment.topLeft,
                  backgroundColor: (widget.message.id == targetChatMessageId && isShowcaseOn.value == chatCreateTaskShowcaseKeyString)
                      ? _tourHighlightAnimation.value
                      : widget.backgroundColor,
                  selectedColor: context.outlineVariant.withValues(alpha: 0.05),
                  margin: EdgeInsets.only(bottom: bottomMargin, left: 8, right: 8),
                  padding: EdgeInsets.only(left: 8, right: 8, top: hideProfile ? 1 : 7, bottom: isTextOnly || hideProfile ? 5 : 7),
                  borderRadius: BorderRadius.circular(6),
                  cursor: SystemMouseCursors.basic,
                ),
                isSelected: selectedMessageId == widget.message.id,
                behavior: HitTestBehavior.deferToChild,
                type: VisirButtonAnimationType.opacity,
                onTap: FocusScope.of(context).unfocus,
                onEnter: (event) {
                  if (MessageWidget.selectedMessageIdNotifier.value == widget.message.id) return;
                  if (isShowcaseOn.value != null) return;
                  MessageWidget.selectedMessageIdNotifier.value = widget.message.id ?? '';
                  return;
                },
                builder: (isHover) {
                  isHover = isHover && !isMobileView;
                  final imageSize = context.textScaler.scale((context.titleSmall!.fontSize! * context.titleSmall!.height!) * 2);
                  return Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Transform.translate(
                                        offset: Offset(0, context.textScaler.scale(1)),
                                        child: Container(
                                          width: imageSize,
                                          height: hideProfile ? null : imageSize,
                                          margin: const EdgeInsets.only(right: 8),
                                          alignment: Alignment.centerRight,
                                          child: hideProfile
                                              ? Padding(
                                                  padding: const EdgeInsets.only(top: 6),
                                                  child: Text.rich(
                                                    TextSpan(
                                                      text: isHover ? DateFormat('HH:mm').format(widget.message.createdAt!) : '',
                                                      style: context.bodySmall?.textColor(context.surfaceTint),
                                                    ),
                                                  ),
                                                )
                                              : IntrinsicWidth(
                                                  child: VisirButton(
                                                    style: VisirButtonStyle(
                                                      alignment: Alignment.topLeft,
                                                      borderRadius: BorderRadius.circular(8),
                                                      backgroundColor: context.surface,
                                                      width: imageSize,
                                                      height: imageSize,
                                                    ),
                                                    type: VisirButtonAnimationType.scaleAndOpacity,
                                                    behavior: HitTestBehavior.opaque,
                                                    onTap: sender == null ? null : () => moveToChannel(userId: sender!.id, channelId: null),
                                                    child: !senderIsLoaded
                                                        ? Shimmer.fromColors(
                                                            baseColor: context.surfaceVariant,
                                                            highlightColor: context.surface,
                                                            child: Container(decoration: BoxDecoration(color: context.outlineVariant)),
                                                          )
                                                        : sender == null && widget.message.userId?.startsWith('B') == true
                                                        ? ProxyNetworkImage(
                                                            imageUrl: team?.largeIconUrl ?? team?.smallIconUrl ?? '',
                                                            oauth: oauth,
                                                            fit: BoxFit.cover,
                                                            errorWidget: (context, url, object) {
                                                              return Image.asset(
                                                                '${(kDebugMode && PlatformX.isWeb) ? "" : "assets/"}place_holder/img_default_profile.png',
                                                                fit: BoxFit.cover,
                                                              );
                                                            },
                                                          )
                                                        : (sender?.profileImage ?? '').isEmpty
                                                        ? Image.asset('${(kDebugMode && PlatformX.isWeb) ? "" : "assets/"}place_holder/img_default_profile.png', fit: BoxFit.cover)
                                                        : ProxyNetworkImage(
                                                            imageUrl: sender?.profileImage ?? '',
                                                            oauth: oauth,
                                                            fit: BoxFit.cover,
                                                            errorWidget: (context, url, object) {
                                                              return Image.asset(
                                                                '${(kDebugMode && PlatformX.isWeb) ? "" : "assets/"}place_holder/img_default_profile.png',
                                                                fit: BoxFit.cover,
                                                              );
                                                            },
                                                          ),
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (!hideProfile)
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              IntrinsicWidth(
                                                child: VisirButton(
                                                  style: VisirButtonStyle(alignment: Alignment.topLeft, cursor: WidgetStateMouseCursor.clickable, hoverColor: Colors.transparent),
                                                  behavior: HitTestBehavior.opaque,
                                                  type: VisirButtonAnimationType.scaleAndOpacity,
                                                  onTap: sender == null ? null : () => moveToChannel(userId: sender!.id, channelId: null),
                                                  child: !senderIsLoaded
                                                      ? ShimmerText(
                                                          text: 'Loading...',
                                                          textSize: context.titleSmall!.fontSize!,
                                                          textColor: context.surfaceVariant,
                                                          shiningColor: context.surface,
                                                          letterspacing: 0,
                                                        )
                                                      : Text(
                                                          sender?.displayName ?? (sender == null && widget.message.isBotMessage ? 'Unknown Bot' : 'Unknown User'),
                                                          style: context.titleSmall?.textBold.textColor(context.outlineVariant),
                                                        ),
                                                ),
                                              ),
                                              if (sender?.isBot ?? widget.message.isBotMessage)
                                                Container(
                                                  margin: EdgeInsets.only(left: 4, bottom: 1),
                                                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                                  decoration: BoxDecoration(color: context.surface, borderRadius: BorderRadius.circular(3)),
                                                  child: Text(context.tr.chat_app, style: context.bodySmall?.textColor(context.shadow)),
                                                ),
                                              const SizedBox(width: 6),
                                              if (widget.message.createdAt != null)
                                                Padding(
                                                  padding: const EdgeInsets.only(bottom: 1),
                                                  child: Text(DateFormat('HH:mm').format(widget.message.createdAt!), style: context.bodyLarge?.textColor(context.onInverseSurface)),
                                                ),
                                            ],
                                          ),
                                        const SizedBox(height: 4),
                                        _buildMessageContent(channels, oauth, theme),
                                        if (widget.message.imageFiles.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 9),
                                            child: Builder(
                                              builder: (context) {
                                                return Wrap(
                                                  spacing: 6,
                                                  runSpacing: 6,
                                                  children: [
                                                    ...widget.message.imageFiles
                                                        .map(
                                                          (e) => MessageImageWidget(
                                                            tabType: widget.tabType,
                                                            imageFile: e,
                                                            imageFiles: widget.message.imageFiles,
                                                            isFile: true,
                                                            imageUrl: null,
                                                            teamId: widget.channel.teamId,
                                                            oauth: oauth,
                                                          ),
                                                        )
                                                        .toList(),
                                                  ],
                                                );
                                              },
                                            ),
                                          ),
                                        if (widget.message.videoFiles.isNotEmpty)
                                          ...widget.message.videoFiles
                                              .map(
                                                (e) => Padding(
                                                  padding: const EdgeInsets.only(top: 12),
                                                  child: MessageVideoWidget(tabType: widget.tabType, file: e, key: Key(e.id ?? ''), oauth: oauth),
                                                ),
                                              )
                                              .toList(),
                                        if (widget.message.extraFiles.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 12),
                                            child: Wrap(
                                              spacing: 12,
                                              runSpacing: 12,
                                              children: [...widget.message.extraFiles.map((e) => MessageFileWidget(file: e, oauth: oauth)).toList()],
                                            ),
                                          ),
                                        if (widget.message.audioFiles.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 12),
                                            child: Wrap(
                                              spacing: 12,
                                              runSpacing: 12,
                                              children: [...widget.message.audioFiles.map((e) => MessageAudioWidget(file: e, oauth: oauth)).toList()],
                                            ),
                                          ),
                                        if (reactions.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 8),
                                            child: Wrap(
                                              spacing: 4,
                                              runSpacing: 4,
                                              children: reactions
                                                  .map(
                                                    (reaction) => MessageReactionButton(
                                                      channel: widget.channel,
                                                      message: widget.message,
                                                      members: widget.members,
                                                      emojis: widget.emojis,
                                                      oauth: oauth,
                                                      parentMessage: widget.parentMessage,
                                                      reaction: reaction,
                                                      tabType: widget.tabType,
                                                      backgroundColor: actionButtonColor,
                                                    ),
                                                  )
                                                  .toList(),
                                            ),
                                          ),
                                        if (!isReply && widget.message.replyCount > 0)
                                          IntrinsicWidth(
                                            child: VisirButton(
                                              type: VisirButtonAnimationType.scaleAndOpacity,
                                              behavior: HitTestBehavior.opaque,
                                              style: VisirButtonStyle(
                                                alignment: Alignment.topLeft,
                                                margin: const EdgeInsets.only(top: 8),
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                                backgroundColor: actionButtonColor,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              onTap: () {
                                                widget.openDetails();
                                                setState(() {
                                                  _replyReadAt = DateTime.now();
                                                });
                                              },
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    '${widget.message.replyCount.toString()} ${context.tr.chat_replies}',
                                                    style: context.labelMedium?.textColor(context.outlineVariant),
                                                  ),
                                                  if (widget.message.latestReplyAtMiliSeconds?.isAfter(replyReadAt) ?? false)
                                                    Padding(
                                                      padding: EdgeInsets.only(left: 6),
                                                      child: Container(
                                                        width: 6,
                                                        height: 6,
                                                        decoration: ShapeDecoration(color: context.error, shape: OvalBorder()),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  );
                },
              );

              return AnimatedBuilder(
                animation: _tourHighlightAnimation,
                builder: (context, child) {
                  return AnchoredOverlay(
                    stackOffset: FixedOverlayHost.getStackOffset(overlayKey),
                    targetState: FixedOverlayHost.getOverlayKey(overlayKey),
                    showOverlay: (selectedMessageId == widget.message.id) && PlatformX.isDesktopView,
                    overlayBuilder: (context, rectBound, offset) {
                      if (widget.parentMessage != null && widget.parentMessage!.id == widget.message.id) return const SizedBox.shrink();
                      if (sender == null) return const SizedBox.shrink();
                      return Stack(
                        children: [
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Transform.translate(
                              offset: Offset(-12, -12),
                              child: MessageActionOptions(
                                message: widget.message,
                                parentMessage: widget.parentMessage,
                                onEdit: widget.onEdit,
                                openDetails: () {
                                  widget.openDetails.call();
                                  // _isMouseInOptions = false;
                                },
                                channel: widget.channel,
                                channels: channels,
                                members: widget.members,
                                groups: widget.groups,
                                emojis: widget.emojis,
                                backgroundColor: actionButtonColor,
                                tabType: widget.tabType,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                    child: result,
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
