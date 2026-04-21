import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visir_ui_showcase/app/showcase_app.dart';
import 'package:visir_ui_showcase/app/showcase_sections.dart';
import 'package:visir_ui_showcase/sections/visir_button_section.dart';

void main() {
  testWidgets(
    'ShowcaseApp renders the sidebar browser and the active section',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const ShowcaseApp());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Visir UI'), findsOneWidget);
      for (final id in showcaseSectionIds) {
        expect(find.byKey(ValueKey('showcase-sidebar-$id')), findsOneWidget);
      }

      for (final id in featuredShowcaseJumpSectionIds) {
        expect(find.text('Jump to ${prettySectionTitle(id)}'), findsNothing);
      }

      expect(find.byType(VisirButtonSection), findsOneWidget);
    },
  );
}
