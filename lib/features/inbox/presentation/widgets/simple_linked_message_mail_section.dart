import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/contextmenu/contextmenu.dart';
import 'package:Visir/dependency/showcase_tutorial/src/enum.dart';
import 'package:Visir/features/chat/application/chat_channel_list_controller.dart';
import 'package:Visir/features/chat/domain/entities/message_entity.dart';
import 'package:Visir/features/chat/presentation/screens/chat_list_screen.dart';
import 'package:Visir/features/chat/providers.dart';
import 'package:Visir/features/common/domain/entities/linked_item_entity.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/log_event.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/presentation/widgets/showcase_wrapper.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_empty_widget.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/inbox/providers.dart';
import 'package:Visir/features/mail/domain/entities/mail_entity.dart';
import 'package:Visir/features/mail/domain/entities/mail_label_entity.dart';
import 'package:Visir/features/mail/presentation/screens/mail_detail_screen.dart';
import 'package:Visir/features/mail/providers.dart';
import 'package:Visir/features/preference/presentation/screens/preference_screen.dart';
import 'package:Visir/features/time_saved/actions.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SimpleLinkedMessageMailSection extends ConsumerStatefulWidget {
  final LinkedMessageEntity? originalTaskMessage;
  final LinkedMailEntity? originalTaskMail;
  final List<LinkedMessageEntity>? linkedMessages;
  final List<LinkedMailEntity>? linkedMails;
  final TabType tabType;
  final bool isEvent;

  const SimpleLinkedMessageMailSection({
    super.key,
    required this.originalTaskMessage,
    required this.originalTaskMail,
    required this.linkedMessages,
    required this.linkedMails,
    required this.tabType,
    required this.isEvent,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SimpleLinkedMessageMailSectionState();
}

class _SimpleLinkedMessageMailSectionState extends ConsumerState<SimpleLinkedMessageMailSection> with SingleTickerProviderStateMixin {
  late AnimationController _tourHighlightController;
  late Animation<Color?> _tourHighlightAnimation;

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

    _tourHighlightAnimation = ColorTween(begin: Utils.mainContext.primary.withValues(alpha: 0.25), end: Utils.mainContext.primary).animate(_tourHighlightController);

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

  void onShowcaseOnListener() {
    if (isShowcaseOn.value == taskLinkedMailDetailShowcaseKeyString) {
      showcaseButtonKey.currentState?.onTap();
    }

    if (isShowcaseOn.value == taskLinkedChatDetailShowcaseKeyString) {
      showcaseButtonKey.currentState?.onTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    final linkedMails = widget.linkedMails ?? [];
    final linkedMessages = widget.linkedMessages ?? [];
    final isAgentMode = ref.watch(currentInboxScreenTypeProvider) == InboxScreenType.agent;
    final usePopupMenu = true || (isAgentMode && widget.tabType == TabType.home);

    return Column(
      children: [
        if (widget.originalTaskMail != null)
          Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 11),
            child: Row(
              children: [
                Padding(padding: const EdgeInsets.only(right: 10), child: Image.asset(widget.originalTaskMail?.type.icon ?? '', width: 14, height: 14)),
                Expanded(
                  child: Text(widget.originalTaskMail?.fromName ?? '', style: context.bodyLarge?.copyWith(color: context.outlineVariant), maxLines: 1),
                ),
                SizedBox(height: 26),
              ],
            ),
          ),
        ...linkedMails.map((m) {
          return Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 11),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(padding: const EdgeInsets.only(right: 10), child: Image.asset(m.type.icon, width: 14, height: 14)),
                Expanded(
                  child: Text(m.fromName, style: context.bodyLarge?.copyWith(color: context.outlineVariant), maxLines: 1),
                ),
                SizedBox(width: 4),
                AnimatedBuilder(
                  animation: _tourHighlightAnimation,
                  builder: (context, child) {
                    if (usePopupMenu) {
                      return PopupMenu(
                        key: showcaseButtonKey,
                        type: ContextMenuActionType.tap,
                        location: PopupMenuLocation.right,
                        width: Utils.linkedPopupSize.width,
                        height: Utils.linkedPopupSize.height,
                        scrollPhysics: NeverScrollableScrollPhysics(),
                        beforePopup: () {
                          ref
                              .read(mailConditionProvider(widget.tabType).notifier)
                              .openThread(label: CommonMailLabels.inbox.id, email: null, threadId: m.threadId, threadEmail: m.hostMail, type: m.type);
                          mailViewportSyncVisibleNotifier[widget.tabType]!.value = false;
                        },
                        onPopup: () {
                          mailViewportSyncVisibleNotifier[widget.tabType]!.value = true;
                        },
                        afterPopup: () {
                          mailViewportSyncVisibleNotifier[widget.tabType]!.value = false;
                        },
                        popup: Container(
                          width: Utils.linkedPopupSize.width,
                          height: Utils.linkedPopupSize.height,
                          child: ShowcaseWrapper(
                            showcaseKey: isShowcaseOn.value != null ? taskLinkedMailDetailShowcaseKeyString : null,
                            tooltipPosition: TooltipPosition.top,
                            child: MailDetailScreen(tabType: widget.tabType, taskMail: m, anchorMailId: m.messageId, close: Navigator.of(context).pop),
                          ),
                        ),
                        style: VisirButtonStyle(
                          padding: EdgeInsets.all(5),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: context.surfaceTint, width: 1),
                        ),
                        options: VisirButtonOptions(tabType: widget.tabType, message: context.tr.quick_view),
                        child: VisirIcon(type: VisirIconType.show, size: 14, isSelected: true),
                      );
                    }
                    return VisirButton(
                      key: showcaseButtonKey,
                      type: VisirButtonAnimationType.scaleAndOpacity,
                      style: VisirButtonStyle(
                        padding: EdgeInsets.all(5),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: context.surfaceTint, width: 1),
                      ),
                      options: VisirButtonOptions(tabType: widget.tabType, message: context.tr.quick_view),
                      child: VisirIcon(type: VisirIconType.show, size: 14, isSelected: true),
                      onTap: () async {
                        await Navigator.of(Utils.mainContext).maybePop();
                        ref
                            .read(mailConditionProvider(widget.tabType).notifier)
                            .openThread(label: CommonMailLabels.inbox.id, email: null, threadId: m.threadId, threadEmail: m.hostMail, type: m.type);
                        mailViewportSyncVisibleNotifier[widget.tabType]!.value = true;
                        ref
                            .read(resizableClosableWidgetProvider(widget.tabType).notifier)
                            .setWidget(
                              ResizableWidget(
                                widget: ShowcaseWrapper(
                                  showcaseKey: isShowcaseOn.value != null ? taskLinkedMailDetailShowcaseKeyString : null,
                                  tooltipPosition: TooltipPosition.top,
                                  child: MailDetailScreen(
                                    tabType: widget.tabType,
                                    taskMail: m,
                                    anchorMailId: m.messageId,
                                    close: () {
                                      mailViewportSyncVisibleNotifier[widget.tabType]!.value = false;
                                      Utils.ref.read(resizableClosableWidgetProvider(widget.tabType).notifier).setWidget(null);
                                    },
                                  ),
                                ),
                                minWidth: 320,
                              ),
                            );
                      },
                    );
                  },
                ),
                SizedBox(width: 4),
                VisirButton(
                  type: VisirButtonAnimationType.scaleAndOpacity,
                  style: VisirButtonStyle(
                    cursor: SystemMouseCursors.click,
                    padding: EdgeInsets.all(5),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: context.surfaceTint, width: 1),
                  ),
                  onTap: () {
                    Utils.launchUrlExternal(url: m.link);
                    UserActionSwtichAction.onOpenMail(mailHost: m.hostMail);
                    logAnalyticsEvent(eventName: 'home_${widget.isEvent ? 'event' : 'task'}_${m.type.title}_app_open');
                  },
                  options: VisirButtonOptions(tabType: widget.tabType, doNotConvertCase: true, message: context.tr.open_in(m.type.title)),
                  child: Image.asset(m.type.icon, width: 14, height: 14),
                ),
              ],
            ),
          );
        }),
        if (widget.originalTaskMessage != null)
          Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 11),
            child: Row(
              children: [
                Padding(padding: const EdgeInsets.only(right: 10), child: Image.asset(widget.originalTaskMessage?.type.icon ?? '', width: 14, height: 14)),
                Expanded(
                  child: Text(widget.originalTaskMessage?.channelName ?? '', style: context.bodyLarge?.copyWith(color: context.outlineVariant), maxLines: 1),
                ),
                SizedBox(height: 26),
              ],
            ),
          ),
        ...linkedMessages.map((m) {
          return Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 11),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(padding: const EdgeInsets.only(right: 10), child: Image.asset(m.type.icon, width: 14, height: 14)),
                Expanded(
                  child: Text('${m.userName} - ${m.channelName}', style: context.bodyLarge?.copyWith(color: context.outlineVariant), maxLines: 1),
                ),
                SizedBox(width: 4),
                AnimatedBuilder(
                  animation: _tourHighlightAnimation,
                  builder: (context, child) {
                    if (usePopupMenu) {
                      return PopupMenu(
                        key: showcaseButtonKey,
                        type: ContextMenuActionType.tap,
                        location: PopupMenuLocation.right,
                        width: Utils.linkedPopupSize.width,
                        height: Utils.linkedPopupSize.height,
                        scrollPhysics: NeverScrollableScrollPhysics(),
                        popup: Container(
                          width: Utils.linkedPopupSize.width,
                          height: Utils.linkedPopupSize.height,
                          child: ShowcaseWrapper(
                            tooltipPosition: TooltipPosition.top,
                            showcaseKey: isShowcaseOn.value != null ? taskLinkedChatDetailShowcaseKeyString : null,
                            child: Builder(
                              builder: (context) {
                                final channel = ref.read(chatChannelListControllerProvider.select((e) => e[m.teamId]?.channels.firstWhereOrNull((c) => c.id == m.channelId)));
                                if (channel != null) ref.read(chatConditionProvider(widget.tabType).notifier).setChannel(channel);
                                return ChatListScreen(tabType: widget.tabType, taskMessage: m, close: Navigator.of(context).pop);
                              },
                            ),
                          ),
                        ),
                        style: VisirButtonStyle(
                          padding: EdgeInsets.all(5),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: context.surfaceTint, width: 1),
                        ),
                        options: VisirButtonOptions(tabType: widget.tabType, message: context.tr.quick_view),
                        child: VisirIcon(type: VisirIconType.show, size: 14, isSelected: true),
                      );
                    }

                    return VisirButton(
                      key: showcaseButtonKey,
                      type: VisirButtonAnimationType.scaleAndOpacity,
                      style: VisirButtonStyle(
                        padding: EdgeInsets.all(5),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: context.surfaceTint, width: 1),
                      ),
                      options: VisirButtonOptions(tabType: widget.tabType, message: context.tr.quick_view),
                      child: VisirIcon(type: VisirIconType.show, size: 14, isSelected: true),
                      onTap: () async {
                        await Navigator.of(Utils.mainContext).maybePop();
                        final channel = ref.read(chatChannelListControllerProvider.select((e) => e[m.teamId]?.channels.firstWhereOrNull((c) => c.id == m.channelId)));
                        if (channel != null) ref.read(chatConditionProvider(widget.tabType).notifier).setChannel(channel);

                        ref
                            .read(resizableClosableWidgetProvider(widget.tabType).notifier)
                            .setWidget(
                              ResizableWidget(
                                widget: ShowcaseWrapper(
                                  tooltipPosition: TooltipPosition.top,
                                  showcaseKey: isShowcaseOn.value != null ? taskLinkedChatDetailShowcaseKeyString : null,
                                  child: ChatListScreen(
                                    tabType: widget.tabType,
                                    taskMessage: m,
                                    close: () {
                                      Utils.ref.read(resizableClosableWidgetProvider(widget.tabType).notifier).setWidget(null);
                                    },
                                  ),
                                ),
                                minWidth: 320,
                              ),
                            );
                      },
                    );
                  },
                ),
                SizedBox(width: 4),
                VisirButton(
                  type: VisirButtonAnimationType.scaleAndOpacity,
                  style: VisirButtonStyle(
                    cursor: SystemMouseCursors.click,
                    padding: EdgeInsets.all(5),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: context.surfaceTint, width: 1),
                  ),
                  options: VisirButtonOptions(tabType: widget.tabType, doNotConvertCase: true, message: context.tr.open_in(m.type.title)),
                  onTap: () {
                    Utils.launchUrlExternal(url: m.link);
                    UserActionSwtichAction.onOpenExternalMessageLink(teamId: m.teamId);
                    logAnalyticsEvent(eventName: 'home_${widget.isEvent ? 'event' : 'task'}_${m.type.title}_app_open');
                  },
                  child: Image.asset(m.type.icon, width: 14, height: 14),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
