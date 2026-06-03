import 'package:flutter/material.dart';

import 'screens/student/student_dashboard_screen.dart';

void main() {
  runApp(const CampusFixApp());
}

class CampusFixApp extends StatelessWidget {
  const CampusFixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CampusFix',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F766E)),
        useMaterial3: true,
      ),
      home: const StudentDashboardScreen(),
    );
  }
}
