import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visir_ui/visir_ui.dart';

void main() {
  Widget buildHarness(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(width: 360, child: child),
        ),
      ),
    );
  }

  testWidgets('standard mode keeps label and hint rendering', (tester) async {
    await tester.pumpWidget(
      buildHarness(
        const VisirInput(label: 'Email', hintText: 'name@example.com'),
      ),
    );

    expect(find.text('Email'), findsOneWidget);
    expect(find.text('name@example.com'), findsOneWidget);
  });

  testWidgets('search mode shows default search icon and omits label text', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildHarness(
        const VisirInput(
          label: 'Search',
          hintText: 'Find projects',
          mode: VisirInputMode.search,
        ),
      ),
    );

    expect(find.text('Find projects'), findsOneWidget);
    expect(find.text('Search'), findsNothing);
    expect(find.byIcon(Icons.search), findsOneWidget);
  });

  testWidgets('search mode respects maxLines', (tester) async {
    await tester.pumpWidget(
      buildHarness(
        const VisirInput(
          label: 'Search',
          hintText: 'Find notes',
          mode: VisirInputMode.search,
          maxLines: 3,
        ),
      ),
    );

    expect(
      find.byWidgetPredicate(
        (widget) => widget is TextField && widget.maxLines == 3,
        description: 'text input with maxLines set to 3',
      ),
      findsOneWidget,
    );
  });

  testWidgets('search mode shows loading spinner and clear action', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildHarness(
        VisirInput(
          label: 'Search',
          hintText: 'Find tasks',
          mode: VisirInputMode.search,
          isLoading: true,
          showClearButton: true,
          onClear: () {},
        ),
      ),
    );

    expect(find.byType(VisirSpinner), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
  });
}
