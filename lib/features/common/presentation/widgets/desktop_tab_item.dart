import 'package:Visir/config/providers.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/chat/application/chat_channel_list_controller.dart';
import 'package:Visir/features/chat/domain/entities/message_channel_entity.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/widgets/showcase_wrapper.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/mail/application/mail_label_list_controller.dart';
import 'package:Visir/features/mail/domain/entities/mail_label_entity.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/domain/entities/local_pref_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DesktopTabItem extends ConsumerStatefulWidget {
  final TabType tab;
  final List<TabType> desktopTabValues;

  const DesktopTabItem({required this.tab, required this.desktopTabValues, Key? key}) : super(key: key);

  @override
  _DesktopTabItemState createState() => _DesktopTabItemState();
}

class _DesktopTabItemState extends ConsumerState<DesktopTabItem> {
  @override
  Widget build(BuildContext context) {
    final tabBarDisplayType = ref.watch(localPrefControllerProvider.select((value) => value.value?.prefTabBarDisplayType));
    final excludedChannelIds = ref.watch(authControllerProvider.select((value) => value.requireValue.userExcludedChannelIds));
    final labels = ref.watch(mailLabelListControllerProvider);
    List<MessageChannelEntity> channels = ref.watch(
      chatChannelListControllerProvider.select((v) => v.values.expand((e) => e.channels).where((e) => !excludedChannelIds.contains(e.id)).toList()),
    );

    final unreadMailList = labels.values.expand((e) => e).where((l) => l.id == CommonMailLabels.inbox.id && l.unread > 0).toList();
    final mailUnreads = unreadMailList.length;

    List<MessageChannelEntity> finalChannelList = channels.where((e) => !e.isDm && !e.isGroupDm).where((e) {
      return e.hasUnreadMessage;
    }).toList();

    List<MessageChannelEntity> finalDMList = channels.where((e) => e.isDm || e.isGroupDm).where((e) {
      return e.hasUnreadMessage;
    }).toList();

    List<MessageChannelEntity> unreadChannelList = [...finalChannelList, ...finalDMList].where((e) => e.hasUnreadMessage).toList();
    final messageUnreads = unreadChannelList.length;

    final isTabBarCollapsed = context.isNarrowScaffold || (tabBarDisplayType == TabBarDisplayType.alwaysCollapsed);
    bool hideUnreadIndicator = ref.watch(hideUnreadIndicatorProvider);

    final orderKey = [
      LogicalKeyboardKey.digit1,
      LogicalKeyboardKey.digit2,
      LogicalKeyboardKey.digit3,
      LogicalKeyboardKey.digit4,
      LogicalKeyboardKey.digit5,
      LogicalKeyboardKey.digit6,
    ];

    return ValueListenableBuilder(
      valueListenable: tabNotifier,
      builder: (context, tab, child) {
        bool isCurrentTab = tab == widget.tab;

        int newCount = 0;
        switch (widget.tab) {
          case TabType.chat:
            newCount = messageUnreads;
            break;
          case TabType.home:
            break;
          case TabType.mail:
            newCount = mailUnreads;
            break;
          case TabType.calendar:
            break;
          case TabType.task:
            break;
        }
        String newCountString = newCount < 1
            ? ''
            : newCount > 99
            ? '99+'
            : newCount.toString();

        final button = VisirButton(
          type: VisirButtonAnimationType.scaleAndOpacity,
          style: VisirButtonStyle(
            width: isTabBarCollapsed ? 36 : 56,

            // selectedColor: context.surface,
            borderRadius: BorderRadius.circular(8),
            cursor: SystemMouseCursors.click,
          ),
          options: VisirButtonOptions(
            bypassMailEditScreen: true,
            bypassTextField: true,
            tooltipLocation: VisirButtonTooltipLocation.right,
            shortcuts: [
              VisirButtonKeyboardShortcut(
                message: widget.tab.getTitle(context),
                keys: [
                  orderKey[widget.desktopTabValues.indexOf(widget.tab)],
                  if (PlatformX.isApple) LogicalKeyboardKey.meta,
                  if (!PlatformX.isApple) LogicalKeyboardKey.control,
                ],
                onTrigger: () {
                  if (widget.desktopTabValues.isEmpty) return true;
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  if (tabNotifier.value != widget.tab) tabNotifier.value = widget.tab;
                  return true;
                },
              ),
            ],
          ),
          isSelected: isCurrentTab,
          focusNode: FocusNode(skipTraversal: true),
          child: Column(
            children: [
              SizedBox(height: 8),
              widget.tab.getVisirIcon(size: isTabBarCollapsed ? 20 : Theme.of(context).iconTheme.size ?? 16, isSelected: isCurrentTab),
              if (!isTabBarCollapsed) ...[
                SizedBox(height: 6),
                Text(
                  widget.tab.getTitle(context),
                  style: context.labelMedium?.textColor(isCurrentTab ? context.onBackground : context.inverseSurface).appFont(context),
                ),
              ],
              SizedBox(height: 8),
            ],
          ),
          onTap: () {
            tabNotifier.value = widget.tab;
          },
        );

        return Padding(
          padding: EdgeInsets.symmetric(vertical: isTabBarCollapsed ? 4 : 6),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (widget.tab.showcaseKey != null) ShowcaseWrapper(showcaseKey: widget.tab.showcaseKey!, child: button) else button,
              if (newCountString.isNotEmpty && !hideUnreadIndicator)
                Positioned(
                  top: 4,
                  right: isTabBarCollapsed ? 4 : 12,
                  child: IgnorePointer(
                    child: Container(
                      width: 6,
                      height: 6,
                      clipBehavior: Clip.antiAlias,
                      decoration: ShapeDecoration(
                        color: context.error,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
