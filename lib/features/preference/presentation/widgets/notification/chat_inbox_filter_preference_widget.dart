import 'package:Visir/dependency/contextmenu/src/ContextMenuArea.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/auth/domain/entities/user_entity.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/widgets/auth_image_view.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/common/presentation/widgets/visir_list_item.dart';
import 'package:Visir/features/preference/application/messenger_integration_list_controller.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:Visir/features/preference/presentation/screens/chat_pref_filter_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatInboxFilterPreferenceWidget extends ConsumerStatefulWidget {
  const ChatInboxFilterPreferenceWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatInboxFilterPreferenceWidgetState();
}

class _ChatInboxFilterPreferenceWidgetState extends ConsumerState<ChatInboxFilterPreferenceWidget> {
  bool get isDarkMode => context.isDarkMode;

  String getNotificationDescription({
    required ChatInboxFilterType messageDmNotificationFilterTypes,
    required ChatInboxFilterType messageChannelNotificationFilterTypes,
  }) {
    if (messageDmNotificationFilterTypes == ChatInboxFilterType.none && messageChannelNotificationFilterTypes == ChatInboxFilterType.none)
      return context.tr.message_pref_filter_none;
    else if (messageDmNotificationFilterTypes == ChatInboxFilterType.mentions && messageChannelNotificationFilterTypes == ChatInboxFilterType.mentions)
      return context.tr.message_pref_filter_mentions;
    else {
      List<String> words = [];
      if (messageDmNotificationFilterTypes == ChatInboxFilterType.mentions) words.add(context.tr.message_pref_filter_mentions_from_direct_messages);
      if (messageDmNotificationFilterTypes == ChatInboxFilterType.all) words.add(context.tr.message_pref_filter_direct_messages);
      if (messageChannelNotificationFilterTypes == ChatInboxFilterType.mentions) words.add(context.tr.message_pref_filter_mentions_from_channels);
      if (messageChannelNotificationFilterTypes == ChatInboxFilterType.all) words.add(context.tr.message_pref_filter_channels);

      return words.join(', ');
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(messengerIntegrationListControllerProvider).value ?? [];

    final messageDmInboxFilterTypes = ref.watch(authControllerProvider.select((e) => e.requireValue.userMessageDmInboxFilterTypes));
    final messageChannelInboxFilterTypes = ref.watch(authControllerProvider.select((e) => e.requireValue.userMessageChannelInboxFilterTypes));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...[OAuthType.slack].map((type) {
          return Column(
            children: list.where((e) => e.type == type).map((e) {
              ChatInboxFilterType _messageDmInboxFilterType = messageDmInboxFilterTypes['${e.teamId}${e.email}'] ?? ChatInboxFilterType.all;
              ChatInboxFilterType _messageChannelInboxFilterType = messageChannelInboxFilterTypes['${e.teamId}${e.email}'] ?? ChatInboxFilterType.mentions;

              String description = getNotificationDescription(
                messageDmNotificationFilterTypes: _messageDmInboxFilterType,
                messageChannelNotificationFilterTypes: _messageChannelInboxFilterType,
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
                        popup: ChatPrefFilterScreen(oAuth: e),
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
