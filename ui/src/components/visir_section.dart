import 'package:flutter/material.dart';

class VisirSection extends StatelessWidget {
  const VisirSection({super.key, this.title, required this.child});

  final String? title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null) ...[Text(title!), const SizedBox(height: 12)],
        child,
      ],
    );
  }
}
