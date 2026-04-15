import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visir_ui_showcase/app/showcase_app.dart';
import 'package:visir_ui_showcase/app/showcase_page.dart';
import 'package:visir_ui_showcase/app/showcase_sections.dart';

void main() {
  testWidgets('ShowcaseApp renders hero text, featured jump links, and sections',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    expect(find.text('Visir UI'), findsOneWidget);
    expect(find.text('Live Visir component playground'), findsOneWidget);
    for (final id in featuredShowcaseJumpSectionIds) {
      expect(
        find.text('Jump to ${prettySectionTitle(id)}'),
        findsOneWidget,
      );
    }
    final inputHeader = find.text(prettySectionTitle('input'));
    final scrollable = find.descendant(
      of: find.byKey(showcaseScrollViewKey),
      matching: find.byType(Scrollable),
    );
    final scrollState = tester.state<ScrollableState>(scrollable);
    expect(scrollState.position.pixels, equals(0));

    final viewportRect = tester.getRect(find.byType(SafeArea));
    final inputBeforeJump = tester.getRect(inputHeader);
    expect(inputBeforeJump.bottom, greaterThan(viewportRect.bottom));

    await tester.tap(find.text('Jump to ${prettySectionTitle('input')}'));
    await tester.pumpAndSettle();

    expect(scrollState.position.pixels, greaterThan(0));
    final inputAfterJump = tester.getRect(inputHeader);
    expect(inputAfterJump.top, greaterThanOrEqualTo(viewportRect.top));
    expect(inputAfterJump.bottom, lessThanOrEqualTo(viewportRect.bottom));

    for (final id in showcaseSectionIds) {
      expect(find.text(prettySectionTitle(id)), findsOneWidget);
    }

    expect(find.text('Component area coming soon'), findsWidgets);
  });
}
