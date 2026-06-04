import 'package:flutter/material.dart';

import 'models/maintenance_report.dart';
import 'screens/login_screen.dart';
import 'screens/student/student_dashboard_screen.dart';

void main() {
  runApp(const CampusFixApp());
}

class CampusFixApp extends StatefulWidget {
  const CampusFixApp({super.key});

  @override
  State<CampusFixApp> createState() => _CampusFixAppState();
}

class _CampusFixAppState extends State<CampusFixApp> {
  final List<MaintenanceReport> _reports = [
    MaintenanceReport(
      reportId: 'CF-0001',
      submittedAt: DateTime(2026, 6, 1),
      title: 'Broken classroom chair',
      location: 'Room 204',
      category: 'Classroom',
      urgency: 'Medium',
      status: 'Submitted',
      description: 'One chair near the back row has a broken leg.',
    ),
    MaintenanceReport(
      reportId: 'CF-0002',
      submittedAt: DateTime(2026, 6, 2),
      title: 'Projector not working',
      location: 'IT Lab 1',
      category: 'IT Equipment',
      urgency: 'High',
      status: 'In Progress',
      description:
          'The projector turns on but does not display the computer screen.',
    ),
    MaintenanceReport(
      reportId: 'CF-0003',
      submittedAt: DateTime(2026, 6, 3),
      title: 'Leaking faucet',
      location: 'Restroom A',
      category: 'Plumbing',
      urgency: 'Low',
      status: 'Resolved',
      description: 'The sink faucet was continuously leaking.',
    ),
  ];

  void _addReport(MaintenanceReport report) {
    setState(() {
      _reports.insert(0, report);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(seedColor: const Color(0xFF114B3A))
        .copyWith(
          primary: const Color(0xFF114B3A),
          secondary: const Color(0xFF0D7C66),
          surface: Colors.white,
        );

    return MaterialApp(
      title: 'CampusFix',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFF5F7F4),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF17211C),
          centerTitle: false,
          elevation: 0,
          surfaceTintColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 1,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color(0xFFE2E7E1)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF114B3A), width: 2),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF114B3A),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF114B3A),
            side: const BorderSide(color: Color(0xFF9DB7AD)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: LoginScreen(
        studentHomeBuilder: (context) {
          return StudentDashboardScreen(
            reports: _reports,
            onReportCreated: _addReport,
          );
        },
      ),
    );
  }
}
