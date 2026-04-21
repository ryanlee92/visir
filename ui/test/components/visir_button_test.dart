import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visir_ui/visir_ui.dart';

void main() {
  Widget buildHarness(Widget child) {
    return VisirTheme(
      data: VisirThemeData.fallback(),
      child: MaterialApp(
        home: Scaffold(
          body: Center(child: SizedBox(width: 240, child: child)),
        ),
      ),
    );
  }

  BoxDecoration _buttonDecoration(WidgetTester tester) {
    final buttonFinder = find.byType(VisirButton);
    final decorationFinder = find.descendant(
      of: buttonFinder,
      matching: find.byType(DecoratedBox),
    );

    return tester.widget<DecoratedBox>(decorationFinder).decoration
        as BoxDecoration;
  }

  testWidgets('secondary buttons use the surface outline base color', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildHarness(
        VisirButton(
          label: 'Continue',
          onPressed: () {},
          variant: VisirButtonVariant.secondary,
        ),
      ),
    );

    final theme = VisirTheme.of(tester.element(find.byType(VisirButton)));
    final decoration = _buttonDecoration(tester);

    expect(decoration.color, theme.components.button.secondaryBackgroundColor);
  });

  testWidgets('ghost buttons keep a transparent base color', (tester) async {
    await tester.pumpWidget(
      buildHarness(
        VisirButton(
          label: 'Continue',
          onPressed: () {},
          variant: VisirButtonVariant.ghost,
        ),
      ),
    );

    final theme = VisirTheme.of(tester.element(find.byType(VisirButton)));
    final decoration = _buttonDecoration(tester);

    expect(decoration.color, theme.components.button.ghostBackgroundColor);
  });

  testWidgets('button tooltips use the custom overlay on hover', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildHarness(
        VisirButton(
          label: 'Continue',
          onPressed: () {},
          tooltip: 'Create item',
        ),
      ),
    );

    expect(find.byTooltip('Create item'), findsNothing);

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(
      location: tester.getCenter(find.byType(VisirButton)),
    );
    await mouse.moveTo(tester.getCenter(find.byType(VisirButton)));
    await tester.pumpAndSettle();

    expect(find.text('Create item'), findsOneWidget);
    expect(find.byTooltip('Create item'), findsNothing);

    await mouse.moveTo(const Offset(0, 0));
    await tester.pumpAndSettle();

    expect(find.text('Create item'), findsNothing);
  });
}
