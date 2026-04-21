import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../ui/visir_ui.dart';

void main() {
  test('VisirTextThemeData copyWith preserves unchanged styles', () {
    final fallback = VisirTextThemeData.fallback(
      VisirThemeData.fallback().tokens.colors,
    );
    final updated = fallback.copyWith(
      title: fallback.title.copyWith(fontSize: 29),
    );

    expect(updated.title.fontSize, 29);
    expect(updated.body, fallback.body);
    expect(updated.label, fallback.label);
  });

  test('VisirTextThemeData equality follows style values', () {
    final colors = VisirThemeData.fallback().tokens.colors;
    final first = VisirTextThemeData.fallback(colors);
    final second = VisirTextThemeData.fallback(colors);

    expect(first, equals(second));
    expect(first.hashCode, equals(second.hashCode));
  });
}
