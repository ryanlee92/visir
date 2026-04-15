import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../ui/visir_ui.dart';
import '../test_ui_widget.dart';

void main() {
  testWidgets('VisirTheme.of returns fallback data without an ancestor', (
    tester,
  ) async {
    late VisirThemeData data;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Builder(
          builder: (context) {
            data = VisirTheme.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(data.tokens.colors.accent, const Color(0xFF7C5DFF));
    expect(data.tokens.radius.md, 16);
  });

  testWidgets('VisirTheme merges custom data over defaults', (tester) async {
    late VisirThemeData data;

    await tester.pumpWidget(
      makeUiTestableWidget(
        child: VisirTheme(
          data: VisirThemeData.fallback().copyWith(
            tokens: VisirTokens.fallback().copyWith(
              colors: const VisirColors(
                accent: Color(0xFFAA66FF),
                accentStrong: Color(0xFF7B39F4),
                surface: Color(0xCC1F1B33),
                surfaceMuted: Color(0x9927253F),
                surfaceOutline: Color(0x33FFFFFF),
                text: Color(0xFFF8F7FF),
                textMuted: Color(0xCCDBD7F3),
                textInverse: Color(0xFF110F1C),
                danger: Color(0xFFD94B67),
                success: Color(0xFF3BB273),
                warning: Color(0xFFF2A93B),
              ),
            ),
          ),
          child: Builder(
            builder: (context) {
              data = VisirTheme.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    expect(data.tokens.colors.accent, const Color(0xFFAA66FF));
  });
}
