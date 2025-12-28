import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/admin_scaffold/admin_scaffold.dart';
import 'package:Visir/features/chat/application/chat_channel_list_controller.dart';
import 'package:Visir/features/chat/application/chat_group_list_controller.dart';
import 'package:Visir/features/chat/application/chat_member_list_controller.dart';
import 'package:Visir/features/chat/domain/entities/message_channel_entity.dart';
import 'package:Visir/features/chat/presentation/screens/chat_list_screen.dart';
import 'package:Visir/features/chat/presentation/widgets/chat_sidebar.dart';
import 'package:Visir/features/chat/providers.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/date_time_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/desktop_scaffold.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/presentation/widgets/proxy_network_image.dart';
import 'package:Visir/features/common/presentation/widgets/visir_app_bar.dart';
import 'package:Visir/features/common/presentation/widgets/visir_empty_widget.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/common/presentation/widgets/visir_list_item.dart';
import 'package:Visir/features/common/presentation/widgets/visir_list_section.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_entity.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:Visir/features/preference/presentation/screens/preference_screen.dart';
import 'package:Visir/features/task/presentation/widgets/timeblock_drop_widget.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_resizable_container/flutter_resizable_container.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => ChatScreenState();
}

class ChatScreenState extends ConsumerState<ChatScreen> with AutomaticKeepAliveClientMixin {
  TabType get tabType => TabType.chat;

  GlobalKey<AdminScaffoldState> adminScaffoldKey = GlobalKey<AdminScaffoldState>();
  GlobalKey<ChatListScreenState> chatListScreenKey = GlobalKey<ChatListScreenState>();
  GlobalKey<TimeblockDropWidgetState> timeblockDropWidgetKey = GlobalKey<TimeblockDropWidgetState>();

  @override
  bool get wantKeepAlive => true;

  ChatSideBar? chatSideBar;

  @override
  void initState() {
    super.initState();

    isShowcaseOn.addListener(onShowcaseOnListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onShowcaseOnListener();
    });
  }

  @override
  void dispose() {
    isShowcaseOn.removeListener(onShowcaseOnListener);
    super.dispose();
  }

  void onShowcaseOnListener() {
    if (isShowcaseOn.value == chatTabShowcaseKeyString || isShowcaseOn.value == chatCreateTaskShowcaseKeyString) {
      final channel = ref.read(
        chatChannelListControllerProvider.select((e) => e.values.expand((e) => e.channels).firstWhereOrNull((c) => c.id == targetChatChannelId)),
      );
      if (channel == null) return;
      ref.read(chatConditionProvider(tabType).notifier).setChannel(channel);
      return;
    }
  }

  Widget _buildChannelWidget(MessageChannelEntity channel, List<OAuthEntity> integratedTeams, {bool isLastOpenedSection = false}) {
    final trailingOnNextLine = PlatformX.isMobileView;
    return VisirListItem(
      titleTrailingOnNextLine: trailingOnNextLine,
      titleLeadingBuilder: (height, style, subStyle, horizontalSpacing) {
        return TextSpan(
          children: [
            WidgetSpan(
              child: Builder(
                builder: (context) {
                  final oauth = integratedTeams.firstWhereOrNull((o) => o.teamId == channel.teamId);
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: ProxyNetworkImage(imageUrl: oauth!.team!.smallIconUrl!, width: height, height: height, oauth: oauth),
                  );
                },
              ),
            ),
          ],
        );
      },
      titleBuilder: (height, style, subStyle, horizontalSpacing) {
        return TextSpan(
          children: [
            TextSpan(text: '${channel.isChannel ? '#' : ''}${channel.displayName}', style: style),
            if (channel.hasUnreadMessage && trailingOnNextLine)
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: CircleAvatar(radius: 3, backgroundColor: context.primary),
                ),
              ),
          ],
        );
      },
      titleTrailingBuilder: (height, style, subStyle, horizontalSpacing) {
        return TextSpan(
          children: [
            if (channel.hasUnreadMessage && !trailingOnNextLine)
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: CircleAvatar(radius: 3, backgroundColor: context.primary),
                ),
              ),
            TextSpan(text: context.tr.updated_at(channel.lastUpdated.dateTimeString), style: style),
          ],
        );
      },
      onTap: () {
        Utils.ref.read(chatConditionProvider(tabType).notifier).setChannel(channel);
      },
    );
  }

  bool showTimeblockDropWidget = false;
  Offset dragOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final resizableClosableDrawer = ref.watch(resizableClosableDrawerProvider(tabType));
    final resizableClosableWidget = ref.watch(resizableClosableWidgetProvider(tabType));
    final channel = ref.watch(chatConditionProvider(tabType).select((v) => v.channel));

    chatSideBar ??= ChatSideBar(tabType: tabType);

    ref.listen(chatConditionProvider(tabType).select((e) => e.channel?.id), (previous, next) {
      chatListScreenKey = GlobalKey<ChatListScreenState>();
      setState(() {});
    });

    final channels = ref.watch(chatChannelListControllerProvider.select((v) => v.values.expand((e) => e.channels).toList()));
    final integratedTeams = ref.watch(localPrefControllerProvider.select((v) => v.value?.messengerOAuths?.where((e) => e.needReAuth != true).toList() ?? []));
    final chatLastChannelIds = ref.watch(chatLastChannelProvider(tabType));
    final chatLastChannels = chatLastChannelIds.map((e) => channels.firstWhereOrNull((e) => e.id == e)).whereType<MessageChannelEntity>().toList();
    final emptySuggestedChannels = (channels.where((e) => e.hasUnreadMessage).toList()..sort((b, a) => a.lastUpdated.compareTo(b.lastUpdated)))
        .take(5)
        .toList();
    final channelStateList = ref.watch(chatChannelStateListProvider(tabType));
    final pinnedChannels = channels.where((e) => channelStateList[e.uniqueId] == ChatChannelSection.pinned).toList()
      ..sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));

    final ratio = ref.watch(zoomRatioProvider);

    return Stack(
      children: [
        Positioned.fill(
          child: AdminScaffold(
            key: adminScaffoldKey,
            tabType: tabType,
            sideBar: chatSideBar!,
            body: ResizableContainer(
              direction: Axis.horizontal,
              children: [
                if (resizableClosableDrawer != null)
                  ResizableChild(
                    size: ResizableSize.expand(min: 120, max: 220),
                    child: DesktopCard(child: resizableClosableDrawer),
                    divider: ResizableDivider(thickness: DesktopScaffold.cardPadding, color: Colors.transparent),
                  ),
                ResizableChild(
                  size: ResizableSize.expand(),
                  child: channel == null
                      ? DesktopCard(
                          child: Column(
                            children: [
                              if (resizableClosableDrawer == null)
                                Container(
                                  height: VisirAppBar.height,
                                  child: Row(
                                    children: [
                                      SizedBox(width: 6),
                                      VisirAppBarButton(
                                        icon: VisirIconType.control,
                                        onTap: () {
                                          adminScaffoldKey.currentState?.toggleSidebar();
                                        },
                                      ).getButton(context: context),
                                    ],
                                  ),
                                ),
                              Expanded(
                                child: Container(
                                  child:
                                      (chatLastChannels.isEmpty && emptySuggestedChannels.isEmpty && pinnedChannels.isEmpty) || resizableClosableDrawer != null
                                      ? VisirEmptyWidget(
                                          message: integratedTeams.isEmpty ? context.tr.no_chat_provider_integrated : context.tr.no_channel_selected,
                                          buttonText: integratedTeams.isEmpty ? context.tr.chat_integrate_chat_button : null,
                                          buttonIcon: VisirIconType.integration,
                                          secondaryButtonText: integratedTeams.isEmpty ? context.tr.hide_tab : null,
                                          onSecondaryButtonTap: integratedTeams.isEmpty
                                              ? () {
                                                  ref.read(tabHiddenProvider(tabType).notifier).update(tabType, true);
                                                  if (tabNotifier.value == tabType) tabNotifier.value = TabType.home;
                                                }
                                              : null,
                                          onButtonTap: () {
                                            Utils.showPopupDialog(
                                              child: PreferenceScreen(
                                                key: Utils.preferenceScreenKey,
                                                initialPreferenceScreenType: PreferenceScreenType.integration,
                                              ),
                                              size: PlatformX.isMobileView ? null : Size(640, 560),
                                            );
                                          },
                                        )
                                      : SingleChildScrollView(
                                          child: Column(
                                            mainAxisAlignment: (chatLastChannels.isNotEmpty || emptySuggestedChannels.isNotEmpty) && PlatformX.isMobileView
                                                ? MainAxisAlignment.start
                                                : MainAxisAlignment.center,
                                            children: [
                                              if (chatLastChannels.isNotEmpty)
                                                VisirListSection(
                                                  removeTopMargin: true,
                                                  titleBuilder: (height, style, subStyle, horizontalSpacing) {
                                                    return TextSpan(
                                                      children: [TextSpan(text: context.tr.last_opened_channel, style: style)],
                                                    );
                                                  },
                                                ),
                                              if (chatLastChannels.isNotEmpty)
                                                ...chatLastChannels.map((e) => _buildChannelWidget(e, integratedTeams, isLastOpenedSection: true)),

                                              if (pinnedChannels.isNotEmpty)
                                                VisirListSection(
                                                  removeTopMargin: chatLastChannels.isNotEmpty,
                                                  titleBuilder: (height, style, subStyle, horizontalSpacing) {
                                                    return TextSpan(
                                                      children: [TextSpan(text: context.tr.mail_label_pinned, style: style)],
                                                    );
                                                  },
                                                ),
                                              if (pinnedChannels.isNotEmpty) ...pinnedChannels.map((e) => _buildChannelWidget(e, integratedTeams)),
                                              if (emptySuggestedChannels.isNotEmpty)
                                                VisirListSection(
                                                  removeTopMargin: chatLastChannels.isNotEmpty,
                                                  titleBuilder: (height, style, subStyle, horizontalSpacing) {
                                                    return TextSpan(
                                                      children: [TextSpan(text: context.tr.suggested_unread_channels, style: style)],
                                                    );
                                                  },
                                                ),
                                              if (emptySuggestedChannels.isNotEmpty)
                                                ...emptySuggestedChannels.map((e) => _buildChannelWidget(e, integratedTeams)),
                                            ],
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: context.background,
                        )
                      : DesktopCard(
                          child: ChatListScreen(
                            key: chatListScreenKey,
                            tabType: tabType,
                            oAuthType: channel.type.oAuthType,
                            onControl: () {
                              adminScaffoldKey.currentState?.toggleSidebar();
                            },
                            close: () {
                              Utils.ref.read(chatConditionProvider(tabType).notifier).clear();
                            },
                            onDragStart: (chat) {
                              showTimeblockDropWidget = true;
                              setState(() {});
                            },
                            onDragEnd: (chat) {
                              final members = ref.read(chatMemberListControllerProvider(tabType: tabType)).members;
                              final groups = ref.read(chatGroupListControllerProvider(tabType: tabType)).groups;
                              final sender = members.firstWhereOrNull((e) => e.id == chat.userId);
                              if (sender == null) return;
                              timeblockDropWidgetKey.currentState
                                  ?.onInboxDragEnd(InboxEntity.fromChat(chat, null, channel, sender, channels, members, groups), dragOffset)
                                  .then((_) {
                                    showTimeblockDropWidget = false;
                                    setState(() {});
                                  })
                                  .catchError((e) {
                                    showTimeblockDropWidget = false;
                                    setState(() {});
                                  });
                            },
                            onDragUpdate: (chat, offset) {
                              dragOffset = offset;

                              final members = ref.read(chatMemberListControllerProvider(tabType: tabType)).members;
                              final groups = ref.read(chatGroupListControllerProvider(tabType: tabType)).groups;
                              final sender = members.firstWhereOrNull((e) => e.id == chat.userId);
                              if (sender == null) return;
                              timeblockDropWidgetKey.currentState?.onInboxDragUpdate(
                                InboxEntity.fromChat(chat, null, channel, sender, channels, members, groups),
                                offset,
                              );
                            },
                          ),
                        ),
                  divider: ResizableDivider(thickness: resizableClosableWidget != null ? DesktopScaffold.cardPadding : 1, color: Colors.transparent),
                ),
                if (resizableClosableWidget != null)
                  ResizableChild(
                    size: ResizableSize.expand(),
                    child: DesktopCard(child: resizableClosableWidget.widget!),
                  ),
              ],
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
    );
  }
}
