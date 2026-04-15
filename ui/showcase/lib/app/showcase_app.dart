import 'package:flutter/material.dart';

import 'showcase_page.dart';
import 'showcase_theme.dart';

class ShowcaseApp extends StatelessWidget {
  const ShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Visir UI Showcase',
      debugShowCheckedModeBanner: false,
      theme: ShowcaseTheme.build(),
      home: const ShowcasePage(),
    );
  }
}
