import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/maintenance_report.dart';
import '../models/report_options.dart';
import '../models/student_user.dart';

class ReportService extends ChangeNotifier {
  ReportService({FirebaseFirestore? firestore}) : _firestore = firestore {
    _reports.addAll(_seedReports);
  }

  final FirebaseFirestore? _firestore;
  final List<MaintenanceReport> _reports = [];
  int _localIdSequence = 0;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isFirebaseEnabled => _firestore != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  static final List<MaintenanceReport> _seedReports = [
    MaintenanceReport(
      studentUid: 'demo-student',
      studentId: '2026-0001',
      reportId: 'CF-0001',
      submittedAt: DateTime(2026, 6, 1),
      title: 'Broken classroom chair',
      location: 'Room 204',
      category: ReportCategory.classroom,
      urgency: ReportUrgency.medium,
      status: ReportStatus.submitted,
      description: 'One chair near the back row has a broken leg.',
    ),
    MaintenanceReport(
      studentUid: 'demo-student',
      studentId: '2026-0001',
      reportId: 'CF-0002',
      submittedAt: DateTime(2026, 6, 2),
      title: 'Projector not working',
      location: 'IT Lab 1',
      category: ReportCategory.itEquipment,
      urgency: ReportUrgency.high,
      status: ReportStatus.inProgress,
      description:
          'The projector turns on but does not display the computer screen.',
    ),
    MaintenanceReport(
      studentUid: 'demo-student',
      studentId: '2026-0001',
      reportId: 'CF-0003',
      submittedAt: DateTime(2026, 6, 3),
      title: 'Leaking faucet',
      location: 'Restroom A',
      category: ReportCategory.plumbing,
      urgency: ReportUrgency.low,
      status: ReportStatus.resolved,
      description: 'The sink faucet was continuously leaking.',
    ),
  ];

  Future<void> loadReports({StudentUser? student}) async {
    final firestore = _firestore;

    if (firestore == null) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      Query<Map<String, dynamic>> query = firestore.collection('reports');

      if (student != null) {
        query = query.where('studentUid', isEqualTo: student.uid);
      }

      final snapshot = await query.get();

      _reports
        ..clear()
        ..addAll(
          snapshot.docs.map((doc) {
            return MaintenanceReport.fromJson({
              ...doc.data(),
              'reportId': doc.data()['reportId'] ?? doc.id,
            });
          }),
        );
    } catch (error) {
      _errorMessage = 'Could not load Firebase reports.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<MaintenanceReport> reportsForStudent(StudentUser student) {
    final reports =
        _reports.where((report) => _belongsToStudent(report, student)).toList()
          ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));

    return List.unmodifiable(reports);
  }

  MaintenanceReport? findStudentReport({
    required StudentUser student,
    required String reportId,
  }) {
    for (final report in _reports) {
      if (_belongsToStudent(report, student) && report.reportId == reportId) {
        return report;
      }
    }

    return null;
  }

  Future<void> addReport(MaintenanceReport report) async {
    _reports.insert(0, report);
    notifyListeners();

    final firestore = _firestore;

    if (firestore == null) {
      return;
    }

    try {
      await firestore
          .collection('reports')
          .doc(_documentIdForReport(report))
          .set(report.toJson());
      _errorMessage = null;
    } catch (error) {
      _errorMessage = 'Could not save this report to Firebase.';
      notifyListeners();
    }
  }

  String createReportId() {
    final firestore = _firestore;

    if (firestore != null) {
      return 'CF-${firestore.collection('reports').doc().id}';
    }

    final timestamp = DateTime.now()
        .toUtc()
        .microsecondsSinceEpoch
        .toRadixString(36)
        .toUpperCase();
    _localIdSequence += 1;
    return 'CF-$timestamp-${_localIdSequence.toString().padLeft(3, '0')}';
  }

  bool _belongsToStudent(MaintenanceReport report, StudentUser student) {
    return report.studentUid == student.uid ||
        (report.studentUid.isEmpty && report.studentId == student.studentId);
  }

  String _documentIdForReport(MaintenanceReport report) {
    if (report.studentUid.isEmpty) {
      return report.reportId;
    }

    return '${report.studentUid}_${report.reportId}';
  }
}
