import 'package:Visir/dependency/contextmenu/src/ContextMenuArea.dart';
import 'package:Visir/features/auth/application/notification_controller.dart';
import 'package:Visir/features/chat/application/chat_channel_list_controller.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/log_event.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/presentation/widgets/selection_widget.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/application/messenger_integration_list_controller.dart';
import 'package:Visir/features/preference/domain/entities/local_pref_entity.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatNotificationFilterScreen extends ConsumerStatefulWidget {
  final OAuthEntity oAuth;

  const ChatNotificationFilterScreen({super.key, required this.oAuth});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatNotificationFilterScreenState();
}

class _ChatNotificationFilterScreenState extends ConsumerState<ChatNotificationFilterScreen> {
  bool get isMobileView => PlatformX.isMobileView;

  OAuthEntity get oAuth => widget.oAuth;

  @override
  Widget build(BuildContext context) {
    final messageDmNotificationFilterType =
        ref.watch(localPrefControllerProvider.select((e) => e.value!.prefMessageDmNotificationFilterTypes['${oAuth.teamId}${oAuth.email}'])) ??
        MessagNotificationFilterType.all;
    final messageChannelNotificationFilterType =
        ref.watch(localPrefControllerProvider.select((e) => e.value!.prefMessageChannelNotificationFilterTypes['${oAuth.teamId}${oAuth.email}'])) ??
        MessagNotificationFilterType.mentions;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Text(context.tr.notification_message_notifications, style: context.titleSmall?.textBold.textColor(context.outlineVariant)),
          ),
          SizedBox(height: 6),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Text(context.tr.notification_message_description, style: context.labelMedium?.textColor(context.inverseSurface)),
          ),
          Padding(
            padding: EdgeInsets.only(top: 6),
            child: Container(
              height: 32,
              child: Row(
                children: [
                  SizedBox(width: 8),
                  Text(context.tr.message_pref_filter_direct_messages, style: context.bodyLarge?.textColor(context.outlineVariant)),
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
                        popup: SelectionWidget<MessagNotificationFilterType>(
                          current: messageDmNotificationFilterType,
                          items: MessagNotificationFilterType.values,
                          getTitle: (item) => item.getTitle(context),
                          onSelect: (messageDmNotificationilterType) async {
                            final pref = ref.read(localPrefControllerProvider).value;
                            if (pref == null) return;
                            int accountIndex = (ref.read(messengerIntegrationListControllerProvider).value ?? []).indexWhere((e) => e.teamId == oAuth.teamId);
                            logAnalyticsEvent(
                              eventName: 'notification_slack_dm',
                              properties: {'account': (accountIndex + 1).toString(), 'option': messageDmNotificationilterType.getTitle(context)},
                            );

                            Map<String, MessagNotificationFilterType> newMessageDmNotificationFilterType = Map.from(pref.prefMessageDmNotificationFilterTypes);
                            newMessageDmNotificationFilterType['${oAuth.teamId}${oAuth.email}'] = messageDmNotificationilterType;
                            await ref.read(localPrefControllerProvider.notifier).set(messageDmNotificationFilterTypes: newMessageDmNotificationFilterType);
                            final channelsMap = ref.read(
                              chatChannelListControllerProvider.select((v) => v.entries.map((e) => MapEntry(e.key, e.value.channels)).toList()),
                            );
                            await ref.read(notificationControllerProvider.notifier).updateLinkedSlackTeam(Map.fromEntries(channelsMap));
                          },
                        ),
                        style: VisirButtonStyle(
                          height: 32,
                          backgroundColor: context.surface,
                          borderRadius: BorderRadius.circular(6),
                          padding: EdgeInsets.only(left: 10, right: 6),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                messageDmNotificationFilterType.getTitle(context),
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
            padding: EdgeInsets.only(top: 8),
            child: Container(
              height: 32,
              child: Row(
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
                        popup: SelectionWidget<MessagNotificationFilterType>(
                          current: messageChannelNotificationFilterType,
                          items: MessagNotificationFilterType.values,
                          getTitle: (item) => item.getTitle(context),
                          onSelect: (messageChannelNotificationFilterType) async {
                            final pref = ref.read(localPrefControllerProvider).value;
                            if (pref == null) return;
                            Map<String, MessagNotificationFilterType> newMessageChannelNotificationFilterType = Map.from(
                              pref.prefMessageChannelNotificationFilterTypes,
                            );
                            newMessageChannelNotificationFilterType['${oAuth.teamId}${oAuth.email}'] = messageChannelNotificationFilterType;
                            await ref
                                .read(localPrefControllerProvider.notifier)
                                .set(messageChannelNotificationFilterTypes: newMessageChannelNotificationFilterType);
                            final channelsMap = ref.read(
                              chatChannelListControllerProvider.select((v) => v.entries.map((e) => MapEntry(e.key, e.value.channels)).toList()),
                            );
                            await ref.read(notificationControllerProvider.notifier).updateLinkedSlackTeam(Map.fromEntries(channelsMap));
                          },
                        ),
                        style: VisirButtonStyle(
                          height: 32,
                          constraints: BoxConstraints(maxWidth: 180),
                          backgroundColor: context.surface,
                          borderRadius: BorderRadius.circular(6),
                          padding: EdgeInsets.only(left: 10, right: 6),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                messageChannelNotificationFilterType.getTitle(context),
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
