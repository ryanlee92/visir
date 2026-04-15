import 'snippet_utils.dart';

String buildCardSnippet({
  Object variant = 'elevated',
  Object density = 'comfortable',
  bool isInteractive = false,
  String childSnippet = "const Text('Card content')",
}) {
  final variantName = enumName(variant);
  final densityName = enumName(density);
  final safeChildSnippet = childSnippet.trim().isEmpty
      ? "const Text('Card content')"
      : childSnippet.trim();
  final arguments = <String>[
    'child: $safeChildSnippet',
    if (variantName != 'elevated') 'variant: VisirCardVariant.$variantName',
    if (densityName != 'comfortable') 'density: VisirCardDensity.$densityName',
    if (isInteractive) 'onTap: () {}',
  ];

  return buildConstructorSnippet(
    constructor: 'VisirCard',
    namedArguments: arguments,
  );
}
