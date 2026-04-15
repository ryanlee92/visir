import 'package:flutter/material.dart';

class ShowcaseSectionLayout extends StatelessWidget {
  const ShowcaseSectionLayout({
    super.key,
    required this.preview,
    required this.controls,
    required this.snippet,
  });

  final Widget preview;
  final Widget controls;
  final Widget snippet;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1080) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: preview),
              const SizedBox(width: 16),
              Expanded(child: controls),
              const SizedBox(width: 16),
              Expanded(child: snippet),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            preview,
            const SizedBox(height: 16),
            controls,
            const SizedBox(height: 16),
            snippet,
          ],
        );
      },
    );
  }
}
