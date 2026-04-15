import 'icon_options.dart';
import 'snippet_utils.dart';

String buildInputSnippet({
  required String label,
  String? hintText,
  CuratedIconOption? prefixIcon,
  CuratedIconOption? suffixIcon,
  String? errorText,
  bool enabled = true,
}) {
  final safeLabel = label.trim().isEmpty ? 'Input Label' : label.trim();
  final safeHintText = hintText?.trim();
  final safeErrorText = errorText?.trim();
  final arguments = <String>[
    'label: ${dartStringLiteral(safeLabel)}',
    if (hasText(safeHintText)) 'hintText: ${dartStringLiteral(safeHintText!)}',
    if (prefixIcon != null) 'prefix: const Icon(${prefixIcon.iconExpression})',
    if (suffixIcon != null) 'suffix: const Icon(${suffixIcon.iconExpression})',
    if (hasText(safeErrorText))
      'errorText: ${dartStringLiteral(safeErrorText!)}',
    if (!enabled) 'enabled: false',
  ];

  return buildConstructorSnippet(
    constructor: 'VisirInput',
    namedArguments: arguments,
  );
}
