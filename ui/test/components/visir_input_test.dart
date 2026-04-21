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

  testWidgets('search mode shows default search icon and exposes semantics', (
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
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.bySemanticsLabel('Search'), findsOneWidget);
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

  testWidgets('search mode uses custom leading when provided', (tester) async {
    await tester.pumpWidget(
      buildHarness(
        const VisirInput(
          label: 'Search',
          hintText: 'Find records',
          mode: VisirInputMode.search,
          leading: Icon(Icons.tune),
        ),
      ),
    );

    expect(find.byIcon(Icons.tune), findsOneWidget);
    expect(find.byIcon(Icons.search), findsNothing);
  });

  testWidgets('search mode clear action invokes callback', (tester) async {
    var clearCount = 0;

    await tester.pumpWidget(
      buildHarness(
        VisirInput(
          label: 'Search',
          hintText: 'Find tasks',
          mode: VisirInputMode.search,
          showClearButton: true,
          onClear: () => clearCount++,
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();

    expect(clearCount, 1);
  });

  testWidgets('search mode wires the provided focus node', (
    tester,
  ) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      buildHarness(
        VisirInput(
          label: 'Search',
          hintText: 'Find tasks',
          mode: VisirInputMode.search,
          focusNode: focusNode,
        ),
      ),
    );

    focusNode.requestFocus();
    await tester.pump();

    final searchField = tester.widget<TextField>(find.byType(TextField));
    final editableText = tester.widget<EditableText>(find.byType(EditableText));

    expect(focusNode.hasFocus, isTrue);
    expect(editableText.focusNode, same(focusNode));
    expect(
      searchField.focusNode,
      same(focusNode),
    );
  });

  testWidgets('search mode shows a danger border when error text is set', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildHarness(
        const VisirInput(
          label: 'Search',
          hintText: 'Find tasks',
          mode: VisirInputMode.search,
          errorText: 'Invalid query',
        ),
      ),
    );

    final searchField = tester.widget<TextField>(find.byType(TextField));
    final errorBorder =
        searchField.decoration?.errorBorder as OutlineInputBorder;
    final expectedDanger =
        VisirTheme.of(tester.element(find.byType(VisirInput))).tokens.colors.danger;

    expect(errorBorder.borderSide.color, expectedDanger);
  });
}
