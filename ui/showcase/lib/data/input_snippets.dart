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
  final arguments = <String>[
    'label: ${dartStringLiteral(label)}',
    if (hasText(hintText)) 'hintText: ${dartStringLiteral(hintText!.trim())}',
    if (prefixIcon != null) 'prefix: const Icon(${prefixIcon.iconExpression})',
    if (suffixIcon != null) 'suffix: const Icon(${suffixIcon.iconExpression})',
    if (hasText(errorText)) 'errorText: ${dartStringLiteral(errorText!.trim())}',
    if (!enabled) 'enabled: false',
  ];

  return buildConstructorSnippet(
    constructor: 'VisirInput',
    namedArguments: arguments,
  );
}
