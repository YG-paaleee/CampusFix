import 'package:flutter/material.dart';

import 'models/maintenance_report.dart';
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
    const MaintenanceReport(
      title: 'Broken classroom chair',
      location: 'Room 204',
      category: 'Classroom',
      urgency: 'Medium',
      status: 'Submitted',
      description: 'One chair near the back row has a broken leg.',
    ),
    const MaintenanceReport(
      title: 'Projector not working',
      location: 'IT Lab 1',
      category: 'IT Equipment',
      urgency: 'High',
      status: 'In Progress',
      description:
          'The projector turns on but does not display the computer screen.',
    ),
    const MaintenanceReport(
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
    return MaterialApp(
      title: 'CampusFix',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F766E)),
        useMaterial3: true,
      ),
      home: StudentDashboardScreen(
        reports: _reports,
        onReportCreated: _addReport,
      ),
    );
  }
}
