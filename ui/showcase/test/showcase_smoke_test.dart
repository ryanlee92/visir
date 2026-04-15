import 'package:flutter_test/flutter_test.dart';
import 'package:visir_ui_showcase/app/showcase_app.dart';

void main() {
  testWidgets('ShowcaseApp renders Visir UI and Component Playground',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ShowcaseApp());

    expect(find.text('Visir UI'), findsOneWidget);
    expect(find.text('Component Playground'), findsOneWidget);
  });
}
