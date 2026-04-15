import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../ui/visir_ui.dart';
import '../test_ui_widget.dart';

void main() {
  test('VisirTheme.updateShouldNotify is false for equivalent data', () {
    final oldTheme = VisirTheme(
      data: VisirThemeData.fallback(),
      child: const SizedBox.shrink(),
    );
    final newTheme = VisirTheme(
      data: VisirThemeData.fallback(),
      child: const SizedBox.shrink(),
    );

    expect(newTheme.updateShouldNotify(oldTheme), isFalse);
  });

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

  testWidgets('VisirTheme merges custom token data over defaults', (
    tester,
  ) async {
    late VisirThemeData data;
    final fallback = VisirThemeData.fallback();

    await tester.pumpWidget(
      makeUiTestableWidget(
        child: VisirTheme(
          data: fallback.copyWith(
            tokens: fallback.tokens.copyWith(
              colors: fallback.tokens.colors.copyWith(
                accent: const Color(0xFFAA66FF),
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
    expect(data.tokens.colors.text, fallback.tokens.colors.text);
    expect(data.tokens.radius.md, fallback.tokens.radius.md);
  });
}
