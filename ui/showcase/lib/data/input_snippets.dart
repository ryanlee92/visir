import 'package:visir_ui/visir_ui.dart';

import 'icon_options.dart';
import 'snippet_utils.dart';

String buildInputSnippet({
  String? label,
  String? hintText,
  CuratedIconOption? suffixIcon,
  CuratedIconOption? leadingIcon,
  String? errorText,
  VisirInputBorder border = VisirInputBorder.none,
  bool enabled = true,
  bool isLoading = false,
  bool showClearButton = false,
  int? maxLines,
}) {
  final safeLabel = label?.trim();
  final safeHintText = hintText?.trim();
  final safeErrorText = errorText?.trim();
  final arguments = <String>[
    if (hasText(safeLabel)) 'label: ${dartStringLiteral(safeLabel!)}',
    if (hasText(safeHintText)) 'hintText: ${dartStringLiteral(safeHintText!)}',
    if (leadingIcon != null)
      'leading: const Icon(${leadingIcon.iconExpression})',
    if (suffixIcon != null) 'suffix: const Icon(${suffixIcon.iconExpression})',
    if (hasText(safeErrorText))
      'errorText: ${dartStringLiteral(safeErrorText!)}',
    if (border != VisirInputBorder.none) 'border: VisirInputBorder.${border.name}',
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
