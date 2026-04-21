import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visir_ui_showcase/app/showcase_app.dart';
import 'package:visir_ui_showcase/sections/visir_badge_section.dart';
import 'package:visir_ui_showcase/sections/visir_card_section.dart';
import 'package:visir_ui_showcase/sections/visir_input_section.dart';

void main() {
  testWidgets('sidebar browser can switch to content sections', (tester) async {
    await tester.pumpWidget(const ShowcaseApp());
    await tester.pump(const Duration(milliseconds: 100));

    final inputSidebar = find.byKey(const ValueKey('showcase-sidebar-input'));
    await tester.ensureVisible(inputSidebar);
    await tester.tap(inputSidebar);
    await tester.pump();

    expect(find.byType(VisirInputSection), findsOneWidget);
    expect(find.text('Loading'), findsWidgets);
    expect(find.text('Clear Button'), findsWidgets);
    expect(find.text('Leading Icon'), findsWidgets);
    expect(find.text('Border'), findsWidgets);
    expect(find.text('Enabled'), findsWidgets);
    expect(find.text('Max Lines'), findsOneWidget);

    final cardSidebar = find.byKey(const ValueKey('showcase-sidebar-card'));
    await tester.ensureVisible(cardSidebar);
    await tester.tap(cardSidebar);
    await tester.pump();

    expect(find.byType(VisirCardSection), findsOneWidget);

    final badgeSidebar = find.byKey(const ValueKey('showcase-sidebar-badge'));
    await tester.ensureVisible(badgeSidebar);
    await tester.tap(badgeSidebar);
    await tester.pump();

    expect(find.byType(VisirBadgeSection), findsOneWidget);
  });
}
