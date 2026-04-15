import 'package:flutter/widgets.dart';
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

    await tester.drag(scrollable, const Offset(0, -150));
    await tester.pumpAndSettle();
    final afterDragOffset = scrollState.position.pixels;
    expect(afterDragOffset, greaterThan(0));

    await tester.tap(find.text('Jump to ${prettySectionTitle('button')}'));
    await tester.pumpAndSettle();
    final postJumpOffset = scrollState.position.pixels;
    expect(postJumpOffset, isNot(equals(afterDragOffset)));
    final viewportRect = tester.getRect(find.byType(SafeArea));
    final buttonRect = tester.getRect(buttonHeader);
    expect(buttonRect.top, greaterThanOrEqualTo(viewportRect.top));
    expect(buttonRect.bottom, lessThanOrEqualTo(viewportRect.bottom));

    expect(
      find.text('Component area coming soon'),
      findsNWidgets(showcaseSectionIds.length),
    );
  });
}
