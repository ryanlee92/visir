import 'package:flutter/material.dart';
import 'package:visir_ui/visir_ui.dart';

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
    final gap = VisirTheme.of(context).components.surface.padding.comfortable;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1080) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: preview),
              SizedBox(width: gap),
              Expanded(child: controls),
              SizedBox(width: gap),
              Expanded(child: snippet),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            preview,
            SizedBox(height: gap),
            controls,
            SizedBox(height: gap),
            snippet,
          ],
        );
      },
    );
  }
}
