import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visir_ui_showcase/app/showcase_app.dart';
import 'package:visir_ui_showcase/app/showcase_sections.dart';
import 'package:visir_ui_showcase/sections/visir_button_section.dart';
import 'package:visir_ui_showcase/sections/visir_icon_button_section.dart';

void main() {
  testWidgets(
    'ShowcaseApp renders hero text, featured jump links, and sections',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const ShowcaseApp());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Visir UI'), findsOneWidget);
      expect(
        find.text('Interactive component showcase for the visir_ui package.'),
        findsOneWidget,
      );
      for (final id in featuredShowcaseJumpSectionIds) {
        expect(find.text('Jump to ${prettySectionTitle(id)}'), findsOneWidget);
      }
      for (final id in showcaseSectionIds) {
        expect(find.text(prettySectionTitle(id)), findsOneWidget);
      }

      expect(find.byType(VisirButtonSection), findsOneWidget);
      expect(find.byType(VisirIconButtonSection), findsOneWidget);
    },
  );
}
