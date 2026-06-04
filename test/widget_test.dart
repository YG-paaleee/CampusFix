import 'package:campusfix/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('login screen renders first', (WidgetTester tester) async {
    await _pumpCampusFix(tester);

    expect(find.text('CampusFix'), findsOneWidget);
    expect(find.text('Login as Student'), findsOneWidget);
    expect(
      find.text('Submit and monitor campus maintenance concerns'),
      findsOneWidget,
    );
  });

  testWidgets('student login opens dashboard', (WidgetTester tester) async {
    await _pumpCampusFix(tester);
    await _loginAsStudent(tester);

    expect(find.text('Student Dashboard'), findsOneWidget);
    expect(find.text('Submit Report'), findsOneWidget);
    expect(find.text('My Reports'), findsOneWidget);
  });

  testWidgets('student can logout back to login screen', (
    WidgetTester tester,
  ) async {
    await _pumpCampusFix(tester);
    await _loginAsStudent(tester);

    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    expect(find.text('Student Login'), findsOneWidget);
    expect(find.text('Login as Student'), findsOneWidget);
  });

  testWidgets('admin login link opens admin placeholder page', (
    WidgetTester tester,
  ) async {
    await _pumpCampusFix(tester);

    await tester.ensureVisible(find.text('Admin Login'));
    await tester.tap(find.text('Admin Login'));
    await tester.pumpAndSettle();

    expect(find.text('Admin page placeholder'), findsOneWidget);
  });

  testWidgets('staff login link opens staff placeholder page', (
    WidgetTester tester,
  ) async {
    await _pumpCampusFix(tester);

    await tester.ensureVisible(find.text('Staff Login'));
    await tester.tap(find.text('Staff Login'));
    await tester.pumpAndSettle();

    expect(find.text('Staff page placeholder'), findsOneWidget);
  });

  testWidgets('submit report button opens form screen', (
    WidgetTester tester,
  ) async {
    await _pumpCampusFix(tester);
    await _loginAsStudent(tester);

    await tester.tap(find.text('Submit Report'));
    await tester.pumpAndSettle();

    expect(find.text('File a Maintenance Report'), findsOneWidget);
    expect(find.text('Issue title'), findsOneWidget);
    expect(find.text('Location or room'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
  });

  testWidgets('my reports button opens reports list', (
    WidgetTester tester,
  ) async {
    await _pumpCampusFix(tester);
    await _loginAsStudent(tester);

    await tester.tap(find.text('My Reports'));
    await tester.pumpAndSettle();

    expect(find.text('Projector not working'), findsOneWidget);
    expect(find.text('Leaking faucet'), findsOneWidget);
    expect(find.text('Search reports'), findsOneWidget);
    expect(find.text('Newest First'), findsOneWidget);
  });

  testWidgets('my reports search filters reports', (WidgetTester tester) async {
    await _pumpCampusFix(tester);
    await _loginAsStudent(tester);

    await tester.tap(find.text('My Reports'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Projector');
    await tester.pumpAndSettle();

    expect(find.text('Projector not working'), findsOneWidget);
    expect(find.text('Broken classroom chair'), findsNothing);
  });

  testWidgets('recent report opens detail screen', (WidgetTester tester) async {
    await _pumpCampusFix(tester);
    await _loginAsStudent(tester);

    await tester.drag(find.byType(ListView), const Offset(0, -250));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Broken classroom chair'));
    await tester.pumpAndSettle();

    expect(find.text('Report Details'), findsOneWidget);
    expect(find.text('Status Progress'), findsOneWidget);
    expect(find.text('Room 204'), findsOneWidget);
  });

  testWidgets('report item opens detail screen', (WidgetTester tester) async {
    await _pumpCampusFix(tester);
    await _loginAsStudent(tester);

    await tester.tap(find.text('My Reports'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Leaking faucet'));
    await tester.pumpAndSettle();

    expect(find.text('Report Details'), findsOneWidget);
    expect(find.text('Restroom A'), findsOneWidget);
    expect(
      find.text('The sink faucet was continuously leaking.'),
      findsOneWidget,
    );
  });

  testWidgets('submitted report appears in my reports', (
    WidgetTester tester,
  ) async {
    await _pumpCampusFix(tester);
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
    expect(find.textContaining('Classroom - Room 105'), findsOneWidget);
  });
}

Future<void> _pumpCampusFix(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1366, 768);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(const CampusFixApp());
}

Future<void> _loginAsStudent(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Login as Student'));
  await tester.tap(find.text('Login as Student'));
  await tester.pumpAndSettle();
}
