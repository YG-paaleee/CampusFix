import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens/admin/admin_login_screen.dart';
import 'screens/login_screen.dart';
import 'screens/staff/staff_login_screen.dart';
import 'screens/student/my_reports_screen.dart';
import 'screens/student/report_detail_screen.dart';
import 'screens/student/student_dashboard_screen.dart';
import 'screens/student/submit_report_screen.dart';
import 'services/report_service.dart';
import 'services/student_auth_service.dart';

void main() {
  runApp(const CampusFixApp());
}

class CampusFixApp extends StatefulWidget {
  const CampusFixApp({super.key});

  @override
  State<CampusFixApp> createState() => _CampusFixAppState();
}

class _CampusFixAppState extends State<CampusFixApp> {
  late final StudentAuthService _authService;
  late final ReportService _reportService;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authService = StudentAuthService();
    _reportService = ReportService();
    _router = GoRouter(
      refreshListenable: _authService,
      redirect: (context, state) {
        final path = state.uri.path;
        final isStudentRoute =
            path == '/student' || path.startsWith('/student/');

        if (!_authService.isLoggedIn && isStudentRoute) {
          return '/';
        }

        if (_authService.isLoggedIn && path == '/') {
          return '/student';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) {
            return LoginScreen(onStudentLogin: _authService.login);
          },
        ),
        GoRoute(
          path: '/admin-login',
          builder: (context, state) => const AdminLoginScreen(),
        ),
        GoRoute(
          path: '/staff-login',
          builder: (context, state) => const StaffLoginScreen(),
        ),
        GoRoute(path: '/student', builder: _buildStudentDashboard),
        GoRoute(path: '/student/reports', builder: _buildMyReports),
        GoRoute(path: '/student/reports/new', builder: _buildSubmitReport),
        GoRoute(
          path: '/student/reports/:reportId',
          builder: _buildReportDetails,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CampusFix',
      debugShowCheckedModeBanner: false,
      theme: _campusFixTheme,
      routerConfig: _router,
    );
  }

  Widget _buildStudentDashboard(BuildContext context, GoRouterState state) {
    final student = _authService.currentStudent;

    if (student == null) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _reportService,
      builder: (context, _) {
        return StudentDashboardScreen(
          reports: _reportService.reportsForStudent(student.studentId),
          onLogout: _authService.logout,
        );
      },
    );
  }

  Widget _buildMyReports(BuildContext context, GoRouterState state) {
    final student = _authService.currentStudent;

    if (student == null) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _reportService,
      builder: (context, _) {
        return MyReportsScreen(
          reports: _reportService.reportsForStudent(student.studentId),
        );
      },
    );
  }

  Widget _buildSubmitReport(BuildContext context, GoRouterState state) {
    final student = _authService.currentStudent;

    if (student == null) {
      return const SizedBox.shrink();
    }

    return SubmitReportScreen(
      studentId: student.studentId,
      nextReportId: _reportService.nextReportId,
      onReportCreated: _reportService.addReport,
    );
  }

  Widget _buildReportDetails(BuildContext context, GoRouterState state) {
    final student = _authService.currentStudent;
    final reportId = state.pathParameters['reportId'];

    if (student == null || reportId == null) {
      return const SizedBox.shrink();
    }

    final report = _reportService.findStudentReport(
      studentId: student.studentId,
      reportId: reportId,
    );

    if (report == null) {
      return const _ReportNotFoundScreen();
    }

    return ReportDetailScreen(report: report);
  }

  @override
  void dispose() {
    _router.dispose();
    _authService.dispose();
    _reportService.dispose();
    super.dispose();
  }
}

final _campusFixColorScheme =
    ColorScheme.fromSeed(seedColor: const Color(0xFF114B3A)).copyWith(
      primary: const Color(0xFF114B3A),
      secondary: const Color(0xFF0D7C66),
      surface: Colors.white,
    );

final _campusFixTheme = ThemeData(
  colorScheme: _campusFixColorScheme,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFF114B3A),
      side: const BorderSide(color: Color(0xFF9DB7AD)),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
);

class _ReportNotFoundScreen extends StatelessWidget {
  const _ReportNotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Not Found')),
      body: const Center(child: Text('This report is not available.')),
    );
  }
}
