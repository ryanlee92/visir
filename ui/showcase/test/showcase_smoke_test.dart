import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visir_ui_showcase/app/showcase_app.dart';
import 'package:visir_ui_showcase/app/showcase_page.dart';
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
      await tester.pumpAndSettle();

      expect(find.text('Visir UI'), findsOneWidget);
      expect(find.text('Live Visir component playground'), findsOneWidget);
      for (final id in featuredShowcaseJumpSectionIds) {
        expect(find.text('Jump to ${prettySectionTitle(id)}'), findsOneWidget);
      }
      final inputHeader = find.text(prettySectionTitle('input'));
      final scrollView = tester.widget<SingleChildScrollView>(
        find.byKey(showcaseScrollViewKey),
      );
      final scrollController = scrollView.controller!;
      expect(scrollController.offset, equals(0));

      final showcaseSafeArea = find.ancestor(
        of: find.byKey(showcaseScrollViewKey),
        matching: find.byType(SafeArea),
      );
      final viewportRect = tester.getRect(showcaseSafeArea.first);
      final inputBeforeJump = tester.getRect(inputHeader);
      expect(inputBeforeJump.bottom, greaterThan(viewportRect.bottom));

      await tester.tap(find.text('Jump to ${prettySectionTitle('input')}'));
      await tester.pumpAndSettle();

      expect(scrollController.offset, greaterThan(0));
      final inputAfterJump = tester.getRect(inputHeader);
      expect(inputAfterJump.top, greaterThanOrEqualTo(viewportRect.top));
      expect(inputAfterJump.bottom, lessThanOrEqualTo(viewportRect.bottom));

      for (final id in showcaseSectionIds) {
        expect(find.text(prettySectionTitle(id)), findsOneWidget);
      }

      expect(find.byType(VisirButtonSection), findsOneWidget);
      expect(find.byType(VisirIconButtonSection), findsOneWidget);
      expect(find.text('Component area coming soon'), findsWidgets);
    },
  );
}
