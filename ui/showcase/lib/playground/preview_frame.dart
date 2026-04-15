import 'package:flutter/material.dart';

class PreviewFrame extends StatelessWidget {
  const PreviewFrame({super.key, required this.child, this.minHeight = 160});

  final Widget child;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: minHeight),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Center(child: child),
    );
  }
}
