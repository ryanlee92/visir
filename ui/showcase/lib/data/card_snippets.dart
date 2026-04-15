import 'snippet_utils.dart';

String buildCardSnippet({
  Object variant = 'elevated',
  Object density = 'comfortable',
  bool isInteractive = false,
  String childSnippet = "const Text('Card content')",
}) {
  final variantName = enumName(variant);
  final densityName = enumName(density);
  final arguments = <String>[
    'child: $childSnippet',
    if (variantName != 'elevated') 'variant: VisirCardVariant.$variantName',
    if (densityName != 'comfortable')
      'density: VisirCardDensity.$densityName',
    if (isInteractive) 'onTap: () {}',
  ];

  return buildConstructorSnippet(
    constructor: 'VisirCard',
    namedArguments: arguments,
  );
}
