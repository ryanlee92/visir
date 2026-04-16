import 'package:flutter/material.dart';

import '../theme/visir_component_role_themes.dart';
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
    final theme = VisirTheme.of(context);
    final tokens = theme.tokens;
    final control = theme.components.control;

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
          border: _border(control.radius, control.borders.base),
          enabledBorder: _border(control.radius, control.borders.base),
          disabledBorder: _border(control.radius, control.borders.disabled),
          focusedBorder: _border(control.radius, control.borders.focus),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(control.radius),
            borderSide: BorderSide(color: tokens.colors.danger),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(control.radius),
            borderSide: BorderSide(color: tokens.colors.danger),
          ),
        ),
      ),
    );
  }

  OutlineInputBorder _border(double radius, VisirBorderState state) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: state.color, width: state.width),
    );
  }
}
