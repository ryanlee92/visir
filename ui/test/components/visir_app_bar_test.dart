import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visir_ui/visir_ui.dart';

void main() {
  Widget buildHarness(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  testWidgets('VisirAppBar exposes the expected preferred size', (tester) async {
    const appBar = VisirAppBar(title: 'Visir UI', leadings: [], trailings: []);

    expect(appBar.preferredSize.height, VisirAppBar.height);

    await tester.pumpWidget(buildHarness(appBar));

    expect(find.text('Visir UI'), findsOneWidget);
    expect(find.byKey(const ValueKey('visir-app-bar')), findsOneWidget);
  });

  testWidgets('VisirAppBar renders leading and trailing buttons', (
    tester,
  ) async {
    var tapped = 0;

    await tester.pumpWidget(
      buildHarness(
        VisirAppBar(
          title: 'Visir UI',
          leadings: [
            VisirAppBarButton.icon(
              icon: const Icon(Icons.menu),
              semanticLabel: 'Menu',
              onPressed: () => tapped++,
            ),
          ],
          trailings: [
            VisirAppBarButton.divider(),
            VisirAppBarButton.icon(
              icon: const Icon(Icons.dark_mode_outlined),
              semanticLabel: 'Theme',
              onPressed: () => tapped++,
            ),
          ],
        ),
      ),
    );

    expect(find.byType(VisirButton), findsNWidgets(2));
    expect(find.byKey(const ValueKey('visir-app-bar-divider')), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Menu'));
    await tester.pump();
    await tester.tap(find.bySemanticsLabel('Theme'));
    await tester.pump();

    expect(tapped, 2);
  });
}
