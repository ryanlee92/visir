import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:flutter/material.dart';

class NewMessageWidget extends StatefulWidget {
  final ScrollController? scrollController;
  final int count;
  final bool isReverse;

  const NewMessageWidget({super.key, this.scrollController, this.isReverse = false, this.count = 1});

  @override
  State<NewMessageWidget> createState() => _NewMessageWidgetState();
}

class _NewMessageWidgetState extends State<NewMessageWidget> {
  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: VisirButton(
        type: VisirButtonAnimationType.scaleAndOpacity,
        onTap: () {
          widget.scrollController?.animateTo(
            widget.isReverse ? 0 : widget.scrollController?.position.maxScrollExtent ?? 0,
            duration: Duration(milliseconds: 150),
            curve: Curves.easeInOut,
          );
        },
        style: VisirButtonStyle(
          padding: EdgeInsets.only(left: 10, right: 8, top: 4, bottom: 4),
          backgroundColor: context.tertiary,
          borderRadius: BorderRadius.circular(12),
          height: 24,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.count > 1 ? context.tr.new_messages(widget.count) : context.tr.new_message, style: context.bodyLarge?.textColor(context.onPrimary)),
            SizedBox(width: 4),
            VisirIcon(type: VisirIconType.arrowDown, size: 12, color: context.onPrimary),
          ],
        ),
      ),
    );
  }
}
