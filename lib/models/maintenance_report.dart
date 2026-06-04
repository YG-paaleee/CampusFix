class MaintenanceReport {
  const MaintenanceReport({
    required this.reportId,
    required this.submittedAt,
    required this.title,
    required this.location,
    required this.category,
    required this.urgency,
    required this.status,
    required this.description,
  });

  final String reportId;
  final DateTime submittedAt;
  final String title;
  final String location;
  final String category;
  final String urgency;
  final String status;
  final String description;
}
