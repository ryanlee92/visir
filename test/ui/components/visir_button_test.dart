import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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
    await tester.pumpWidget(
      makeUiTestableWidget(
        child: VisirButton(label: 'Continue', onPressed: null),
      ),
    );

    await tester.tap(find.byType(VisirButton));
    await tester.pump();
    expect(find.text('Continue'), findsOneWidget);
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
            VisirButton(
              label: 'Small',
              size: VisirButtonSize.sm,
              onPressed: () {},
            ),
            VisirButton(
              label: 'Large',
              size: VisirButtonSize.lg,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );

    final smallHeight = tester.getSize(find.text('Small')).height;
    final largeHeight = tester.getSize(find.text('Large')).height;
    expect(largeHeight, greaterThan(smallHeight));
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
