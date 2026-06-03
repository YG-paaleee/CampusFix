import 'package:campusfix/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('student dashboard renders', (WidgetTester tester) async {
    await tester.pumpWidget(const CampusFixApp());

    expect(find.text('CampusFix'), findsOneWidget);
    expect(find.text('Student Dashboard'), findsOneWidget);
    expect(find.text('Submit Report'), findsOneWidget);
    expect(find.text('My Reports'), findsOneWidget);
  });
}
