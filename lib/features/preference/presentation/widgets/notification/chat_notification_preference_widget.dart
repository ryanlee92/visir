import 'package:Visir/dependency/contextmenu/src/ContextMenuArea.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/widgets/auth_image_view.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/common/presentation/widgets/visir_list_item.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/application/messenger_integration_list_controller.dart';
import 'package:Visir/features/preference/domain/entities/local_pref_entity.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:Visir/features/preference/presentation/screens/chat_notification_filter_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatNotificationPreferenceWidget extends ConsumerStatefulWidget {
  const ChatNotificationPreferenceWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatNotificationPreferenceWidgetState();
}

class _ChatNotificationPreferenceWidgetState extends ConsumerState<ChatNotificationPreferenceWidget> {
  bool get isDarkMode => context.isDarkMode;

  String getNotificationDescription({
    required MessagNotificationFilterType messageDmNotificationFilterTypes,
    required MessagNotificationFilterType messageChannelNotificationFilterTypes,
  }) {
    if (messageDmNotificationFilterTypes == MessagNotificationFilterType.none && messageChannelNotificationFilterTypes == MessagNotificationFilterType.none)
      return context.tr.message_pref_filter_none;
    else if (messageDmNotificationFilterTypes == MessagNotificationFilterType.mentions &&
        messageChannelNotificationFilterTypes == MessagNotificationFilterType.mentions)
      return context.tr.message_pref_filter_mentions;
    else {
      List<String> words = [];
      if (messageDmNotificationFilterTypes == MessagNotificationFilterType.mentions) words.add(context.tr.message_pref_filter_mentions_from_direct_messages);
      if (messageDmNotificationFilterTypes == MessagNotificationFilterType.all) words.add(context.tr.message_pref_filter_direct_messages);
      if (messageChannelNotificationFilterTypes == MessagNotificationFilterType.mentions) words.add(context.tr.message_pref_filter_mentions_from_channels);
      if (messageChannelNotificationFilterTypes == MessagNotificationFilterType.all) words.add(context.tr.message_pref_filter_channels);

      return words.join(', ');
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(messengerIntegrationListControllerProvider).value ?? [];

    final messageDmNotificationFilterTypes = ref.watch(localPrefControllerProvider.select((e) => e.value!.prefMessageDmNotificationFilterTypes));
    final messageChannelNotificationFilterTypes = ref.watch(localPrefControllerProvider.select((e) => e.value!.prefMessageChannelNotificationFilterTypes));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...[OAuthType.slack].map((type) {
          return Column(
            children: list.where((e) => e.type == type).map((e) {
              MessagNotificationFilterType _messageDmNotificationFilterTypes =
                  messageDmNotificationFilterTypes['${e.teamId}${e.email}'] ?? MessagNotificationFilterType.all;
              MessagNotificationFilterType _messageChannelNotificationFilterTypes =
                  messageChannelNotificationFilterTypes['${e.teamId}${e.email}'] ?? MessagNotificationFilterType.mentions;

              String description = getNotificationDescription(
                messageDmNotificationFilterTypes: _messageDmNotificationFilterTypes,
                messageChannelNotificationFilterTypes: _messageChannelNotificationFilterTypes,
              );
              return VisirListItem(
                verticalMarginOverride: 8,
                verticalPaddingOverride: 0,
                titleLeadingBuilder: (height, baseStyle, verticalSpacing, horizontalSpacing) => TextSpan(
                  children: [
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: AuthImageView(oauth: e, size: 28),
                    ),
                  ],
                ),
                titleBuilder: (height, baseStyle, verticalSpacing, horizontalSpacing) => TextSpan(text: e.email, style: baseStyle),
                detailsBuilder: (height, baseStyle, verticalSpacing, horizontalSpacing) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.teamName!, style: baseStyle),
                      SizedBox(height: 3),
                      Text(description, style: baseStyle),
                    ],
                  );
                },
                titleTrailingBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(
                  children: [
                    WidgetSpan(
                      child: PopupMenu(
                        location: PopupMenuLocation.bottom,
                        type: ContextMenuActionType.tap,
                        width: 180,
                        forcePopup: true,
                        popup: ChatNotificationFilterScreen(oAuth: e),
                        style: VisirButtonStyle(
                          cursor: SystemMouseCursors.click,
                          padding: EdgeInsets.all(6),
                          borderRadius: BorderRadius.circular(6),
                          backgroundColor: context.surface,
                        ),
                        options: VisirButtonOptions(message: context.tr.notification_preference, tooltipLocation: VisirButtonTooltipLocation.left),
                        child: VisirIcon(type: VisirIconType.control, size: 16, isSelected: true),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }
}
