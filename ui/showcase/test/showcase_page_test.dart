import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visir_ui/visir_ui.dart';
import 'package:visir_ui_showcase/app/showcase_app.dart';
import 'package:visir_ui_showcase/app/showcase_page.dart';
import 'package:visir_ui_showcase/app/showcase_theme.dart';
import 'package:visir_ui_showcase/sections/showcase_section_layout.dart';

void main() {
  testWidgets('ShowcaseApp renders page shell smoke coverage', (tester) async {
    tester.view.physicalSize = const Size(800, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Visir UI'), findsOneWidget);
    expect(find.byKey(const ValueKey('showcase-theme-button')), findsOneWidget);
    expect(find.byKey(showcaseScrollViewKey), findsOneWidget);
    expect(find.byType(VisirCard), findsWidgets);
    expect(find.byType(VisirAppBar), findsOneWidget);
  });

  testWidgets('ShowcaseApp theme button toggles the app shell theme', (
    tester,
  ) async {
    await tester.pumpWidget(const ShowcaseApp());
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byKey(const ValueKey('showcase-theme-button')));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byIcon(Icons.light_mode_outlined), findsOneWidget);
  });

  testWidgets('ShowcaseTheme maps Visir text tokens into Material text theme', (
    tester,
  ) async {
    final themeData = _customVisirThemeData();
    final materialTheme = ShowcaseTheme.build(themeData, Brightness.light);

    expect(
      materialTheme.textTheme.titleLarge?.fontSize,
      themeData.text.hero.fontSize,
    );
    expect(
      materialTheme.textTheme.titleLarge?.color,
      materialTheme.colorScheme.onSurface,
    );
    expect(
      materialTheme.textTheme.labelLarge?.fontSize,
      themeData.text.label.fontSize,
    );
    expect(
      materialTheme.textTheme.bodyMedium?.fontSize,
      themeData.text.body.fontSize,
    );
  });

  testWidgets('ShowcaseApp theme button updates the input surface color', (
    tester,
  ) async {
    await tester.pumpWidget(const ShowcaseApp());
    await tester.pump(const Duration(milliseconds: 100));

    final shellFinder = find.byKey(const ValueKey('visir-input-shell'));
    final initialShell =
        tester.widget<Container>(shellFinder).decoration as BoxDecoration;
    final initialColor = initialShell.color;

    await tester.tap(find.byKey(const ValueKey('showcase-theme-button')));
    await tester.pump(const Duration(milliseconds: 200));

    final updatedShell =
        tester.widget<Container>(shellFinder).decoration as BoxDecoration;
    final updatedColor = updatedShell.color;

    expect(initialColor, isNot(updatedColor));
    expect(updatedColor, const Color(0xCC1F1B33));
  });

  testWidgets('ShowcaseApp light theme divider uses dark border color', (
    tester,
  ) async {
    await tester.pumpWidget(const ShowcaseApp());
    await tester.pump(const Duration(milliseconds: 100));

    final divider = tester.widget<ColoredBox>(
      find.descendant(
        of: find.byType(VisirDivider),
        matching: find.byType(ColoredBox),
      ),
    );

    expect(divider.color, isNot(Colors.white));
    expect(divider.color, const Color(0x331D1A1F));
  });

  testWidgets('showcase page shell spacing follows shared role tokens', (
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
    final heroColumn = tester
        .widgetList<Column>(find.byType(Column))
        .firstWhere((column) => _isHeroColumn(column));
    final heroGap = heroColumn.children[1] as SizedBox;

    expect(
      scrollView.padding,
      const EdgeInsets.symmetric(horizontal: 31, vertical: 54),
    );
    expect(heroGap.height, 38);
  });

  testWidgets(
    'ShowcaseApp uses one shared theme source for Material radii and Visir shell',
    (tester) async {
      final themeData = _customVisirThemeData();
      tester.view.physicalSize = const Size(640, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(ShowcaseApp(visirThemeData: themeData));
      await tester.pump(const Duration(milliseconds: 100));

      final context = tester.element(find.byKey(showcaseScrollViewKey));
      final materialTheme = Theme.of(context);
      final scrollView = tester.widget<SingleChildScrollView>(
        find.byKey(showcaseScrollViewKey),
      );
      final cardShape =
          materialTheme.cardTheme.shape! as RoundedRectangleBorder;
      final chipShape =
          materialTheme.chipTheme.shape! as RoundedRectangleBorder;

      expect(
        scrollView.padding,
        const EdgeInsets.symmetric(horizontal: 31, vertical: 54),
      );
      expect(
        cardShape.borderRadius.resolve(TextDirection.ltr),
        BorderRadius.circular(33),
      );
      expect(
        chipShape.borderRadius.resolve(TextDirection.ltr),
        BorderRadius.circular(123),
      );
    },
  );

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

bool _isHeroColumn(Column column) {
  if (column.children.isEmpty) {
    return false;
  }

  final firstChild = column.children.first;
  return firstChild is Text &&
      firstChild.data ==
          'Interactive component showcase for the visir_ui package.';
}

VisirThemeData _customVisirThemeData() {
  final fallback = VisirThemeData.fallback();
  return fallback.copyWith(
    tokens: fallback.tokens.copyWith(
      radius: const VisirRadius(sm: 33, md: 16, lg: 22, pill: 123),
    ),
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
