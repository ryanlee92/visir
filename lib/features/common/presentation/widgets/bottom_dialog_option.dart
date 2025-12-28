import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BottomDialogOption extends ConsumerStatefulWidget {
  final String title;
  final VisirIconType icon;
  final bool? isWarning;
  final void Function() onTap;

  const BottomDialogOption({required this.icon, required this.title, this.isWarning, required this.onTap});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BottomDialogOptionState();
}

class _BottomDialogOptionState extends ConsumerState<BottomDialogOption> {
  bool get isWarning => widget.isWarning ?? false;

  @override
  Widget build(BuildContext context) {
    return VisirButton(
      type: VisirButtonAnimationType.scaleAndOpacity,
      style: VisirButtonStyle(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16)),
      onTap: () {
        context.pop();
        widget.onTap();
      },
      child: Row(
        children: [
          VisirIcon(type: widget.icon, size: 20, color: isWarning ? context.error : null, isSelected: true),
          const SizedBox(width: 16),
          Expanded(child: Text(widget.title, style: context.titleSmall?.textColor(isWarning ? context.error : context.shadow))),
        ],
      ),
    );
  }
}
