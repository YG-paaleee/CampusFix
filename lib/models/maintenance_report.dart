import 'report_options.dart';

class MaintenanceReport {
  const MaintenanceReport({
    required this.studentUid,
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

  final String studentUid;
  final String studentId;
  final String reportId;
  final DateTime submittedAt;
  final String title;
  final String location;
  final ReportCategory category;
  final ReportUrgency urgency;
  final ReportStatus status;
  final String description;

  factory MaintenanceReport.fromJson(Map<String, dynamic> json) {
    return MaintenanceReport(
      studentUid: json['studentUid']?.toString() ?? '',
      studentId: json['studentId']?.toString() ?? '',
      reportId: json['reportId']?.toString() ?? '',
      submittedAt: _readDate(json['submittedAt']),
      title: json['title']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      category: _enumFromName(
        ReportCategory.values,
        json['category']?.toString(),
        ReportCategory.others,
      ),
      urgency: _enumFromName(
        ReportUrgency.values,
        json['urgency']?.toString(),
        ReportUrgency.medium,
      ),
      status: _enumFromName(
        ReportStatus.values,
        json['status']?.toString(),
        ReportStatus.submitted,
      ),
      description: json['description']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentUid': studentUid,
      'studentId': studentId,
      'reportId': reportId,
      'submittedAt': submittedAt.toIso8601String(),
      'title': title,
      'location': location,
      'category': category.name,
      'urgency': urgency.name,
      'status': status.name,
      'description': description,
    };
  }
}

T _enumFromName<T extends Enum>(List<T> values, String? name, T fallback) {
  for (final value in values) {
    if (value.name == name) {
      return value;
    }
  }

  return fallback;
}

DateTime _readDate(Object? value) {
  if (value is DateTime) {
    return value;
  }

  if (value is String) {
    return DateTime.tryParse(value) ?? DateTime.now();
  }

  try {
    final date = (value as dynamic).toDate();
    if (date is DateTime) {
      return date;
    }
  } catch (_) {
    // Firestore is not configured in tests, so keep parsing tolerant.
  }

  return DateTime.now();
}
