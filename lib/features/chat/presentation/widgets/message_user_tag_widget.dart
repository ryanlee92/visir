import 'package:Visir/features/chat/domain/entities/message_member_entity.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:flutter/material.dart';

class MessageUserTagWidget extends StatefulWidget {
  final String text;
  final TextStyle defaultStyle;
  final bool isMe;
  final MessageMemberEntity member;
  final void Function({required String? userId, required String? channelId})? moveTochannel;

  MessageUserTagWidget({Key? key, required this.text, required this.defaultStyle, required this.isMe, required this.member, required this.moveTochannel})
    : super(key: key);

  @override
  State<MessageUserTagWidget> createState() => _MessageUserTagWidgetState();
}

class _MessageUserTagWidgetState extends State<MessageUserTagWidget> {
  bool get isMobileView => PlatformX.isMobileView;

  double get lineHeight => widget.defaultStyle.fontSize! * widget.defaultStyle.height!;

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: VisirButton(
        style: VisirButtonStyle(
          alignment: Alignment.topLeft,
          cursor: WidgetStateMouseCursor.clickable,
          backgroundColor: widget.isMe ? context.primary : context.tertiary,
          borderRadius: BorderRadius.circular(4),
        ),
        behavior: HitTestBehavior.opaque,
        type: VisirButtonAnimationType.scaleAndOpacity,
        onTap: () {
          if (widget.moveTochannel != null) {
            widget.moveTochannel!(userId: widget.member.id, channelId: null);
          }
        },
        child: Container(
          height: lineHeight,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          alignment: Alignment.center,
          child: Text(widget.text, style: widget.defaultStyle.textColor(widget.isMe ? context.onPrimary : context.onTertiary)),
        ),
      ),
    );
  }
}
