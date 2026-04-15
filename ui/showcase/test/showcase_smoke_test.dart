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

    final scrollable = find.byType(Scrollable);
    final buttonHeader = find.text(prettySectionTitle('button'));
    final initialTop = tester.getTopLeft(buttonHeader).dy;
    await tester.drag(scrollable, const Offset(0, -150));
    await tester.pumpAndSettle();
    final draggedTop = tester.getTopLeft(buttonHeader).dy;
    expect(draggedTop, lessThan(initialTop - 20));

    await tester.tap(find.text('Jump to ${prettySectionTitle('button')}'));
    await tester.pumpAndSettle();
    final postJumpTop = tester.getTopLeft(buttonHeader).dy;
    expect(postJumpTop, lessThan(draggedTop - 20));
    expect(postJumpTop, lessThanOrEqualTo(initialTop + 12));

    expect(
      find.text('Component area coming soon'),
      findsNWidgets(showcaseSectionIds.length),
    );
  });
}
