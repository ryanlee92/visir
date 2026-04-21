import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visir_ui/visir_ui.dart';
import 'package:visir_ui_showcase/app/showcase_app.dart';
import 'package:visir_ui_showcase/app/showcase_page.dart';
import 'package:visir_ui_showcase/app/showcase_theme.dart';
import 'package:visir_ui_showcase/app/showcase_sections.dart';
import 'package:visir_ui_showcase/sections/showcase_section_layout.dart';
import 'package:visir_ui_showcase/sections/visir_button_section.dart';
import 'package:visir_ui_showcase/sections/visir_input_section.dart';

void main() {
  testWidgets('ShowcaseApp renders grouped component sidebar', (tester) async {
    await tester.pumpWidget(const ShowcaseApp());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Visir UI'), findsOneWidget);
    expect(find.byKey(const ValueKey('showcase-theme-button')), findsOneWidget);
    expect(find.byKey(showcaseScrollViewKey), findsOneWidget);
    expect(find.text('Actions'), findsOneWidget);
    expect(find.text('Forms'), findsOneWidget);
    expect(find.text('Surfaces'), findsOneWidget);
    expect(find.text('Feedback'), findsOneWidget);
    expect(find.text('Status'), findsOneWidget);
    for (final id in showcaseSectionIds) {
      expect(find.byKey(ValueKey('showcase-sidebar-$id')), findsOneWidget);
    }
    expect(find.byType(VisirButtonSection), findsOneWidget);
  });

  testWidgets('ShowcaseApp switches the active section from the sidebar', (
    tester,
  ) async {
    await tester.pumpWidget(const ShowcaseApp());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(VisirButtonSection), findsOneWidget);
    expect(find.byType(VisirInputSection), findsNothing);

    final inputSidebar = find.byKey(const ValueKey('showcase-sidebar-input'));
    await tester.ensureVisible(inputSidebar);
    await tester.tap(inputSidebar);
    await tester.pump();

    expect(find.byType(VisirInputSection), findsOneWidget);
    expect(find.byType(VisirButtonSection), findsNothing);
  });

  testWidgets('ShowcaseApp theme button toggles the app shell theme', (
    tester,
  ) async {
    await tester.pumpWidget(const ShowcaseApp());
    await tester.pump(const Duration(milliseconds: 100));

    await tester.ensureVisible(
      find.byKey(const ValueKey('showcase-theme-button')),
    );
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

    final inputSidebar = find.byKey(const ValueKey('showcase-sidebar-input'));
    await tester.ensureVisible(inputSidebar);
    await tester.tap(inputSidebar);
    await tester.pump();

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

    final dividerSidebar = find.byKey(
      const ValueKey('showcase-sidebar-divider'),
    );
    await tester.ensureVisible(dividerSidebar);
    await tester.tap(dividerSidebar);
    await tester.pump();

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

    expect(
      scrollView.padding,
      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
    );
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
        const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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

    expect(firstGap.height, 16);
    expect(secondGap.height, 16);
  });
}

VisirThemeData _customVisirThemeData() {
  final fallback = VisirThemeData.fallback();
  return fallback.copyWith(
    tokens: fallback.tokens.copyWith(
      radius: const VisirRadius(sm: 33, md: 16, lg: 22, pill: 123),
    ),
    components: fallback.components.copyWith(
      surface: fallback.components.surface.copyWith(
        padding: const VisirSurfaceDensityScale(
          compact: 12,
          comfortable: 16,
          spacious: 31,
        ),
      ),
    ),
  );
}
