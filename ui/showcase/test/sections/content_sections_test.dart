import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visir_ui_showcase/app/showcase_app.dart';

void main() {
  testWidgets('showcase page renders input card and badge sections', (
    tester,
  ) async {
    await tester.pumpWidget(const ShowcaseApp());

    expect(find.text('VisirInput'), findsOneWidget);
    expect(find.text('Loading'), findsWidgets);
    expect(find.text('Clear Button'), findsWidgets);
    expect(find.text('Leading Icon'), findsWidgets);
    expect(find.text('Border'), findsWidgets);
    expect(find.text('Max Lines'), findsOneWidget);
    expect(find.text('VisirCard'), findsOneWidget);
    expect(find.text('VisirBadge'), findsOneWidget);
  });
}
