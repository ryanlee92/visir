import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../ui/visir_ui.dart';
import '../test_ui_widget.dart';

void main() {
  testWidgets('primary medium button renders label', (tester) async {
    await tester.pumpWidget(
      makeUiTestableWidget(
        child: VisirButton(label: 'Continue', onPressed: () {}),
      ),
    );

    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('icon button reuses button interaction shell', (tester) async {
    var tapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: makeUiTestableWidget(
            child: VisirIconButton(
              icon: const Icon(Icons.add),
              semanticLabel: 'Create',
              tooltip: 'Create',
              onPressed: () => tapCount += 1,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(VisirIconButton));
    expect(tapCount, 1);
  });

  testWidgets('icon button wires semantic label for accessibility', (
    tester,
  ) async {
    await tester.pumpWidget(
      makeUiTestableWidget(
        child: VisirIconButton(
          icon: const Icon(Icons.add),
          semanticLabel: 'Create item',
          onPressed: () {},
        ),
      ),
    );

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'Create item' &&
            widget.properties.button == true,
      ),
      findsWidgets,
    );
  });

  testWidgets('icon button exposes disabled semantics state', (tester) async {
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      makeUiTestableWidget(
        child: VisirIconButton(
          icon: const Icon(Icons.add),
          semanticLabel: 'Create item',
        ),
      ),
    );

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'Create item' &&
            widget.properties.button == true &&
            widget.properties.enabled == false,
      ),
      findsWidgets,
    );

    semantics.dispose();
  });

  testWidgets('icon button applies primary button foreground color to icon', (
    tester,
  ) async {
    Color? capturedIconColor;

    await tester.pumpWidget(
      makeUiTestableWidget(
        child: VisirIconButton(
          icon: Builder(
            builder: (context) {
              capturedIconColor = IconTheme.of(context).color;
              return const Icon(Icons.add);
            },
          ),
          semanticLabel: 'Create item',
          variant: VisirButtonVariant.primary,
          onPressed: () {},
        ),
      ),
    );

    expect(
      capturedIconColor,
      VisirThemeData.fallback().tokens.colors.textInverse,
    );
  });

  testWidgets('empty label does not implicitly switch to icon-only layout', (
    tester,
  ) async {
    await tester.pumpWidget(
      makeUiTestableWidget(
        child: VisirButton(
          label: '',
          leading: const Icon(Icons.add),
          onPressed: () {},
        ),
      ),
    );

    expect(
      find.byWidgetPredicate((widget) => widget is Text && widget.data == ''),
      findsOneWidget,
    );
  });

  testWidgets('button tooltip message is wired through Tooltip', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: makeUiTestableWidget(
            child: VisirButton(
              label: 'Tooltip',
              tooltip: 'Create item',
              onPressed: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.byTooltip('Create item'), findsOneWidget);
  });

  testWidgets('icon-only button requires an explicit semantic label', (
    tester,
  ) async {
    expect(
      () => VisirButton(
        label: '',
        leading: const Icon(Icons.add),
        isIconOnly: true,
        onPressed: () {},
      ),
      throwsAssertionError,
    );
  });

  testWidgets('disabled button ignores taps', (tester) async {
    var enabledTapCount = 0;
    var disabledTapCount = 0;
    final disabledFocusNode = FocusNode(debugLabel: 'disabled-button-focus');
    addTearDown(disabledFocusNode.dispose);

    await tester.pumpWidget(
      makeUiTestableWidget(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            VisirButton(label: 'Enabled', onPressed: () => enabledTapCount++),
            VisirButton(
              label: 'Disabled',
              isLoading: true,
              focusNode: disabledFocusNode,
              onPressed: () => disabledTapCount++,
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.text('Enabled'));
    await tester.pump();

    await tester.tap(find.text('Disabled'));
    await tester.pump();

    disabledFocusNode.requestFocus();
    await tester.pump();

    expect(disabledFocusNode.hasPrimaryFocus, isFalse);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(enabledTapCount, 1);
    expect(disabledTapCount, 0);
  });

  testWidgets('loading button shows spinner and preserves label slot', (
    tester,
  ) async {
    await tester.pumpWidget(
      makeUiTestableWidget(
        child: const VisirButton(label: 'Continue', isLoading: true),
      ),
    );

    expect(find.byType(VisirSpinner), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('large button is taller than small button', (tester) async {
    await tester.pumpWidget(
      makeUiTestableWidget(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              key: const ValueKey('small-button-container'),
              child: VisirButton(
                label: 'Small',
                size: VisirButtonSize.sm,
                onPressed: () {},
              ),
            ),
            Container(
              key: const ValueKey('large-button-container'),
              child: VisirButton(
                label: 'Large',
                size: VisirButtonSize.lg,
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );

    final smallHeight = tester
        .getSize(find.byKey(const ValueKey('small-button-container')))
        .height;
    final largeHeight = tester
        .getSize(find.byKey(const ValueKey('large-button-container')))
        .height;
    expect(largeHeight, greaterThan(smallHeight));
  });

  testWidgets('autofocus focuses injected node and enter activates callback', (
    tester,
  ) async {
    final focusNode = FocusNode(debugLabel: 'visir-button-focus');
    addTearDown(focusNode.dispose);
    var activationCount = 0;

    await tester.pumpWidget(
      makeUiTestableWidget(
        child: VisirButton(
          label: 'Continue',
          autofocus: true,
          focusNode: focusNode,
          onPressed: () => activationCount++,
        ),
      ),
    );
    await tester.pump();

    expect(focusNode.hasPrimaryFocus, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(activationCount, 1);
  });

  testWidgets('focused button shows a visible focus treatment', (tester) async {
    final focusNode = FocusNode(debugLabel: 'focus-visual');
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      makeUiTestableWidget(
        child: VisirButton(
          label: 'Continue',
          focusNode: focusNode,
          onPressed: () {},
        ),
      ),
    );

    final decorationFinder = find.descendant(
      of: find.byType(VisirButton),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is DecoratedBox && widget.decoration is BoxDecoration,
      ),
    );

    final unfocusedDecoration =
        tester.widget<DecoratedBox>(decorationFinder).decoration
            as BoxDecoration;

    focusNode.requestFocus();
    await tester.pumpAndSettle();

    final focusedDecoration =
        tester.widget<DecoratedBox>(decorationFinder).decoration
            as BoxDecoration;

    expect(
      (unfocusedDecoration.border! as Border).top.color,
      VisirThemeData.fallback().tokens.colors.surfaceOutline,
    );
    expect(
      (focusedDecoration.border! as Border).top.color,
      VisirThemeData.fallback().tokens.colors.accent,
    );
  });

  testWidgets('enabled button exposes button semantics and enabled state', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      makeUiTestableWidget(
        child: VisirButton(label: 'Continue', onPressed: () {}),
      ),
    );

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'Continue' &&
            widget.properties.button == true &&
            widget.properties.enabled == true,
      ),
      findsOneWidget,
    );

    semantics.dispose();
  });

  testWidgets('enabled button uses click cursor on desktop pointers', (
    tester,
  ) async {
    await tester.pumpWidget(
      makeUiTestableWidget(
        child: VisirButton(label: 'Continue', onPressed: () {}),
      ),
    );

    final mouseRegion = tester.widget<MouseRegion>(
      find.descendant(
        of: find.byType(VisirButton),
        matching: find.byType(MouseRegion),
      ),
    );

    expect(mouseRegion.cursor, SystemMouseCursors.click);
  });

  testWidgets('disabled loading button cannot autofocus or take focus', (
    tester,
  ) async {
    final focusNode = FocusNode(debugLabel: 'disabled-loading-focus');
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      makeUiTestableWidget(
        child: VisirButton(
          label: 'Busy',
          isLoading: true,
          autofocus: true,
          focusNode: focusNode,
          onPressed: () {},
        ),
      ),
    );
    await tester.pump();

    expect(focusNode.hasPrimaryFocus, isFalse);

    focusNode.requestFocus();
    await tester.pump();

    expect(focusNode.hasPrimaryFocus, isFalse);
  });

  testWidgets('focus traversal skips disabled button', (tester) async {
    final firstFocusNode = FocusNode(debugLabel: 'first-focus');
    final disabledFocusNode = FocusNode(debugLabel: 'disabled-focus');
    final lastFocusNode = FocusNode(debugLabel: 'last-focus');
    addTearDown(firstFocusNode.dispose);
    addTearDown(disabledFocusNode.dispose);
    addTearDown(lastFocusNode.dispose);

    late BuildContext traversalContext;

    await tester.pumpWidget(
      makeUiTestableWidget(
        child: FocusTraversalGroup(
          policy: WidgetOrderTraversalPolicy(),
          child: Builder(
            builder: (context) {
              traversalContext = context;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  VisirButton(
                    label: 'First',
                    focusNode: firstFocusNode,
                    onPressed: () {},
                  ),
                  VisirButton(label: 'Disabled', focusNode: disabledFocusNode),
                  VisirButton(
                    label: 'Last',
                    focusNode: lastFocusNode,
                    onPressed: () {},
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );

    firstFocusNode.requestFocus();
    await tester.pump();
    expect(firstFocusNode.hasPrimaryFocus, isTrue);

    FocusScope.of(traversalContext).nextFocus();
    await tester.pump();

    expect(disabledFocusNode.hasPrimaryFocus, isFalse);
    expect(lastFocusNode.hasPrimaryFocus, isTrue);
  });

  testWidgets('hover feedback only changes enabled button visuals', (
    tester,
  ) async {
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(gesture.removePointer);

    await gesture.addPointer(location: Offset.zero);
    await tester.pumpWidget(
      makeUiTestableWidget(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            VisirButton(label: 'Enabled hover', onPressed: () {}),
            const VisirButton(label: 'Disabled hover'),
          ],
        ),
      ),
    );

    final enabledShell = find.descendant(
      of: find.byType(VisirButton).first,
      matching: find.byWidgetPredicate((widget) => widget is ConstrainedBox),
    );
    final enabledBefore = tester.getRect(enabledShell);
    final enabledTextBefore = tester.getRect(find.text('Enabled hover'));
    final disabledBefore = tester.getRect(find.text('Disabled hover'));

    await gesture.moveTo(tester.getCenter(find.text('Enabled hover')));
    await tester.pumpAndSettle();

    final enabledAfter = tester.getRect(enabledShell);
    final enabledTextAfter = tester.getRect(find.text('Enabled hover'));
    expect(enabledAfter, enabledBefore);
    expect(enabledTextAfter.width, lessThan(enabledTextBefore.width));
    expect(enabledTextAfter.height, lessThan(enabledTextBefore.height));

    await gesture.moveTo(tester.getCenter(find.text('Disabled hover')));
    await tester.pumpAndSettle();

    final disabledAfter = tester.getRect(find.text('Disabled hover'));
    expect(disabledAfter, disabledBefore);
  });

  testWidgets('press feedback shrinks and then restores enabled button', (
    tester,
  ) async {
    await tester.pumpWidget(
      makeUiTestableWidget(
        child: VisirButton(label: 'Press me', onPressed: () {}),
      ),
    );

    final center = tester.getCenter(find.text('Press me'));
    final buttonShell = find.descendant(
      of: find.byType(VisirButton),
      matching: find.byWidgetPredicate((widget) => widget is ConstrainedBox),
    );
    final shellBefore = tester.getRect(buttonShell);
    final textBefore = tester.getRect(find.text('Press me'));

    final gesture = await tester.startGesture(center);
    await tester.pumpAndSettle();

    final shellPressed = tester.getRect(buttonShell);
    final textPressed = tester.getRect(find.text('Press me'));
    expect(shellPressed, shellBefore);
    expect(textPressed.width, lessThan(textBefore.width));
    expect(textPressed.height, lessThan(textBefore.height));

    await gesture.up();
    await tester.pumpAndSettle();

    final shellAfter = tester.getRect(buttonShell);
    final textAfter = tester.getRect(find.text('Press me'));
    expect(shellAfter, shellBefore);
    expect(textAfter, textBefore);
  });
}
