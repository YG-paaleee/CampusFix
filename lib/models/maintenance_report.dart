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
    this.assignedStaffId,
    this.assignedStaffName,
    this.notes = const [],
    this.resolutionNote,
    this.resolutionImage,
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
  final String? assignedStaffId;
  final String? assignedStaffName;
  final List<String> notes;

  /// Staff's completion note and an optional base64-encoded evidence photo.
  final String? resolutionNote;
  final String? resolutionImage;

  MaintenanceReport copyWith({
    String? studentUid,
    String? studentId,
    String? reportId,
    DateTime? submittedAt,
    String? title,
    String? location,
    ReportCategory? category,
    ReportUrgency? urgency,
    ReportStatus? status,
    String? description,
    String? assignedStaffId,
    String? assignedStaffName,
    List<String>? notes,
    String? resolutionNote,
    String? resolutionImage,
  }) {
    return MaintenanceReport(
      studentUid: studentUid ?? this.studentUid,
      studentId: studentId ?? this.studentId,
      reportId: reportId ?? this.reportId,
      submittedAt: submittedAt ?? this.submittedAt,
      title: title ?? this.title,
      location: location ?? this.location,
      category: category ?? this.category,
      urgency: urgency ?? this.urgency,
      status: status ?? this.status,
      description: description ?? this.description,
      assignedStaffId: assignedStaffId ?? this.assignedStaffId,
      assignedStaffName: assignedStaffName ?? this.assignedStaffName,
      notes: notes ?? this.notes,
      resolutionNote: resolutionNote ?? this.resolutionNote,
      resolutionImage: resolutionImage ?? this.resolutionImage,
    );
  }

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
      assignedStaffId: json['assignedStaffId']?.toString(),
      assignedStaffName: json['assignedStaffName']?.toString(),
      notes: (json['notes'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      resolutionNote: json['resolutionNote']?.toString(),
      resolutionImage: json['resolutionImage']?.toString(),
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
      if (assignedStaffId != null) 'assignedStaffId': assignedStaffId,
      if (assignedStaffName != null) 'assignedStaffName': assignedStaffName,
      'notes': notes,
      if (resolutionNote != null) 'resolutionNote': resolutionNote,
      if (resolutionImage != null) 'resolutionImage': resolutionImage,
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
