import 'package:campusfix/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('login screen renders first', (WidgetTester tester) async {
    await tester.pumpWidget(const CampusFixApp());

    expect(find.text('CampusFix'), findsOneWidget);
    expect(find.text('Login as Student'), findsOneWidget);
    expect(
      find.text('Palawan State University maintenance request portal'),
      findsOneWidget,
    );
  });

  testWidgets('student login opens dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const CampusFixApp());
    await _loginAsStudent(tester);

    expect(find.text('Student Dashboard'), findsOneWidget);
    expect(find.text('Submit Report'), findsOneWidget);
    expect(find.text('My Reports'), findsOneWidget);
  });

  testWidgets('submit report button opens form screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CampusFixApp());
    await _loginAsStudent(tester);

    await tester.tap(find.text('Submit Report'));
    await tester.pumpAndSettle();

    expect(find.text('Maintenance Request'), findsOneWidget);
    expect(find.text('Issue title'), findsOneWidget);
    expect(find.text('Location or room'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
  });

  testWidgets('my reports button opens reports list', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CampusFixApp());
    await _loginAsStudent(tester);

    await tester.tap(find.text('My Reports'));
    await tester.pumpAndSettle();

    expect(find.text('Broken classroom chair'), findsOneWidget);
    expect(find.text('Projector not working'), findsOneWidget);
    expect(find.text('Leaking faucet'), findsOneWidget);
  });

  testWidgets('report item opens detail screen', (WidgetTester tester) async {
    await tester.pumpWidget(const CampusFixApp());
    await _loginAsStudent(tester);

    await tester.tap(find.text('My Reports'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Broken classroom chair'));
    await tester.pumpAndSettle();

    expect(find.text('Report Details'), findsOneWidget);
    expect(find.text('Room 204'), findsOneWidget);
    expect(
      find.text('One chair near the back row has a broken leg.'),
      findsOneWidget,
    );
  });

  testWidgets('submitted report appears in my reports', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CampusFixApp());
    await _loginAsStudent(tester);

    await tester.tap(find.text('Submit Report'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Broken window');
    await tester.enterText(find.byType(TextFormField).at(1), 'Room 105');
    await tester.enterText(
      find.byType(TextFormField).at(2),
      'Window glass has a visible crack.',
    );

    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Submit').last);
    await tester.pumpAndSettle();

    expect(find.text('Student Dashboard'), findsOneWidget);
    expect(find.text('Report submitted.'), findsOneWidget);

    await tester.tap(find.text('My Reports'));
    await tester.pumpAndSettle();

    expect(find.text('Broken window'), findsOneWidget);
    expect(find.text('Classroom - Room 105\nUrgency: Medium'), findsOneWidget);
  });
}

Future<void> _loginAsStudent(WidgetTester tester) async {
  await tester.tap(find.text('Login as Student'));
  await tester.pumpAndSettle();
}
