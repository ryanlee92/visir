import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/color_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TaskColorPickerWidget extends ConsumerStatefulWidget {
  final Color color;
  final void Function(Color color) onColorSelected;

  const TaskColorPickerWidget({super.key, required this.onColorSelected, required this.color});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TaskColorPickerWidgetState();
}

class _TaskColorPickerWidgetState extends ConsumerState<TaskColorPickerWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      decoration: BoxDecoration(color: context.surface, borderRadius: BorderRadius.circular(6)),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: Constants.taskColors
            .map(
              (c) => VisirButton(
                type: VisirButtonAnimationType.scaleAndOpacity,
                style: VisirButtonStyle(
                  cursor: SystemMouseCursors.click,
                  width: 32,
                  height: 32,
                  backgroundColor: c,
                  borderRadius: BorderRadius.circular(6),
                  border: widget.color.toHex() == c.toHex() ? Border.all(color: context.primary, width: 3, strokeAlign: BorderSide.strokeAlignOutside) : null,
                ),
                onTap: () async {
                  widget.onColorSelected(c);
                  context.pop();
                },
              ),
            )
            .toList(),
      ),
    );
  }
}
