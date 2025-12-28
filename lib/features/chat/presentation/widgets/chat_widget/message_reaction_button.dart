import 'package:Visir/config/providers.dart';
import 'package:Visir/features/chat/actions.dart';
import 'package:Visir/features/chat/domain/entities/message_channel_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_emoji_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_member_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_reaction_entity.dart';
import 'package:Visir/features/common/presentation/utils/extensions/list_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/proxy_network_image.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:emoji_extension/emoji_extension.dart' hide Color;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MessageReactionButton extends ConsumerStatefulWidget {
  final MessageChannelEntity channel;
  final MessageEntity message;
  final MessageEntity? parentMessage;
  final MessageReactionEntity reaction;
  final List<MessageEmojiEntity> emojis;
  final List<MessageMemberEntity> members;
  final TabType tabType;
  final OAuthEntity? oauth;
  final Color backgroundColor;

  const MessageReactionButton({
    super.key,
    required this.channel,
    required this.message,
    required this.parentMessage,
    required this.reaction,
    required this.emojis,
    required this.members,
    required this.tabType,
    required this.oauth,
    required this.backgroundColor,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MessageEmojiButtonState();
}

class _MessageEmojiButtonState extends ConsumerState<MessageReactionButton> {
  MessageReactionEntity get reaction => widget.reaction;

  MessageEntity get message => widget.message;

  MessageEmojiEntity? get emoji => widget.emojis.firstWhereOrNull((e) => e.name == reaction.name);
  bool get isAlias => emoji?.isAlias ?? false;

  MessageEmojiEntity? get originalCustomEmoji => isAlias ? widget.emojis.firstWhereOrNull((e) => e.name == emoji?.aliasOriginalName) : null;
  Emoji? get originalEmoji => isAlias ? Emojis.getOneOrNull(emoji?.aliasOriginalName ?? '') : null;

  bool get isUserReact => reaction.users.contains(widget.channel.meId);

  bool get isReply => widget.parentMessage != null;

  bool get isMobileView => PlatformX.isMobileView;

  String get userNames {
    List<String> names = [];
    List<String> users = [...reaction.users];

    if (users.contains(widget.channel.meId)) {
      names.add(context.tr.chat_reaction_you);
      users.remove(widget.channel.meId);
    }

    users.forEach((e) {
      final member = widget.members.firstWhereOrNull((m) => m.id == e);
      if (member != null) names.add(member.displayName ?? '');
    });

    return names.join(', ');
  }

  List<MessageMemberEntity> get reactingMembers {
    return widget.members.where((e) => reaction.users.contains(e.id)).toList().unique((e) => e.id);
  }

  Widget customEmojiWidget({required String url}) {
    return ProxyNetworkImage(imageUrl: url, oauth: widget.oauth, width: 18, height: 18, alignment: Alignment.center, fit: BoxFit.cover);
  }

  Widget emojiWidget({required String text}) {
    return Text(text, style: context.titleSmall?.textColor(context.outlineVariant));
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: VisirButton(
        type: VisirButtonAnimationType.scaleAndOpacity,
        style: VisirButtonStyle(
          height: 24,
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          backgroundColor: isUserReact ? context.secondary : widget.backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        options: VisirButtonOptions(
          tooltipLocation: VisirButtonTooltipLocation.top,
          span: WidgetSpan(
            alignment: PlaceholderAlignment.aboveBaseline,
            baseline: TextBaseline.alphabetic,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 184 - 16),
              child: Text(userNames, style: context.bodyMedium?.textColor(context.outlineVariant), textAlign: TextAlign.center),
            ),
          ),
        ),
        onLongPress: PlatformX.isDesktopView
            ? null
            : () {
                Utils.showBottomDialog(
                  title: TextSpan(
                    children: [
                      if (emoji?.url != null)
                        WidgetSpan(
                          child: ProxyNetworkImage(
                            imageUrl: emoji!.url!,
                            oauth: widget.oauth,
                            width: 24,
                            height: 24,
                            alignment: Alignment.center,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        TextSpan(text: Emojis.getOneOrNull(reaction.displayName ?? '')?.value ?? ''),
                      WidgetSpan(child: SizedBox(width: 6)),
                      TextSpan(text: reaction.count.toString()),
                    ],
                  ),
                  body: Column(
                    children: reactingMembers
                        .map(
                          (e) => Padding(
                            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: ProxyNetworkImage(imageUrl: e.profileImage ?? '', oauth: widget.oauth, width: 32, height: 32),
                                ),
                                SizedBox(width: 8),
                                Text(e.displayName ?? '', style: context.titleMedium?.textColor(context.onSurfaceVariant)),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                );
              },
        onTap: () {
          if (reaction.name == null) return;
          if (isUserReact) {
            if (isReply) {
              MessageAction.removeReplyReaction(
                tabType: widget.tabType,
                message: widget.message,
                emoji: reaction.name!,
                userId: widget.channel.meId,
                channel: widget.channel,
                parent: widget.parentMessage!,
              );
            } else {
              MessageAction.removeReaction(
                tabType: widget.tabType,
                message: widget.message,
                emoji: reaction.name!,
                userId: widget.channel.meId,
                channel: widget.channel,
              );
            }
          } else {
            if (isReply) {
              MessageAction.addReplyReaction(
                tabType: widget.tabType,
                message: widget.message,
                emoji: reaction.name!,
                userId: widget.channel.meId,
                channel: widget.channel,
                parent: widget.parentMessage!,
              );
            } else {
              MessageAction.addReaction(
                tabType: widget.tabType,
                message: widget.message,
                emoji: reaction.name!,
                userId: widget.channel.meId,
                channel: widget.channel,
              );
            }
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            isAlias
                ? (originalEmoji == null ? customEmojiWidget(url: originalCustomEmoji?.url ?? '') : emojiWidget(text: originalEmoji?.value ?? ''))
                : emoji?.url != null
                ? customEmojiWidget(url: emoji!.url!)
                : emojiWidget(text: Emojis.getOneOrNull(reaction.displayName ?? '')?.value ?? ''),
            SizedBox(width: 6),
            Text(reaction.count.toString(), style: context.labelMedium?.textColor(isUserReact ? context.onSecondary : context.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
