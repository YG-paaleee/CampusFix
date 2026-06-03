import 'package:campusfix/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CampusFix app shell renders', (WidgetTester tester) async {
    await tester.pumpWidget(const CampusFixApp());

    expect(find.text('CampusFix'), findsOneWidget);
    expect(find.text('Campus Maintenance Request System'), findsOneWidget);
    expect(find.text('Student side will be built step by step.'), findsOneWidget);
  });
}
