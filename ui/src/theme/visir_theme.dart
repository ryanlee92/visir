import 'package:flutter/widgets.dart';

import 'visir_theme_data.dart';

class VisirTheme extends InheritedWidget {
  const VisirTheme({super.key, required this.data, required super.child});

  final VisirThemeData data;

  static VisirThemeData of(BuildContext context) {
    final theme = context.dependOnInheritedWidgetOfExactType<VisirTheme>();
    return theme?.data ?? VisirThemeData.fallback();
  }

  @override
  bool updateShouldNotify(VisirTheme oldWidget) => data != oldWidget.data;
}
