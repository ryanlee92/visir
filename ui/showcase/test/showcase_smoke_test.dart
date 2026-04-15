import 'package:flutter_test/flutter_test.dart';
import 'package:visir_ui_showcase/app/showcase_app.dart';

void main() {
  testWidgets('ShowcaseApp renders the hero and jump links',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ShowcaseApp());

    expect(find.text('Visir UI'), findsOneWidget);
    expect(find.text('Live Visir component playground'), findsOneWidget);
    expect(find.text('Jump to Button'), findsOneWidget);
    expect(find.text('Jump to Input'), findsOneWidget);
  });
}
