import 'package:flutter/material.dart';
import 'package:visir_ui/visir_ui.dart';

import 'showcase_page.dart';
import 'showcase_theme.dart';

class ShowcaseApp extends StatelessWidget {
  const ShowcaseApp({super.key, this.visirThemeData});

  final VisirThemeData? visirThemeData;

  @override
  Widget build(BuildContext context) {
    final resolvedThemeData = visirThemeData ?? VisirThemeData.fallback();

    return VisirTheme(
      data: resolvedThemeData,
      child: MaterialApp(
        title: 'Visir UI Showcase',
        debugShowCheckedModeBanner: false,
        theme: ShowcaseTheme.build(resolvedThemeData),
        home: const ShowcasePage(),
      ),
    );
  }
}
