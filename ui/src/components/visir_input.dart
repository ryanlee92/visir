import 'package:flutter/material.dart';

import '../theme/visir_theme.dart';

class VisirInput extends StatelessWidget {
  const VisirInput({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.prefix,
    this.suffix,
    this.errorText,
    this.enabled = true,
  });

  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final Widget? prefix;
  final Widget? suffix;
  final String? errorText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final tokens = VisirTheme.of(context).tokens;

    return Material(
      color: Colors.transparent,
      child: TextField(
        controller: controller,
        enabled: enabled,
        style: TextStyle(color: tokens.colors.text),
        decoration: InputDecoration(
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          labelStyle: TextStyle(
            color: tokens.colors.textMuted,
            fontWeight: FontWeight.w600,
          ),
          floatingLabelStyle: TextStyle(
            color: tokens.colors.textMuted,
            fontWeight: FontWeight.w600,
          ),
          hintText: hintText,
          hintStyle: TextStyle(color: tokens.colors.textMuted),
          errorText: errorText,
          prefix: prefix,
          suffix: suffix,
          filled: true,
          fillColor: tokens.colors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(tokens.radius.md),
            borderSide: BorderSide(color: tokens.colors.surfaceOutline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(tokens.radius.md),
            borderSide: BorderSide(color: tokens.colors.surfaceOutline),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(tokens.radius.md),
            borderSide: BorderSide(color: tokens.colors.surfaceOutline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(tokens.radius.md),
            borderSide: BorderSide(color: tokens.colors.accent),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(tokens.radius.md),
            borderSide: BorderSide(color: tokens.colors.danger),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(tokens.radius.md),
            borderSide: BorderSide(color: tokens.colors.danger),
          ),
        ),
      ),
    );
  }
}
