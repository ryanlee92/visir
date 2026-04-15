import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../ui/visir_ui.dart';
import '../test_ui_widget.dart';

void main() {
  testWidgets('VisirInput renders label and hint text', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: makeUiTestableWidget(
            child: const VisirInput(
              label: 'Email',
              hintText: 'name@example.com',
            ),
          ),
        ),
      ),
    );

    expect(find.text('Email'), findsOneWidget);
    expect(find.text('name@example.com'), findsOneWidget);
  });

  testWidgets('VisirCard density changes padding profile', (tester) async {
    await tester.pumpWidget(
      makeUiTestableWidget(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SizedBox(
              key: ValueKey('compact-card'),
              child: VisirCard(
                density: VisirCardDensity.compact,
                child: Text('Compact'),
              ),
            ),
            SizedBox(
              key: ValueKey('spacious-card'),
              child: VisirCard(
                density: VisirCardDensity.spacious,
                child: Text('Spacious'),
              ),
            ),
          ],
        ),
      ),
    );

    final compact = tester.getSize(find.byKey(const ValueKey('compact-card')));
    final spacious = tester.getSize(
      find.byKey(const ValueKey('spacious-card')),
    );
    expect(spacious.height, greaterThan(compact.height));
  });

  testWidgets('VisirBadge shows label', (tester) async {
    await tester.pumpWidget(
      makeUiTestableWidget(child: const VisirBadge(label: 'Beta')),
    );

    expect(find.text('Beta'), findsOneWidget);
  });

  testWidgets('VisirEmptyState renders title description and action', (
    tester,
  ) async {
    await tester.pumpWidget(
      makeUiTestableWidget(
        child: VisirEmptyState(
          title: 'No tasks',
          description: 'Create one to get started',
          action: VisirButton(label: 'Create', onPressed: () {}),
        ),
      ),
    );

    expect(find.text('No tasks'), findsOneWidget);
    expect(find.text('Create one to get started'), findsOneWidget);
    expect(find.text('Create'), findsOneWidget);
  });
}
