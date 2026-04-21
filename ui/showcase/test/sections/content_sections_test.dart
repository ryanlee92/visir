import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visir_ui_showcase/app/showcase_app.dart';
import 'package:visir_ui/visir_ui.dart';

void main() {
  testWidgets('showcase page renders input card and badge sections', (
    tester,
  ) async {
    await tester.pumpWidget(const ShowcaseApp());

    expect(find.text('VisirInput'), findsOneWidget);
    expect(find.text('Search Mode'), findsOneWidget);
    await tester.ensureVisible(find.text('Search Mode'));
    await tester.tap(find.text('Search Mode'));
    await tester.pump();
    final input = tester.widget<VisirInput>(find.byType(VisirInput));
    expect(input.mode, VisirInputMode.search);
    expect(find.text('Loading'), findsWidgets);
    expect(find.text('Clear Button'), findsWidgets);
    expect(find.text('Custom Leading'), findsWidgets);
    expect(find.text('Max Lines'), findsOneWidget);
    expect(
      find.textContaining('mode: VisirInputMode.search'),
      findsOneWidget,
    );
    expect(find.text('VisirCard'), findsOneWidget);
    expect(find.text('VisirBadge'), findsOneWidget);
  });
}
