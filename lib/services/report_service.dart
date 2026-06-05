import 'package:flutter/foundation.dart';

import '../models/maintenance_report.dart';
import '../models/report_options.dart';

class ReportService extends ChangeNotifier {
  final List<MaintenanceReport> _reports = [
    MaintenanceReport(
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

  List<MaintenanceReport> reportsForStudent(String studentId) {
    final reports =
        _reports.where((report) => report.studentId == studentId).toList()
          ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));

    return List.unmodifiable(reports);
  }

  MaintenanceReport? findStudentReport({
    required String studentId,
    required String reportId,
  }) {
    for (final report in _reports) {
      if (report.studentId == studentId && report.reportId == reportId) {
        return report;
      }
    }

    return null;
  }

  void addReport(MaintenanceReport report) {
    _reports.insert(0, report);
    notifyListeners();
  }

  String get nextReportId {
    final nextNumber = _reports.length + 1;
    return 'CF-${nextNumber.toString().padLeft(4, '0')}';
  }
}
