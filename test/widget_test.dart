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

  testWidgets('submit report button opens form screen', (WidgetTester tester) async {
    await tester.pumpWidget(const CampusFixApp());

    await tester.tap(find.text('Submit Report'));
    await tester.pumpAndSettle();

    expect(find.text('Maintenance Request'), findsOneWidget);
    expect(find.text('Issue title'), findsOneWidget);
    expect(find.text('Location or room'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
  });

  testWidgets('my reports button opens reports list', (WidgetTester tester) async {
    await tester.pumpWidget(const CampusFixApp());

    await tester.tap(find.text('My Reports'));
    await tester.pumpAndSettle();

    expect(find.text('Broken classroom chair'), findsOneWidget);
    expect(find.text('Projector not working'), findsOneWidget);
    expect(find.text('Leaking faucet'), findsOneWidget);
  });

  testWidgets('report item opens detail screen', (WidgetTester tester) async {
    await tester.pumpWidget(const CampusFixApp());

    await tester.tap(find.text('My Reports'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Broken classroom chair'));
    await tester.pumpAndSettle();

    expect(find.text('Report Details'), findsOneWidget);
    expect(find.text('Room 204'), findsOneWidget);
    expect(find.text('One chair near the back row has a broken leg.'), findsOneWidget);
  });
}
