import 'icon_options.dart';
import 'snippet_utils.dart';

String buildButtonSnippet({
  required String label,
  Object variant = 'primary',
  Object size = 'md',
  bool isLoading = false,
  bool isExpanded = false,
  Object border = 'none',
  bool showShadow = true,
  CuratedIconOption? leadingIcon,
  CuratedIconOption? trailingIcon,
  String? tooltip,
  bool enabled = true,
}) {
  final variantName = enumName(variant);
  final sizeName = enumName(size);
  final borderName = enumName(border);
  final arguments = <String>[
    'label: ${dartStringLiteral(label)}',
    if (variantName != 'primary') 'variant: VisirButtonVariant.$variantName',
    if (sizeName != 'md') 'size: VisirButtonSize.$sizeName',
    if (borderName != 'none') 'border: VisirButtonBorder.$borderName',
    if (!showShadow) 'showShadow: false',
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
  Object border = 'none',
  bool showShadow = false,
  String? tooltip,
  bool enabled = true,
}) {
  final variantName = enumName(variant);
  final sizeName = enumName(size);
  final borderName = enumName(border);
  final arguments = <String>[
    'icon: const Icon(${icon.iconExpression})',
    'semanticLabel: ${dartStringLiteral(semanticLabel)}',
    if (variantName != 'secondary') 'variant: VisirButtonVariant.$variantName',
    if (sizeName != 'md') 'size: VisirButtonSize.$sizeName',
    if (borderName != 'none') 'border: VisirButtonBorder.$borderName',
    if (showShadow) 'showShadow: true',
    if (hasText(tooltip)) 'tooltip: ${dartStringLiteral(tooltip!.trim())}',
    'onPressed: ${enabled ? '() {}' : 'null'}',
  ];

  return buildConstructorSnippet(
    constructor: 'VisirIconButton',
    namedArguments: arguments,
  );
}
