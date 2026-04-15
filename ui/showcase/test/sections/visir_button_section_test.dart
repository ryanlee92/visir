import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visir_ui_showcase/sections/visir_button_section.dart';

void main() {
  testWidgets('button section updates snippet when variant changes', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: VisirButtonSection())),
      ),
    );

    expect(find.textContaining('VisirButton('), findsOneWidget);

    await tester.ensureVisible(find.text('Danger'));
    await tester.tap(find.text('Danger'));
    await tester.pumpAndSettle();

    expect(find.textContaining('VisirButtonVariant.danger'), findsOneWidget);
  });
}
