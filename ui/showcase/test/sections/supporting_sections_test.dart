import 'package:flutter_test/flutter_test.dart';
import 'package:visir_ui_showcase/app/showcase_app.dart';

void main() {
  testWidgets('showcase page renders all supporting component sections', (
    tester,
  ) async {
    await tester.pumpWidget(const ShowcaseApp());

    expect(find.text('VisirSection'), findsOneWidget);
    expect(find.text('VisirDivider'), findsOneWidget);
    expect(find.text('VisirSpinner'), findsOneWidget);
    expect(find.text('VisirEmptyState'), findsOneWidget);
  });
}
