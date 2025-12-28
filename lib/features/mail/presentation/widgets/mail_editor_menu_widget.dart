import 'package:flutter/material.dart';

class MailEditorMenuWidget extends StatefulWidget {
  final List<MenuItem>? items;

  final Widget Function(GlobalKey key) builder;
  const MailEditorMenuWidget({Key? key, required this.builder, this.items}) : super(key: key);

  @override
  _MailEditorMenuWidgetState createState() => _MailEditorMenuWidgetState();
}

class _MailEditorMenuWidgetState extends State<MailEditorMenuWidget> {
  GlobalKey key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return widget.builder(key);
  }
}

class MenuItem {
  final String text;
  final TextStyle? textStyle;
  final Widget? leading;
  final VoidCallback onTap;

  const MenuItem({required this.text, this.leading, required this.onTap, this.textStyle});
}
