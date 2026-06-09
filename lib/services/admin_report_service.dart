import 'package:flutter/foundation.dart';
import '../models/maintenance_report.dart';
import '../models/report_options.dart';

class AdminReportService extends ChangeNotifier {
  List<MaintenanceReport> _reports = [];

  AdminReportService() {
    _generateMockData();
  }

  List<MaintenanceReport> get reports => _reports;

  int get totalReports => _reports.length;
  int get pendingReports => _reports.where((r) => r.status == ReportStatus.submitted).length;
  int get inProgressReports => _reports.where((r) => r.status == ReportStatus.inProgress).length;
  int get resolvedReports => _reports.where((r) => r.status == ReportStatus.resolved).length;
  int get urgentReports => _reports.where((r) => r.urgency == ReportUrgency.high).length;

  MaintenanceReport? getReportById(String reportId) {
    try {
      return _reports.firstWhere((r) => r.reportId == reportId);
    } catch (_) {
      return null;
    }
  }

  void updateReportStatus(String reportId, ReportStatus newStatus) {
    final index = _reports.indexWhere((r) => r.reportId == reportId);
    if (index != -1) {
      _reports[index] = _reports[index].copyWith(status: newStatus);
      notifyListeners();
    }
  }

  void assignStaff(String reportId, String staffId, String staffName) {
    final index = _reports.indexWhere((r) => r.reportId == reportId);
    if (index != -1) {
      _reports[index] = _reports[index].copyWith(
        assignedStaffId: staffId,
        assignedStaffName: staffName,
      );
      notifyListeners();
    }
  }

  void addReportNote(String reportId, String note) {
    if (note.trim().isEmpty) return;
    final index = _reports.indexWhere((r) => r.reportId == reportId);
    if (index != -1) {
      final currentNotes = List<String>.from(_reports[index].notes);
      currentNotes.add(note.trim());
      _reports[index] = _reports[index].copyWith(notes: currentNotes);
      notifyListeners();
    }
  }

  void _generateMockData() {
    _reports = [
      MaintenanceReport(
        studentUid: 'u1',
        studentId: '1001',
        reportId: 'r1',
        submittedAt: DateTime.now().subtract(const Duration(days: 2)),
        title: 'Broken projector in Room 301',
        location: 'Building A, Room 301',
        category: ReportCategory.itEquipment,
        urgency: ReportUrgency.high,
        status: ReportStatus.submitted,
        description: 'The projector is not turning on despite being plugged in.',
      ),
      MaintenanceReport(
        studentUid: 'u2',
        studentId: '1002',
        reportId: 'r2',
        submittedAt: DateTime.now().subtract(const Duration(hours: 5)),
        title: 'Leaking sink',
        location: 'Science Block Restroom',
        category: ReportCategory.plumbing,
        urgency: ReportUrgency.medium,
        status: ReportStatus.inProgress,
        description: 'Water is dripping constantly from the second sink.',
      ),
      MaintenanceReport(
        studentUid: 'u3',
        studentId: '1003',
        reportId: 'r3',
        submittedAt: DateTime.now().subtract(const Duration(days: 1)),
        title: 'Flickering lights',
        location: 'Library, 2nd Floor',
        category: ReportCategory.electrical,
        urgency: ReportUrgency.low,
        status: ReportStatus.resolved,
        description: 'Several fluorescent tubes are flickering.',
      ),
      MaintenanceReport(
        studentUid: 'u4',
        studentId: '1004',
        reportId: 'r4',
        submittedAt: DateTime.now().subtract(const Duration(minutes: 30)),
        title: 'No internet connection',
        location: 'Cafeteria',
        category: ReportCategory.itEquipment,
        urgency: ReportUrgency.high,
        status: ReportStatus.submitted,
        description: 'Wi-Fi access point appears to be dead.',
      ),
      MaintenanceReport(
        studentUid: 'u5',
        studentId: '1005',
        reportId: 'r5',
        submittedAt: DateTime.now().subtract(const Duration(days: 3)),
        title: 'Broken chair',
        location: 'Building B, Room 105',
        category: ReportCategory.classroom,
        urgency: ReportUrgency.low,
        status: ReportStatus.submitted,
        description: 'One of the chairs has a broken leg.',
      ),
    ];
    notifyListeners();
  }
}
