import 'dart:ui' show SemanticsAction, SemanticsFlag;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  testWidgets('VisirInput binds label semantics to the text field', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

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

    final semanticsData = tester
        .getSemantics(find.byType(EditableText))
        .getSemanticsData();
    expect(semanticsData.label, contains('Email'));
    expect(semanticsData.hasFlag(SemanticsFlag.isTextField), isTrue);
    expect(semanticsData.hasFlag(SemanticsFlag.isFocusable), isTrue);
    expect(semanticsData.hasFlag(SemanticsFlag.hasEnabledState), isTrue);
    expect(semanticsData.hasFlag(SemanticsFlag.isEnabled), isTrue);

    semantics.dispose();
  });

  testWidgets('VisirInput uses generic affix slots for prefix and suffix', (
    tester,
  ) async {
    const prefix = Text('pre');
    const suffix = Text('post');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: makeUiTestableWidget(
            child: const VisirInput(
              label: 'Email',
              prefix: prefix,
              suffix: suffix,
            ),
          ),
        ),
      ),
    );

    final textField = tester.widget<TextField>(find.byType(TextField));
    final decoration = textField.decoration!;

    expect(decoration.prefix, same(prefix));
    expect(decoration.suffix, same(suffix));
    expect(decoration.prefixIcon, isNull);
    expect(decoration.suffixIcon, isNull);
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

  testWidgets(
    'actionable VisirCard exposes button semantics and keyboard activation',
    (tester) async {
      final semantics = tester.ensureSemantics();
      var tapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: makeUiTestableWidget(
              child: VisirCard(
                onTap: () => tapCount += 1,
                child: const Text('Open task'),
              ),
            ),
          ),
        ),
      );

      final semanticsData = tester
          .getSemantics(find.byType(VisirCard))
          .getSemanticsData();
      expect(semanticsData.label, 'Open task');
      expect(semanticsData.hasFlag(SemanticsFlag.isButton), isTrue);
      expect(semanticsData.hasFlag(SemanticsFlag.isFocusable), isTrue);
      expect(semanticsData.hasFlag(SemanticsFlag.hasEnabledState), isTrue);
      expect(semanticsData.hasFlag(SemanticsFlag.isEnabled), isTrue);
      expect(semanticsData.hasAction(SemanticsAction.tap), isTrue);
      expect(semanticsData.hasAction(SemanticsAction.focus), isTrue);

      final focusNode = Focus.of(tester.element(find.text('Open task')));
      focusNode.requestFocus();
      await tester.pump();

      expect(focusNode.hasPrimaryFocus, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(tapCount, 1);

      semantics.dispose();
    },
  );

  testWidgets('actionable VisirCard shows a visible focus treatment', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: makeUiTestableWidget(
            child: VisirCard(onTap: () {}, child: const Text('Focusable card')),
          ),
        ),
      ),
    );

    final decorationFinder = find.descendant(
      of: find.byType(VisirCard),
      matching: find.byWidgetPredicate(
        (widget) => widget is Container && widget.decoration is BoxDecoration,
      ),
    );
    final unfocusedDecoration =
        tester.widget<Container>(decorationFinder).decoration! as BoxDecoration;

    final focusNode = Focus.of(tester.element(find.text('Focusable card')));
    focusNode.requestFocus();
    await tester.pump();

    final focusedDecoration =
        tester.widget<Container>(decorationFinder).decoration! as BoxDecoration;

    expect(
      (unfocusedDecoration.border! as Border).top.color,
      VisirThemeData.fallback().tokens.colors.surfaceOutline,
    );
    expect(
      (focusedDecoration.border! as Border).top.color,
      VisirThemeData.fallback().tokens.colors.accent,
    );
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
