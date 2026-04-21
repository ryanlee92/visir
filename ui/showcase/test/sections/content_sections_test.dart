import 'package:flutter_test/flutter_test.dart';
import 'package:visir_ui_showcase/app/showcase_app.dart';

void main() {
  testWidgets('showcase page renders input card and badge sections', (
    tester,
  ) async {
    await tester.pumpWidget(const ShowcaseApp());

    expect(find.text('VisirInput'), findsOneWidget);
    expect(find.text('Search Mode'), findsOneWidget);
    await tester.ensureVisible(find.text('Search Mode'));
    await tester.tap(find.text('Search Mode'));
    await tester.pump();
    await tester.ensureVisible(find.text('Max Lines'));
    expect(find.text('Max Lines'), findsOneWidget);
    expect(find.text('VisirCard'), findsOneWidget);
    expect(find.text('VisirBadge'), findsOneWidget);
  });
}
