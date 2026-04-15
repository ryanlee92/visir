import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visir_ui_showcase/playground/code_snippet_panel.dart';
import 'package:visir_ui_showcase/playground/playground_toggle.dart';

void main() {
  testWidgets('code snippet panel renders code text', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CodeSnippetPanel(
          title: 'Snippet',
          code: 'VisirButton(label: "Go")',
        ),
      ),
    );

    expect(find.text('Snippet'), findsOneWidget);
    expect(find.text('VisirButton(label: "Go")'), findsOneWidget);
  });

  testWidgets('playground toggle reflects current value', (tester) async {
    var value = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PlaygroundToggle(
            label: 'Loading',
            value: value,
            onChanged: (next) => value = next,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Loading'));
    expect(value, isTrue);
  });
}
