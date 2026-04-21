import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visir_ui_showcase/app/showcase_app.dart';
import 'package:visir_ui_showcase/sections/visir_divider_section.dart';
import 'package:visir_ui_showcase/sections/visir_empty_state_section.dart';
import 'package:visir_ui_showcase/sections/visir_section_section.dart';
import 'package:visir_ui_showcase/sections/visir_spinner_section.dart';

void main() {
  testWidgets('sidebar browser can switch to supporting sections', (
    tester,
  ) async {
    await tester.pumpWidget(const ShowcaseApp());
    await tester.pump(const Duration(milliseconds: 100));

    final sectionSidebar = find.byKey(
      const ValueKey('showcase-sidebar-section'),
    );
    await tester.ensureVisible(sectionSidebar);
    await tester.tap(sectionSidebar);
    await tester.pump();
    expect(find.byType(VisirSectionSection), findsOneWidget);

    final dividerSidebar = find.byKey(
      const ValueKey('showcase-sidebar-divider'),
    );
    await tester.ensureVisible(dividerSidebar);
    await tester.tap(dividerSidebar);
    await tester.pump();
    expect(find.byType(VisirDividerSection), findsOneWidget);

    final spinnerSidebar = find.byKey(
      const ValueKey('showcase-sidebar-spinner'),
    );
    await tester.ensureVisible(spinnerSidebar);
    await tester.tap(spinnerSidebar);
    await tester.pump();
    expect(find.byType(VisirSpinnerSection), findsOneWidget);

    final emptyStateSidebar = find.byKey(
      const ValueKey('showcase-sidebar-empty-state'),
    );
    await tester.ensureVisible(emptyStateSidebar);
    await tester.tap(emptyStateSidebar);
    await tester.pump();
    expect(find.byType(VisirEmptyStateSection), findsOneWidget);
  });
}
