import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visir_ui/visir_ui.dart';

void main() {
  Widget buildHarness(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: SizedBox(width: 360, child: child)),
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

    final theme = VisirTheme.of(tester.element(find.byType(VisirInput)));
    final label = tester.widget<Text>(find.text('Email'));
    final editableText = tester.widget<EditableText>(find.byType(EditableText));

    expect(label.style?.fontSize, theme.text.label.fontSize);
    expect(label.style?.fontWeight, theme.text.label.fontWeight);
    expect(label.style?.height, theme.text.label.height);
    expect(label.style?.color, theme.tokens.colors.textMuted);

    expect(editableText.style.fontSize, theme.text.body.fontSize);
    expect(editableText.style.fontWeight, theme.text.body.fontWeight);
    expect(editableText.style.height, theme.text.body.height);
    expect(editableText.style.color, theme.tokens.colors.text);
  });

  testWidgets('input can omit label entirely', (tester) async {
    await tester.pumpWidget(
      buildHarness(const VisirInput(hintText: 'name@example.com')),
    );

    expect(find.text('name@example.com'), findsOneWidget);
    expect(find.text('Email'), findsNothing);
    expect(find.byWidgetPredicate((widget) => widget is Text && widget.data == null), findsNothing);
  });

  testWidgets('input border defaults to none', (tester) async {
    await tester.pumpWidget(
      buildHarness(const VisirInput(hintText: 'name@example.com')),
    );

    final shell = tester.widget<Container>(
      find.byKey(const ValueKey('visir-input-shell')),
    );
    final decoration = shell.decoration as BoxDecoration;

    expect(decoration.border, isNull);
  });

  testWidgets('input border stays none when disabled', (tester) async {
    await tester.pumpWidget(
      buildHarness(
        const VisirInput(
          hintText: 'name@example.com',
          enabled: false,
          border: VisirInputBorder.none,
        ),
      ),
    );

    final shell = tester.widget<Container>(
      find.byKey(const ValueKey('visir-input-shell')),
    );
    final decoration = shell.decoration as BoxDecoration;

    expect(decoration.border, isNull);
  });

  testWidgets('input border states use semantic tokens', (tester) async {
    await tester.pumpWidget(
      buildHarness(
        const VisirInput(
          hintText: 'name@example.com',
          border: VisirInputBorder.base,
        ),
      ),
    );

    final theme = VisirTheme.of(tester.element(find.byType(VisirInput)));
    final baseShell = tester.widget<Container>(
      find.byKey(const ValueKey('visir-input-shell')),
    );
    final baseBorder =
        (baseShell.decoration as BoxDecoration).border! as Border;

    expect(baseBorder.top.color, theme.components.control.borders.base.color);
    expect(baseBorder.top.width, theme.components.control.borders.base.width);

    await tester.pumpWidget(
      buildHarness(
        const VisirInput(
          hintText: 'name@example.com',
          border: VisirInputBorder.success,
        ),
      ),
    );

    final successShell = tester.widget<Container>(
      find.byKey(const ValueKey('visir-input-shell')),
    );
    final successBorder =
        (successShell.decoration as BoxDecoration).border! as Border;

    expect(successBorder.top.color, theme.tokens.colors.success);
    expect(successBorder.top.width, theme.components.control.borders.base.width);

    await tester.pumpWidget(
      buildHarness(
        const VisirInput(
          hintText: 'name@example.com',
          border: VisirInputBorder.error,
        ),
      ),
    );

    final errorShell = tester.widget<Container>(
      find.byKey(const ValueKey('visir-input-shell')),
    );
    final errorBorder = (errorShell.decoration as BoxDecoration).border! as Border;

    expect(errorBorder.top.color, theme.tokens.colors.danger);
    expect(errorBorder.top.width, theme.components.control.borders.base.width);
  });

  testWidgets('errorText forces the error border', (tester) async {
    await tester.pumpWidget(
      buildHarness(
        const VisirInput(
          hintText: 'name@example.com',
          border: VisirInputBorder.success,
          errorText: 'Invalid email',
        ),
      ),
    );

    final theme = VisirTheme.of(tester.element(find.byType(VisirInput)));
    final shell = tester.widget<Container>(
      find.byKey(const ValueKey('visir-input-shell')),
    );
    final border = (shell.decoration as BoxDecoration).border! as Border;

    expect(border.top.color, theme.tokens.colors.danger);
    expect(border.top.width, theme.components.control.borders.base.width);
  });

  testWidgets('errorText still forces the error border when disabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildHarness(
        const VisirInput(
          hintText: 'name@example.com',
          enabled: false,
          border: VisirInputBorder.success,
          errorText: 'Invalid email',
        ),
      ),
    );

    final theme = VisirTheme.of(tester.element(find.byType(VisirInput)));
    final shell = tester.widget<Container>(
      find.byKey(const ValueKey('visir-input-shell')),
    );
    final border = (shell.decoration as BoxDecoration).border! as Border;

    expect(border.top.color, theme.tokens.colors.danger);
    expect(border.top.width, theme.components.control.borders.base.width);
  });

  testWidgets('input shell adds padding around the field', (tester) async {
    await tester.pumpWidget(
      buildHarness(
        const VisirInput(label: 'Email', hintText: 'name@example.com'),
      ),
    );

    final shell = tester.widget<Container>(
      find.byKey(const ValueKey('visir-input-shell')),
    );

    expect(shell.padding, const EdgeInsets.fromLTRB(6, 4, 6, 4));
  });

  testWidgets('input shows a leading button when provided', (tester) async {
    await tester.pumpWidget(
      buildHarness(
        const VisirInput(
          label: 'Search',
          hintText: 'Find projects',
          leading: Icon(Icons.search),
        ),
      ),
    );

    expect(find.text('Find projects'), findsOneWidget);
    expect(find.byKey(const ValueKey('visir-input-leading')), findsOneWidget);
    expect(find.byType(VisirIconButton), findsOneWidget);
  });

  testWidgets('input shows a trailing button when provided', (tester) async {
    await tester.pumpWidget(
      buildHarness(
        const VisirInput(
          label: 'Email',
          hintText: 'name@example.com',
          suffix: Icon(Icons.mail_outline),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('visir-input-suffix')), findsOneWidget);
    expect(find.byType(VisirIconButton), findsOneWidget);
  });

  testWidgets('input wires custom leading and trailing callbacks', (
    tester,
  ) async {
    var leadingCount = 0;
    var trailingCount = 0;

    await tester.pumpWidget(
      buildHarness(
        VisirInput(
          label: 'Search',
          hintText: 'Find projects',
          leading: const Icon(Icons.search),
          leadingOnPressed: () => leadingCount++,
          suffix: const Icon(Icons.arrow_forward),
          suffixOnPressed: () => trailingCount++,
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('visir-input-leading')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('visir-input-suffix')));
    await tester.pump();

    expect(leadingCount, 1);
    expect(trailingCount, 1);
  });

  testWidgets('input respects maxLines', (tester) async {
    await tester.pumpWidget(
      buildHarness(
        const VisirInput(label: 'Notes', hintText: 'Find notes', maxLines: 3),
      ),
    );

    expect(
      find.byWidgetPredicate(
        (widget) => widget is EditableText && widget.maxLines == 3,
        description: 'text input with maxLines set to 3',
      ),
      findsOneWidget,
    );
  });

  testWidgets('input shows loading spinner and clear action', (tester) async {
    await tester.pumpWidget(
      buildHarness(
        VisirInput(
          label: 'Search',
          hintText: 'Find tasks',
          isLoading: true,
          showClearButton: true,
          onClear: () {},
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byKey(const ValueKey('visir-input-clear')), findsOneWidget);
    expect(find.byType(VisirIconButton), findsOneWidget);
  });

  testWidgets('input loading spinner follows the theme text color', (
    tester,
  ) async {
    final baseTheme = VisirThemeData.fallback();
    final themedData = baseTheme.copyWith(
      tokens: baseTheme.tokens.copyWith(
        colors: baseTheme.tokens.colors.copyWith(text: const Color(0xFF222222)),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VisirTheme(
            data: themedData,
            child: const VisirInput(
              label: 'Search',
              hintText: 'Find tasks',
              isLoading: true,
            ),
          ),
        ),
      ),
    );

    final spinner = tester.widget<CircularProgressIndicator>(
      find.byType(CircularProgressIndicator),
    );
    final valueColor = spinner.valueColor as AlwaysStoppedAnimation<Color>;

    expect(valueColor.value, const Color(0xFF222222));
  });

  testWidgets('input uses custom leading when provided', (tester) async {
    await tester.pumpWidget(
      buildHarness(
        const VisirInput(
          label: 'Search',
          hintText: 'Find records',
          leading: Icon(Icons.tune),
        ),
      ),
    );

    expect(find.byIcon(Icons.tune), findsOneWidget);
    expect(find.byKey(const ValueKey('visir-input-leading')), findsOneWidget);
    expect(find.byType(VisirIconButton), findsOneWidget);
  });

  testWidgets('input clear action invokes callback', (tester) async {
    var clearCount = 0;
    final controller = TextEditingController(text: 'tasks');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      buildHarness(
        VisirInput(
          label: 'Search',
          hintText: 'Find tasks',
          controller: controller,
          showClearButton: true,
          onClear: () => clearCount++,
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('visir-input-clear')));
    await tester.pump();

    expect(clearCount, 1);
    expect(find.text('tasks'), findsNothing);
  });

  testWidgets('input wires the provided focus node', (tester) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      buildHarness(
        VisirInput(
          label: 'Search',
          hintText: 'Find tasks',
          focusNode: focusNode,
        ),
      ),
    );

    focusNode.requestFocus();
    await tester.pump();

    final editableText = tester.widget<EditableText>(find.byType(EditableText));

    expect(focusNode.hasFocus, isTrue);
    expect(editableText.focusNode, same(focusNode));
  });

  testWidgets('input shows a danger border when error text is set', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildHarness(
        const VisirInput(
          label: 'Search',
          hintText: 'Find tasks',
          errorText: 'Invalid query',
        ),
      ),
    );

    final searchShell = tester.widget<Container>(
      find.byKey(const ValueKey('visir-input-shell')),
    );
    final border = searchShell.decoration as BoxDecoration;
    final expectedDanger = VisirTheme.of(
      tester.element(find.byType(VisirInput)),
    ).tokens.colors.danger;
    final theme = VisirTheme.of(tester.element(find.byType(VisirInput)));
    final error = tester.widget<Text>(find.text('Invalid query'));

    expect((border.border as Border).top.color, expectedDanger);
    expect(error.style?.fontSize, theme.text.caption.fontSize);
    expect(error.style?.fontWeight, theme.text.caption.fontWeight);
    expect(error.style?.height, theme.text.caption.height);
    expect(error.style?.color, expectedDanger);
  });
}
