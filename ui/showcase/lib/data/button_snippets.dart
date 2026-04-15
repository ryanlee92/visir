import 'icon_options.dart';
import 'snippet_utils.dart';

String buildButtonSnippet({
  required String label,
  Object variant = 'primary',
  Object size = 'md',
  bool isLoading = false,
  bool isExpanded = false,
  CuratedIconOption? leadingIcon,
  CuratedIconOption? trailingIcon,
  String? tooltip,
  bool enabled = true,
}) {
  final variantName = enumName(variant);
  final sizeName = enumName(size);
  final arguments = <String>[
    'label: ${dartStringLiteral(label)}',
    if (variantName != 'primary') 'variant: VisirButtonVariant.$variantName',
    if (sizeName != 'md') 'size: VisirButtonSize.$sizeName',
    if (leadingIcon != null)
      'leading: const Icon(${leadingIcon.iconExpression})',
    if (trailingIcon != null)
      'trailing: const Icon(${trailingIcon.iconExpression})',
    if (isLoading) 'isLoading: true',
    if (isExpanded) 'isExpanded: true',
    if (hasText(tooltip)) 'tooltip: ${dartStringLiteral(tooltip!.trim())}',
    'onPressed: ${enabled ? '() {}' : 'null'}',
  ];

  return buildConstructorSnippet(
    constructor: 'VisirButton',
    namedArguments: arguments,
  );
}

String buildIconButtonSnippet({
  required CuratedIconOption icon,
  required String semanticLabel,
  Object variant = 'secondary',
  Object size = 'md',
  String? tooltip,
  bool enabled = true,
}) {
  final variantName = enumName(variant);
  final sizeName = enumName(size);
  final arguments = <String>[
    'icon: const Icon(${icon.iconExpression})',
    'semanticLabel: ${dartStringLiteral(semanticLabel)}',
    if (variantName != 'secondary')
      'variant: VisirButtonVariant.$variantName',
    if (sizeName != 'md') 'size: VisirButtonSize.$sizeName',
    if (hasText(tooltip)) 'tooltip: ${dartStringLiteral(tooltip!.trim())}',
    'onPressed: ${enabled ? '() {}' : 'null'}',
  ];

  return buildConstructorSnippet(
    constructor: 'VisirIconButton',
    namedArguments: arguments,
  );
}
