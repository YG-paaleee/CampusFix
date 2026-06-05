import 'report_options.dart';

class MaintenanceReport {
  const MaintenanceReport({
    required this.studentId,
    required this.reportId,
    required this.submittedAt,
    required this.title,
    required this.location,
    required this.category,
    required this.urgency,
    required this.status,
    required this.description,
  });

  final String studentId;
  final String reportId;
  final DateTime submittedAt;
  final String title;
  final String location;
  final ReportCategory category;
  final ReportUrgency urgency;
  final ReportStatus status;
  final String description;
}
