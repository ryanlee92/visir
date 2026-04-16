import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visir_ui/visir_ui.dart';
import 'package:visir_ui_showcase/app/showcase_page.dart';
import 'package:visir_ui_showcase/sections/showcase_section_layout.dart';

void main() {
  testWidgets('showcase page scroll padding follows shared role tokens', (
    tester,
  ) async {
    final themeData = _customVisirThemeData();
    tester.view.physicalSize = const Size(640, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: VisirTheme(data: themeData, child: const ShowcasePage()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    final scrollView = tester.widget<SingleChildScrollView>(
      find.byKey(showcaseScrollViewKey),
    );

    expect(
      scrollView.padding,
      const EdgeInsets.symmetric(horizontal: 31, vertical: 54),
    );
  });

  testWidgets('showcase section layout gap follows shared surface tokens', (
    tester,
  ) async {
    final themeData = _customVisirThemeData();

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(800, 600)),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: VisirTheme(
            data: themeData,
            child: Center(
              child: SizedBox(
                width: 800,
                child: ShowcaseSectionLayout(
                  preview: const SizedBox(width: 10, height: 10),
                  controls: const SizedBox(width: 10, height: 10),
                  snippet: const SizedBox(width: 10, height: 10),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final layout = tester.widget<Column>(find.byType(Column).first);
    final firstGap = layout.children[1] as SizedBox;
    final secondGap = layout.children[3] as SizedBox;

    expect(firstGap.height, 31);
    expect(secondGap.height, 31);
  });
}

VisirThemeData _customVisirThemeData() {
  final fallback = VisirThemeData.fallback();
  return fallback.copyWith(
    components: fallback.components.copyWith(
      surface: fallback.components.surface.copyWith(
        padding: fallback.components.surface.padding.copyWith(
          compact: 19,
          comfortable: 31,
          spacious: 47,
        ),
      ),
      content: fallback.components.content.copyWith(
        compactSpacing: 7,
        inlineSpacing: 13,
      ),
    ),
  );
}
