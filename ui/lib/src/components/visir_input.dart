import 'package:flutter/material.dart';

import '../foundation/visir_enums.dart';
import '../foundation/visir_tokens.dart';
import '../theme/visir_component_role_themes.dart';
import '../theme/visir_theme.dart';
import 'visir_icon_button.dart';
import 'visir_spinner.dart';

class VisirInput extends StatelessWidget {
  const VisirInput({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.suffix,
    this.errorText,
    this.enabled = true,
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
  final Widget? suffix;
  final String? errorText;
  final bool enabled;
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
    final hasError = _hasError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              color: tokens.colors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        _buildShell(tokens: tokens, control: control, hasError: hasError),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            errorText!.trim(),
            style: TextStyle(color: tokens.colors.danger, fontSize: 12),
          ),
        ],
      ],
    );
  }

  bool get _hasError => errorText != null && errorText!.trim().isNotEmpty;

  Widget _buildShell({
    required VisirTokens tokens,
    required VisirControlThemeData control,
    required bool hasError,
  }) {
    final effectiveMaxLines = maxLines ?? 1;
    final effectiveBorder = !enabled
        ? control.borders.disabled
        : hasError
        ? VisirBorderState(
            color: tokens.colors.danger,
            width: control.borders.base.width,
          )
        : control.borders.base;
    Widget shell({required bool hasText}) {
      final shouldShowClearButton =
          showClearButton && (controller == null || hasText);

      return Semantics(
        container: true,
        label: label,
        textField: true,
        child: Container(
          key: const ValueKey('visir-input-shell'),
          padding: const EdgeInsets.fromLTRB(6, 4, 6, 4),
          decoration: BoxDecoration(
            color: tokens.colors.surface,
            borderRadius: BorderRadius.circular(control.radius),
            border: Border.all(
              color: effectiveBorder.color,
              width: effectiveBorder.width,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (leading != null) ...[
                _buildLeadingButton(leading!),
                const SizedBox(width: 0),
              ] else
                SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: controller,
                    enabled: enabled,
                    autofocus: autofocus,
                    focusNode: focusNode,
                    onSubmitted: onSubmitted,
                    onChanged: onChanged,
                    maxLines: effectiveMaxLines,
                    minLines: 1,
                    textAlignVertical: effectiveMaxLines == 1
                        ? TextAlignVertical.top
                        : TextAlignVertical.top,
                    style: TextStyle(color: tokens.colors.text, height: 1.2),
                    decoration: InputDecoration.collapsed(
                      hintText: hintText,
                      hintStyle: TextStyle(color: tokens.colors.textMuted),
                    ),
                  ),
                ),
              ),
              if (suffix != null) ...[
                const SizedBox(width: 8),
                _buildTrailingButton(suffix!),
              ],
              if (isLoading) ...[
                const SizedBox(width: 8),
                const _SearchLoadingIndicator(),
                const SizedBox(width: 8),
              ],
              if (shouldShowClearButton) ...[
                const SizedBox(width: 8),
                _buildClearButton(
                  enabled
                      ? () {
                          controller?.clear();
                          onClear?.call();
                        }
                      : null,
                ),
                const SizedBox(width: 2),
              ],
            ],
          ),
        ),
      );
    }

    if (controller == null) {
      return shell(hasText: false);
    }

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller!,
      builder: (context, value, child) {
        final hasText = value.text.isNotEmpty;
        return shell(hasText: hasText);
      },
    );
  }

  VisirIconButton _buildLeadingButton(Widget leadingWidget) {
    return VisirIconButton(
      key: const ValueKey('visir-input-leading'),
      icon: leadingWidget,
      semanticLabel: 'Leading action',
      size: VisirButtonSize.md,
      tooltip: 'Leading action',
    );
  }

  VisirIconButton _buildTrailingButton(Widget trailingWidget) {
    return VisirIconButton(
      key: const ValueKey('visir-input-suffix'),
      icon: trailingWidget,
      semanticLabel: 'Trailing action',
      size: VisirButtonSize.md,
      tooltip: 'Trailing action',
    );
  }

  VisirIconButton _buildClearButton(VoidCallback? onPressed) {
    return VisirIconButton(
      key: const ValueKey('visir-input-clear'),
      icon: const Icon(Icons.close),
      semanticLabel: 'Clear',
      size: VisirButtonSize.sm,
      onPressed: onPressed,
      tooltip: 'Clear',
    );
  }
}

class _SearchLoadingIndicator extends StatelessWidget {
  const _SearchLoadingIndicator();

  @override
  Widget build(BuildContext context) {
    final tokens = VisirTheme.of(context).tokens;

    return SizedBox(
      width: 14,
      height: 14,
      child: CircularProgressIndicator(
        strokeWidth: 1.4,
        valueColor: AlwaysStoppedAnimation<Color>(tokens.colors.textMuted),
      ),
    );
  }
}
