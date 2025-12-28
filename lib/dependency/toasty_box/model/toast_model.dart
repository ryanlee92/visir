import 'package:flutter/material.dart';

class ToastModel {
  final TextSpan message;
  final List<ToastButton> buttons;

  ToastModel({
    required this.message,
    required this.buttons,
  });
}

class ToastButton {
  final String text;
  final void Function(ToastModel) onTap;
  final Color color;
  final Color textColor;

  ToastButton({
    required this.color,
    required this.textColor,
    required this.text,
    required this.onTap,
  });
}
