import 'package:flutter/material.dart';

class VisirEmptyState extends StatelessWidget {
  const VisirEmptyState({
    super.key,
    required this.title,
    required this.description,
    this.action,
  });

  final String title;
  final String description;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title),
        const SizedBox(height: 8),
        Text(description, textAlign: TextAlign.center),
        if (action != null) ...[const SizedBox(height: 16), action!],
      ],
    );
  }
}
