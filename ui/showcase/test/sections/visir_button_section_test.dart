import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visir_ui_showcase/sections/visir_button_section.dart';

void main() {
  testWidgets('button section updates snippet when variant changes', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: VisirButtonSection()),
        ),
      ),
    );

    expect(find.textContaining('VisirButton('), findsOneWidget);

    await tester.ensureVisible(find.text('Danger'));
    await tester.tap(find.text('Danger'));
    await tester.pumpAndSettle();

    expect(find.textContaining('VisirButtonVariant.danger'), findsOneWidget);
  });

  testWidgets('button section updates snippet when loading changes', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: VisirButtonSection()),
        ),
      ),
    );

    await tester.ensureVisible(find.text('Loading'));
    await tester.tap(find.text('Loading'));
    await tester.pump();

    expect(find.textContaining('isLoading: true'), findsOneWidget);
  });

  testWidgets('button section updates snippet when border and shadow change', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: VisirButtonSection()),
        ),
      ),
    );

    await tester.ensureVisible(find.text('Success'));
    await tester.tap(find.text('Success'));
    await tester.pumpAndSettle();

    expect(find.textContaining('VisirButtonBorder.success'), findsOneWidget);

    await tester.ensureVisible(find.text('Shadow'));
    await tester.tap(find.text('Shadow'));
    await tester.pump();

    expect(find.textContaining('showShadow: false'), findsOneWidget);
  });
}
