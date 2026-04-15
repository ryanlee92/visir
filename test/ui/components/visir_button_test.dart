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

  testWidgets('disabled button ignores taps', (tester) async {
    var enabledTapCount = 0;
    var disabledTapCount = 0;

    await tester.pumpWidget(
      makeUiTestableWidget(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            VisirButton(label: 'Enabled', onPressed: () => enabledTapCount++),
            VisirButton(
              label: 'Disabled',
              isLoading: true,
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

  testWidgets('hovering lowers opacity or transforms toward pressed feedback', (
    tester,
  ) async {
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(gesture.removePointer);

    await gesture.addPointer(location: Offset.zero);
    await tester.pumpWidget(
      makeUiTestableWidget(
        child: VisirButton(label: 'Hover', onPressed: () {}),
      ),
    );

    await gesture.moveTo(tester.getCenter(find.byType(VisirButton)));
    await tester.pumpAndSettle();

    final animatedScale = tester.widget<AnimatedScale>(
      find.byType(AnimatedScale),
    );
    expect(animatedScale.scale, lessThan(1.0));
  });
}
