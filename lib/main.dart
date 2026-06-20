import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'firebase_options.dart';
import 'models/report_options.dart';
import 'screens/admin/admin_all_reports_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/admin_login_screen.dart';
import 'screens/admin/admin_report_management_screen.dart';
import 'screens/admin/admin_staff_management_screen.dart';
import 'screens/login_screen.dart';
import 'screens/staff/staff_assigned_reports_screen.dart';
import 'screens/staff/staff_dashboard_screen.dart';
import 'screens/staff/staff_login_screen.dart';
import 'screens/student/my_reports_screen.dart';
import 'screens/student/report_detail_screen.dart';
import 'screens/student/student_dashboard_screen.dart';
import 'screens/student/student_signup_screen.dart';
import 'screens/student/submit_report_screen.dart';
import 'services/admin_auth_service.dart';
import 'services/admin_staff_service.dart';
import 'services/report_service.dart';
import 'services/staff_auth_service.dart';
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
  late final AdminAuthService _adminAuthService;
  late final StaffAuthService _staffAuthService;
  late final ReportService _reportService;
  late final AdminStaffService _adminStaffService;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authService = StudentAuthService(
      authApiKey: widget.authApiKey,
      firestore: widget.firestore,
    );
    _adminAuthService = AdminAuthService();
    _staffAuthService = StaffAuthService();
    _reportService = ReportService(firestore: widget.firestore);
    _adminStaffService = AdminStaffService();
    _restoreStudentSession();
    _router = GoRouter(
      refreshListenable: Listenable.merge([_authService, _adminAuthService, _staffAuthService]),
      redirect: (context, state) {
        final path = state.uri.path;
        
        // --- Student Routing Logic ---
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

        // --- Admin Routing Logic ---
        final isAdminRoute = path == '/admin' || path.startsWith('/admin/');
        final isAdminLoginRoute = path == '/admin-login';

        if (!_adminAuthService.isLoggedIn && isAdminRoute) {
          return '/admin-login';
        }

        if (_adminAuthService.isLoggedIn && isAdminLoginRoute) {
          return '/admin';
        }

        // --- Staff Routing Logic ---
        final isStaffRoute = path == '/staff' || path.startsWith('/staff/');
        final isStaffLoginRoute = path == '/staff-login';

        if (!_staffAuthService.isLoggedIn && isStaffRoute) {
          return '/staff-login';
        }

        if (_staffAuthService.isLoggedIn && isStaffLoginRoute) {
          return '/staff';
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
          builder: (context, state) => AdminLoginScreen(onAdminLogin: _loginAdmin),
        ),
        GoRoute(
          path: '/admin',
          builder: (context, state) => AnimatedBuilder(
            animation: _reportService,
            builder: (context, _) {
              return AdminDashboardScreen(
                totalReports: _reportService.totalReports,
                pendingReports: _reportService.pendingReports,
                resolvedReports: _reportService.resolvedReports,
                urgentReports: _reportService.urgentReports,
                onLogout: () {
                  _adminAuthService.logout();
                },
              );
            },
          ),
        ),
        GoRoute(
          path: '/admin/reports',
          builder: (context, state) => AnimatedBuilder(
            animation: _reportService,
            builder: (context, _) {
              return AdminAllReportsScreen(
                reports: _reportService.reports,
              );
            },
          ),
        ),
        GoRoute(
          path: '/admin/reports/:reportId',
          builder: (context, state) {
            final reportId = state.pathParameters['reportId'];
            if (reportId == null) return const SizedBox.shrink();

            return AnimatedBuilder(
              animation: _reportService,
              builder: (context, _) {
                final report = _reportService.getReportById(reportId);
                if (report == null) {
                  return Scaffold(
                    appBar: AppBar(title: const Text('Not Found')),
                    body: const Center(child: Text('Report not found')),
                  );
                }

                return AdminReportManagementScreen(
                  report: report,
                  onStatusChanged: (newStatus) {
                    _reportService.updateReportStatus(reportId, newStatus);
                  },
                  onStaffAssigned: (staffId, staffName) {
                    _reportService.assignStaff(reportId, staffId, staffName);
                  },
                  onNoteAdded: (note) {
                    _reportService.addReportNote(reportId, note);
                  },
                );
              },
            );
          },
        ),
        GoRoute(
          path: '/admin/staff',
          builder: (context, state) => AnimatedBuilder(
            animation: _adminStaffService,
            builder: (context, _) {
              return AdminStaffManagementScreen(
                staffMembers: _adminStaffService.staffMembers,
                onAddStaff: _adminStaffService.addStaff,
                onToggleStatus: _adminStaffService.toggleStaffStatus,
                onEditStaff: _adminStaffService.editStaffDetails,
              );
            },
          ),
        ),
        GoRoute(
          path: '/staff-login',
          builder: (context, state) => StaffLoginScreen(onStaffLogin: _loginStaff),
        ),
        GoRoute(
          path: '/staff',
          builder: (context, state) {
            return AnimatedBuilder(
              animation: _reportService,
              builder: (context, _) {
                final staffId = _staffAuthService.currentStaffId;
                if (staffId == null) return const SizedBox.shrink();

                final staffReports = _reportService.reports
                    .where((r) => r.assignedStaffId == staffId)
                    .toList();
                
                final pendingTasks = staffReports
                    .where((r) => r.status != ReportStatus.resolved && r.status != ReportStatus.rejected)
                    .length;
                final urgentTasks = staffReports
                    .where((r) => r.status != ReportStatus.resolved && r.status != ReportStatus.rejected && r.urgency == ReportUrgency.high)
                    .length;

                return StaffDashboardScreen(
                  pendingTasks: pendingTasks,
                  urgentTasks: urgentTasks,
                  onLogout: () {
                    _staffAuthService.logout();
                  },
                );
              },
            );
          },
        ),
        GoRoute(
          path: '/staff/assignments',
          builder: (context, state) {
            return AnimatedBuilder(
              animation: _reportService,
              builder: (context, _) {
                final staffId = _staffAuthService.currentStaffId;
                if (staffId == null) return const SizedBox.shrink();

                final staffReports = _reportService.reports
                    .where((r) => r.assignedStaffId == staffId)
                    .toList();

                return StaffAssignedReportsScreen(reports: staffReports);
              },
            );
          },
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

  Future<String?> _loginAdmin({
    required String email,
    required String password,
  }) async {
    final success = await _adminAuthService.login(
      email: email,
      password: password,
    );

    if (success) {
      // Load all reports so the admin sees every student's data from
      // Firestore, not just the in-memory seed list.
      await _reportService.loadReports();
      return null;
    }

    return _adminAuthService.errorMessage ?? 'Could not sign in as Admin.';
  }

  Future<String?> _loginStaff({
    required String email,
    required String password,
  }) async {
    final success = await _staffAuthService.login(
      email: email,
      password: password,
    );

    if (success) {
      // Load all reports so the staff member sees the ones assigned to them
      // from Firestore, not just the in-memory seed list.
      await _reportService.loadReports();
      return null;
    }

    return _staffAuthService.errorMessage ?? 'Could not sign in as Staff.';
  }

  @override
  void dispose() {
    _router.dispose();
    _authService.dispose();
    _adminAuthService.dispose();
    _staffAuthService.dispose();
    _reportService.dispose();
    _adminStaffService.dispose();
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
