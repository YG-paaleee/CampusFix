import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'firebase_options.dart';
import 'screens/admin/admin_login_screen.dart';
import 'screens/login_screen.dart';
import 'screens/staff/staff_login_screen.dart';
import 'screens/student/my_reports_screen.dart';
import 'screens/student/report_detail_screen.dart';
import 'screens/student/student_dashboard_screen.dart';
import 'screens/student/student_signup_screen.dart';
import 'screens/student/submit_report_screen.dart';
import 'services/report_service.dart';
import 'services/student_auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final firebaseServices = await _configureFirebase();

  runApp(
    CampusFixApp(
      firestore: firebaseServices.firestore,
      authApiKey: firebaseServices.authApiKey,
    ),
  );
}

class CampusFixApp extends StatefulWidget {
  const CampusFixApp({super.key, this.firestore, this.authApiKey});

  final FirebaseFirestore? firestore;
  final String? authApiKey;

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
    _authService = StudentAuthService(
      authApiKey: widget.authApiKey,
      firestore: widget.firestore,
    );
    _reportService = ReportService(firestore: widget.firestore);
    _restoreStudentSession();
    _router = GoRouter(
      refreshListenable: _authService,
      redirect: (context, state) {
        final path = state.uri.path;
        final isSignupRoute = path == '/student/signup';
        final isStudentRoute =
            (path == '/student' || path.startsWith('/student/')) &&
            !isSignupRoute;

        if (!_authService.isLoggedIn && isStudentRoute) {
          return '/';
        }

        if (_authService.isLoggedIn && (path == '/' || isSignupRoute)) {
          return '/student';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) {
            return LoginScreen(onStudentLogin: _loginStudent);
          },
        ),
        GoRoute(path: '/student/signup', builder: _buildStudentSignup),
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
          reports: _reportService.reportsForStudent(student),
          onLogout: () {
            _authService.logout();
          },
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
          reports: _reportService.reportsForStudent(student),
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
      studentUid: student.uid,
      studentId: student.studentId,
      createReportId: _reportService.createReportId,
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
      student: student,
      reportId: reportId,
    );

    if (report == null) {
      return const _ReportNotFoundScreen();
    }

    return ReportDetailScreen(report: report);
  }

  Widget _buildStudentSignup(BuildContext context, GoRouterState state) {
    return StudentSignupScreen(onStudentRegistered: _registerStudent);
  }

  Future<void> _restoreStudentSession() async {
    await _authService.restoreSession();
    final student = _authService.currentStudent;

    if (student != null) {
      await _reportService.loadReports(student: student);
    }
  }

  Future<String?> _loginStudent({
    required String identifier,
    required String password,
  }) async {
    final success = await _authService.login(
      identifier: identifier,
      password: password,
    );
    final student = _authService.currentStudent;

    if (success && student != null) {
      await _reportService.loadReports(student: student);
      return null;
    }

    return _authService.errorMessage ?? 'Could not sign in.';
  }

  Future<String?> _registerStudent({
    required String fullName,
    required String studentId,
    required String email,
    required String password,
  }) async {
    final success = await _authService.registerStudent(
      fullName: fullName,
      studentId: studentId,
      email: email,
      password: password,
    );
    final student = _authService.currentStudent;

    if (success && student != null) {
      await _reportService.loadReports(student: student);
      return null;
    }

    return _authService.errorMessage ?? 'Could not create account.';
  }

  @override
  void dispose() {
    _router.dispose();
    _authService.dispose();
    _reportService.dispose();
    super.dispose();
  }
}

Future<_FirebaseServices> _configureFirebase() async {
  if (!DefaultFirebaseOptions.isConfigured) {
    return const _FirebaseServices();
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  return _FirebaseServices(
    firestore: FirebaseFirestore.instance,
    authApiKey: DefaultFirebaseOptions.currentPlatform.apiKey,
  );
}

class _FirebaseServices {
  const _FirebaseServices({this.firestore, this.authApiKey});

  final FirebaseFirestore? firestore;
  final String? authApiKey;
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
