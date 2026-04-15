import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visir_ui_showcase/app/showcase_app.dart';
import 'package:visir_ui_showcase/app/showcase_sections.dart';

void main() {
  testWidgets('ShowcaseApp renders hero text, featured jump links, and sections',
      (WidgetTester tester) async {
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
    final buttonHeader = find.text(prettySectionTitle('button'));

    final scrollable = find.descendant(
      of: find.byType(SingleChildScrollView),
      matching: find.byType(Scrollable),
    );
    final scrollState = tester.state<ScrollableState>(scrollable);
    expect(scrollState.position.pixels, equals(0));

    scrollState.position.jumpTo(scrollState.position.maxScrollExtent);
    await tester.pumpAndSettle();
    final viewportRect = tester.getRect(find.byType(SafeArea));
    final offscreenButtonRect = tester.getRect(buttonHeader);
    expect(offscreenButtonRect.top, lessThan(viewportRect.top));

    await tester.drag(scrollable, const Offset(0, -32));
    await tester.pumpAndSettle();
    final afterDragOffset = scrollState.position.pixels;
    expect(afterDragOffset, greaterThan(0));

    final jumpButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Jump to ${prettySectionTitle('button')}'),
    );
    jumpButton.onPressed!.call();
    await tester.pumpAndSettle();
    final buttonRect = tester.getRect(buttonHeader);
    expect(scrollState.position.pixels, lessThan(afterDragOffset));
    expect(buttonRect.top, greaterThanOrEqualTo(viewportRect.top));
    expect(buttonRect.bottom, lessThanOrEqualTo(viewportRect.bottom));

    for (final id in showcaseSectionIds) {
      expect(find.text(prettySectionTitle(id)), findsOneWidget);
    }

    expect(find.text('Component area coming soon'), findsWidgets);
  });
}
