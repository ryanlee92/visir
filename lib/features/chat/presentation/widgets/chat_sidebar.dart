import 'package:Visir/dependency/admin_scaffold/admin_scaffold.dart';
import 'package:Visir/features/chat/application/chat_channel_list_controller.dart';
import 'package:Visir/features/chat/domain/entities/message_channel_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_team_entity.dart';
import 'package:Visir/features/chat/providers.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/widgets/proxy_network_image.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/inbox/providers.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatSideBar extends SideBar {
  ChatSideBar({super.key, super.onSelected, super.width, super.drawerCallback, required super.tabType, super.items = const []})
    : super(selectedRoute: '', activeBackgroundColor: Colors.transparent, hoverBackgroundColor: Colors.transparent);

  @override
  _ChatSideBarState createState() => _ChatSideBarState();
}

class _ChatSideBarState extends SideBarState {
  bool get isDarkMode => context.isDarkMode;

  @override
  void initState() {
    super.initState();
    if (widget.drawerCallback != null) {
      widget.drawerCallback!(true);
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.drawerCallback != null) {
      widget.drawerCallback!(false);
    }
  }

  @override
  void didUpdateWidget(ChatSideBar oldWidget) {
    if (oldWidget.selectedRoute != widget.selectedRoute) {
      setState(() {});
    }

    super.didUpdateWidget(oldWidget);
  }

  void sortChannels(List<MessageChannelEntity> list) {
    list.sort((a, b) {
      DateTime? aCreatedAt = a.lastUpdated;
      DateTime? bCreatedAt = b.lastUpdated;
      return bCreatedAt.compareTo(aCreatedAt);
    });
  }

  void onDragEnded(String sectionId, AdminMenuItem item) {
    final channelMap = ref.read(chatChannelListControllerProvider);
    final channel = [...channelMap.values.expand((e) => e.channels).toList()].firstWhereOrNull((e) => e.uniqueId == item.id);
    if (channel == null) return;
    ref
        .read(chatChannelStateListProvider(widget.tabType).notifier)
        .updateChannelState(channelId: channel.uniqueId, section: ChatChannelSection.values.firstWhere((e) => e.name == sectionId));
  }

  AdminMenuItem buildChannelMenuItem({
    required MessageChannelEntity e,
    required List<MessageTeamEntity> teams,
    required List<OAuthEntity> messengerOAuths,
    required String? currentChannelId,
  }) {
    return AdminMenuItem(
      route: e.uniqueId,
      icon: (size) {
        final team = teams.firstWhereOrNull((t) => t.id == e.teamId);
        final oauth = messengerOAuths.firstWhereOrNull((o) => o.teamId == team?.id);
        return ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: ProxyNetworkImage(imageUrl: team!.smallIconUrl!, width: size, height: size, oauth: oauth),
        );
      },
      titleColor: e.unreadCount > 0 ? null : context.inverseSurface,
      titleBold: e.unreadCount > 0,
      badge: e.unreadCount > 0 ? -1 : null,
      title: e.isChannel ? '#${e.displayName}' : e.displayName,
      isSelected: currentChannelId == e.uniqueId,
      isDraggable: true,
      sectionId: ChatChannelSection.basic.name,
      onDragEnded: onDragEnded,
      id: e.uniqueId,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeSwitchProvider);
    final teams = ref.watch(chatChannelListControllerProvider.select((v) => v.values.map((e) => e.team).toList()));
    final chatOAuths = ref.watch(localPrefControllerProvider.select((e) => e.value?.messengerOAuths ?? []));
    final currentChannelId = ref.watch(chatConditionProvider(widget.tabType).select((v) => v.channel?.uniqueId));
    final channels = ref.watch(chatChannelListControllerProvider.select((v) => v.values.expand((e) => e.channels).toList()));
    final channelStateList = ref.watch(chatChannelStateListProvider(widget.tabType));
    final currentChannel = channels.firstWhereOrNull((e) => e.uniqueId == currentChannelId);

    List<MessageChannelEntity> finalChannelList = channels
        .where((e) => e.isChannel)
        .where((e) => channelStateList[e.uniqueId] == ChatChannelSection.basic || channelStateList[e.uniqueId] == null)
        .toList();
    sortChannels(finalChannelList);

    List<MessageChannelEntity> finalDMList = channels
        .where((e) => !e.isChannel)
        .where((e) => channelStateList[e.uniqueId] == ChatChannelSection.basic || channelStateList[e.uniqueId] == null)
        .toList();
    sortChannels(finalDMList);

    List<MessageChannelEntity> finalMutedList = channels.where((e) => channelStateList[e.uniqueId] == ChatChannelSection.muted).toList();
    sortChannels(finalMutedList);

    List<MessageChannelEntity> finalPinnedList = channels.where((e) => channelStateList[e.uniqueId] == ChatChannelSection.pinned).toList();
    sortChannels(finalPinnedList);

    return SideBar(
      backgroundColor: context.background,
      hoverBackgroundColor: context.outlineVariant.withValues(alpha: 0.05),
      borderColor: context.surface,
      activeIconColor: context.onPrimary,
      iconColor: context.onSurface,
      activeBackgroundColor: context.outlineVariant.withValues(alpha: context.isDarkMode ? 0.12 : 0.06),
      textStyle: context.labelLarge!.copyWith(color: context.onBackground).appFont(context),
      activeTextStyle: context.labelLarge!.copyWith(color: context.onBackground).appFont(context),
      subtextStyle: context.labelMedium!.copyWith(color: context.outlineVariant).appFont(context),
      activeSubtextStyle: context.labelMedium!.copyWith(color: context.outlineVariant).appFont(context),
      items: [
        if (currentChannel != null)
          AdminMenuItem(
            route: 'opened',
            title: context.tr.opened,
            isSection: true,
            children: [buildChannelMenuItem(e: currentChannel, teams: teams, messengerOAuths: chatOAuths, currentChannelId: currentChannelId)],
          ),
        AdminMenuItem(
          route: 'pinned',
          title: context.tr.mail_label_pinned,
          isSection: true,
          sectionId: ChatChannelSection.pinned.name,
          onDragEnded: onDragEnded,
          children: finalPinnedList
              .map((e) => buildChannelMenuItem(e: e, teams: teams, messengerOAuths: chatOAuths, currentChannelId: currentChannelId))
              .toList(),
        ),
        AdminMenuItem(
          route: 'channels',
          title: context.tr.chat_channels,
          isSection: true,
          sectionId: ChatChannelSection.basic.name,
          onDragEnded: onDragEnded,
          children: finalChannelList
              .map((e) => buildChannelMenuItem(e: e, teams: teams, messengerOAuths: chatOAuths, currentChannelId: currentChannelId))
              .toList(),
        ),
        AdminMenuItem(
          route: 'dms',
          title: context.tr.chat_dms,
          isSection: true,
          sectionId: ChatChannelSection.basic.name,
          onDragEnded: onDragEnded,
          children: finalDMList.map((e) => buildChannelMenuItem(e: e, teams: teams, messengerOAuths: chatOAuths, currentChannelId: currentChannelId)).toList(),
        ),
        AdminMenuItem(
          route: 'muted',
          title: context.tr.muted,
          isSection: true,
          sectionId: ChatChannelSection.muted.name,
          onDragEnded: onDragEnded,
          children: finalMutedList
              .map((e) => buildChannelMenuItem(e: e, teams: teams, messengerOAuths: chatOAuths, currentChannelId: currentChannelId))
              .toList(),
        ),
      ],
      selectedRoute: InboxFilterType.all.name,
      tabType: widget.tabType,
      onSelected: (item) {
        if (item.id != null) {
          final channel = channels.firstWhereOrNull((e) => e.uniqueId == item.id);

          if (channel == null) return;
          if (ref.read(chatConditionProvider(widget.tabType).select((v) => v.channel?.uniqueId)) == item.id) {
            ref.read(chatConditionProvider(widget.tabType).notifier).clear();
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              Navigator.maybePop(context);
            });
          } else {
            ref.read(chatConditionProvider(widget.tabType).notifier).setChannel(channel);
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              Navigator.maybePop(context);
            });
          }
        }
      },
    );
  }
}
