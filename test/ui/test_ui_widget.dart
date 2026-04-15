import 'package:flutter/material.dart';

import '../../ui/visir_ui.dart';

Widget makeUiTestableWidget({required Widget child}) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: VisirTheme(data: VisirThemeData.fallback(), child: child),
  );
}
