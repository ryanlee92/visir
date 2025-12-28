import 'package:Visir/dependency/master_detail_flow/src/details_item.dart';
import 'package:Visir/dependency/modal_bottom_sheet/src/utils/modal_scroll_controller.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/auth/application/notification_controller.dart';
import 'package:Visir/features/chat/application/chat_channel_list_controller.dart';
import 'package:Visir/features/chat/domain/entities/message_channel_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_team_entity.dart';
import 'package:Visir/features/common/presentation/utils/extensions/list_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/common/presentation/widgets/visir_list_section.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/presentation/widgets/notification/chat_inbox_filter_preference_widget.dart';
import 'package:Visir/features/preference/presentation/widgets/notification/chat_notification_preference_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatPrefScreen extends ConsumerStatefulWidget {
  final bool isSmall;
  final VoidCallback? onClose;

  const ChatPrefScreen({super.key, required this.isSmall, this.onClose});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatPrefScreenState();
}

class _ChatPrefScreenState extends ConsumerState<ChatPrefScreen> {
  late TextEditingController searchController;

  ValueNotifier<String> hoverId = ValueNotifier('');

  List<String> opendedListedChannelsTeamIds = [];
  List<String> opendedUnlistedChannelsTeamIds = [];
  final Duration listOpenDuration = const Duration(milliseconds: 300);

  FocusNode searchFocusNode = FocusNode();

  ScrollController? _scrollController;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController(text: null);
    searchFocusNode.onKeyEvent = onKeyEventTextField;
    searchFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _scrollController?.dispose();

    searchController.dispose();
    widget.onClose?.call();
    super.dispose();
  }

  KeyEventResult onKeyEventTextField(FocusNode node, KeyEvent event) {
    final key = event.logicalKey;
    if (event is KeyDownEvent) {
      if (ServicesBinding.instance.keyboard.logicalKeysPressed.length == 1 && key == LogicalKeyboardKey.escape) {
        if (searchFocusNode.hasFocus) {
          searchController.clear();
          setState(() {});
        } else {
          Navigator.of(context).pop();
        }

        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  Future<void> addChannelsToExcludedList({required List<MessageChannelEntity> channels}) async {
    final user = ref.read(authControllerProvider).requireValue;
    final pref = ref.read(localPrefControllerProvider).value;
    if (pref == null) return;

    await ref
        .read(authControllerProvider.notifier)
        .updateUser(
          user: user.copyWith(
            excludedChannelIds: [...(user.userExcludedChannelIds), ...(channels.map((e) => e.id))].unique((e) => e).whereType<String>().toList(),
          ),
        );
    final channelsMap = ref.read(chatChannelListControllerProvider.select((v) => v.entries.map((e) => MapEntry(e.key, e.value.channels)).toList()));
    await ref.read(notificationControllerProvider.notifier).updateLinkedSlackTeam(Map.fromEntries(channelsMap));
  }

  Future<void> substractChannelsFromExcludedList({required List<MessageChannelEntity> channels}) async {
    final user = ref.read(authControllerProvider).requireValue;
    final pref = ref.read(localPrefControllerProvider).value;
    if (pref == null) return;

    await ref
        .read(authControllerProvider.notifier)
        .updateUser(
          user: user.copyWith(
            excludedChannelIds: [...(user.userExcludedChannelIds)]
              ..removeWhere((e) => channels.where((c) => c.id == e).isNotEmpty)
              ..whereType<String>().toList(),
          ),
        );
    final channelsMap = ref.read(chatChannelListControllerProvider.select((v) => v.entries.map((e) => MapEntry(e.key, e.value.channels)).toList()));
    await ref.read(notificationControllerProvider.notifier).updateLinkedSlackTeam(Map.fromEntries(channelsMap));
  }

  Widget channelWidget({required MessageTeamEntity team, required MessageChannelEntity? channel, required bool isExcluded}) {
    String allChannelsSubstractId = 'all_channels_substract';
    String allChannelsAddId = 'all_channels_add';

    List<MessageChannelEntity> teamChannels = ref.read(chatChannelListControllerProvider.select((v) => v[team.id]?.channels ?? []));
    List<MessageChannelEntity> teamChannelsExceptDm = teamChannels.where((c) => !c.isDm && !c.isGroupDm).toList();

    return Padding(
      padding: EdgeInsets.only(bottom: 2, top: channel == null ? 5 : 0),
      child: GestureDetector(
        onTapDown: (_) {
          setState(() {
            if (channel != null) {
              hoverId.value = channel.id;
            } else {
              if (isExcluded) {
                hoverId.value = allChannelsSubstractId;
              } else {
                hoverId.value = allChannelsAddId;
              }
            }
          });
        },
        onTapUp: (_) {
          setState(() {
            hoverId.value = "";
          });
        },
        child: MouseRegion(
          onEnter: (event) {
            if (channel != null) {
              hoverId.value = channel.id;
            } else {
              if (isExcluded) {
                hoverId.value = allChannelsSubstractId;
              } else {
                hoverId.value = allChannelsAddId;
              }
            }
          },
          onExit: (event) {
            hoverId.value = '';
          },
          child: ValueListenableBuilder<String>(
            valueListenable: hoverId,
            builder: (context, value, child) {
              return VisirButton(
                type: VisirButtonAnimationType.scaleAndOpacity,
                style: VisirButtonStyle(
                  cursor: WidgetStateMouseCursor.clickable,
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                  borderRadius: BorderRadius.circular(4),
                ),
                onTap: () {
                  if (channel == null) {
                    if (isExcluded) {
                      substractChannelsFromExcludedList(channels: teamChannelsExceptDm);
                    } else {
                      addChannelsToExcludedList(channels: teamChannelsExceptDm);
                    }
                  } else {
                    if (isExcluded) {
                      substractChannelsFromExcludedList(channels: [channel]);
                    } else {
                      addChannelsToExcludedList(channels: [channel]);
                    }
                  }
                  hoverId.value = '';
                },
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(6),
                      child: VisirIcon(
                        type: isExcluded ? VisirIconType.addWithCircle : VisirIconType.subtractWithCircle,
                        size: 14,
                        color: channel == null ? context.secondary : context.outlineVariant,
                      ),
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        channel == null ? context.tr.channel_list_all_channels : '# ${channel.displayName}',
                        style: context.bodyMedium?.textColor(channel == null ? context.secondary : context.outlineVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String getShowUnreadChannelsOnlyString(bool? showUnreadChannelsOnly) {
    if (!(showUnreadChannelsOnly ?? false)) return context.tr.chat_all;
    return context.tr.chat_unread_only;
  }

  String getShowUnreadDmssOnlyString(bool? showUnreadDmsOnly) {
    if (!(showUnreadDmsOnly ?? false)) return context.tr.chat_all;
    return context.tr.chat_unread_only;
  }

  @override
  Widget build(BuildContext context) {
    _scrollController ??= ModalScrollController.ofSyncGroup(context)?.addAndGet() ?? ScrollController();

    return DetailsItem(
      title: widget.isSmall ? context.tr.chat_pref_title : null,
      hideBackButton: !widget.isSmall,
      scrollController: _scrollController,
      scrollPhysics: Utils.getScrollPhysicsForBottomSheet(context, _scrollController),
      appbarColor: context.background,
      bodyColor: context.background,
      dividerColor: context.outline,
      children: [
        VisirListSection(
          removeTopMargin: true,
          titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: context.tr.mail_pref_filter_inbox_filter, style: baseStyle),
        ),

        ChatInboxFilterPreferenceWidget(),

        VisirListSection(
          titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: context.tr.notification_pref_title, style: baseStyle),
        ),

        ChatNotificationPreferenceWidget(),
      ],
    );
  }
}
