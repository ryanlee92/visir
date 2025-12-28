import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/showcase_tutorial/src/enum.dart';
import 'package:Visir/features/chat/application/chat_channel_list_controller.dart';
import 'package:Visir/features/chat/domain/entities/message_entity.dart';
import 'package:Visir/features/chat/presentation/screens/chat_list_screen.dart';
import 'package:Visir/features/chat/providers.dart';
import 'package:Visir/features/common/domain/entities/linked_item_entity.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/log_event.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/showcase_wrapper.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/mail/domain/entities/mail_entity.dart';
import 'package:Visir/features/mail/domain/entities/mail_label_entity.dart';
import 'package:Visir/features/mail/presentation/screens/mail_detail_screen.dart';
import 'package:Visir/features/mail/providers.dart';
import 'package:Visir/features/time_saved/actions.dart';
import 'package:collection/collection.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MobileLinkedMessageMailSection extends ConsumerStatefulWidget {
  final LinkedMessageEntity? originalTaskMessage;
  final LinkedMailEntity? originalTaskMail;
  final List<LinkedMessageEntity>? linkedMessages;
  final List<LinkedMailEntity>? linkedMails;
  final Widget bodyDivider;
  final TabType tabType;
  final bool isEvent;

  const MobileLinkedMessageMailSection({
    super.key,
    required this.bodyDivider,
    required this.originalTaskMessage,
    required this.originalTaskMail,
    required this.linkedMessages,
    required this.linkedMails,
    required this.tabType,
    required this.isEvent,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MobileLinkedMessageSectionState();
}

class _MobileLinkedMessageSectionState extends ConsumerState<MobileLinkedMessageMailSection> with SingleTickerProviderStateMixin {
  late AnimationController _tourHighlightController;
  late Animation<Color?> _tourHighlightAnmiation;

  GlobalKey<VisirButtonState> showcaseButtonKey = GlobalKey();

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

    _tourHighlightAnmiation = ColorTween(
      begin: Utils.mainContext.primary.withValues(alpha: 0.25),
      end: Utils.mainContext.primary,
    ).animate(_tourHighlightController);

    isShowcaseOn.addListener(onShowcaseOnListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onShowcaseOnListener();
    });
  }

  @override
  void dispose() {
    _tourHighlightController.dispose();
    isShowcaseOn.removeListener(onShowcaseOnListener);
    super.dispose();
  }

  String? prevShowcaseKey;
  void onShowcaseOnListener() {
    if (isShowcaseOn.value == taskLinkedMailDetailShowcaseKeyString) {
      EasyThrottle.throttle('mobileLinkedMessageMailSection:showcaseMail', Duration(milliseconds: 3000), () {
        openMail();
      });
    }

    if (isShowcaseOn.value == taskLinkedChatDetailShowcaseKeyString) {
      EasyThrottle.throttle('mobileLinkedMessageMailSection:showcaseChat', Duration(milliseconds: 3000), () {
        openChat();
      });
    }
  }

  void openMail() {
    final linkedMail = widget.linkedMails?.firstOrNull;
    if (linkedMail == null) return;
    ref
        .read(mailConditionProvider(widget.tabType).notifier)
        .openThread(label: CommonMailLabels.inbox.id, email: null, threadId: linkedMail.threadId, threadEmail: linkedMail.hostMail, type: linkedMail.type);
    logAnalyticsEvent(eventName: 'home_${widget.isEvent ? 'event' : 'task'}_gmail_show');

    mailViewportSyncVisibleNotifier[widget.tabType]!.value = false;

    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => ShowcaseWrapper(
          showcaseKey: isShowcaseOn.value == taskLinkedMailDetailShowcaseKeyString ? taskLinkedMailDetailShowcaseKeyString : null,
          tooltipPosition: TooltipPosition.top,
          onBeforeShowcase: () async {
            await Future.delayed(Duration(milliseconds: 1000));
          },
          child: Material(
            child: MailDetailScreen(tabType: widget.tabType, taskMail: linkedMail, anchorMailId: linkedMail.messageId, close: Navigator.of(context).pop),
          ),
        ),
        settings: RouteSettings(name: 'mobile_linked_message_mail_section_mail_detail_screen'),
      ),
    );

    mailViewportSyncVisibleNotifier[widget.tabType]!.value = true;
  }

  void openChat() {
    final linkedMessage = widget.linkedMessages?.firstOrNull;
    if (linkedMessage == null) return;
    final channels = ref.read(chatChannelListControllerProvider.select((v) => v.values.expand((e) => e.channels).toList()));
    final channel = channels.firstWhereOrNull((e) => e.id == linkedMessage.channelId);
    if (channel == null) return;

    ref.read(chatConditionProvider(widget.tabType).notifier).setThreadAndChannel(linkedMessage.threadId, channel, targetMessageId: linkedMessage.messageId);

    logAnalyticsEvent(eventName: 'home_${widget.isEvent ? 'event' : 'task'}_slack_show');

    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => ShowcaseWrapper(
          showcaseKey: isShowcaseOn.value == taskLinkedChatDetailShowcaseKeyString ? taskLinkedChatDetailShowcaseKeyString : null,
          tooltipPosition: TooltipPosition.top,
          onBeforeShowcase: () async {
            await Future.delayed(Duration(milliseconds: 1000));
          },
          child: ChatListScreen(tabType: widget.tabType, taskMessage: linkedMessage, isFromMobileTaskEdit: true, close: Navigator.of(context).pop),
        ),
        settings: RouteSettings(name: 'mobile_linked_message_mail_section_chat_list_screen_detail'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final linkedMails = widget.linkedMails ?? [];
    final linkedMessages = widget.linkedMessages ?? [];

    return Column(
      children: [
        if (widget.originalTaskMessage != null)
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Image.asset(widget.originalTaskMessage?.type.icon ?? '', width: 20, height: 20),
                    const SizedBox(width: 12, height: 36),
                    Expanded(
                      child: Text(
                        widget.originalTaskMessage?.channelName ?? '',
                        style: context.titleMedium?.textColor(context.outlineVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              widget.bodyDivider,
            ],
          ),
        if (widget.originalTaskMail != null)
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Image.asset(widget.originalTaskMail?.type.icon ?? '', width: 20, height: 20),
                    const SizedBox(width: 12, height: 36),
                    Expanded(
                      child: Text(
                        widget.originalTaskMail?.fromName ?? '',
                        style: context.titleMedium?.textColor(context.outlineVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              widget.bodyDivider,
            ],
          ),
        Column(
          children: [
            ...linkedMessages.map((linkedMessage) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Image.asset(linkedMessage.type.icon, width: 20, height: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${linkedMessage.userName} - ${linkedMessage.channelName}',
                        style: context.titleMedium?.textColor(context.outlineVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _tourHighlightAnmiation,
                      builder: (context, child) {
                        return VisirButton(
                          key: showcaseButtonKey,
                          type: VisirButtonAnimationType.scaleAndOpacity,
                          style: VisirButtonStyle(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: context.surface, width: 1),
                            padding: EdgeInsets.symmetric(horizontal: 9, vertical: 9),
                            backgroundColor: isShowcaseOn.value != null ? _tourHighlightAnmiation.value : null,
                          ),
                          onTap: openChat,
                          child: VisirIcon(type: VisirIconType.show, size: 18, isSelected: true),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    VisirButton(
                      type: VisirButtonAnimationType.scaleAndOpacity,
                      style: VisirButtonStyle(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: context.surface, width: 1),
                        padding: EdgeInsets.symmetric(horizontal: 9, vertical: 9),
                      ),
                      onTap: () {
                        Utils.launchUrlExternal(url: linkedMessage.link);
                        UserActionSwtichAction.onOpenExternalMessageLink(teamId: linkedMessage.teamId);
                        logAnalyticsEvent(eventName: 'home_${widget.isEvent ? 'event' : 'task'}_slack_app_open');
                      },
                      child: Image.asset(linkedMessage.type.icon, width: 18, height: 18),
                    ),
                  ],
                ),
              );
            }),
            ...linkedMails.map((linkedMail) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Image.asset(linkedMail.type.icon, width: 20, height: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        linkedMail.fromName,
                        style: context.titleMedium?.textColor(context.outlineVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _tourHighlightAnmiation,
                      builder: (context, child) {
                        return VisirButton(
                          key: showcaseButtonKey,
                          type: VisirButtonAnimationType.scaleAndOpacity,
                          style: VisirButtonStyle(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: context.surface, width: 1),
                            padding: EdgeInsets.symmetric(horizontal: 9, vertical: 9),
                            backgroundColor: isShowcaseOn.value != null ? _tourHighlightAnmiation.value : null,
                          ),
                          onTap: openMail,
                          child: VisirIcon(type: VisirIconType.show, size: 18, isSelected: true),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    VisirButton(
                      type: VisirButtonAnimationType.scaleAndOpacity,
                      style: VisirButtonStyle(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: context.surface, width: 1),
                        padding: EdgeInsets.symmetric(horizontal: 9, vertical: 9),
                      ),
                      onTap: () {
                        Utils.launchUrlExternal(url: linkedMail.link);
                        UserActionSwtichAction.onOpenMail(mailHost: linkedMail.hostMail);
                        logAnalyticsEvent(eventName: 'home_${widget.isEvent ? 'event' : 'task'}_gmail_app_open');
                      },
                      child: Image.asset(linkedMail.type.icon, width: 18, height: 18),
                    ),
                  ],
                ),
              );
            }),
            if (linkedMessages.isNotEmpty || linkedMails.isNotEmpty) widget.bodyDivider,
          ],
        ),
      ],
    );
  }
}
