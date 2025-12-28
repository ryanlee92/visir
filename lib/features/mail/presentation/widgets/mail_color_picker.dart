import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:flutter/material.dart';

enum MailColorPickerType { both, background, text }

class MailColorPicker extends StatefulWidget {
  const MailColorPicker({
    required this.backgroundColor,
    required this.position,
    required this.hideMenu,
    required this.onChangeBackgroundColor,
    required this.onChangeFontColor,
    required this.type,
    this.initialFontColor,
    this.initialBackgroundColor,
    super.key,
  });

  final Color? backgroundColor;
  final Offset position;
  final VoidCallback hideMenu;
  final void Function(Color? color) onChangeFontColor;
  final void Function(Color? color) onChangeBackgroundColor;
  final Color? initialFontColor;
  final Color? initialBackgroundColor;
  final MailColorPickerType type;

  @override
  _MailColorPickerState createState() => _MailColorPickerState();
}

class _MailColorPickerState extends State<MailColorPicker> {
  Color? fontColor;
  Color? backgroundColor;

  MailColorPickerType get type => widget.type;

  bool get showBackgroundColorPicker => [MailColorPickerType.both, MailColorPickerType.background].contains(type);

  bool get showTextColorPicker => [MailColorPickerType.both, MailColorPickerType.text].contains(type);

  double get width => type == MailColorPickerType.both ? 536 : 272;

  @override
  initState() {
    super.initState();
    fontColor = widget.initialFontColor;
    backgroundColor = widget.initialBackgroundColor;
  }

  Widget buildColorPicker({required void Function(BuildContext context, Color? color) onRequestChangeColor, required Color? currentColor}) {
    return Column(
      children: [
        Wrap(
          spacing: 2,
          children:
              [
                Colors.white,
                Colors.grey.shade100,
                Colors.grey.shade200,
                Colors.grey.shade300,
                Colors.grey.shade400,
                Colors.grey.shade500,
                Colors.grey.shade600,
                Colors.grey.shade700,
                Colors.grey.shade800,
                Colors.grey.shade900,
                Colors.black,
              ].map((color) {
                return VisirButton(
                  type: VisirButtonAnimationType.scaleAndOpacity,
                  style: VisirButtonStyle(width: 20, height: 20, backgroundColor: color),
                  onTap: () => onRequestChangeColor(context, color),
                  child: color == currentColor
                      ? VisirIcon(type: VisirIconType.check, size: 16, color: color.computeLuminance() > 0.6 ? Colors.black : Colors.white)
                      : null,
                );
              }).toList(),
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 2,
          children:
              [
                Colors.red.shade500,
                Colors.deepOrange.shade500,
                Colors.orange.shade500,
                Colors.yellow.shade500,
                Colors.lightGreen.shade500,
                Colors.green.shade500,
                Colors.teal.shade500,
                Colors.lightBlue.shade500,
                Colors.indigo.shade500,
                Colors.deepPurple.shade500,
                Colors.purple.shade500,
              ].map((color) {
                return VisirButton(
                  type: VisirButtonAnimationType.scaleAndOpacity,
                  style: VisirButtonStyle(width: 20, height: 20, backgroundColor: color),
                  onTap: () => onRequestChangeColor(context, color),
                  child: color == currentColor ? VisirIcon(type: VisirIconType.check, size: 16, color: Colors.white) : null,
                );
              }).toList(),
        ),
        SizedBox(height: 12),
        Container(
          height: 196,
          child: Wrap(
            spacing: 2,
            runSpacing: 2,
            direction: Axis.vertical,
            children:
                [
                      Colors.red,
                      Colors.deepOrange,
                      Colors.orange,
                      Colors.yellow,
                      Colors.lightGreen,
                      Colors.green,
                      Colors.teal,
                      Colors.lightBlue,
                      Colors.indigo,
                      Colors.deepPurple,
                      Colors.purple,
                    ]
                    .map((color) {
                      return [50, 100, 200, 300, 400, 600, 700, 800, 900].map(
                        (shade) => VisirButton(
                          type: VisirButtonAnimationType.scaleAndOpacity,
                          style: VisirButtonStyle(width: 20, height: 20, backgroundColor: color[shade]),
                          onTap: () => onRequestChangeColor(context, color[shade]),
                          child: color[shade] == currentColor
                              ? VisirIcon(type: VisirIconType.check, size: 16, color: shade < 200 ? Colors.black : Colors.white)
                              : null,
                        ),
                      );
                    })
                    .expand((e) => e)
                    .toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 358,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? context.surface,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [BoxShadow(color: Color(0x3F000000), blurRadius: 12, offset: Offset(0, 4), spreadRadius: 0)],
      ),
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          if (showBackgroundColorPicker)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr.mail_toolbar_color_picker_background_color,
                    style: context.textTheme.titleSmall?.textColor(context.outlineVariant).appFont(context),
                  ),
                  SizedBox(height: 12),
                  VisirButton(
                    type: VisirButtonAnimationType.scaleAndOpacity,
                    onTap: () {
                      widget.onChangeBackgroundColor(null);
                      backgroundColor = null;
                      setState(() {});
                    },
                    style: VisirButtonStyle(
                      height: 24,
                      backgroundColor: context.surfaceVariant,
                      borderRadius: BorderRadius.circular(4),
                      alignment: Alignment.center,
                    ),
                    child: Text(
                      context.tr.mail_toolbar_color_picker_reset_to_default,
                      style: context.textTheme.labelMedium?.textColor(context.outlineVariant).appFont(context),
                    ),
                  ),
                  SizedBox(height: 12),
                  buildColorPicker(
                    onRequestChangeColor: (context, color) {
                      widget.onChangeBackgroundColor(color);
                      backgroundColor = color;
                      setState(() {});
                    },
                    currentColor: backgroundColor,
                  ),
                ],
              ),
            ),
          if (type == MailColorPickerType.both) SizedBox(width: 24),
          if (showTextColorPicker)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr.mail_toolbar_color_picker_font_color,
                    style: context.textTheme.titleSmall?.textColor(context.outlineVariant).appFont(context),
                  ),
                  SizedBox(height: 12),
                  VisirButton(
                    type: VisirButtonAnimationType.scaleAndOpacity,
                    onTap: () {
                      widget.onChangeFontColor(null);
                      fontColor = null;
                      setState(() {});
                    },
                    style: VisirButtonStyle(
                      height: 24,
                      backgroundColor: context.surfaceVariant,
                      borderRadius: BorderRadius.circular(4),
                      alignment: Alignment.center,
                    ),
                    child: Text(
                      context.tr.mail_toolbar_color_picker_reset_to_default,
                      style: context.textTheme.labelMedium?.textColor(context.outlineVariant).appFont(context),
                    ),
                  ),
                  SizedBox(height: 12),
                  buildColorPicker(
                    onRequestChangeColor: (context, color) {
                      widget.onChangeFontColor(color);
                      fontColor = color;
                      setState(() {});
                    },
                    currentColor: fontColor,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
