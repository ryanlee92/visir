import 'package:flutter/material.dart';

import '../foundation/visir_enums.dart';
import '../foundation/visir_tokens.dart';
import '../theme/visir_component_role_themes.dart';
import '../theme/visir_theme.dart';
import '../theme/visir_text_theme.dart';
import 'visir_icon_button.dart';
import 'visir_spinner.dart';

enum VisirInputBorder { none, base, success, error }

class VisirInput extends StatelessWidget {
  const VisirInput({
    super.key,
    this.label,
    this.border = VisirInputBorder.none,
    this.hintText,
    this.controller,
    this.suffix,
    this.suffixTooltip,
    this.suffixOnPressed,
    this.errorText,
    this.enabled = true,
    this.onSubmitted,
    this.onChanged,
    this.autofocus = false,
    this.focusNode,
    this.leading,
    this.leadingTooltip,
    this.leadingOnPressed,
    this.showClearButton = false,
    this.onClear,
    this.isLoading = false,
    this.maxLines,
  });

  final String? label;
  final VisirInputBorder border;
  final String? hintText;
  final TextEditingController? controller;
  final Widget? suffix;
  final String? suffixTooltip;
  final VoidCallback? suffixOnPressed;
  final String? errorText;
  final bool enabled;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final FocusNode? focusNode;
  final Widget? leading;
  final String? leadingTooltip;
  final VoidCallback? leadingOnPressed;
  final bool showClearButton;
  final VoidCallback? onClear;
  final bool isLoading;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final theme = VisirTheme.of(context);
    final tokens = theme.tokens;
    final text = theme.text;
    final control = theme.components.control;
    final hasError = _hasError;
    final labelText = _labelText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (labelText != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              labelText,
              style: text.label.copyWith(color: tokens.colors.textMuted),
            ),
          ),
        _buildShell(
          tokens: tokens,
          control: control,
          text: text,
          hasError: hasError,
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            errorText!.trim(),
            style: text.caption.copyWith(color: tokens.colors.danger),
          ),
        ],
      ],
    );
  }

  bool get _hasError => errorText != null && errorText!.trim().isNotEmpty;

  String? get _labelText {
    final value = label?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }

    return value;
  }

  Widget _buildShell({
    required VisirTokens tokens,
    required VisirControlThemeData control,
    required VisirTextThemeData text,
    required bool hasError,
  }) {
    final effectiveMaxLines = maxLines ?? 1;
    final effectiveBorder = hasError
        ? VisirBorderState(
            color: tokens.colors.danger,
            width: control.borders.base.width,
          )
        : switch (border) {
            VisirInputBorder.none => null,
            VisirInputBorder.base => control.borders.base,
            VisirInputBorder.success => VisirBorderState(
              color: tokens.colors.success,
              width: control.borders.base.width,
            ),
            VisirInputBorder.error => VisirBorderState(
              color: tokens.colors.danger,
              width: control.borders.base.width,
            ),
          };
    Widget shell({required bool hasText}) {
      final shouldShowClearButton =
          showClearButton && (controller == null || hasText);

      final border = effectiveBorder == null
          ? null
          : Border.all(
              color: effectiveBorder.color,
              width: effectiveBorder.width,
            );

      return Semantics(
        container: true,
        label: _labelText ?? hintText?.trim() ?? 'Input',
        textField: true,
        child: Container(
          key: const ValueKey('visir-input-shell'),
          padding: const EdgeInsets.fromLTRB(6, 4, 6, 4),
          decoration: BoxDecoration(
            color: tokens.colors.surface,
            borderRadius: BorderRadius.circular(control.radius),
            border: border,
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
                    style: text.body.copyWith(color: tokens.colors.text),
                    decoration: InputDecoration.collapsed(
                      hintText: hintText,
                      hintStyle: text.body.copyWith(
                        color: tokens.colors.textMuted,
                      ),
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
      semanticLabel: leadingTooltip ?? 'Leading action',
      size: VisirButtonSize.md,
      onPressed: leadingOnPressed,
      tooltip: leadingTooltip,
    );
  }

  VisirIconButton _buildTrailingButton(Widget trailingWidget) {
    return VisirIconButton(
      key: const ValueKey('visir-input-suffix'),
      icon: trailingWidget,
      semanticLabel: suffixTooltip ?? 'Trailing action',
      size: VisirButtonSize.md,
      onPressed: suffixOnPressed,
      tooltip: suffixTooltip,
    );
  }

  VisirIconButton _buildClearButton(VoidCallback? onPressed) {
    return VisirIconButton(
      key: const ValueKey('visir-input-clear'),
      icon: const Icon(Icons.close),
      semanticLabel: 'Clear',
      size: VisirButtonSize.sm,
      variant: VisirButtonVariant.ghost,
      onPressed: onPressed,
      tooltip: 'Clear',
    );
  }
}

class _SearchLoadingIndicator extends StatelessWidget {
  const _SearchLoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return VisirSpinner(
      size: VisirSpinnerSize.sm,
      tone: VisirSpinnerTone.neutral,
    );
  }
}
