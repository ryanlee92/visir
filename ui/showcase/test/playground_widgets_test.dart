import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visir_ui_showcase/playground/code_snippet_panel.dart';
import 'package:visir_ui_showcase/playground/playground_enum_picker.dart';
import 'package:visir_ui_showcase/playground/playground_text_field.dart';
import 'package:visir_ui_showcase/playground/playground_toggle.dart';
import 'package:visir_ui_showcase/playground/preview_frame.dart';

enum _DemoSize { sm, md, lg }

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

  testWidgets('code snippet panel keeps long snippets scrollable', (
    tester,
  ) async {
    final code = List.generate(
      40,
      (index) => 'final longLine$index = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";',
    ).join('\n');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 280,
            child: CodeSnippetPanel(title: 'Snippet', code: code),
          ),
        ),
      ),
    );

    final scrollables = find.descendant(
      of: find.byType(CodeSnippetPanel),
      matching: find.byType(Scrollable),
    );
    expect(scrollables, findsAtLeastNWidgets(1));

    final selectableText = tester.widget<SelectableText>(
      find.descendant(
        of: find.byType(CodeSnippetPanel),
        matching: find.byType(SelectableText),
      ),
    );
    expect(selectableText.enableInteractiveSelection, isTrue);
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

  testWidgets('playground text field renders label and updates value', (
    tester,
  ) async {
    var latest = '';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PlaygroundTextField(
            label: 'Label',
            value: 'Initial',
            onChanged: (next) => latest = next,
          ),
        ),
      ),
    );

    expect(find.text('Label'), findsOneWidget);
    expect(find.text('Initial'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Updated');
    await tester.pump();
    expect(latest, equals('Updated'));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PlaygroundTextField(
            label: 'Label',
            value: 'Synced',
            onChanged: (next) => latest = next,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Synced'), findsOneWidget);
  });

  testWidgets('playground enum picker changes selection', (tester) async {
    var selected = _DemoSize.sm;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PlaygroundEnumPicker<_DemoSize>(
            label: 'Size',
            values: _DemoSize.values,
            value: selected,
            onChanged: (next) => selected = next,
          ),
        ),
      ),
    );

    expect(find.text('Size'), findsOneWidget);

    await tester.tap(find.text(_DemoSize.lg.name));
    await tester.pump();

    expect(selected, equals(_DemoSize.lg));
  });

  testWidgets('preview frame enforces min height and centers child', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            child: PreviewFrame(minHeight: 240, child: Text('Preview Child')),
          ),
        ),
      ),
    );

    final frameBox = find.descendant(
      of: find.byType(PreviewFrame),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is ConstrainedBox && widget.constraints.minHeight == 240,
      ),
    );
    expect(frameBox, findsOneWidget);
    expect(tester.getSize(frameBox).height, greaterThanOrEqualTo(240));

    final frameRect = tester.getRect(frameBox);
    final childRect = tester.getRect(find.text('Preview Child'));
    expect((frameRect.center.dx - childRect.center.dx).abs(), lessThan(1.0));
    expect((frameRect.center.dy - childRect.center.dy).abs(), lessThan(1.0));
  });
}
