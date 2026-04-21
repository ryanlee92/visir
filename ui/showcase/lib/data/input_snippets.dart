import 'package:visir_ui/visir_ui.dart';

import 'icon_options.dart';
import 'snippet_utils.dart';

String buildInputSnippet({
  required String label,
  String? hintText,
  CuratedIconOption? prefixIcon,
  CuratedIconOption? suffixIcon,
  CuratedIconOption? leadingIcon,
  String? errorText,
  bool enabled = true,
  VisirInputMode mode = VisirInputMode.standard,
  bool isLoading = false,
  bool showClearButton = false,
  int? maxLines,
}) {
  final safeLabel = label.trim().isEmpty ? 'Input Label' : label.trim();
  final safeHintText = hintText?.trim();
  final safeErrorText = errorText?.trim();
  final arguments = <String>[
    'label: ${dartStringLiteral(safeLabel)}',
    if (hasText(safeHintText)) 'hintText: ${dartStringLiteral(safeHintText!)}',
    if (mode != VisirInputMode.standard) 'mode: VisirInputMode.search',
    if (mode == VisirInputMode.search && leadingIcon != null)
      'leading: const Icon(${leadingIcon.iconExpression})',
    if (mode == VisirInputMode.standard && prefixIcon != null)
      'prefix: const Icon(${prefixIcon.iconExpression})',
    if (mode == VisirInputMode.standard && suffixIcon != null)
      'suffix: const Icon(${suffixIcon.iconExpression})',
    if (hasText(safeErrorText))
      'errorText: ${dartStringLiteral(safeErrorText!)}',
    if (!enabled) 'enabled: false',
    if (isLoading) 'isLoading: true',
    if (showClearButton) 'showClearButton: true',
    if (maxLines != null) 'maxLines: $maxLines',
  ];

  return buildConstructorSnippet(
    constructor: 'VisirInput',
    namedArguments: arguments,
  );
}
