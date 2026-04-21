import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visir_ui_showcase/sections/visir_icon_button_section.dart';

void main() {
  testWidgets(
    'icon button section updates snippet when border and shadow change',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: VisirIconButtonSection()),
          ),
        ),
      );

      await tester.ensureVisible(find.text('Base'));
      await tester.tap(find.text('Base'));
      await tester.pumpAndSettle();

      expect(find.textContaining('VisirButtonBorder.base'), findsOneWidget);

      await tester.ensureVisible(find.text('Shadow'));
      await tester.tap(find.text('Shadow'));
      await tester.pump();

      expect(find.textContaining('showShadow: true'), findsOneWidget);
    },
  );
}
