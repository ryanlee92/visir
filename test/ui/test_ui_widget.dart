import 'package:flutter/material.dart';

import '../../test/testable_widget.dart';
import '../../ui/visir_ui.dart';

Widget makeUiTestableWidget({required Widget child}) {
  return makeTestableWidget(
    child: VisirTheme(
      data: VisirThemeData.fallback(),
      child: Center(child: child),
    ),
  );
}
