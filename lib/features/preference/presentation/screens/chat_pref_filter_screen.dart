import 'package:Visir/dependency/contextmenu/src/ContextMenuArea.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/auth/domain/entities/user_entity.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/log_event.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/presentation/widgets/selection_widget.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/preference/application/messenger_integration_list_controller.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatPrefFilterScreen extends ConsumerStatefulWidget {
  final OAuthEntity oAuth;

  const ChatPrefFilterScreen({super.key, required this.oAuth});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatPrefFilterScreenState();
}

class _ChatPrefFilterScreenState extends ConsumerState<ChatPrefFilterScreen> {
  bool get isMobileView => PlatformX.isMobileView;

  OAuthEntity get oAuth => widget.oAuth;

  @override
  Widget build(BuildContext context) {
    final messageDmInboxFilterType =
        ref.watch(authControllerProvider.select((e) => e.requireValue.userMessageDmInboxFilterTypes['${oAuth.teamId}${oAuth.email}'])) ??
        ChatInboxFilterType.all;
    final messageChannelInboxFilterType =
        ref.watch(authControllerProvider.select((e) => e.requireValue.userMessageChannelInboxFilterTypes['${oAuth.teamId}${oAuth.email}'])) ??
        ChatInboxFilterType.mentions;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Text(context.tr.message_pref_filter_inbox_filter, style: context.titleSmall?.textBold.textColor(context.outlineVariant)),
          ),
          SizedBox(height: 6),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Text(context.tr.message_pref_filter_inbox_filter_description, style: context.labelMedium?.textColor(context.inverseSurface)),
          ),
          Padding(
            padding: EdgeInsets.only(top: 6),
            child: Container(
              height: 32,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(width: 8),
                  Text(context.tr.message_pref_filter_direct_messages, style: context.bodyLarge?.textColor(context.outlineVariant)),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: PopupMenu(
                        forcePopup: true,
                        location: PopupMenuLocation.bottom,
                        width: 180,
                        borderRadius: 6,
                        type: ContextMenuActionType.tap,
                        popup: SelectionWidget<ChatInboxFilterType>(
                          current: messageDmInboxFilterType,
                          items: ChatInboxFilterType.values,
                          getTitle: (item) => item.getTitle(context),
                          onSelect: (messageDmInboxFilterType) async {
                            final user = ref.read(authControllerProvider).requireValue;
                            int accountIndex = (ref.read(messengerIntegrationListControllerProvider).value ?? []).indexWhere((e) => e.teamId == oAuth.teamId);
                            logAnalyticsEvent(
                              eventName: 'inbox_filter_slack_dm',
                              properties: {'account': (accountIndex + 1).toString(), 'option': messageDmInboxFilterType.getTitle(context)},
                            );
                            Map<String, ChatInboxFilterType> newMessageDmInboxFilterType = Map.from(user.userMessageDmInboxFilterTypes);
                            newMessageDmInboxFilterType['${oAuth.teamId}${oAuth.email}'] = messageDmInboxFilterType;
                            await ref
                                .read(authControllerProvider.notifier)
                                .updateUser(user: user.copyWith(messageDmInboxFilterTypes: newMessageDmInboxFilterType));
                          },
                        ),
                        style: VisirButtonStyle(
                          height: 32,
                          backgroundColor: context.surface,
                          borderRadius: BorderRadius.circular(6),
                          padding: EdgeInsets.only(left: 10, right: 6),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Text(
                                messageDmInboxFilterType.getTitle(context),
                                style: context.bodyMedium?.textColor(context.outlineVariant),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 6),
                            VisirIcon(type: VisirIconType.arrowDown, size: 12, color: context.outlineVariant),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 3),
            child: Container(
              height: 32,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(width: 8),
                  Text(context.tr.message_pref_filter_channels, style: context.bodyLarge?.textColor(context.outlineVariant)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: PopupMenu(
                        forcePopup: true,
                        location: PopupMenuLocation.bottom,
                        width: 180,
                        borderRadius: 6,
                        type: ContextMenuActionType.tap,
                        popup: SelectionWidget<ChatInboxFilterType>(
                          current: messageChannelInboxFilterType,
                          items: [ChatInboxFilterType.none, ChatInboxFilterType.mentions],
                          getTitle: (item) => item.getTitle(context),
                          onSelect: (messageChannelInboxFilterType) async {
                            final user = ref.read(authControllerProvider).requireValue;
                            Map<String, ChatInboxFilterType> newMessageChannelInboxFilterType = Map.from(user.userMessageChannelInboxFilterTypes);
                            newMessageChannelInboxFilterType['${oAuth.teamId}${oAuth.email}'] = messageChannelInboxFilterType;
                            await ref
                                .read(authControllerProvider.notifier)
                                .updateUser(user: user.copyWith(messageChannelInboxFilterTypes: newMessageChannelInboxFilterType));
                          },
                        ),
                        style: VisirButtonStyle(
                          height: 32,
                          backgroundColor: context.surface,
                          borderRadius: BorderRadius.circular(6),
                          padding: EdgeInsets.only(left: 10, right: 6),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Text(
                                messageChannelInboxFilterType.getTitle(context),
                                style: context.bodyMedium?.textColor(context.outlineVariant),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 6),
                            VisirIcon(type: VisirIconType.arrowDown, size: 12, color: context.outlineVariant),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 6),
        ],
      ),
    );
  }
}
