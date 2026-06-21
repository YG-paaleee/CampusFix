import 'package:campusfix/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1366, 768);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpWidget(const CampusFixApp());
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('staff can log in and reach the staff dashboard', (tester) async {
    await _pump(tester);

    await tester.ensureVisible(find.text('Staff Login'));
    await tester.tap(find.text('Staff Login'));
    await tester.pumpAndSettle();

    // Fields are pre-filled with staff@campus.edu / password.
    await tester.tap(find.widgetWithText(FilledButton, 'Login'));
    await tester.pumpAndSettle();

    expect(find.text('Staff Dashboard'), findsOneWidget);
    expect(find.text('Welcome, Maintenance Team'), findsOneWidget);
  });

  testWidgets('admin can log in and reach the admin dashboard', (tester) async {
    await _pump(tester);

    await tester.ensureVisible(find.text('Admin Login'));
    await tester.tap(find.text('Admin Login'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Admin Email'),
      'admin@campus.edu',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Password'),
      'password',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Secure Login'));
    await tester.pumpAndSettle();

    expect(find.text('Admin Dashboard'), findsOneWidget);
  });
}
