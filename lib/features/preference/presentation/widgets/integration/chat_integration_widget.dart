import 'package:Visir/dependency/contextmenu/src/ContextMenuArea.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/auth/application/notification_controller.dart';
import 'package:Visir/features/auth/domain/entities/user_entity.dart';
import 'package:Visir/features/chat/application/chat_channel_list_controller.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/log_event.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/utils/first_time_tracker.dart';
import 'package:Visir/features/common/presentation/widgets/auth_image_view.dart';
import 'package:Visir/features/common/presentation/widgets/desktop_scaffold.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/common/presentation/widgets/visir_list_item.dart';
import 'package:Visir/features/inbox/application/inbox_controller.dart';
import 'package:Visir/features/preference/application/messenger_integration_list_controller.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:Visir/features/preference/presentation/screens/chat_pref_filter_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

extension OAuthTypeMessengerX on OAuthType {
  String getMessengerOAuthTitle(BuildContext context) {
    switch (this) {
      case OAuthType.slack:
        return context.tr.integration_slack;
      case OAuthType.discord:
        return context.tr.integration_discord;
      default:
        return '';
    }
  }

  get messengerOAuthAssetPath {
    switch (this) {
      case OAuthType.slack:
        return '${(kDebugMode && kIsWeb) ? "" : "assets/"}logos/logo_slack.png';
      case OAuthType.discord:
        return '${(kDebugMode && kIsWeb) ? "" : "assets/"}logos/logo_discord.png';
      default:
        return '';
    }
  }
}

class ChatIntegrationWidget extends ConsumerStatefulWidget {
  const ChatIntegrationWidget({super.key});

  @override
  ConsumerState createState() => _ChatIntegrationWidgetState();
}

class _ChatIntegrationWidgetState extends ConsumerState<ChatIntegrationWidget> {
  OAuthType? loadingType;
  bool get isDarkMode => context.isDarkMode;

  String? lastIntegratedEmail;

  Future<void> integrate({required OAuthType type}) async {
    loadingType = type;
    setState(() {});

    final result = await Utils.ref.read(messengerIntegrationListControllerProvider.notifier).integrate(type: type);

    if (result == true) {
      final channels = await Utils.ref.read(chatChannelListControllerProvider.notifier).load();

      setState(() {
        final list = ref.read(messengerIntegrationListControllerProvider).value ?? [];
        lastIntegratedEmail = list.lastOrNull?.email;
      });

      // Track first Slack connection for funnel analytics
      FirstTimeTracker.trackFeatureIfFirst('slack_connected', additionalProperties: {'provider': type == OAuthType.slack ? 'slack' : 'discord', 'team_count': channels.length});

      final refreshInbox = Utils.ref.read(inboxControllerProvider.notifier).refresh();
      await Future.wait(
        [
          refreshInbox,
          Utils.ref.read(notificationControllerProvider.notifier).updateLinkedSlackTeam(Map.fromEntries(channels.entries.map((e) => MapEntry(e.key, e.value.channels)))),
        ].whereType<Future>(),
      );
    }

    if (mounted) {
      loadingType = null;
      setState(() {});
    }
  }

  Future<void> unintegrate({required OAuthEntity oauth, required OAuthType type}) async {
    await Utils.ref.read(messengerIntegrationListControllerProvider.notifier).unintegrate(oauth: oauth);
    final user = ref.read(authControllerProvider).requireValue;
    logAnalyticsEvent(
      eventName: user.onTrial ? 'trial_disconnect_service' : 'disconnect_service',
      properties: {'service': type.getAnalyticsServiceName(isCalendar: false, isMail: false)},
    );

    if (mounted) {
      loadingType = null;
      setState(() {});
    }
  }

  String getIntegrationDescription({required ChatInboxFilterType messageDmInboxFilterType, required ChatInboxFilterType messageChannelInboxFilterType}) {
    if (messageDmInboxFilterType == ChatInboxFilterType.none && messageChannelInboxFilterType == ChatInboxFilterType.none)
      return context.tr.message_pref_filter_none;
    else if (messageDmInboxFilterType == ChatInboxFilterType.mentions && messageChannelInboxFilterType == ChatInboxFilterType.mentions)
      return context.tr.message_pref_filter_mentions;
    else {
      List<String> words = [];
      if (messageDmInboxFilterType == ChatInboxFilterType.mentions) words.add(context.tr.message_pref_filter_mentions_from_direct_messages);
      if (messageDmInboxFilterType == ChatInboxFilterType.all) words.add(context.tr.message_pref_filter_direct_messages);
      if (messageChannelInboxFilterType == ChatInboxFilterType.mentions) words.add(context.tr.message_pref_filter_mentions_from_channels);
      if (messageChannelInboxFilterType == ChatInboxFilterType.all) words.add(context.tr.message_pref_filter_channels);

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
      children: [OAuthType.slack]
          .map(
            (type) => VisirListItem(
              titleBuilder: (height, baseStyle, verticalSpacing, horizontalSpacing) => TextSpan(
                children: [
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Container(
                      width: 28,
                      height: 28,
                      margin: EdgeInsets.only(right: horizontalSpacing * 2),
                      child: Container(
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                        alignment: Alignment.center,
                        child: Image.asset(type.messengerOAuthAssetPath, width: 20, height: 20, fit: BoxFit.contain),
                      ),
                    ),
                  ),
                  TextSpan(text: type.getMessengerOAuthTitle(context), style: baseStyle?.appFont(context).textBold),
                ],
              ),
              titleTrailingBuilder: (height, baseStyle, verticalSpacing, horizontalSpacing) => TextSpan(
                children: [
                  WidgetSpan(
                    child: VisirButton(
                      type: VisirButtonAnimationType.scaleAndOpacity,
                      style: VisirButtonStyle(
                        height: height + 12,
                        padding: EdgeInsets.symmetric(horizontal: horizontalSpacing * 2),
                        backgroundColor: context.primary,
                        borderRadius: BorderRadius.circular(DesktopScaffold.cardRadius),
                      ),
                      onTap: () async {
                        await integrate(type: type);
                      },
                      child: Text(context.tr.integration_connect, style: baseStyle?.textColor(context.onPrimary)),
                    ),
                  ),
                ],
              ),
              detailsBuilder: (height, baseStyle, verticalSpacing, horizontalSpacing) {
                return Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Column(
                    children: list.where((e) => e.type == type).map((e) {
                      ChatInboxFilterType _messageDmInboxFilterTypes = messageDmInboxFilterTypes['${e.teamId}${e.email}'] ?? ChatInboxFilterType.all;
                      ChatInboxFilterType _messageChannelInboxFilterTypes = messageChannelInboxFilterTypes['${e.teamId}${e.email}'] ?? ChatInboxFilterType.mentions;

                      String description =
                          '${context.tr.message_pref_filter_inbox_filter}: ${getIntegrationDescription(messageDmInboxFilterType: _messageDmInboxFilterTypes, messageChannelInboxFilterType: _messageChannelInboxFilterTypes)}';

                      return Container(
                        padding: EdgeInsets.only(bottom: verticalSpacing),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AuthImageView(oauth: e, size: 24),
                            SizedBox(width: horizontalSpacing * 2),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(e.email, style: baseStyle?.textColor(context.outlineVariant)),
                                  if (description.isNotEmpty) Text(description, style: context.bodyMedium?.textColor(context.inverseSurface)),
                                ],
                              ),
                            ),
                            SizedBox(width: horizontalSpacing),
                            if (e.needReAuth == true)
                              VisirButton(
                                type: VisirButtonAnimationType.scaleAndOpacity,
                                style: VisirButtonStyle(
                                  cursor: SystemMouseCursors.click,
                                  width: 28,
                                  height: 28,
                                  borderRadius: BorderRadius.circular(DesktopScaffold.cardRadius),
                                  backgroundColor: context.error,
                                ),
                                onTap: () => integrate(type: type),
                                child: VisirIcon(type: VisirIconType.caution, size: 16, color: context.onError, isSelected: true),
                              ),
                            if (e.needReAuth != true)
                              PopupMenu(
                                type: ContextMenuActionType.tap,
                                forcePopup: true,
                                location: PopupMenuLocation.bottom,
                                popup: ChatPrefFilterScreen(oAuth: e),
                                width: 200,
                                style: VisirButtonStyle(
                                  cursor: SystemMouseCursors.click,
                                  width: 28,
                                  height: 28,
                                  borderRadius: BorderRadius.circular(DesktopScaffold.cardRadius),
                                  backgroundColor: context.surface,
                                ),
                                options: VisirButtonOptions(message: context.tr.inbox_filter),
                                child: VisirIcon(type: VisirIconType.control, size: 16, isSelected: true),
                              ),
                            SizedBox(width: horizontalSpacing),
                            VisirButton(
                              type: VisirButtonAnimationType.scaleAndOpacity,
                              style: VisirButtonStyle(
                                cursor: SystemMouseCursors.click,
                                width: 28,
                                height: 28,
                                borderRadius: BorderRadius.circular(DesktopScaffold.cardRadius),
                                backgroundColor: context.surface,
                              ),
                              options: VisirButtonOptions(message: context.tr.disconnect),
                              onTap: () => unintegrate(oauth: e, type: type),
                              child: VisirIcon(type: VisirIconType.trash, size: 16, isSelected: true),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          )
          .toList(),
    );
  }
}
