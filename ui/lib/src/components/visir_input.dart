import 'package:flutter/material.dart';

import '../foundation/visir_enums.dart';
import '../foundation/visir_tokens.dart';
import '../theme/visir_component_role_themes.dart';
import '../theme/visir_theme.dart';
import 'visir_spinner.dart';

enum VisirInputMode { standard, search }

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
    this.mode = VisirInputMode.standard,
    this.onSubmitted,
    this.onChanged,
    this.autofocus = false,
    this.focusNode,
    this.leading,
    this.showClearButton = false,
    this.onClear,
    this.isLoading = false,
    this.maxLines,
  });

  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final Widget? prefix;
  final Widget? suffix;
  final String? errorText;
  final bool enabled;
  final VisirInputMode mode;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final FocusNode? focusNode;
  final Widget? leading;
  final bool showClearButton;
  final VoidCallback? onClear;
  final bool isLoading;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final theme = VisirTheme.of(context);
    final tokens = theme.tokens;
    final control = theme.components.control;

    return switch (mode) {
      VisirInputMode.standard => _buildStandard(tokens, control),
      VisirInputMode.search => _buildSearch(tokens, control),
    };
  }

  Widget _buildStandard(
    VisirTokens tokens,
    VisirControlThemeData control,
  ) {
    return Material(
      color: Colors.transparent,
      child: TextField(
        controller: controller,
        enabled: enabled,
        maxLines: maxLines,
        autofocus: autofocus,
        focusNode: focusNode,
        onSubmitted: onSubmitted,
        onChanged: onChanged,
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

  Widget _buildSearch(
    VisirTokens tokens,
    VisirControlThemeData control,
  ) {
    final effectiveMaxLines = maxLines ?? 1;

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: tokens.colors.surface,
          borderRadius: BorderRadius.circular(control.radius),
          border: Border.all(
            color: enabled ? control.borders.base.color : control.borders.disabled.color,
            width: enabled ? control.borders.base.width : control.borders.disabled.width,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildLeading(tokens),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled,
                autofocus: autofocus,
                focusNode: focusNode,
                onSubmitted: onSubmitted,
                onChanged: onChanged,
                maxLines: effectiveMaxLines,
                style: TextStyle(color: tokens.colors.text),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  hintText: hintText,
                  hintStyle: TextStyle(color: tokens.colors.textMuted),
                  errorText: errorText,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (isLoading) ...[
              const SizedBox(width: 8),
              const VisirSpinner(
                size: VisirSpinnerSize.sm,
                tone: VisirSpinnerTone.inverse,
              ),
            ],
            if (showClearButton) ...[
              const SizedBox(width: 6),
              IconButton(
                onPressed: enabled ? onClear : null,
                icon: Icon(
                  Icons.close,
                  size: 16,
                  color: tokens.colors.textMuted,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(width: 28, height: 28),
                visualDensity: VisualDensity.compact,
                splashRadius: 16,
                tooltip: 'Clear',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLeading(VisirTokens tokens) {
    if (leading != null) {
      return leading!;
    }

    return Icon(
      Icons.search,
      size: 16,
      color: tokens.colors.textMuted,
    );
  }

  OutlineInputBorder _border(double radius, VisirBorderState state) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: state.color, width: state.width),
    );
  }
}
